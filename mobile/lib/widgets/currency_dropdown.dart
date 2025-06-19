import 'package:flutter/material.dart';

import '../utils/global.dart';

class CurrencyDropdown extends StatelessWidget {
  final Currency? selectedCurrency;
  final String? errorText;
  final ValueChanged<Currency?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Currency>(
      value: selectedCurrency,
      decoration: InputDecoration(errorText: errorText),
      items: Currency.values.map((currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: Row(
            children: [
              Text(
                currency.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(currency.name),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return Currency.values.map((entry) {
          return Text(
            entry.symbol,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }).toList();
      },
      onChanged: onChanged,
    );
  }
}
