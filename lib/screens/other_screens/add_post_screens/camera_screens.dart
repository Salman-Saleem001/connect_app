import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/media_preview.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/video_edit_screen.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../widgets/appbars.dart';

/// Camera example home widget.
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function? onSend;

  const CameraScreen({
    super.key,
    required this.cameras,
    this.fromMessage = false,
    this.onSend,
  });

  final bool fromMessage;

  @override
  State<CameraScreen> createState() {
    return _CameraScreenState();
  }
}

void _logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraType cameraType = CameraType.rear;
  CustomMediaType mediaType = CustomMediaType.video;
  VideoStates videoState = VideoStates.idle;
  var flashMode = FlashMode.off;
  double paddingValue = 0.0;
  late Timer timer;
  int selectedTime = 45;
  int recordedSeconds = 0;

  bool get _isImage => mediaType == CustomMediaType.image;

  bool get _isRecording => videoState == VideoStates.recording;
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  recordingTimer() {
    log(recordedSeconds.toString());
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isRecording) {
        if (recordedSeconds == selectedTime) {
          stopVideoRecording().then((XFile? file) {
            if (file != null) {
              videoFile = file;
              Get.off(() => VideoEditScreen(
                filePath: file.path,
                isVideo: true,
                fromMessage: widget.fromMessage,
                onSend: widget.onSend,
              ));
              paddingValue = 0;
              videoState = VideoStates.idle;
              recordedSeconds = 0;
              t.cancel();
            }
          });

        } else {
          recordedSeconds += 1;

        }
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      onNewCameraSelected(widget.cameras[0]);
    }
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller?.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _cameraPreviewWidget(),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: customAppBarTransparent(
                      backButton: true,
                      title: 'Create Video',
                      marginTop: 25,
                    ),
                  ),
                  _topToggleOptions(),
                  _captureButton(),
                  Positioned(
                      bottom: 50,
                      right: 40,
                      child: InkWell(
                        onTap: _getMediaFromGallery,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/ic_upload.png',
                              height: 30,
                            ),
                            Text(
                              'Upload',
                              style: regularText(size: 12)
                                  .copyWith(color: Colors.white),
                            )
                          ],
                        ),
                      )),
                  if(!_isRecording)
                  Positioned(
                    bottom: 45,
                    left: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(.25),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          10.wp,
                          TimeSelectedText(
                            selectedTime: selectedTime,
                            onTap: () {
                              selectedTime = 30;
                              setState(() {});
                            },
                            title: '30',
                          ),
                          10.wp,
                          TimeSelectedText(
                            selectedTime: selectedTime,
                            onTap: () {
                              selectedTime = 45;
                              setState(() {});
                            },
                            title: '45',
                          ),
                          10.wp,
                          TimeSelectedText(
                            selectedTime: selectedTime,
                            onTap: () {
                              selectedTime = 60;
                              setState(() {});
                            },
                            title: '60',
                          ),
                          10.wp,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getMediaFromGallery() async {
    final ImagePicker picker = ImagePicker();
    if (_isImage) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        int sizeInBytes = file.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 8) {
          Global.showToastAlert(
              context: Get.overlayContext!,
              strTitle: "",
              strMsg: 'Image size must be less than 8 MB',
              toastType: TOAST_TYPE.toastError);
        } else {
          Get.off(() => MediaPreviewScreen(
                filePath: image.path,
                fromMessage: widget.fromMessage,
                onSend: widget.onSend,
              ));
        }
      }
    } else {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final file = File(video.path);
        int sizeInBytes = file.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 10) {
          Global.showToastAlert(
              context: Get.overlayContext!,
              strTitle: "",
              strMsg: 'Video size must be less than 10 MB',
              toastType: TOAST_TYPE.toastError);
        } else {
          Get.off(() => MediaPreviewScreen(
                filePath: video.path,
                isVideo: true,
                fromMessage: widget.fromMessage,
                onSend: widget.onSend,
              ));
        }
      }
    }
  }

  Positioned _captureButton() {
    return Positioned(
        bottom: 30,
        left: 0,
        right: 0,
        child: Column(
          children: [
            if (!_isImage)
              Text(
                _getTimeString(),
                style: regularText().copyWith(color: Colors.white),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 75,
                  width: 75,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: AnimatedPadding(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(paddingValue),
                            curve: Curves.easeInOut,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    _isImage
                                        ? Colors.white
                                        : HexColor('#F15A31'),
                                  ),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states
                                              .contains(MaterialState.pressed)
                                          ? Colors.grey.shade400
                                          : null;
                                    },
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                  )),
                              onPressed:
                                  _isImage ? _onPressImage : _onPressVideo,
                              child: const Text(''),
                            ))),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  _onPressVideo() {
    if (VideoStates.idle == videoState) {
      setState(() {
        paddingValue = 13;
        videoState = VideoStates.recording;
        onVideoRecordButtonPressed();
        recordingTimer();
      });
    } else {
      setState(() {
        paddingValue = 0;
        videoState = VideoStates.idle;
        onStopButtonPressed();
      });
    }
  }

  void _onPressImage() {
    final CameraController? cameraController = controller;
    if (cameraController != null &&
        cameraController.value.isInitialized &&
        !cameraController.value.isRecordingVideo) {
      onTakePictureButtonPressed();
    }
  }

  Positioned _topToggleOptions() {
    return Positioned(
        left: 20,
        top: 200,
        child: Column(
          children: [
            if (widget.cameras.length > 1)
              _iconOption('assets/images/ic_flip.png', 'Flip', () {
                if (cameraType == CameraType.rear) {
                  onNewCameraSelected(widget.cameras[1]);
                  cameraType = CameraType.front;
                } else {
                  onNewCameraSelected(widget.cameras[0]);
                  cameraType = CameraType.rear;
                }
              }),
            if (widget.cameras.length > 1)
              _iconOption(_getFlashIcon(flashMode), 'Flash', () {
                if (flashMode == FlashMode.off) {
                  flashMode = FlashMode.auto;
                  setState(() {});
                  setFlashMode(FlashMode.auto);
                } else if (flashMode == FlashMode.auto) {
                  flashMode = FlashMode.torch;
                  setState(() {});
                  setFlashMode(FlashMode.torch);
                } else if (flashMode == FlashMode.torch) {
                  flashMode = FlashMode.off;
                  setState(() {});
                  setFlashMode(FlashMode.off);
                }
              }),
            if (!_isRecording)
              _iconOption(
                  _getMediaIcon(mediaType), _isImage ? 'Video' : 'Image', () {
                if (_isImage) {
                  setState(() {
                    mediaType = CustomMediaType.video;
                  });
                } else {
                  setState(() {
                    mediaType = CustomMediaType.image;
                  });
                }
              }),
          ],
        ));
  }

  SafeArea _iconOption(String icon, String title, Function onTap) {
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
              child: Image.asset(icon, color: Colors.grey, height: 25),
            ),
          ),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
        });
        if (file != null) {
          Get.off(() => MediaPreviewScreen(
                filePath: file.path,
                fromMessage: widget.fromMessage,
                onSend: widget.onSend,
              ));
        }
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {});
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        videoFile = file;

        Get.off(() => VideoEditScreen(
          filePath: file.path,
          isVideo: true,
          fromMessage: widget.fromMessage,
          onSend: widget.onSend,
        ));
        // invoke(file);
        // _startVideoPlayer();
      }
    });
  }


  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    flashMode = mode;
    setState(() {});
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String _getMediaIcon(CustomMediaType videoMode) {
    switch (videoMode) {
      case CustomMediaType.image:
        return 'assets/images/video.png';
      case CustomMediaType.video:
        return 'assets/images/image.png';
      case CustomMediaType.audio:
        return 'assets/images/video.png';
    }
  }

  String _getFlashIcon(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return 'assets/images/ic_falsh_off.png';
      case FlashMode.auto:
        return 'assets/images/ic_falsh_auto.png';
      case FlashMode.always:
        return 'assets/images/ic_flash_on.png';
      case FlashMode.torch:
        return 'assets/images/ic_flash_on.png';
    }
    // return 'assets/images/ic_falsh_off.png';
  }

  String _getTimeString() {
    if (recordedSeconds < 10) {
      return '00:0$recordedSeconds';
    }
    return '00:$recordedSeconds';
  }
}

class TimeSelectedText extends StatelessWidget {
  const TimeSelectedText({
    super.key,
    required this.selectedTime,
    required this.onTap,
    required this.title,
  });

  final int selectedTime;
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: ColoredBox(
        color: selectedTime == int.parse(title) ? AppColors.white: Colors.transparent,
        child: GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: selectedTime == int.parse(title) ? 18 : 14,
                  color: selectedTime == int.parse(title)?Colors.black:AppColors.white),
            ).paddingAll(5),
        ),
      ),
    ).paddingSymmetric(vertical: 5);
  }
}

T? _ambiguate<T>(T? value) => value;
