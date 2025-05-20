import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/modern_pin_input.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({super.key});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  bool _isAuthenticating = false;
  bool _isError = false;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_pin.length < 6 && !_isAuthenticating) {
      setState(() {
        _pin.add(digit);
        _isError = false;
        _errorMessage = '';
      });

      // Check PIN when 6 digits are entered
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty && !_isAuthenticating) {
      setState(() {
        _pin.removeLast();
        _isError = false;
        _errorMessage = '';
      });
    }
  }

  // Removed unused _clearPin method

  Future<void> _verifyPin() async {
    final enteredPin = _pin.join();
    
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = await authProvider.verifyPin(enteredPin);
      
      if (isAuthenticated) {
        // Navigate to home screen on success
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
        }
      } else {
        _showError('Incorrect PIN. Please try again.');
        _shakeController.forward();
      }
    } catch (e) {
      _showError('Authentication error. Please try again.');
      _shakeController.forward();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _pin.clear();
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
    });
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'To reset your PIN, you will need to verify your identity. '
          'Would you like to proceed with PIN reset?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.pinResetRoute);
            },
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Account'),
        content: const Text(
          'Creating a new account will set up a new PIN. '
          'Would you like to proceed?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.pinSetupRoute);
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    // We don't need these variables anymore since we're using ModernPinInput widget
    
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: _isError
                  ? Offset(sin(_shakeAnimation.value * 3 * pi) * 10, 0)
                  : Offset.zero,
              child: child,
            );
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo or icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Welcome text
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Instruction text
                    Text(
                      'Enter your PIN to continue',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // PIN dots indicator and keypad
                    ModernPinInput(
                      length: 6,
                      pin: _pin,
                      onDigitPressed: _addDigit,
                      onBackspacePressed: _removeDigit,
                      onBiometricPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Biometric authentication not implemented yet'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      isError: _isError,
                      isLoading: _isAuthenticating,
                    ),
                    
                    // Error message
                    if (_isError) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    

                    
                    const SizedBox(height: 40),
                    
                    // Bottom options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Switch user
                        TextButton(
                          onPressed: () {
                            // Switch user functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Switch user not implemented yet'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.switch_account,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Switch User',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Create new account
                        TextButton(
                          onPressed: _showCreateAccountDialog,
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'New Account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Forgot PIN
                        TextButton(
                          onPressed: _showForgotPinDialog,
                          child: Column(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Forgot PIN',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
