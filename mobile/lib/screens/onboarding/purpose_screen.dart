import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/constants.dart';
import 'preferences_screen.dart';

/// Purpose selection screen
class PurposeScreen extends ConsumerStatefulWidget {
  const PurposeScreen({super.key});

  @override
  ConsumerState<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends ConsumerState<PurposeScreen> {
  final Set<String> _selectedPurposes = {};

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
              _ProgressIndicator(currentStep: 1, totalSteps: 4),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'How can we help you?',
                style: AppTypography.headlineMedium(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply to personalize your experience',
                style: AppTypography.bodyMedium(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              // Purpose options
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.purposeOptions.length,
                  itemBuilder: (context, index) {
                    final purpose = AppConstants.purposeOptions[index];
                    final isSelected = _selectedPurposes.contains(purpose.id);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PurposeCard(
                        icon: purpose.icon,
                        title: purpose.title,
                        isSelected: isSelected,
                        onTap: () => _togglePurpose(purpose.id),
                      ),
                    );
                  },
                ),
              ),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedPurposes.isNotEmpty 
                      ? () => _navigateToNext(context) 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabled,
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
              const SizedBox(height: 16),
              
              // Skip button
              Center(
                child: TextButton(
                  onPressed: () => _navigateToNext(context),
                  child: Text(
                    'Skip for now',
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

  void _togglePurpose(String purposeId) {
    setState(() {
      if (_selectedPurposes.contains(purposeId)) {
        _selectedPurposes.remove(purposeId);
      } else {
        _selectedPurposes.add(purposeId);
      }
    });
  }

  void _navigateToNext(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreferencesScreen(
          selectedPurposes: _selectedPurposes.toList(),
        ),
      ),
    );
  }
}

/// Purpose card widget
class _PurposeCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PurposeCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
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
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleSmall(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                ),
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
    );
  }
}

/// Progress indicator widget
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
        final isCurrent = index == currentStep - 1;
        
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
