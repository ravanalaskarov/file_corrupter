import 'dart:io';
import 'dart:math';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_corrupter/widgets/upload_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum FileActions { corrupt, processing, download }

List<int> corruptBytes(Map<String, dynamic> data) {
  List<int> fileBytes = data['fileBytes'];
  int tenPercentageOfBytes = data['tenPercentageOfBytes'];

  final randomObject = Random();

  for (int i = 0; i < tenPercentageOfBytes; i++) {
    fileBytes[randomObject.nextInt(fileBytes.length)] =
        randomObject.nextInt(256);
  }

  return fileBytes;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? _originalFile;
  Future<String?>? _corruptFileIsolate;
  var _corrupting = false;


  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _originalFile = result.files.first;
      });
    }
  }

  void _dismissFile() {
    setState(() {
      _originalFile = null;
      _corrupting = false;
      _corruptFileIsolate = Future.value(null);
    });
  }

  Future<String> _createCorruptedFile() async {
    final cacheDir = await getTemporaryDirectory();
    final corruptedFilePath = '${cacheDir.path}/${_originalFile!.name}';
    final corruptedFile =
        await File(_originalFile!.path!).copy(corruptedFilePath);
    final fileBytes = await corruptedFile.readAsBytes();
    final tenPercentageOfBytes = (fileBytes.length * 0.1).toInt();

    final List<int> corruptedBytes = await compute(
      corruptBytes,
      {
        'fileBytes': fileBytes,
        'tenPercentageOfBytes': tenPercentageOfBytes,
      },
    );

    await corruptedFile.writeAsBytes(corruptedBytes);

    return corruptedFilePath;
  }

  void saveCorruptedFile(final corruptedFilePath) async {
    bool? success = await copyFileIntoDownloadFolder(corruptedFilePath,
        '${_originalFile!.name}.${_originalFile!.extension}');
    if (success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File saved successfully.'),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save the file.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Corrupter"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
              "Note: This process will only create a corrupted copy of the file.\nThis process will not corrupt the original file.",
            ),
            const SizedBox(
              height: 40,
            ),
            FutureBuilder<String?>(
              future: _corruptFileIsolate,
              builder: (context, snapshot) {
                final corruptedFilePath = snapshot.data;

                Function()? actionButtonOnPressed;

                if (corruptedFilePath != null) {
                  actionButtonOnPressed = () {
                    saveCorruptedFile(corruptedFilePath);
                  };
                } else if (_originalFile != null) {
                  actionButtonOnPressed = () {
                    setState(() {
                      _corrupting = true;
                      _corruptFileIsolate = _createCorruptedFile();
                    });
                  };
                }

                return Expanded(
                  child: Column(
                    children: [
                      UploadWidget(
                        fileName: _originalFile?.name,
                        onPressed:
                            _originalFile == null ? _pickFile : _dismissFile,
                      ),
                      const Spacer(),
                      if (corruptedFilePath == null && _corrupting)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: LinearProgressIndicator(),
                        ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(corruptedFilePath == null
                            ? Icons.insert_page_break
                            : Icons.save),
                        label: Text(
                          corruptedFilePath == null
                              ? "Corrupt file"
                              : "Save corrupted file",
                        ),
                        onPressed: actionButtonOnPressed,
                      ),
                      const SizedBox(
                        height: 80,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
