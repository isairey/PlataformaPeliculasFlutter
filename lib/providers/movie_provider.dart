import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/tmdb_client.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/cast_member.dart';

final tmdbClientProvider = Provider((ref) => TMDBClient());

final trendingMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getTrendingMovies(),
);
final popularMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getPopularMovies(),
);
final topRatedMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getTopRatedMovies(),
);
final upcomingMoviesProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getUpcomingMovies(),
);

final trendingTvShowsProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getTrendingTvShows(),
);
final popularTvShowsProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getPopularTvShows(),
);
final topRatedTvShowsProvider = FutureProvider<List<Movie>>(
  (ref) => ref.watch(tmdbClientProvider).getTopRatedTvShows(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String q) => state = q;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final searchMoviesProvider =
    FutureProvider.autoDispose<List<Movie>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  await Future.delayed(const Duration(milliseconds: 500));
  return ref.watch(tmdbClientProvider).searchMovies(query);
});

final movieDetailProvider =
    FutureProvider.family<MovieDetail, (int, String)>((ref, args) {
  final (id, mediaType) = args;
  return ref.watch(tmdbClientProvider).getMovieDetail(id, mediaType);
});

final castProvider =
    FutureProvider.family<List<CastMember>, (int, String)>((ref, args) {
  final (id, mediaType) = args;
  return ref.watch(tmdbClientProvider).getCast(id, mediaType);
});



final similarProvider =
    FutureProvider.family<List<Movie>, (int, String)>((ref, args) {
  final (id, mediaType) = args;
  return ref.watch(tmdbClientProvider).getSimilar(id, mediaType);
});
