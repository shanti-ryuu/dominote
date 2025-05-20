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

class _PinSetupScreenState extends State<PinSetupScreen> with SingleTickerProviderStateMixin {
  String? _firstPin;
  String? _errorText;
  bool _isConfirmingPin = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirmingPin ? 'Confirm PIN' : 'Set PIN'),
        actions: [
          if (_isConfirmingPin)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isConfirmingPin = false;
                  _firstPin = null;
                  _errorText = null;
                });
              },
              tooltip: 'Go back',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isConfirmingPin
                      ? Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: theme.colorScheme.primary,
                          key: const ValueKey('confirm_icon'),
                        )
                      : Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: theme.colorScheme.primary,
                          key: const ValueKey('setup_icon'),
                        ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isConfirmingPin
                        ? 'Confirm your PIN'
                        : 'Create a 4-digit PIN',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    key: ValueKey(_isConfirmingPin ? 'confirm_title' : 'setup_title'),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _isConfirmingPin
                          ? 'Please enter your PIN again to confirm'
                          : 'This PIN will be used to secure your notes',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      key: ValueKey(_isConfirmingPin ? 'confirm_subtitle' : 'setup_subtitle'),
                    ),
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
                  onResetPin: _isConfirmingPin ? () {
                    setState(() {
                      _isConfirmingPin = false;
                      _firstPin = null;
                      _errorText = null;
                    });
                  } : null,
                ),
                const SizedBox(height: 32),
                if (!_isConfirmingPin) ...[                  
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Account Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.person_add_outlined,
                    title: 'Register New Account',
                    subtitle: 'Create a new account with a different PIN',
                    onTap: () {
                      // This is already the register screen, so just show a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You are already creating a new account'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    icon: Icons.help_outline,
                    title: 'Forgot PIN?',
                    subtitle: 'Reset your PIN if you forgot it',
                    onTap: () {
                      _showResetPinDialog();
                    },
                    theme: theme,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setFirstPin(String pin) {
    _animationController.forward().whenComplete(() {
      setState(() {
        _firstPin = pin;
        _isConfirmingPin = true;
        _errorText = null;
      });
      _animationController.reverse();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN set successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    }
  }
  
  Future<void> _showResetPinDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPinSet = await authProvider.checkPinStatus();
    
    if (!mounted) return;
    
    if (!isPinSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PIN is set yet. Please create a new PIN.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text('This will delete your current PIN and all your notes. Are you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authProvider.resetPin();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN has been reset. Please create a new PIN.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
