import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../core/constants/constants.dart';
import '../models/movie.dart';

class ShowsScreen extends ConsumerStatefulWidget {
  const ShowsScreen({super.key});

  @override
  ConsumerState<ShowsScreen> createState() => _ShowsScreenState();
}

class _ShowsScreenState extends ConsumerState<ShowsScreen> {
  double _scrollOffset = 0.0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingShows = ref.watch(trendingTvShowsProvider);
    final popularShows = ref.watch(popularTvShowsProvider);
    final topRatedShows = ref.watch(topRatedTvShowsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60.0),
        child: SafeArea(
          child: Container(
            color: Colors.black.withValues(
              alpha: (_scrollOffset / 350).clamp(0, 1).toDouble(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Row(
              children: [
                Icon(Icons.tv, color: AppColors.primary, size: 28),
                SizedBox(width: 8),
                Text(
                  'TV Shows',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100), // Space for header
                _buildSection(context, 'Trending Series', trendingShows),
                _buildSection(context, 'Popular TV Shows', popularShows),
                _buildSection(context, 'Top Rated Shows', topRatedShows),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    AsyncValue<List<Movie>> asyncMovies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: asyncMovies.when(
            data: (movies) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: movies[index],
                    onTap: () => context.push('/details', extra: movies[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(
              child: Text(
                'Error loading TV shows',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
