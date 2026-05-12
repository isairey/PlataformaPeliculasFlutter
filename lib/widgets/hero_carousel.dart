import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../core/constants/constants.dart';

class HeroCarousel extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie) onTap;

  const HeroCarousel({super.key, required this.movies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox();

    return CarouselSlider(
      options: CarouselOptions(
        height: 550.0,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: true,
      ),
      items: movies.take(5).map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => onTap(movie),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: '${ApiConstants.originalImageBaseUrl}${movie.posterPath ?? movie.backdropPath}',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent, Colors.black45],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2))]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.push('/player', extra: movie),
                              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                              label: const Text('Play',
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => onTap(movie),
                              icon: const Icon(Icons.add, color: Colors.white, size: 28),
                              label: const Text('My List', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
