import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../core/constants/constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchMoviesProvider);
    final trendingMovies = ref.watch(trendingMoviesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search TV Series, movies...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).updateQuery('');
                                    _focusNode.requestFocus();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => ref.read(searchQueryProvider.notifier).updateQuery(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? trendingMovies.when(
                      data: (movies) {
                        return CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Text('Top Searches', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final movie = movies[index];
                                  return InkWell(
                                    onTap: () => context.push('/details', extra: movie),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: CachedNetworkImage(
                                              imageUrl: '${ApiConstants.imageBaseUrl}${movie.backdropPath ?? movie.posterPath}',
                                              width: 140,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, err) => Container(
                                                width: 140,
                                                height: 80,
                                                color: Colors.grey[900],
                                                child: const Icon(Icons.error, color: Colors.white54),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              movie.title,
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: movies.length > 20 ? 20 : movies.length,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const SizedBox(),
                    )
                  : searchResults.when(
                      data: (movies) {
                        if (movies.isEmpty) {
                          return const Center(child: Text('Oh, we didn\'t find that.', style: TextStyle(color: Colors.white54, fontSize: 18)));
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
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
                      error: (err, stack) => const Center(child: Text('Error loading results', style: TextStyle(color: Colors.white))),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
