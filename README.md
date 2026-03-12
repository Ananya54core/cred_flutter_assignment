# CRED Bills — Vertical Carousel Assignment

A Flutter application implementing a swipeable vertical card carousel that replicates the CRED bill payments UI. Data is fetched from mock APIs and displayed with smooth animations, tag text flipping, and proper state handling.

---

## 🏗️ Architecture

The project follows a **layered architecture** with clear separation of concerns:

```
lib/app/
├── data/
│   ├── exceptions/      → Custom exception handling (NetworkException)
│   ├── models/           → Data models (BillCardModel, BillSectionModel, FlipperConfig)
│   ├── providers/        → Network layer (ApiService with Dio, NetworkInterceptor)
│   └── repositories/     → Data orchestration (BillRepository)
├── modules/
│   └── home/
│       ├── bindings/     → Dependency injection (HomeBinding)
│       ├── controllers/  → Business logic (HomeController)
│       └── views/        → UI screens (HomeView)
├── routes/               → Named routing configuration
├── utils/                → Shared constants (AppColors, AppTheme, CommonWidgets)
└── widgets/              → Reusable UI components (BillCard, FlipperText, Carousel)
```

**Data flows unidirectionally:**  
`ApiService` → `BillRepository` → `HomeController` → `HomeView` → `Widgets`

---

## 🛠️ Tech Choices

| Area | Choice | Rationale |
|------|--------|-----------|
| **State Management** | GetX | Lightweight reactive state with `.obs` observables, built-in DI via `Bindings`, and simple named routing — ideal for a focused single-screen app |
| **Networking** | Dio | Interceptor support for request/response logging, configurable timeouts, and clean error handling via `DioException` mapping |
| **Image Caching** | cached_network_image | Efficient caching of card logos with placeholder/error widget support |
| **Fonts** | Google Fonts (Inter) | Modern, clean typography matching the CRED design language |
| **Carousel** | Custom-built | Hand-built `VerticalRotatingCarousel` widget using `Stack` + `Positioned` + `AnimationController` for precise control over the stacked-papers animation and frame-level performance |

---

## 📱 States Handled

### 1. ≤ 2 Items (Mock1)
Cards are displayed as a simple **static vertical list** — no carousel or swipe gestures. Matches the design spec for the 2-card state.

### 2. > 2 Items (Mock2)
Cards are displayed in an **animated vertical carousel** with swipe-to-dismiss behavior. The top card slides up and out, remaining cards shift up, and a new card enters from below — like a stack of papers.

### 3. Additional States
- **Loading** — fullscreen spinner while APIs are fetched
- **Error** — error message with retry button on network failure
- **Empty** — gracefully handles empty card list
- **Tag text flipping** — 3D cube rotation animation when `flipper_config` is present; static `footer_text` as fallback

---

## 🧪 Tests Covered

**49 tests across 5 files — all passing.**

Run all tests:
```bash
flutter test
```

| Test File | Tests | What It Covers |
|-----------|-------|----------------|
| `test/model_test.dart` | 21 | JSON parsing for all data models — `BillCardModel`, `BillSectionModel`, `FlipperConfig`, `LogoModel`, `CtaModel`, `CardsAnimationConfig`. Includes edge cases: missing fields, defaults, empty data, auto-pay detection |
| `test/carousel_test.dart` | 7 | Carousel UI states — 0 items (empty), ≤2 items (static list), >2 items (swipeable carousel), swipe advancing, multiple consecutive swipes, full wrap-around cycle |
| `test/flipper_text_test.dart` | 7 | Tag text behavior — footer text fallback, flipper config cycling, continuous loop, finalStage inclusion, "DUE" → "Due soon" conversion, single-item no-flip |
| `test/controller_test.dart` | 7 | HomeController logic — loading/success states, default mock2 selection, API toggle switching, NetworkException handling, generic error handling, retry, cache speed |
| `test/performance_test.dart` | 5 | Animation smoothness — frame-by-frame rendering at 60fps, rapid multiple swipes, frame count budget validation, settle-time verification, full-cycle stress test |

---

## 🔧 How to Run

### Prerequisites
- Flutter SDK (3.7.2+)
- Chrome browser (for web development)

