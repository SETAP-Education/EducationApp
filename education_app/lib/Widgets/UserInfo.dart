

import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {

  UserInfo({ super.key });

   @override
  State<UserInfo> createState() => UserInfoState(); 
}

class UserInfoState extends State<UserInfo> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          
        ],
      )
    );
  }
}