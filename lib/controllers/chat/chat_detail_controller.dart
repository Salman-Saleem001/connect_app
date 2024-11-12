import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../globals/database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../models/chat_model_data.dart';
import '../../models/local_chat_model.dart';

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

  changeText(String strvalue) {
    if (Global.checkNull(strvalue) && strvalue
        .trim()
        .isNotEmpty) {
      showSendButton = true;
    } else {
      showSendButton = false;
    }
    update();
  }

  generateThumbnail(String video) async{
    debugPrint("Generating thumbnail");
    final tempDir = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.webp';
    final thumbnailPath = '${tempDir.path}/$fileName';
    thumbnail= await VideoThumbnail.thumbnailFile(
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

      final file = File(thumbnail??'');

      // Check if the file exists
      if (await file.exists()) {
        await file.delete();
        debugPrint("File deleted successfully: $thumbnail");
      } else {
        debugPrint("File not found: $thumbnail");
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }finally{
      thumbnail=null;
    }
  }

  getSingleChatDetail(
      {required String secondUserId, required int videoId}) async {
    isDataFetched.value = false;
    await dataBase.getSingleChatDetail(
        secondUserId: secondUserId, videoId: videoId).then((val) {
      if (val != null) {
        chatDataModel.value = ChatDataModel.fromJson(val);
        // update();
      }
    });
    // chatDataModel.value = ChatDataModel.fromJson();
    debugPrint(chatDataModel.value?.toJson().toString());
    isDataFetched.value = true;

    update();
  }

  sendMessage({required String chatRoomId}) {
    if (controllerMessage.text
        .trim()
        .isNotEmpty) {
      dataBase.sendMessage(
        chatRoomId: chatRoomId,
        model: ChatDataModel(
          messageData: controllerMessage.text,
          lastMessageType: 'text',
        ),
      );
      controllerMessage.clear();
    }
  }

  updateLastMessage({required String secondUser, required int videId,}) {
    debugPrint('Update last time');
    dataBase.updateChatRoom(secondUser: secondUser, videId: videId);
  }

  getMessages({required String chatRoomId}) {
    return dataBase.getMessages(chatRoomId: chatRoomId);
  }

  updateStatus(
      {required String secondUserId, required String status, required int videoId}) async {
    await dataBase
        .setAcceptanceStatus(
        secondUserId: secondUserId, status: status, videoId: videoId)
        .then((val) async {
      if (true) {
        await getSingleChatDetail(secondUserId: secondUserId, videoId: videoId);
      }
    });
  }

  addEmojis(String strvalue) {
    controllerMessage.text = controllerMessage.text + strvalue;
    showSendButton = true;
    update();
  }

  showEmoji() {
    isShowEmojis = isShowEmojis ? false : true;
    update();
  }

  disableEmoji() {
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

  void showImagePicker(context,) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Gallery'),
                    onTap: () async {
                      await imgFromGallery2();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    await imgFromCamera2();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  imgFromCamera2() async {
    try {
      ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      imageCompressor([pickedFile!]);
    } catch (e) {
      print('image picker error: $e');
    }
  }

  imgFromGallery2() async {
    try {
      ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickMultiImage();
      imageCompressor(pickedFile!);
    } catch (e) {
      print('image picker error: $e');
    }
  }

  var loading = false;

  imageCompressor(List<XFile> selectedImage) async {
    try {
      loading = true;
      update();

      List<File> files = [];
      for (int i = 0; i < selectedImage.length; i++) {
        // File compressedFile = await FlutterNativeImage.compressImage(
        //     selectedImage[i].path,
        //     quality: 30,
        //     percentage: 50);
        //
        // files.add(compressedFile);
      }

      uploadImage(files);
    } catch (e) {
      Future.error(e);
      return;
    }
  }

  Future<void> uploadImage(List<File> files) async {
    log(files.length.toString());
    if (files.isEmpty) {
      loading = false;
      update();
      return;
    }

    // HashMap<String, String> requestParams = HashMap();
    // HashMap<String, String> requestParamsImg = HashMap();
    List<String> paths = [];
    for (int i = 0; i < files.length; i++) {
      paths.add(files[i].path);
    }

    var res;

    res.fold((failure) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Something went wrong! Try again",
          toastType: TOAST_TYPE.toastError);
      loading = false;
      update();
    }, (mResult) async {
      List<String> images = mResult.responseData as List<String>;
      // sendMessage(files: images);
      loading = false;
      update();
    });
  }

  createChatRoom({required String secondUser,
    required String chatRoomId,
    required String userName,
    required String description,
    required String tags,
    required int videoId,
    required String avatar
  }) async {
    dataBase.createChatRoom(
        secondUser: secondUser,
        chatRoomId: chatRoomId,
        userName: userName,
        tags: tags,
        videoUrl: videoUrl ?? '',
        description: description,
        videId: videoId, userAvatar: avatar);
  }

  uploadToStorage(File file) async {
    videoUrl = await dataBase.uploadToStorage(file);

    if (videoUrl?.isNotEmpty == true) {
      debugPrint("Here is my Video==> $videoUrl");
      return true;
    } else {
      return false;
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
