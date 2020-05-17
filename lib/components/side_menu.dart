import 'package:flutter/material.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/lessons_list_screen.dart';

class SideMenu extends StatelessWidget {
  final AuthService _auth=AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              ''
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/img.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Create Lesson'),
            onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => LessonsListScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap : ()async {
              await _auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(emailReset: "",)));
            }
          ),
      ],
      ),
    );
  }
}
