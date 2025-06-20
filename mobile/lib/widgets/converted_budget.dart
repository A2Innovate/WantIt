import 'package:flutter/material.dart';

import '../utils/global.dart';

class ConvertedBudgetText extends StatelessWidget {
  final double budget;
  final Currency baseCurrency;
  final Future<(Currency, double)?> future;

  const ConvertedBudgetText({
    super.key,
    required this.budget,
    required this.baseCurrency,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Currency, double)?>(
      future: future,
      builder: (context, snapshot) {
        final baseText = formatCurrency(budget, baseCurrency);
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            !snapshot.hasData) {
          return Text(baseText);
        }

        final (convertedCurrency, convertedAmount) = snapshot.data!;
        return RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              TextSpan(
                text: baseText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    ' (≈ ${formatCurrency(convertedAmount, convertedCurrency)})',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
