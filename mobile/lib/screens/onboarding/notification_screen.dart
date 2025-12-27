import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import 'auth_screen.dart';

/// Notification permission screen
class NotificationScreen extends ConsumerStatefulWidget {
  final List<String> selectedPurposes;
  final String selectedLanguage;
  final String selectedMadhhab;

  const NotificationScreen({
    super.key,
    required this.selectedPurposes,
    required this.selectedLanguage,
    required this.selectedMadhhab,
  });

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _dailyAyahEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _ProgressIndicator(currentStep: 3, totalSteps: 4),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Stay connected',
                style: AppTypography.headlineMedium(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Receive gentle reminders and daily inspiration',
                style: AppTypography.bodyMedium(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              
              // Illustration
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Notification options
              _NotificationOption(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive important updates and reminders',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              const SizedBox(height: 16),
              _NotificationOption(
                icon: Icons.menu_book_outlined,
                title: 'Daily Ayah',
                subtitle: 'Start your day with Quranic wisdom',
                value: _dailyAyahEnabled,
                onChanged: (value) {
                  setState(() => _dailyAyahEnabled = value);
                },
              ),
              
              const Spacer(),
              
              // Enable notifications button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enableNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Enable Notifications',
                          style: AppTypography.labelLarge(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Maybe later button
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _skipNotifications,
                  child: Text(
                    'Maybe later',
                    style: AppTypography.labelMedium(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enableNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      // Request notification permission
      final notificationService = NotificationService();
      await notificationService.init();
      
      // Enable daily ayah if selected
      if (_dailyAyahEnabled) {
        await notificationService.enableDailyAyahNotifications();
      }
      
      // Navigate to auth screen
      _navigateToNext(notificationsEnabled: _notificationsEnabled);
    } catch (e) {
      // Continue anyway
      _navigateToNext(notificationsEnabled: false);
    }
  }

  void _skipNotifications() {
    _navigateToNext(notificationsEnabled: false);
  }

  void _navigateToNext({required bool notificationsEnabled}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          selectedPurposes: widget.selectedPurposes,
          selectedLanguage: widget.selectedLanguage,
          selectedMadhhab: widget.selectedMadhhab,
          notificationsEnabled: notificationsEnabled,
        ),
      ),
    );
  }
}

/// Notification option toggle
class _NotificationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall(
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Progress indicator
class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive 
                  ? AppColors.primary 
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
