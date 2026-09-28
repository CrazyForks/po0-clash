---
name: ui-work
description: Use when changing FlClash Flutter UI, widgets, screens, Material You styling, navigation surfaces, async feedback, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows, dialogs, and interaction behavior.

## Workflow

1. Locate existing nearby widgets and reuse their patterns before adding new abstractions.
2. Follow Material 3 on every platform (`docs/features/material3-ui.md`); the look never branches on the platform.
3. Use existing providers, notifiers, and helpers where possible.
4. Keep `child:` last in widget constructors.
5. Prefer `const` constructors and final locals.
6. Localize user-facing text through ARB; use `localization` when text changes are non-trivial.
7. Add focused widget tests when behavior changes, especially for rendering states, taps, scrolling, and empty/error states.
8. For asynchronous controls, define separately:
   - authoritative provider/domain state;
   - display-only state such as a minimum progress duration;
   - tap policy while work or display holds are active;
   - failure/disposal cleanup, normally in `finally` for animations and timers.
9. Run targeted verification:

   ```bash
   flutter analyze
   flutter test test/widgets/
   ```

## Shapes

All corner radii come from `lib/common/shape.dart`. Never write a radius literal in a widget. The tokens are the
Material 3 corner scale, and corners are plain rounded rectangles.

| Token | Value | Use |
| --- | --- | --- |
| `none` | 0 | square edges, and the flat side of a grouped run |
| `extraSmall` | 4 | menus, text fields, snack-bar style messages, blocks inside a rounded surface |
| `small` | 8 | chips, small badges, swatches |
| `medium` | 12 | cards (`CommonCard` and `SurfaceCard` default), icon containers |
| `large` | 16 | FABs, the inner edge of side sheets, the outer corners of a grouped run |
| `largeIncreased` | 20 | reserved |
| `extraLarge` | 28 | dialogs, bottom sheets, full-screen containers |
| `full` | 1000 | pills and circles: indicators, progress, navigation selection |

- `AppCorner` holds the scale as `double`, for `radius:` on `CommonCard` and for arithmetic.
- `AppRadius` mirrors it as `BorderRadius`, plus `all`, `top`, and `vertical` builders.
- `AppShape` mirrors it as `RoundedRectangleBorder`, plus `full` (stadium), `circle`, `input`
  (`OutlineInputBorder` on `extraSmall`), and the `all`/`top`/`vertical`/`of` builders.
- Component shapes come from the theme's Material 3 defaults; `ThemeData.withAppShapes` only sets outlined text
  fields and round progress ends. Do not restate component shapes at call sites, and leave `InputDecoration.border`
  unset so inputs inherit `AppShape.input`.

Nested radii are derived, never tokens. Concentric corners need `outer = inner + inset`, so name the inset and
compute the outer value, as the selection ring in `lib/widgets/palette.dart` does.

## Motion

Use `Durations.*` and `Easing.*` only; see `.agents/rules.md` ("Material 3 Shapes and Motion") and the transition
table in `docs/features/material3-ui.md` for which pattern fits which change.

## Pitfalls

- Do not introduce a new visual system for one screen.
- Do not manually edit generated localization or provider files.
- Avoid broad layout rewrites unless the requested change requires them.
- Do not mutate provider/domain state merely to smooth a transition. Keep presentation holds local and let real errors
  bypass them immediately.
- Do not leave loading animations active when callbacks throw. Test the exception path, not only the successful tap.

## Current Interaction Examples

- `CoreStatusButton` watches `coreStatusProvider` but keeps its 600-millisecond connecting hold locally. Taps are ignored
  during the hold or genuine connecting state; disconnected cancels the hold immediately.
- Proxy delay testing writes `0` while pending, the measured delay on success, and `-1` on failure. `DelayTestButton` resets
  its animation in `finally`.
