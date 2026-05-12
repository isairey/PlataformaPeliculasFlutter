import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/movie_provider.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/movie_card.dart';
import '../models/movie.dart';
import '../core/constants/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double _scrollOffset = 0.0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(trendingMoviesProvider);
    ref.invalidate(popularMoviesProvider);
    ref.invalidate(topRatedMoviesProvider);
    ref.invalidate(upcomingMoviesProvider);
    
    try {
      await Future.wait([
        ref.read(trendingMoviesProvider.future),
        ref.read(popularMoviesProvider.future),
        ref.read(topRatedMoviesProvider.future),
        ref.read(upcomingMoviesProvider.future),
      ]);
    } catch (_) {}
  }

  Widget _buildSection(String title, AsyncValue<List<Movie>> asyncMovies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 160,
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
            loading: () => const SizedBox(),
            error: (err, stack) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final trendingMovies = ref.watch(trendingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 70.0),
        child: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _scrollOffset > 50
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'MovieSync',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 22),
                    onPressed: () => context.push('/search'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.black,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: trendingMovies.when(
                data: (movies) => HeroCarousel(
                  movies: movies,
                  onTap: (movie) => context.push('/details', extra: movie),
                ),
                loading: () => const SizedBox(height: 550, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => const SizedBox(height: 550),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSection('Popular', popularMovies),
                  _buildSection('Trending Now', topRatedMovies),
                  _buildSection('Coming Soon', upcomingMovies),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
