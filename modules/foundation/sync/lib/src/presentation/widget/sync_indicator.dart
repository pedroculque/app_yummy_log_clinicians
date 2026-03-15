import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_foundation/src/presentation/cubit/sync_cubit.dart';
import 'package:sync_foundation/src/presentation/cubit/sync_state.dart';
import 'package:ui_kit/ui_kit.dart';

/// Indicador visual do status de sincronização.
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final cfg = _getConfig(context, state);

        if (compact) return _buildCompact(context, cfg);
        return _buildFull(context, cfg);
      },
    );
  }

  Widget _buildCompact(BuildContext context, _Cfg cfg) {
    return GestureDetector(
      onTap: onTap ?? () => _onTap(context, cfg),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cfg.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: cfg.loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cfg.iconColor,
                ),
              )
            : Icon(cfg.icon, size: 16, color: cfg.iconColor),
      ),
    );
  }

  Widget _buildFull(BuildContext context, _Cfg cfg) {
    final colors = AppColors.fromContext(context);

    return GestureDetector(
      onTap: onTap ?? () => _onTap(context, cfg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: cfg.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cfg.border ?? Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cfg.loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cfg.iconColor,
                ),
              )
            else
              Icon(cfg.icon, size: 16, color: cfg.iconColor),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                cfg.label,
                style: AppTextStyles.body2.copyWith(
                  color: colors.neutralBlack,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, _Cfg cfg) {
    if (cfg.canSync) unawaited(context.read<SyncCubit>().sync());
  }

  _Cfg _getConfig(BuildContext context, SyncState state) {
    final c = AppColors.fromContext(context);

    return switch (state) {
      SyncInitial() => _Cfg(
          icon: Icons.cloud_off_outlined,
          label: 'Inicializando...',
          iconColor: c.gray,
          bg: c.neutralSilver,
          loading: true,
          canSync: false,
        ),
      SyncDisabled() => _Cfg(
          icon: Icons.cloud_off_outlined,
          label: 'Faça login para sincronizar',
          iconColor: c.gray,
          bg: c.neutralSilver,
          canSync: false,
        ),
      SyncInProgress(:final message) => _Cfg(
          icon: Icons.cloud_sync_outlined,
          label: message ?? 'Sincronizando...',
          iconColor: c.primary,
          bg: c.primaryLight.withValues(alpha: 0.1),
          loading: true,
          canSync: false,
        ),
      SyncCompleted(:final lastSyncAt) => _Cfg(
          icon: Icons.cloud_done_outlined,
          label: _formatLastSync(lastSyncAt),
          iconColor: c.success,
          bg: c.successLight.withValues(alpha: 0.1),
        ),
      SyncPending(:final pendingCount) => _Cfg(
          icon: Icons.cloud_upload_outlined,
          label: '$pendingCount pendente'
              '${pendingCount > 1 ? 's' : ''}',
          iconColor: c.alert,
          bg: c.alertLight.withValues(alpha: 0.1),
        ),
      SyncError(:final message) => _Cfg(
          icon: Icons.cloud_off_outlined,
          label: message,
          iconColor: c.error,
          bg: c.errorLight.withValues(alpha: 0.1),
          border: c.error.withValues(alpha: 0.3),
        ),
    };
  }

  String _formatLastSync(DateTime lastSyncAt) {
    final diff = DateTime.now().difference(lastSyncAt);
    if (diff.inMinutes < 1) return 'Sincronizado agora';
    if (diff.inMinutes < 60) {
      return 'Sincronizado há ${diff.inMinutes}min';
    }
    if (diff.inHours < 24) {
      return 'Sincronizado há ${diff.inHours}h';
    }
    return 'Sincronizado há ${diff.inDays}d';
  }
}

class _Cfg {
  const _Cfg({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bg,
    this.border,
    this.loading = false,
    this.canSync = true,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bg;
  final Color? border;
  final bool loading;
  final bool canSync;
}
