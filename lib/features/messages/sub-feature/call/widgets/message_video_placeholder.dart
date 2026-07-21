import 'package:flutter/material.dart';

class MessageVideoPlaceholder
    extends StatelessWidget {
  const MessageVideoPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF405A52),
              Color(0xFF263F37),
              Color(0xFF142A23),
            ],
          ),
        ),
      ),
    );
  }
}