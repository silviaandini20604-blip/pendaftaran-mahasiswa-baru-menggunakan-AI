import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic> testResults;
  final dynamic userMajorChoice;

  const ResultsScreen({
    Key? key,
    required this.testResults,
    required this.userMajorChoice,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Load data user yang sedang login
  Future<void> _loadCurrentUser() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  // Simpan hasil tes ke database
  Future<void> _saveTestResult(bool useRecommendedMajor) async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final testData = {
        'user_id': _currentUser!.id,
        'ocean_scores': widget.testResults['ocean_results']['scores'] is Map
            ? widget.testResults['ocean_results']['scores']
            : _convertOceanScores(
                widget.testResults['ocean_results']['scores'],
              ),
        'aptitude_score': widget.testResults['aptitude']['score'],
        'passed': widget.testResults['aptitude']['passed'],
        'recommended_major_id': useRecommendedMajor
            ? widget
                  .testResults['career_recommendation']['recommended_major_id']
            : widget.userMajorChoice.id,
        'chosen_major_id': useRecommendedMajor
            ? widget
                  .testResults['career_recommendation']['recommended_major_id']
            : widget.userMajorChoice.id,
      };

      final response = await apiService.saveTestResult(testData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );

      // Balik ke dashboard setelah save
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving results: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Convert format OCEAN scores kalo perlu
  Map<String, double> _convertOceanScores(dynamic scores) {
    if (scores is List) {
      return {
        'openness': scores[0].toDouble(),
        'conscientiousness': scores[1].toDouble(),
        'extraversion': scores[2].toDouble(),
        'agreeableness': scores[3].toDouble(),
        'neuroticism': scores[4].toDouble(),
      };
    }
    return {
      'openness': 0.0,
      'conscientiousness': 0.0,
      'extraversion': 0.0,
      'agreeableness': 0.0,
      'neuroticism': 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final aptitude = widget.testResults['aptitude'];
    final career = widget.testResults['career_recommendation'];
    final passedAptitude = aptitude['passed'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingScreen()
            : _buildResultsContent(aptitude, career, passedAptitude),
      ),
    );
  }

  // Screen loading ketika lagi save hasil
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Menyimpan hasil...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Konten utama hasil tes
  Widget _buildResultsContent(
    Map<String, dynamic> aptitude,
    Map<String, dynamic> career,
    bool passedAptitude,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          // Header dengan gradient
          _buildHeader(),

          // Isi hasil tes
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Hasil Tes Aptitude
                _buildAptitudeResults(aptitude, passedAptitude),
                SizedBox(height: 20),

                // Hasil Tes OCEAN
                _buildOceanScoreCard(),
                SizedBox(height: 20),

                // Rekomendasi Karir AI
                _buildCareerRecommendation(career),
                SizedBox(height: 20),

                // Pilihan Akhir Jurusan
                _buildFinalDecision(career),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header dengan back button dan celebration
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Back button dan judul
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios_rounded, size: 20),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hasil Tes Akhir',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Celebration icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.emoji_events, color: Colors.white, size: 40),
          ),
          SizedBox(height: 16),

          // Congratulations message
          Text(
            'TES BERHASIL DISELESAIKAN!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Selamat! Anda telah menyelesaikan seluruh rangkaian tes Career_N',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Card hasil tes aptitude
  Widget _buildAptitudeResults(
    Map<String, dynamic> aptitude,
    bool passedAptitude,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.quiz, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Hasil Tes Aptitude',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildResultItem(
              'Nilai Tes',
              '${aptitude['score']}/${aptitude['total_questions']}',
              Icons.score,
            ),
            _buildResultItem(
              'Persentase',
              '${aptitude['percentage'].toStringAsFixed(1)}%',
              Icons.percent,
            ),
            _buildResultItem(
              'Status',
              passedAptitude ? 'LULUS' : 'TIDAK LULUS',
              passedAptitude ? Icons.check_circle : Icons.cancel,
              isStatus: true,
              passed: passedAptitude,
            ),
          ],
        ),
      ),
    );
  }

  // Card hasil tes kepribadian OCEAN
  Widget _buildOceanScoreCard() {
    final oceanScores = widget.testResults['ocean_results']['scores'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.psychology, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Hasil Tes Kepribadian OCEAN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildOceanScoreItem(
              'Keterbukaan',
              oceanScores is Map ? oceanScores['openness'] : oceanScores[0],
            ),
            _buildOceanScoreItem(
              'Keteraturan',
              oceanScores is Map
                  ? oceanScores['conscientiousness']
                  : oceanScores[1],
            ),
            _buildOceanScoreItem(
              'Ekstroversi',
              oceanScores is Map ? oceanScores['extraversion'] : oceanScores[2],
            ),
            _buildOceanScoreItem(
              'Keramahan',
              oceanScores is Map
                  ? oceanScores['agreeableness']
                  : oceanScores[3],
            ),
            _buildOceanScoreItem(
              'Stabilitas Emosi',
              oceanScores is Map ? oceanScores['neuroticism'] : oceanScores[4],
            ),
          ],
        ),
      ),
    );
  }

  // Item individual untuk score OCEAN
  Widget _buildOceanScoreItem(String label, dynamic score) {
    final numericScore = score is double
        ? score
        : double.tryParse(score.toString()) ?? 0.0;
    final percentage = numericScore / 5.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                numericScore.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          // Progress bar untuk score
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (percentage * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getScoreColor(numericScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (percentage * 100).round(),
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card rekomendasi karir dari AI
  Widget _buildCareerRecommendation(Map<String, dynamic> career) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Rekomendasi Karir dari AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    career['recommended_career'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Berdasarkan analisis AI terhadap kepribadian dan kemampuan Anda',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section pilihan akhir jurusan
  Widget _buildFinalDecision(Map<String, dynamic> career) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilihan Akhir Jurusan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Silakan pilih jurusan yang akan Anda ambil:',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 20),

            // Opsi 1: Rekomendasi AI
            _buildMajorChoiceCard(
              career['recommended_career'],
              'Rekomendasi AI',
              Icons.auto_awesome,
              Icons.recommend,
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              true, // useRecommendedMajor = true
            ),

            SizedBox(height: 16),

            // Opsi 2: Pilihan Awal User
            _buildMajorChoiceCard(
              widget.userMajorChoice.name,
              'Pilihan awal Anda',
              Icons.favorite,
              Icons.person,
              Color(0xFF4CAF50),
              Color(0xFF8BC34A),
              false, // useRecommendedMajor = false
            ),
          ],
        ),
      ),
    );
  }

  // Card untuk pilihan jurusan
  Widget _buildMajorChoiceCard(
    String majorName,
    String description,
    IconData icon,
    IconData trailingIcon,
    Color startColor,
    Color endColor,
    bool useRecommendedMajor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _saveTestResult(useRecommendedMajor),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        majorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                Icon(trailingIcon, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper buat item hasil (score, persentase, status)
  Widget _buildResultItem(
    String title,
    String value,
    IconData icon, {
    bool isStatus = false,
    bool? passed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isStatus)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: passed! ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.blue;
    if (score >= 2.0) return Colors.orange;
    return Colors.red;
  }
}
