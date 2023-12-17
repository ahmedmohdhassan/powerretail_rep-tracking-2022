import 'package:flutter/material.dart';

class LogInButton extends StatelessWidget {
  const LogInButton({
    Key? key,
    required this.text,
    required this.onTap,
    required this.color,
    this.icon,
  }) : super(key: key);
  final VoidCallback onTap;
  final String text;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 50),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
