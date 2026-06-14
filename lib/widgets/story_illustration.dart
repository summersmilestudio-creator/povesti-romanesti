import 'package:flutter/material.dart';
import '../models/story.dart';

/// Ilustrația custom a unei povești (înlocuiește emoji-ul vechi).
/// Dacă assetul lipsește din orice motiv, cade elegant pe emoji.
class StoryIllustration extends StatelessWidget {
  final Story story;
  final double size;

  const StoryIllustration({super.key, required this.story, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/illustrations/${story.id}.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => Center(
        child: Text(story.emoji, style: TextStyle(fontSize: size * 0.6)),
      ),
    );
  }
}
