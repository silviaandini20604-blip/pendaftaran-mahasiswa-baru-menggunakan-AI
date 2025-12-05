import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/major_model.dart';
import '../services/api_service.dart';
import 'ocean_test_screen.dart';

class MajorSelectionScreen extends StatefulWidget {
  @override
  _MajorSelectionScreenState createState() => _MajorSelectionScreenState();
}

class _MajorSelectionScreenState extends State<MajorSelectionScreen> {
  List<Major> _majors = [];
  List<Major> _filteredMajors = [];
  String _selectedCategory = 'UNIVERSITY';
  Major? _selectedMajor;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMajors();
  }

  // Load data jurusan dari API
  Future<void> _loadMajors() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMajors(_selectedCategory);

      setState(() {
        _majors = (response as List)
            .map((item) => Major.fromJson(item))
            .toList();
        _filteredMajors = _majors;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading majors: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // Filter jurusan berdasarkan search query
  void _filterMajors(String query) {
    setState(() {
      _filteredMajors = _majors
          .where(
            (major) =>
                major.name.toLowerCase().contains(query.toLowerCase()) ||
                major.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  // Navigasi ke screen tes kepribadian
  void _proceedToOceanTest() {
    if (_selectedMajor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a major first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OceanTestScreen(selectedMajor: _selectedMajor!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            _buildHeader(),

            // Filter kategori (UNIVERSITY vs SMK)
            _buildCategoryFilter(),

            // Search bar
            _buildSearchBar(),
            SizedBox(height: 16),

            // Count hasil pencarian
            _buildResultsCount(),
            SizedBox(height: 8),

            // List jurusan
            _buildMajorsList(),

            // Tombol lanjut
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  // Header dengan back button dan judul
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  'Silahkan Pilih Jurusan Yang Anda Minati!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Filter kategori UNIVERSITY vs SMK
  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildCategoryButton('UNIVERSITY', 'UNIVERSITAS', Icons.school),
          SizedBox(width: 12),
          _buildCategoryButton('SMK', 'SMK', Icons.engineering),
        ],
      ),
    );
  }

  // Widget individual buat tombol kategori
  Widget _buildCategoryButton(String category, String label, IconData icon) {
    bool isSelected = _selectedCategory == category;

    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF667EEA) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _loadMajors();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Search bar buat cari jurusan
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterMajors,
          decoration: InputDecoration(
            hintText: 'Cari jurusan...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  // Count berapa banyak jurusan yang ketemu
  Widget _buildResultsCount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${_filteredMajors.length} jurusan ditemukan',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // List jurusan dengan berbagai state (loading, empty, data)
  Widget _buildMajorsList() {
    return Expanded(
      child: _isLoading
          ? _buildLoadingState()
          : _filteredMajors.isEmpty
          ? _buildEmptyState()
          : _buildMajorsListView(),
    );
  }

  // Loading state ketika data lagi dimuat
  Widget _buildLoadingState() {
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
          Text('Memuat jurusan...', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Empty state ketika ga ada jurusan yang ketemu
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'Jurusan tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coba kata kunci lain atau kategori berbeda',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // List view buat nampilin jurusan-jurusan
  Widget _buildMajorsListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMajors.length,
      itemBuilder: (context, index) {
        final major = _filteredMajors[index];
        return _buildMajorItem(major);
      },
    );
  }

  // Widget individual buat setiap item jurusan
  Widget _buildMajorItem(Major major) {
    bool isSelected = _selectedMajor?.id == major.id;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedMajor = major;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFF667EEA).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Color(0xFF667EEA) : Colors.transparent,
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon jurusan
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF667EEA) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _selectedCategory == 'UNIVERSITY'
                          ? Icons.school
                          : Icons.engineering,
                      color: isSelected ? Colors.white : Color(0xFF667EEA),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),

                  // Info jurusan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          major.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Color(0xFF667EEA)
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          major.description,
                          style: TextStyle(
                            color: isSelected
                                ? Color(0xFF667EEA).withOpacity(0.8)
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Checkmark kalo selected
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tombol continue buat lanjut ke tes berikutnya
  Widget _buildContinueButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _proceedToOceanTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Color(0xFF667EEA).withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lanjut ke Tes Kepribadian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
