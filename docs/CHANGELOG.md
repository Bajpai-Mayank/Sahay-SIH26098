# SAHAY-AI — Changelog

All notable changes to this project will be documented in this file.

## [0.0.2] - 2026-09-10

### Added — Phase 2: Flutter Shell, Routing & Theming

- **Project Scaffolding:** Initialized Flutter client supporting Android, Web, and Windows targets.
- **Dependencies:** Configured `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `google_fonts`, `logger`, `intl`, and `uuid`.
- **Theming System:**
  - `AppColors` — Trauma-informed, calming deep teal, slate, emerald, and warm amber color palette.
  - `AppTypography` — Custom text themes powered by Google Fonts Inter.
  - `AppTheme` — Comprehensive Material 3 Light and Dark themes with custom input, button, and card styles.
- **Core Infrastructure:**
  - `AppConfig` and `ApiConfig` with centralized endpoints and timeouts.
  - `AppException` hierarchy covering network, auth, validation, server, and storage failures.
  - `ApiClient` wrapping Dio with `AuthInterceptor` and exception mapping.
  - `SecureStorageService` and `TokenManager` for platform-secure JWT lifecycle management.
  - `DraftStorage` providing offline check-in draft caching with idempotency UUIDs.
  - `ContextX` extensions for responsive screen queries and snack bars.
  - `FormValidators` for email, password, and required inputs.
- **Shared Models & Widgets:**
  - `UserModel`, `UserRole`, `SupportPriority` enums and models.
  - `LoadingWidget`, `AppErrorWidget` (with retry action), `EmptyStateWidget`, and `PriorityBadge`.
- **Participant / Victim Screens:**
  - `SplashScreen` with branding animation.
  - `LanguageSelectionScreen` supporting English, Hindi, and regional Indic languages.
  - `ConsentScreen` implementing explicit consent toggles for data collection, AI assistance, and voice.
  - `VictimHomeScreen` with calm non-clinical well-being status, action grid, emergency hotline banner.
  - `CheckinScreen` with 5-point mood, sleep, safety, and routine sliders + idempotency keys.
  - `ChatScreen` with supportive conversational check-in interface and mock AI responses.
  - `VoiceScreen` featuring optional audio recording UI and text fallback.
  - `RequestHelpScreen` routing human intervention requests to caseworkers.
  - `FollowupScreen` showing upcoming tele-counselling appointments and milestones.
  - `SupportStatusScreen` presenting reassuring progress without raw psychiatric scores.
- **Counsellor & Caseworker Screens:**
  - `CounsellorDashboardScreen` with priority attention tallies (URGENT: 3, HIGH: 7, MODERATE: 8) and featured `CASE-1042` card with explainable evidence factors and action buttons.
  - `PriorityQueueScreen` with multi-category filtering (ALL / URGENT / HIGH / MODERATE).
  - `CaseDetailScreen` with evidence signal breakdowns and direct outreach actions.
  - `CaseTimelineScreen` with chronological spine for intake, check-ins, assessments, and interventions.
  - `ConversationSummaryScreen` displaying privacy-preserving structured signals and topic markers.
  - `AssessmentScreen` showing multi-factor signal calculations.
  - `TrendScreen` visualizing longitudinal well-being trajectories.
  - `AlertsScreen` displaying critical and warning alert feeds with acknowledge actions.
  - `InterventionsScreen` managing action plans and modal for new support creation.
- **District & Common Screens:**
  - `DistrictDashboardScreen` featuring zonal KPI metrics, caseload distributions, and service capacities.
  - `LoginScreen` with one-tap demo role switching (Participant / Counsellor / District Lead).
  - `RegisterScreen` for onboarding.
  - `ProfileScreen` with theme toggle and language selector.
  - `PrivacyScreen` with consent toggles and data retention policies.
- **Declarative Router:** Centralized `GoRouter` configuring all 20+ feature paths.
- **Smoke Tests:** Updated `test/widget_test.dart` verifying initial app rendering.

## [0.0.1] - 2026-09-10

### Added — Phase 1: Repository Audit & Architecture

- Inspected repository (verified empty state).
- Authored 14 architecture and specification documents in `docs/`:
  - `INITIAL_REPOSITORY_AUDIT.md`
  - `ARCHITECTURE.md`
  - `DATABASE.md`
  - `AI_ARCHITECTURE.md`
  - `AI_SAFETY_BOUNDARY.md`
  - `API.md`
  - `PRIVACY_SECURITY.md`
  - `WORKFLOW.md`
  - `TESTING.md`
  - `DECISIONS.md`
  - `INTEGRATION_STATUS.md`
  - `MANUAL_SETUP.md`
  - `MODEL_RESEARCH.md`
  - `CHANGELOG.md`
