import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PinInput extends StatefulWidget {
  final Function(String) onPinComplete;
  final String? errorText;
  
  const PinInput({
    super.key,
    required this.onPinComplete,
    this.errorText,
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12, // 0-9 + delete button
          itemBuilder: (context, index) {
            // Handle special cases (empty button at index 9, 0 at index 10, delete at index 11)
            if (index == 9) {
              return const SizedBox.shrink();
            }
            
            if (index == 10) {
              index = 0;
            } else if (index == 11) {
              // Delete button
              return InkWell(
                onTap: () {
                  if (_currentIndex > 0) {
                    setState(() {
                      _currentIndex--;
                      _pin[_currentIndex] = '';
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.backspace,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
            
            return InkWell(
              onTap: () {
                if (_currentIndex < AppConstants.pinLength) {
                  setState(() {
                    _pin[_currentIndex] = index.toString();
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
                    index.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
