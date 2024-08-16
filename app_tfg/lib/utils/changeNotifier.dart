import 'package:flutter/material.dart';

class RefreshNotifier extends ChangeNotifier {
  void notifyRefresh() {
    notifyListeners();
  }
}
