import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

final customerInfoProvider = FutureProvider((ref) async {
  ref.watch(isUserPremiumProvider);
  ref.watch(timerProvider);
  final customerInfo = await Purchases.getCustomerInfo();
  return customerInfo;
});

class BuyPremiumWidget extends ConsumerWidget {
  const BuyPremiumWidget({super.key, required this.offerings});
  final Offerings offerings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);

    final isUserPremium = ref.watch(isUserPremiumProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("get Membership"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            Center(
              child: Text(
                isUserPremium ? "You're a member!" : "Get Zal PRO",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 23.sp, fontFamily: "roboto", fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 3.h),
            isUserPremium
                ? Center(
                    child: Text("Expires ${timeago.format(
                      DateTime.parse("${customerInfo.valueOrNull!.allExpirationDates.entries.lastOrNull?.value}"),
                      allowFromNow: true,
                    )}"),
                  )
                : const BenefitsWidget(),
            isUserPremium
                ? Center(
                    child: TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse("${customerInfo.valueOrNull!.managementURL}"), mode: LaunchMode.externalApplication);
                        },
                        child: const Text("Manage subscriptions")),
                  )
                : Container(),
            const Spacer(),
            ElevatedButton(
                style: ButtonStyle(
                  padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
                ),
                onPressed: () async {
                  await Purchases.purchaseStoreProduct(offerings.current!.monthly!.storeProduct);
                  showSnackbar("Purchase successful!", context);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[HexColor("#ffc196"), HexColor("#ff7295")],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Row(
                      children: [
                        SizedBox(width: 7.w),
                        Icon(FontAwesomeIcons.crown, size: 5.h),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "1 month",
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    "${offerings.current!.monthly!.storeProduct.price.removeTrailingZero()} ${offerings.current!.monthly!.storeProduct.currencyCode}",
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "3-days trial, cancel anytime!",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    "per month",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 3.h),
            ElevatedButton(
                style: ButtonStyle(
                  padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
                ),
                onPressed: () async {
                  await Purchases.purchaseStoreProduct(offerings.current!.annual!.storeProduct);
                  showSnackbar("Purchase successful!", context);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[HexColor("#dc8eff"), HexColor("#9d57ff")],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Row(
                      children: [
                        SizedBox(width: 7.w),
                        Icon(FontAwesomeIcons.crown, size: 5.h),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "12 Months",
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    "${offerings.current!.annual!.storeProduct.price.removeTrailingZero()} ${offerings.current!.annual!.storeProduct.currencyCode}",
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "7-days trial, cancel anytime!",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    "per year",
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 9.h),
            const RestorePurchasesButton(),
          ],
        ),
      ),
    );
  }
}

class BenefitsWidget extends ConsumerWidget {
  const BenefitsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "benefits",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          children: const [
            BenefitCard(text: "Remove Ads"),
            BenefitCard(text: "better charts (coming soon)"),
            BenefitCard(text: "Support the Developer"),
          ],
        ),
      ],
    );
  }
}

class BenefitCard extends ConsumerWidget {
  const BenefitCard({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

final isrestorePurchaseFirstRunProvider = AutoDisposeStateProvider<bool>((ref) {
  return true;
});
final restorePurchaseProvider = FutureProvider.autoDispose<bool>((ref) async {
  if (ref.read(isrestorePurchaseFirstRunProvider) == true) {
    await Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(isrestorePurchaseFirstRunProvider.notifier).state = false;
    });

    return true;
  }
  await Future.delayed(const Duration(seconds: 5));
  await Purchases.restorePurchases();
  return true;
});

class RestorePurchasesButton extends ConsumerWidget {
  const RestorePurchasesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restorePurchases = ref.watch(restorePurchaseProvider);
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(restorePurchaseProvider);
      },
      child: restorePurchases.when(
        skipLoadingOnRefresh: false,
        data: (data) => restorePurchases.isLoading ? const CircularProgressIndicator() : const Text("Restore Purchases"),
        error: (error, stackTrace) => Text(error.toString(), maxLines: 5),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
