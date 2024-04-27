


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabBarCustom extends StatefulWidget {

  TabBarCustom({ super.key, required this.options, this.onChange });

  final List<String> options; 
  Function(String)? onChange; 

  @override
  State<TabBarCustom> createState() => TabBarCustomState(); 
}

class TabBarCustomState extends State<TabBarCustom> {

  String selected = "";

  @override void initState() {
    selected = widget.options[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int idx = 0; idx < widget.options.length; idx++)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = widget.options[idx];
                  });
                },
                child:  Column(
                  children: [ 
                    Text(widget.options[idx], style: GoogleFonts.nunito(
                      fontSize: 18, 
                      color: selected == widget.options[idx] ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: selected == widget.options[idx] ? FontWeight.bold : FontWeight.normal
                    )),

                    const SizedBox(height: 6.0),

                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: selected == widget.options[idx] ? Theme.of(context).colorScheme.primary : Colors.transparent
                      ),
                    )
                    
                  ]
                )
              )
            )
        ]
      )
    );
  }
}