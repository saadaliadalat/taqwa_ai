import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/favorite_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom_error;

/// Favorites screen
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      ref.read(favoritesProvider.notifier).loadFavorites(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Saved Items', style: AppTypography.titleLarge(
          color: theme.colorScheme.onBackground,
        )),
      ),
      body: Column(
        children: [
          _FilterChips(
            currentFilter: favoritesState.filter,
            ayahCount: favoritesState.ayahCount,
            hadithCount: favoritesState.hadithCount,
            aiResponseCount: favoritesState.aiResponseCount,
            onFilterChanged: (filter) {
              ref.read(favoritesProvider.notifier).setFilter(filter);
            },
          ),
          Expanded(
            child: favoritesState.isLoading
                ? const LoadingWidget()
                : favoritesState.filteredFavorites.isEmpty
                    ? _EmptyFavorites(filter: favoritesState.filter)
                    : _FavoritesList(
                        favorites: favoritesState.filteredFavorites,
                        onDelete: (id) => ref.read(favoritesProvider.notifier).removeFavorite(id),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final FavoriteFilter currentFilter;
  final int ayahCount, hadithCount, aiResponseCount;
  final ValueChanged<FavoriteFilter> onFilterChanged;

  const _FilterChips({
    required this.currentFilter,
    required this.ayahCount,
    required this.hadithCount,
    required this.aiResponseCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Chip('All', ayahCount + hadithCount + aiResponseCount, currentFilter == FavoriteFilter.all, () => onFilterChanged(FavoriteFilter.all)),
          const SizedBox(width: 8),
          _Chip('Quran', ayahCount, currentFilter == FavoriteFilter.ayah, () => onFilterChanged(FavoriteFilter.ayah), AppColors.primary),
          const SizedBox(width: 8),
          _Chip('Hadith', hadithCount, currentFilter == FavoriteFilter.hadith, () => onFilterChanged(FavoriteFilter.hadith), AppColors.secondary),
          const SizedBox(width: 8),
          _Chip('AI', aiResponseCount, currentFilter == FavoriteFilter.aiResponse, () => onFilterChanged(FavoriteFilter.aiResponse), AppColors.info),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _Chip(this.label, this.count, this.isSelected, this.onTap, [this.color]);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.15) : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : AppColors.border),
        ),
        child: Row(
          children: [
            Text(label, style: AppTypography.labelMedium(color: isSelected ? c : AppColors.textPrimary)),
            const SizedBox(width: 6),
            Text(count.toString(), style: AppTypography.labelSmall(color: isSelected ? c : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final FavoriteFilter filter;
  const _EmptyFavorites({required this.filter});

  @override
  Widget build(BuildContext context) {
    return custom_error.EmptyStateWidget(
      title: 'No saved items yet',
      message: 'Items you save will appear here',
      icon: Icons.bookmark_outline,
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<FavoriteModel> favorites;
  final ValueChanged<String> onDelete;

  const _FavoritesList({required this.favorites, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return _FavoriteItem(favorite: fav, onDelete: () => onDelete(fav.id));
      },
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onDelete;

  const _FavoriteItem({required this.favorite, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = favorite.isAyah ? AppColors.primary : favorite.isHadith ? AppColors.secondary : AppColors.info;
    final icon = favorite.isAyah ? Icons.menu_book : favorite.isHadith ? Icons.format_quote : Icons.auto_awesome;

    return Dismissible(
      key: Key(favorite.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(color: AppColors.error, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          title: Text(favorite.reference ?? 'AI Response', style: AppTypography.labelMedium(color: color)),
          subtitle: Text(favorite.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        ),
      ),
    );
  }
}
