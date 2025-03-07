import 'package:flutter/material.dart';
import 'counter_button.dart';

class ValueCounter extends StatelessWidget {
  static const double _defaultBorderRadius = 12.0;
  static const double _defaultPadding = 12.0;
  static const double _defaultSpacing = 8.0;
  static const double _defaultValueFontSize = 24.0;
  static const double _defaultLabelFontSize = 16.0;
  static const double _defaultSubtitleFontSize = 14.0;
  static const int _defaultMinValue = 0;
  static const int _defaultMaxValue = 999999;

  final String? label;
  final int value;
  final int minValue;
  final int maxValue;
  final void Function(int)? onChanged;
  final String? subtitle;

  const ValueCounter({
    Key? key,
    this.label,
    required this.value,
    required this.onChanged,
    this.minValue = _defaultMinValue,
    this.maxValue = _defaultMaxValue,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: _defaultLabelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: _defaultSpacing),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: _defaultPadding,
            horizontal: _defaultPadding + 4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: _defaultSubtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const SizedBox(height: _defaultPadding),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CounterButton(
                    icon: Icons.remove,
                    onPressed: _canDecrement ? _handleDecrement : null,
                    theme: theme,
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: _defaultValueFontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  CounterButton(
                    icon: Icons.add,
                    onPressed: _canIncrement ? _handleIncrement : null,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _canDecrement => onChanged != null && value > minValue;
  bool get _canIncrement => onChanged != null && value < maxValue;

  void _handleDecrement() => onChanged?.call(value - 1);
  void _handleIncrement() => onChanged?.call(value + 1);
} 