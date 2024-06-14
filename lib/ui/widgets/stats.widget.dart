import 'package:flutter/material.dart';

import 'package:terpiez/models/models.dart';

class StatsWidget extends StatelessWidget {
  final CaughtTerpiez terp;
  const StatsWidget({super.key, required this.terp});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: terp.stats.entries
              .map(
                (e) => Padding(
                  // padding on the right side
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(children: [
                    Text(
                      '${e.key} -->',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    //
                    Expanded(
                      child: Text(
                        e.value.toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                ),
              )
              .toList(),
        ));
  }
}
