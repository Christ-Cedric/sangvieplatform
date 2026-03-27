class ApiConstants {
  // Pour appareil réel, utilisez l'adresse IP de votre machine
  static const String baseUrl = "https://sangvieplatform.onrender.com/api";

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String registerUser = "$baseUrl/auth/register-user";
  static const String registerHospital = "$baseUrl/auth/register-hospital";
  static const String me = "$baseUrl/auth/me";

  // Blood Requests
  static const String requests = "$baseUrl/requests";
  static const String createHospitalRequest = "$baseUrl/hospitals/request";
  static const String myRequests = "$baseUrl/hospitals/my-requests";
  static String requestById(String id) => "$baseUrl/requests/$id";
  static String hospitalRequests(String hospitalId) =>
      "$baseUrl/requests/hospital/$hospitalId";

  // Users (admin)
  static const String users = "$baseUrl/users";
  static const String adminUsers = "$baseUrl/admin/users";
  static String userById(String id) => "$baseUrl/users/$id";

  // Hospitals (admin)
  static const String hospitals = "$baseUrl/hospitals";
  static const String adminHospitals = "$baseUrl/admin/hospitals";
  static const String pendingHospitals = "$baseUrl/admin/pending-hospitals";
  static String hospitalById(String id) => "$baseUrl/hospitals/$id";
  static String verifyHospital(String id) =>
      "$baseUrl/admin/verify-hospital/$id";
  static String suspendAccount(String id, String type) =>
      "$baseUrl/admin/suspend/$id?type=$type";
  static String deleteAccount(String id, String type) =>
      "$baseUrl/admin/account/$id?type=$type";

  // Donations & Donor Actions
  static const String myDonations = "$baseUrl/users/my-donations";
  static String respondToRequest(String requestId) =>
      "$baseUrl/users/respond/$requestId";
  static const String updateDonorStatus = "$baseUrl/users/status";

  // Stats
  static const String adminStats = "$baseUrl/admin/stats";
  static const String adminReports = "$baseUrl/admin/reports";
  static const String hospitalStats = "$baseUrl/hospitals/stats";

  // Notifications
  static const String notifications = "$baseUrl/notifications";
  static String markNotificationRead(String id) =>
      "$baseUrl/notifications/$id/read";
}
