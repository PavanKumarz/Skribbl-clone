import 'package:flutter/material.dart';

class PaintScoreStrip extends StatelessWidget {
  final List<Map<String, String>> rankedScoreboard;
  final String currentNickname;

  const PaintScoreStrip({
    super.key,
    required this.rankedScoreboard,
    required this.currentNickname,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rankedScoreboard.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final player = rankedScoreboard[index];
          final username = player['username'] ?? 'Unknown';
          final points = player['points'] ?? '0';
          final isCurrentUser = username == currentNickname;
          return Container(
            constraints: const BoxConstraints(minWidth: 116, maxWidth: 170),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? const Color(0xFFFFE8BE)
                  : const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCFE1FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111A3A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C5B88),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PaintScorePanel extends StatelessWidget {
  final List<Map<String, String>> rankedScoreboard;
  final String currentNickname;

  const PaintScorePanel({
    super.key,
    required this.rankedScoreboard,
    required this.currentNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0CCFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scores',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111A3A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: rankedScoreboard.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = rankedScoreboard[index];
                final username = player['username'] ?? 'Unknown';
                final points = player['points'] ?? '0';
                final isCurrentUser = username == currentNickname;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFFFFE9C2)
                        : const Color(0xFFEAF5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4C5B88),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111A3A),
                          ),
                        ),
                      ),
                      Text(
                        points,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4C5B88),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
