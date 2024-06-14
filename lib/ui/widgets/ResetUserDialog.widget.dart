import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:terpiez/hooks/useSelector.hook.dart';
import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/pages/homepage_tabs.page.dart';
import 'package:terpiez/utils/utils.dart';
import 'package:uuid/uuid.dart';

class ResetUserDialog extends StatelessWidget {
  const ResetUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Clear User Data"),
      content: const Text(
          "This is a destructive action and all data will be lost. Are you sure you want to reset your account?"),
      actions: [
        // Close dialog button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); //
          },
          child: const Text("Cancel"),
        ),

        // Reset user button
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red.shade500),
          ),
          onPressed: () async {
            // get all location from redis
            await RedisClient.instance.connect();
            List<dynamic> locationJson =
                jsonDecode(await RedisClient.instance.get('locations', '.'));
            await RedisClient.instance.closeConnection();
            List<TerpLocation> terpiezCoordinates =
                TerpLocation.fromJsonList(locationJson);

            // clear local storage data
            DateTime newFirstDayActive = DateTime.now();
            String newId = const Uuid().v4();
            await LocalStorage.setString('caught_terpiez', jsonEncode({}));
            await LocalStorage.setString('user_id', newId);
            await LocalStorage.setBool('is_sound_on', true);
            await LocalStorage.setInt('terpiez_caught_count', 0);
            await LocalStorage.setString(
                'first_day_active', newFirstDayActive.toString());

            if (!context.mounted) return;

            // clear provider
            useProvider<UserProvider>(context, false)
                .reset(newId, newFirstDayActive, terpiezCoordinates);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePageTabs(),
              ),
            );
          },
          child: const Text(
            "Reset",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
