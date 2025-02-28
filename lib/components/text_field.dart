import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry contentPadding;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isValid;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 12.0),
    this.controller,
    this.onChanged,
    this.errorText,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;
    Color labelColor = Colors.black;

    if (controller != null && controller!.text.isNotEmpty) {
      if (errorText != null && !isValid) {
        borderColor = Colors.red;
        labelColor = Colors.red;
      } else {
        borderColor = Colors.green;
        labelColor = Colors.green;
      }
    } else {
      borderColor = Colors.black;
      labelColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
              contentPadding: contentPadding,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
          if (errorText != null &&
              controller != null &&
              controller!.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
