import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/helpers.dart';
import '../onboarding/welcome_screen.dart';

/// Profile & Settings screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userData = ref.watch(userDataStreamProvider);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleLarge(
          color: theme.colorScheme.onBackground,
        )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          _UserInfoCard(userData: userData),
          const SizedBox(height: 24),

          // Settings sections
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                trailing: Switch(
                  value: settings.darkModeEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.menu_book,
                title: 'Daily Ayah',
                trailing: Switch(
                  value: settings.dailyAyahEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleDailyAyah(),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsSection(
            title: 'Preferences',
            children: [
              _SettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: settings.language,
                onTap: () => _showLanguagePicker(context, ref),
              ),
              _SettingsTile(
                icon: Icons.school,
                title: 'Madhhab',
                subtitle: settings.madhhab == 'none' ? 'No preference' : settings.madhhab,
                onTap: () => _showMadhhabPicker(context, ref),
              ),
              _SettingsTile(
                icon: Icons.text_fields,
                title: 'Quran Font Size',
                subtitle: '${settings.quranFontSize}px',
                onTap: () => _showFontSizePicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                titleColor: AppColors.error,
                onTap: () => _signOut(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // App version
          Center(
            child: Text(
              'Taqwa AI v1.0.0',
              style: AppTypography.bodySmall(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: 'Select Language',
        options: ['English', 'Arabic', 'Urdu', 'Turkish', 'Indonesian'],
        onSelect: (value) {
          ref.read(settingsProvider.notifier).setLanguage(value.toLowerCase());
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMadhhabPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PickerSheet(
        title: 'Select Madhhab',
        options: ['Hanafi', 'Maliki', 'Shafi\'i', 'Hanbali', 'No Preference'],
        onSelect: (value) {
          ref.read(settingsProvider.notifier).setMadhhab(
            value == 'No Preference' ? 'none' : value.toLowerCase(),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFontSizePicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quran Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: settings.quranFontSize.toDouble(),
                min: 18, max: 40, divisions: 11,
                onChanged: (v) => ref.read(settingsProvider.notifier).setQuranFontSize(v.toInt()),
              ),
              Text('بِسْمِ اللَّهِ', style: TextStyle(fontFamily: 'Amiri', fontSize: settings.quranFontSize.toDouble())),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _UserInfoCard extends StatelessWidget {
  final AsyncValue<dynamic> userData;
  const _UserInfoCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.valueOrNull?.displayName ?? 'Guest User',
                  style: AppTypography.titleLarge(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  userData.valueOrNull?.email ?? 'Sign in to sync data',
                  style: AppTypography.bodySmall(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelMedium(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _PickerSheet({required this.title, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: AppTypography.titleMedium()),
          ),
          ...options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () => onSelect(opt),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
