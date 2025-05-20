import 'package:flutter/material.dart';
import 'dart:math';

class ModernPinInput extends StatelessWidget {
  final int length;
  final List<String> pin;
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBiometricPressed;
  final bool isError;
  final bool isLoading;
  
  const ModernPinInput({
    super.key,
    required this.length,
    required this.pin,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed,
    this.isError = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    // Responsive sizing
    final pinDotSize = isSmallScreen ? 12.0 : 16.0;
    final keypadButtonSize = isSmallScreen ? 65.0 : min(size.width / 5, 80.0);
    final keypadSpacing = isSmallScreen ? 12.0 : 16.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: pinDotSize,
              height: pinDotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < pin.length
                    ? (isError 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.primary)
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[300]),
                border: Border.all(
                  color: isError 
                      ? theme.colorScheme.error.withOpacity(0.5)
                      : theme.colorScheme.primary.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Number keypad
        Wrap(
          alignment: WrapAlignment.center,
          spacing: keypadSpacing,
          runSpacing: keypadSpacing,
          children: [
            // Numbers 1-9
            for (int i = 1; i <= 9; i++)
              _buildKeypadButton(
                i.toString(), 
                keypadButtonSize,
                theme,
                isDarkMode,
                () => onDigitPressed(i.toString()),
              ),
            
            // Biometric button (placeholder)
            Container(
              width: keypadButtonSize,
              height: keypadButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.fingerprint,
                  size: keypadButtonSize * 0.4,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                onPressed: onBiometricPressed,
              ),
            ),
            
            // Number 0
            _buildKeypadButton(
              '0', 
              keypadButtonSize,
              theme,
              isDarkMode,
              () => onDigitPressed('0'),
            ),
            
            // Backspace button
            Container(
              width: keypadButtonSize,
              height: keypadButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.backspace_outlined,
                  size: keypadButtonSize * 0.3,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                onPressed: onBackspacePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(
    String digit, 
    double size, 
    ThemeData theme, 
    bool isDarkMode,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode 
                ? Colors.grey[900] 
                : Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: size * 0.3,
                    height: size * 0.3,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    digit,
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
