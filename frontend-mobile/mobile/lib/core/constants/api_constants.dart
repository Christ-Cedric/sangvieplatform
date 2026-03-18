class ApiConstants {
  // Pour appareil réel, utilisez l'adresse IP de votre machine
  static const String baseUrl = "http://192.168.100.179:5000/api";

  // Auth
  static const String login = "$baseUrl/auth/login";
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
  static String userById(String id) => "$baseUrl/users/$id";

  // Hospitals (admin)
  static const String hospitals = "$baseUrl/hospitals";
  static String hospitalById(String id) => "$baseUrl/hospitals/$id";

  // Donations & Donor Actions
  static const String myDonations = "$baseUrl/users/my-donations";
  static String respondToRequest(String requestId) =>
      "$baseUrl/users/respond/$requestId";
  static const String updateDonorStatus = "$baseUrl/users/status";

  // Stats
  static const String adminStats = "$baseUrl/admin/stats";
  static const String hospitalStats = "$baseUrl/hospitals/stats";
}
