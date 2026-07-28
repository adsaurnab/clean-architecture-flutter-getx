# Project Guide (Flutter + GetX, Clean Architecture)

Read this before writing any code. It defines the folder layout, naming, and
patterns for this app. When adding a feature, follow it exactly — do not
invent new patterns, folder names, or state-management approaches.

## Stack
- Flutter (Material 3, `useMaterial3: true`)
- State/DI/Routing: **GetX** (`get` package)
- Networking: **Dio**, wrapped in a custom `ApiClient`
- Local storage: `shared_preferences` via `StorageHelper` singleton
- Logging: `logger` package via `AppLogger` wrapper
- Dates/formatting: `intl`

## Top-level structure
```
lib/
  main.dart
  app/
    core/
      app_theme/        # AppColors, AppTheme
      binding/           # InitialBinding (app-wide DI, rarely touched)
      constants/          # AppConstant, gap_constants (SizedBox gaps)
      helper/              # StorageHelper, etc. singletons
      services/             # plain Dart services, framework-agnostic (see Services)
      utils/                 # extensions.dart, logger.dart
      widgets/                # shared widgets used across 2+ modules (see Widgets)
    env/
      env.dart          # EnvConfig (dev/prod)
    network/
      api_client.dart        # ApiClient (Dio wrapper)
      api_client_usage.dart  # part file; global `apiClient` instance
    modules/
      <feature_name>/
        data/
          model/                 # <Feature>Model, fromJson/toJson
          repository_impl/       # <Feature>RepositoryImpl implements domain repo
        domain/
          repository/             # abstract <Feature>Repository (interface)
        presentation/
          bindings/                # <Feature>Binding extends Bindings
          controllers/              # <Feature>Controller extends GetxController
          views/                     # <Feature>View extends GetView<Controller>
          components/
            widgets/                  # small StatelessWidgets private to this feature
    routes/
      app_pages.dart     # AppPages: route table
      app_routes.dart    # part file; Routes / _Paths constants
```

Every feature module is **self-contained** under `modules/<feature_name>/`
and follows the same `data / domain / presentation` split. Copy this
structure exactly for any new feature (e.g. `modules/settings/...`).

## Adding a new feature — step by step
When asked to add a feature called `foo`, create these files in this order:

1. `modules/foo/data/model/foo_model.dart`
    - Plain class, `final` fields, named constructor with `required`.
    - `factory FooModel.fromJson(Map<String, dynamic> json)` using `json["key"]`
      (double-quoted keys, no null-safety operators unless the field is
      genuinely optional).
    - `Map<String, dynamic> toJson()` mirroring the same keys.
2. `modules/foo/domain/repository/foo_repository.dart`
    - `abstract class FooRepository { Future<...> someMethod(); }`
    - This is the **contract**. Presentation layer only ever depends on this,
      never on the impl directly.
3. `modules/foo/data/repository_impl/foo_repository_impl.dart`
    - `class FooRepositoryImpl implements FooRepository`.
    - Real API calls go through `apiClient` (see Networking below). Mock/demo
      data (as in `home_repository_impl.dart`) is acceptable only as a
      placeholder — replace with real `apiClient` calls when a backend exists.
4. `modules/foo/presentation/controllers/foo_controller.dart`
    - `class FooController extends GetxController`.
    - Get the repository via `Get.find<FooRepository>()` (never
      `Get.find<FooRepositoryImpl>()`).
    - State is exposed as `Rx` fields: `RxList`, `RxBool isLoading`,
      `RxnString error` (nullable Rx for error messages), `Rx<T>`/`RxString`
      as needed. Never use `.obs` on private state and expose via getters —
      keep Rx fields public and final on the controller directly, mutate with
      `.value =`.
    - Fetch/init logic lives in a method (`loadX()`), called from `onInit()`.
    - Pattern:
      ```dart
      class FooController extends GetxController {
        final FooRepository repository = Get.find<FooRepository>();
        final RxList<FooModel> items = <FooModel>[].obs;
        final RxBool isLoading = false.obs;
        final RxnString error = RxnString();
 
        @override
        void onInit() {
          super.onInit();
          loadItems();
        }
 
        Future<void> loadItems() async {
          isLoading.value = true;
          error.value = null;
          try {
            items.value = await repository.getItems();
          } catch (e) {
            error.value = 'Could not load items. Check your connection and try again.';
          } finally {
            isLoading.value = false;
          }
        }
      }
      ```
5. `modules/foo/presentation/bindings/foo_binding.dart`
    - `class FooBinding extends Bindings`, registers repository first, then
      controller, both with `Get.lazyPut`:
      ```dart
      class FooBinding extends Bindings {
        @override
        void dependencies() {
          Get.lazyPut<FooRepository>(() => FooRepositoryImpl());
          Get.lazyPut<FooController>(() => FooController());
        }
      }
      ```
