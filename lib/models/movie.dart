class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String mediaType;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.mediaType = 'movie',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String mediaType = json['media_type'] ?? (json['name'] != null ? 'tv' : 'movie');
    
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: mediaType,
    );
  }
}
