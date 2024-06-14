import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:terpiez/hooks/useSelector.hook.dart';
import 'package:terpiez/providers/user.provider.dart';
import 'package:terpiez/ui/widgets/ResetUserDialog.widget.dart';
import 'package:terpiez/utils/local_storage_singleton.dart';

class PreferencesView extends StatefulWidget {
  // constructor
  const PreferencesView({
    super.key,
  });

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title:
              const Text("Preferences", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: view());
  }

  Widget view() {
    UserProvider user = useProvider(context, true);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      children: [
        ListTile(
          title: const Text("Play Sound"),
          trailing: Switch(
            value: user.isPlaySoundOn,
            onChanged: (bool newValue) async {
              user.isPlaySoundOn = newValue;
              await LocalStorage.setBool('is_sound_on', newValue);
              FlutterBackgroundService().invoke('update_sound', {
                'play_sound': newValue,
              });
            },
          ),
        ),
        ListTile(
          title: const Text(
            "Reset User",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => const ResetUserDialog());
          },
        ),
      ],
    );
  }
}
