import 'package:flutter/material.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';

// All rights reserved by Healer

// ignore: must_be_immutable
class PrimaryButton extends StatelessWidget {
  final String label;
  final Color? color;
  final GestureTapCallback onPress;
  final dynamic icon;
  final dynamic keys;
  final bool bordered;
  final bool whiteButton;
  final double buttonHight;
  double radius;

  PrimaryButton({
    super.key,
    required this.label,
    required this.onPress,
    this.color,
    this.whiteButton = false,
    this.bordered = false,
    this.radius = 10,
    this.icon,
    this.keys,
    this.buttonHight = 55.0,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColorTop,
              AppColors.primaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 7),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(whiteButton ? 15 : radius),
        ),
        height: buttonHight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPress,
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(whiteButton ? 15 : radius),
              ),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              style: regularText(size: 18).copyWith(
                color: whiteButton ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      );
}

class BorderedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  BorderedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.borderColorButton),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16.0),
      ),
      child: Text(
        text,
        style: regularText(size: 15, color: AppColors.textPrimary),
      ),
    );
  }
}
