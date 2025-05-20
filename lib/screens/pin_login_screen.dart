import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/pin_input.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String? _errorText;
  int _attempts = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Enter your PIN',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please enter your 4-digit PIN to access your notes',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            PinInput(
              errorText: _errorText,
              onPinComplete: _verifyPin,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPin(String pin) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isValid = await authProvider.verifyPin(pin);
    
    if (isValid) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      }
    } else {
      _attempts++;
      
      setState(() {
        if (_attempts >= 3) {
          _errorText = 'Too many failed attempts. Please try again carefully.';
        } else {
          _errorText = 'Invalid PIN. Please try again.';
        }
      });
    }
  }
}
