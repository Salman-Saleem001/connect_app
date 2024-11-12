import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ignore: must_be_immutable
class VideoView extends StatefulWidget {
  final bool isLocal;
  final String url;
  const VideoView({Key? key, this.isLocal = false, this.url = ''})
      : super(key: key);

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isLocal) {
      _controller = VideoPlayerController.file(File(widget.url))
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true);
    } else {
      _controller = VideoPlayerController.network(widget.url.isEmpty
          ? 'https://vod-progressive.akamaized.net/exp=1664615196~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F520%2F16%2F402600916%2F1720731425.mp4~hmac=811caaa84f656f88e3d01903966aa9034544d0c2d658ac8deada26228d2937aa/vimeo-prod-skyfire-std-us/01/520/16/402600916/1720731425.mp4'
          : widget.url)
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(_controller),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && mounted) {
          _controller.pause();
        } else if (visibility.visibleFraction > 0.8 && mounted) {
          _controller.play();
          setState(() {});
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: _controller.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: _controller.value.aspectRatio > 0.8
                              ? BoxFit.contain
                              : BoxFit.contain,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      if (!_controller.value.isPlaying)
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: Center(
                            child: Image.asset(
                              'assets/images/ic_play.png',
                              height: 60,
                              color: Colors.black87,
                            ),
                          ),
                        )
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
