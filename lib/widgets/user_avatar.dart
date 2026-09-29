import 'package:flutter/material.dart';
import '../services/services.dart';

/// Shows a network image, falling back to an initial (or a person icon).
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor; // solid fallback colour; gradient if null
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final trimmed = name.trim();

    final fallback = Center(
      child: trimmed.isEmpty
          ? Icon(Icons.person, color: textColor ?? Colors.white, size: size * 0.55)
          : Text(
              trimmed[0].toUpperCase(),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
            ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        gradient: backgroundColor == null
            ? const LinearGradient(colors: [Color(0xFF3CB6A6), Color(0xFF1B5C53)])
            : null,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}

/// Avatar of the logged-in user. Rebuilds automatically when the photo changes.
class CurrentUserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const CurrentUserAvatar({super.key, this.name = "", this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AccountService.currentAvatarUrl,
      builder: (_, url, __) => UserAvatar(imageUrl: url, name: name, size: size),
    );
  }
}