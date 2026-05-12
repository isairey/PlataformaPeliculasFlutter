import 'movie.dart';

class Genre {
  final int id;
  final String name;
  const Genre({required this.id, required this.name});
  factory Genre.fromJson(Map<String, dynamic> j) =>
      Genre(id: j['id'] ?? 0, name: j['name'] ?? '');
}

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String mediaType;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? status;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.mediaType,
    required this.genres,
    this.runtime,
    this.tagline,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> j, {String fallbackType = 'movie'}) {
    final isTv = j['media_type'] == 'tv' || j['name'] != null || j['number_of_seasons'] != null;
    final genreList = (j['genres'] as List? ?? [])
        .map((g) => Genre.fromJson(g as Map<String, dynamic>))
        .toList();

    int? runtime;
    if (j['runtime'] != null) {
      runtime = j['runtime'] as int?;
    } else {
      final rt = j['episode_run_time'];
      if (rt is List && rt.isNotEmpty) runtime = rt.first as int?;
    }

    return MovieDetail(
      id: j['id'] ?? 0,
      title: j['title'] ?? j['name'] ?? '',
      overview: j['overview'] ?? '',
      posterPath: j['poster_path'],
      backdropPath: j['backdrop_path'],
      voteAverage: (j['vote_average'] ?? 0).toDouble(),
      releaseDate: j['release_date'] ?? j['first_air_date'] ?? '',
      mediaType: isTv ? 'tv' : fallbackType,
      genres: genreList,
      runtime: runtime,
      tagline: j['tagline'] as String?,
      numberOfSeasons: j['number_of_seasons'] as int?,
      numberOfEpisodes: j['number_of_episodes'] as int?,
      status: j['status'] as String?,
    );
  }

  Movie toMovie() => Movie(
        id: id,
        title: title,
        overview: overview,
        posterPath: posterPath,
        backdropPath: backdropPath,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
        mediaType: mediaType,
      );

  String get runtimeFormatted {
    if (runtime == null) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}
