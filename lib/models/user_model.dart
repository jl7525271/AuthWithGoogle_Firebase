class UserModel {
 late String name;
 late String email;
 late String? bio;
 late String profilePic;
 late String createdAt;
 late String? phoneNumber;
 late String uid;


 UserModel({
  required this.name, // pairing with AuthEmail
  required this.email, // pairing with AuthEmail
  required this.bio,
  required this.profilePic, //pairing with AuthEmail
  required this.createdAt,
  required this.phoneNumber,
  required this.uid, //pairing with AuthEmail "id"
  });

 //FROM MAP
 factory UserModel.fromMap (Map<String, dynamic> map) {
   return UserModel(
       name: map['name'] ?? '',
       email:  map['email'] ?? '',
       bio:  map['bio'] ?? '',
       profilePic:  map['profilePic'] ?? '',
       createdAt:  map['createdAt'] ?? '',
       phoneNumber: map['phoneNumber'] ?? '',
       uid: map['uid'] ?? '',
   );
 }

 //TO MAP
  Map<String, dynamic> toMap() {
   return{
     "name": name,
     "email": email,
     "bio": bio,
     "profilePic":profilePic,
     "createdAt": createdAt,
     "phoneNumber": phoneNumber,
     "uid": uid,
   };
  }
}