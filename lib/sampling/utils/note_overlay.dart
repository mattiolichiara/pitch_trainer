import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../general/widgets/ui_utils.dart';

@pragma("vm:entry-point")
void overlayMain(String? payload) {
  WidgetsFlutterBinding.ensureInitialized();
  
  final Map<String, dynamic> args = payload != null ? jsonDecode(payload) : {};
  
  final String note = args['note'] ?? 'Default Note';

  runApp(NoteOverlay(note: note));
}

class NoteOverlay extends StatelessWidget {
  final String note;
  const NoteOverlay({super.key, required this.note});
  
  Widget _overlayContent(ThemeData td, Size size) {
    return Text(
      note,
      style: TextStyle(
        color: td.colorScheme.onSurface,
        fontSize: size.width * 0.35,
        shadows: [
          UiUtils.widgetsShadow(80, 20, td),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData td = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: td.colorScheme.surface,
        body: Center(
          child: _overlayContent(td, size),
        ),
      ),
    );
  }
}
