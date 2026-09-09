import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,

  });

  @override
  Widget build(BuildContext context){
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: Colors.black,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 5),
          Text(
            label, style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          ),
        ],
      ),
    );
  }
}