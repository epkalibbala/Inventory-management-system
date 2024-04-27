// import 'dart:io';
// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:Reacapp/models/all_uni.dart';
// import 'package:Reacapp/models/profile.dart';
// import 'package:Reacapp/models/todo.dart';
// import 'package:Reacapp/models/uni.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:rxdart/subjects.dart';
// import '../models/home_map.dart';
// import '../models/user.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:csv/csv.dart';

// mixin ConnectedHomesModel on Model {
//   List<HomeMap> _homes = [];
//   List<Todo> _comments = [];
//   List<Todo> _seen = [];
//   List<UniMap> _uni = [];
//   List<String> progies = [];
//   List<String> _progsCodes = [];
//   List<String> _progs = [];
//   List<Profile> _pfs = [];
//   List papers = [];
//   User _authenticatedUser;
//   AllUniMap _allUniMap;
//   Profile _authenticatedUserProfile;
//   bool _isLoading = false;
//   bool web = true;
//   bool ui = true;
//   //bool displayAll = true;
//   bool shake = false;
//   String _selHomeId;
//   String documentImage;
//   String textRecog = '';
//   int totalPaperContributions;
//   double progress;
//   String url;
//   bool validURL = false;
//   var filePath;
//   int _pf;
//   String imageProfile;
// }

// mixin HomesModel on ConnectedHomesModel {
//   bool _showStarred = false;
//   bool showFiltere = false;
//   String other;
//   String programmeCode;
//   String unicourse;
//   String universityfilt;
//   //String selectedCourse;

//   List<HomeMap> get allhomes {
//     return List.from(_homes);
//   }

//   List<Todo> get allcomments {
//     return List.from(_comments);
//   }

//   AllUniMap get allUni {
//     return _allUniMap;
//   }

//   List<Profile> get allprofiles {
//     return List.from(_pfs);
//   }

//   List<UniMap> get allprog {
//     return List.from(_uni);
//   }

//   List<HomeMap> get displayedHomes {
//     //HomeMap
//     if (_showStarred) {
//       return _homes.where((HomeMap home) => home.isFavorite).toList();
//     } else if (other != null) {
//       return _homes
//           .where((HomeMap home) =>
//               home.courseCode.toLowerCase().contains(other.toLowerCase()) ||
//               home.title.toLowerCase().contains(other.toLowerCase()))
//           .toList();
//     } else if (programmeCode != null) {
//       return _homes
//           .where((HomeMap home) =>
//               home.programme
//                   .toLowerCase()
//                   .contains(programmeCode.toLowerCase()) &&
//               home.university
//                   .toLowerCase()
//                   .contains(universityfilt.toLowerCase()))
//           .toList();
//     } else if (unicourse != null && unicourse != 'All') {
//       return _homes
//           .where((HomeMap home) =>
//               home.programme.toLowerCase().contains(unicourse.toLowerCase()))
//           .toList();
//     } else if (unicourse == 'All') {
//       return List.from(_homes);
//     }
//     return List.from(_homes);
//   }

//   /*List<String> get displayedprog {
//     if(prog != null){
//      return _progies.where((String home) => home.toLowerCase().contains(prog.toLowerCase())).toList();// || home.title.toLowerCase().contains(other.toLowerCase())).toList();
//     }
//     return List.from(_progies);
//   }*/

//   List<List<dynamic>> data = [];
//   //List<String> programme = [];

//   loadAsset() async {
//     final myData = await rootBundle.loadString(
//         "assets/worldUniversities.csv"); //loadString("assets/Book2.csv")
//     List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
//     data = csvTable;
//     for (int i = 0; i < data.length; i++) {
//       _progsCodes.add(data[i][1]);
//     }
//     for (int i = 0; i < data.length; i++) {
//       _progs.add(data[i][0]);
//     }
//   }

//   int get selectedHomeIndex {
//     return _homes.indexWhere((HomeMap home) {
//       return home.id == _selHomeId;
//     });
//   }

//   String get selectedHomeId {
//     return _selHomeId;
//   }

//   HomeMap get selectedHome {
//     if (selectedHomeId == null) {
//       return null;
//     }
//     return _homes.firstWhere((HomeMap home) {
//       return home.id == _selHomeId;
//     });
//   }

//   bool get displayFavsOnly {
//     return _showStarred;
//   }

//   kyusaToProfile() {
//     ui = false;
//     notifyListeners();
//   }

//   kyusaToGuidelines() {
//     web = true;
//     notifyListeners();
//   }

//   kyusaToPay() {
//     web = false;
//     notifyListeners();
//   }

//   kyusaToPapers() {
//     ui = true;
//     notifyListeners();
//   }

//   kyusaToShake() {
//     shake = false;
//     notifyListeners(); // tests whether profile was altered
//   }

//   kyusaToFilter() {
//     showFiltere = !showFiltere;
//     notifyListeners();
//   }

