import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Functions/analytics_manager.dart';

final packageInfoProvider = FutureProvider((ref) => PackageInfo.fromPlatform());

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    ref.read(screenViewProvider("about"));
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Container(
            child: ListView(
          children: [
            CircleAvatar(
              radius: 8.h,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipOval(child: Image.asset('assets/images/zal_logo.png')),
              ),
            ),
            SizedBox(height: 2.h),
            Center(
                child: Text(
              "Zal",
              style: Theme.of(context).textTheme.headlineSmall,
            )),
            Center(
                child: Text(
              "monitor & control your PC. anytime, anywhere!",
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            )),
            Center(
                child: Text(
              "${ref.watch(packageInfoProvider).value?.version}",
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            )),
            TextButton(
                onPressed: () {
                  launchUrl(Uri.parse("https://zalapp.com/"));
                },
                child: const Text("ZalApp.com")),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.sp)),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Wrap(
                      children: [
                        const Icon(
                          Icons.tag_faces_sharp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "enjoying it?",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final InAppReview inAppReview = InAppReview.instance;
                            if (await inAppReview.isAvailable()) {
                              inAppReview.requestReview();
                            } else {
                              inAppReview.openStoreListing(appStoreId: 'com.hedihadi.zal');
                            }
                          },
                          child: Column(
                            children: [
                              const Wrap(
                                children: [
                                  Icon(Icons.star_outlined, color: Colors.amber),
                                  Icon(Icons.star_outlined, color: Colors.amber),
                                  Icon(Icons.star_outlined, color: Colors.amber),
                                  Icon(Icons.star_outlined, color: Colors.amber),
                                  Icon(Icons.star_outlined, color: Colors.amber),
                                ],
                              ),
                              Text(
                                "rate on Play Store",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 7.h,
                          width: 1.0,
                          color: Colors.white30,
                          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(const ClipboardData(text: "https://play.google.com/store/apps/details?id=com.hedihadi.zal"));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("copied!"),
                              behavior: SnackBarBehavior.floating,
                            ));
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.share, color: Colors.white),
                              Text("Share - copy download link", style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse("https://www.freeprivacypolicy.com/live/6a690c4a-7f7a-4614-aee0-fce78a3e2995"),
                    );
                  },
                  child: const Text("Privacy Policy"),
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse("https://developer.apple.com/app-store/review/guidelines/#privacy"),
                    );
                  },
                  child: const Text("TOS"),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
