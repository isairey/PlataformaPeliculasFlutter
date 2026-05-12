import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../models/cast_member.dart';
import '../models/movie_detail.dart';
import '../core/constants/constants.dart';
import '../core/streaming/streaming_servers.dart';
import '../providers/movie_provider.dart';
import '../widgets/cast_card.dart';
import '../widgets/movie_card.dart';
import '../widgets/server_selector_sheet.dart';
import '../screens/player_screen.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  int _selectedSeason = 1;
  int _selectedEpisode = 1;
  StreamingServer _selectedServer = StreamingServer.videasy;

  bool get _isTv => widget.movie.mediaType == 'tv';

  void _onSeasonOrEpisodeChanged({int? season, int? episode}) {
    setState(() {
      if (season != null) {
        _selectedSeason = season;
        _selectedEpisode = 1;
      }
      if (episode != null) _selectedEpisode = episode;
    });
  }

  void _playNow() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PlayerScreen(
        movie: widget.movie,
        season: _selectedSeason,
        episode: _selectedEpisode,
        initialServer: _selectedServer,
      ),
    ));
  }

  Future<void> _pickServer() async {
    final result = await ServerSelectorSheet.show(context, _selectedServer);
    if (result != null && result != _selectedServer && mounted) {
      setState(() => _selectedServer = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(movieDetailProvider((widget.movie.id, widget.movie.mediaType)));
    final castAsync = ref.watch(castProvider((widget.movie.id, widget.movie.mediaType)));
    final similarAsync = ref.watch(similarProvider((widget.movie.id, widget.movie.mediaType)));

    final posterUrl =
        '${ApiConstants.originalImageBaseUrl}${widget.movie.backdropPath ?? widget.movie.posterPath}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(posterUrl)),
          SliverToBoxAdapter(child: _buildInfo(detailAsync)),
          SliverToBoxAdapter(child: _buildCast(castAsync)),
          SliverToBoxAdapter(child: _buildSimilar(similarAsync)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }

  Widget _buildHero(String posterUrl) {
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: posterUrl,
            fit: BoxFit.cover,
            errorWidget: (ctx, e, s) => Container(color: const Color(0xFF111111)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent, Colors.black45],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              widget.movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(AsyncValue<MovieDetail> detailAsync) {
    return detailAsync.when(
      loading: () => _buildInfoContent(null),
      error: (e, s) => _buildInfoContent(null),
      data: (d) => _buildInfoContent(d),
    );
  }

  Widget _buildInfoContent(MovieDetail? d) {
    final year = (d?.releaseDate ?? widget.movie.releaseDate).split('-').first;
    final rating = (d?.voteAverage ?? widget.movie.voteAverage).toStringAsFixed(1);
    final tagline = d?.tagline ?? '';
    final overview = d?.overview ?? widget.movie.overview;
    final genres = d?.genres ?? [];
    final runtime = d?.runtimeFormatted ?? '';
    final seasons = d?.numberOfSeasons;
    final serverInfo = StreamingServers.getInfo(_selectedServer);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(year, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('HD', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              if (runtime.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(runtime, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
              if (seasons != null) ...[
                const SizedBox(width: 10),
                Text('$seasons Seasons',
                    style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ],
          ),
          if (genres.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: genres
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(g.name,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ))
                  .toList(),
            ),
          ],
          if (tagline.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"$tagline"',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 16),
          if (_isTv) _buildSeasonEpisodePicker(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _playNow,
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 26),
                  label: Text(
                    _isTv
                        ? 'Play S$_selectedSeason E$_selectedEpisode'
                        : 'Play Movie',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _pickServer,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(
                    color: serverInfo.badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: serverInfo.badgeColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(serverInfo.icon, color: serverInfo.badgeColor, size: 18),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Server',
                              style: TextStyle(color: serverInfo.badgeColor, fontSize: 10)),
                          Text(serverInfo.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Overview',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            overview.isEmpty ? 'No overview available.' : overview,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSeasonEpisodePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Season & Episode',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Season',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 6),
                    _numPicker(
                      value: _selectedSeason,
                      min: 1,
                      max: 30,
                      onChanged: (v) => _onSeasonOrEpisodeChanged(season: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Episode',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 6),
                    _numPicker(
                      value: _selectedEpisode,
                      min: 1,
                      max: 50,
                      onChanged: (v) => _onSeasonOrEpisodeChanged(episode: v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('S$_selectedSeason · E$_selectedEpisode',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _numPicker({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
            onPressed: value > min ? () => onChanged(value - 1) : null,
            splashRadius: 16,
          ),
          Expanded(
            child: Text('$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white70, size: 16),
            onPressed: value < max ? () => onChanged(value + 1) : null,
            splashRadius: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCast(AsyncValue<List<CastMember>> castAsync) {
    return castAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (cast) {
        if (cast.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('Cast',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cast.length,
                itemBuilder: (ctx, i) => CastCard(cast: cast[i]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSimilar(AsyncValue<List<Movie>> similarAsync) {
    return similarAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('More Like This',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: movies.length,
                itemBuilder: (ctx, i) => MovieCard(
                  movie: movies[i],
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => DetailsScreen(movie: movies[i])),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