6. `modules/foo/presentation/components/widgets/*.dart`
    - Small, single-purpose `StatelessWidget`s, one per file, named after what
      they render (`empty_state.dart`, `error_state.dart`, `loading_state.dart`,
      `<thing>_card.dart`, etc.).
    - Only put a widget here if `foo` is the *only* module that uses it. If
      it's shared by 2+ modules, it belongs in `core/widgets/` instead — see
      the **Widgets** section below for the full rule and an example.
    - Widgets that need theme colors take `required this.colorScheme` as a
      constructor param (passed down from the view) rather than calling
      `Theme.of(context)` again inside every child, **unless** the widget is a
      true leaf/state widget (like `EmptyState`, `ErrorState`), which is
      allowed to call `Theme.of(context).colorScheme` itself.
7. `modules/foo/presentation/views/foo_view.dart`
    - `class FooView extends GetView<FooController>` (never `StatefulWidget`
      for a page root — state lives in the controller).
    - Access controller state via `controller.xxx`.
    - Reactive UI is wrapped in `Obx(() { ... })`. Inside, always handle in
      this order: loading → error → empty → data.
    - Prefer `CustomScrollView` + `SliverAppBar`/`SliverList`/`SliverPadding`
      for scrollable pages with a header, matching `home_view.dart`. Break the
      appbar and body into private `_buildAppBar` / `_buildBody` methods on
      the view class.
8. Register the route:
    - Add path constant to `routes/app_routes.dart` (`_Paths` and `Routes`).
    - Add a `GetPage` entry to `routes/app_pages.dart` importing the new
      `FooBinding` and `FooView`.

## Naming conventions
- Files: `snake_case.dart`.
- Classes: `UpperCamelCase`, prefixed with the feature name
  (`HomeController`, `HomeModel`, `HomeRepository`, `HomeRepositoryImpl`,
  `HomeBinding`, `HomeView`).
- Private class members / methods: `_leadingUnderscore`.
- Constants classes are non-instantiable: private constructor
  `ClassName._();` then `static const` members (see `AppConstant`,
  `AppColors`, `AppTheme`).
- Singletons use the private-constructor + factory pattern:
  ```dart
  class Foo {
    Foo._internal();
    static final Foo _instance = Foo._internal();
    factory Foo() => _instance;
  }
  ```
  (see `StorageHelper`, `ChatService`).

## Services
Services hold **business/integration logic that isn't UI state** — talking to
a socket, a database, a device API, a third-party SDK, background timers,
etc. This logic must survive a state-management migration untouched, so it
is written as **plain Dart, with zero GetX (or any state-mgmt) imports**.

- A service is a plain class. It never extends `GetxController`, `GetxService`,
  or anything from `package:get/get.dart`. It never holds `Rx` fields.
- Controllers/Views are the *only* GetX-aware layer. A controller calls into
  a service and exposes the result as `Rx` state for the UI. If you ever
  migrate off GetX, only the `presentation/` layer should need to change —
  every `core/services` and module service stays as-is.
- **Lifetime decides the shape:**
    - **App-lifecycle / module-lifecycle service** (needs to live once for the
      whole app, or once per module, e.g. a socket connection, a chat session,
      a cache): make it a **singleton** using the private-constructor +
      factory pattern already used for `StorageHelper`/`ChatService`.
    - **One-off / stateless operation** (a single task with no state to keep
      alive, e.g. formatting, a one-shot computation, a single API side-effect
      wrapper): make it a **normal class**, instantiated where it's needed
      (or injected via `Get.lazyPut`/constructor) — do **not** force it into a
      singleton just for consistency.
- Never build a `GetxController` or a service to do one narrow, single-use
  task that belongs to only one screen — that logic either stays inline in
  the relevant controller method, or becomes a small plain-class helper
  called by the controller. Controllers/Views only orchestrate UI state and
  navigation, per the "Adding a new feature" section above; they must not
  contain the actual business/integration logic themselves — that belongs
  in the service.
- Place a service in `core/services/` if it's shared across modules
  (e.g. `ChatService`), or in `modules/<feature>/data/services/` (or
  similar, mirroring `repository_impl/`) if it's specific to one module.

**Example — app-lifecycle singleton service:**
```dart
// core/services/socket_service.dart
// Plain Dart, no GetX import. Lives for the whole app.
class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  bool _connected = false;

  Future<void> connect(String url) async {
    // open the socket...
    _connected = true;
  }

  void send(String payload) {
    if (!_connected) return;
    // write to socket...
  }

  void dispose() {
    // close the socket...
    _connected = false;
  }
}
```

**Example — one-off, non-singleton service:**
```dart
// core/services/file_export_service.dart
// Plain Dart, stateless, created per use — not a singleton.
class FileExportService {
  Future<String> exportToCsv(List<Map<String, dynamic>> rows) async {
    // build CSV string and write to disk, return the file path
    return '/tmp/export.csv';
  }
}
```

