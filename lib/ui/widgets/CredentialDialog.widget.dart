import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:terpiez/utils/const.dart';
import 'package:terpiez/hooks/useSelector.hook.dart';
import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/user.provider.dart';
import 'package:terpiez/ui/pages/pages.dart';
import 'package:terpiez/ui/widgets/widgets.dart';
import 'package:terpiez/utils/utils.dart';

class CredentialsDialog extends StatefulWidget {
  const CredentialsDialog({super.key});

  @override
  State<CredentialsDialog> createState() => _CredentialsDialogState();
}

class _CredentialsDialogState extends State<CredentialsDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showPassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _onSubmit() async {
    setState(() {
      isLoading = true;
    });
    UserProvider user = useProvider(context, false);

    // logic for storing user id and data
    final username = _usernameController.text;
    final password = _passwordController.text;

    bool res = await redis.connect(user: username, pass: password);

    // succesfull connection
    if (res) {
      user.isConnectedToInternet = true;

      // store credentials
      await redis.storeCredentials(username, password);
      user.hasValidCredentials = true;

      // store the first day active
      await LocalStorage.setString('first_day_active', DateTime.now().toString());
      user.firstDayActive = DateTime.now();

      // create user in localstorage with new uuid
      final String userId = const Uuid().v4();
      await LocalStorage.setString('user_id', userId);
      user.userId = userId;

      // initialize caught terpiez field in local storage
      await LocalStorage.setString('caught_terpiez', jsonEncode({}));

      // 1. get terpiez locations
      final data = await RedisClient.instance.get('locations', '.');
      final List<dynamic> json = jsonDecode(data);
      // 2. serialize terpiez location
      final List<TerpLocation> terpiezLocations = [];
      for (final element in json) {
        terpiezLocations.add(TerpLocation.fromJson(element));
      }
      // 3. store terpiez locations into provider
      user.allTerpLocations = terpiezLocations;

      await redis.closeConnection();

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePageTabs(),
        ),
      );
    }
    // no connection
    else {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Username or password credentials for redis are incorrect, or check your connection to internet'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      // elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: const Text('Enter your Crendentials'),
      content: SizedBox(
        height: 150,
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              const SpaceY(20),
              TextFormField(
                obscureText: showPassword,
                controller: _passwordController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.remove_red_eye_sharp
                          : Icons.remove_red_eye_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        MaterialButton(
          padding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(
              color: Color.fromARGB(128, 132, 131, 131),
              width: 0.5,
            ),
          ),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
        MaterialButton(
          elevation: 0,
          padding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Colors.blue,
          onPressed: _onSubmit,
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
        )
      ],
    );
  }
}
