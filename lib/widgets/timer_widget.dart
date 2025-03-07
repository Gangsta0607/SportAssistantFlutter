import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;
  final Function(int)? onTimeChanged;
  final VoidCallback onComplete;

  const TimerWidget({
    Key? key,
    required this.seconds,
    this.onTimeChanged,
    required this.onComplete,
  }) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> with SingleTickerProviderStateMixin {
  late int _currentTime;
  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _currentTime = widget.seconds;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    
    _animationController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentTime > 0) {
          _currentTime--;
          if (widget.onTimeChanged != null) {
            widget.onTimeChanged!(_currentTime);
          }
          
          if (_currentTime == 0) {
            _completeTimer();
          }
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _currentTime = widget.seconds;
      _isRunning = false;
      if (widget.onTimeChanged != null) {
        widget.onTimeChanged!(_currentTime);
      }
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() {
      _isRunning = false;
    });
    widget.onComplete();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(_isRunning ? 51 : 26),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(_isRunning ? 77 : 26),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _formatTime(_currentTime),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerButton(
              onPressed: _resetTimer,
              icon: Icons.refresh,
              label: 'Сброс',
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 20),
            _buildTimerButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              icon: _isRunning ? Icons.pause : Icons.play_arrow,
              label: _isRunning ? 'Пауза' : 'Старт',
              color: theme.colorScheme.primary,
              size: 70,
            ),
            const SizedBox(width: 20),
            _buildTimerButton(
              onPressed: _completeTimer,
              icon: Icons.check,
              label: 'Готово',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTimerButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    double size = 60,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 4,
              backgroundColor: color,
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
} 