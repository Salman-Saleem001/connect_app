import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/searchScreen_controller.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/text_fields.dart';

class SecondaryHomeScreen extends StatefulWidget {
  const SecondaryHomeScreen({Key? key}) : super(key: key);

  @override
  SecondaryHomeScreenState createState() => SecondaryHomeScreenState();
}

class SecondaryHomeScreenState extends State<SecondaryHomeScreen> {
  TextEditingController notesController = TextEditingController();
  FocusNode notesNode = FocusNode();

  var controller = Get.put(SearchScreenController());

  int selectedCat = 0;
  List<String> status = ['Recommended', 'Trending', 'Featured', 'Events'];

  final List<Map<String, String>> videos = [
    {
      'username': 'ben_offiicial99',
      'location': 'California, USA',
      'profileImageUrl': 'https://via.placeholder.com/150',
      'videoImageUrl': 'https://via.placeholder.com/600x400',
      'description':
          'Anyone heading to Phoenix Game Tonight? #Football #Phoenix #EdenPark',
      'views': '1.7M views',
      'rating': '5',
      'expiry': '3 days',
    },
    {
      'username': 'ben_offiicial99',
      'location': 'California, USA',
      'profileImageUrl': 'https://via.placeholder.com/150',
      'videoImageUrl': 'https://via.placeholder.com/600x400',
      'description':
          'Anyone heading to Phoenix Game Tonight? #Football #Phoenix #EdenPark',
      'views': '1.7M views',
      'rating': '5',
      'expiry': '3 days',
    },
  ];

  SizedBox categories() {
    return SizedBox(
      height: 60,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.lightText.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: ListView.separated(
          separatorBuilder: (ctx, i) => const SizedBox(
            width: 15,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: status.length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCat = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == selectedCat
                          ? Colors
                              .red // Replace with AppColors.primaryColorBottom if defined
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  status[index],
                  style: TextStyle(
                    color: index == selectedCat
                        ? Colors
                            .red // Replace with AppColors.primaryColorBottom if defined
                        : Colors
                            .grey, // Replace with AppColors.textPrimary if defined
                    fontSize: 12, // Adjust the font size as needed
                    fontWeight: index == selectedCat
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        titleColor: AppColors.primaryColor,
        title: 'Connect Giant',
        backButton: false,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              child: Center(child: Image.asset('assets/images/ic_support.png')),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              customTextFieldOptionalPreffix(
                notesController,
                notesNode,
                [],
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.grey, // Use your defined color here
                ),
                hint: 'Search',
              ),
              categories(),
              Expanded(
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return VideoCard(video: video);
                  },
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final Map<String, String> video;

  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 33,
              backgroundImage: NetworkImage(video['profileImageUrl']!),
            ),
            title: Text('@${video['username']}'),
            subtitle: Text(video['location']!),
            trailing: Icon(
              Icons.person_add_alt_1_outlined,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(video['videoImageUrl']!),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              video['description']!,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < int.parse(video['rating']!)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              Text(
                'Expires in ${video['expiry']}',
                style: normalText(size: 14, color: AppColors.lightBorder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
