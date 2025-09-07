import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:gyzyleller/shared/widgets/custom_app_bar.dart';

class SpecialProfile extends StatelessWidget {
  const SpecialProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: CustomAppBar(
        title: 'Hünärmen profilim'.tr,
        showBackButton: true,
        centerTitle: true,
        showElevation: false,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/profile_pic.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.blue, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kerwen Myradow',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Men uly tejribeli santehnik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 3 ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '3 (281)',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildStatCard(Icons.folder, 'Döredilen ýyldyzy', '12',
                        Colors.red.shade100, Colors.red),
                    _buildStatCard(Icons.star, 'Ýerine ýetirilen', '28',
                        Colors.red.shade100, Colors.red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bio Bölümü
          _buildSection(
            title: 'Bio:',
            content:
                'Lorem Ipsum is simply dummy text the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard.',
            footer: 'Location: Aşgabat',
            footerIcon: Icons.location_on,
          ),

          _buildHorizontalScrollSection(
            title: 'Işler, diplomlar, sertifikatlar 15',
            items: [
              'assets/work_1.png',
              'assets/work_2.png',
              'assets/work_3.png',
              'assets/work_4.png',
            ],
          ),

          _buildTeswirlerSection(
            title: 'Teswirler 15',
            comments: [
              {
                'name': 'Merdan_97',
                'comment':
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
                'date': '22.05.2023',
                'stars': 4,
                'avatar': 'assets/avatar_1.png',
              },
              {
                'name': 'Merdan_97',
                'comment': 'Lorem ipsum dolor sit amet',
                'date': '22.05.2023',
                'stars': 4,
                'avatar': 'assets/avatar_2.png',
              },
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String count,
      Color bgColor, Color iconColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                count,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      String? content,
      String? footer,
      IconData? footerIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (content != null)
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          if (footer != null) const SizedBox(height: 10),
          if (footer != null)
            Row(
              children: [
                if (footerIcon != null)
                  Icon(footerIcon, size: 16, color: Colors.grey),
                if (footerIcon != null) const SizedBox(width: 5),
                Text(
                  footer,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollSection(
      {required String title, required List<String> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Text(
                      'Girişin',
                      style: TextStyle(color: Colors.blue),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100, // Resimlerin yüksekliği
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      items[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeswirlerSection(
      {required String title, required List<Map<String, dynamic>> comments}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Text(
                      'Girişin',
                      style: TextStyle(color: Colors.blue),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: comments.map((comment) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(comment['avatar']),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < comment['stars']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment['comment'],
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment['date'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
