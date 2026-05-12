import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../../models/movie.dart';
import '../../models/movie_detail.dart';
import '../../models/cast_member.dart';

class TMDBClient {
  late final Dio _dio;

  TMDBClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        queryParameters: {'api_key': ApiConstants.apiKey},
      ),
    );
  }

  Future<List<Movie>> getTrendingMovies() async {
    final r = await _dio.get('/trending/movie/day');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getPopularMovies() async {
    final r = await _dio.get('/movie/popular');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final r = await _dio.get('/movie/top_rated');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final r = await _dio.get('/movie/upcoming');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    final r = await _dio.get('/search/multi', queryParameters: {'query': query});
    return (r.data['results'] as List)
        .where((e) => e['media_type'] == 'movie' || e['media_type'] == 'tv')
        .map((e) => Movie.fromJson(e))
        .toList();
  }

  Future<List<Movie>> getTrendingTvShows() async {
    final r = await _dio.get('/trending/tv/day');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getPopularTvShows() async {
    final r = await _dio.get('/tv/popular');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getTopRatedTvShows() async {
    final r = await _dio.get('/tv/top_rated');
    return (r.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<MovieDetail> getMovieDetail(int id, String mediaType) async {
    final endpoint = mediaType == 'tv' ? '/tv/$id' : '/movie/$id';
    final r = await _dio.get(endpoint);
    return MovieDetail.fromJson(r.data, fallbackType: mediaType);
  }

  Future<List<CastMember>> getCast(int id, String mediaType) async {
    final endpoint = mediaType == 'tv'
        ? '/tv/$id/aggregate_credits'
        : '/movie/$id/credits';
    final r = await _dio.get(endpoint);
    final cast = r.data['cast'] as List? ?? [];
    return cast
        .take(20)
        .map((e) => CastMember.fromJson(e))
        .toList();
  }

  Future<List<Movie>> getSimilar(int id, String mediaType) async {
    final endpoint = mediaType == 'tv'
        ? '/tv/$id/recommendations'
        : '/movie/$id/recommendations';
    final r = await _dio.get(endpoint);
    final results = r.data['results'] as List? ?? [];
    return results.take(20).map((e) {
      final map = Map<String, dynamic>.from(e);
      map['media_type'] = mediaType;
      return Movie.fromJson(map);
    }).toList();
  }
}
