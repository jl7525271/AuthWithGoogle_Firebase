import 'dart:convert';
import 'dart:io';
import 'package:auth_with_google/models/user_model.dart';
import 'package:auth_with_google/pages/otp_page.dart';
import 'package:auth_with_google/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart';

class AuthProvider extends ChangeNotifier{

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSignedWithEmail = false;
  bool get isSignedWithEmail => _isSignedWithEmail;
  String _uid ='';
  String get uid => _uid;
  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final  FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  final  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email',],);


  // ESTO HACE QUE SE VERIFIQUE SI YA HIZO EL SIGN IN
  // APENAS INICIE LA APLICACION Y SI ES TRUE, ENVIA A LA
  // PANTALLA DE HOME, SINO AL REGISTER
  AuthProvider () {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    _isSignedIn = sharedPref.getBool('is_signedin') ?? false;
    _isSignedWithEmail = sharedPref.getBool('isSignedInWithEmail') ?? false;
    notifyListeners();
  }

  Future setSignIn () async{
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }
  void signInWhitPhone (BuildContext context, String phoneNumber)  async {

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
            },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(verificationId: verificationId)));

          },
          codeAutoRetrievalTimeout: (verificationId){

          }
      );
       _isSignedWithEmail = false;
       notifyListeners();
    } on FirebaseAuthException catch(e){
      showSnackBar(context, e.message.toString());
    }
  }

  void verifyOtpCode ({
      required BuildContext context,
      required String verificationId,
      required String userOtp,
      required Function onSuccess,
      }) async {
      _isLoading = true;
      notifyListeners();

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: userOtp,
        );
      User? user = (await _firebaseAuth.signInWithCredential(credential)).user!;
      if(user != null ){
        //AQUI LLAMAMOS AL USER ID (UID) en desde firebase
        _uid = user.uid;
        onSuccess();

      }  _isLoading = false;
          notifyListeners();
      } on FirebaseAuthException catch(e){
        showSnackBar(context, e.message.toString());
      }
    }

    //DATA BASE OPERATIONS ON FIRE BASE
  Future <bool> checkExistingUser () async {
    DocumentSnapshot snapshot = await _firebaseFireStore.collection("user").doc(_uid).get();
    if(snapshot.exists){
      print('USER EXISTS');
      return true;
    } else {
      print('NEW USER');
      return false;
    }
  }

  void saveUserDataToFirebase({
  required BuildContext context,
  required UserModel userModel,
  required File profilePic,
  required Function onSuccess
  }) async {
    _isLoading = true;
    notifyListeners();
    try{
      //uploading image to firebase
      await storeFileToStorage(
          "profilePic/$_uid",
          profilePic,
      ).then((value) {
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.uid!;
      });
      _userModel = userModel;
      print('UserModelPhone: ${userModel.toMap()}');

      //uploading to db
      await _firebaseFireStore.collection("user").doc(_uid).set(userModel.toMap()).then((value) {
        onSuccess();
        _isLoading= false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e){
      showSnackBar(context, e.message.toString());
      _isLoading= false;
      notifyListeners();
    }
  }

  Future <String> storeFileToStorage(String ref, File file)  async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
   TaskSnapshot snapshot =  await uploadTask;
   String downloadUrl = await snapshot.ref.getDownloadURL();
   return downloadUrl;
  }

  Future getDataFromFirestore () async {
    await _firebaseFireStore.collection("user").doc(
      _firebaseAuth.currentUser!.uid!).get().then((DocumentSnapshot snapshot) {
       _userModel = UserModel(
         name: snapshot['name'] ?? '',
         email:  snapshot['email'] ?? '',
         bio:  snapshot['bio'] ?? '',
         profilePic:  snapshot['profilePic'] ?? '',
         createdAt:  snapshot['createdAt'] ?? '',
         phoneNumber: snapshot['phoneNumber'] ?? '',
         uid: snapshot['uid'] ?? '',
       );
       _uid = userModel.uid;
    });
  }

  //STORING LOCALLY DATA  WITH SHARED PREF
  Future saveUserDataToSP() async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    print('SP: ${userModel.toMap()}');
    await sharedPref.setString('user_model', jsonEncode(userModel.toMap()));
  }

  //Get data from shared pref
  Future getDataFromSP () async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String data = sharedPref.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn= false;
    notifyListeners();
    sharedPref.clear();
  }


   Future signInWithGoogle(BuildContext context) async {
    try{
      final account =  await _googleSignIn.signIn();
      // print('Account:  $account');
      final googleKeyId = await account!.authentication;
      // print('========ID======');
      // print(googleKeyId.idToken);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) => HomePage()), (route) => false);
      _isSignedWithEmail = true;
      notifyListeners();
      return account;

    }catch(e){
      print('Error en: $e');
      return null;
    }
  }

  Future<void> storeDataWithGoogle(BuildContext context) async {
    final account = await signInWithGoogle(context); // Espera el resultado de signInWithGoogle
    if (account != null) {
      // print('Account de store: ${account.toString()}');
      File image = File(account.photoUrl.toString().trim());
      // print('image: $image');

      UserModel userModel = UserModel(
          name: account.displayName.toString().trim(),
          email: account.email.toString().trim(),
          bio: 'Register with email',
          profilePic: account.photoUrl.toString().trim(),
          createdAt: DateTime.now().microsecondsSinceEpoch.toString(),
          phoneNumber:'+593 123456789',
          uid: account.id.toString().trim(),
      );
      _userModel = userModel;
      print(userModel.toMap());

      final SharedPreferences sharedPref = await SharedPreferences.getInstance();
      sharedPref.setBool("isSignedInWithEmail", true);
      _isSignedWithEmail = true;
      notifyListeners();
      try {
        _uid = account.id.toString().trim();
        //uploading to db
        await _firebaseFireStore.collection("user").doc(_uid).set(userModel.toMap()).then((value) {
          saveUserDataToSP().then((value) => setSignIn().then((value)
          => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false)));
          _isLoading= false;
          notifyListeners();
        });
      } on FirebaseAuthException catch (e){
        showSnackBar(context, e.message.toString());
        _isLoading= false;
        notifyListeners();
      }
    }
  }

  Future signOutWithGoogle () async {
    try{
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      final account =  await _googleSignIn.signOut();
      print('Account:  $account');
      _isSignedIn= false;
      _isSignedWithEmail = true;
      sharedPref.clear();
      notifyListeners();
      return account;

    }catch(e){
      print('Error en: $e');
      return null;
    }
  }

}