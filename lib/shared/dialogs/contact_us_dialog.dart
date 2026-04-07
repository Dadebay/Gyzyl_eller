import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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
                            return InkWell(
                              onTap: () {
                                final value = contact['value']?.toString();
                                if (value != null && value.startsWith('http')) {
                                  launchUrl(Uri.parse(value),
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  if (contact['icon'] != null)
                                    CachedNetworkImage(
                                      height: 18,
                                      width: 18,
                                      fit: BoxFit.contain,
                                      imageUrl:
                                          '${Api().urlSimple}${contact['icon']}',
                                    ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      contact['value'].toString(),
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
