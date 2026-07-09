import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/controllers/chat/voice_recording_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_image_v2/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../globals/database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../models/chat_model.dart';
import '../../models/chat_model_data.dart';
import '../../models/local_chat_model.dart';
import '../../screens/main_screens/chat_view/widget/location_permission.dart';
import '../../services/audio_service.dart';
import '../../utils/audio_utils.dart';
import 'audio_player_controller.dart';

class ChatDetailController extends GetxController {
  bool mShowData = false;
  bool isShowLoader = false;
  bool isShowEmojis = false;
  String? videoUrl;

  // late io.Socket socket;

  Rx<ChatDataModel?> chatDataModel = Rx<ChatDataModel?>(null);
  String? thumbnail;
  RxBool isDataFetched = false.obs;
  List<LocalChatModel> alChat = [];
  Database dataBase = Database();
  int initialCount = 0;
  TextEditingController controllerMessage = TextEditingController();

  bool showSendButton = false;

  String imgProfilePic = '';
  String id = '';
  String userId = '';

  // Voice Recording
  late VoiceRecordingController voiceRecordingController;
  late AudioPlayerController audioPlayerController;
  bool isUploadingVoice = false;
  double uploadProgress = 0.0;

  @override
  void onInit() {
    super.onInit();
    voiceRecordingController = VoiceRecordingController();
    audioPlayerController = Get.put(AudioPlayerController(), permanent: false);
  }

  @override
  void onClose() {
    voiceRecordingController.dispose();
    // Don't dispose here - GetX will handle it
    try {
      Get.delete<AudioPlayerController>();
    } catch (e) {
      log('Error deleting AudioPlayerController: $e');
    }
    super.onClose();
  }

  void changeText(String strValue) {
    if (Global.checkNull(strValue) && strValue.trim().isNotEmpty) {
      showSendButton = true;
    } else {
      showSendButton = false;
    }
    update();
  }

  Future<void> generateThumbnail(String video) async {
    debugPrint("Generating thumbnail");
    final tempDir = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.webp';
    final thumbnailPath = '${tempDir.path}/$fileName';
    thumbnail = await VideoThumbnail.thumbnailFile(
      video: video,
      thumbnailPath: thumbnailPath,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    update();
  }

  Future<void> deleteSingleFile() async {
    try {
      // Get the path to the temporary directory

      // Construct the full path to the file

      final file = File(thumbnail ?? '');

      // Check if the file exists
      if (await file.exists()) {
        await file.delete();
        debugPrint("File deleted successfully: $thumbnail");
      } else {
        debugPrint("File not found: $thumbnail");
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
    } finally {
      thumbnail = null;
    }
  }

  Future<void> getSingleChatDetail({required String secondUserId, required int videoId}) async {
    isDataFetched.value = false;
    await dataBase.getSingleChatDetail(secondUserId: secondUserId, videoId: videoId).then((val) {
      if (val != null) {
        chatDataModel.value = ChatDataModel.fromJson(val);
        // update();
        userId = Database.userId == chatDataModel.value?.senderId
            ? chatDataModel.value?.receiverId ?? ''
            : chatDataModel.value?.senderId ?? '';
      }
    });
    // chatDataModel.value = ChatDataModel.fromJson();
    debugPrint(chatDataModel.value?.toJson().toString());
    isDataFetched.value = true;

    update();
  }

  void sendMessage({List<String> files = const <String>[]}) {
    if (controllerMessage.text.trim().isNotEmpty || files.isNotEmpty) {
      // Determine message type
      MessageType msgType = MessageType.text;
      if (files.isNotEmpty) {
        msgType = MessageType.image;
      }

      dataBase.sendMessage(
        chatRoomId: chatDataModel.value?.chatsId ?? '',
        model: ChatModel(
          from: Database.userId,
          to: userId,
          message: controllerMessage.text.trim(),
          files: files,
          timeStamp: Timestamp.now(),
          messageType: msgType,
        ),
      );
    }

    updateLastMessage(
        secondUser:
        (chatDataModel.value?.senderId ?? '') == Database.userId
            ? (chatDataModel.value?.receiverId ?? '')
            : (chatDataModel.value?.senderId ?? ''),
        videId: chatDataModel.value?.videoId ?? 0);
    controllerMessage.clear();
    showSendButton = false;
    update();
  }

  void updateLastMessage({
    required String secondUser,
    required int videId,
  }) {
    debugPrint('Update last time');
    dataBase.updateChatRoom(secondUser: secondUser, videId: videId);
  }

  dynamic getMessages({required String chatRoomId}) {
    return dataBase.getMessages(chatRoomId: chatRoomId);
  }

  Future<void> updateStatus({required String secondUserId, required String status, required int videoId}) async {
    await dataBase.setAcceptanceStatus(secondUserId: secondUserId, status: status, videoId: videoId).then((val) async {
      if (true) {
        await getSingleChatDetail(secondUserId: secondUserId, videoId: videoId);
      }
    });
  }

  void addEmojis(String strvalue) {
    controllerMessage.text = controllerMessage.text + strvalue;
    showSendButton = true;
    update();
  }

  void showEmoji() {
    isShowEmojis = isShowEmojis ? false : true;
    update();
  }

  void disableEmoji() {
    isShowEmojis = false;

    update();
  }

  List<String> emojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😅',
    '😂',
    '🤣',
    '🥲',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚'
  ];

  Future<void> imgFromCamera2() async {
    try {
      ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
      );
      imageCompressor([pickedFile!]);
    } catch (e) {
      debugPrint('image picker error: $e');
    }
  }