//   Future<Map<String, dynamic>> uploadImage(File image,
//       {String imagePath}) async {
//     _isLoading = true;
//     final mimeTypeData = lookupMimeType(image.path).split('/');
//     final imageUploadRequest = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'https://us-central1-college-fc02c.cloudfunctions.net/storeImage'));
//     final file = await http.MultipartFile.fromPath(
//       'image',
//       image.path,
//       contentType: MediaType(
//         mimeTypeData[0],
//         mimeTypeData[1],
//       ),
//     );
//     imageUploadRequest.files.add(file);
//     if (imagePath != null) {
//       imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
//     }
//     imageUploadRequest.headers['Authorization'] =
//         'Bearer ${_authenticatedUser.token}';

//     try {
//       final streamedResponse = await imageUploadRequest.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         //print('Something went wrong, ${_authenticatedUser.token}');
//         //print(json.decode(response.body));
//         return null;
//       }
//       final responseData = json.decode(response.body);
//       _isLoading = false;
//       notifyListeners();
//       return responseData;
//     } catch (error) {
//       //print(error);
//       _isLoading = false;
//       return null;
//     }
//   }

//   Future<bool> addUniv() async {
//     //String uni
//     _isLoading = true;
//     notifyListeners();

//     // final DateTime now = DateTime.now();
//     // final String joined = now.toIso8601String();

