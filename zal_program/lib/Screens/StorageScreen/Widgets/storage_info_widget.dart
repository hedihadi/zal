import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/StorageScreen/Widgets/text_with_link_icon.dart';

class StorageInfoWidget extends ConsumerWidget {
  const StorageInfoWidget({super.key, required this.info});
  final Map<String, dynamic> info;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
      children: getWidgets(context),
    );
  }

  List<Widget> getWidgets(BuildContext context) {
    final List<Widget> result = [];
    if (info.containsKey("transferMode")) {
      result.add(Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextWithLinkIcon(text: 'Transfer Mode', url: "https://zalapp.com/info#storage"),
                  info['transferMode'][0].replaceAll(" ", '') != info['transferMode'][1].replaceAll(" ", '')
                      ? Icon(
                          FontAwesomeIcons.triangleExclamation,
                          color: Theme.of(context).colorScheme.error,
                        )
                      : Container(),
                ],
              ),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  tableRow(context, "Supported", Icons.abc, "${info['transferMode'][0]}", showIcon: false),
                  tableRow(context, "Current", Icons.abc, "${info['transferMode'][1]}", showIcon: false),
                ],
              ),
            ],
          ),
        ),
      ));
    }
    if (info.containsKey("powerOnHours")) {
      result.add(Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWithLinkIcon(text: 'Working time', url: "https://zalapp.com/info#storage"),
              Text("${secondsToWrittenTime((info['powerOnHours'] as int) * 60 * 60)},"),
              Text("Powered on ${info['powerOnCount']} times."),
            ],
          ),
        ),
      ));
    }

    if (info.containsKey("healthText")) {
      result.add(Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Health",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  Text(" ${info['healthText']}",
                      style: TextStyle(
                          color: info['healthText'] == "Good"
                              ? Colors.green[600]
                              : info['healthText'] == 'Caution'
                                  ? Colors.yellow
                                  : info['healthText'] == 'Bad'
                                      ? Colors.red
                                      : null)),
                ],
              ),
              info.containsKey("healthPercentage") == false
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: info['healthPercentage'].toDouble() / 100,
                          ),
                        ),
                        Text(" ${info['healthPercentage']}%"),
                      ],
                    ),
            ],
          ),
        ),
      ));
    }
    if (info.containsKey("features")) {
      result.add(Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Features",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              Wrap(
                children: List<String>.from(info['features']).map((e) {
                  return Card(
                    elevation: 3,
                    shadowColor: Colors.transparent,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(e),
                            InkWell(
                              child: Icon(
                                FontAwesomeIcons.question,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 15,
                              ),
                              onTap: () {
                                launchUrl(Uri.parse("https://zalapp.com/info#storage"));
                              },
                            ),
                          ],
                        )),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ));
    }
    return result;
  }
}
