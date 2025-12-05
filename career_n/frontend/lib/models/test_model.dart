// MODEL UNTUK MENYIMPAN HASIL TES PSIKOLOGI
class TestResult {
  final int id;
  final int userId;
  final Map<String, double> oceanScores;
  final int aptitudeScore;
  final bool passed;
  final int? recommendedMajorId;
  final int? chosenMajorId;
  final DateTime testDate;

  TestResult({
    required this.id,
    required this.userId,
    required this.oceanScores,
    required this.aptitudeScore,
    required this.passed,
    this.recommendedMajorId,
    this.chosenMajorId,
    required this.testDate,
  });

  // METHOD UNTUK MENGUBAH DATA DARI JSON MENJADI OBJECT TestResult
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      userId: json['user_id'],
      oceanScores: _parseOceanScores(json),
      aptitudeScore: json['aptitude_score'],
      passed: json['passed'] == 1,
      recommendedMajorId: json['recommended_major_id'],
      chosenMajorId: json['chosen_major_id'],
      testDate: DateTime.parse(json['test_date']),
    );
  }

  // METHOD BANTUAN UNTUK MENGOLAH SKOR OCEAN DARI JSON
  static Map<String, double> _parseOceanScores(Map<String, dynamic> json) {
    return {
      'openness': json['ocean_score_openness'].toDouble(),
      'conscientiousness': json['ocean_score_conscientiousness'].toDouble(),
      'extraversion': json['ocean_score_extraversion'].toDouble(),
      'agreeableness': json['ocean_score_agreeableness'].toDouble(),
      'neuroticism': json['ocean_score_neuroticism'].toDouble(),
    };
  }
}

// MODEL UNTUK PERTANYAAN TES KEPRIBADIAN OCEAN
class OceanQuestion {
  final int id;
  final String question;
  final String dimension;

  OceanQuestion({
    required this.id,
    required this.question,
    required this.dimension,
  });
}

// MODEL UNTUK PERTANYAAN TES BAKAT (APTITUDE)
class AptitudeQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  AptitudeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}
