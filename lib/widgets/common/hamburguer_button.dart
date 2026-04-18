import 'package:flutter/material.dart';

class HamburguerButton extends StatelessWidget {
  final double top;
  final double left;

  const HamburguerButton({
    super.key,
    required this.top,
    required this.left
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: SafeArea(
        child: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () {Scaffold.of(context).openDrawer();},
          ),
        ),
      ),
    );
  }
}