import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/constants.dart';
import 'notification_screen.dart';

/// Preferences screen for language and madhhab selection
class PreferencesScreen extends ConsumerStatefulWidget {
  final List<String> selectedPurposes;

  const PreferencesScreen({
    super.key,
    required this.selectedPurposes,
  });

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String _selectedLanguage = 'en';
  String _selectedMadhhab = 'none';

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
              _ProgressIndicator(currentStep: 2, totalSteps: 4),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Customize your experience',
                style: AppTypography.headlineMedium(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These settings help us provide more relevant guidance',
                style: AppTypography.bodyMedium(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language selection
                      Text(
                        'Preferred Language',
                        style: AppTypography.titleSmall(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LanguageSelector(
                        selectedLanguage: _selectedLanguage,
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value);
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Madhhab selection
                      Text(
                        'Preferred Islamic School (Madhhab)',
                        style: AppTypography.titleSmall(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps provide rulings relevant to your tradition',
                        style: AppTypography.bodySmall(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MadhhabSelector(
                        selectedMadhhab: _selectedMadhhab,
                        onChanged: (value) {
                          setState(() => _selectedMadhhab = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _navigateToNext(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.labelLarge(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationScreen(
          selectedPurposes: widget.selectedPurposes,
          selectedLanguage: _selectedLanguage,
          selectedMadhhab: _selectedMadhhab,
        ),
      ),
    );
  }
}

/// Language selector widget
class _LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.languageOptions.map((lang) {
        final isSelected = selectedLanguage == lang.code;
        
        return InkWell(
          onTap: () => onChanged(lang.code),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : isDark
                      ? AppColors.darkCard
                      : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              lang.nativeName,
              style: AppTypography.labelMedium(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Madhhab selector widget
class _MadhhabSelector extends StatelessWidget {
  final String selectedMadhhab;
  final ValueChanged<String> onChanged;

  const _MadhhabSelector({
    required this.selectedMadhhab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: AppConstants.madhhabOptions.map((madhhab) {
        final isSelected = selectedMadhhab == madhhab.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(madhhab.id),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkBorder
                          : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          madhhab.name,
                          style: AppTypography.titleSmall(
                            color: isSelected
                                ? AppColors.primary
                                : isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          madhhab.arabicName,
                          style: AppTypography.bodySmall(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Progress indicator (reused from purpose_screen)
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
