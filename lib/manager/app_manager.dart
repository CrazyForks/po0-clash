import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/permission.dart';
import 'package:fl_clash/common/system_dns.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/po0_screen.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/animated_visibility.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(checkIpProvider, (prev, next) {
      if (prev != next && next.isInit && next.containsDetection) {
        ref.read(networkDetectionProvider.notifier).startCheck();
      }
    });
    ref.listenManual(configProvider, (prev, next) {
      if (prev != next) {
        ref.read(storeActionProvider.notifier).savePreferencesDebounce();
      }
    });
    ref.listenManual(needUpdateGroupsProvider, (prev, next) {
      if (prev != next) {
        ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
      }
    });
    ref.listenManual(suspendProvider, (prev, next) {
      final isStart = ref.read(isStartProvider);
      if (prev != next && isStart) {
        debouncer.call(FunctionTag.suspend, () async {
          final core = ref.read(coreHandlerProvider);
          if (next == true) {
            await core.stopListener();
          } else {
            await core.startListener();
          }
          ref.read(checkIpNumProvider.notifier).add();
        });
      }
    });
    ref.listenManual(initProvider, (prev, next) {
      if (next) {
        ref.read(po0FirewallProvider.notifier).start();
      }
    }, fireImmediately: true);
    po0Screen?.listen(ref.read(po0FirewallProvider.notifier).setScreenOn);
    final systemDns = systemDnsCoordinator;
    if (systemDns != null) {
      ref.listenManual(shouldPatchSystemDnsProvider, (prev, next) {
        unawaited(systemDns.sync(next));
      }, fireImmediately: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    if (state == AppLifecycleState.resumed) {
      permissions.check(ref.read);
      render?.resume();
      ref.read(po0FirewallProvider.notifier).pollNow();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(setupActionProvider.notifier).tryCheckIp();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(themeActionProvider.notifier).updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (_) {
        render?.resume();
      },
      child: widget.child,
    );
  }
}

class AppEnvManager extends StatelessWidget {
  final Widget child;

  const AppEnvManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      if (globalState.isPre) {
        return Banner(
          message: 'DEBUG',
          location: BannerLocation.topEnd,
          child: child,
        );
      }
    }
    if (globalState.isPre) {
      return Banner(
        message: globalState.appEnv.toUpperCase(),
        location: BannerLocation.topEnd,
        child: child,
      );
    }
    return child;
  }
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail({
    required this.items,
    required this.currentIndex,
    required this.extended,
    required this.onSelected,
    this.onToggleExtended,
  });

  static const extendedWidth = 220.0;

  final List<NavigationItem> items;
  final int currentIndex;
  final bool extended;
  final void Function(int index) onSelected;
  final VoidCallback? onToggleExtended;

  @override
  Widget build(BuildContext context) {
    final onToggleExtended = this.onToggleExtended;
    return NavigationRail(
      scrollable: true,
      extended: extended,
      minExtendedWidth: extendedWidth,
      backgroundColor: Colors.transparent,
      labelType: extended ? NavigationRailLabelType.none : null,
      leading: onToggleExtended == null
          ? null
          : IconButton(
              tooltip: context.appLocalizations.toggleLabel,
              onPressed: onToggleExtended,
              icon: Icon(extended ? Icons.menu_open : Icons.menu),
            ),
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: item.icon,
            label: Text(item.label.label),
          ),
      ],
      onDestinationSelected: onSelected,
      selectedIndex: currentIndex,
    );
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  Widget _buildBackground({
    required BuildContext context,
    required Widget child,
  }) {
    return Material(color: context.colorScheme.surfaceContainer, child: child);
  }

  void _updateSideBarWidth(WidgetRef ref, double contentWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value =
          ref.read(viewSizeProvider.select((state) => state.width)) -
          contentWidth;
    });
  }

  void _handleToPage(WidgetRef ref, PageLabel pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final preserveNavigationFocus =
        focusNode?.context?.findAncestorWidgetOfExactType<NavigationRail>() !=
        null;
    ref.read(currentPageLabelProvider.notifier).toPage(pageLabel);
    if (!preserveNavigationFocus || focusNode == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.context != null && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  void _toggleLabel(WidgetRef ref) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showLabel: !state.showLabel));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = navigationState.navigationItems;
    final viewMode = navigationState.viewMode;
    final currentIndex = navigationState.currentIndex;
    final showLabel = ref.watch(appSettingProvider).showLabel;
    final canExtend = viewMode == ViewMode.desktop;
    return Container(
      color: context.colorScheme.surfaceContainer,
      child: Row(
        children: [
          AnimatedVisibility.sidebar(
            visible: viewMode != ViewMode.mobile,
            child: _buildBackground(
              context: context,
              child: SafeArea(
                child: Column(
                  children: [
                    if (system.isMacOS) const SizedBox(height: 22),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const HiddenBarScrollBehavior(),
                        child: _SidebarRail(
                          items: navigationItems,
                          currentIndex: currentIndex,
                          extended: canExtend && showLabel,
                          onToggleExtended: canExtend
                              ? () => _toggleLabel(ref)
                              : null,
                          onSelected: (index) {
                            _handleToPage(ref, navigationItems[index].label);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRect(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  _updateSideBarWidth(ref, constraints.maxWidth);
                  return child;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
