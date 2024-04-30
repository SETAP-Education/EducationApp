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
      onTap: () => {
        if (onClick != null) {
          onClick!() 
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: important ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
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