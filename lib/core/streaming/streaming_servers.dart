import 'package:flutter/material.dart';

enum StreamingServer { vidlink, videasy, vidfast, movies111 }

class ServerInfo {
  final StreamingServer server;
  final String name;
  final String description;
  final IconData icon;
  final Color badgeColor;
  final String embedHost;

  const ServerInfo({
    required this.server,
    required this.name,
    required this.description,
    required this.icon,
    required this.badgeColor,
    required this.embedHost,
  });

  Map<String, String> get headers => {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        'Referer': 'https://$embedHost/',
        'Origin': 'https://$embedHost',
      };
}

class StreamingServers {
  static const List<ServerInfo> all = [
    ServerInfo(
      server: StreamingServer.vidlink,
      name: 'VidLink Pro',
      description: 'Ad-Free',
      icon: Icons.link,
      badgeColor: Color(0xFF2196F3),
      embedHost: 'vidlink.pro',
    ),
    ServerInfo(
      server: StreamingServer.videasy,
      name: 'Videasy',
      description: 'Ad-Free & Great UI',
      icon: Icons.smart_display_outlined,
      badgeColor: Color(0xFF9C27B0),
      embedHost: 'player.videasy.net',
    ),
    ServerInfo(
      server: StreamingServer.vidfast,
      name: 'Vidfast',
      description: 'Fast & HD',
      icon: Icons.speed,
      badgeColor: Color(0xFFE91E63),
      embedHost: 'vidfast.net',
    ),
    ServerInfo(
      server: StreamingServer.movies111,
      name: '111Movies',
      description: 'Ad-Free & Fast',
      icon: Icons.movie_filter_outlined,
      badgeColor: Color(0xFF00BCD4),
      embedHost: '111movies.net',
    ),
  ];

  static ServerInfo getInfo(StreamingServer server) =>
      all.firstWhere((s) => s.server == server, orElse: () => all.first);


  static String buildUrl(
    StreamingServer server,
    int tmdbId,
    String mediaType, {
    int season = 1,
    int episode = 1,
  }) {
    final tv = mediaType == 'tv';
    switch (server) {
      case StreamingServer.vidlink:
        return tv
            ? 'https://vidlink.pro/tv/$tmdbId/$season/$episode'
            : 'https://vidlink.pro/movie/$tmdbId';
      case StreamingServer.videasy:
        return tv
            ? 'https://player.videasy.net/tv/$tmdbId/$season/$episode'
            : 'https://player.videasy.net/movie/$tmdbId';
      case StreamingServer.vidfast:
        return tv
            ? 'https://vidfast.pro/tv/$tmdbId/$season/$episode?autoPlay=true&title=false&hideServer=true'
            : 'https://vidfast.pro/movie/$tmdbId?autoPlay=true&title=false&hideServer=true';
      case StreamingServer.movies111:
        return tv
            ? 'https://111movies.net/tv/$tmdbId/$season/$episode'
            : 'https://111movies.net/movie/$tmdbId';
    }
  }
}
