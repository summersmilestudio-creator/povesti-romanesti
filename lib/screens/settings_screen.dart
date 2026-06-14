import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const SettingsScreen({
    super.key,
    required this.settingsProvider,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.settingsProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.settingsProvider.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;

    final settings = widget.settingsProvider;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setări',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.nightText : AppColors.warmBrown,
              ),
            ),
            const SizedBox(height: 24),

            // Night mode
            _buildSettingCard(
              isDark: isDark,
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'Mod noapte',
              subtitle: 'Culori calde și întunecate pentru citit seara',
              trailing: Switch(
                value: settings.nightMode,
                onChanged: (_) => settings.toggleNightMode(),
                activeThumbColor: AppColors.golden,
              ),
            ),
            const SizedBox(height: 16),

            // Font size
            _buildSettingCard(
              isDark: isDark,
              icon: Icons.text_fields_rounded,
              title: 'Mărime text',
              subtitle: 'Ajustează mărimea textului în povești',
              trailing: null,
              bottom: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.nightText : AppColors.warmBrown,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 16.0,
                          max: 32.0,
                          divisions: 8,
                          activeColor: AppColors.forestGreen,
                          inactiveColor: AppColors.golden.withValues(alpha: 0.3),
                          label: '${settings.fontSize.round()}',
                          onChanged: (value) => settings.setFontSize(value),
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.nightText : AppColors.warmBrown,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Previzualizare: ${settings.fontSize.round()} pt',
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightCard : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.golden.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '📖',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Povești Românești',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versiunea 2.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.nightText.withValues(alpha: 0.6)
                          : AppColors.lightBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Basme și legende românești din folclorul nostru. '
                    'Patrimoniu cultural pentru toată familia. '
                    'Fără colectare de date personale.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creat cu dragoste pentru moștenirea noastră',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.golden,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget? trailing,
    Widget? bottom,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightCard : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.golden.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.nightBackground : AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.golden,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.nightText : AppColors.warmBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.nightText.withValues(alpha: 0.6)
                            : AppColors.lightBrown,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          ?bottom,
        ],
      ),
    );
  }
}
