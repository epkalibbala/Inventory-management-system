//import 'package:renthomes/models/profile.dart';
import 'package:scoped_model/scoped_model.dart';


import './connected_homes.dart';

class MainModel extends Model with ConnectedHomesModel, UserModel, HomesModel, UtilityModel {}
// class MainModel, Model, ConnectedHomesModel, UserModel, HomesModel, UtilityModel {}