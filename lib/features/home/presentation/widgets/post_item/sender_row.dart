import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/home/presentation/widgets/story_card.dart';

class SenderRow extends StatelessWidget {
  const SenderRow({
    super.key,
    required this.isAnonymous,
    required this.displayName,
    required this.displayAvatar,
  });

  final bool isAnonymous;
  final String displayName;
  final String? displayAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: displayAvatar != null
              ? ResizeImage(
                  CachedNetworkImageProvider(
                    displayAvatar!,
                    cacheManager: customCacheManager,
                  ),
                  width: 96,
                  height: 96,
                )
              : null,
          backgroundColor: isAnonymous
              ? const Color(0xFF5A4FCF).withValues(alpha: 0.3)
              : Colors.grey,
          child: displayAvatar == null
              ? Icon(
                  Icons.person,
                  color: isAnonymous ? const Color(0xFF5A4FCF) : Colors.white24,
                  size: 16,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A4FCF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Anon',
                          style: TextStyle(
                            color: Color(0xFF5A4FCF),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Text(
                'Asked',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
