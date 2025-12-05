import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/major_model.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class AptitudeTestScreen extends StatefulWidget {
  final Major selectedMajor;
  final dynamic oceanResults;

  const AptitudeTestScreen({
    Key? key,
    required this.selectedMajor,
    required this.oceanResults,
  }) : super(key: key);

  @override
  _AptitudeTestScreenState createState() => _AptitudeTestScreenState();
}

class _AptitudeTestScreenState extends State<AptitudeTestScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<String?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _testCompleted = false;
  Map<String, dynamic>? _testResults;

  @override
  void initState() {
    super.initState();
    _loadAptitudeQuestions();
  }

  // MEMUAT SOAL TES BAKAT (CONTOH)
  void _loadAptitudeQuestions() {
    setState(() {
      _questions = [
        {
          'id': 1,
          'question': 'Jika 2x + 5 = 15, berapa nilai x?',
          'options': ['5', '10', '7.5', '20'],
          'correct_answer': '5',
        },
        {
          'id': 2,
          'question': 'Sinonim dari "Cerdas" adalah?',
          'options': ['Bodoh', 'Pintar', 'Malas', 'Rajin'],
          'correct_answer': 'Pintar',
        },
        {
          'id': 3,
          'question': 'Benda berikut yang bukan termasuk kubus adalah?',
          'options': ['Dadu', 'Rubik', 'Kardus', 'Bola'],
          'correct_answer': 'Bola',
        },
        {
          'id': 4,
          'question': 'Ibukota Indonesia adalah?',
          'options': ['Jakarta', 'Surabaya', 'Bandung', 'Medan'],
          'correct_answer': 'Jakarta',
        },
        {
          'id': 5,
          'question': '5 + 3 × 2 = ?',
          'options': ['16', '11', '10', '13'],
          'correct_answer': '11',
        },
      ];
      _userAnswers = List.generate(_questions.length, (index) => null);
      _isLoading = false;
    });
  }

  // MENANGANI JAWABAN PERTANYAAN
  void _answerQuestion(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });

    if (_currentQuestionIndex < _questions.length - 1) {
      _goToNextQuestion();
    } else {
      _submitAptitudeTest();
    }
  }

  // PINDAH KE PERTANYAAN BERIKUTNYA
  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });
  }

  // MENGIRIM HASIL TES KE SERVER
  Future<void> _submitAptitudeTest() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final correctAnswers = _questions
          .map((q) => q['correct_answer'] as String)
          .toList();

      final aptitudeResponse = await apiService.submitAptitude(
        _userAnswers.map((answer) => answer ?? 'null').toList(),
        correctAnswers,
      );

      final oceanScores = widget.oceanResults['scores'] is Map
          ? Map<String, double>.from(widget.oceanResults['scores'])
          : _convertOceanScores(widget.oceanResults['scores']);

      final careerResponse = await apiService.recommendCareer(
        oceanScores,
        aptitudeResponse['score'],
      );

      _handleTestCompletion(aptitudeResponse, careerResponse);
    } catch (e) {
      _showErrorSnackBar('Error submitting test: $e');
    }
  }

  // MENANGANI SETELAH TES SELESAI
  void _handleTestCompletion(dynamic aptitudeResponse, dynamic careerResponse) {
    setState(() {
      _testResults = {
        'aptitude': aptitudeResponse,
        'career_recommendation': careerResponse,
        'selected_major': widget.selectedMajor,
        'ocean_results': widget.oceanResults,
      };
      _testCompleted = true;
    });
  }

  // MENGUBAH FORMAT SKOR OCEAN
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

  // MENAMPILKAN PESAN ERROR
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // KEMBALI KE PERTANYAAN SEBELUMNYA
  void _navigateToPrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // MEMBANGUI HEADER DENGAN PROGRESS BAR
  Widget _buildHeader() {
    final progressValue = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
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
          _buildAppBar(),
          SizedBox(height: 16),
          _buildProgressInfo(progressValue),
        ],
      ),
    );
  }

  // MEMBANGUN APPBAR DENGAN TOMBOL BACK
  Widget _buildAppBar() {
    return Row(
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
            'Tes Ujian Masuk',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // MEMBANGUN INFO PROGRESS DAN PROGRESS BAR
  Widget _buildProgressInfo(double progressValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
        ),
        SizedBox(height: 8),
        _buildProgressBar(progressValue),
      ],
    );
  }

  // MEMBANGUN PROGRESS BAR
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

  // MEMBANGUN KARTU PERTANYAAN
  Widget _buildQuestionCard() {
    final currentQuestion = _questions[_currentQuestionIndex];

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
          _buildQuestionHeader(),
          SizedBox(height: 20),
          _buildQuestionText(currentQuestion['question']),
        ],
      ),
    );
  }

  // MEMBANGUN HEADER PERTANYAAN
  Widget _buildQuestionHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // MEMBANGUN TEKS PERTANYAAN
  Widget _buildQuestionText(String question) {
    return Text(
      question,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  // MEMBANGUN PILIHAN JAWABAN
  Widget _buildAnswerOptions() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildAnswerOption(options[index], index);
      },
    );
  }

  // MEMBANGUN SATU PILIHAN JAWABAN
  Widget _buildAnswerOption(String option, int index) {
    final isSelected = _userAnswers[_currentQuestionIndex] == option;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _answerQuestion(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFF9C27B0).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Color(0xFF9C27B0) : Colors.grey[200]!,
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
                _buildOptionIndicator(index, isSelected),
                SizedBox(width: 16),
                _buildOptionText(option),
                if (isSelected) _buildSelectedIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MEMBANGUN INDIKATOR PILIHAN (A, B, C, D)
  Widget _buildOptionIndicator(int index, bool isSelected) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF9C27B0) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          String.fromCharCode(65 + index),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // MEMBANGUN TEKS PILIHAN JAWABAN
  Widget _buildOptionText(String option) {
    return Expanded(
      child: Text(
        option,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  // MEMBANGUN ICON TANDA TERPILIH
  Widget _buildSelectedIcon() {
    return Icon(Icons.check_circle, color: Colors.green, size: 24);
  }

  // MEMBANGUN TOMBOL NAVIGASI
  Widget _buildNavigationButtons() {
    return Column(
      children: [
        if (_currentQuestionIndex > 0) _buildBackButton(),
        SizedBox(height: 20),
      ],
    );
  }

  // MEMBANGUN TOMBOL KEMBALI
  Widget _buildBackButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _navigateToPrevious,
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF9C27B0),
          side: BorderSide(color: Color(0xFF9C27B0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Kembali ke Pertanyaan Sebelumnya',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // MEMBANGUN LAYAR TES
  Widget _buildTestScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeader(), SizedBox(height: 24), _buildTestContent()],
    );
  }

  // MEMBANGUN KONTEN TES (SCROLLABLE)
  Widget _buildTestContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildQuestionCard(),
            SizedBox(height: 24),
            _buildAnswerOptions(),
            SizedBox(height: 20),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // MEMBANGUN LAYAR HASIL TES
  Widget _buildResultsScreen() {
    final aptitude = _testResults!['aptitude'];
    final passed = aptitude['passed'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          _buildResultsHeader(passed, aptitude),
          _buildResultsContent(passed),
        ],
      ),
    );
  }

  // MEMBANGUN HEADER HASIL TES
  Widget _buildResultsHeader(bool passed, dynamic aptitude) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [Color(0xFF4CAF50), Color(0xFF8BC34A)]
              : [Color(0xFFF44336), Color(0xFFEF9A9A)],
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
          _buildResultsIcon(passed),
          SizedBox(height: 16),
          _buildResultsTitle(passed),
          SizedBox(height: 8),
          _buildScoreInfo(aptitude),
        ],
      ),
    );
  }

  // MEMBANGUN ICON HASIL TES
  Widget _buildResultsIcon(bool passed) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        passed ? Icons.celebration : Icons.sentiment_dissatisfied,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  // MEMBANGUN JUDUL HASIL TES
  Widget _buildResultsTitle(bool passed) {
    return Text(
      passed ? 'SELAMAT! ANDA LULUS' : 'ANDA BELUM LULUS',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  // MEMBANGUN INFO NILAI
  Widget _buildScoreInfo(dynamic aptitude) {
    return Column(
      children: [
        Text(
          'Nilai Ujian : ${aptitude['score']}/${aptitude['total_questions']} (${aptitude['percentage'].toStringAsFixed(1)}%)',
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
        ),
        SizedBox(height: 4),
        Text(
          'Nilai Minimal : ${aptitude['passing_score']}%',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  // MEMBANGUN KONTEN HASIL TES
  Widget _buildResultsContent(bool passed) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: passed ? _buildPassedContent() : _buildFailedContent(),
    );
  }

  // MEMBANGUN KONTEN JIKA LULUS
  Widget _buildPassedContent() {
    final career = _testResults!['career_recommendation'];
    final selectedMajor = _testResults!['selected_major'];

    return Column(
      children: [
        _buildAIRecommendationCard(career),
        SizedBox(height: 20),
        _buildMajorSelectionCard(selectedMajor),
        SizedBox(height: 20),
        _buildContinueButton(),
      ],
    );
  }

  // MEMBANGUN KARTU REKOMENDASI AI
  Widget _buildAIRecommendationCard(dynamic career) {
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
            _buildCardHeader(Icons.auto_awesome, 'Rekomendasi AI untuk Anda :'),
            SizedBox(height: 16),
            _buildRecommendationContent(career),
          ],
        ),
      ),
    );
  }

  // MEMBANGUN KARTU PILIHAN JURUSAN
  Widget _buildMajorSelectionCard(Major selectedMajor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
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
            _buildCardHeader(Icons.school, 'Pilihan Jurusan Anda:'),
            SizedBox(height: 16),
            _buildMajorContent(selectedMajor),
          ],
        ),
      ),
    );
  }

  // MEMBANGUN HEADER KARTU
  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // MEMBANGUN KONTEN REKOMENDASI
  Widget _buildRecommendationContent(dynamic career) {
    return Container(
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
            'Berdasarkan analisis kepribadian dan kemampuan Anda',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // MEMBANGUN KONTEN JURUSAN
  Widget _buildMajorContent(Major selectedMajor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedMajor.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            selectedMajor.description,
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // MEMBANGUN TOMBOL LANJUTKAN
  Widget _buildContinueButton() {
    final selectedMajor = _testResults!['selected_major'];

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                testResults: _testResults!,
                userMajorChoice: selectedMajor,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667EEA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Color(0xFF667EEA).withOpacity(0.3),
        ),
        child: Text(
          'Simpan Hasil dan Lanjutkan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // MEMBANGUN KONTEN JIKA TIDAK LULUS
  Widget _buildFailedContent() {
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
          children: [
            _buildMotivationIcon(),
            SizedBox(height: 16),
            _buildMotivationTitle(),
            SizedBox(height: 16),
            _buildMotivationMessage(),
            SizedBox(height: 20),
            _buildDashboardButton(),
          ],
        ),
      ),
    );
  }

  // MEMBANGUN ICON MOTIVASI
  Widget _buildMotivationIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: 30),
    );
  }

  // MEMBANGUN JUDUL MOTIVASI
  Widget _buildMotivationTitle() {
    return Text(
      'Jangan Menyerah! 💪',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // MEMBANGUN PESAN MOTIVASI
  Widget _buildMotivationMessage() {
    return Text(
      'Setiap kegagalan adalah batu loncatan menuju kesuksesan. '
      'Teruslah berusaha dan belajar, waktumu akan datang dengan lebih baik! 🚀',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
    );
  }

  // MEMBANGUN TOMBOL KEMBALI KE DASHBOARD
  Widget _buildDashboardButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFFF9800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Kembali ke Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // MEMBANGUN LOADING INDICATOR
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat soal...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? _buildLoadingIndicator()
          : _testCompleted
          ? _buildResultsScreen()
          : _buildTestScreen(),
    );
  }
}
