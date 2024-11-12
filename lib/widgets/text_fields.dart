import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connect_app/globals/container_properties.dart';
import 'package:connect_app/utils/app_colors.dart';

import '../utils/text_styles.dart';

customTextFiled(
  TextEditingController controller,
  FocusNode focusNode,
  List<TextInputFormatter>? textInputFormatter,
  dynamic icon, {
  bool obscure = false,
  bool dropdown = false,
  dynamic suffixIcon,
  Color? color,
  void Function(String? val)? onchange,
  Function? ontap,
  int? lines,
  TextInputType textInputType = TextInputType.text,
  String hint = '',
}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(
        radius: 15, color: color ?? const Color.fromARGB(0, 0, 0, 0)),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,

      // cursorColor: Colors.white,
      style: regularText(size: 15).copyWith(),
      readOnly: ontap != null,
      onTap: () {
        if (ontap != null) {
          ontap();
        }
      },
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
              borderSide:
                  BorderSide(color: AppColors.primaryColorBottom, width: 2),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.bgGrey),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

Widget customTextFieldOptionalPreffix(TextEditingController? controller,
    FocusNode? focusNode, List<TextInputFormatter>? textInputFormatter,
    {bool obscure = false,
    bool dropdown = false,
    dynamic prefixIcon, // Added prefixIcon parameter
    dynamic suffixIcon,
    Color? color,
    Function(String? val)? onchange,
    void Function()? ontap,
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
      readOnly: ontap != null,
      onTap: ontap,
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
      maxLines: lines ?? 1, // Sets maximum number of lines
    ),
  );
}

simplecustomTextFiled(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter>? textInputFormatter, dynamic icon,
    {bool obscure = false,
    bool dropdown = false,
    dynamic suffixIcon,
    Color? color,
    dynamic onchange,
    Function? ontap,
    int? lines,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(
        radius: 15, color: color ?? Colors.transparent),
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
      readOnly: ontap != null,
      onTap: ontap == null ? () {} : ontap(),
      decoration: InputDecoration(
          labelText: hint,
          labelStyle:
              normalText().copyWith(color: Colors.grey.withOpacity(0.9)),
          suffixIcon: dropdown ? const Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: lines == null ? 0 : 5),
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
  final void Function(String)?  onchange;
  final Function? ontap;
  final int? lines;
  final TextInputType textInputType;
  final String hint;

  CustomTextFieldMulti({
    this.controller,
    this.focusNode,
    this.textInputFormatter,
    this.icon,
    this.obscure = false,
    this.dropdown = false,
    this.suffixIcon,
    this.color,
    this.onchange,
    this.ontap,
    this.lines,
    this.textInputType = TextInputType.text,
    this.hint = '',
  });

  @override
  _CustomTextFieldMultiState createState() => _CustomTextFieldMultiState();
}

class _CustomTextFieldMultiState extends State<CustomTextFieldMulti> {
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
        readOnly: widget.ontap != null,
        onTap: widget.ontap == null ? null : () => widget.ontap!(),
        decoration: InputDecoration(
          labelText: widget.hint,
          labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
          suffixIcon: widget.dropdown
              ? const Icon(Icons.keyboard_arrow_down)
              : (_showIcon ? widget.suffixIcon : null),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: widget.lines == null ? 0 : 5),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(widget.icon == null ? 8 : 15),
          ),
        ),
      ),
    );
  }
}

customTextFiledMenu(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter> textInputFormatter, dynamic icon,
    {bool obscure = false,
    dynamic ontap,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      decoration: ContainerProperties.simpleDecoration(
          radius: 15, color: Colors.transparent),
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

customTextFiledSimple(TextEditingController controller, FocusNode focusNode,
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
    String lable = ''}) {
  return SizedBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lable,
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
          style: regularText(size: textSize)
              .copyWith(color: textColor ?? Colors.white),
          decoration: InputDecoration(
              hintText: hint,
              suffixIcon: Container(
                  alignment: Alignment.center,
                  width: 30,
                  height: 30,
                  child: icon),
              hintStyle: regularText(color: AppColors.borderColor),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor)),
              border: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor))),
        ),
      ],
    ),
  );
}

multiLinesTextField(
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
            borderSide: BorderSide(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.primaryColorBottom, width: 2),
            borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.bgGrey),
            borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

OutlineInputBorder _outlineBorder(Color? borderColor) {
  return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor ?? const Color(0xFF000000)),
      borderRadius: BorderRadius.circular(5));
}
