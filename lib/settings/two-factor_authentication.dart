import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorAuth extends StatefulWidget {
  const TwoFactorAuth({super.key});

  @override
  State<TwoFactorAuth> createState() => _TwoFactorAuthState();
}

class _TwoFactorAuthState extends State<TwoFactorAuth>
    with WidgetsBindingObserver {
  bool authenticated = false;
  bool isEnabled = false;
  bool isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadFingerprintSetting();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isAuthenticating) {
      _checkAuthenticationOnStartup();
    }
  }

  Future<void> _checkAuthenticationOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;

    if (isFingerprintEnabled) {
      bool isAuthenticated = await showBiometricAuth();
      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed. Please try again later.'),
            backgroundColor: Colors.red.shade500,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      } else {

      }
    }
  }

  Future<bool> showBiometricAuth() async {
    if (isAuthenticating) return false;

    setState(() {
      isAuthenticating = true;
    });

    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication not available.'),
            backgroundColor: Colors.red.shade500,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(10),
          ),
        );
        return false;
      }

      final result = await auth.authenticate(
        localizedReason: 'Authenticate to access the dashboard',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (result) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('is_authenticated', true);
      }

      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
          backgroundColor: Colors.red.shade500,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
        ),
      );
      return false;
    } finally {
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  Future<void> saveFingerprintSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', value);

    if (!value) {
      prefs.setBool('is_authenticated', false);
    }
  }

  Future<void> loadFingerprintSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Two-Factor Authentication"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Secure your account with Two-Factor Authentication",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enable 2F Authentication",
                  style: const TextStyle(fontSize: 18),
                ),
                Switch(
                  activeColor: Colors.blueGrey.shade900,
                  value: isEnabled,
                  onChanged: (value) async {
                    if (isAuthenticating) return;

                    setState(() {
                      isEnabled = value;
                    });
                    await saveFingerprintSetting(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value
                            ? 'Biometric authentication enabled'
                            : 'Biometric authentication disabled'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: value ? Colors.green.shade500 : Colors.red.shade500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Icon(
                isEnabled ? Icons.fingerprint : Icons.security,
                size: 100,
                color: Colors.blueGrey.shade400,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
