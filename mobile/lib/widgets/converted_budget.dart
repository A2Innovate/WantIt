import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
    final locale = FlutterI18n.currentLocale(context);
    final theme = Theme.of(context);

    return FutureBuilder<(Currency, double)?>(
      future: future,
      builder: (context, snapshot) {
        final baseText = formatCurrency(
          budget,
          baseCurrency,
          locale: locale!.languageCode,
        );

        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            !snapshot.hasData) {
          return Text(
            baseText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          );
        }

        final (convertedCurrency, convertedAmount) = snapshot.data!;
        if (convertedCurrency != baseCurrency) {
          return RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: baseText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' (≈ ${formatCurrency(convertedAmount, convertedCurrency, locale: locale.languageCode)})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text(
            baseText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          );
        }
      },
    );
  }
}
