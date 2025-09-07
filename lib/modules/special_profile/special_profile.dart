import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';

class SpecialProfile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String shortBio;
  final String longBio;
  final String province;
  final List<File> images;

  const SpecialProfile({
    super.key,
    required this.name,
    this.imageUrl,
    required this.shortBio,
    required this.longBio,
    required this.province,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: Text(
          "Hünärmen profilim".tr,
          style: TextStyle(color: ColorConstants.fonts),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorConstants.kPrimaryColor2,
            )),
        backgroundColor: ColorConstants.background,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              IconConstants.edit,
              width: 24,
              height: 24,
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBox(
                      icon: SvgPicture.asset(
                        IconConstants.Isolation_Mode,
                      ),
                      label: "Döredilen ýumuşlar",
                      value: "12"),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
                  ),
                  _StatBox(
                      icon: SvgPicture.asset(
                        IconConstants.Isolation_Mode2,
                      ),
                      label: "Ýerine ýetiren işler",
                      value: "28"),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                shortBio,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    IconConstants.calendar,
                  ),
                  SizedBox(width: 5),
                  Text("24.07.2023",
                      style: TextStyle(color: ColorConstants.fonts)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Icon(Icons.star,
                      color: i < 3 ? Colors.amber : Colors.grey, size: 20),
                ),
              ),
              const Text("(281)", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bio:", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(longBio,
                    style: const TextStyle(color: ColorConstants.fonts)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.location_on,
                        size: 16, color: ColorConstants.fonts),
                    SizedBox(width: 4),
                    Text("Ashgabat",
                        style: TextStyle(color: ColorConstants.fonts)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildWorksSection(),
          const SizedBox(height: 16),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildWorksSection() {
    return Container(
      decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Işler, diplomlar, sertifikatlar 15",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.fonts)),
              Text("Girişleýin", style: TextStyle(color: ColorConstants.blue)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length > 4 ? 4 : images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(images[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Teswirler 15",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Girişleýin", style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),
          _ReviewTile(),
          const SizedBox(height: 8),
          _ReviewTile(),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  const _StatBox(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        Text(label,
            style: const TextStyle(color: ColorConstants.fonts, fontSize: 10)),
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConstants.fonts,
            )),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage("assets/images/profile.png")),
              const SizedBox(width: 8),
              const Text("Merdan_97",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(Icons.star,
                      color: i < 4 ? Colors.amber : Colors.grey, size: 16),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod"),
          const SizedBox(height: 4),
          const Text("22.05.2023",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
