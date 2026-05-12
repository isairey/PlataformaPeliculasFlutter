import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../core/constants/constants.dart';
import 'package:shimmer/shimmer.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[850]!,
                        highlightColor: Colors.grey[800]!,
                        child: Container(color: Colors.black),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.white),
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white, size: 40),
                      ),
                    ),
              if (movie.mediaType == 'tv')
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      'TV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
