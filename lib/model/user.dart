import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String token;
  final String phoneNo;
  final String firstName;
  final String secondName;
  final String userName;
  final String gender;
  final String subscriberType;
  final String accessLevel;
  final String status;
  final String profileId;
  final String imageUrl;
  final String university;
  final String joined;
  final String yearOfStudy;
  final String country;
  

  User({
  @required this.id, 
  @required this.email, 
  this.token, 
  this.phoneNo, 
  this.firstName, 
  this.secondName, 
  this.userName,
  this.gender,
  this.subscriberType,
  this.accessLevel,
  this.status,
  this.profileId,
  this.imageUrl,
  this.university,
  this.joined,
  this.yearOfStudy,
  this.country
  });
  }