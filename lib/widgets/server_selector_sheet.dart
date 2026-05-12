import 'package:flutter/material.dart';
import '../core/streaming/streaming_servers.dart';

class ServerSelectorSheet extends StatelessWidget {
  final StreamingServer current;
  final ValueChanged<StreamingServer> onSelected;

  const ServerSelectorSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  static Future<StreamingServer?> show(BuildContext context, StreamingServer current) {
    return showModalBottomSheet<StreamingServer>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ServerSelectorSheet(
        current: current,
        onSelected: (s) => Navigator.pop(context, s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose Server',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Switch if a server is slow or not working',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: StreamingServers.all
                    .map((info) => _buildTile(info))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(ServerInfo info) {
    final selected = info.server == current;
    return InkWell(
      onTap: () => onSelected(info.server),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? info.badgeColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? info.badgeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: info.badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(info.icon, color: info.badgeColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    info.description,
                    style: TextStyle(color: info.badgeColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: info.badgeColor, size: 22),
          ],
        ),
      ),
    );
  }
}
