import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/pin_input.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _firstPin;
  String? _errorText;
  bool _isConfirmingPin = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirmingPin ? 'Confirm PIN' : 'Set PIN'),
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
              _isConfirmingPin
                  ? 'Confirm your PIN'
                  : 'Create a 4-digit PIN',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _isConfirmingPin
                    ? 'Please enter your PIN again to confirm'
                    : 'This PIN will be used to secure your notes',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            PinInput(
              errorText: _errorText,
              onPinComplete: (pin) {
                if (_isConfirmingPin) {
                  _confirmPin(pin);
                } else {
                  _setFirstPin(pin);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setFirstPin(String pin) {
    setState(() {
      _firstPin = pin;
      _isConfirmingPin = true;
      _errorText = null;
    });
  }

  Future<void> _confirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _errorText = 'PINs do not match. Try again.';
        _isConfirmingPin = false;
        _firstPin = null;
      });
      return;
    }

    // Save PIN and navigate to home
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.setPin(pin);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    }
  }
}
