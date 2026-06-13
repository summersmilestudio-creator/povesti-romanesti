import 'package:flutter/material.dart';
import '../data/stories.dart';
import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/reading_screen.dart';
import '../services/unlock_service.dart';
import '../theme.dart';

/// Toate poveștile sunt GRATUITE — monetizare exclusiv prin reclame.
/// (Modelul vechi cu plată unică a fost eliminat: nicio poveste nu mai e blocată.)
bool isStoryLocked(Story story) => false;

/// Deschide povestea dacă e permisă; altfel arată paywall-ul.
Future<void> openStory(
  BuildContext context,
  Story story,
  FavoritesProvider favoritesProvider,
  SettingsProvider settingsProvider,
) async {
  if (isStoryLocked(story)) {
    await showStoryPaywall(context);
    return;
  }
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReadingScreen(
        story: story,
        favoritesProvider: favoritesProvider,
        settingsProvider: settingsProvider,
      ),
    ),
  );
}

/// Dialog de deblocare: o singură plată pentru toate poveștile.
Future<void> showStoryPaywall(BuildContext context) {
  final unlock = UnlockService.instance;
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      bool busy = false;
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          final price = unlock.formattedPrice;

          Future<void> doBuy() async {
            setLocal(() => busy = true);
            final ok = await unlock.buyUnlock();
            if (!ctx.mounted) return;
            if (!ok) {
              setLocal(() => busy = false);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Cumpărarea nu e disponibilă acum. Încearcă mai târziu.'),
                ),
              );
            } else {
              Navigator.pop(ctx);
            }
          }

          Future<void> doRestore() async {
            setLocal(() => busy = true);
            await unlock.restore();
            await Future.delayed(const Duration(seconds: 1));
            if (!ctx.mounted) return;
            if (unlock.unlocked) {
              Navigator.pop(ctx);
            } else {
              setLocal(() => busy = false);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Nicio achiziție de restaurat.')),
              );
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('🔓  Deblochează poveștile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primele $kFreeStoryCount povești sunt gratuite. '
                  'Deblochează toate cele ${allStories.length} basme și legende '
                  'printr-o singură plată — pentru totdeauna, fără abonament.',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            actions: [
              TextButton(
                onPressed: busy ? null : doRestore,
                child: const Text('Restaurează'),
              ),
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(ctx),
                child: const Text('Mai târziu'),
              ),
              ElevatedButton(
                onPressed: busy ? null : doBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Deblochează · $price'),
              ),
            ],
          );
        },
      );
    },
  );
}
