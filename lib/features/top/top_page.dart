import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/common_widget/digital_clock_widget.dart';
import 'package:kujiracchi_dart/features/config/config.dart';

import 'package:kujiracchi_dart/features/config/config_page.dart';

class TopPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ConfigNotifier configNotifier = ref.watch(configProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('トップ'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/remain'),
                    child: Text('Remain'),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/stopwatch'),
                          child: Text('Stop Watch'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/timer'),
                          child: Text('Timer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Center(child: DigitalClockWidget())),
                Expanded(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/config'),
                        icon: Icon(Icons.settings),
                      ),
                    ),
                    Expanded(
                        child:
                            ElevatedButton(onPressed: null, child: Text('b'))),
                    Expanded(
                        child:
                            ElevatedButton(onPressed: null, child: Text('c'))),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
