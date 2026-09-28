import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutboundMode extends ConsumerWidget {
  const OutboundMode({super.key});

  void _handleChangeMode(Mode mode, WidgetRef ref) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final height = getWidgetHeight(2);
    return SizedBox(
      height: height,
      child: Consumer(
        builder: (_, ref, _) {
          final mode = ref.watch(
            patchClashConfigProvider.select((state) => state.mode),
          );
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: CommonCard(
              onPressed: () {},
              skipTraversal: true,
              info: Info(
                label: appLocalizations.outboundMode,
                iconData: Icons.call_split_sharp,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: RadioGroup<Mode>(
                  groupValue: mode,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _handleChangeMode(value, ref);
                  },
                  child: _ModeRadioList(
                    onSelect: (item) {
                      _handleChangeMode(item, ref);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeRadioList extends StatelessWidget {
  const _ModeRadioList({required this.onSelect});

  final void Function(Mode mode) onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final minTileHeight = min(
          constraints.maxHeight / 3,
          globalState.measure.bodyMediumHeight + 16,
        );
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final item in Mode.values)
              ListItem.radio(
                horizontalTitleGap: 8,
                tileTitleAlignment: ListTileTitleAlignment.center,
                minTileHeight: minTileHeight,
                minVerticalPadding: 0,
                padding: EdgeInsets.only(left: 12.ap, right: 16.ap),
                onTap: () {
                  onSelect(item);
                },
                value: item,
                title: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.toSoftBold,
                ),
              ),
          ],
        );
      },
    );
  }
}

class OutboundModeV2 extends StatelessWidget {
  const OutboundModeV2({super.key});

  void _handleChangeMode(Mode mode, WidgetRef ref) {
    ref.read(setupActionProvider.notifier).changeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        child: Consumer(
          builder: (_, ref, _) {
            final mode = ref.watch(
              patchClashConfigProvider.select((state) => state.mode),
            );
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Mode>(
                    segments: [
                      for (final item in Mode.values)
                        ButtonSegment(value: item, label: Text(item.label)),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) {
                      _handleChangeMode(selection.single, ref);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
