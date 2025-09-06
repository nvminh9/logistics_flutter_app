import 'package:flutter/material.dart';

abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void clearError() {
    setError(null);
  }

  @protected
  Future<T?> safeCall<T>(Future<T> Function() apiCall) async {
    try {
      setLoading(true);
      clearError();
      final result = await apiCall();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}