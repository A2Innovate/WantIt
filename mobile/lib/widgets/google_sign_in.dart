import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final localizedStrings = AppLocalizations.of(context)!;
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
          // Google Icon SVG-like
          SizedBox(
            height: 18,
            width: 18,
            child: Image.asset(
              'assets/icons/google.png', // Make sure this exists
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            localizedStrings.continue_with_google,
            style: TextStyle(
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
