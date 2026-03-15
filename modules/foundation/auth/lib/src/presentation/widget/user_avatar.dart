import 'package:auth_foundation/src/auth_repository.dart';
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
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(user.photoUrl!),
        backgroundColor: colors.grayLight,
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
