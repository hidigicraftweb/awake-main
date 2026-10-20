import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - changes based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android emulator
    } else {
      return 'http://localhost:8000/api'; // iOS simulator
    }
  }

  // Storage base URL (for images, files, etc.)
  static String get storageBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    } else {
      return 'http://localhost:8000'; // iOS simulator
    }
  }

  /// Constructs full URL for storage paths (e.g., profile photos)
  static String? getFullStorageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    // If already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Ensure path starts with /
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$storageBaseUrl$normalizedPath';
  }

  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String loginVerifyOtp = '/login/verify-otp';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String userStats = '/user/stats';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';

  // OTP endpoints
  static const String otpSend = '/otp/send';
  static const String otpVerify = '/otp/verify';
  static const String otpResend = '/otp/resend';

  // Password reset endpoints
  static const String forgotPassword = '/password/forgot';
  static const String resetPassword = '/password/reset';

  // Categories
  static const String categories = '/categories';

  // Cities
  static const String cities = '/cities';

  // Cafes
  static const String cafes = '/cafes';
  static const String cafesPopular = '/cafes/popular';
  static const String cafesNewest = '/cafes/newest';

  // Products
  static const String products = '/products';
  static const String productsPopular = '/products/popular';
  static const String productsTopRated = '/products/top-rated';
  static const String productsFeatured = '/products/featured';
  static String productsByCategorySlug(String slug) => '/products/category/$slug';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionsActive = '/transactions/active';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopup = '/wallet/topup';
  static const String walletTopupInfo = '/wallet/topup-info';

  // Helper methods
  static String cafeById(int id) => '/cafes/$id';
  static String cafesByCity(int cityId) => '/cities/$cityId/cafes';
  static String productById(dynamic id) => '/products/$id';
  static String productsByCategory(int categoryId) =>
      '/categories/$categoryId/products';
  static String transactionById(int id) => '/transactions/$id';
  static String transactionReorder(int id) => '/transactions/$id/reorder';
  static String transactionCancel(int id) => '/transactions/$id/cancel';
  static String walletTransactionById(int id) => '/wallet/transactions/$id';
  static String walletTopupUploadProof(int id) =>
      '/wallet/topup/$id/upload-proof';
  static String walletTopupCancel(int id) => '/wallet/topup/$id/cancel';
}
