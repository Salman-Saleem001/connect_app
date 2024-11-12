import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connect_app/extensions/string_extensions.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:tapioca/tapioca.dart';

import '../../../controllers/chat/chat_detail_controller.dart';
import '../../../globals/video_view.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/appbars.dart';
import '../../../widgets/primary_button.dart';
import 'add_post_screen.dart';

class VideoEditScreen extends StatefulWidget {
  final String filePath;
  final bool isVideo;
  final bool fromMessage;
  final Function? onSend;

  const VideoEditScreen(
      {super.key, required this.filePath, this.isVideo = false, required this.fromMessage, this.onSend});

  @override
  State<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends State<VideoEditScreen> {
  final navigatorKey = GlobalKey<NavigatorState>();
  var chatController = Get.put(ChatDetailController());
  Color? filterColor;
  bool isLoading = false;
  bool audioClicked = false;
  late bool showTextField;
  late bool showFilters;
  String? values;
  String? audioUrlName;
  String? selectedAudio;
  String? outputUrlName;
  static const EventChannel _channel = EventChannel('video_editor_progress');
  late StreamSubscription _streamSubscription;
  int processPercentage = 0;

  @override
  void initState() {
    super.initState();
    showTextField = false;
    filterColor = null;
    showFilters = false;
    values = null;
    storagePermissionRequest();
    _enableEventReceiver();
  }

  @override
  void dispose() {
    super.dispose();
    filterColor = null;
    _disableEventReceiver();
  }

  Future<void> storagePermissionRequest() async {
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      debugPrint('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      debugPrint('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      debugPrint('Permission Permanently Denied');
    }
  }

  void _enableEventReceiver() {
    _streamSubscription =
        _channel.receiveBroadcastStream().listen((dynamic event) {
      debugPrint("$event");
      setState(() {
        processPercentage = (event.toDouble() * 100).round();
      });
    }, onError: (dynamic error) {
      debugPrint('Received error: ${error.message}');
    }, cancelOnError: true);
  }

  Future<File> loadAssetFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.mp3');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  Future<void> audioFilePick(String path) async {
    dynamic audioFile = await loadAssetFile('assets/audio/$selectedAudio.mp3');
    if (audioFile != null) {
      audioUrlName = audioFile?.path;
      debugPrint(">>>>> ${audioFile?.path}");
      await mergeFiles(path);
    } else {
      // User canceled the picker
    }
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> mergeFiles(String filePath) async {
    final tempDir = await getTemporaryDirectory();
    String outputUrl =
        '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
    if (await File(outputUrl).exists()) {
      debugPrint("Exist");
      File(outputUrl).delete();
    }
    String commandToExecute =
        '-i $audioUrlName -i $filePath -c copy $outputUrl';
    FFmpegKit.execute(commandToExecute).then((value) {
      setState(() {
        outputUrlName = outputUrl;
      });

      debugPrint("DURUM: $value");
    });
    debugPrint("DURUM: ${await Directory(outputUrlName ?? '').exists()}");
  }

  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var width = context.width;
    var height = context.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          widget.isVideo
              ? SizedBox.expand(child: VideoView(isLocal: true, url: widget.filePath,fit: BoxFit.none,))
              : Image.file(
                  File(widget.filePath),
                ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: customAppBarTransparent(
              backButton: true,
              title: 'Edit ${widget.isVideo ? 'Video' : 'Image'} ',
              marginTop: 25,
            ),
          ),
          if (filterColor != null)
            Positioned.fill(
              child: ColoredBox(
                  color: (filterColor ?? Colors.transparent).withOpacity(.4)),
            ),
          showTextField
              ? Center(
                  child: TextField(
                    autofocus: true,
                    onChanged: (val) {
                      values = val;
                    },
                    enableIMEPersonalizedLearning: true,
                    style: regularText(size: 24).copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    cursorColor: Colors.black,
                    maxLines: null,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Center(
                child: Text(
                    values ?? '',
                    textAlign: TextAlign.center,
                    style: regularText(size: 24).copyWith(
                      color: Colors.white,
                    ),
                  ),
              ),
          Positioned(
              right: 40,
              top: height / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.005,
                      ),
                      _iconOption('assets/images/text_icon.png', () {
                        setState(() {
                          showTextField = !showTextField;
                        });
                      }),
                      _iconOption('assets/images/music_icon.png', () async {
                        debugPrint("Here");
                        setState(() {
                          audioClicked = true;
                        });
                        AudioPlayer audioPlayer = AudioPlayer();
                        selectedAudio = null;
                        List<String>? audios = ['distant', 'stock', 'sunlit'];
                        showModalBottomSheet(
                            showDragHandle: true,
                            backgroundColor: Colors.black87,
                            context: context,
                            builder: (_) {
                              ValueNotifier<int> onClicked = ValueNotifier(-1);
                              ValueNotifier<String> selected =
                              ValueNotifier('');
                              return PopScope(
                                onPopInvokedWithResult: (val, results) {
                                  audioPlayer.stop();
                                  audios?.clear();
                                  audios = null;
                                  audioPlayer.dispose();
                                  onClicked.dispose();
                                  setState(() {
                                    audioClicked = false;
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 30),
                                        itemBuilder: (_, index) {
                                          return ValueListenableBuilder(
                                            valueListenable: selected,
                                            builder: (BuildContext context,
                                                String value, Widget? child) {
                                              return GestureDetector(
                                                behavior:
                                                HitTestBehavior.opaque,
                                                onTap: () {
                                                  selectedAudio =
                                                  audios?[index];
                                                  selected.value =
                                                      audios?[index] ?? '';
                                                  debugPrint(
                                                      "WORKING===> & assets/audio/$selectedAudio.mp3");
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                  child: ColoredBox(
                                                    color: selected.value ==
                                                        audios?[index]
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                            audios?[index]
                                                                .capitalizeText() ??
                                                                '',
                                                            style: regularText(size: 24).copyWith(
                                                                color: selected
                                                                    .value ==
                                                                    audios?[
                                                                    index]
                                                                    ? Colors
                                                                    .black
                                                                    : Colors
                                                                    .white),
                                                          ),
                                                          ValueListenableBuilder(
                                                            valueListenable:
                                                            onClicked,
                                                            builder:
                                                                (BuildContext
                                                            context,
                                                                int value,
                                                                Widget?
                                                                child) {
                                                              return GestureDetector(
                                                                behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                                onTap:
                                                                    () async {
                                                                  audioClicked =
                                                                  !audioClicked;
                                                                  if (audioClicked) {
                                                                    debugPrint(
                                                                        "$value");
                                                                    audioPlayer
                                                                        .stop();
                                                                  } else {
                                                                    audioPlayer.setAudioSource(
                                                                        AudioSource.asset(
                                                                            'assets/audio/${audios?[index]}.mp3'));
                                                                    audioPlayer
                                                                        .play();
                                                                  }
                                                                  if (onClicked
                                                                      .value ==
                                                                      index) {
                                                                    onClicked
                                                                        .value = -1;
                                                                  } else {
                                                                    onClicked
                                                                        .value =
                                                                        index;
                                                                  }
                                                                },
                                                                child: Icon(
                                                                  value == index
                                                                      ? Icons
                                                                      .pause
                                                                      : Icons
                                                                      .play_arrow,
                                                                  size: 24,
                                                                  color: selected
                                                                      .value ==
                                                                      audios?[
                                                                      index]
                                                                      ? Colors
                                                                      .black
                                                                      : Colors
                                                                      .white,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        separatorBuilder: (_, index) {
                                          return const SizedBox(
                                            height: 10,
                                          );
                                        },
                                        itemCount: audios?.length ?? 0),
                                    Positioned(
                                      right: 20,
                                      child: ValueListenableBuilder(
                                        valueListenable: selected,
                                        builder: (BuildContext context,String value, Widget? child) {
                                          if(value.isNotEmpty){
                                            return GestureDetector(
                                              onTap: (){
                                                Get.back();
                                              },
                                              child: const DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,

                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Icon(Icons.check,color: Colors.black,),
                                                ),
                                              ),
                                            );
                                          }else{
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                        debugPrint("Here is the val====>$audioClicked");
                      }),
                      _iconOption('assets/images/filters_icon.png', () {
                        setState(() {
                          showFilters = !showFilters;
                        });
                      }),
                      SizedBox(
                        height: height * 0.005,
                      ),
                    ],
                  ),
                ),
              )),
          if (showFilters)
            Positioned(
              width: width,
              height: height / 6,
              bottom: height / 12,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          filterColor = AppColors.defaultColors[index];
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/filter_picture.png',
                          fit: BoxFit.cover,
                          height: 50,
                          width: 100,
                          color: AppColors.defaultColors[index].withOpacity(.4),
                          colorBlendMode: BlendMode.overlay,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemCount: AppColors.defaultColors.length),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                color: Colors.white,
                padding:
                     EdgeInsets.symmetric(horizontal: !isLoading? 30: width/2.18, vertical: 20),
                width: double.infinity,
                child: !isLoading? PrimaryButton(
                    label: 'Save Changes',
                    onPress: () async {
                      debugPrint("clicked!");
                      setState(() {
                        isLoading = true;
                      });
                      List<TapiocaBall> tapiocaBalls = [];

                      if (filterColor != null) {
                        tapiocaBalls.add(
                            TapiocaBall.filterFromColor(filterColor!, 0.4));
                      }

                      if (values != null && values?.isNotEmpty == true) {
                        TextPainter textPainter = TextPainter(
                          text: TextSpan(
                            text: values,
                            style: const TextStyle(fontSize: 24),
                          ),
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout();
                        int textWidth = textPainter.width.toInt();
                        int textHeight = textPainter.height.toInt();

                        int xPosition = (width / 2).toInt() - textWidth ~/ 2;
                        int yPosition = (height / 2).toInt() - textHeight ~/ 2;
                        tapiocaBalls.add(
                          TapiocaBall.textOverlay(values ?? 'Hello', xPosition,
                              yPosition, 24, const Color(0xffffc0cb)),
                        );
                      }
                      if (tapiocaBalls.isNotEmpty) {
                        try {
                          var tempDir = await getTemporaryDirectory();
                          final path =
                              '${tempDir.path}/result_${DateTime.now().millisecondsSinceEpoch}.mp4';
                          debugPrint(
                              "will start in Path==>${outputUrlName ?? widget.filePath}");
                          final cup =
                              Cup(Content(widget.filePath), tapiocaBalls);
                          await cup.suckUp(path).then((_) async {
                            debugPrint("finished");
                            setState(() {
                              processPercentage = 0;
                            });
                            debugPrint(path);
                            if (selectedAudio != null) {
                              await audioFilePick(path);
                            }
                            if(widget.fromMessage){
                              await chatController.uploadToStorage(File(outputUrlName != null
                                  ? outputUrlName ?? ''
                                  : widget.filePath,)).then((val)async{
                                if(val){
                                  await widget.onSend!();
                                  Get.back(result: val);
                                }
                              });

                            }else{
                              Get.off(() => CreatePostScreen(
                                filePath: outputUrlName != null
                                    ? outputUrlName ?? ''
                                    : path,
                                isVideo: widget.isVideo,
                              ),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }).catchError((e) {
                            debugPrint('Got error: $e');
                          });
                        } on PlatformException {
                          debugPrint("error!!!!");
                        }
                      } else {
                        Get.off(() => CreatePostScreen(
                              filePath: outputUrlName ?? widget.filePath,
                              isVideo: true,
                            ));
                      }
                      filterColor=null;
                      values= null;
                    }): const CircularProgressIndicator(color: Colors.red,),),
          ),
        ],
      ),
    );
  }

  _iconOption(String icon, Function() onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
        child: Image.asset(
          icon,
          color: Colors.grey,
          scale: 1,
        ),
      ),
    );
  }
}