**Example — how a controller uses a service (GetX stays in this layer only):**
```dart
class ChatController extends GetxController {
  final ChatService _chatService = ChatService(); // singleton, plain Dart
  final RxList<String> messages = <String>[].obs;

  void sendMessage(String text) {
    _chatService.send(text);     // business logic lives in the service
    messages.add(text);          // controller only updates UI state
  }
}
```

## Widgets
Where a widget lives depends on **how many places use it**, not which module
it was first written for:

- **Used in only one module** → keep it in that module's
  `presentation/components/widgets/` (e.g. `ProductCard` only makes sense in
  `modules/home`).
- **Used across 2+ modules, or is a generic app-wide building block**
  (buttons, a shared avatar, a shared empty/error/loading state, a shared
  app bar, a bottom sheet, a dialog wrapper) → move/create it in
  `core/widgets/`, one file per widget, same `StatelessWidget` conventions
  as module widgets (named constructor params, `colorScheme` passed in
  where relevant).
- If a widget starts in a module and a second module later needs the same
  thing, **promote** it: move the file to `core/widgets/`, update imports in
  both modules. Don't duplicate it a second time.

**Example — shared widget usage:**
```dart
// core/widgets/app_empty_state.dart
import 'package:flutter/material.dart';
import '../constants/gap_constants.dart';

/// Generic empty-state used by any module (home, orders, notifications...).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.message, this.icon});
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          gapH12,
          Text(message, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 15)),
        ],
      ),
    );
  }
}

// usage in any module's view:
// import '../../../../core/widgets/app_empty_state.dart';
// const AppEmptyState(message: 'No orders yet', icon: Icons.receipt_long_outlined)
```

## Theming
- All colors come from `AppColors` (`core/app_theme/app_colors.dart`) — never
  hardcode a `Color(0xFF...)` in a widget. Add new colors there, grouped
  under an existing or new `// Comment` section header.
- Light/dark `ThemeData` are built in `AppTheme` (`lightTheme`, `darkTheme`).
  If a widget needs a themed color not on `ColorScheme`, add it to
  `AppColors` and reference it directly; otherwise prefer
  `Theme.of(context).colorScheme` (e.g. `colorScheme.onSurface.withValues(alpha: 0.5)`)
  over `AppColors` for standard surface/text roles, matching existing views.
- Use `withValues(alpha: x)`, not the deprecated `withOpacity(x)`, in new
  code (existing files have both; new code should use `withValues`).
- Numeric UI constants (border radius, elevation, animation duration, avatar
  sizes) live in `AppConstant` — reuse them, don't invent new magic numbers
  for things already covered there.

```dart
// usage example
Container(
  decoration: BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppConstant.borderRadius),
  ),
);
// preferred for standard text/surface roles inside a widget:
final colorScheme = Theme.of(context).colorScheme;
Text('Hi', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)));
```

## Spacing
- Never use raw `SizedBox(height: n)` / `SizedBox(width: n)` for spacing.
  Use the pre-defined gap constants from `core/constants/gap_constants.dart`:
  `gapH2..gapH64` (vertical) and `gapW2..gapW64` (horizontal), matching the
  nearest available step. If a value isn't available, add it to
  `gap_constants.dart` rather than inlining a `SizedBox`.

```dart
// usage example
Column(
  children: [
    const Text('Title'),
    gapH8,             // instead of SizedBox(height: 8)
    const Text('Subtitle'),
  ],
);
```

## Networking
- All HTTP calls go through the single `apiClient` instance
  (`network/api_client_usage.dart`, a `part of api_client.dart`) — never
  instantiate `Dio` directly in a repository.
- `ApiClient` exposes `get(path, {queryParameters})` and
  `post(path, {data})`; extend `ApiClient` itself (not ad-hoc Dio calls) if a
  new HTTP verb is needed.
- Base URL and environment come from `EnvConfig.instance` (`app/env/env.dart`),
  not hardcoded strings. `EnvConfig.initialize(environment: ...)` is called
  once in `main.dart` before `runApp`.
- Repository implementations call `apiClient.get(...)`/`apiClient.post(...)`
  and map the JSON response through the model's `fromJson`.

```dart
// usage example inside a *RepositoryImpl
class FooRepositoryImpl implements FooRepository {
  @override
  Future<List<FooModel>> getItems() async {
    final response = await apiClient.get('/foo');
    final List data = response.data as List;
    return data.map((json) => FooModel.fromJson(json)).toList();
  }
}
```

## Storage
- Use `StorageHelper()` (singleton) for any local key-value persistence:
  `writeString/writeBool/writeInt`, `readString/readBool/readInt`, `remove`,
  `clearAll`. Do not import `shared_preferences` directly elsewhere.

