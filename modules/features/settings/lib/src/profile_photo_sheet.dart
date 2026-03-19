import 'dart:async';

import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:settings_feature/src/cubit/auth_cubit.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

Future<void> _pickProfilePhoto(
  BuildContext context,
  AuthCubit cubit,
  ImageSource source,
) async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(
    source: source,
    maxWidth: 1200,
    imageQuality: 85,
  );
  if (!context.mounted || xFile == null) return;
  final ok = await cubit.uploadProfilePhoto(xFile.path);
  if (!context.mounted) return;
  if (ok) {
    final l10n = context.l10n;
    uiSnackBar(
      context: context,
      message: l10n.profilePhotoUpdated,
      type: UiSnackbarType.success,
    );
  }
}

/// Cria a implementação de [ProfilePhotoSheet] para registro no GetIt.
ProfilePhotoSheet createProfilePhotoSheet(GetIt getIt) =>
    (context) => _showProfilePhotoSourceSheet(context, getIt);

void _showProfilePhotoSourceSheet(BuildContext context, GetIt getIt) {
  final l10n = context.l10n;
  final appColors = AppColors.fromContext(context);
  final authCubit = getIt<AuthCubit>();
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) => Theme(
        data: Theme.of(context),
        child: MediaQuery(
          data: MediaQuery.of(context),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.profilePhotoSheetTitle,
                style: AppTextStyles.h4.copyWith(
                  color: appColors.neutralBlack,
                  fontSize: AppTextStyles.h4.fontSize ?? 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: appColors.primary,
                ),
                title: Text(
                  l10n.takePhoto,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontSize: AppTextStyles.body1.fontSize ?? 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(
                    _pickProfilePhoto(
                      context,
                      authCubit,
                      ImageSource.camera,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: appColors.secondary,
                ),
                title: Text(
                  l10n.chooseFromGallery,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontSize: AppTextStyles.body1.fontSize ?? 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(
                    _pickProfilePhoto(
                      context,
                      authCubit,
                      ImageSource.gallery,
                    ),
                  );
                },
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
