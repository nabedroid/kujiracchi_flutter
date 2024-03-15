import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stopwatch_notifier.dart';
import 'stopwatch_provider.dart';

class StopwatchWidget extends ConsumerWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StopwatchNotifier notifier = ref.watch(stopwatchProvider);
    int ms = notifier.count;
    int h = (ms / 1000 / 60 / 60).floor();
    int m = (ms / 1000 / 60 % 60).floor();
    int s = (ms / 1000 % 60).floor();
    int f = (ms % 1000 / 100).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: FittedBox(child: Text(h.toString().padLeft(2, '0')))),
              Expanded(flex: 1, child: FittedBox(child: const Text(':'))),
              Expanded(flex: 3, child: FittedBox(child: Text(m.toString().padLeft(2, '0')))),
              Expanded(flex: 1, child: FittedBox(child: const Text('`'))),
              Expanded(flex: 3, child: FittedBox(child: Text(s.toString().padLeft(2, '0')))),
              Expanded(flex: 1, child: FittedBox(child: const Text('.'))),
              Expanded(flex: 3, child: FittedBox(child: Text(f.toString()))),
            ]),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
              onPressed: () => ref.read(stopwatchProvider.notifier).start(),
              child: Text('start')),
          ElevatedButton(
              onPressed: () => ref.read(stopwatchProvider.notifier).stop(),
              child: Text('stop')),
          ElevatedButton(
              onPressed: () => ref.read(stopwatchProvider.notifier).reset(),
              child: Text('reset')),
        ]),
      ],
    );
  }
}
