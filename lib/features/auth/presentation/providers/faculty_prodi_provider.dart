import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/academic_helper.dart';

class FacultyProdiData {
  final List<dynamic> fakultas;
  final List<dynamic> prodi;

  FacultyProdiData({required this.fakultas, required this.prodi});
}

final facultyProdiProvider = FutureProvider<FacultyProdiData>((ref) async {
  await AcademicHelper.initialize();
  return FacultyProdiData(
    fakultas: AcademicHelper.faculties,
    prodi: AcademicHelper.prodis,
  );
});
