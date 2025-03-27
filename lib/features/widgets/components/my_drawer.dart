import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(elevation: 4, width: 250,
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      child: Column(
        children: [
          SizedBox(height: 35,),
          Padding(padding: EdgeInsets.all(5),child: Divider(
            // color: Theme.of(context).colorScheme.secondary,
          ),),
          // app logo
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:  NetworkImage(
                    'https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg?w=740',
                  ),
                ),
              ),
              Text('Gbesan Emm',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color:  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          // themetoggle(),
          Padding(padding: EdgeInsets.all(5),child: Divider(
          ),),

          // home list tile
          MyDrawerTile(text: 'H O M E',
            onTap: (){},
            icon: Icons.home,
          ),
          // blog
          MyDrawerTile(text: 'B L O G',
            onTap: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => Blog()));
            },
            icon: Icons.newspaper_sharp,
          ),
          // notifications
          MyDrawerTile(text: 'N O T I F I C A T I O N S ',
            onTap: (){},
            icon: Icons.notification_add,
          ),
          // insights
          MyDrawerTile(text: 'I N S I G H T S',
            onTap: (){},
            icon: Icons.trending_up,
          ),
          MyDrawerTile(
            text: 'S C A N  M E',
            onTap: (){},
            icon: Icons.qr_code
          )
        ],
      ),
    );
  }
}
