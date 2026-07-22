import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';

class FacultyProdiData {
  final List<dynamic> fakultas;
  final List<dynamic> prodi;

  FacultyProdiData({required this.fakultas, required this.prodi});
}

final facultyProdiProvider = FutureProvider<FacultyProdiData>((ref) async {
  final fakultasStr = await rootBundle.loadString(AppAssets.fakultasJson);
  final prodiStr = await rootBundle.loadString(AppAssets.prodiJson);

  
  return FacultyProdiData(
    fakultas: json.decode(fakultasStr),
    prodi: json.decode(prodiStr),
  );
});
