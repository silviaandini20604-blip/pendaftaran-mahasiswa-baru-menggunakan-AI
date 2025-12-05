import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/major_model.dart';
import '../services/api_service.dart';
import 'aptitude_test_screen.dart';

class OceanTestScreen extends StatefulWidget {
  final Major selectedMajor;

  const OceanTestScreen({Key? key, required this.selectedMajor})
    : super(key: key);

  @override
  _OceanTestScreenState createState() => _OceanTestScreenState();
}

class _OceanTestScreenState extends State<OceanTestScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<int> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOceanQuestions();
  }

  // Load soal tes OCEAN (buat sementara pake sample data)
  void _loadOceanQuestions() {
    // TODO: nanti ganti dengan data dari API
    setState(() {
      _questions = [
        {
          'id': 1,
          'question': 'Saya adalah orang yang penuh imajinasi dan kreatif',
          'dimension': 'openness',
        },
        {
          'id': 2,
          'question': 'Saya selalu menyelesaikan tugas tepat waktu',
          'dimension': 'conscientiousness',
        },
        {
          'id': 3,
          'question': 'Saya merasa nyaman berada di sekitar banyak orang',
          'dimension': 'extraversion',
        },
        {
          'id': 4,
          'question': 'Saya mudah mempercayai orang lain',
          'dimension': 'agreeableness',
        },
        {
          'id': 5,
          'question': 'Saya sering merasa cemas atau khawatir',
          'dimension': 'neuroticism',
        },
        {
          'id': 6,
          'question': 'Saya tertarik dengan seni dan keindahan',
          'dimension': 'openness',
        },
        {
          'id': 7,
          'question': 'Saya membuat perencanaan sebelum melakukan sesuatu',
          'dimension': 'conscientiousness',
        },
        {
          'id': 8,
          'question': 'Saya menjadi pusat perhatian dalam kelompok',
          'dimension': 'extraversion',
        },
        {
          'id': 9,
          'question': 'Saya peduli dengan perasaan orang lain',
          'dimension': 'agreeableness',
        },
        {
          'id': 10,
          'question': 'Saya mudah merasa sedih atau tertekan',
          'dimension': 'neuroticism',
        },
      ];
      _answers = List.generate(
        _questions.length,
        (index) => 0,
      ); // 0 = belum dijawab
      _isLoading = false;
    });
  }

  // Handle ketika user jawab pertanyaan
  void _answerQuestion(int score) {
    setState(() {
      _answers[_currentQuestionIndex] = score;
    });

    // Cek apakah ini pertanyaan terakhir atau belum
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++; // Lanjut ke pertanyaan berikutnya
      });
    } else {
      _submitOceanTest(); // Kalo udah selesai, submit hasilnya
    }
  }

  // Submit hasil tes ke API
  Future<void> _submitOceanTest() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.analyzeOcean(_answers);

      // Lanjut ke tes aptitude
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AptitudeTestScreen(
            selectedMajor: widget.selectedMajor,
            oceanResults: response,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Convert dimension name ke Bahasa Indonesia
  String _getDimensionName(String dimension) {
    switch (dimension) {
      case 'openness':
        return 'Keterbukaan';
      case 'conscientiousness':
        return 'Keteraturan';
      case 'extraversion':
        return 'Ekstroversi';
      case 'agreeableness':
        return 'Keramahan';
      case 'neuroticism':
        return 'Stabilitas Emosi';
      default:
        return dimension;
    }
  }

  // Dapetin warna yang sesuai untuk setiap dimensi
  Color _getDimensionColor(String dimension) {
    switch (dimension) {
      case 'openness':
        return Color(0xFF2196F3); // Biru
      case 'conscientiousness':
        return Color(0xFF4CAF50); // Hijau
      case 'extraversion':
        return Color(0xFFFF9800); // Orange
      case 'agreeableness':
        return Color(0xFF9C27B0); // Ungu
      case 'neuroticism':
        return Color(0xFFF44336); // Merah
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progressValue = (_currentQuestionIndex + 1) / _questions.length;
    final dimensionColor = _getDimensionColor(currentQuestion['dimension']);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan progress bar
            _buildHeader(progressValue, dimensionColor),

            SizedBox(height: 24),

            // Konten utama (pertanyaan + pilihan jawaban)
            _buildQuestionContent(currentQuestion, dimensionColor),
          ],
        ),
      ),
    );
  }

  // Screen loading ketika soal lagi dimuat
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat soal...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Header dengan back button, progress bar, dan judul
  Widget _buildHeader(double progressValue, Color dimensionColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)], // Gradient orange
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Tes Kepribadian',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Progress indicator
          Text(
            'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          _buildProgressBar(progressValue),
        ],
      ),
    );
  }

  // Progress bar buat nunjukin progress pengerjaan tes
  Widget _buildProgressBar(double progressValue) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: (progressValue * 100).round(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            flex: 100 - (progressValue * 100).round(),
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  // Konten utama yang isinya pertanyaan dan pilihan jawaban
  Widget _buildQuestionContent(
    Map<String, dynamic> currentQuestion,
    Color dimensionColor,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Card pertanyaan
            _buildQuestionCard(currentQuestion, dimensionColor),
            SizedBox(height: 24),

            // Pilihan jawaban
            _buildAnswerOptions(dimensionColor),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Card buat nampilin pertanyaan
  Widget _buildQuestionCard(
    Map<String, dynamic> currentQuestion,
    Color dimensionColor,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Badge dimensi kepribadian
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: dimensionColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getDimensionName(currentQuestion['dimension']),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Teks pertanyaan
          Text(
            currentQuestion['question'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // List pilihan jawaban (1-5)
  Widget _buildAnswerOptions(Color dimensionColor) {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Biar scrollable di dalam ScrollView
      itemCount: 5,
      itemBuilder: (context, index) {
        final score = index + 1;
        final isSelected = _answers[_currentQuestionIndex] == score;

        return _buildAnswerOption(
          score,
          _getAnswerText(score),
          _getAnswerIcon(score),
          isSelected,
          dimensionColor,
        );
      },
    );
  }

  // Widget individual buat setiap pilihan jawaban
  Widget _buildAnswerOption(
    int score,
    String text,
    IconData icon,
    bool isSelected,
    Color dimensionColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _answerQuestion(score),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? dimensionColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? dimensionColor : Colors.grey[200]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon jawaban
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? dimensionColor
                        : _getAnswerColor(score).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : _getAnswerColor(score),
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Teks jawaban
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getAnswerDescription(score),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Checkmark kalo dipilih
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: dimensionColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper functions buat teks jawaban
  String _getAnswerText(int score) {
    switch (score) {
      case 1:
        return 'Sangat Tidak Setuju';
      case 2:
        return 'Tidak Setuju';
      case 3:
        return 'Netral';
      case 4:
        return 'Setuju';
      case 5:
        return 'Sangat Setuju';
      default:
        return '';
    }
  }

  String _getAnswerDescription(int score) {
    switch (score) {
      case 1:
        return 'Sama sekali tidak sesuai dengan saya';
      case 2:
        return 'Tidak sesuai dengan saya';
      case 3:
        return 'Kadang-kadang sesuai';
      case 4:
        return 'Sesuai dengan saya';
      case 5:
        return 'Sangat sesuai dengan saya';
      default:
        return '';
    }
  }

  IconData _getAnswerIcon(int score) {
    switch (score) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.help;
    }
  }

  Color _getAnswerColor(int score) {
    switch (score) {
      case 1:
        return Color(0xFFF44336);
      case 2:
        return Color(0xFFFF9800);
      case 3:
        return Color(0xFFFFC107);
      case 4:
        return Color(0xFF8BC34A);
      case 5:
        return Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }
}
