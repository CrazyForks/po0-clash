import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreStatusButton extends ConsumerStatefulWidget {
  const CoreStatusButton({super.key});

  @override
  ConsumerState<CoreStatusButton> createState() => _CoreStatusButtonState();
}

class _CoreStatusButtonState extends ConsumerState<CoreStatusButton> {
  static const _holdDuration = Duration(milliseconds: 600);

  Timer? _holdTimer;
  CoreStatus _status = CoreStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _status = ref.read(coreStatusProvider);
    ref.listenManual(coreStatusProvider, (_, next) {
      _onStatusChanged(next);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onStatusChanged(CoreStatus next) {
    setState(() {
      _status = next;
      switch (next) {
        case CoreStatus.connecting:
          _holdTimer ??= Timer(_holdDuration, () {
            if (mounted) {
              setState(() {
                _holdTimer = null;
              });
            }
          });
          break;
        case CoreStatus.disconnected:
          _holdTimer?.cancel();
          _holdTimer = null;
          break;
        case CoreStatus.connected:
          break;
      }
    });
  }

  Future<void> _handleConnection() async {
    if (_holdTimer != null) {
      return;
    }
    final coreStatus = ref.read(coreStatusProvider);
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final tip = coreStatus == CoreStatus.connected
        ? context.appLocalizations.forceRestartCoreTip
        : context.appLocalizations.restartCoreTip;
    final res = await dialogs.showMessage(message: TextSpan(text: tip));
    if (res != true) {
      return;
    }
    try {
      await ref.read(coreActionProvider.notifier).restartCore();
    } catch (error) {
      dialogs.showNotifier(error.toString(), level: MessageLevel.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coreStatus = _holdTimer != null ? CoreStatus.connecting : _status;
    final appLocalizations = context.appLocalizations;
    final tone = switch (coreStatus) {
      CoreStatus.connecting => GlassTone.accent,
      CoreStatus.connected => GlassTone.success,
      CoreStatus.disconnected => GlassTone.danger,
    };
    final color = context.toneColor(tone);
    final label = switch (coreStatus) {
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    return FadeScaleBox(
      alignment: Alignment.centerRight,
      child: GlassButton(
        key: ValueKey(coreStatus),
        tooltip: appLocalizations.coreStatus,
        borderRadius: AppRadius.full,
        color: color.withValues(alpha: context.glass.isDark ? 0.18 : 0.12),
        rimColor: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
        onTap: _handleConnection,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 16,
              child: switch (coreStatus) {
                CoreStatus.connecting => Padding(
                  padding: const EdgeInsets.all(2),
                  child: CommonCircleLoading(color: color),
                ),
                CoreStatus.connected => Icon(
                  Icons.check,
                  size: 16,
                  color: color,
                ),
                CoreStatus.disconnected => Icon(
                  Icons.restart_alt_sharp,
                  size: 16,
                  color: color,
                ),
              },
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
