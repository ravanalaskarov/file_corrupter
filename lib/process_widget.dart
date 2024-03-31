import 'package:flutter/material.dart';

class ProcessWidget extends StatelessWidget {
  const ProcessWidget({super.key, required this.process});
  final int process;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(value: process.toDouble()),
        ),
        SizedBox(
          width: 50,
          child: Text("$process%", textAlign: TextAlign.right,),
        ),
      ],
    );
  }
}
