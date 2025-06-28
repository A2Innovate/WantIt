import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class LocalGlobalToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  @override
  _LocalGlobalToggleState createState() => _LocalGlobalToggleState();
  const LocalGlobalToggle({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });
}

class _LocalGlobalToggleState extends State<LocalGlobalToggle> {
  late bool isGlobal;

  @override
  void initState() {
    super.initState();
    isGlobal = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: isGlobal ? Colors.grey : Colors.blue,
            ),
            SizedBox(width: 4),
            Text(
              appLocalizations.location_local,
              style: TextStyle(
                color: isGlobal ? Colors.black : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
        Switch(
          value: isGlobal,
          onChanged: (value) {
            setState(() {
              isGlobal = value;
            });
            widget.onChanged(value);
          },
          activeColor: Colors.white,
          activeTrackColor: Colors.grey,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade800,
        ),
        SizedBox(width: 8),
        Row(
          children: [
            Text(
              appLocalizations.location_global,
              style: TextStyle(
                color: isGlobal ? Colors.blue : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.public, color: isGlobal ? Colors.blue : Colors.grey),
          ],
        ),
      ],
    );
  }
}
