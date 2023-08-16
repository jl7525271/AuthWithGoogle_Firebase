import 'package:auth_with_google/pages/login_pages.dart';
import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:auth_with_google/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class WelcomeHomePage extends StatefulWidget {
  const WelcomeHomePage({super.key});

  @override
  State<WelcomeHomePage> createState() => _WelcomeHomePageState();
}

class _WelcomeHomePageState extends State<WelcomeHomePage> {
  @override
  Widget build(BuildContext context) {
    final ap= Provider.of<AuthProvider> (context, listen: true ); // PROBAR CON TRUE

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal:35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/image1.png'),
               const SizedBox(height: 20),
               const Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
               Text(
                  'Never a better time than now to start',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold
                  ),
                ),
                // ADD CUSTOM BUTTON
                SizedBox(height: 25,),
                SizedBox(width: double.infinity,),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: () async {
                      if(ap.isSignedIn == true ){

                        await ap.getDataFromSP().whenComplete(() =>
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()))
                        );
                      } else  {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      }
                    },
                    textButton: 'Get Started',
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}
