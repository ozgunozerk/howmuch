import 'package:flutter/material.dart';

import 'package:how_much/presentation/ui/colours.dart';

class InnerBottomDialogModal extends StatelessWidget {
  final bool cancellable;
  final Widget content;

  const InnerBottomDialogModal(
      {required this.cancellable, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Commented out part is the drag handle for the bottom sheet modal.
        // It looks nice, but probably contradicts with the design here.
        // This shouldn't be draggable
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Align(
        //     alignment: Alignment.topCenter,
        //     child: Container(
        //       height: 4.0,
        //       width: 60.0,
        //       decoration: BoxDecoration(
        //           color: howLightGrey,
        //           borderRadius: BorderRadius.circular(10.0)),
        //     ),
        //   ),
        // ),
        if (cancellable)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: howBlack))
            ],
          ),
        content,
      ],
    );
  }
}
