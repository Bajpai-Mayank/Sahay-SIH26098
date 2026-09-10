import 'package:go_router/go_router.dart';
import '../features/alerts/presentation/alerts_screen.dart';
import '../features/assessments/presentation/assessment_screen.dart';
import '../features/assessments/presentation/trend_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/checkin/presentation/checkin_screen.dart';
import '../features/counsellor/presentation/case_detail_screen.dart';
import '../features/counsellor/presentation/case_timeline_screen.dart';
import '../features/counsellor/presentation/conversation_summary_screen.dart';
import '../features/counsellor/presentation/counsellor_dashboard_screen.dart';
import '../features/counsellor/presentation/priority_queue_screen.dart';
import '../features/dashboard/presentation/district_dashboard_screen.dart';
import '../features/interventions/presentation/interventions_screen.dart';
import '../features/onboarding/presentation/consent_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/profile/presentation/privacy_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/victim/presentation/followup_screen.dart';
import '../features/victim/presentation/notifications_screen.dart';
import '../features/victim/presentation/request_help_screen.dart';
import '../features/victim/presentation/support_status_screen.dart';
import '../features/victim/presentation/victim_home_screen.dart';
import '../features/voice/presentation/voice_screen.dart';

/// Central Declarative GoRouter configuration for SAHAY-AI.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Onboarding
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/consent',
      builder: (context, state) => const ConsentScreen(),
    ),

    // Authentication
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Participant / Victim Area
    GoRoute(
      path: '/victim',
      builder: (context, state) => const VictimHomeScreen(),
    ),
    GoRoute(
      path: '/checkin',
      builder: (context, state) => const CheckinScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) => const VoiceScreen(),
    ),
    GoRoute(
      path: '/victim/request-help',
      builder: (context, state) => const RequestHelpScreen(),
    ),
    GoRoute(
      path: '/victim/followup',
      builder: (context, state) => const FollowupScreen(),
    ),
    GoRoute(
      path: '/victim/support-status',
      builder: (context, state) => const SupportStatusScreen(),
    ),
    GoRoute(
      path: '/victim/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Counsellor / Caseworker Area
    GoRoute(
      path: '/counsellor',
      builder: (context, state) => const CounsellorDashboardScreen(),
    ),
    GoRoute(
      path: '/counsellor/queue',
      builder: (context, state) {
        final priority = state.uri.queryParameters['priority'];
        return PriorityQueueScreen(initialFilter: priority);
      },
    ),
    GoRoute(
      path: '/counsellor/cases/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CASE-1042';
        return CaseDetailScreen(caseId: id);
      },
    ),
    GoRoute(
      path: '/counsellor/cases/:id/timeline',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CASE-1042';
        return CaseTimelineScreen(caseId: id);
      },
    ),
    GoRoute(
      path: '/counsellor/cases/:id/conversations',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CASE-1042';
        return ConversationSummaryScreen(caseId: id);
      },
    ),
    GoRoute(
      path: '/counsellor/cases/:id/assessments',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CASE-1042';
        return AssessmentScreen(caseId: id);
      },
    ),
    GoRoute(
      path: '/counsellor/cases/:id/trend',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CASE-1042';
        return TrendScreen(caseId: id);
      },
    ),

    // Operations & Alerts
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/interventions',
      builder: (context, state) {
        final caseId = state.uri.queryParameters['caseId'];
        return InterventionsScreen(caseId: caseId);
      },
    ),

    // District Administrator Area
    GoRoute(
      path: '/district',
      builder: (context, state) => const DistrictDashboardScreen(),
    ),

    // Shared Profile & Privacy
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
  ],
);