```dart
// usage example
await StorageHelper().writeString('auth_token', token);
final token = StorageHelper().readString('auth_token');
```

## Logging
- Use `AppLogger.debug/info/warning/error/fatal(...)`, never `print()` or a
  raw `Logger()` instance. `error()` and `fatal()` accept optional
  `Object? error` / `StackTrace? stackTrace`.

```dart
// usage example
AppLogger.info('Loaded ${items.length} items');
try {
  await repository.getItems();
} catch (e, st) {
  AppLogger.error('Failed to load items', e, st);
}
```

## Extensions & utils
- Common formatting/helper logic goes in `core/utils/extensions.dart` as an
  `extension` on the relevant core type (`String`, `DateTime`, `int`,
  `double`), grouped by target type, each member documented with a `///`
  doc comment. Prefer adding to an existing extension over writing a
  free-standing utility function.

## Routing
- Never call `Navigator.push` directly. Use GetX navigation:
  `Get.toNamed(Routes.FOO)`, `Get.offNamed(...)`, etc.
- Route name constants belong in `Routes`/`_Paths` in `app_routes.dart`
  (uppercase snake-ish, e.g. `HOME`, `PROFILE`); the `_Paths` values are the
  actual `'/foo'` strings used by `GetPage.name`.

```dart
// usage example
Get.toNamed(Routes.PROFILE);
```

## General code style
- 2-space indentation, trailing commas on multi-line arg lists (as produced
  by `dart format`).
- Prefer `const` constructors wherever possible.
- Widgets take named, `required` constructor params; no positional params
  besides `key`.
- Keep widget `build` methods focused — extract repeated or logically
  distinct chunks (like an app bar) into private `_buildXxx` methods on the
  same class, or into a separate widget file under `components/widgets/`
  if it's reused or self-contained (see `home_view.dart`'s
  `_buildAppBar`/`_buildBody` vs. `ProductCard` as its own file).
- Icons: Material icon set with the `_rounded`/`_outlined` suffix variants
  (`Icons.wifi_off_rounded`, `Icons.mail_outline_rounded`) for visual
  consistency — pick the same suffix family used by sibling icons in that
  view.
- Import order: Flutter/Dart SDK packages first, then third-party packages,
  then relative project imports (deepest-relative last), each group
  separated by a blank line where the existing file does so.

## What NOT to do
- Don't use `setState`/`StatefulWidget` for page-level state — use a
  `GetxController` + `Obx`.
- Don't call repositories or `apiClient` directly from a `View` — always go
  through the `Controller`.
- Don't put business logic in widgets under `components/widgets/` — they
  should be presentational only, receiving data/callbacks via constructor.
- Don't bypass the `domain/repository` abstraction — controllers depend on
  the interface (`Get.find<FooRepository>()`), never the impl class.
- Don't hardcode colors, spacing, or the API base URL — use `AppColors`,
  `gap_constants.dart`/`AppConstant`, and `EnvConfig` respectively.
- Don't write a service that extends `GetxController`/`GetxService` or
  imports `package:get/get.dart` — services must be plain Dart so swapping
  state-management frameworks only touches `presentation/`.
- Don't make a service a singleton "just in case" — only make it a
  singleton if it genuinely needs to live for the app's or a module's whole
  lifecycle; a one-off operation should be a plain, freely-instantiated
  class.
- Don't build a controller or service around a single narrow one-screen task
  — controllers/views only orchestrate UI state and navigation; real
  business/integration logic belongs in a service, called by the controller.
- Don't duplicate a widget across modules — if 2+ modules need it, it
  belongs in `core/widgets/`, not copy-pasted into each module's
  `components/widgets/`.

## Quick checklist for a new feature
- [ ] `data/model/<feature>_model.dart`
- [ ] `domain/repository/<feature>_repository.dart`
- [ ] `data/repository_impl/<feature>_repository_impl.dart`
- [ ] `presentation/controllers/<feature>_controller.dart`
- [ ] `presentation/bindings/<feature>_binding.dart`
- [ ] `presentation/components/widgets/*.dart` (empty/error/loading states + item widgets) — only widgets used solely by this module
- [ ] Any widget needed by 2+ modules placed/promoted to `core/widgets/` instead
- [ ] `presentation/views/<feature>_view.dart`
- [ ] Route added to `app_routes.dart` + `app_pages.dart`
- [ ] No hardcoded colors/spacing/URLs; uses `AppColors`/gap constants/`EnvConfig`
- [ ] Uses `AppLogger`, `StorageHelper`, `apiClient` where relevant instead of raw packages
- [ ] Any business/integration logic (not UI state) extracted into a plain-Dart service, not left in the controller and not built on GetX
- [ ] Service made a singleton only if it must live for the app's/module's whole lifecycle; otherwise a plain class