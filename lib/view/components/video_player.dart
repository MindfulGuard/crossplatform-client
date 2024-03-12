// Make sure to add following packages to pubspec.yaml:
// * media_kit
// * media_kit_video
// * media_kit_libs_video
import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';  

class AppPlayer extends StatefulWidget {
  String source;

  AppPlayer({
    Key? key,
    required this.source
  }) : super(key: key);
  @override
  State<AppPlayer> createState() => AppPlayerState();
}

class AppPlayerState extends State<AppPlayer> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.setPlaylistMode(PlaylistMode.loop);
    player.open(Media(widget.source));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 520,
        // Use [Video] widget to display video output.
        child: Video(
          pauseUponEnteringBackgroundMode: false,
          controller: controller,
          filterQuality: FilterQuality.medium
        ),
      ),
    );
  }
}