import 'package:flutter/material.dart';
import 'dart:async';

class CounterButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ThemeData theme;

  const CounterButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.theme,
  }) : super(key: key);

  @override
  CounterButtonState createState() => CounterButtonState();
}

class CounterButtonState extends State<CounterButton> {
  Timer? _timer;
  Timer? _accelerationTimer;
  int _currentInterval = 150;

  @override
  void dispose() {
    _timer?.cancel();
    _accelerationTimer?.cancel();
    super.dispose();
  }

  void _startIncrementing() {
    if (widget.onPressed == null) return;
    
    // Сбрасываем интервал
    _currentInterval = 150;
    
    // Сначала вызываем один раз для мгновенной реакции
    widget.onPressed!();
    
    void createTimer() {
      _timer?.cancel();
      _timer = Timer.periodic(Duration(milliseconds: _currentInterval), (timer) {
          widget.onPressed!();
        
        if (_currentInterval > 25) {
          _currentInterval -= 5;
          createTimer(); // Пересоздаем таймер с новым интервалом
        }
      });
    }
    createTimer();
  }

  void _stopIncrementing() {
    _timer?.cancel();
    _timer = null;
    _accelerationTimer?.cancel();
    _accelerationTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onPressed == null ? null : _startIncrementing,
      onLongPressUp: _stopIncrementing,
      onLongPressEnd: (_) => _stopIncrementing(),
      onLongPressCancel: _stopIncrementing,
      child: Material(
        color: widget.onPressed != null
            ? widget.theme.colorScheme.primary.withAlpha(26)
            : widget.theme.colorScheme.onSurface.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              widget.icon,
              color: widget.onPressed != null
                  ? widget.theme.colorScheme.primary
                  : widget.theme.colorScheme.onSurface.withAlpha(77),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 