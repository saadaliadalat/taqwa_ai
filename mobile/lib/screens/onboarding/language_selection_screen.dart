import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Language Selection Screen - Choose preferred language
/// 
/// Premium design with flag icons and smooth animations
class LanguageSelectionScreen extends StatefulWidget {
  final Function(String language) onSelect;
  final VoidCallback onBack;

  const LanguageSelectionScreen({
    super.key,
    required this.onSelect,
    required this.onBack,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final List<_LanguageOption> _languageOptions = [
    _LanguageOption(
      id: 'english',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    _LanguageOption(
      id: 'arabic',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    _LanguageOption(
      id: 'urdu',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
    ),
    _LanguageOption(
      id: 'malay',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
    ),
    _LanguageOption(
      id: 'indonesian',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
    _LanguageOption(
      id: 'french',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Default to English
    _selectedLanguage = 'english';
    
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
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Language Selection',
                          style: AppTypography.headlineMedium(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select Your Preferred Language',
                          style: AppTypography.bodyMedium(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Language Grid
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
                                  childAspectRatio: 1.3,
                                ),
                                itemCount: _languageOptions.length,
                                itemBuilder: (context, index) {
                                  return _LanguageCard(
                                    option: _languageOptions[index],
                                    isSelected: _selectedLanguage == _languageOptions[index].id,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _selectedLanguage = _languageOptions[index].id;
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
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.cardGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => widget.onSelect(_selectedLanguage!),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Text(
                                        'Continue',
                                        style: AppTypography.labelLarge(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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

class _LanguageOption {
  final String id;
  final String name;
  final String nativeName;
  final String flag;

  _LanguageOption({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class _LanguageCard extends StatefulWidget {
  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _LanguageCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard>
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
    
    Future.delayed(Duration(milliseconds: widget.delay * 80), () {
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
          child: Stack(
            children: [
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Flag
                    Text(
                      widget.option.flag,
                      style: const TextStyle(fontSize: 36),
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
                    const SizedBox(height: 2),
                    
                    // Native name
                    Text(
                      widget.option.nativeName,
                      style: AppTypography.bodySmall(
                        color: widget.isSelected 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkmark
              if (widget.isSelected)
                Positioned(
                  top: 12,
                  right: 12,
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
