class ApiConstants {
  static const String apiBaseUrl = 'https://mvmwebapp-freph8bvg6euapa3.uaenorth-01.azurewebsites.net';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
}

class ApiErrors {
  // English error messages
  static const String badRequestError = "Bad request";
  static const String noContent = "No data available";
  static const String forbiddenError = "Forbidden";
  static const String unauthorizedError = "Unauthorized";
  static const String notFoundError = "Not found";
  static const String conflictError = "Conflict";
  static const String internalServerError = "Internal server error";
  static const String unknownError = "Unknown error";
  static const String timeoutError = "Connection timeout";
  static const String defaultError = "An error occurred";
  static const String cacheError = "Cache error";
  static const String noInternetError = "No internet connection";
  static const String loadingMessage = "Loading...";
  static const String retryAgainMessage = "Try again";
  static const String ok = "Ok";
} 