### Run on Web
```bash
flutter pub get
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

The `--disable-web-security` flag is needed because the mock APIs are served from a different domain and don't have CORS headers.

### Run on Android
```bash
flutter build apk --release
```

### Run Tests
```bash
flutter test
```

---

## 📝 Assumptions

1. **Auto-pay badge logic** — The API does not have a dedicated `is_auto_pay_enabled` field. Auto-pay is inferred from `payment_tag == "OUTSTANDING"`, which is an assumption based on the mock data where outstanding bills appeared to have auto-pay enabled.

2. **"DUE" text handling** — The mock API sends the literal text `"DUE"` for one card, which looks incomplete in the UI. This is auto-corrected to `"Due soon"` for better readability.

3. **Flipper delay override** — The API's `flip_delay` defaults to 2000ms when not specified. This was increased to 5000ms as the default for a more comfortable reading pace, since the tagline text cycles continuously.

4. **Carousel minimum card count** — The carousel animation requires at least 5 unique cards to populate all 5 visible slots without duplicate keys. For card counts between 3-4, the behavior may need additional handling. Since the assignment specifies only 2 or 9+ cards, this edge case is acceptable.

5. **Tag text animation** — The problem statement mentions tag text should "flip." This was implemented as a 3D cube rotation animation (rotating around the X-axis with perspective) rather than a simple text swap, for a more premium visual effect.

6. **Web for development** — The app was primarily developed and tested via Chrome web. The carousel and animations are optimized for Flutter's standard rendering pipeline and work across platforms.

7. **PayButton display** — The "Pay" prefix is stripped from the CTA button title (e.g., "Pay ₹200" → "₹200") for a cleaner card layout, matching the CRED design where the button label is just the amount.

---

## 🤖 AI Disclosure

AI tools were used during the development of this project in the following areas:

- **FlipperText animation** — The 3D cube rotation animation for the tag text transition was developed with AI assistance (transition logic, Matrix4 perspective transforms, and continuous cycling behavior).
- **Test scaffolding** — AI assisted in structuring and writing the test files (`model_test.dart`, `carousel_test.dart`, `flipper_text_test.dart`, `controller_test.dart`, `performance_test.dart`).
- **Code review** — AI was used to review the codebase against the assignment's "Points to ensure" checklist and identify gaps.

All core architecture decisions, widget implementations, API integration, state management, and carousel design were done manually.

---

## 📦 Project Structure

```
lib/
├── main.dart                              → App entry point
├── app/
│   ├── data/
│   │   ├── exceptions/
│   │   │   └── network_exception.dart     → Dio error → user-friendly messages
│   │   ├── models/
│   │   │   ├── bill_card_model.dart       → Card, Logo, CTA, Background, FlipperConfig models
│   │   │   └── bill_section_model.dart    → Section wrapper + animation config
│   │   ├── providers/
│   │   │   ├── api_service.dart           → Dio HTTP client
│   │   │   └── network_interceptor.dart   → Request/response logging
│   │   └── repositories/
│   │       └── bill_repository.dart       → Fetches + parses API data
│   ├── modules/
│   │   └── home/
│   │       ├── bindings/
│   │       │   └── home_binding.dart      → DI: ApiService → Repository → Controller
│   │       ├── controllers/
│   │       │   └── home_controller.dart   → Reactive state, pre-fetch, toggle
│   │       └── views/
│   │           └── home_view.dart         → Main screen UI
│   ├── routes/
│   │   ├── app_pages.dart                 → Route definitions
│   │   └── app_routes.dart                → Route constants
│   ├── utils/
│   │   ├── app_colors.dart                → Centralized color palette
│   │   ├── app_theme.dart                 → ThemeData configuration
│   │   └── common_widgets.dart            → SectionHeader, PayButton, LogoAvatar, etc.
│   └── widgets/
│       ├── bill_card.dart                 → Individual card row widget
│       ├── flipper_text.dart              → 3D cube-rotation tag text animator
│       ├── vertical_rotating_carousel.dart → Custom stacked-papers carousel
│       └── vertical_stack_carousel.dart   → (Unused fallback — kept for reference)
test/
├── model_test.dart                        → Data model parsing tests
├── carousel_test.dart                     → Carousel UI state tests
├── flipper_text_test.dart                 → Tag text behavior tests
├── controller_test.dart                   → HomeController unit tests
└── performance_test.dart                  → Animation smoothness tests
```
