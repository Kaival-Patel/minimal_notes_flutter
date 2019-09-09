import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes_by_kaival/mainScreen.dart';
import 'package:notes_by_kaival/sync_notes.dart';
class syncedNotes extends StatefulWidget {
  @override
  _syncedNotesState createState() => _syncedNotesState();
}

class _syncedNotesState extends State<syncedNotes> {
  FirebaseDatabase firebaseDatabase;
  List notes;
  List id;
  var listNote=[];
  var noteList=[];
  List colorNote;
  int count=0;
  List<dynamic> mainList;
  SyncNotes sn=SyncNotes();
  FirebaseUser user;
  bool isSignedIn=false;
  bool isdownloading=true;
  FirebaseAuth auth=FirebaseAuth.instance;
  int selectedId;
  Timer timer;
  Future<bool> getUser() async{
    user?.reload();
    user=await auth.currentUser();
    if(user.uid.isEmpty){
      setState(() {
       isSignedIn=false; 
      });
      return false;
    }
    else{
      setState(() {
       isSignedIn=true; 
      });
      return true;
    }
  }
  @override
  void initState(){
    super.initState();
    firebaseDatabase=FirebaseDatabase.instance;
    getUser().whenComplete((){
      if(isSignedIn==true){
      fetchNotes();
      timer=Timer(Duration(milliseconds: 1000),(){
        setState(() {
         isdownloading=false; 
        });
      });
    }
    });
    
  }

  fetchNotes()async {
    if(user.uid.isNotEmpty){
      final db=firebaseDatabase.reference().child('UserData').child(""+user.uid.toString()).child('Notes');
      noteList.clear();
      db.once().then((DataSnapshot ds){
        mainList=ds.value;
        mainList.forEach((v){try{noteList.add(v);}catch(e){print(e.message());}});
        print("LIST:::");
        if(noteList.length>0){
        for(int i=1;i<noteList.length;i++){
          if(noteList[i]!=null){
          print("NOTELIST:"+noteList[i]['note'].toString());
          }
          else{
            noteList.removeAt(i);
          }
          
        }
        for(int i=1;i<noteList.length;i++){
          print("AT INDEX:$i");
          print("NOTELIST:"+noteList[i]['note'].toString());
          
          
        }
        print("NOTE LIST SIZE:${noteList.length}");
      };
      });
    }
  }
      
   Color parsefromString(String color)
  {
    String values=color.split('(0x')[1].split(')')[0];
    int colorval=int.parse(values,radix:16);
    Color originalColor= Color(colorval);
    return originalColor;
  }
    
  showNoteAlert(int index,String note){
    showDialog(
      context: context,
      builder: (_)=>Card(
        child: AlertDialog(
          title: Text("Modify Synced Notes",style: TextStyle(color:Color(0xFF641fdd),),),
          content: Text("You want to Delete this note:"+note),
          actions: <Widget>[
            RaisedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('Close',style: TextStyle(color: Colors.white),),
            ),
             RaisedButton(
               color: Colors.white,
              onPressed: (){
                final db=firebaseDatabase.reference().child('UserData').child(""+user.uid.toString()).child('Notes');
                db.child(index.toString()).remove().whenComplete((){
                  fetchNotes();
                  timer=Timer(Duration(milliseconds: 1000),(){
                  setState(() {
                  isdownloading=false; 
                       });
                   });
                  Fluttertoast.showToast(msg:"Deleted from Synced Notes!",backgroundColor:Color(0xFF641fdd),textColor: Colors.white);
                });
                
                Navigator.of(context).pop();
              },
              child: Text('Delete',style: TextStyle(color: Colors.red),),
            )
          ],
        ),
      )
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color:Color(0xFF641fdd)),
      ),
      backgroundColor: Colors.white,
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10),),
              Text("Notes",style: TextStyle(color: Color(0xFF641fdd),fontSize: 18),),
              isdownloading?CircularProgressIndicator():Expanded(
                child:noteList.length>0?GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
        
                  ),
                  itemCount:noteList.length,
                  itemBuilder: (context,index)=>Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(
                        color:Colors.grey[200],
                        blurRadius:10.0,
                        offset: Offset(1.0,8.0),
                      )],
                    ),
                    child: GestureDetector(
                      onTap: (){
                        print(noteList[index]['note']);
                        print("With ID:$index");
                        String note=noteList[index]['note'].toString();
                        showNoteAlert(index,note);
                        //moveToUpdateScreen(context, note[index].toString(),colorNote[index].toString());
                        
                      },
                       child:Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Align(
                                alignment: Alignment.topRight,
                                child: Text(".",style: TextStyle(color:parsefromString(index==0?Colors.blue.toString():noteList[index]['color']),fontSize: 43,),),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(index==0?"Your Synced Notes =>":noteList[index]['note'],style: TextStyle(color:Color(0xFF717082),fontSize: 15 ),maxLines: 2,),
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  )
                ):Text("Seems like You dont have any Notes Synced or Network error!"),
              ),
              
              
            ],
            
      ),
    );
      
  }
}