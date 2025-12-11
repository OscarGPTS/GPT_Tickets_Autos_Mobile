import 'package:flutter/material.dart';

class UserAppBarWidget extends StatelessWidget {
  final String? userEmail;
  final String? photoUrl;
  final String? userName;

  const UserAppBarWidget({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                userName ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                userEmail ?? '',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    userName != null && userName!.isNotEmpty
                        ? userName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
