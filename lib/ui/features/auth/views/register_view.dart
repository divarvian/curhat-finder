import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterView extends ConsumerStatefulWidget {
  final bool isKonselor;
  const RegisterView({super.key, this.isKonselor = false});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Form State
  String _fullName = '';
  String _nickname = '';
  String _gender = '';
  String _batch = '';
  String _facultyId = '';
  String _prodiId = '';
  String _hobby = '';
  Set<String> _topics = {};

  // Data
  List<dynamic> _fakultasList = [];
  List<dynamic> _prodiList = [];
  List<dynamic> _filteredProdiList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fakultasStr = await rootBundle.loadString('assets/data/fakultas.json');
      final prodiStr = await rootBundle.loadString('assets/data/prodi.json');
      
      setState(() {
        _fakultasList = json.decode(fakultasStr);
        _prodiList = json.decode(prodiStr);
      });
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Final submit
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  void _submitForm() {
    // TODO: Call API or Provider to save the profile data
    debugPrint("Full Name: $_fullName");
    debugPrint("Nickname: $_nickname");
    debugPrint("Gender: $_gender");
    debugPrint("Batch: $_batch");
    debugPrint("Faculty ID: $_facultyId");
    debugPrint("Prodi ID: $_prodiId");
    debugPrint("Hobby: $_hobby");
    debugPrint("Topics: $_topics");
    
    // Redirect to main
    context.go('/main');
  }

  void _onFacultySelected(String facultyId) {
    setState(() {
      _facultyId = facultyId;
      _prodiId = ''; // Reset prodi if faculty changes
      _filteredProdiList = _prodiList.where((p) => p['fakultas_id'] == facultyId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5), // Light pinkish top
              Color(0xFFE6F0FA), // Light blue middle
              Color(0xFF4A6B9C), // Dark blue bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1FullName(),
                    _buildStep2Nickname(),
                    _buildStep3Gender(),
                    _buildStep4Batch(),
                    _buildStep5Faculty(),
                    _buildStep6Prodi(),
                    _buildStep7Hobby(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B264F)),
              onPressed: _prevStep,
            ),
          ),
          const Text(
            'Register',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B264F),
              fontFamily: 'Gilroy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8.0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep ? const Color(0xFF4A6B9C) : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Langkah - ${_currentStep + 1}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4A6B9C),
              fontFamily: 'Gilroy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTemplate({
    required String title,
    required Widget content,
    required bool isNextEnabled,
    String buttonText = "Lanjut",
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B264F),
              fontFamily: 'Gilroy',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: content,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isNextEnabled ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7D1D1), // Light pink button
                foregroundColor: const Color(0xFF1B264F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: const Color(0xFFF7D1D1).withOpacity(0.5),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // Bottom safe space
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String value,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFF1B264F),
          fontFamily: 'Gilroy',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF1B264F).withOpacity(0.5),
            fontFamily: 'Gilroy',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildPillOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7D1D1) : const Color(0xFFFDF7F7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFF7D1D1) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1B264F),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
    );
  }

  // --- Steps ---

  Widget _buildStep1FullName() {
    return _buildStepTemplate(
      title: 'Yuk Kenalan!\nSiapa nama lengkapmu?',
      isNextEnabled: _fullName.trim().isNotEmpty,
      content: _buildTextField(
        hint: 'Nama Lengkap',
        value: _fullName,
        onChanged: (val) => setState(() => _fullName = val),
      ),
    );
  }

  Widget _buildStep2Nickname() {
    return _buildStepTemplate(
      title: 'Kamu mau di panggil siapa?',
      isNextEnabled: _nickname.trim().isNotEmpty,
      content: _buildTextField(
        hint: 'Nama Panggilanmu',
        value: _nickname,
        onChanged: (val) => setState(() => _nickname = val),
      ),
    );
  }

  Widget _buildStep3Gender() {
    final options = ['Laki - Laki', 'Perempuan', 'Nonbiner', 'Lainnya'];
    return _buildStepTemplate(
      title: 'Kamu diidentifikasi sebagai...',
      isNextEnabled: _gender.isNotEmpty,
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: options.map((opt) {
          return _buildPillOption(
            label: opt,
            isSelected: _gender == opt,
            onTap: () => setState(() => _gender = opt),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep4Batch() {
    final options = ['2026', '2025', '2024', '2023', '2022'];
    return _buildStepTemplate(
      title: 'Angkatan berapa?',
      isNextEnabled: _batch.isNotEmpty,
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: options.map((opt) {
          return _buildPillOption(
            label: opt,
            isSelected: _batch == opt,
            onTap: () => setState(() => _batch = opt),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep5Faculty() {
    return _buildStepTemplate(
      title: 'Fakultas mana?',
      isNextEnabled: _facultyId.isNotEmpty,
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _fakultasList.map((f) {
          final id = f['id'] as String;
          final singkatan = f['singkatan'] as String;
          return _buildPillOption(
            label: singkatan,
            isSelected: _facultyId == id,
            onTap: () => _onFacultySelected(id),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep6Prodi() {
    // Kelompokkan prodi berdasarkan jenjang
    final Map<String, List<dynamic>> grouped = {};
    for (var p in _filteredProdiList) {
      final nama = p['nama'] as String;
      String prefix = '';
      String display = nama;

      if (nama.startsWith('S1 ') || nama.startsWith('S2 ') || nama.startsWith('S3 ')) {
        prefix = nama.substring(0, 2);
        display = nama.substring(3);
      } else if (nama.startsWith('D3 ') || nama.startsWith('D4 ')) {
        prefix = nama.substring(0, 2);
        display = nama.substring(3);
      } else if (nama.startsWith('Profesi ')) {
        prefix = 'Profesi';
        display = nama.substring(8);
      } else {
        prefix = 'Lainnya';
      }

      if (!grouped.containsKey(prefix)) grouped[prefix] = [];
      grouped[prefix]!.add({'id': p['id'], 'display': display});
    }

    // Urutkan key jenjang (D3, D4, S1, S2, S3, Profesi)
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      // Prioritaskan S dan D
      final order = {'D3': 1, 'D4': 2, 'S1': 3, 'S2': 4, 'S3': 5, 'Profesi': 6, 'Lainnya': 7};
      int wA = order[a] ?? 99;
      int wB = order[b] ?? 99;
      return wA.compareTo(wB);
    });

    return _buildStepTemplate(
      title: 'Prodi apa?',
      isNextEnabled: _prodiId.isNotEmpty,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedKeys.map((key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Program $key',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B264F),
                    fontFamily: 'Gilroy',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: grouped[key]!.map((item) {
                    return _buildPillOption(
                      label: item['display'],
                      isSelected: _prodiId == item['id'],
                      onTap: () => setState(() => _prodiId = item['id']),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep7Hobby() {
    if (widget.isKonselor) {
      final options = ['Overhelmed', 'Hilang arah', 'Keuangan', 'Burnout', 'Hubungan', 'Keluarga', 'Anxiety'];
      return _buildStepTemplate(
        title: 'Topik yang kamu kuasai',
        isNextEnabled: _topics.isNotEmpty,
        buttonText: 'Masuk',
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((opt) {
            final isSelected = _topics.contains(opt);
            return _buildPillOption(
              label: opt,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _topics.remove(opt);
                  } else {
                    _topics.add(opt);
                  }
                });
              },
            );
          }).toList(),
        ),
      );
    } else {
      return _buildStepTemplate(
        title: 'Apa hal yang bisa bikin kamu happy?',
        isNextEnabled: _hobby.trim().isNotEmpty,
        buttonText: 'Masuk',
        content: _buildTextField(
          hint: 'Ex. Main padel',
          value: _hobby,
          onChanged: (val) => setState(() => _hobby = val),
        ),
      );
    }
  }
}
