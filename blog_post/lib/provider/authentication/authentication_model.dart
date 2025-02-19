import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationModel extends ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  LocalAuthentication get auth => _auth;

  String _pinCode = "";
  String get pinCode => _pinCode;

  void cleanPinCode() {
    _pinCode = "";
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

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

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
      Logger().d("hasTouchId: $hasTouchId");

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка проверки биометрии: $e');
      _canCheckBiometrics = false;
      notifyListeners();
    }
  }

  Future<void> savePreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      if(_isAuthenticating && _isCancelled == false) {
        await prefs.setBool('use_biometry', _isAuthenticating);
      }
      await prefs.setString('email', email);
      await prefs.setString('pin_code', _pinCode);

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить настройки');
    }
  }

  String _pinCodePrefs = "";
  String get pinCodePrefs => _pinCodePrefs;

  Future<void> readPinCodeFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('pin_code') ?? '';

    _pinCodePrefs = stringValue;
    notifyListeners();
  }

  String _email = "";
  String get email => _email;

  Future<void> readEmailFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('email') ?? '';

    _email = stringValue;
    notifyListeners();
  }

  bool _isUseBiometry = false;
  bool get isUseBiometry => _isUseBiometry;
  
  Future<void> readUseBiometryFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool("use_biometry") ?? false;

    _isUseBiometry = boolValue;
    notifyListeners();
  }

  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  Future<void> authenticate() async {
    bool authenticated = false;

    try {
      _isAuthenticating = false;
      _isCancelled = false;
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
        notifyListeners();
      } else {
        _isCancelled = true;
      }
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('$e');
      _isAuthenticating = false;
      _isCancelled = false;
      notifyListeners();

      return;
    }
  }

  Future<void> cleanPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _pinCode = "";
    notifyListeners();
  }
}
