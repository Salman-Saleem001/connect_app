import 'dart:developer';

import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/globals/video_view.dart';
import 'package:connect_app/models/stories_model.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:video_player/video_player.dart';

import '../../../controllers/mainScreen_controllers/stories_controller.dart';
import '../../../utils/login_details.dart';

class StatusView extends StatefulWidget {
  final List<MyStories> statuses;
  final int initialIndex;

  const StatusView({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  late VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  double _videoDuration = 5.0;
  late final StoriesController storiesController;
  @override
  void initState() {
    storiesController = Get.put(StoriesController());
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _videoController = null;
    _initializeStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeStatus() {
    log("current Index==> $_currentIndex");
    final status = widget.statuses[_currentIndex];
    if (status.mediaType == 'video') {
      _initializeVideo(status.media ?? '');
    } else {
      _startImageProgress();
    }
  }

  void _initializeVideo(String videoUrl) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoController?.initialize().then((_) {
      _videoDuration = _videoController?.value.duration.inMilliseconds.toDouble() ?? 5000;
      _startVideoProgress();
      setState(() {
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      debugPrint('Error initializing video: $error');
      _startImageProgress();
    });
  }

  void _startImageProgress() {
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _progressController.forward().then((_) {
      _nextStatus();
    });
  }

  void _startVideoProgress() {
    _progressController = AnimationController(
      duration: Duration(milliseconds: _videoDuration.toInt()),
      vsync: this,
    );
    _progressController.forward().then((_) {
      log("Next Status===> $_currentIndex");
      _nextStatus();
    });
  }

  void _nextStatus() {
    if (_currentIndex < widget.statuses.length - 1) {
      _initializeStatus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
    storiesController.viewStories(
        index: _currentIndex,
        isSelf: widget.statuses[_currentIndex].user?.id == Get.find<UserDetail>().userData.user?.id);
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    log("Page changed getting called");
    setState(() {
      _currentIndex = index;
      _isVideoInitialized = false;
    });
    _progressController.dispose();
    _videoController?.dispose();
    _initializeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.statuses.length,
            itemBuilder: (context, index) {
              return _buildStatusPage(widget.statuses[index]);
            },
          ),
          // Progress bars at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 4,
                  child: Row(
                    children: List.generate(
                      widget.statuses.length,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppColors.bgGrey,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: index < _currentIndex
                                ? SizedBox(
                                    height: 5,
                                    child: ColoredBox(
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                : index == _currentIndex && _isVideoInitialized
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (BuildContext context, Widget? child) {
                                          return LinearProgressIndicator(
                                            value: _progressController.value,
                                            backgroundColor: AppColors.bgGrey,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryColor,
                                            ),
                                          );
                                        },
                                      )
                                    : SizedBox(
                                        height: 5,
                                        child: ColoredBox(color: AppColors.bgGrey),
                                      ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Header with user info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.bgGrey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: NetworkImageCustom(
                          image: widget.statuses[_currentIndex].user?.avatar,
                          fit: BoxFit.cover,
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.statuses[_currentIndex].user?.firstName ?? 'User',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatTime(
                              widget.statuses[_currentIndex].createdAt ?? '',
                            ),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Navigation areas and tap to next
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _previousStatus,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox(),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStatus,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          // Caption if available
          if (widget.statuses[_currentIndex].caption != null && widget.statuses[_currentIndex].caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.statuses[_currentIndex].caption ?? '',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPage(MyStories status) {
    if (status.mediaType == 'video') {
      return _buildVideoStatus(status);
    } else {
      return _buildImageStatus(status);
    }
  }

  Widget _buildVideoStatus(MyStories status) {
    return Center(
      child: _isVideoInitialized && _videoController != null
          ? VideoView(
              url: status.media ?? '',
              isFullScreen: true,
              isContained: false,
              videoController: _videoController,
            )
          : SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
    );
  }

  Widget _buildImageStatus(MyStories status) {
    return Container(
      color: AppColors.scaffoldBackgroundColor,
      child: Center(
        child: NetworkImageCustom(
          image: status.media,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _formatTime(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      Duration diff = DateTime.now().difference(dateTime);

      if (diff.inSeconds < 60) {
        return 'now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }
}
