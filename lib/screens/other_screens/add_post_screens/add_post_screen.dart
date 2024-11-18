import 'dart:io';

import 'package:connect_app/services/google_map/google_map_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connect_app/extensions/string_extensions.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/radioGroups.dart';
import 'package:connect_app/globals/video_view.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/success.dart';
import 'package:connect_app/services/google_map/google_map_screen.dart';
import 'package:connect_app/services/google_map/home_provider.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:connect_app/widgets/text_fields.dart';

import '../../../controllers/mainScreen_controllers/home_page_cont.dart';
import '../../../globals/global.dart';

class CreatePostScreen extends StatefulWidget {
  final String filePath;
  final bool isVideo;

  const CreatePostScreen(
      {super.key, required this.filePath, this.isVideo = false});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  var getController = Get.put(HomeFeedController());
  late List<String> tags;
  late TextEditingController controller;
  late TextEditingController controller1;
  late List<RadioButtonTile<String>> tiles;
  DateTime? selectedExpiry;
  @override
  void initState() {
    // TODO: implement initState
    controller = TextEditingController();
    controller1 = TextEditingController();
    tags = [];
    tiles = [];
    setListOfTags();
    selectedExpiry = DateTime.now();
    super.initState();
  }

  setListOfTags() async {
    await getController.getLocation();
    await getController.getTags();
    getController.tags?.forEach((element) {
      tiles.add(RadioButtonTile(title: element, value: element));
    });
    for (var val in tiles) {
      debugPrint('val==>${val.value} and Title====> ${val.title}');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (getController.addresses.isEmpty) {
      getController.getLocation();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Stack(
        children: [
          ColoredBox(
            color: AppColors.white,
            child: Column(
              children: [
                SizedBox(
                    height: ht(400),
                    child: widget.isVideo
                        ? VideoView(
                            isLocal: true,
                            url: widget.filePath,
                            isContained: true,
                          )
                        : Image.file(File(widget.filePath))),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    children: [
                      Text(
                        'Add Info',
                        style: subHeadingText(size: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      multiLinesTextField(
                        controller,
                        FocusNode(),
                        [],
                        hint: 'Write a Brief Caption & Description',
                      ),
                      20.hp,
                      Consumer<HomeProvider>(
                          builder: (context, homeProvider, _) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Get.to(() => GoogleMapScreen(
                                  selectedLocation: LatLng(
                                      homeProvider.startLocation.latitude,
                                      homeProvider.startLocation.longitude),
                                ))?.then((v){
                                  setState(() {});
                              context.read<GoogleMapScreenProvider>().update();
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add Location',
                                style: subHeadingText(size: 16),
                              ),
                              const Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        );
                      }),
                      20.hp,
                      _preferences(),
                      20.hp,
                      Text(
                        'Add Expiry Date',
                        style: subHeadingText(size: 16),
                      ),
                      10.hp,
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          showDatePicker(
                            context: context,
                            firstDate:  DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                            builder: (context, child){
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primaryColor, // <-- SEE HERE
                                    onPrimary: AppColors.white, // <-- SEE HERE
                                    onSurface: Colors.grey, // <-- SEE HERE
                                    onInverseSurface: AppColors.primaryColor,
                                    // inverseSurface: AppColors.primaryColor
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primaryColor, // Button text color
                                    ),
                                  ),
                                ),

                                child: child!,
                              );
                            }
                          ).then((value){
                            setState(() {
                              selectedExpiry= value;
                            });
                          });
                        },
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_month),
                            10.wp,
                            Text(
                              selectedExpiry?.toIso8601String().substring(0,10)??'',
                              style: subHeadingText(size: 16, color: Colors.grey),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Post',
                    onPress: () {
                      if(controller.text.isEmpty){
                        Global.showToastAlert(
                            context: Get.overlayContext!,
                            strTitle: "Message",
                            strMsg: 'Please Enter the Info',
                            toastType: TOAST_TYPE.toastError);
                      }
                      debugPrint("setPost===>${
                           File(widget.filePath)}${ controller.text}${getController.position?.latitude ?? 0.0}${getController.position?.longitude ?? 0.0},${context.read<GoogleMapScreenProvider>().locationData?.city ?? ''},${context.read<GoogleMapScreenProvider>().locationData?.state ?? ''},${context.read<GoogleMapScreenProvider>().locationData?.country ?? ''}",);
                      getController
                          .setPost(
                        title: '',
                        video: File(widget.filePath),
                        info: controller.text,
                        lat: getController.position?.latitude ?? 0.0,
                        lng: getController.position?.longitude ?? 0.0,
                        city: context.read<GoogleMapScreenProvider>().locationData?.city ?? '',
                        state:  context.read<GoogleMapScreenProvider>().locationData?.state ?? '',
                        country:  context.read<GoogleMapScreenProvider>().locationData?.country ?? '',
                        tags: tags,
                        expiryDate: selectedExpiry?.toIso8601String() ??
                            DateTime.now().toIso8601String(),
                      )
                          .then((val) {
                        if (val) {
                          Get.off(() => const SuccessUploaded());
                          debugPrint("val====>$val");
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: customAppBarTransparent(
              backButton: true,
              title: 'Add a new Post',
              marginTop: 25,
            ),
          ),
        ],
      )),
    );
  }

  Widget _preferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          'Add Tags',
          style: subHeadingText(size: 16),
        ),
        const SizedBox(
          height: 20,
        ),
        customTextFiled(
          controller1,
          FocusNode(),
          [],
          SizedBox(
            height: 50,
            width: 40,
            child: Center(
              child: Image.asset(
                'assets/images/ic_search.png',
                height: 18,
                color: AppColors.iconColor,
              ),
            ),
          ),
          hint: 'Search',
          onchange: (String? val) {
            if (val?.length == 1 || val?.isEmpty == true) {
              setState(() {});
            }
          },
        ),
        SizedBox(
          height: ht(12),
        ),
        if (controller1.text.isNotEmpty) ...[
          PrimaryButton(
            label: 'add Tag',
            onPress: () async {
              String val = '#${controller1.text.capitalizeText()}';
              tiles.add(RadioButtonTile(title: val, value: val));
              await getController.sendTags(val).then((val) {
                if (val) {
                  debugPrint("Tags added");
                }
              });
              controller1.clear();
              setState(() {});
            },
          ),
          25.hp,
        ],
        if (tiles.isNotEmpty)
          RadioButtonTileGroup<String>(
            selectedValues: [tiles.first.title],
            onChanged: (newValues) {
              tags = [];
              for (var val in newValues) {
                tags.add(val);
                debugPrint(val);
              }
            },
            selectedTileColor: AppColors.primaryColorBottom,
            // Customize selected tile color
            borderWidth: 1.0,
            // Customize border width
            borderRadius: 100,
            // Customize border radius
            tilesPerRow: 4,
            // Set number of tiles per row
            tiles: tiles,
          ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    tags.clear();
    tiles.clear();
    controller1.dispose();
    super.dispose();
  }
}
