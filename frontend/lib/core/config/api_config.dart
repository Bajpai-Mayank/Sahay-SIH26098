/// Central API and network settings for SAHAY-AI.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoint paths
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  static const String userMe = '/users/me';
  static const String userPreferences = '/users/me/preferences';

  static const String cases = '/cases';
  static String caseById(String id) => '/cases/$id';
  static String caseConsent(String id) => '/cases/$id/consent';
  static String caseCheckins(String id) => '/cases/$id/checkins';
  static String caseTimeline(String id) => '/cases/$id/timeline';
  static String caseAssessments(String id) => '/cases/$id/assessments';
  static String caseSupportPriority(String id) => '/cases/$id/support-priority';
  static String caseTrend(String id) => '/cases/$id/trend';
  static String caseInterventions(String id) => '/cases/$id/interventions';

  static const String conversations = '/conversations';
  static String conversationMessages(String id) => '/conversations/$id/messages';
  static String conversationById(String id) => '/conversations/$id';

  static const String voiceUpload = '/voice/upload';
  static String voiceTranscribe(String id) => '/voice/$id/transcribe';
  static String voiceAnalysis(String id) => '/voice/$id/analysis';

  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';
  static String alertAcknowledge(String id) => '/alerts/$id/acknowledge';
  static String alertAssign(String id) => '/alerts/$id/assign';

  static String interventionById(String id) => '/interventions/$id';

  static const String dashboardCounsellor = '/dashboard/counsellor';
  static const String dashboardDistrict = '/dashboard/district';
  static const String dashboardState = '/dashboard/state';
}
