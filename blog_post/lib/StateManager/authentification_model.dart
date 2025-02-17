import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthentificationModel extends ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  LocalAuthentication get auth => _auth;
  String _prefsEmail = "";
  String _prefsPinCode = "";

  String get prefsEmail => _prefsEmail;
  String get prefsPinCode => _prefsPinCode;

  void setPrefsEmail(String email) {
    _prefsEmail = email;
    _prefsPinCode = _pinCode;

    notifyListeners();
  }

  String _pinCode = "";
  String get pinCode => _pinCode;
  void setPinCode(String pinCode) {
    _pinCode = pinCode;
    notifyListeners();
  }

  void appendToPinCode(String digit) {
    if (_pinCode.length < 4) {
      _pinCode += digit;
      notifyListeners();
    }
  }

  void removeLastDigit() {
    if (_pinCode.isNotEmpty) {
      _pinCode = _pinCode.substring(0, _pinCode.length - 1);
      notifyListeners();
    }
  }

  TextEditingController _pinCodeController = TextEditingController();
  TextEditingController get pinCodeController => _pinCodeController;

  String _authorizedState = 'Not Authorized';
  String get authorizedState => _authorizedState;
  void setAuthorizedState(String state) {
    _authorizedState = state;
    notifyListeners();
  }

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;
  void setIsAuthenticating(bool state) {
    _isAuthenticating = state;
    notifyListeners();
  }

  bool _useBiometry = false;
  bool get useBiometry => _useBiometry;

  bool _canCheckBiometrics = false;
  bool get canCheckBiometrics => _canCheckBiometrics;

  Future<void> checkBiometryAvailability() async {
    try {
      final bool canCheck = await _auth.isDeviceSupported();

      if (!canCheck) {
        _canCheckBiometrics = false;
        notifyListeners();
      }

      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();

      final bool hasTouchId = availableBiometrics.contains(BiometricType.weak);

      Logger().d("availableBiometrics: $availableBiometrics");
      _canCheckBiometrics = hasTouchId;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка проверки биометрии: $e');
      _canCheckBiometrics = false;
      notifyListeners();
    }
  }

  void toggleBiometry() {
    _useBiometry = !_useBiometry;
    notifyListeners();
  }

  Future<void> savePreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // await prefs.setBool('use_biometry', _useBiometry);
      await prefs.setString('email', email);
      await prefs.setString('pin_code', _pinCode);

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить настройки');
    }
  }

  Future<String> readPinCodeFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('pin_code') ?? '';
    return stringValue;
  }

  Future<String> readEmailFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('email') ?? '';
    return stringValue;
  }

  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  Future<void> authenticate() async {
    bool authenticated = false;

    try {
      _isAuthenticating = false;
      _isCancelled = false;
      _authorizedState = 'Authenticating';
      notifyListeners();

      authenticated = await _auth.authenticate(
          localizedReason: "Подтвердите вашу личность",
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true,
          ));

      if (authenticated) {
        _isAuthenticating = true;
        _authorizedState = 'Successfully Authenticated';
        notifyListeners();
      } else {
        _isCancelled = true;
        _authorizedState = 'Authentication Cancelled';
      }
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('$e');
      _isAuthenticating = false;
      _isCancelled = false;
      _authorizedState = "Error - ${e.message}";
      notifyListeners();

      return;
    }
  }
}
