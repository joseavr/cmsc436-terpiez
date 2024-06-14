import 'package:flutter/material.dart';
import 'package:terpiez/utils/icon_assets.dart';
import 'package:terpiez/ui/widgets/CredentialDialog.widget.dart';
import 'package:terpiez/ui/widgets/spacex.dart';
import 'package:terpiez/ui/widgets/spacey.dart';
import 'package:terpiez/utils/Icons.dart';

class CredentialPage extends StatelessWidget {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // redis icon
          const AppIcon(
            iconName: IconAssets.redis,
            size: 100.0,
          ),

          const SpaceY(10),

          //text
          const Text('Please enter your crendentials\nto connect with Redis', textAlign: TextAlign.center,),

          const SpaceY(16),

          // material button
          MaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const CredentialsDialog();
                },
              );
            },
            minWidth: 120,
            padding: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.black,
            child: const SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Connect', style: TextStyle(color: Colors.white)),
                  SpaceX(6),
                  AppIcon(iconName: IconAssets.plugged, color: Colors.white)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
