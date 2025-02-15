import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool? obscureText;
  final void Function(String)? setParams;
  final String labelText;
  final String? errorText;
  final Widget? iconsSuffix;

  const TextFieldWidget(
      {super.key,
      required this.controller,
      required this.obscureText,
      required this.setParams,
      required this.labelText,
      required this.errorText,
      required this.iconsSuffix});

  @override
  Widget build(BuildContext context) {
    double mWidth = MediaQuery.of(context).size.width;
    double mHeight = MediaQuery.of(context).size.height;

    return SizedBox(
        width: mWidth * 0.8,
        height: mHeight * 0.1,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          obscureText: obscureText ?? false,
          onChanged: setParams,
          decoration: InputDecoration(
            labelText: labelText,
            errorText: errorText,
            suffixIcon: iconsSuffix,
            alignLabelWithHint: false,
          ),
        ));
  }
}
