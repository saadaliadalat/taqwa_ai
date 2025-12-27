import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/settings_provider.dart';

/// Offline banner widget
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'You are offline',
              style: AppTypography.labelMedium(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated offline banner that slides in/out
class AnimatedOfflineBanner extends ConsumerStatefulWidget {
  const AnimatedOfflineBanner({super.key});

  @override
  ConsumerState<AnimatedOfflineBanner> createState() => _AnimatedOfflineBannerState();
}

class _AnimatedOfflineBannerState extends ConsumerState<AnimatedOfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    // Animate based on connectivity
    if (!isOnline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'No internet connection',
                style: AppTypography.labelMedium(color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                '• Using cached data',
                style: AppTypography.labelSmall(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connectivity indicator dot
class ConnectivityIndicator extends ConsumerWidget {
  final double size;

  const ConnectivityIndicator({super.key, this.size = 8});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success : AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Scaffold wrapper with offline banner
class OfflineAwareScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const OfflineAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Sync indicator widget
class SyncIndicator extends StatelessWidget {
  final bool isSyncing;
  final int pendingCount;

  const SyncIndicator({
    super.key,
    required this.isSyncing,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSyncing && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSyncing) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Syncing...',
              style: AppTypography.labelSmall(color: AppColors.info),
            ),
          ] else if (pendingCount > 0) ...[
            Icon(
              Icons.cloud_upload_outlined,
              size: 14,
              color: AppColors.info,
            ),
            const SizedBox(width: 4),
            Text(
              '$pendingCount pending',
              style: AppTypography.labelSmall(color: AppColors.info),
            ),
          ],
        ],
      ),
    );
  }
}
