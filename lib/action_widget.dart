import 'package:file_corrupter/home_screen.dart';
import 'package:flutter/material.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({super.key, required this.action, required this.onPressed});
  final FileActions action;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(action == FileActions.download ? Icons.save : Icons.insert_page_break),
      label: Text(action == FileActions.download ? "Save corrupted file" : "Corrupt file!") ,
      onPressed: onPressed,
    );
  }
}
