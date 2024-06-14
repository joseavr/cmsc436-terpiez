import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:terpiez/models/models.dart';
import 'package:terpiez/ui/widgets/mini_map.dart';
import 'package:terpiez/ui/widgets/spacex.dart';
import 'package:terpiez/ui/widgets/spacey.dart';
import 'package:terpiez/ui/widgets/stats.widget.dart';

class DetailView extends StatefulWidget {
  final CaughtTerpiez terp;

  // constructor
  const DetailView({
    super.key,
    required this.terp,
  });

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> with TickerProviderStateMixin {
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
            Text(widget.terp.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            baseColor: Colors.red,
            spawnMinSpeed: 10,
            spawnMaxSpeed: 40,
            spawnMinRadius: 10,
            spawnMaxRadius: 30,
            particleCount: 20,
            spawnOpacity: 0.1,
            image: Image(image: AssetImage('assets/pokeball.png')),
          ),
        ),
        vsync: this,
        child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _portraitView();
          }

          return _landscapeView();
        }),
      ),
    );
  }

  Widget _portraitView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                      tag: widget.terp.name,
                      child: Image.file(File(widget.terp.image)))
                  .animate(delay: 400.ms)
                  .then()
                  .shake(),
              const SizedBox(height: 10),
              Text(
                widget.terp.name,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ).animate(delay: 500.ms).fade().slide(),
              const SpaceY(20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 200,
                      child: MiniGoogleMapWidget(
                          caughtLocations: widget.terp.caughtLocations),
                    ),
                  ),

                  const SpaceX(8),

                  // stats
                  StatsWidget(terp: widget.terp),
                ],
              ),
              const SpaceY(20),
              Text(widget.terp.description)
            ],
          ),
        ),
      ),
    );
  }

  Widget _landscapeView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: widget.terp.name,
                child: Image.file(
                  File(widget.terp.image),
                  height: 200,
                  width: 200,
                ).animate(delay: 400.ms).then().shake(),
              ),
              const SizedBox(height: 10),
              Text(
                widget.terp.name,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ).animate(delay: 500.ms).fade().slide(),
            ],
          ),
        ),

        const SpaceX(30),

        Expanded(
          flex: 2,
          child: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: MiniGoogleMapWidget(
                    caughtLocations: widget.terp.caughtLocations),
              ),

              const SpaceX(8), //

              StatsWidget(terp: widget.terp),
            ],
          ),
        ),

        const SpaceX(30),

        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 250, child: Text(widget.terp.description)),
                ]),
          ),
        ),
      ],
    );
  }
}
