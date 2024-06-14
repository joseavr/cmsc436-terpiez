import 'package:flutter/material.dart';
import 'package:terpiez/hooks/useSelector.hook.dart';
import 'dart:io';

import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/widgets/widgets.dart';

class CatchedTerpiezDialog extends StatefulWidget {
  const CatchedTerpiezDialog({super.key, required this.terp});

  final CaughtTerpiez terp;

  @override
  State<CatchedTerpiezDialog> createState() => _CatchedTerpiezDialogState();
}

class _CatchedTerpiezDialogState extends State<CatchedTerpiezDialog> {
  @override
  Widget build(BuildContext context) {
    UserProvider user = useProvider<UserProvider>(context);

    user.isTerpDialogOpen = true;

    return AlertDialog(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      // elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: const Text('Good News! 🎉🎉'),

      content: SizedBox(
        height: 325,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text
            const Text(
              'You found a new terpiez',
            ),

            const SpaceY(15),

            // image
            Image.file(File(widget.terp.image), width: 280, height: 265),
            const SpaceY(5),
            Center(
              child: Text(
                widget.terp.name,
                style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        MaterialButton(
          minWidth: 250,
          padding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              color: Color.fromARGB(128, 132, 131, 131),
              width: 0.5,
            ),
          ),
          color: Colors.white,
          onPressed: () {
            user.isTerpDialogOpen = false;
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }
}
