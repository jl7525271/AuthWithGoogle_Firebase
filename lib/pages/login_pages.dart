import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:auth_with_google/widgets/custom_button.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = new TextEditingController();
  Country selectedCountry = Country(
      phoneCode: '593',
      countryCode: 'EC',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'Ecuador',
      example: 'Ecuador',
      displayName: 'Ecuador',
      displayNameNoCountryCode: 'EC',
      e164Key: "",
  );
  var heigt;
  var width;

  @override
  Widget build(BuildContext context) {
    heigt = MediaQuery.sizeOf(context).height;
    width = MediaQuery.sizeOf(context).width;
    
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      )
    );
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,),
     body: SafeArea(
       child: Center(
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
                       SizedBox(height: 10),
                       _textFormField(),
                       SizedBox(height: 20),
                       _buttonRegister(),
                       SizedBox(height: 10),
                       _singnInWithGoogle(),
                     ],
                   ),
                 ],
               ),
         ),
       ),
     ),
    );
  }

  Widget _singnInWithGoogle(){
    return MaterialButton(
        splashColor: Colors.transparent,
        minWidth: double.infinity,
        height: heigt*0.055,
        color: Colors.grey[500],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.google, color: Colors.white,),
            SizedBox(width: 15),
            Text('Singn in with Google', style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
            )
          ],
        ),
        onPressed: () async {
          singWithGoogle();
          storeDataWithGoogle();
        }
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
      child: Image.asset('assets/img/image2.png'),
    );
  }

  Widget _textRegister() {
    return Container(
      child: Column(
        children: [
          const Text(
            "Register",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Add your phone number to register. \n"
                " We'll send a verification code",
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

  Widget _textFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: phoneController,
      cursorColor: Colors.purple,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold
      ),
      onChanged: (value) {
        setState(() {
          phoneController.text = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Enter phone number',
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500, 
          fontSize: 15, 
          color: Colors.grey.shade600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black12),
        ),
        prefixIcon: Container(
          padding: EdgeInsets.all(12.0),
          child: InkWell(
            onTap: (){
              showCountryPicker(
                  context: context,
                  countryListTheme: CountryListThemeData(
                    bottomSheetHeight: 450,
                  ),
                  onSelect: (value){
                    setState(() {
                      selectedCountry= value;
                    });
                  }
              );
            },
            child: Text('${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ), 
        suffixIcon: phoneController.text.length > 9
          ? Container(
          height: 30,
          width: 30,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(
            Icons.done, 
            color: Colors.white,
            size: 20,
          ),
        ) : null
      ),
    );
  }

  Widget _buttonRegister() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 45,
        child: CustomButton(
            textButton: 'Login',
            onPressed: (){
              sendPhoneNumber ();
            },
          ),
        ),
        SizedBox(height: 14),
        Text(
          'or',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        )
      ],
      );
  }

  void sendPhoneNumber () {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWhitPhone(context, '+${selectedCountry.phoneCode}${phoneNumber}');
  }

  void singWithGoogle () {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.signInWithGoogle(context);

  }
  void storeDataWithGoogle() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeDataWithGoogle(context);
  }






}
