
import 'package:auth_with_google/pages/welcome_home_page.dart';
import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final isSignedWithEmail = Provider.of<AuthProvider>(context,listen: false).isSignedWithEmail;
    return Scaffold(
      appBar: isSignedWithEmail == true
         ? AppBar(
        backgroundColor:  Colors.purple,
        title: Text('Flutter email Auth'),
          actions: [
            IconButton(
              onPressed: (){
                singOutWithGoogle();
                Navigator.push (context, MaterialPageRoute(builder: (context) => WelcomeHomePage()));
              },
              icon: Icon(FontAwesomeIcons.doorOpen),
            ),
        ])
        : AppBar(
          backgroundColor:  Colors.purple,
          title: Text('Flutter phone Auth'),
          actions: [
            IconButton(onPressed: ()  {
              ap.userSignOut().then((value) => Navigator.push (context, MaterialPageRoute(builder: (context) => WelcomeHomePage())));
              },
                icon: Icon(Icons.exit_to_app)),
          ]
      ),

      body: isSignedWithEmail == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    backgroundImage: NetworkImage(ap.userModel.profilePic),
                    radius: 50,
                  ),
                  SizedBox(height: 20,),
                  Text(ap.userModel.name),
                  Text(ap.userModel.phoneNumber!),
                  Text(ap.userModel.email),
                  Text(ap.userModel.bio!),
                ],
              ),
            )
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  backgroundImage: NetworkImage(ap.userModel.profilePic),
                  radius: 50,
                ),
                SizedBox(height: 20,),
                Text(ap.userModel.name),
                Text(ap.userModel.phoneNumber!),
                Text(ap.userModel.email),
                Text(ap.userModel.bio!),
              ],
            ),
      )
    );
  }


  void singOutWithGoogle () {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.signOutWithGoogle();
  }
}
