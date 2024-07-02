import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _accessToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;

  AuthNotifier() {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    print('Checking authentication...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _isAuthenticated = _accessToken != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> loginUser(String email, String password) async {
    var url = Uri.parse('http://127.0.0.1:8000/api/v1/login/access-token');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&grant_type=password',
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', responseBody['access_token']);
      _accessToken = responseBody['access_token'];
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
