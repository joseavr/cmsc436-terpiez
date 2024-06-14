import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/hooks/hooks.dart';
import 'package:terpiez/ui/widgets/widgets.dart';

class FinderScreen extends StatefulWidget {
  const FinderScreen({super.key});

  @override
  State<FinderScreen> createState() => _FinderScreenState();
}

class _FinderScreenState extends State<FinderScreen> {
  late ConfettiController _confettiContorller;

  @override
  void initState() {
    super.initState();
    _confettiContorller =
        ConfettiController(duration: const Duration(milliseconds: 400));

    FlutterBackgroundService().invoke('update_is_map_service', {
      'is_map_service': true,
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void playConfetti() {
    _confettiContorller.play();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider user = useProvider(context);
    double distanceToClosestTerpiez =
        user.closestTerpiezInMeters == double.infinity
            ? 0.0
            : user.closestTerpiezInMeters;

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Terpiez Finder',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SpaceY(16.0),

                    // Google Map
                    const SizedBox(
                      height: 400,
                      width: 400,
                      child: GoogleMapWidget(),
                    ),

                    const SpaceY(16.0),

                    const Text(
                      'Closest Terpiez:',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),

                    const SpaceY(6),

                    Text(
                      user.isConnectedToInternet
                          ? '$distanceToClosestTerpiez m'
                          : '<undefined>',
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),

                    const SpaceY(8),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CatchTerpiezButton(playConfetti: playConfetti),
                        ConfettiWidget(
                          confettiController: _confettiContorller,

                          // Direction
                          blastDirectionality: BlastDirectionality.explosive,
                          blastDirection: -pi / 2,

                          // emission count
                          emissionFrequency: 0.2,
                          numberOfParticles: 10,

                          // set intesity
                          minBlastForce: 10,
                          maxBlastForce: 100,
                        ),
                      ],
                    ),

                    const SpaceY(20.0),
                  ],
                ),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // justify-start
              crossAxisAlignment: CrossAxisAlignment.center, // items-center
              children: [
                const Text(
                  'Terpiez Finder',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // google maps widget
                    const SizedBox(
                        height: 300.0, width: 400.0, child: GoogleMapWidget()),

                    Column(
                      children: [
                        const Text(
                          'Closest Terpiez:',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),

                        Text(
                          '$distanceToClosestTerpiez m',
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),

                        // Google Map
                        const CatchTerpiezButton(),

                        const SpaceY(20.0),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        }
      },
    );
  }
}
