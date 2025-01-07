import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorAuth extends StatefulWidget {
  const TwoFactorAuth({super.key});

  @override
  State<TwoFactorAuth> createState() => _TwoFactorAuthState();
}

class _TwoFactorAuthState extends State<TwoFactorAuth> with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      _checkAuthenticationOnStartup();
    }
  }

  Future<void> loadFingerprintSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    });
  }

  Future<void> _checkAuthenticationOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;

    if (isFingerprintEnabled) {
      bool isAuthenticated = await showBiometricAuth();
      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed. Please try again later.')),
        );
        Navigator.of(context).pop();

      } else {
        Navigator.pop(context);
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
          const SnackBar(content: Text('Biometric authentication not available')),
        );
        return false;
      }

      final result = await auth.authenticate(
        localizedReason: 'Authenticate to access the dashboard',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Two-Factor Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enable 2F Authentication",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Switch(
              activeColor: Colors.blueGrey.shade900,
              value: isEnabled,
              onChanged: (value) async {
                if (isAuthenticating) return;

                setState(() {
                  isEnabled = value;
                });
                await saveFingerprintSetting(value);
                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric authentication enabled')),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric authentication disabled')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
