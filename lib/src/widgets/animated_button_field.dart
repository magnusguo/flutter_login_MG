import 'package:flutter/material.dart';
import 'package:flutter_login_MG/src/models/user_button_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Returns an [Interval] for animating a subrange within another interval,
/// useful for nested animation sequencing.
Interval _getInternalInterval(
  double start,
  double end,
  double externalStart,
  double externalEnd, [
  Curve curve = Curves.linear,
]) {
  return Interval(
    start + (end - start) * externalStart,
    start + (end - start) * externalEnd,
    curve: curve,
  );
}

/// A custom button field widget with animation support.
///
/// This widget displays a button-style field with left icon, title text,
/// right content text, and right arrow. It supports loading animations
/// and maintains visual consistency with form fields.
class AnimatedButtonField extends StatefulWidget {
  /// Creates an [AnimatedButtonField].
  ///
  /// The [width] and [buttonField] are required.
  const AnimatedButtonField({
    required this.width,
    required this.buttonField,
    super.key,
    this.interval = const Interval(0, 1),
    this.loadingController,
    this.enabled = true,
  });

  /// Controls the animation timing of this widget relative to a larger sequence.
  final Interval interval;

  /// Animation controller for loading transitions.
  final AnimationController? loadingController;

  /// Width of the button field (usually based on screen size).
  final double width;

  /// The button field configuration data.
  final UserButtonField buttonField;

  /// Whether the button is enabled for user interaction.
  final bool enabled;

  @override
  State<AnimatedButtonField> createState() => _AnimatedButtonFieldState();
}

class _AnimatedButtonFieldState extends State<AnimatedButtonField> {
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    final interval = widget.interval;
    final loadingController = widget.loadingController;

    if (loadingController != null) {
      scaleAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(
            0,
            .2,
            interval.begin,
            interval.end,
            Curves.easeOutBack,
          ),
        ),
      );
    } else {
      // If no loading controller, just use a constant animation
      scaleAnimation = AlwaysStoppedAnimation(1.0);
    }
  }

  TextStyle _getRightTextStyle(ThemeData theme) {
    // If custom text style is provided, use it
    if (widget.buttonField.rightTextStyle != null) {
      return widget.buttonField.rightTextStyle!;
    }

    // Otherwise, build style from individual properties with dynamic sizing
    //这里修改过代码, 因为在小屏幕尺寸下, 文字会显示不全 尤其是注册用户时 出生时辰这里, 所以需要动态调整字体大小 2025-11-23 02:49:03
    double fontSize = widget.buttonField.rightTextSize ?? 14.0;
    
    // If no custom size specified, calculate based on text length and screen width
    if (widget.buttonField.rightTextSize == null) {
      final textLength = widget.buttonField.rightText.length;
      final screenWidth = MediaQuery.of(context).size.width;
      
      // Dynamic font size calculation
      if (textLength <= 10 || screenWidth >= 385) {
        fontSize = 13.0;
      } else {
        fontSize = 11.5;
      }
    }
    return theme.textTheme.bodyMedium!.copyWith(
      color: widget.buttonField.rightTextColor ?? theme.textTheme.bodySmall?.color,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.enabled && widget.buttonField.enabled;
    
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled 
                ? () async {
                    if (widget.buttonField.onTap != null) {
                      await widget.buttonField.onTap!(widget.buttonField.keyName);
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Left Icon
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: widget.buttonField.icon ?? 
                           const Icon(FontAwesomeIcons.solidCircleUser, size: 18),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title Text
                  Expanded(
                    child: Text(
                      widget.buttonField.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isEnabled 
                            ? theme.textTheme.bodyMedium?.color
                            : theme.disabledColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Right Content Text
                  if (widget.buttonField.rightText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.buttonField.rightText,
                      style: _getRightTextStyle(theme).copyWith(
                        color: isEnabled 
                            ? _getRightTextStyle(theme).color
                            : theme.disabledColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(width: 8),
                  
                  // Right Arrow
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isEnabled 
                        ? theme.iconTheme.color?.withOpacity(0.6)
                        : theme.disabledColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
