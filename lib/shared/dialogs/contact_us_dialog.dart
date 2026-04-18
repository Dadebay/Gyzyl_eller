import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gyzyleller/core/services/api.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

Future<void> showContactUsDialog(BuildContext context) async {
  final lang = GetStorage().read('langCode') ?? 'tk';
  final url = '${Api().urlSimple}api/$lang/contact-info';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: FutureBuilder<http.Response>(
          future: http.get(Uri.parse(url), headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(color: ColorConstants.fonts),
                  ),
                ),
              );
            }

            final body = json.decode(snapshot.data!.body);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 28),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      if (body['phone_number'] != null)
                        InkWell(
                          onTap: () {
                            launchUrl(Uri.parse('tel:${body['phone_number']}'));
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 18,
                                  color: ColorConstants.kPrimaryColor2),
                              const SizedBox(width: 6),
                              Text(
                                body['phone_number'].toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (body['email'] != null)
                        InkWell(
                          onTap: () {
                            launchUrl(Uri.parse('mailto:${body['email']}'));
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.email,
                                  size: 18,
                                  color: ColorConstants.kPrimaryColor2),
                              const SizedBox(width: 6),
                              Text(
                                body['email'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      if (body['contacts'] != null &&
                          (body['contacts'] as List).isNotEmpty) ...[
                        const SizedBox(height: 20),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (body['contacts'] as List).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (_, pos) {
                            final contact = body['contacts'][pos];
                            final value = contact['value']?.toString() ?? '';
                            final name =
                                (contact['name'] ?? contact['type'] ?? value)
                                    .toString()
                                    .toLowerCase();
                            final icon = _contactIcon(name, value);
                            return InkWell(
                              onTap: () {
                                if (value.startsWith('http')) {
                                  launchUrl(Uri.parse(value),
                                      mode: LaunchMode.externalApplication);
                                } else if (value.startsWith('tel:') ||
                                    value.startsWith('+') ||
                                    RegExp(r'^[0-9]').hasMatch(value)) {
                                  launchUrl(Uri.parse('tel:$value'));
                                }
                              },
                              child: Row(
                                children: [
                                  HugeIcon(
                                    icon: icon,
                                    size: 22,
                                    color: ColorConstants.kPrimaryColor2,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

IconData _contactIcon(String name, String value) {
  final combined = '$name $value'.toLowerCase();
  if (combined.contains('instagram')) return HugeIcons.strokeRoundedInstagram;
  if (combined.contains('tiktok')) return HugeIcons.strokeRoundedTiktok;
  if (combined.contains('telegram')) return HugeIcons.strokeRoundedTelegram;
  if (combined.contains('youtube')) return HugeIcons.strokeRoundedYoutube;
  if (combined.contains('facebook')) return HugeIcons.strokeRoundedFacebook01;
  if (combined.contains('twitter') || combined.contains('x.com')) {
    return HugeIcons.strokeRoundedNewTwitter;
  }
  if (combined.contains('whatsapp')) return HugeIcons.strokeRoundedWhatsapp;
  if (combined.contains('linkedin')) return HugeIcons.strokeRoundedLinkedin01;
  if (combined.contains('mail') || combined.contains('@')) {
    return HugeIcons.strokeRoundedMail01;
  }
  if (combined.contains('phone') ||
      combined.contains('tel') ||
      combined.contains('+')) {
    return HugeIcons.strokeRoundedCall;
  }
  if (combined.contains('web') || combined.contains('http')) {
    return HugeIcons.strokeRoundedGlobe;
  }
  return HugeIcons.strokeRoundedLink01;
}
