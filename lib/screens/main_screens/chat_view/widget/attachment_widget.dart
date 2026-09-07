import 'package:connect_app/controllers/chat/chat_detail_controller.dart';
import 'package:connect_app/screens/main_screens/chat_view/widget/gallery_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class AttachmentWidget extends StatelessWidget {
  const AttachmentWidget({super.key});


  @override
  Widget build(BuildContext context) {
    final controller= Get.put(ChatDetailController());
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Attach',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insert_drive_file, color: Colors.orange),
              ),
              title: const Text('Document'),
              subtitle: const Text('PDF, DOC, XLS, etc.', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(context).pop();
                await controller.pickDocument();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Photos and videos', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (BuildContext bc) {
                    return GalleryOptions();
                  },
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
              title: const Text('Location'),
              subtitle: const Text('Share your location', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(context).pop();
                await controller.pickLocation();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
