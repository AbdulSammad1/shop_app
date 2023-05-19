import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import '../Models/http_exception.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

//checking whether the user is authenticated or not
  bool get isAuth {
    return Token != null;
  }

//checking for token
  String get Token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get UserId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDWVbH37C8MJhnKZ_vWDvEUJ_OD3haM5uM');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      //here below we are throwing our own error for checking for the signup/signin. It is because in this case firebase doesn't throw an error just shows an error message
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //
        throw HttpException(responseData['error']['message']);
      }

      //setting values of token and userid
      _token = responseData['idToken'];
      _userId = responseData['localId'];

      //setting token expiry date. We get it in seconds. so converting it into date format below
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      //using autologout function here. So it checks for the login time, awaits for it and logout the user after the time expires.
      _autoLogout();
      notifyListeners();

      //setting up our shared preferences here to then implement auto login funtion below
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    //using return here to return future inorder to make loading spinner work correctly
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    //using return here to return future inorder to make loading spinner work correctly
    return _authenticate(email, password, 'signInWithPassword');
  }

  //Implementing auto login function using shared preferences and storing user login information in the device and checking for it
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer == null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear(); 
  }

  void _autoLogout() {
    //setting autologout functionality to logout user automatically after the time expires
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
