import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/widgets/ui_utils.dart';

import 'languages.dart';

class WarningDialog extends StatelessWidget {
  const WarningDialog({super.key, required this.title, required this.subtitle, required this.onYesPressed, required this.onNoPressed,});

  final String title;
  final String subtitle;
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: size.width*0.8,
        height: size.height*0.2,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: td.colorScheme.primary,
            width: 1.5,
          ),
          boxShadow: [UiUtils.widgetsShadow(5, 80, td)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: td.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width*0.09),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.lerp(td.colorScheme.primary, td.colorScheme.onSurfaceVariant, 0.2)!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onYesPressed,
                        child: Text(
                          Languages.yes.getString(context),
                          style: TextStyle(
                            color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width*0.09),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.lerp(td.colorScheme.primary, td.colorScheme.onSurfaceVariant, 0.2)!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onNoPressed,
                        child: Text(
                          Languages.no.getString(context),
                          style: TextStyle(
                            color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}