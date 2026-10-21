import 'package:flutter/foundation.dart';

import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

/// 登录状态与当前用户。
class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _loading;
  String? get error => _error;

  /// 启动时从 settings 表恢复登录态。
  Future<void> restore() async {
    _user = await _repository.currentUser();
    notifyListeners();
  }

  Future<bool> login({
    required String account,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.login(account: account, password: password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}
