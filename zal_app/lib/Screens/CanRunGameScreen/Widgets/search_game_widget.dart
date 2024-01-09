import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/CanRunGameScreen/providers.dart';
import 'package:sizer/sizer.dart';

final isLoadingProvider = StateProvider.autoDispose((ref) => false);

final selectedGameProvider = StateProvider.autoDispose<String?>((ref) => null);

class SearchGameWidget extends ConsumerStatefulWidget {
  const SearchGameWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchGameWidgetState();
}

class _SearchGameWidgetState extends ConsumerState<SearchGameWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(label: Text("what game you want to play?")),
          onChanged: (value) async {
            ref.read(isLoadingProvider.notifier).state = true;
            ref.read(searchGameProvider.notifier).state = value;
          },
        ),
        SizedBox(height: 2.h),
        const GamesList(),
        SizedBox(height: 3.h),
      ],
    );
  }
}

class GamesList extends ConsumerWidget {
  const GamesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchGameResult = ref.watch(searchGameResultProvider);

    return searchGameResult.when(
        data: (data) {
          if (data.isEmpty) return Container();
          return Column(
            children: [
              Text("Choose your game", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
              SizedBox(
                height: 20.h,
                child: ListView.builder(
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final game = data.entries.toList()[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedGameProvider.notifier).state = game.key;
                      },
                      child: Card(
                        color: ref.watch(selectedGameProvider) == game.key ? Theme.of(context).primaryColor : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(
                                  game.key,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Image.network(game.value),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Text("$error"),
        loading: () => const CircularProgressIndicator());
  }
}
