import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:terpiez/hooks/hooks.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/views/detail_view.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = useProvider<UserProvider>(context);
    final caughTerpiez = user.caughtTerpiez;

    FlutterBackgroundService().invoke('update_is_map_service', {
      'is_map_service': false,
    });

    return caughTerpiez.isEmpty
        ? const Center(
            child: Text('No terpiez found...\nGo to Finder page',
                style: TextStyle(fontSize: 16.0)),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: caughTerpiez.map((terp) {
                return ListTile(
                  //
                  leading: Hero(
                    tag: terp.name,
                    child: Image.file(File(terp.thumbnail)),
                  ),

                  title: Text(terp.name),

                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailView(terp: terp),
                      ),
                    ),
                  },
                );
              }).toList(),
            ),
          );
  }
}
