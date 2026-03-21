import 'package:flutter/material.dart';
import 'package:package_app_rating/package_app_rating.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

/// Modal de avaliação (estrelas + enviar), com textos via [AppLocalizations].
Future<void> showClinicianAppRatingModal({
  required BuildContext context,
  required AppRatingTranslations translations,
  required ValueChanged<int> onRatingSelected,
  required VoidCallback onDismiss,
  required VoidCallback onClose,
}) async {
  final l10n = AppLocalizations.of(context);
  String tr(String key) {
    switch (key) {
      case 'appRatingModalTitle':
        return l10n.appRatingModalTitle;
      case 'appRatingModalSubtitle':
        return l10n.appRatingModalSubtitle;
      case 'appRatingButton':
        return l10n.appRatingButton;
      default:
        return key;
    }
  }

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return _AppRatingDialog(
        translations: translations,
        tr: tr,
        onRatingSelected: onRatingSelected,
      );
    },
  );
  if (result == null) {
    onDismiss();
  }
  onClose();
}

class _AppRatingDialog extends StatefulWidget {
  const _AppRatingDialog({
    required this.translations,
    required this.tr,
    required this.onRatingSelected,
  });

  final AppRatingTranslations translations;
  final String Function(String key) tr;
  final ValueChanged<int> onRatingSelected;

  @override
  State<_AppRatingDialog> createState() => _AppRatingDialogState();
}

class _AppRatingDialogState extends State<_AppRatingDialog> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return AlertDialog(
      backgroundColor: appColors.backgroundDefault,
      title: Text(
        widget.translations.getTitle(widget.tr),
        style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.translations.getSubtitle(widget.tr),
            style: AppTextStyles.body1.copyWith(color: appColors.grayDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled = _selected >= star;
              return IconButton(
                onPressed: () => setState(() => _selected = star),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: appColors.primary,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        UiFixedButton(
          text: widget.translations.getButtonText(widget.tr),
          enabled: _selected != 0,
          onPressed: () {
            final r = _selected;
            Navigator.of(context).pop('submit');
            widget.onRatingSelected(r);
          },
        ),
      ],
    );
  }
}
