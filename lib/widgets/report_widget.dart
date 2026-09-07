import 'package:connect_app/widgets/primary_button.dart';
import 'package:connect_app/widgets/text_fields.dart';
import 'package:flutter/material.dart';

import '../utils/text_styles.dart';

class ReportWidget extends StatefulWidget {
  final Function(String) onSubmit;
  const ReportWidget({super.key, required this.onSubmit});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  late final TextEditingController textEditingController;
  late final ValueNotifier<int> isOtherSelected;
  late List<String> options;
  @override
  void initState() {
    textEditingController = TextEditingController();
    isOtherSelected = ValueNotifier(-1);
    options = [
      'Abusive',
      'Harassment',
      'Pornography',
      'Other',
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Report",
            style: subHeadingText(),
          ),
          SizedBox(
            height: 20,
          ),
          ValueListenableBuilder<int>(
            valueListenable: isOtherSelected,
            builder: (BuildContext context, value, Widget? child) {
              if (value == 3) {
                return multiLinesTextField(
                  textEditingController,
                  FocusNode(),
                  [],
                  hint: 'Description',
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: options.asMap().entries.map((element) {
                    return GestureDetector(
                      onTap: () {
                        if (element.value == 'Other') {
                          textEditingController.clear();
                        } else {
                          textEditingController.text = element.value;
                        }
                        isOtherSelected.value = element.key;
                      },
                      child: Text(
                        "${value == element.key ? "✓ " : ""}${element.value}\n",
                        style: normalText().copyWith(fontSize: 16),
                      ),
                    );
                  }).toList(),
                );
              }
            },
            child: multiLinesTextField(
              textEditingController,
              FocusNode(),
              [],
              hint: 'Description',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          PrimaryButton(
            label: 'Submit',
            onPress: () {
              if (textEditingController.text.isEmpty) {
                return;
              }
              widget.onSubmit(textEditingController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    isOtherSelected.dispose();
    options.clear();
    super.dispose();
  }
}
