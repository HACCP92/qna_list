import 'package:flutter/material.dart';
import '../../data/repository/qna_repository.dart';

class QnaViewModel with ChangeNotifier {
  final QnaRepository _repository = QnaRepository();
  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  Future<void> fetchData() async {
    final newData = await _repository.fetchData();
    _data = newData;
    notifyListeners();
  }
}
