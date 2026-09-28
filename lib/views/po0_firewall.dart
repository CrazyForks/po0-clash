import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/po0_firewall.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxContentWidth = 880.0;

class Po0FirewallView extends StatelessWidget {
  const Po0FirewallView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: context.appLocalizations.po0Firewall,
      body: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: const [
              _OverviewCard(),
              _SettingsCard(),
              _TokensSection(),
              _TokenResults(),
              _DirectTip(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Tone { success, warning, danger, primary, neutral }

({Color color, Color container}) _toneColors(BuildContext context, _Tone tone) {
  final hero = HeroTheme.maybeOf(context);
  final colorScheme = context.colorScheme;
  final color = switch (tone) {
    _Tone.success => hero?.success ?? colorScheme.primary,
    _Tone.warning => hero?.warning ?? colorScheme.tertiary,
    _Tone.danger => colorScheme.error,
    _Tone.primary => colorScheme.primary,
    _Tone.neutral => colorScheme.onSurfaceVariant,
  };
  final base = hero?.content1 ?? colorScheme.surfaceContainerLow;
  return (
    color: color,
    container: Color.alphaBlend(color.withValues(alpha: 0.16), base),
  );
}

_Tone _toneOf(Po0ResultType type) => switch (type) {
  Po0ResultType.applied => _Tone.success,
  Po0ResultType.notApplied || Po0ResultType.disabled => _Tone.warning,
  Po0ResultType.rejected || Po0ResultType.error => _Tone.danger,
};

class _Section extends StatelessWidget {
  const _Section({this.title, this.trailing, required this.child});

  final String? title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Rebuilds its subtree periodically so relative times stay current.
class _Ticker extends StatefulWidget {
  const _Ticker({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

({IconData icon, _Tone tone, String title}) _overviewStatus(
  AppLocalizations appLocalizations, {
  required bool enabled,
  required bool hasTokens,
  required Po0FirewallState state,
}) {
  final results = state.results;
  final applied = results
      .where((it) => it.type == Po0ResultType.applied)
      .length;
  if (!enabled) {
    return (
      icon: Icons.shield_outlined,
      tone: _Tone.neutral,
      title: appLocalizations.po0StatusOff,
    );
  }
  if (!hasTokens) {
    return (
      icon: Icons.key_off_outlined,
      tone: _Tone.warning,
      title: appLocalizations.po0StatusNoToken,
    );
  }
  if (state.isRunning) {
    return (
      icon: Icons.sync,
      tone: _Tone.primary,
      title: appLocalizations.po0Running,
    );
  }
  if (results.isEmpty) {
    return (
      icon: Icons.schedule,
      tone: _Tone.neutral,
      title: appLocalizations.po0StatusWaiting,
    );
  }
  if (applied == results.length) {
    return (
      icon: Icons.verified_user,
      tone: _Tone.success,
      title: appLocalizations.po0StatusApplied,
    );
  }
  return (
    icon: Icons.gpp_maybe,
    tone: applied == 0 ? _Tone.danger : _Tone.warning,
    title: appLocalizations.po0StatusPartial(applied, results.length),
  );
}

class _OverviewCard extends ConsumerWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final setting = ref.watch(po0FirewallSettingProvider);
    final state = ref.watch(po0FirewallProvider);
    final notifier = ref.read(po0FirewallProvider.notifier);
    final hasTokens = po0TokensOf(setting.tokenEntries).isNotEmpty;
    final (:icon, :tone, :title) = _overviewStatus(
      appLocalizations,
      enabled: setting.enable,
      hasTokens: hasTokens,
      state: state,
    );
    final canRun = setting.enable && hasTokens && !state.isRunning;
    final exitIp = state.results.map((it) => it.currentIp).nonNulls.firstOrNull;
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: canRun ? () => unawaited(notifier.query()) : null,
          child: Text(appLocalizations.po0QueryStatus),
        ),
        FilledButton.icon(
          onPressed: canRun ? () => unawaited(notifier.whitelist()) : null,
          icon: const Icon(Icons.bolt, size: 18),
          label: Text(appLocalizations.po0WhitelistNow),
        ),
      ],
    );
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            children: [
              _StatusBadge(icon: icon, tone: tone, spinning: state.isRunning),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: commonDuration,
                      child: Text(
                        title,
                        key: ValueKey(title),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _Ticker(
                      builder: (context) {
                        final lastRunAt = state.lastRunAt;
                        final meta = [
                          ?exitIp == null
                              ? null
                              : appLocalizations.po0Exit(exitIp),
                          ?lastRunAt == null
                              ? null
                              : appLocalizations.po0LastShort(
                                  lastRunAt.getLastUpdateTimeDesc(context),
                                ),
                          ?lastRunAt == null || !setting.enable
                              ? null
                              : appLocalizations.po0PollEvery(
                                  setting.pollSeconds,
                                ),
                        ];
                        final style = context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        );
                        if (meta.isEmpty) {
                          return Text(
                            appLocalizations.po0AutoWhitelistDesc,
                            style: style,
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          children: [
                            for (final (index, segment) in meta.indexed) ...[
                              if (index > 0) Text('·', style: style),
                              Text(segment, style: style),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 16), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.tone,
    required this.spinning,
  });

  final IconData icon;
  final _Tone tone;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    final hero = HeroTheme.maybeOf(context);
    return AnimatedContainer(
      duration: commonDuration,
      curve: Curves.easeOutCubic,
      width: 52,
      height: 52,
      decoration: ShapeDecoration(
        color: colors.container,
        shape: hero != null ? AppShape.all(HeroCorner.medium) : AppShape.md,
      ),
      child: Center(
        child: spinning
            ? SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colors.color,
                ),
              )
            : Icon(icon, color: colors.color, size: 28),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return _Section(
      title: appLocalizations.settings,
      child: SurfaceCard(
        child: Column(
          children: [
            ConfigToggleItem(
              leading: const Icon(Icons.shield_outlined),
              title: (l) => l.po0AutoWhitelist,
              subtitle: (l) => l.po0AutoWhitelistDesc,
              selector: po0FirewallSettingProvider.select(
                (state) => state.enable,
              ),
              onChanged: (ref, value) => ref
                  .read(po0FirewallSettingProvider.notifier)
                  .update((state) => state.copyWith(enable: value)),
            ),
            const Divider(height: 0),
            const _PollIntervalItem(),
          ],
        ),
      ),
    );
  }
}

class _PollIntervalItem extends ConsumerWidget {
  const _PollIntervalItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final seconds = ref.watch(
      po0FirewallSettingProvider.select((state) => state.pollSeconds),
    );
    final (:min, :max) = po0PollSecondsRange;
    return ListItem.input(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.po0PollInterval),
      subtitle: Text(appLocalizations.secondsCount(seconds)),
      dialogTitle: appLocalizations.po0PollInterval,
      suffixText: appLocalizations.seconds,
      resetValue: '${defaultPo0FirewallProps.pollSeconds}',
      value: '$seconds',
      maxLength: TextInputLimits.interval,
      validator: (value) {
        final label = appLocalizations.po0PollInterval;
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(label);
        }
        final number = int.tryParse(value);
        if (number == null) {
          return appLocalizations.numberTip(label);
        }
        if (number < min || number > max) {
          return appLocalizations.po0PollIntervalRange(min, max);
        }
        return null;
      },
      onChanged: (value) {
        if (value == null) {
          return;
        }
        ref
            .read(po0FirewallSettingProvider.notifier)
            .update((state) => state.copyWith(pollSeconds: int.parse(value)));
      },
    );
  }
}

class _TokensSection extends ConsumerWidget {
  const _TokensSection();

  Future<void> _edit(WidgetRef ref, {int? index}) async {
    final entries = ref.read(po0FirewallSettingProvider).tokenEntries;
    final entry = await dialogs.showCommonDialog<Po0TokenEntry>(
      child: _TokenEntryDialog(
        entry: index == null ? null : entries[index],
        otherTokens: {
          for (final (i, it) in entries.indexed)
            if (i != index) it.token,
        },
      ),
    );
    if (entry == null) {
      return;
    }
    ref
        .read(po0FirewallSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            tokenEntries: [
              for (final (i, it) in state.tokenEntries.indexed)
                i == index ? entry : it,
              if (index == null) entry,
            ],
          ),
        );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int index) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.po0Token),
      ),
    );
    if (confirmed != true) {
      return;
    }
    ref
        .read(po0FirewallSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            tokenEntries: [...state.tokenEntries]..removeAt(index),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final entries = ref.watch(
      po0FirewallSettingProvider.select((state) => state.tokenEntries),
    );
    return _Section(
      title: appLocalizations.po0Tokens,
      trailing: TextButton.icon(
        onPressed: () => _edit(ref),
        icon: const Icon(Icons.add, size: 18),
        label: Text(appLocalizations.po0AddToken),
      ),
      child: SurfaceCard(
        child: Column(
          children: [
            if (entries.isEmpty)
              ListItem(
                leading: const Icon(Icons.key_off_outlined),
                title: Text(appLocalizations.po0TokensEmpty),
                subtitle: Text(appLocalizations.po0TokensEmptyDesc),
                onTap: () => _edit(ref),
              ),
            for (final (index, entry) in entries.indexed) ...[
              if (index > 0) const Divider(height: 0),
              _TokenEntryItem(
                entry: entry,
                onEdit: () => _edit(ref, index: index),
                onDelete: () => _delete(context, ref, index),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TokenEntryItem extends StatelessWidget {
  const _TokenEntryItem({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final Po0TokenEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final label = Po0Token(entry.token).label;
    return ListItem(
      leading: const Icon(Icons.key_outlined),
      title: Text(entry.name.isNotEmpty ? entry.name : label),
      subtitle: entry.name.isEmpty ? null : Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: appLocalizations.edit,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: appLocalizations.delete,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}

class _TokenEntryDialog extends StatefulWidget {
  const _TokenEntryDialog({required this.entry, required this.otherTokens});

  final Po0TokenEntry? entry;
  final Set<String> otherTokens;

  @override
  State<_TokenEntryDialog> createState() => _TokenEntryDialogState();
}

class _TokenEntryDialogState extends State<_TokenEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _tokenController = TextEditingController(
    text: widget.entry?.token,
  );
  late final _nameController = TextEditingController(text: widget.entry?.name);

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateToken(String? value) {
    final appLocalizations = context.appLocalizations;
    final token = value?.trim() ?? '';
    if (token.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.po0Token);
    }
    if (!isPo0Token(token)) {
      return appLocalizations.po0TokensInvalid;
    }
    if (widget.otherTokens.contains(token)) {
      return appLocalizations.po0TokenDuplicate;
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop(
      Po0TokenEntry(
        token: _tokenController.text.trim(),
        name: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: widget.entry == null
          ? appLocalizations.po0AddToken
          : appLocalizations.po0EditToken,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(appLocalizations.submit)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            spacing: 24,
            children: [
              TextFormField(
                controller: _tokenController,
                autofocus: widget.entry == null,
                inputFormatters: TextInputLimits.limit(
                  TextInputLimits.password,
                ),
                decoration: InputDecoration(
                  labelText: appLocalizations.po0Token,
                  hintText: 'pgnfw_xxx',
                ),
                validator: _validateToken,
                onFieldSubmitted: (_) => _submit(),
              ),
              TextFormField(
                controller: _nameController,
                inputFormatters: TextInputLimits.limit(TextInputLimits.name),
                decoration: InputDecoration(
                  labelText: appLocalizations.po0TokenName,
                ),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenResults extends ConsumerWidget {
  const _TokenResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(po0FirewallProvider.select((it) => it.results));
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }
    return _Section(
      title: context.appLocalizations.po0Whitelist,
      child: Column(
        children: [
          for (final (index, result) in results.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
              child: FadeScaleEnterBox(
                child: _TokenCard(index: index, result: result),
              ),
            ),
        ],
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.index, required this.result});

  final int index;
  final Po0TokenResult result;

  String _summary(AppLocalizations appLocalizations) {
    final ip = result.currentIp ?? appLocalizations.unknown;
    final message = result.message ?? '';
    return switch (result.type) {
      Po0ResultType.applied => appLocalizations.po0ResultApplied(ip),
      Po0ResultType.notApplied => appLocalizations.po0ResultNotApplied(ip),
      Po0ResultType.disabled => appLocalizations.po0ResultDisabled,
      Po0ResultType.rejected => appLocalizations.po0ResultRejected(message),
      Po0ResultType.error => appLocalizations.po0ResultError(message),
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final limit = result.limit;
    final used = result.whitelist.length;
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.name ?? result.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Pill(
                label: switch (result.type) {
                  Po0ResultType.applied => appLocalizations.po0ChipApplied,
                  Po0ResultType.notApplied =>
                    appLocalizations.po0ChipNotApplied,
                  Po0ResultType.disabled => appLocalizations.po0ChipDisabled,
                  Po0ResultType.rejected => appLocalizations.po0ChipRejected,
                  Po0ResultType.error => appLocalizations.po0ChipError,
                },
                tone: _toneOf(result.type),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _summary(appLocalizations),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (limit != null && limit > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (used / limit).clamp(0, 1).toDouble(),
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      color: _toneColors(context, _toneOf(result.type)).color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appLocalizations.po0Usage(used, limit),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (result.whitelist.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in result.whitelist)
                  _EntryChip(
                    entry: entry,
                    isCurrent: sameC24(entry.ip, result.currentIp),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});

  final String label;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.container,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EntryChip extends StatelessWidget {
  const _EntryChip({required this.entry, required this.isCurrent});

  final Po0WhitelistEntry entry;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hero = HeroTheme.maybeOf(context);
    final colors = _toneColors(context, _Tone.primary);
    final foreground = isCurrent ? colors.color : colorScheme.onSurface;
    final slot = entry.slot;
    final chip = DecoratedBox(
      decoration: ShapeDecoration(
        color: isCurrent
            ? colors.container
            : hero?.default100 ?? colorScheme.surfaceContainerHigh,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent) ...[
              Icon(Icons.my_location, size: 14, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              entry.ip,
              style: context.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            if (slot != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.push_pin, size: 13, color: foreground),
              Text(
                '$slot',
                style: context.textTheme.labelSmall?.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return isCurrent
        ? Tooltip(message: context.appLocalizations.po0CurrentExit, child: chip)
        : chip;
  }
}

class _DirectTip extends StatelessWidget {
  const _DirectTip();

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.appLocalizations.po0DirectTip,
              style: context.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
