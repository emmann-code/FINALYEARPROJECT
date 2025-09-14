import 'package:flutter/material.dart';
class MyDrawerTile extends StatelessWidget {
  final String text;
  final IconData? icon;
  final void Function()? onTap;
  const MyDrawerTile({super.key,
    required this.text, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: ListTile(
        title: Text(text,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,fontSize: 13),),
        leading: Icon(icon,color: Theme.of(context).colorScheme.inversePrimary,),
        onTap: onTap,
      ),
    );
  }
}
