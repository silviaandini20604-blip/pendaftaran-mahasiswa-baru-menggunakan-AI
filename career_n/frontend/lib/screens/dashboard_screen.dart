import 'package:flutter/material.dart';
import 'major_selection_screen.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String username = "Pengguna";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final api = Provider.of<ApiService>(context, listen: false);

    // Ambil username setelah login
    setState(() {
      username = api.currentUser?['full_name'] ??
                 api.currentUser?['username'] ??
                 "Pengguna";
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(username: username),
      ResultsTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Buat bottom navigation bar yang keren
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) =>
              setState(() => _currentIndex = index), // Ganti screen ketika tap
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF667EEA),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          items: [
            // Tab Home
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 0
                      ? Color(0xFF667EEA).withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF667EEA).withOpacity(0.1),
                ),
                child: Icon(Icons.home_filled, size: 24),
              ),
              label: 'Home',
            ),

            // BottomNavigationBarItem(
            //   icon: Container(
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       color: _currentIndex == 1
            //           ? Color(0xFF667EEA).withOpacity(0.1)
            //           : Colors.transparent,
            //     ),
            //     child: Icon(Icons.quiz_outlined, size: 24),
            //   ),
            //   activeIcon: Container(
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       color: Color(0xFF667EEA).withOpacity(0.1),
            //     ),
            //     child: Icon(Icons.quiz, size: 24),
            //   ),
            //   label: 'Tes',
            // ),

            // Tab Hasil
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 2
                      ? Color(0xFF667EEA).withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.assignment_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF667EEA).withOpacity(0.1),
                ),
                child: Icon(Icons.assignment, size: 24),
              ),
              label: 'Hasil',
            ),

            // BottomNavigationBarItem(
            //   icon: Container(
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       color: _currentIndex == 3
            //           ? Color(0xFF667EEA).withOpacity(0.1)
            //           : Colors.transparent,
            //     ),
            //     child: Icon(Icons.person_outline, size: 24),
            //   ),
            //   activeIcon: Container(
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       color: Color(0xFF667EEA).withOpacity(0.1),
            //     ),
            //     child: Icon(Icons.person, size: 24),
            //   ),
            //   label: 'Profil',
            // ),
          ],
        ),
      ),
    );
  }
}

// Tab Home - Halaman utama aplikasi
class HomeTab extends StatelessWidget {
  final String username;

  const HomeTab({required this.username});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildHeader(),
            SizedBox(height: 8),
            _buildQuickStartCard(context),
            SizedBox(height: 32),
            _buildStepsSection(),
          ],
        ),
      ),
    );
  }

  // Widget buat header dengan greeting
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work, color: Colors.white, size: 28),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                username,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card besar buat ajak user mulai tes
  Widget _buildQuickStartCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.rocket_launch, size: 36, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Mulai Tes Sekarang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Jangan Lupa Berdoa Sebelum Memulai',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke screen pemilihan jurusan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MajorSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF667EEA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'MULAI TES',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section buat nampilin langkah-langkah tes
  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah Tes:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        _buildStep(
          1,
          'Pilih Jurusan yang Diminati',
          Icons.school,
          'Pilih dari berbagai jurusan yang tersedia',
        ),
        _buildStep(
          2,
          'Tes Kepribadian',
          Icons.psychology,
          '10 pertanyaan untuk memahami kepribadian',
        ),
        _buildStep(
          3,
          'Tes Ujian Masuk',
          Icons.quiz,
          'Uji kemampuan dan potensi akademik',
        ),
      ],
    );
  }

  // Widget buat nampilin setiap langkah tes
  Widget _buildStep(
    int number,
    String title,
    IconData icon,
    String description,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet number dengan gradient
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Color(0xFF667EEA), size: 20),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class TestTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16),
//           Text(
//             'Pilih Jenis Tes',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Pilih tes yang ingin Anda ikuti',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           SizedBox(height: 32),
//           _buildTestCard(
//             'Tes Minat Jurusan',
//             'Pilih jurusan yang sesuai dengan minat dan passion Anda',
//             Icons.school,
//             [Color(0xFF4CAF50), Color(0xFF8BC34A)],
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => MajorSelectionScreen()),
//             ),
//           ),
//           _buildTestCard(
//             'Tes Kepribadian OCEAN',
//             'Temukan kepribadian Anda melalui tes OCEAN yang komprehensif',
//             Icons.psychology,
//             [Color(0xFFFF9800), Color(0xFFFFB74D)],
//             () {
//               // Navigate to OCEAN test
//             },
//           ),
//           _buildTestCard(
//             'Tes Aptitude',
//             'Uji kemampuan dan potensi akademik Anda',
//             Icons.assignment,
//             [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
//             () {
//               // Navigate to aptitude test
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     List<Color> colors,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: colors,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: colors[0].withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(icon, color: Colors.white, size: 30),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           subtitle,
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Tab Hasil - Buat nampilin hasil tes user
class ResultsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder icon karena belum ada hasil
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Belum Ada Hasil Tes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Hasil tes Anda akan muncul di sini setelah\nmenyelesaikan tes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          SizedBox(height: 24),
          // Tombol buat mulai tes dari tab hasil
          Container(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MajorSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mulai Tes Sekarang',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
