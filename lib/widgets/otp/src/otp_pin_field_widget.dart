import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_pin_field_input_type.dart';
import 'otp_pin_field_style.dart';

typedef OnDone = void Function(String text);

class OtpPinField extends StatefulWidget {
  final double fieldHeight;
  final double fieldWidth;
  final int maxLength;
  final OtpPinFieldStyle? otpPinFieldStyle;
  final OnDone onSubmit;
  final OtpPinFieldInputType otpPinFieldInputType;
  final String otpPinInputCustom;
  final OtpPinFieldDecoration otpPinFieldDecoration;
  final TextInputType keyboardType;
  final bool autoFocus;
  final bool highlightBorder;

  const OtpPinField({
    Key? key,
    this.fieldHeight = 60.0,
    this.fieldWidth = 60.0,
    this.maxLength = 4,
    this.otpPinFieldStyle = const OtpPinFieldStyle(),
    this.otpPinFieldInputType = OtpPinFieldInputType.none,
    this.otpPinFieldDecoration =
        OtpPinFieldDecoration.underlinedPinBoxDecoration,
    this.otpPinInputCustom = "*",
    required this.onSubmit,
    this.keyboardType = TextInputType.number,
    this.autoFocus = true,
    this.highlightBorder = true,
  }) : super(key: key);

  @override
  OtpPinFieldState createState() => OtpPinFieldState();
}

class OtpPinFieldState extends State<OtpPinField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late List<String> pinsInputed;
  bool ending = false;
  bool hasFocus = false;
  String text = "";

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    pinsInputed = [];
    for (var i = 0; i < widget.maxLength; i++) {
      pinsInputed.add("");
    }
    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.fieldHeight,
      child: Stack(children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildBody(context),
            ),
          ),
        ),
        Opacity(
          opacity: 0.0,
          child: TextField(
            maxLength: widget.maxLength,
            autofocus: !kIsWeb ? widget.autoFocus : false,
            enableInteractiveSelection: false,
            inputFormatters: widget.keyboardType == TextInputType.number
                ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                : null,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            onSubmitted: (text) {},
            onChanged: (text) {
              this.text = text;
              // FocusScope.of(context).nextFocus();
              if (ending && text.length == widget.maxLength) {
                return;
              }
              _bindTextIntoWidget(text);
              setState(() {});
              ending = text.length == widget.maxLength;
              if (ending) {
                widget.onSubmit(text);
                FocusScope.of(context).unfocus();
              }
            },
          ),
        )
      ]),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    var tmp = <Widget>[];
    for (var i = 0; i < widget.maxLength; i++) {
      tmp.add(Expanded(child: _buildFieldInput(context, i)));
      if (i < widget.maxLength - 1) {
        tmp.add(SizedBox(
          width: widget.otpPinFieldStyle!.fieldPadding,
        ));
      }
    }
    return tmp;
  }

  Widget _buildFieldInput(BuildContext context, int i) {
    Color fieldBorderColor;
    Color? fieldBackgroundColor;
    BoxDecoration boxDecoration;

    // if (widget.highlightBorder) {
    fieldBorderColor = widget.highlightBorder && _shouldHighlight(i)
        ? widget.otpPinFieldStyle!.activeFieldBorderColor
        : widget.otpPinFieldStyle!.defaultFieldBorderColor;
    fieldBackgroundColor = widget.highlightBorder && _shouldHighlight(i)
        ? widget.otpPinFieldStyle!.activeFieldBackgroundColor
        : widget.otpPinFieldStyle!.defaultFieldBackgroundColor;
    // }

    if (widget.otpPinFieldDecoration ==
        OtpPinFieldDecoration.underlinedPinBoxDecoration) {
      boxDecoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: fieldBorderColor,
            width: 1.0,
          ),
        ),
      );
    } else if (widget.otpPinFieldDecoration ==
        OtpPinFieldDecoration.defaultPinBoxDecoration) {
      boxDecoration = BoxDecoration(
          border: Border.all(
            color: fieldBorderColor,
            width: 1.0,
          ),
          color: fieldBackgroundColor,
          borderRadius: BorderRadius.circular(5.0));
    } else if (widget.otpPinFieldDecoration ==
        OtpPinFieldDecoration.roundedPinBoxDecoration) {
      boxDecoration = BoxDecoration(
        border: Border.all(
          color: fieldBorderColor,
          width: widget.otpPinFieldStyle!.fieldBorderWidth,
        ),
        shape: BoxShape.circle,
        color: fieldBackgroundColor,
      );
    } else {
      boxDecoration = BoxDecoration(
          border: Border.all(
            color: fieldBorderColor,
            width: 1.0,
          ),
          color: fieldBackgroundColor,
          borderRadius: BorderRadius.circular(
              widget.otpPinFieldStyle!.fieldBorderRadius));
    }

    return InkWell(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
          width: widget.fieldWidth,
          alignment: Alignment.center,
          decoration: boxDecoration,
          child: Text(
            _getPinDisplay(i),
            style: widget.otpPinFieldStyle!.textStyle,
            textAlign: TextAlign.center,
          )),
    );
  }

  String _getPinDisplay(int position) {
    var display = "";
    var value = pinsInputed[position];
    switch (widget.otpPinFieldInputType) {
      case OtpPinFieldInputType.password:
        display = "*";
        break;
      case OtpPinFieldInputType.custom:
        display = widget.otpPinInputCustom;
        break;
      default:
        display = value;
        break;
    }
    return value.isNotEmpty ? display : value;
  }

  void _bindTextIntoWidget(String text) {
    ///Reset value
    for (var i = text.length; i < pinsInputed.length; i++) {
      pinsInputed[i] = "";
    }
    if (text.isNotEmpty) {
      for (var i = 0; i < text.length; i++) {
        pinsInputed[i] = text[i];
      }
    }
  }

  void _focusListener() {
    if (mounted == true) {
      setState(() {
        hasFocus = _focusNode.hasFocus;
      });
    }
  }

  bool _shouldHighlight(int i) {
    return hasFocus &&
        (i == text.length ||
            (i == text.length - 1 && text.length == widget.maxLength));
  }
}
