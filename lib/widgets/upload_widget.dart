import 'package:flutter/material.dart';

class UploadWidget extends StatelessWidget {
  const UploadWidget({super.key, this.fileName, required this.onPressed});
  final String? fileName;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(fileName == null ? Icons.upload : Icons.cancel),
      label: Text(fileName ?? "Upload file"),
      onPressed: onPressed,
    );
  }
}
