import 'dart:io';
import 'package:auth_with_google/models/user_model.dart';
import 'package:auth_with_google/pages/home_page.dart';
import 'package:auth_with_google/provider/auth_provider.dart';
import 'package:auth_with_google/widgets/image_picker.dart';
import 'package:auth_with_google/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_button.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  //For Selecting image
  void   selectImage () async {
    image = await pickImage(context);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context,listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading ==  true
          ? Center(child: CircularProgressIndicator(color: Colors.purple),)
          : SingleChildScrollView(
          padding: EdgeInsets.only(top: 15, bottom: 35, left: 5, right: 5),
          child: Center(
            child: Column(
              children: [
                _imageProfile(),
                _textFieldsForm(),
                SizedBox(height: 20,),
                _buttonContinue(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageProfile() {
    return InkWell(
        onTap: () {
          selectImage();
        },
        child: image == null
            ? const CircleAvatar(
          backgroundColor: Colors.purple,
          radius: 50,
          child: Icon(
            Icons.account_circle,
            size: 50,
            color: Colors.white,
          ),
        )
            : CircleAvatar(
          backgroundImage: FileImage(image!),
          radius: 50,
        )
    );
  }

  Widget _textFieldsForm() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          //name fiel
          _textFielGeneral(
              hintText: 'Jhon Smith',
              iconData: Icons.account_circle,
              inputType: TextInputType.name,
              maxLines: 1,
              controller: nameController),
          //email
          _textFielGeneral(
              hintText: 'example@example.com',
              iconData: Icons.email,
              inputType: TextInputType.emailAddress,
              maxLines: 1,
              controller: emailController),
          //bio
          _textFielGeneral(
              hintText: 'Enter your bio here...',
              iconData: Icons.edit,
              inputType: TextInputType.name,
              maxLines: 2,
              controller: bioController)
        ],
      ),
    );
  }

  Widget _textFielGeneral({
    required String hintText,
    required IconData iconData,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.purple,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.purple
            ),
            child: Icon(
              iconData,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Colors.transparent
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Colors.transparent
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.purple.shade50,
          filled: true,
        ),

      ),
    );
  }

  Widget _buttonContinue() {
    return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.80,
            height: 45,
            child: CustomButton(
              textButton: 'Continue',
              onPressed: () {
                storeDataWithPhone();
              },
            ),
          ),
        ]
    );
  }


  //STORE  THE DATA
  void storeDataWithPhone () async {
    final ap = Provider.of <AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        bio: bioController.text.trim(),
        profilePic: '',
        createdAt: '',
        phoneNumber: '',
        uid: ""
    );
    if(image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: (){
         // change when data is save
          ap.saveUserDataToSP().then((value) => ap.setSignIn().then((value)
          => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false)));
        });

    }else{
      showSnackBar(context, 'Please upload your profile photo');
    }
  }
}