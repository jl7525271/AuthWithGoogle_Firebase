import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String textButton;
  final void Function()? onPressed;

  const CustomButton({super.key, required this.textButton, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          backgroundColor: MaterialStatePropertyAll(Colors.purple),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)))
        ),
        child: Text(textButton, style: const TextStyle(fontSize: 16)),
    );
  }
}

