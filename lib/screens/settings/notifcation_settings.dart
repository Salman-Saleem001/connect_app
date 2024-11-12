import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';

import '../../services/firebase_utils.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool receiveAlerts ;
  @override
  void initState() {
    // TODO: implement initState
    setData();
    super.initState();
  }

  setData()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    receiveAlerts= sharedPreferences.getBool('notificationStatus')??true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Manage Notifications', marginTop: 25),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Manage Notifications',
                style: regularText(color: AppColors.txtGrey)),
          ),
          buildSwitchListTile(
            title: 'Receive important alerts',
            value: receiveAlerts,
            onChanged: (bool value) {
              setState(() {
                receiveAlerts = value;
              });
              if(value){
                FirebaseUtils().getToken();

              }else{
                FirebaseUtils().deleteToken();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(
        Icons.notifications_outlined,
        color: AppColors.txtGrey,
      ),
      value: value,
      activeColor: AppColors.white, // Default active color
      inactiveThumbColor: Colors.grey, // Default inactive thumb color
      inactiveTrackColor: Colors.grey[300], // Default inactive track color
      activeTrackColor: AppColors.primaryColorBottom,
      onChanged: onChanged,
    );
  }
}
