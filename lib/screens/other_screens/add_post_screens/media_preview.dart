import 'dart:io';

import 'package:connect_app/extensions/string_extensions.dart';
import 'package:connect_app/globals/video_view.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/add_post_screen.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../controllers/chat/chat_detail_controller.dart';
import '../../../globals/database.dart';
import '../../../utils/text_styles.dart';

class MediaPreviewScreen extends StatefulWidget {
  final String filePath;
  final bool isVideo;
  final bool fromMessage;
  final Function? onSend;


  const MediaPreviewScreen(
      {super.key, required this.filePath, this.isVideo = false, this.fromMessage=false, this.onSend, });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  var chatController = Get.put(ChatDetailController());
  String? audioUrlName;
  String? outputUrlName;
  String? selectedAudio;
  late bool audioClicked;
  late bool isLoading;
  late Database database;


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

  @override
  void initState() {
    // TODO: implement initState
    audioClicked = false;
    isLoading= false;
    database= Database();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioUrlName=null;
    outputUrlName= null;
     selectedAudio= null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = context.height;
    var width = context.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                    child: widget.isVideo
                        ? VideoView(isLocal: true, url: widget.filePath)
                        : Image.file(File(widget.filePath))),
                if (!audioClicked)
                  Container(
                      color: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: !isLoading? 30: width/2.18, vertical: 20),
                      width: double.infinity,
                      child: isLoading? const CircularProgressIndicator(color: Colors.red,) :PrimaryButton(
                          label: !widget.fromMessage? 'Save Changes': 'Send Video',
                          onPress: () async {
                            setState(() {
                              isLoading= true;
                            });
                            if (selectedAudio != null) {
                              await audioFilePick(widget.filePath);
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
                              Get.to(() => CreatePostScreen(
                                filePath: outputUrlName != null
                                    ? outputUrlName ?? ''
                                    : widget.filePath,
                                isVideo: widget.isVideo,
                              ),
                              );
                            }
                            setState(() {
                              isLoading= false;
                            });
                            audioUrlName=null;
                            // outputUrlName= null;
                            selectedAudio= null;
                          }))
              ],
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
                                onPopInvoked: (val) {
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
                                                ).paddingSymmetric(),
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
                      SizedBox(
                        height: height * 0.005,
                      ),
                    ],
                  ),
                ),
              )),
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
        ],
      ),
    );
  }

  _iconOption(String icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
            child: Image.asset(icon, color: Colors.grey, height: 25),
          ),
        ),
      ),
    );
  }
}
