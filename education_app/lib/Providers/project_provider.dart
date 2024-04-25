import 'package:flutter/foundation.dart';

class ProjectProvider with ChangeNotifier {
  String _selectedProjectId = "";

  String get selectedProjectId => _selectedProjectId;

  void selectProject(String projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }
}
