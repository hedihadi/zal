import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWithLinkIcon extends ConsumerWidget {
  const TextWithLinkIcon({super.key, required this.text, required this.url, this.textStyle});
  final String text;
  final String url;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(
          text,
          style: textStyle ?? Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
        ),
        InkWell(
          child: Icon(
            FontAwesomeIcons.question,
            color: Theme.of(context).colorScheme.secondary,
            size: 15,
          ),
          onTap: () {
            launchUrl(Uri.parse(url));
          },
        ),
      ],
    );
  }
}
