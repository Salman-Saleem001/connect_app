import 'package:connect_app/globals/container_properties.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/text_styles.dart';

Container customTextFiled(
  TextEditingController controller,
  FocusNode focusNode,
  List<TextInputFormatter>? textInputFormatter,
  dynamic icon, {
  bool obscure = false,
  bool dropdown = false,
  dynamic suffixIcon,
  Color? color,
  void Function(String? val)? onchange,
  void Function(PointerDownEvent)? onTapOutSide,
  Function? onTap,
  int? lines,
  TextInputType textInputType = TextInputType.text,
  String hint = '',
  bool? enabled,
}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(radius: 15, color: color ?? const Color.fromARGB(0, 0, 0, 0)),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      enabled: enabled,
      // cursorColor: Colors.white,
      style: regularText(size: 15).copyWith(),
      readOnly: onTap != null,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      onTapOutside: onTapOutSide,
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: normalText().copyWith(color: AppColors.lightText),
          hintText: textInputType == TextInputType.datetime ? '01/01/2023' : '',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon == null
              ? null
              : SizedBox(
                  height: 60,
                  width: 40,
                  child: icon,
                ),
          suffixIcon: dropdown ? const Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColorBottom, width: 2),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.bgGrey),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

Widget customTextFieldOptionalPrefix(
    TextEditingController? controller, FocusNode? focusNode, List<TextInputFormatter>? textInputFormatter,
    {bool obscure = false,
    bool dropdown = false,
    dynamic prefixIcon, // Added prefixIcon parameter
    dynamic suffixIcon,
    Color? color,
    void Function(String val)? onchange,
    void Function()? onTap,
    int? lines,
    double borderRadius = 16,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: color ?? Colors.transparent,
    ),
    child: TextField(
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon != null
            ? SizedBox(
                height: 60,
                width: 40,
                child: prefixIcon,
              )
            : null,
        suffixIcon: dropdown ? const Icon(Icons.keyboard_arrow_down) : suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColorBottom, width: 2),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        // Increased vertical padding
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      minLines: lines ?? 1,
      // Sets minimum number of lines
      maxLines: lines, // Sets maximum number of lines
    ),
  );
}

Container simpleCustomTextFiled(
    TextEditingController controller, FocusNode focusNode, List<TextInputFormatter>? textInputFormatter, dynamic icon,
    {bool obscure = false,
    bool dropdown = false,
    dynamic suffixIcon,
    Color? color,
    dynamic onchange,
    Function? onTap,
    int? lines,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(radius: 15, color: color ?? Colors.transparent),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      cursorColor: Colors.black,
      style: regularText(size: 15).copyWith(color: Colors.black),
      readOnly: onTap != null,
      onTap: onTap == null ? () {} : onTap(),
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: normalText().copyWith(color: Colors.grey.withValues(alpha: 0.9)),
          suffixIcon: dropdown ? const Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

class CustomTextFieldMulti extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? textInputFormatter;
  final dynamic icon;
  final bool obscure;
  final bool dropdown;
  final dynamic suffixIcon;
  final Color? color;
  final void Function(String)? onchange;
  final Function? onTap;
  final int? lines;
  final TextInputType textInputType;
  final String hint;

  const CustomTextFieldMulti({
    super.key,
    this.controller,
    this.focusNode,
    this.textInputFormatter,
    this.icon,
    this.obscure = false,
    this.dropdown = false,
    this.suffixIcon,
    this.color,
    this.onchange,
    this.onTap,
    this.lines,
    this.textInputType = TextInputType.text,
    this.hint = '',
  });

  @override
  CustomTextFieldMultiState createState() => CustomTextFieldMultiState();
}

class CustomTextFieldMultiState extends State<CustomTextFieldMulti> {
  bool _showIcon = true;

  @override
  void initState() {
    super.initState();
    // Hide the icon after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showIcon = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: widget.color ?? Colors.transparent,
      ),
      child: TextField(
        keyboardType: widget.textInputType,
        inputFormatters: widget.textInputFormatter ?? [],
        focusNode: widget.focusNode,
        textAlign: TextAlign.start,
        obscureText: widget.obscure,
        controller: widget.controller,
        onChanged: widget.onchange,
        maxLines: widget.lines,
        cursorColor: Colors.black,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        readOnly: widget.onTap != null,
        onTap: widget.onTap == null ? null : () => widget.onTap!(),
        decoration: InputDecoration(
          labelText: widget.hint,
          labelStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.9)),
          suffixIcon: widget.dropdown ? const Icon(Icons.keyboard_arrow_down) : (_showIcon ? widget.suffixIcon : null),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: widget.lines == null ? 0 : 5),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
        ),
      ),
    );
  }
}

GestureDetector customTextFiledMenu(
    TextEditingController controller, FocusNode focusNode, List<TextInputFormatter> textInputFormatter, dynamic icon,
    {bool obscure = false, dynamic onTap, TextInputType textInputType = TextInputType.text, String hint = ''}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: ContainerProperties.simpleDecoration(radius: 15, color: Colors.transparent),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        cursorColor: Colors.white,
        style: regularText(size: 15).copyWith(color: Colors.white),
        readOnly: true,
        enabled: false,
        decoration: InputDecoration(
          labelText: hint,
          hintStyle: regularText().copyWith(color: Colors.white),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.bgGrey),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.bgGrey),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.bgGrey),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
        ),
      ),
    ),
  );
}

SizedBox customTextFiledSimple(TextEditingController controller, FocusNode focusNode,
    {bool obscure = false,
    int? maxChar,
    List<TextInputFormatter> textInputFormatter = const [],
    double height = 35,
    double textSize = 15,
    Color? textColor,
    Color? cursorColor,
    Color? borderColor,
    dynamic icon,
    TextStyle? hintStyle,
    TextInputType textInputType = TextInputType.text,
    String hint = '',
    String label = ''}) {
  return SizedBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: regularText(size: 12, color: const Color(0xFFFFF5E1)),
        ),
        TextField(
          keyboardType: textInputType,
          inputFormatters: textInputFormatter,
          focusNode: focusNode,
          obscureText: obscure,
          maxLength: maxChar,
          controller: controller,
          cursorColor: cursorColor ?? Colors.black,
          style: regularText(size: textSize).copyWith(color: textColor ?? Colors.white),
          decoration: InputDecoration(
              hintText: hint,
              suffixIcon: Container(alignment: Alignment.center, width: 30, height: 30, child: icon),
              hintStyle: regularText(color: AppColors.borderColor),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1.5, color: AppColors.borderColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1.5, color: AppColors.borderColor)),
              border: UnderlineInputBorder(borderSide: BorderSide(width: 1.5, color: AppColors.borderColor))),
        ),
      ],
    ),
  );
}

SizedBox multiLinesTextField(
  TextEditingController controller,
  FocusNode focusNode,
  List<TextInputFormatter> textInputFormatter, {
  bool obscure = false,
  int? maxChar,
  double textSize = 15,
  Color? textColor,
  Color? cursorColor,
  Color? borderColor,
  TextStyle? hintStyle,
  TextInputType textInputType = TextInputType.text,
  String hint = '',
}) {
  return SizedBox(
    child: TextField(
      keyboardType: textInputType,
      inputFormatters: textInputFormatter,
      focusNode: focusNode,
      obscureText: obscure,
      maxLength: maxChar,
      maxLines: 5,
      controller: controller,
      cursorColor: cursorColor ?? Colors.black,
      style: TextStyle(
        fontSize: textSize,
        color: textColor ?? Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderColor), borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColorBottom, width: 2),
            borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.bgGrey), borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}
