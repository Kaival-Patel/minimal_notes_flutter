import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes_by_kaival/signInWithGoogle.dart';

class SyncNotes{
   FirebaseDatabase firebaseDatabase;
   initFirebase(){
     firebaseDatabase=FirebaseDatabase.instance;
   }
   syncMyNotes(int id,String notes,String color,String userID) async{
    await firebaseDatabase.reference().child('UserData').child(userID).child('Notes').child(""+id.toString()).set({
      'note':notes,
      'color':color,
    }).whenComplete((){
      Fluttertoast.showToast(msg:"Syncing "+notes.substring(0,5)+"..",toastLength: Toast.LENGTH_SHORT);
      Fluttertoast.showToast(msg:"Syncing of "+notes.substring(0,5)+".."+" completed!",toastLength: Toast.LENGTH_SHORT);
    });
  }
  syncMyReminderNotes(int id,String notes,String color,String userID) async{
   await firebaseDatabase.reference().child('UserData').child(userID).child('ReminderNotes').child(""+id.toString()).set({
      'note':notes,
      'color':color,
    }).whenComplete((){
      Fluttertoast.showToast(msg:"Syncing "+notes.substring(0,5)+"..",toastLength: Toast.LENGTH_SHORT);
    });
  }


   }







