import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final continueWithGoogle = FlutterI18n.translate(
      context,
      'continue_with_google',
    );

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFdadce0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: Image.asset(
              'assets/icons/google.png', // Ensure this asset exists in your project
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            continueWithGoogle,
            style: const TextStyle(
              color: Color(0xFF3c4043),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
