import 'package:flutter/material.dart';

class Components {
  TextField returnTextField(TextEditingController controller,
      BuildContext context, bool obsecured, String hintText) {
    return TextField(
      controller: controller,
      cursorColor: Colors.red,
      keyboardType: TextInputType.emailAddress,
      obscureText: obsecured,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontSize: 14, color: Colors.white),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1))),
    );
  }

  Container mainButton(
      Size size, String title, BuildContext context, Color color) {
    return Container(
      alignment: Alignment.center,
      width: size.width * 0.8,
      height: 40,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
