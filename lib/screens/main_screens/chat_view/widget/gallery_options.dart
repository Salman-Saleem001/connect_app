import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../controllers/chat/chat_detail_controller.dart';

class GalleryOptions extends StatelessWidget {
  const GalleryOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Text(
              'Choose from Gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Photos'),
              subtitle: const Text('Choose from gallery', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(context).pop();
                await controller.imgFromGallery2();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.video_library, color: Colors.purple),
              ),
              title: const Text('Video'),
              subtitle: const Text('Choose from gallery', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(context).pop();
                await controller.pickVideo(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
