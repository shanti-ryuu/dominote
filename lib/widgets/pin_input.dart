import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PinInput extends StatefulWidget {
  final Function(String) onPinComplete;
  final String? errorText;
  final VoidCallback? onResetPin;
  
  const PinInput({
    super.key,
    required this.onPinComplete,
    this.errorText,
    this.onResetPin,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  final List<String> _pin = List.filled(AppConstants.pinLength, '');
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            AppConstants.pinLength,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentIndex == index
                      ? theme.colorScheme.primary
                      : isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _pin[index].isNotEmpty
                    ? isDarkMode ? Colors.grey[800] : Colors.grey[200]
                    : Colors.transparent,
              ),
              child: Center(
                child: _pin[index].isNotEmpty
                    ? Text(
                        '•',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 32),
        // PIN keyboard layout (1-9, 0)
        Column(
          children: [
            // Row 1: 1, 2, 3
            _buildKeyboardRow([1, 2, 3], isDarkMode, theme),
            const SizedBox(height: 8),
            // Row 2: 4, 5, 6
            _buildKeyboardRow([4, 5, 6], isDarkMode, theme),
            const SizedBox(height: 8),
            // Row 3: 7, 8, 9
            _buildKeyboardRow([7, 8, 9], isDarkMode, theme),
            const SizedBox(height: 8),
            // Row 4: Reset, 0, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset PIN button
                if (widget.onResetPin != null) ...[
                  _buildSpecialButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    onTap: widget.onResetPin!,
                    isDarkMode: isDarkMode,
                    theme: theme,
                  ),
                ] else ...[
                  _buildEmptyButton(),
                ],
                const SizedBox(width: 8),
                // 0 button
                _buildNumberButton(0, isDarkMode, theme),
                const SizedBox(width: 8),
                // Delete button
                _buildSpecialButton(
                  icon: Icons.backspace,
                  label: 'Delete',
                  onTap: () {
                    if (_currentIndex > 0) {
                      setState(() {
                        _currentIndex--;
                        _pin[_currentIndex] = '';
                      });
                    }
                  },
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildKeyboardRow(List<int> numbers, bool isDarkMode, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < numbers.length; i++) ...[
          _buildNumberButton(numbers[i], isDarkMode, theme),
          if (i < numbers.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
  
  Widget _buildNumberButton(int number, bool isDarkMode, ThemeData theme) {
    return SizedBox(
      width: 80,
      height: 60,
      child: InkWell(
        onTap: () {
          if (_currentIndex < AppConstants.pinLength) {
            setState(() {
              _pin[_currentIndex] = number.toString();
              _currentIndex++;
              
              // Check if PIN is complete
              if (_currentIndex == AppConstants.pinLength) {
                widget.onPinComplete(_pin.join());
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSpecialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
    required ThemeData theme,
  }) {
    return SizedBox(
      width: 80,
      height: 60,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyButton() {
    return const SizedBox(width: 80, height: 60);
  }
}