//     final Map<String, dynamic> uniData = {
//       //'dateOfUpload': joined,
//       //'university': uni,
//       'universiteis': _progsCodes,
//       'respCountries': _progs
//     };
//     try {
//       final http.Response response = await http.post(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/alluniversities.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(uniData));

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final AllUniMap newAllUni = AllUniMap(
//           id: responseData['name'],
//           // university: uni,
//           // dateOfUpload: joined,
//           allUni: _progsCodes,
//           respcCountries: _progs);
//       //_uni.add(newUni);
//       _allUniMap = newAllUni;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<Null> fetchUni({onlyForUser = false}) {
//     //_isLoading = true;
//     _uni = [];
//     progies = [];
//     notifyListeners();
//     return http
//         .get(Uri.parse(
//             'https://college-fc02c.firebaseio.com/universities.json?auth=${_authenticatedUser.token}'))
//         .then<Null>((http.Response response) {
//       final List<UniMap> fetchedUniList = [];
//       final Map<String, dynamic> uniListData = json.decode(response.body);
//       if (uniListData == null) {
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       uniListData.forEach((String uniId, dynamic uniData) {
//         final UniMap uni = UniMap(
//             id: uniId,
//             trustedContributionCut:
//                 int.parse(uniData['trustedContributionCut']),
//             document: uniData['coursesCodes'],
//             university: uniData['university'],
//             country: uniData['country'],
//             city: uniData['city'],
//             dateOfUpload: uniData['dateOfUpload'],
//             documentProg: uniData['courses']);
//         fetchedUniList.add(uni);
//         progies.add(uni.university);
//       });
//       /*_homes = onlyForUser ? fetchedHomeList.where((HomeMap home) {
//          return home.userId == _authenticatedUser.id; <========== In admin app will be used to extract where isFlagged is true;
//        }).toList() : fetchedHomeList;*/
//       _uni = fetchedUniList;
//       //progies.add('All');
//       //_isLoading = false;
//       notifyListeners();
//       _selHomeId = null;
//     }).catchError((error) {
//       //_isLoading = false;
//       notifyListeners();
//       return;
//     });
//   }

//   Future<bool> addHelp(
//       {String subject, String description, String feelings}) async {
//     _isLoading = true;
//     notifyListeners();

//     final DateTime now = DateTime.now();
//     final String dateSent = now.toIso8601String();

//     final Map<String, dynamic> homeData = {
//       'userName': _authenticatedUserProfile.userName,
//       'title': subject,
//       'feelings': feelings,
//       'university': _authenticatedUserProfile.university,
//       'yearOfStudy': _authenticatedUserProfile.yearOfStudy,
//       'programme': _authenticatedUserProfile.course,
//       'desription': description,
//       'userEmail': _authenticatedUser.email,
//       'userId': _authenticatedUser.id,
//       'profileId': _authenticatedUser.profileId,
//       'dateOfUpload': dateSent,
//       'profilePicOfUploader': _authenticatedUser.imageUrl
//     };
//     try {
//       final http.Response response = await http.post(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/help/${_authenticatedUserProfile.countryOfStudy}.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(homeData));

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         // print(response.statusCode.toString());
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> addHome(
//       {String userName,
//       String university,
//       String country,
//       String programme,
//       String yearOfStudy,
//       String textRecog,
//       String title,
//       String description,
//       String courseCode,
//       String imageUrlOfUploader}) async {
//     _isLoading = true;
//     notifyListeners();

//     final DateTime now = DateTime.now();
//     final String joined = now.toIso8601String();

//     final Map<String, dynamic> homeData = {
//       'userName': userName,
//       'document': papers,
//       'title': title,
//       'university': university,
//       'yearOfStudy': yearOfStudy,
//       'programme': programme,
//       'approval': 'approved',
//       'hide': 'false',
//       'textRecog': textRecog,
//       'desription': description,
//       'courseCode': courseCode,
//       'userEmail': _authenticatedUser.email,
//       'imageUrl': url,
//       'userId': _authenticatedUser.id,
//       'dateOfUpload': joined,
//       'profilePicOfUploader': imageUrlOfUploader
//     };
//     try {
//       final http.Response response = await http.post(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/papers/$country.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(homeData));

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         // print(response.statusCode.toString());
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final HomeMap newHome = HomeMap(
//           id: responseData['name'],
//           userName: userName,
//           document: papers,
//           image: url,
//           university: university,
//           programme: programme,
//           yearOfStudy: double.parse(yearOfStudy),
//           title: title,
//           description: description,
//           courseCode: courseCode,
//           userEmail: _authenticatedUser.email,
//           userId: _authenticatedUser.id,
//           dateOfUpload: joined,
//           picOfUploader: imageUrlOfUploader);
//       _homes.add(newHome);
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<Null> fetchHomes({onlyForUser = false}) {
//     _isLoading = true;
//     _homes = [];
//     notifyListeners();
//     return http
//         .get(Uri.parse(
//             'https://college-fc02c.firebaseio.com/papers/${_authenticatedUserProfile.countryOfStudy}.json?auth=${_authenticatedUser.token}'))
//         // 'https://college-fc02c.firebaseio.com/papers/UGANDA.json?auth=${_authenticatedUser.token}'))
//         .then<Null>((http.Response response) {
//       final List<HomeMap> fetchedHomeList = [];
//       final Map<String, dynamic> homeListData = json.decode(response.body);
//       if (homeListData == null) {
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       homeListData.forEach((String homeId, dynamic homeData) {
//         final HomeMap home = HomeMap(
//             id: homeId,
//             picOfUploader: homeData['profilePicOfUploader'],
//             userName: homeData['userName'], //-----> Name of Uploader
//             dateOfUpload: homeData['dateOfUpload'],
//             image: homeData[
//                 'imageUrl'], //------> to be displyed as card photo, not as photo of uploader
//             document: homeData['document'],
//             university: homeData['university'],
//             programme: homeData['programme'],
//             yearOfStudy: double.parse(homeData['yearOfStudy']),
//             title: homeData['title'],
//             description: homeData['description'],
//             courseCode: homeData['courseCode'],
//             userEmail: homeData['userEmail'],
//             userId: homeData['userId'],
//             isFavorite: homeData['wishlistUsers'] == null
//                 ? false
//                 : (homeData['wishlistUsers'] as Map<String, dynamic>)
//                     .containsKey(_authenticatedUser.id),
//             isFlagged: homeData['flaggingUsers'] == null
//                 ? false
//                 : (homeData['flaggingUsers'] as Map<String, dynamic>)
//                     .containsKey(_authenticatedUser.id));
//         fetchedHomeList.add(home);
//       });
//       totalPaperContributions = fetchedHomeList
//           .where((HomeMap home) {
//             return home.userId == _authenticatedUser.id;
//           })
//           .toList()
//           .length;
//       /*_homes = onlyForUser ? fetchedHomeList.where((HomeMap home) {
//          return home.userId == _authenticatedUser.id; <========== In admin app will be used to extract where isFlagged is true;
//        }).toList() : fetchedHomeList;*/
//       _homes = fetchedHomeList.reversed.toList();
//       _isLoading = false;
//       notifyListeners();
//       _selHomeId = null;
//     }).catchError((error) {
//       _isLoading = false;
//       notifyListeners();
//       return;
//     });
//   }

//   Future<Null> fetchComments({onlyForUser = true}) {
//     //print('mukene one');
//     //_isLoading = true;
//     String id = _authenticatedUser.id;
//     _seen = [];
//     _comments = [];
//     notifyListeners();
//     return http
//         .get(Uri.parse(
//             'https://college-fc02c.firebaseio.com/comments.json?orderBy="userId"&equalTo="$id"&auth=${_authenticatedUser.token}')) //orderBy="userId"&equalTo="${_authenticatedUser.id}"
//         .then<Null>((http.Response response) {
//       final List<Todo> fetchedCommentsList = [];
//       final Map<String, dynamic> commentListData = json.decode(response.body);
//       if (commentListData == null) {
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       commentListData.forEach((String commentId, dynamic commentData) {
//         final Todo comment = Todo(
//           userId: commentData["userId"],
//           profileId: commentData["profileId"],
//           subject: commentData["subject"],
//           paperId: commentData["paperId"],
//           dateOfComment: commentData["dateOfComment"],
//           seen: commentData['seen'],
//           question: commentData["question"],
//           value: commentData["value"],
//           stars: commentData["stars"],
//           starCount: commentData["starCount"],
//         );
//         fetchedCommentsList.add(comment);
//       });
//       _comments = onlyForUser
//           ? fetchedCommentsList
//               .where((Todo comment) =>
//                       comment.userId == //return
//                           _authenticatedUser.id &&
//                       comment.seen ==
//                           'unseen' //<========== In admin app will be used to extract where isFlagged is true;
//                   )
//               .toList()
//           : fetchedCommentsList;
//       //_seen.isNotEmpty ? _comments = _seen.where((Todo comment) => comment.seen == 'unseen').toList() : [];
//       //_homes = fetchedHomeList;
//       //_isLoading = false;
//       notifyListeners();
//       //_selHomeId = null;
//     }).catchError((error) {
//       _isLoading = false;
//       notifyListeners();
//       return;
//     });
//   }

//   void toggleHomeFlaggedStatus() async {
//     final bool isCurrentlyFa = selectedHome.isFlagged;
//     final bool newFlagStatus = !isCurrentlyFa;
//     final HomeMap updatedHome = HomeMap(
//         id: selectedHome.id,
//         image: selectedHome.image,
//         document: selectedHome.document,
//         title: selectedHome.title,
//         description: selectedHome.description,
//         courseCode: selectedHome.courseCode,
//         university: selectedHome.university,
//         programme: selectedHome.university,
//         yearOfStudy: selectedHome.yearOfStudy,
//         userName: selectedHome.userName,
//         dateOfUpload: selectedHome.dateOfUpload,
//         picOfUploader: selectedHome.picOfUploader,
//         userEmail: selectedHome.userEmail,
//         userId: selectedHome.userId,
//         isFavorite: selectedHome.isFavorite,
//         isFlagged: newFlagStatus);
//     _homes[selectedHomeIndex] = updatedHome;
//     //_selHomeIndex = null;
//     notifyListeners();
//     http.Response response;
//     if (newFlagStatus) {
//       response = await http.put(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/papers/${_authenticatedUserProfile.countryOfStudy}/${selectedHome.id}/flaggingUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(true));
//     } else {
//       response = await http.delete(Uri.parse(
//           'https://college-fc02c.firebaseio.com/papers/${_authenticatedUserProfile.countryOfStudy}/${selectedHome.id}/flaggingUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'));
//     }
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       final HomeMap updatedHome = HomeMap(
//           id: selectedHome.id,
//           image: selectedHome.image,
//           document: selectedHome.document,
//           title: selectedHome.title,
//           description: selectedHome.description,
//           courseCode: selectedHome.courseCode,
//           userName: selectedHome.userName,
//           university: selectedHome.university,
//           programme: selectedHome.university,
//           yearOfStudy: selectedHome.yearOfStudy,
//           dateOfUpload: selectedHome.dateOfUpload,
//           picOfUploader: selectedHome.picOfUploader,
//           userEmail: selectedHome.userEmail,
//           userId: selectedHome.userId,
//           isFavorite: selectedHome.isFavorite,
//           isFlagged: !newFlagStatus);
//       _homes[selectedHomeIndex] = updatedHome;
//       //_selHomeIndex = null;
//       notifyListeners();
//     }
//   }

//   void toggleHomeFavStatus() async {
//     final bool isCurrentlyFav = selectedHome.isFavorite;
//     final bool newFavStatus = !isCurrentlyFav;
//     final HomeMap updatedHome = HomeMap(
//         id: selectedHome.id,
//         image: selectedHome.image,
//         document: selectedHome.document,
//         title: selectedHome.title,
//         description: selectedHome.description,
//         courseCode: selectedHome.courseCode,
//         userName: selectedHome.userName,
//         university: selectedHome.university,
//         programme: selectedHome.university,
//         yearOfStudy: selectedHome.yearOfStudy,
//         dateOfUpload: selectedHome.dateOfUpload,
//         picOfUploader: selectedHome.picOfUploader,
//         userEmail: selectedHome.userEmail,
//         userId: selectedHome.userId,
//         isFavorite: newFavStatus,
//         isFlagged: selectedHome.isFlagged);
//     _homes[selectedHomeIndex] = updatedHome;
//     //_selHomeIndex = null;
//     notifyListeners();
//     http.Response response;
//     if (newFavStatus) {
//       response = await http.put(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/papers/${_authenticatedUserProfile.countryOfStudy}/${selectedHome.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(true));
//     } else {
//       response = await http.delete(Uri.parse(
//           'https://college-fc02c.firebaseio.com/papers/${_authenticatedUserProfile.countryOfStudy}/${selectedHome.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'));
//     }
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       final HomeMap updatedHome = HomeMap(
//           id: selectedHome.id,
//           image: selectedHome.image,
//           document: selectedHome.document,
//           title: selectedHome.title,
//           description: selectedHome.description,
//           courseCode: selectedHome.courseCode,
//           userName: selectedHome.userName,
//           university: selectedHome.university,
//           programme: selectedHome.university,
//           yearOfStudy: selectedHome.yearOfStudy,
//           dateOfUpload: selectedHome.dateOfUpload,
//           picOfUploader: selectedHome.picOfUploader,
//           userEmail: selectedHome.userEmail,
//           userId: selectedHome.userId,
//           isFavorite: !newFavStatus,
//           isFlagged: selectedHome.isFlagged);
//       _homes[selectedHomeIndex] = updatedHome;
//       //_selHomeIndex = null;
//       notifyListeners();
//     }
//   }

//   void selectHome(String homeId) {
//     _selHomeId = homeId;
//     if (homeId != null) {
//       notifyListeners();
//     }
//   }

//   void toggleDisplayMode() {
//     _showStarred = !_showStarred;
//     notifyListeners();
//   }

//   void toggleDisplayModeToFilter() {
//     notifyListeners();
//   }
// }

// mixin UserModel on ConnectedHomesModel {
//   Timer _authTimer;
//   String _password;
//   dynamic profileError;
//   PublishSubject<bool> _userSubject = PublishSubject();
//   User get user {
//     return _authenticatedUser;
//   }

//   final Map<String, dynamic> map = {
//     'imageUrl': null,
//     'gender': null,
//     'uid': null,
//     'email': null,
//     'accessLevel': 'wanaichi',
//     'userName': null,
//     'university': null,
//     'country': null,
//     'countryOfStudy': null,
//     'yearOfStudy': null,
//     'joined': null,
//     'course': null,
//     'lastName': null,
//     'firstName': null,
//     'phoneNumber': null
//   };

//   Profile get profile {
//     return _authenticatedUserProfile;
//   }

//   PublishSubject<bool> get userSubject {
//     return _userSubject;
//   }

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     _isLoading = true;
//     notifyListeners();
//     final Map<String, dynamic> authData = {
//       'email': email,
//       'password': password,
//       'returnSecureToken': true
//     };
//     try {
//       final http.Response response = await http.post(
//           Uri.parse(
//               'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyA_xooS8Td0YF66vwBlTW2WJfw4pYrg5is'),
//           body: json.encode(authData),
//           headers: {'Content-Type': 'application/json'});
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       bool hasError = true;
//       String message = 'Something went wrong.';
//       if (responseData.containsKey('idToken')) {
//         hasError = false;
//         message = 'Authentication succeeded!';
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         _authenticatedUser = User(
//           id: responseData['localId'],
//           email: email,
//           token: responseData['idToken'],
//         );
//         _authenticatedUserProfile = Profile(
//           id: responseData['localId'],
//           email: email,
//           status: 'active',
//           accessLevel: 'wanaichi',
//         );
//         setAuthTimeout(int.parse(responseData['expiresIn']));
//         _userSubject.add(true);
//         final DateTime now = DateTime.now();
//         final DateTime expiryTime =
//             now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//         prefs.setString('token', responseData['idToken']);
//         prefs.setString('userEmail', email);
//         prefs.setString('password', password);
//         prefs.setString('userId', responseData['localId']);
//         prefs.setString('expiryTime', expiryTime.toIso8601String());
//         // _authenticatedUserProfile = _pfs.firstWhere((Profile profile) {
//         //   return profile.email == _authenticatedUser.email;
//         // });

//         // prefs.setString('profileId', _authenticatedUserProfile.profileId);
//         // prefs.setString('userNm', _authenticatedUserProfile.userName);
//         // prefs.setString('profileImg', _authenticatedUserProfile.imageUrl);
//         // prefs.setString('university', _authenticatedUserProfile.university);
//         // prefs.setString('joined', _authenticatedUserProfile.joined);
//         // prefs.setString('yearOfStudy', _authenticatedUserProfile.yearOfStudy);
//         // prefs.setString('gender', _authenticatedUserProfile.gender);
//         // prefs.setString('country', _authenticatedUserProfile.country);
//         // prefs.setString('countryOfStudy', _authenticatedUserProfile.countryOfStudy);
//         // prefs.setString('firstName', _authenticatedUserProfile.firstName);
//         // prefs.setString('lastName', _authenticatedUserProfile.secondName);
//         // prefs.setString('course', _authenticatedUserProfile.course);
//         // prefs.setString('status', _authenticatedUserProfile.status);
//       } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
//         message = 'This email was not found.';
//       } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
//         message = 'The password was invalid.';
//       }
//       _isLoading = false;
//       notifyListeners();
//       return {'success': !hasError, 'message': message};
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return {'success': true, 'message': 'Something went wrong'};
//     }
//   }

//   Future<Map<String, dynamic>> signup(
//       String email, String password, String userNname) async {
//     _isLoading = true;
//     notifyListeners();
//     final Map<String, dynamic> authData = {
//       'email': email,
//       'password': password,
//       'returnSecureToken': true
//     };
//     try {
//       final http.Response response = await http.post(
//           Uri.parse(
//               'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyA_xooS8Td0YF66vwBlTW2WJfw4pYrg5is'),
//           body: json.encode(authData),
//           headers: {'Content-Type': 'application/json'});
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       bool hasError = true;
//       String message = 'Something went wrong.';
//       if (responseData.containsKey('idToken')) {
//         hasError = false;
//         message = 'Authentication succeeded!';
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         _authenticatedUser = User(
//           id: responseData['localId'],
//           email: email,
//           userName: userNname,
//           token: responseData['idToken'],
//         );
//         _password = password;
//         _authenticatedUserProfile = Profile(
//           id: responseData['localId'],
//           email: email,
//           status: 'active',
//           userName: userNname,
//           joined: DateTime.now().toIso8601String(),
//           accessLevel: 'wanaichi',
//         );
//         setAuthTimeout(int.parse(responseData['expiresIn']));
//         final DateTime now = DateTime.now();
//         final DateTime expiryTime =
//             now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//         _userSubject.add(true);
//         prefs.setString('token', responseData['idToken']);
//         prefs.setString('userEmail', email);
//         prefs.setString('password', password);
//         prefs.setString('userNm', userNname);
//         prefs.setString('userId', responseData['localId']);
//         prefs.setString('expiryTime', expiryTime.toIso8601String());
//       } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
//         message = 'This email already exists.';
//       }
//       _isLoading = false;
//       notifyListeners();
//       return {'success': !hasError, 'message': message};
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return {'success': true, 'message': 'fuck'};
//     }
//   }

//   void autoAuthenticate() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String token = prefs.getString('token');
//     final String expiryTimeString = prefs.getString('expiryTime');
//     if (token != null) {
//       final DateTime now = DateTime.now();
//       final parsedExpiryTime = DateTime.parse(expiryTimeString);
//       if (parsedExpiryTime.isBefore(now)) {
//         _authenticatedUser = null;
//         notifyListeners();
//         return;
//       }
//       final String userEmail = prefs.getString('userEmail') ?? '';
//       final String userId = prefs.getString('userId') ?? '';
//       final String profileId = prefs.getString('profileId') ?? '';
//       final String userName = prefs.getString('userNm') ?? '';
//       final String imageUrl = prefs.getString('profileImg') ?? '';
//       final String university = prefs.getString('university') ?? '';
//       final String joined = prefs.getString('joined') ?? '';
//       final String yearOfStudy = prefs.getString('yearOfStudy') ?? '';
//       final String gender = prefs.getString('gender') ?? '';
//       final String country = prefs.getString('country') ?? '';
//       final String countryOfStudy = prefs.getString('countryOfStudy') ?? '';
//       final String firstName = prefs.getString('firstName') ?? '';
//       final String secondName = prefs.getString('lastName') ?? '';
//       final String course = prefs.getString('course') ?? '';
//       final String phoneNumber = prefs.getString('phoneNumber') ?? '';
//       final String status = prefs.getString('status') ?? '';
//       final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
//       _authenticatedUser = User(id: userId, email: userEmail, token: token);
//       _authenticatedUserProfile = Profile(
//           countryOfStudy: countryOfStudy,
//           id: userId,
//           email: userEmail,
//           firstName: firstName,
//           secondName: secondName,
//           course: course,
//           phoneNo: phoneNumber,
//           status: status,
//           profileId: profileId,
//           userName: userName,
//           imageUrl: imageUrl,
//           university: university,
//           joined: joined,
//           yearOfStudy: yearOfStudy,
//           gender: gender,
//           accessLevel: 'wanaichi',
//           country: country);
//       _userSubject.add(true);
//       setAuthTimeout(tokenLifespan);
//       notifyListeners();
//     }
//   }

//   void logOut() async {
//     _authenticatedUser = null;
//     _authenticatedUserProfile = null;
//     ui = true;
//     _authTimer.cancel();
//     _userSubject.add(false);
//     _selHomeId = null;
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.remove('token');
//     //prefs.remove('userEmail');
//     prefs.remove('userId');
//     prefs.remove('profileId');
//     prefs.remove('userNm');
//     prefs.remove('profileImg');
//     prefs.remove('university');
//     prefs.remove('joined');
//     prefs.remove('yearOfStudy');
//     prefs.remove('gender');
//     prefs.remove('country');
//     prefs.remove('firstName');
//     prefs.remove('lastName');
//     prefs.remove('course');
//     prefs.remove('phoneNumber');
//     prefs.remove('status');
//   }

//   void setAuthTimeout(int time) {
//     _authTimer = Timer(Duration(seconds: time), logOut);
//   }

//   Future<Map<String, dynamic>> uploadImageProfile(File image,
//       {String imagePath}) async {
//     final mimeTypeData = lookupMimeType(image.path).split('/');
//     final imageUploadRequest = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//             'https://us-central1-college-fc02c.cloudfunctions.net/storeImage'));
//     final file = await http.MultipartFile.fromPath(
//       'image',
//       image.path,
//       contentType: MediaType(
//         mimeTypeData[0],
//         mimeTypeData[1],
//       ),
//     );
//     imageUploadRequest.files.add(file);
//     if (imagePath != null) {
//       imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
//     }
//     imageUploadRequest.headers['Authorization'] =
//         'Bearer ${_authenticatedUser.token}';

//     try {
//       final streamedResponse = await imageUploadRequest.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         return null;
//       }
//       final responseData = json.decode(response.body);
//       return responseData;
//     } catch (error) {
//       print(error);
//       return null;
//     }
//   }

//   Future<Null> addProfile() async {
//     _isLoading = true;
//     notifyListeners();

//     final DateTime now = DateTime.now();
//     final String joined = now.toIso8601String();

//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     final Map<String, dynamic> profileData = {
//       'uid': _authenticatedUser.id,
//       'email': _authenticatedUser.email,
//       'accessLevel': 'wanaichi',
//       'chances': '0',
//       'adminPoints': '0',
//       'password': _password,
//       'signUpDevice': 'android',
//       'userName': _authenticatedUser.userName,
//       'status': 'active',
//       'appleVersion': '1.0.0',
//       'androidVersion': '1.0.6',
//       'joined': joined
//     };
//     try {
//       final http.Response response = await http.put(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/profiles/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(profileData));

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         _isLoading = false;
//         notifyListeners();
//         return; // false
//       }
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       prefs.setString('profileId', responseData['name']);
//       prefs.setString('userNm', _authenticatedUser.userName);
//       _authenticatedUserProfile = Profile(
//         id: _authenticatedUser.id,
//         email: _authenticatedUser.email,
//         profileId: responseData['name'],
//         status: 'active',
//         adminPoints: '0',
//         chances: '0',
//         androidVersion: '1.0.7',
//         appleVersion: '1.0.0',
//         signUpDevice: 'android',
//         joined: joined,
//         userName: _authenticatedUser.userName,
//         accessLevel: 'wanaichi',
//       );
//       _isLoading = false;
//       notifyListeners();
//       return; // true
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return; // false
//     }
//   }

//   Future<Null> fetchProfiles() {
//     _pfs = [];
//     _isLoading = true;
//     notifyListeners();
//     return http
//         .get(Uri.parse(
//             'https://college-fc02c.firebaseio.com/profiles.json?auth=${_authenticatedUser.token}'))
//         .then<Null>((http.Response response) async {
//       final List<Profile> fetchedProfileList = [];
//       final Map<String, dynamic> profileListData = json.decode(response.body);
//       if (profileListData == null) {
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }
//       final SharedPreferences prefs = await SharedPreferences.getInstance();

//       profileListData.forEach((String profileId, dynamic profileData) {
//         // print('What the actual fuck4');
//         // print('What the actual fuck5');
//         // prefs.setString('profileId', profileId);
//         // prefs.setString('userNm', profileData['userName']);
//         // prefs.setString('profileImg', profileData['imageUrl']);
//         // prefs.setString('university', profileData['university']);
//         // prefs.setString('joined', profileData['joined']);
//         // prefs.setString('yearOfStudy', profileData['yearOfStudy']);
//         // prefs.setString('gender', profileData['gender']);
//         // prefs.setString('country', profileData['country']);
//         // prefs.setString('firstName', profileData['firstName']);
//         // prefs.setString('lastName', profileData['lastName']);
//         // prefs.setString('course', profileData['course']);
//         // prefs.setString('status', profileData['status']);
//         final Profile profile = Profile(
//             id: profileData['uid'],
//             email: profileData['email'],
//             profileId: profileId,
//             userName: profileData['userName'],
//             firstName: profileData['firstName'],
//             secondName: profileData['secondName'],
//             course: profileData['course'],
//             status: profileData['status'],
//             chances: profileData['chances'],
//             adminPoints: profileData['adminPoints'],
//             androidVersion: profileData['androidVersion'],
//             appleVersion: profileData['appleVersion'],
//             signUpDevice: profileData['signUpDevice'],
//             phoneNo: profileData['phoneNumber'],
//             accessLevel: profileData['accessLevel'],
//             imageUrl: profileData['imageUrl'],
//             university: profileData['university'],
//             countryOfStudy: profileData['countryOfStudy'],
//             joined: profileData['joined'],
//             yearOfStudy: profileData['yearOfStudy'],
//             gender: profileData['gender'],
//             country: profileData['country']);
//         fetchedProfileList.add(profile);
//       });

//       _pfs = fetchedProfileList;
//       // if (_authenticatedUser.userName == null) {
//       //   _pf = _pfs.indexWhere((Profile profile) {
//       //     return profile.email.trim() == _authenticatedUser.email;
//       //   });
//       // }
//       //_profiles = fetchedprofileList;  <-------- List of Study Circle! Where _profiles is analogy to previous _homes
//       //profileIdFromFetch = _authenticatedUser.profileId;
//       if (fetchedProfileList.firstWhere((Profile profile) {
//             return profile.email == _authenticatedUser.email;
//           }) != null) {
//         _authenticatedUserProfile =
//             fetchedProfileList.firstWhere((Profile profile) {
//           return profile.email == _authenticatedUser.email;
//         });
//         prefs.setString('profileId', _authenticatedUserProfile.profileId);
//         prefs.setString('userNm', _authenticatedUserProfile.userName);
//         prefs.setString('profileImg', _authenticatedUserProfile.imageUrl);
//         prefs.setString('university', _authenticatedUserProfile.university);
//         prefs.setString('joined', _authenticatedUserProfile.joined);
//         prefs.setString('yearOfStudy', _authenticatedUserProfile.yearOfStudy);
//         prefs.setString('gender', _authenticatedUserProfile.gender);
//         prefs.setString('country', _authenticatedUserProfile.country);
//         prefs.setString(
//             'countryOfStudy', _authenticatedUserProfile.countryOfStudy);
//         prefs.setString('firstName', _authenticatedUserProfile.firstName);
//         prefs.setString('lastName', _authenticatedUserProfile.secondName);
//         prefs.setString('course', _authenticatedUserProfile.course);
//         prefs.setString('status', _authenticatedUserProfile.status);
//       }
//       // _isLoading = false;
//       notifyListeners();
//     }).catchError((error) {
//       profileError = error;
//       _isLoading = false;
//       notifyListeners();
//       return;
//     });
//   }

//   Future<bool> updateProfile({
//     String imageUrl,
//     String firstName,
//     String lastName,
//     String phoneNumber,
//     String status,
//     String chances,
//     String reactivationDate,
//     List deactivationTimes,
//     String country,
//     String gender,
//     String universty,
//     String countryOfStudy,
//     String course,
//     String yearOfStudy,
//   }) async {
//     //*
//     _isLoading = true;
//     notifyListeners();

//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('profileImg', imageUrl);
//     prefs.setString('university', universty);
//     prefs.setString('yearOfStudy', yearOfStudy);
//     prefs.setString('gender', gender);
//     prefs.setString('country', country);
//     prefs.setString('firstName', firstName);
//     prefs.setString('lastName', lastName);
//     prefs.setString('course', course);
//     prefs.setString('phoneNumber', phoneNumber);

//     final Map<String, dynamic> updateData = {
//       'imageUrl': imageUrl,
//       'gender': gender,
//       'course': course,
//       'firstName': firstName,
//       'secondName': lastName,
//       'phoneNumber': phoneNumber,
//       'status': status,
//       'chances': chances,
//       'deactivationTimes': deactivationTimes,
//       'adminPoints': _authenticatedUserProfile.adminPoints,
//       'signUpDevice': _authenticatedUserProfile.signUpDevice,
//       'appleVersion': _authenticatedUserProfile.appleVersion,
//       'androidVersion': _authenticatedUserProfile.androidVersion,
//       'uid': _authenticatedUser.id,
//       'email': _authenticatedUser.email,
//       'accessLevel': 'wanaichi',
//       'userName': _authenticatedUserProfile.userName,
//       'university': universty,
//       'countryOfStudy': countryOfStudy,
//       'country': country,
//       'yearOfStudy': yearOfStudy,
//       'joined': _authenticatedUserProfile.joined
//     };
//     try {
//       final http.Response response = await http.put(
//           Uri.parse(
//               'https://college-fc02c.firebaseio.com/profiles/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}'),
//           body: json.encode(updateData));
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         _isLoading = false;
//         return false;
//       }
//       final Profile updatedProfile = Profile(
//         id: _authenticatedUser.id,
//         email: _authenticatedUser.email,
//         imageUrl: imageUrl,
//         firstName: firstName,
//         secondName: lastName,
//         course: course,
//         status: status,
//         chances: chances,
//         adminPoints: _authenticatedUserProfile.adminPoints,
//         androidVersion: _authenticatedUserProfile.androidVersion,
//         appleVersion: _authenticatedUserProfile.appleVersion,
//         signUpDevice: _authenticatedUserProfile.signUpDevice,
//         deactivationDates: deactivationTimes,
//         phoneNo: phoneNumber,
//         profileId: _authenticatedUserProfile.profileId,
//         userName: _authenticatedUserProfile.userName,
//         accessLevel: 'wanaichi',
//         university: universty,
//         countryOfStudy: countryOfStudy,
//         joined: _authenticatedUserProfile.joined,
//         gender: gender,
//         yearOfStudy: yearOfStudy,
//         country: country,
//       );
//       //_homes[selectedHomeIndex] = updatedHome;       <----- can be used to block seleted user if changed to _profiles
//       _authenticatedUserProfile = updatedProfile;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
// }

// mixin UtilityModel on ConnectedHomesModel {
//   bool get isLoading {
//     return _isLoading;
//   }
// }
