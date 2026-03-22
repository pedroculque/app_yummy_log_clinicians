import 'package:auth_foundation/src/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Avatar do usuário com foto ou iniciais.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.user,
    this.size = 40,
    super.key,
  });

  final AuthUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromContext(context);

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: user.photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => ColoredBox(
              color: colors.grayLight,
              child: Center(
                child: SizedBox(
                  width: size * 0.35,
                  height: size * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => ColoredBox(
              color: colors.primary,
              child: Center(
                child: Text(
                  user.initials,
                  style: TextStyle(
                    color: colors.neutralWhite,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.primary,
      child: Text(
        user.initials,
        style: TextStyle(
          color: colors.neutralWhite,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
