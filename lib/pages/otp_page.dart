import 'package:auth_with_google/pages/home_page.dart';
import 'package:auth_with_google/pages/user_information_page.dart';
import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:auth_with_google/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_button.dart';

class OtpPage extends StatefulWidget {

  final String verificationId;

  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String? otpCode;
  var heigt;
  var width;

  @override
  Widget build(BuildContext context) {
    heigt = MediaQuery.sizeOf(context).height;
    width = MediaQuery.sizeOf(context).width;
    final isLoading = Provider.of<AuthProvider>(context,listen: true).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SafeArea(
      child: isLoading == true
        ? Center(child: CircularProgressIndicator(color: Colors.purple),)
        : Center(
          child: Padding(
            padding: EdgeInsets.symmetric( horizontal:50),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _image(),
                    SizedBox(height: 15),
                    _textRegister(),
                    SizedBox(height: 20),
                    _pinPutOTP(),
                    SizedBox(height: 20),
                    _buttonRegister(),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _image() {
    return Container(
      width: width*0.50,
      height: heigt*0.30,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple[50],
      ),
      child: Image.asset('assets/img/image3.png'),
    );
  }

  Widget _textRegister() {
    return Container(
      child: Column(
        children: [
          const Text(
            "Verification",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Enter OTP send to your phone number",
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
        ],
      ),

    );
  }

  Widget _pinPutOTP() {
    return Pinput(
      length: 6,
      showCursor: true,
      autofocus: true,
      defaultPinTheme: PinTheme(
        width: width*0.10,
        height: heigt*0.065,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple.shade200),
        ),
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      onCompleted: (value) {
        setState(() {
          otpCode = value;
        });
      },

    );
  }

  Widget _buttonRegister() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 45,
          child: CustomButton(
            textButton: 'Verify',
            onPressed: (){
              if( otpCode != null ) {
                verifyOtpCode(context, otpCode!);
              }else {
                showSnackBar(context, 'Enter 6-Digit code');
              }
            },
          ),
        ),
        SizedBox(height: 20),
        Text(
            "Didn't recive any code?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
              fontWeight: FontWeight.bold
            ),
        ),
        SizedBox(height: 10),
        Text(
          "Resend code verification",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade600
          ),
        ),
      ],
    );
  }

  void verifyOtpCode (BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtpCode(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: (){
          //checking user exist
          ap.checkExistingUser().then(
          (value) async {
            if( value == true ) {
              //User exist en DB
              ap.getDataFromFirestore().then(
              (value) => ap.saveUserDataToSP(). then(
                (value) => ap.setSignIn().then(
                  (value) => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false),),),);

            }else{
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserInformationPage()), (route) => false);
            }
          });
        }
    );
  }

}
