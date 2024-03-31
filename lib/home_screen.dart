import 'dart:io';
import 'dart:math';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_corrupter/action_widget.dart';
import 'package:file_corrupter/process_widget.dart';
import 'package:file_corrupter/upload_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum FileActions { corrupt, processing, download }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? originalFile;
  String? fileName;
  String? fileExtension;
  final randomObject = Random();
  File? corruptedFile;

  int corruptProcess = 0;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        originalFile = File(result.files.single.path!);
        fileName = file.name;
        fileExtension = file.extension;
      });
    }
  }

  void dismissFile() {
    setState(() {
      originalFile = null;
      fileName = null;
      fileExtension = null;
      corruptProcess = 0;
      corruptedFile = null;
    });
  }

  void createCorruptedFile() async {
    final cacheDir = await getTemporaryDirectory();
    final filePath = '${cacheDir.path}/${fileName!}.${fileExtension!}';
    corruptedFile = File(filePath);

    try {
      final originalAccessFile = await originalFile!.open();

      final sink = corruptedFile!.openWrite();

      final length = await originalAccessFile.length();

      for (int i = 0; i < length; i++) {
        sink.add([randomObject.nextInt(256)]);

        setState(() {
          corruptProcess = ((i * 100) / length).round();
        });
      }

      await originalAccessFile.close();

      await sink.close();
    } catch (_) {}
  }

  void saveCorruptedFile() async {
    bool? success = await copyFileIntoDownloadFolder(corruptedFile!.path, '${fileName!}.${fileExtension!}');
    if (success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved successfully.'),
          )
        );
      }
    }
    else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save the file.'),
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    FileActions fileAction = FileActions.processing;

    if (corruptProcess == 0 && originalFile != null) {
      fileAction = FileActions.corrupt;
    } else if (corruptProcess == 100 && corruptedFile != null) {
      fileAction = FileActions.download;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("File Corrupter"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
                "Note: This process will only create a corrupted copy of the file.\nThis process will not corrupt the original file."),
            const SizedBox(
              height: 40,
            ),
            UploadWidget(
                fileName: fileName,
                onPressed: originalFile == null ? pickFile : dismissFile),
            const Spacer(),
            if (originalFile != null) ProcessWidget(process: corruptProcess),
            const SizedBox(
              height: 40,
            ),
            ActionWidget(
              action: fileAction,
              onPressed: fileAction == FileActions.processing
                  ? null
                  : (fileAction == FileActions.corrupt
                      ? createCorruptedFile
                      : saveCorruptedFile),
            ),
            const SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }
}
