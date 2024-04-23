


import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  const Button({ super.key, this.onClick, this.child, this.important = false, this.width = double.infinity });

  final bool important;
  final Function? onClick; 
  final Widget? child; 
  final double width; 

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick,
      borderRadius: BorderRadius.circular(100),
      child: Ink(
        decoration: BoxDecoration(
          color: important ? const Color(0xFF19c37d) : Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Center(child: child)
        )
      )
    );
  }
}