  var loading = false;

  Future<void> imageCompressor(List<XFile> selectedImage) async {
    try {
      loading = true;
      update();

      List<File> files = [];
      for (int i = 0; i < selectedImage.length; i++) {
        log('Processing image ${i + 1}/${selectedImage.length}: ${selectedImage[i].path}');

        // Check if file exists
        final File originalFile = File(selectedImage[i].path);
        if (!await originalFile.exists()) {
          log('ERROR: Image file does not exist: ${selectedImage[i].path}');
          throw Exception('Image file not found');
        }

        // Try to compress image, fallback to original if fails
        try {
          log('Attempting to compress image ${i + 1}...');
          File compressedFile =
              await FlutterNativeImage.compressImage(selectedImage[i].path, quality: 30, percentage: 50).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              log('Compression timeout, using original');
              return originalFile;
            },
          );

          files.add(compressedFile);
          log('Image ${i + 1} compressed successfully: ${compressedFile.path}');
        } catch (compressError) {
          log('⚠️ Compression failed for image $i, using original file: $compressError');
          // If compression fails, use original file
          files.add(originalFile);
          log('Using original file instead: ${originalFile.path}');
        }
      }

      uploadImage(files);
    } catch (e) {
      Future.error(e);
      return;
    }
  }

  Future<void> uploadImage(List<File> files) async {
    log('Uploading ${files.length} images');
    if (files.isEmpty) {
      loading = false;
      update();
      return;
    }

    try {
      loading = true;
      update();
      EasyLoading.show(status: 'Uploading ${files.length} photo(s)...');

      List<String> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'image_${timestamp}_$i.jpg';
        final filePath = 'chats/$id/images/$fileName';

        log('Uploading image $i: $filePath');

        // Upload to Firebase Storage
        final Reference ref = FirebaseStorage.instance.ref().child(filePath);
        final UploadTask uploadTask = ref.putFile(files[i]);

        // Track progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          EasyLoading.showProgress(
            progress,
            status: 'Uploading image ${i + 1}/${files.length} - ${(progress * 100).toStringAsFixed(0)}%',
          );
        });

        final TaskSnapshot taskSnapshot = await uploadTask.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            throw Exception('Upload timeout - please check your internet connection');
          },
        );
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        uploadedUrls.add(downloadUrl);
        log('Image uploaded: $downloadUrl');
      }

      log('Sending message to Firestore with ${uploadedUrls.length} images');

      // Send message with uploaded images
      sendMessage(files: uploadedUrls);


      loading = false;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('${files.length} photo(s) sent!');

      log('All images uploaded successfully');
    } catch (e) {
      log('Error uploading images: $e');
      loading = false;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to upload photos. Please try again.\n${e.toString()}",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  Future<void> createChatRoom(
      {required String secondUser,
      required String chatRoomId,
      required String userName,
      required String description,
      required String tags,
      required int videoId,
      required String avatar}) async {
    dataBase.createChatRoom(
        secondUser: secondUser,
        chatRoomId: chatRoomId,
        userName: userName,
        tags: tags,
        videoUrl: videoUrl ?? '',
        description: description,
        videId: videoId,
        userAvatar: avatar);
  }

  Future<bool> uploadToStorage(File file) async {
    videoUrl = await dataBase.uploadToStorage(file);

    if (videoUrl?.isNotEmpty == true) {
      debugPrint("Here is my Video==> $videoUrl");
      return true;
    } else {
      return false;
    }
  }

  Future<void> pickDocument() async {
    try {
      log('Opening file picker for documents...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        log('User cancelled file selection');
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileExtension = result.files.single.extension ?? '';

      log('File selected: $fileName, size: ${result.files.single.size} bytes');

      await uploadDocument(file, fileName, fileExtension);
    } catch (e) {
      log('Error picking document: $e');
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to pick file. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  Future<void> uploadDocument(File documentFile, String fileName, String extension) async {
    try {
      loading = true;
      update();

      log('Starting document upload: $fileName');

      // Check file size (25 MB limit for documents)
      final fileSize = await documentFile.length();
      log('Document file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      if (fileSize > 25 * 1024 * 1024) {
        loading = false;
        update();
        EasyLoading.dismiss();
        Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "File is too large. Maximum size is 25MB.",
          toastType: TOAST_TYPE.toastError,
        );
        return;
      }

      EasyLoading.show(status: 'Uploading document...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'doc_${timestamp}_$fileName';
      final filePath = 'chats/$id/documents/$uniqueFileName';

      log('Uploading to: $filePath');

      // Upload to Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(documentFile);

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        EasyLoading.showProgress(progress, status: 'Uploading ${(progress * 100).toStringAsFixed(0)}%');
        log('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final TaskSnapshot taskSnapshot = await uploadTask.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw Exception('Upload timeout - please check your internet connection');
        },
      );
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      log('Document uploaded successfully');

      // Send message with document
      await dataBase.sendMessage(
        chatRoomId: chatDataModel.value?.chatsId ?? '',
        model: ChatModel(
          from: Database.userId,
          to: userId,
          message: fileName,
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.document,
          voiceData: {'url': downloadUrl, 'fileName': fileName, 'fileSize': fileSize, 'fileExtension': extension},
        ),

      );

      updateLastMessage(
          secondUser:
          (chatDataModel.value?.senderId ?? '') == Database.userId
              ? (chatDataModel.value?.receiverId ?? '')
              : (chatDataModel.value?.senderId ?? ''),
          videId: chatDataModel.value?.videoId ?? 0);

      loading = false;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Document sent!');

      log('Document upload complete: $downloadUrl');
    } catch (e) {
      log('Error uploading document: $e');
      loading = false;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to upload document. Please try again.\n${e.toString()}",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  Future<void> imgFromGallery2() async {
    try {
      log('Opening gallery for photos...');
      ImagePicker picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

      if (pickedFiles.isEmpty) {
        log('User cancelled photo selection');
        return;
      }

      log('Selected ${pickedFiles.length} photos');
      await imageCompressor(pickedFiles);
    } catch (e) {
      log('Error picking images from gallery: $e');
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to select photos. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    try {
      ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(source: source);

      if (pickedFile != null) {
        await uploadVideo(File(pickedFile.path));
      }
    } catch (e) {
      log('Error picking video: $e');
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to pick video.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  /// Upload video to Firebase Storage
  Future<void> uploadVideo(File videoFile) async {
    try {
      loading = true;
      update();

      log('Starting video upload...');

      // Check file size (100 MB limit)
      final fileSize = await videoFile.length();
      log('Video file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      if (fileSize > 100 * 1024 * 1024) {
        loading = false;
        update();
        EasyLoading.dismiss();
        Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "Error",
          strMsg: "Video is too large. Maximum size is 100MB.",
          toastType: TOAST_TYPE.toastError,
        );
        return;
      }

      EasyLoading.show(status: 'Uploading video...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_$timestamp.mp4';
      final filePath = 'chats/$id/videos/$fileName';

      log('Uploading to: $filePath');

      // Upload to Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(videoFile);

      // Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        EasyLoading.showProgress(progress, status: 'Uploading video ${(progress * 100).toStringAsFixed(0)}%');
        log('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final TaskSnapshot taskSnapshot = await uploadTask.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw Exception('Upload timeout - please check your internet connection');
        },
      );
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      log('Video uploaded successfully, getting duration...');

      // Get video duration
      int duration = await _getVideoDuration(videoFile);

      log('Sending video message to Firestore...');

      // Send message with video
      await dataBase.sendMessage(
        chatRoomId: chatDataModel.value?.chatsId ?? '',
        model: ChatModel(
          from: Database.userId,
          to: userId,
          message: 'Video',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.video,
          voiceData: {'url': downloadUrl, 'duration': duration, 'fileSize': fileSize},
        ),
      );
      updateLastMessage(
          secondUser:
          (chatDataModel.value?.senderId ?? '') == Database.userId
              ? (chatDataModel.value?.receiverId ?? '')
              : (chatDataModel.value?.senderId ?? ''),
          videId: chatDataModel.value?.videoId ?? 0);
      loading = false;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Video sent!');

      log('Video upload complete: $downloadUrl');
    } catch (e) {
      log('Error uploading video: $e');
      loading = false;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to upload video. Please try again.\n${e.toString()}",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  /// Get video duration in seconds
  Future<int> _getVideoDuration(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      log('Error getting video duration: $e');
      return 0;
    }
  }

  Future<void> pickLocation() async {
    try {
      log('Opening location picker...');

      // Import the location picker screen dynamically
      final result = await Get.to(() => const LocationPickerScreen());

      if (result != null && result is Map<String, dynamic>) {
        log('Location selected: ${result['latitude']}, ${result['longitude']}');
        await sendLocationMessage(result);
        updateLastMessage(
            secondUser:
            (chatDataModel.value?.senderId ?? '') == Database.userId
                ? (chatDataModel.value?.receiverId ?? '')
                : (chatDataModel.value?.senderId ?? ''),
            videId: chatDataModel.value?.videoId ?? 0);
      } else {
        log('Location picker cancelled');
      }
    } catch (e) {
      log('Error picking location: $e');
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to pick location. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage(String chatRoomId, String secondUserId) async {
    try {
      // Get recorded file
      final File? audioFile = voiceRecordingController.getRecordingFile();
      if (audioFile == null) {
        log('No audio file to send');
        return;
      }

      // Show loading
      isUploadingVoice = true;
      uploadProgress = 0.0;
      update();
      EasyLoading.show(status: 'Uploading voice message...');

      // Get file size and duration
      final fileSize = await AudioUtils.getFileSize(audioFile.path);
      final duration = AudioUtils.durationToSeconds(voiceRecordingController.recordingDuration);

      // Upload to Firebase Storage
      final uploadResult = await AudioService.uploadAudioWithRetry(
        audioFile: audioFile,
        chatRoomId: id,
        onProgress: (progress) {
          uploadProgress = progress;
          update();
        },
      );

      if (uploadResult['success'] != true) {
        throw Exception('Upload failed: ${uploadResult['error']}');
      }

      final audioUrl = uploadResult['url'] as String;

      // Create voice message
      final voiceData = {'url': audioUrl, 'duration': duration, 'fileSize': fileSize};

      // Send message to Firestore
      await dataBase.sendMessage(
        chatRoomId: chatRoomId,
        model: ChatModel(
          from: "",
          to: secondUserId,
          message: 'Voice message',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.voice,
          voiceData: voiceData,
        ),
      );

      updateLastMessage(
          secondUser:
          (chatDataModel.value?.senderId ?? '') == Database.userId
              ? (chatDataModel.value?.receiverId ?? '')
              : (chatDataModel.value?.senderId ?? ''),
          videId: chatDataModel.value?.videoId ?? 0);
      // Clean up
      await voiceRecordingController.reset();
      isUploadingVoice = false;
      uploadProgress = 0.0;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Voice message sent!');

      log('Voice message sent successfully');
    } catch (e) {
      log('Error sending voice message: $e');
      isUploadingVoice = false;
      uploadProgress = 0.0;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to send voice message. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  Future<void> sendLocationMessage(Map<String, dynamic> locationData) async {
    try {
      log('Sending location message...');

      loading = true;
      update();
      EasyLoading.show(status: 'Sending location...');

      // Send message to Firestore
      await dataBase.sendMessage(
        chatRoomId: chatDataModel.value?.chatsId ?? '',
        model: ChatModel(
          from: Database.userId,
          to: userId,
          message: 'Location',
          files: [],
          timeStamp: Timestamp.now(),
          messageType: MessageType.location,
          voiceData: locationData,
        ),
      );

      loading = false;
      update();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Location sent!');

      log('Location message sent successfully');
    } catch (e) {
      log('Error sending location message: $e');
      loading = false;
      update();

      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to send location. Please try again.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    chatDataModel.value = null;
    controllerMessage.dispose();
    super.dispose();
  }
}
