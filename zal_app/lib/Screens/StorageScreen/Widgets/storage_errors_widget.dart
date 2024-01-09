import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Widgets/card_widget.dart';

class StorageErrorsWidget extends ConsumerWidget {
  const StorageErrorsWidget({super.key, required this.storage});
  final Storage storage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> transferMode = List<String>.from(storage.info['transferMode']).map((e) => e.replaceAll(" ", "")).toList();
    final  uncorrectableSectorCount =
        storage.smartAttributes.firstWhereOrNull((element) => element.attributeName == 'Uncorrectable Sector Count');
    //final Map<String, dynamic>? currentPendingSectorCount =
    //    storageInfo.smartAttributes?.firstWhereOrNull((element) => element['attributeName'] == 'Current Pending Sector Count');
    final reallocatedSectorsCount =
        storage.smartAttributes.firstWhereOrNull((element) => element.attributeName == 'Reallocated Sectors Count');
    return ListView(
      shrinkWrap: true,
      children: [
        (transferMode.contains('----') == false) && transferMode[0] != transferMode[1]
            ? CardWidget(
                title: "Wrong Port!",
                titleIcon: Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                    "Incorrect port connection may lead to slower data transfer speeds. This storage supports ${transferMode[1]}, but it's currently connected to ${transferMode[0]}."))
            : Container(),
        [null, 0].contains(uncorrectableSectorCount?.rawValue) == false
            ? CardWidget(
                title: "Uncorrectable Sector Count!",
                titleIcon: Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  "the storage has ${uncorrectableSectorCount?.rawValue} Uncorrectable Sector Count, Remember, if this number keeps going up often, the HDD is expected to die!",
                ))
            : Container(),
        [null, 0].contains(reallocatedSectorsCount?.rawValue) == false
            ? CardWidget(
                title: "Reallocated Sectors Count!",
                titleIcon: Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  "this storage has ${reallocatedSectorsCount?.rawValue} Reallocated Sectors Count. if the number is low, then it's not critical. but if the number keeps going up then this hard drive is about to die!",
                ))
            : Container(),
      ],
    );
  }
}
