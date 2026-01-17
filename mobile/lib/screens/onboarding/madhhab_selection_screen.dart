import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_decorations.dart';

/// Madhhab Selection Screen - Choose your school of Islamic jurisprudence
/// 
/// Beautiful card-based selection with premium animations
class MadhhabSelectionScreen extends StatefulWidget {
  final Function(String madhhab) onSelect;
  final VoidCallback onSkip;

  const MadhhabSelectionScreen({
    super.key,
    required this.onSelect,
    required this.onSkip,
  });

  @override
  State<MadhhabSelectionScreen> createState() => _MadhhabSelectionScreenState();
}

class _MadhhabSelectionScreenState extends State<MadhhabSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedMadhhab;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final List<_MadhhabOption> _madhhabOptions = [
    _MadhhabOption(
      id: 'hanafi',
      name: 'Hanafi',
      arabicName: 'حنفي',
      description: 'Founded by Imam Abu Hanifa',
      icon: '🕌',
    ),
    _MadhhabOption(
      id: 'shafii',
      name: "Shafi'i",
      arabicName: 'شافعي',
      description: 'Founded by Imam al-Shafi\'i',
      icon: '📖',
    ),
    _MadhhabOption(
      id: 'maliki',
      name: 'Maliki',
      arabicName: 'مالكي',
      description: 'Founded by Imam Malik',
      icon: '🌙',
    ),
    _MadhhabOption(
      id: 'hanbali',
      name: 'Hanbali',
      arabicName: 'حنبلي',
      description: 'Founded by Imam Ahmad',
      icon: '⭐',
    ),
    _MadhhabOption(
      id: 'jafari',
      name: 'Jafari',
      arabicName: 'جعفري',
      description: 'Founded by Imam Ja\'far',
      icon: '🌟',
    ),
    _MadhhabOption(
      id: 'none',
      name: 'None',
      arabicName: 'بدون',
      description: 'No specific preference',
      icon: '🤲',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D5A3C),
              Color(0xFF084228),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Madhhab Selection',
                          style: AppTypography.headlineMedium(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose Your School of Thought\n(Madhhab) for unified guidance',
                          style: AppTypography.bodyMedium(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Madhhab Grid
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Drag handle indicator
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: _madhhabOptions.length,
                                itemBuilder: (context, index) {
                                  return _MadhhabCard(
                                    option: _madhhabOptions[index],
                                    isSelected: _selectedMadhhab == _madhhabOptions[index].id,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _selectedMadhhab = _madhhabOptions[index].id;
                                      });
                                    },
                                    delay: index,
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Continue button
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      gradient: _selectedMadhhab != null
                                          ? AppColors.cardGradient
                                          : LinearGradient(
                                              colors: [
                                                Colors.grey.shade300,
                                                Colors.grey.shade400,
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: _selectedMadhhab != null
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.4),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _selectedMadhhab != null
                                            ? () => widget.onSelect(_selectedMadhhab!)
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                          child: Text(
                                            'Continue',
                                            style: AppTypography.labelLarge(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: widget.onSkip,
                                  child: Text(
                                    'Skip for now',
                                    style: AppTypography.labelMedium(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MadhhabOption {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String icon;

  _MadhhabOption({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.icon,
  });
}

class _MadhhabCard extends StatefulWidget {
  final _MadhhabOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _MadhhabCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_MadhhabCard> createState() => _MadhhabCardState();
}

class _MadhhabCardState extends State<_MadhhabCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected 
                  ? AppColors.primary 
                  : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or emoji
              Text(
                widget.option.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                widget.option.name,
                style: AppTypography.titleMedium(
                  color: widget.isSelected 
                      ? AppColors.primary 
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              
              // Arabic name
              Text(
                widget.option.arabicName,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: widget.isSelected 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
                ),
              ),
              
              // Checkmark indicator
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
