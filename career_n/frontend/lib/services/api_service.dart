import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String baseUrl = 'http://localhost:5000/api';

  Map<String, dynamic>? currentUser;

  // ========================= LOGIN =========================
  Future<dynamic> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    final data = json.decode(response.body);

    // Simpan user ke variabel
    if (data['user'] != null) {
      currentUser = data['user'];
    }

    return data;
  }

  // ========================= MAJORS =========================
  Future<dynamic> getMajors(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/majors?category=$category'),
    );

    return json.decode(response.body);
  }

  // ========================= OCEAN TEST =========================
  Future<dynamic> analyzeOcean(List<int> answers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze-ocean'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'answers': answers}),
    );

    return json.decode(response.body);
  }

  // ========================= APTITUDE =========================
  Future<dynamic> submitAptitude(
    List<String> userAnswers,
    List<String> correctAnswers,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit-aptitude'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'answers': userAnswers,
        'correct_answers': correctAnswers,
      }),
    );

    return json.decode(response.body);
  }

  // ========================= CAREER RECOMMENDER =========================
  Future<dynamic> recommendCareer(
    Map<String, dynamic> oceanScores,
    int aptitudeScore,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recommend-career'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ocean_scores': oceanScores,
        'aptitude_score': aptitudeScore,
      }),
    );

    return json.decode(response.body);
  }

  // ========================= SAVE TEST RESULT =========================
  Future<dynamic> saveTestResult(Map<String, dynamic> testData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save-test-result'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(testData),
    );

    return json.decode(response.body);
  }
}
