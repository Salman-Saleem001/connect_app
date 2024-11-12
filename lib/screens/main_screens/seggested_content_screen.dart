import 'package:flutter/material.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';

class SuggestedConnectionsPage extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {
      'videoImageUrl': 'https://via.placeholder.com/150',
      'tag': 'Top 10',
    },
    {
      'videoImageUrl': 'https://via.placeholder.com/150',
      'tag': '',
    },
    {
      'videoImageUrl': 'https://via.placeholder.com/150',
      'tag': '',
    },
    {
      'videoImageUrl': 'https://via.placeholder.com/150',
      'tag': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBarTransparent(title: 'Suggested Content'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMainVideoSection(context),
            SizedBox(height: 16),
            buildSectionTitle('Videos you might like'),
            buildHorizontalVideoList(videos),
            SizedBox(height: 16),
            buildSectionTitle('Reels picked for you'),
            buildHorizontalVideoList(videos),
            SizedBox(height: 16),
            buildSectionTitle('Trending Reels'),
            buildHorizontalVideoList(videos),
          ],
        ),
      ),
    );
  }

  Widget buildMainVideoSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          'https://via.placeholder.com/600x400',
          width: MediaQuery.of(context).size.width,
          height: ht(550),
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: Text(
            'Anyone heading to Phoenix Game Tonight?\n#Football #Phoenix #EdenPark',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.play_arrow,
              color: AppColors.primaryColor,
            ),
            label: Text(
              'Play',
              style: normalText(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        title,
        style: regularText(color: AppColors.textLight),
      ),
    );
  }

  Widget buildHorizontalVideoList(List<Map<String, String>> videos) {
    return SizedBox(
      height: ht(163),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return buildVideoCard(videos[index]);
        },
      ),
    );
  }

  Widget buildVideoCard(Map<String, String> video) {
    return Container(
      width: wd(107),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              video['videoImageUrl']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          if (video.containsKey('tag'))
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red,
                child: Text(
                  video['tag']!,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
