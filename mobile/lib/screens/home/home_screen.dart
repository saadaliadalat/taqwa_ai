import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/quran_provider.dart';
import '../../models/ayah_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/ayah_card.dart';
import '../../widgets/loading_widget.dart';
import '../ask_ai/ask_ai_screen.dart';
import '../favorites/favorites_screen.dart';

/// Home screen with greeting, daily ayah, and quick actions
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      ref.read(conversationsProvider.notifier).loadConversations(user.uid);
      ref.read(favoritesProvider.notifier).loadFavorites(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userData = ref.watch(userDataStreamProvider);
    final dailyAyah = ref.watch(dailyAyahProvider);
    final conversations = ref.watch(conversationsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: theme.colorScheme.background,
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'ت',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Taqwa AI',
                    style: AppTypography.titleLarge(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  _GreetingSection(
                    userName: userData.valueOrNull?.displayName,
                  ),
                  const SizedBox(height: 24),
                  
                  // Daily Ayah
                  dailyAyah.when(
                    data: (ayah) => ayah != null
                        ? _DailyAyahCard(ayah: ayah)
                        : const SizedBox.shrink(),
                    loading: () => const ShimmerCard(height: 200),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _QuickActionsSection(),
                  const SizedBox(height: 24),
                  
                  // Continue Conversation
                  if (conversations.conversations.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Continue Conversation',
                      onSeeAll: () {
                        // TODO: Navigate to conversations list
                      },
                    ),
                    const SizedBox(height: 12),
                    _RecentConversationCard(
                      conversation: conversations.conversations.first,
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Favorites Preview
                  if (favorites.favorites.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Saved Items',
                      onSeeAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _FavoritesPreview(
                      favorites: favorites.favorites.take(3).toList(),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Greeting section
class _GreetingSection extends StatelessWidget {
  final String? userName;

  const _GreetingSection({this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Helpers.getEnglishGreeting(),
          style: AppTypography.bodyLarge(
            color: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName ?? 'Seeker of Knowledge',
          style: AppTypography.headlineSmall(
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Helpers.getIslamicGreeting(),
          style: AppTypography.arabicBody(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Daily Ayah card
class _DailyAyahCard extends ConsumerWidget {
  final AyahModel ayah;

  const _DailyAyahCard({required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ayah of the Day',
                      style: AppTypography.labelSmall(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // TODO: Share ayah
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ayah.text,
            style: AppTypography.quranMedium(color: Colors.white),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          if (ayah.hasTranslation) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              ayah.translation!,
              style: AppTypography.bodyMedium(color: Colors.white.withOpacity(0.9)),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Surah ${Helpers.getSurahName(ayah.surahNumber)} ${ayah.surahNumber}:${ayah.numberInSurah}',
            style: AppTypography.labelSmall(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

/// Quick actions section
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.auto_awesome,
            label: 'Ask a Question',
            color: AppColors.primary,
            onTap: () {
              // Navigate to Ask AI (index 1 in bottom nav)
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.menu_book,
            label: 'Read Quran',
            color: AppColors.secondary,
            onTap: () {
              // Navigate to Quran (index 2 in bottom nav)
            },
          ),
        ),
      ],
    );
  }
}

/// Quick action card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.labelMedium(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          title,
          style: AppTypography.titleMedium(
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: AppTypography.labelMedium(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

/// Recent conversation card
class _RecentConversationCard extends StatelessWidget {
  final dynamic conversation;

  const _RecentConversationCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          conversation.title ?? 'New Conversation',
          style: AppTypography.titleSmall(
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (conversation.lastMessagePreview != null)
              Text(
                conversation.lastMessagePreview!,
                style: AppTypography.bodySmall(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Text(
              Helpers.formatRelativeTime(conversation.updatedAt),
              style: AppTypography.labelSmall(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to conversation
        },
      ),
    );
  }
}

/// Favorites preview
class _FavoritesPreview extends StatelessWidget {
  final List<dynamic> favorites;

  const _FavoritesPreview({required this.favorites});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < favorites.length - 1 ? 12 : 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          favorite.isAyah 
                              ? Icons.menu_book 
                              : favorite.isHadith 
                                  ? Icons.format_quote 
                                  : Icons.auto_awesome,
                          size: 16,
                          color: favorite.isAyah 
                              ? AppColors.primary 
                              : favorite.isHadith 
                                  ? AppColors.secondary 
                                  : AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            favorite.reference ?? 'AI Response',
                            style: AppTypography.labelSmall(
                              color: isDark 
                                  ? AppColors.darkTextSecondary 
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        favorite.content,
                        style: AppTypography.bodySmall(
                          color: isDark 
                              ? AppColors.darkTextPrimary 
                              : AppColors.textPrimary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
