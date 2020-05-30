import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Container(
        color: Colors.blue[50],
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(padding:EdgeInsets.all(16.0),child:Text("Thank you for choosing to learn with us! We are a group of three students and created this app as a part of our final project of our degree. The purpose of the app is to create a pleasant and sufficient way to learn English.",
            style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold),),),
            Center(child:Text("Problem or Question ? – let us know. Reach us at: learnwith@gmail.com",
              style: TextStyle(fontSize: 25.0),textAlign: TextAlign.center,
            ),),
          ],
        ),
      ),

    );
  }
}
