import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:terpiez/hooks/hooks.dart';
import 'package:terpiez/providers/user.provider.dart';
import 'package:terpiez/ui/widgets/spacey.dart';
import 'package:terpiez/utils/calculateDaysActive.util.dart';

// NOTE: CANNOT USE EXPANDED IN SINGLE CHILD SCROLLVIEW

class StatsScreen extends StatelessWidget {
  final int terpiezFound = 12;
  final int daysActive = 3;
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProvider user = useProvider<UserProvider>(context);

    FlutterBackgroundService().invoke('update_is_map_service', {
      'is_map_service': false,
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // justify-start
        crossAxisAlignment: CrossAxisAlignment.center, // items-center
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 46.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SpaceY(16.0),

          Text(
            'Terpiez found: ${user.terpiezCaughtCount}',
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),

          Text(
            'Days Active: ${calculateDaysActive(user.firstDayActive)}',
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),

          const SpaceY(60.0), // space-y: 16px

          Text(
            'User: ${user.userId}',
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
