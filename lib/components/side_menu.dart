import 'package:flutter/material.dart';
import 'package:temp_project/database/auth.dart';
import 'package:temp_project/screens/LoginScreen.dart';
import 'package:temp_project/screens/about_us_screen.dart';
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
            child: Container(
              child: Column(
                children: <Widget>[
                  Material(
                    borderRadius:BorderRadius.all(Radius.circular(50.0)),
                    elevation: 10.0,
                    child:Padding(padding: EdgeInsets.all(11.0),
                    child: Image.asset('images/logo2.jpg',width: 55.0,height: 55.0,),),
                  ),
                  Text("Learn With Movies",style: TextStyle(color:Colors.white,fontSize: 25.0),)
                ],
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.indigo,
                  Colors.blueAccent
                ]
              ),
            )

          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Create Lesson'),
            onTap: ()async{
              await Navigator.push(context, MaterialPageRoute(builder: (context) => LessonsListScreen()));
            Navigator.pop(context);
            },
          ),
          ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Us'),
              onTap : ()async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUs()));
                Navigator.pop(context);

              }
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
