class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/auth/profile';

  static const String workouts = '$baseUrl/workouts';
  static String workoutById(String id) => '$baseUrl/workouts/$id';
  static String completeWorkout(String id) => '$baseUrl/workouts/$id/complete';

  static const String waterToday = '$baseUrl/water/today';
  static const String water = '$baseUrl/water';
  static String waterEntry(String id) => '$baseUrl/water/$id';
  static const String waterHistory = '$baseUrl/water/history';

  static const String challengeActive = '$baseUrl/challenges/active';
  static const String challenges = '$baseUrl/challenges';
  static String finishChallenge(String id) => '$baseUrl/challenges/$id/finish';

  static const String weight = '$baseUrl/weight';
  static const String weightHistory = '$baseUrl/weight/history';

  static const String calendar = '$baseUrl/calendar';
}
