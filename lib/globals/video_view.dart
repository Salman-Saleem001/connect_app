import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/mainScreen_controllers/home_page_cont.dart';


// ignore: must_be_immutable
class VideoView extends StatefulWidget {
  final bool isLocal;
  final bool isAsset;
  final bool isContained;
  final bool isFullScreen;
  final String url;
  final String? country;
  final BoxFit? fit;
  final int? id;
  const VideoView(
      {Key? key,
      this.isContained = false,
      this.isLocal = false,
      this.url = '',
      this.isAsset = false,
      this.isFullScreen = false, this.country, this.id, this.fit, })
      : super(key: key);

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;

  late Animation controller;

  @override
  void initState() {
    play = false;
    super.initState();

    if (widget.isAsset) {
      _controller = VideoPlayerController.asset(widget.url,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true);
    } else if (widget.isLocal) {
      _controller = VideoPlayerController.file(File(widget.url))
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url.isEmpty
          ? 'http://3.123.149.87/storage/videos/QbKX9HXAwWrwLYmgbHVRI944dTWUJ4FMrF8hg6XK.mp4'
          : widget.url),)
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true);
    }

    if(widget.id!=null){
      var homeController= Get.put(HomeFeedController());
      homeController.postView(widget.id??0, widget.country??'');
    }

  }

  var started = false;
  var play = false;
  void playVideo() {
    _controller.play();
    play = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        play = false;
      });
    });
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
          setState(() {
            started = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              playVideo();
            }
          });
        },
        child: Container(
          color: Colors.black,
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: _controller.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: _controller.value.aspectRatio > 0.9 ||
                                  widget.isContained
                              ? widget.fit??BoxFit.contain
                              : BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      if (!_controller.value.isPlaying && started)
                        const SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Center(
                            child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                radius: 30,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                )),
                          ),
                        ),
                      if (play)
                        const SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Center(
                            child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                radius: 30,
                                child: Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 30,
                                )),
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
