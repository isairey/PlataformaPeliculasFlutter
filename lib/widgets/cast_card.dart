import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cast_member.dart';
import '../core/constants/constants.dart';

class CastCard extends StatelessWidget {
  final CastMember cast;
  const CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: cast.profilePath != null
                ? CachedNetworkImage(
                    imageUrl:
                        '${ApiConstants.imageBaseUrl}${cast.profilePath}',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (ctx, e, s) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            cast.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            cast.character,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Colors.white38, size: 36),
      );
}
