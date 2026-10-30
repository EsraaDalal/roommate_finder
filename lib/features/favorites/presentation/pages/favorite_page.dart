
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/app_brand_mark.dart';
import '../../../../core/widgets/section_header.dart';

import '../../../discovery/presentation/widgets/listing_card_widgets.dart';

import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';
import '../widgets/favorite_listing_card.dart';



class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      context.read<FavoritesBloc>().add(
        LoadFavorites(userId: uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBrandMark(),
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(
                      title: 'Saved places',
                      subtitle:
                          'Homes you would love to come back to.',
                    ),
                  ],
                ),
              ),
            ),
      
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
           const SliverToBoxAdapter(
  child: SizedBox(height: 15),
),
            const _FavoritesList(),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is FavoritesLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      builder: (context, state) {
        if (state is FavoritesInitial ||
            state is FavoritesLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is FavoritesError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  final uid =
                      FirebaseAuth.instance.currentUser?.uid;

                  if (uid != null) {
                    context.read<FavoritesBloc>().add(
                      LoadFavorites(userId: uid),
                    );
                  }
                },
                child: const Text('Retry'),
              ),
            ),
          );
        }

        if (state is FavoritesLoaded) {
          final favorites = state.favorites;

          if (favorites.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyResults(
                title: 'No saved places yet',
                message:
                    'Tap the heart on any listing to keep it here for later.',
              ),
            );
          }

          return SliverList.separated(
            itemCount: favorites.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final favorite = favorites[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: FavoriteListingCard(
                  favorite: favorite,
                  isFavorite: true,
                  onFavoriteToggle: () {
                    context.read<FavoritesBloc>().add(
                      ToggleFavorite(listing: favorite),
                    );
                  },
                   onTap: () {
    
  },
                ),
              );
            },
          );
        }

        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
      },
    );
  }
}
