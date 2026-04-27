import 'package:flutter/material.dart';

class KeyboardBottomPadding extends StatelessWidget {
  final Widget child;

  const KeyboardBottomPadding({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // This widget isolates MediaQuery listener so the entire form tree 
    // doesn't rebuild continuously during keyboard pop-up animation.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}
