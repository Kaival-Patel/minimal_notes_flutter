import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes_by_kaival/mainScreen.dart';
import 'package:notes_by_kaival/reminderNotesDatabaseHelper.dart';
import 'package:notes_by_kaival/sync_notes.dart';
class reminderNotes extends StatefulWidget {
 
  @override
  _reminderNotesState createState() => _reminderNotesState();
}

class _reminderNotesState extends State<reminderNotes> {
  GlobalKey<FormState> _key=GlobalKey<FormState>();
  bool oncetapped=false;
  TextEditingController tc=TextEditingController();
  final dbhelper=ReminderNotesDb.instance;
  int count=0;
  List note=[];
  List colorNote=[];
  List id=[];
  int selectedId;
  String addednote;
  Color usercolor=Colors.red;
  FirebaseAuth auth=FirebaseAuth.instance;
  FirebaseUser user;
  bool isSignedIn=false;
  SyncNotes sync_notes=SyncNotes();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FocusNode _textfield=FocusNode();
  @override
  void initState(){
    super.initState();
    setupScreen();
    getUser();
    sync_notes.initFirebase();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid=AndroidInitializationSettings('notepad');
    var initializationSettingsIos=IOSInitializationSettings();
    var initializationSettings=InitializationSettings(initializationSettingsAndroid,initializationSettingsIos); 
  }
  
  Future cancelNotification(int id) async{
    flutterLocalNotificationsPlugin.cancel(id);
  }

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

  Future<int> _getCount() async
  {
    int result=await dbhelper.queryRowCount();
    setState(() {
     count=result; 
    });
    return result;
  }
  void _delete(int id) async{
    final result=await dbhelper.delete(id);
    if(result>0){
      Fluttertoast.showToast(msg:"Reminder Deleted Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Reminder Deletion Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print("Deleted Row:$result");
  }

  void _update(int id,String text,String color) async{
    Map<String, dynamic> row = {
      ReminderNotesDb.columnId:id,
      ReminderNotesDb.columnNote:text,
      ReminderNotesDb.columnColor  : color.toString(),
    };
    final result=await dbhelper.update(row);
    if(result>0){
      Fluttertoast.showToast(msg:"Note Updated Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Note Updating Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print("Row Updated:$result");
  }

  void _insert(int primarykey,String text,Color color) async {
    // row to insert
    Map<String, dynamic> row = {
      ReminderNotesDb.columnId:primarykey,
      ReminderNotesDb.columnNote:text,
      ReminderNotesDb.columnColor:color.toString(),
    };
    final id = await dbhelper.insert(row);
    if(id>0){
      Fluttertoast.showToast(msg:"Note Saved Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Note Saving Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print('inserted row id: $id');
  }
  void _query() async {
    final allclRows = await dbhelper.queryColumn();
    final allColorRows= await dbhelper.queryColors();
     final allIdRows= await dbhelper.queryId();
    print('query all rows:');
    setState(() {
      note.clear();
      allclRows.forEach((row) => note.add(row.values.toString().replaceFirst('(', ')').replaceAll(')', '')));
      colorNote.clear();
      allColorRows.forEach((row)=>colorNote.add(row.values.toString()));
      id.clear();
      allIdRows.forEach((row)=>id.add(row.values.toString().replaceFirst('(', ')').replaceAll(')', '')));
  
    });
    print(note);
    print(colorNote);
    print(id);
  }

  void setupScreen()
  {
    _getCount();
    _query();
  }

  void syncData(){
    getUser();
    _getCount();
    _query();
    for(int i=0;i<count;i++){
    sync_notes.syncMyReminderNotes(id[i], note[i], colorNote[i], user.uid);
    }
    setState(() {
      oncetapped=true; 
     });
  }

  Color parsefromString(String color)
  {
    String values=color.split('(0x')[1].split(')')[0];
    int colorval=int.parse(values,radix:16);
    Color originalColor= Color(colorval);
    return originalColor;
  }

  void moveToUpdateScreen(BuildContext context,String note,String passedcolor)
  {
    Color prevColor=parsefromString(passedcolor.toString());
    TextEditingController updatescreentc = TextEditingController();
    Color newColor=Colors.red;
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc)
      {
        return Container(
        color:Colors.transparent,
        child: Container(
          /*decoration: BoxDecoration(
                      borderRadius:BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ) ,
                      boxShadow: [BoxShadow(
                        color:Colors.grey[200],
                        blurRadius:10.0,
                        offset: Offset(1.0,8.0),
                      ),]
                    ),*/
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: SingleChildScrollView(
                              child: Column(
                  children: <Widget>[
                    Form(
                      key: _key,
                      child: ListTile(
                        leading: Icon(Icons.note_add,color: Colors.blue[800],),
                        title: TextFormField(
                          controller: updatescreentc,
                          textInputAction: TextInputAction.done,
                          keyboardAppearance: Brightness.dark,
                          focusNode: _textfield,
                          onFieldSubmitted: (term){
                            _textfield.unfocus();
                            SystemChrome.restoreSystemUIOverlays();
                          },
                          onSaved: (input)=>addednote=input,
                          maxLines: 5,
                          validator: (input){
                            if(input.isEmpty)
                            {
                              return 'Drop the Note';
                            }
                          },
                          style: TextStyle(color: Colors.black,fontSize: 18),
                          decoration: InputDecoration(
                            labelText:  note,
                            labelStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                    ),
                    ListTile(
                      leading: Icon(Icons.color_lens,color: Colors.red,),
                      title: Text("Choose the Color for your note",style:TextStyle(color: Colors.orange,fontStyle: FontStyle.italic) ,),
                      subtitle:MaterialColorPicker(
                      circleSize: 40,
                      onColorChange:(Color color)
                      {
                        newColor=color;
                      },
                      selectedColor:prevColor
                    ) ,
                    ),
                    ListTile(
                      leading: Icon(Icons.update,color:Colors.blue),
                        title: RaisedButton(
                        onPressed:(){
                          setState(() {
                            if(updatescreentc.text.isNotEmpty)
                            {
                            _update(selectedId, updatescreentc.text, newColor.toString());
                            }
                          });
                          setupScreen();
                          Navigator.of(context).pop();
                          SystemChrome.restoreSystemUIOverlays();
                        },
                        color: Colors.blue,
                        child:Text("Update Task",style: TextStyle(color:Colors.white),),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.delete,color:prevColor ,),
                      title: RaisedButton(
                      onPressed:(){
                          _delete(selectedId);
                          cancelNotification(selectedId);
                        
                        setupScreen();
                        Navigator.of(context).pop();
                        SystemChrome.restoreSystemUIOverlays();
                      },
                      color: Colors.white,
                      child: Text("Delete Task",style: TextStyle(color:prevColor)),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications_off,color:Color(0xFFfc4103) ,),
                      title: RaisedButton(
                        onPressed: (){
                          cancelNotification(selectedId);
                          setupScreen();
                          Navigator.of(context).pop();
                          SystemChrome.restoreSystemUIOverlays();
                        },
                        child: Text("Delete Notification only",style: TextStyle(color: Color(0xFFfc4103)),),
                        color: Colors.white,
                      ),

                      
                    )                
                  ],
                ),
              ),
            ),
          ),
        );
      }
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
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF641fdd),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Drawer(
            child: ListView(
              children: <Widget>[
                Card(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                    borderRadius:  BorderRadius.circular(15),
                     child: isSignedIn?UserAccountsDrawerHeader(
                      accountEmail:Text(""+user.email),
                      accountName: Text(""+user.displayName),
                      currentAccountPicture: CircleAvatar(radius: 30,child: ClipOval(child:Image(image: NetworkImage(user.photoUrl),),)),
                    ):ListTile(
                      leading: Icon(Icons.error,color: Colors.red,),
                      title: Text("Go to Home and SignIn"),
                      onTap: (){
                        Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context)=>mainScreen(),
                          )
                        );
                      },
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  elevation: 0.0,
                  child: isSignedIn?ListTile(
                    leading: Icon(Icons.sync,color: Colors.orange,),
                    title: Text("Sync Reminder Notes",),
                    onTap: (){
                      if(oncetapped==false){
                                    setState(() {
                                         oncetapped=true; 
                                        });
                                    Fluttertoast.showToast(msg:"Tap Again to Sync",toastLength: Toast.LENGTH_SHORT);
                                        syncData();
                                        
                    }
                    for(int i=0;i<count;i++){
                               sync_notes.syncMyReminderNotes(int.parse(id[i]), note[i], colorNote[i], user.uid);
                          }
                    }
                  ):ListTile(
                    leading: Icon(Icons.sync_disabled,color: Colors.grey,),
                    title: Text("Sign In to Sync"),
                    onTap: (){
                      Navigator.push(context, 
                        MaterialPageRoute(
                          builder: (context)=>mainScreen(),
                        )
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20),),
              Align(
                alignment: Alignment.centerRight,
                child:Row(
                  children: <Widget>[
                    Text("You have ",style: TextStyle(color: Color(0xFFD7DAE0),fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                    Text("$count tasks",style: TextStyle(color: Color(0xFF641FDD),fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                    Text(" to complete",style: TextStyle(color: Color(0xFFD7DAE0),fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                  ],
                ),
              ),
              ],),
              Padding(padding: EdgeInsets.only(bottom: 20),),
              Visibility(
                              child: Text("Nothing to show..Drop Some notes!",style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 18)),
                              visible: count==0?true:false,
                            ),
              Expanded(
                child:GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
        
                  ),
                  itemCount:note.length,
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
                        print("ID:"+id[index]);
                        setState(() {
                         selectedId=int.parse(id[index]); 
                         print("SELECTED ID:$selectedId");
                        });
                        moveToUpdateScreen(context,note[index].toString(),colorNote[index].toString());
                        
                      },
                       child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Align(
                                alignment: Alignment.topRight,
                                child: Text(".",style: TextStyle(color:parsefromString(colorNote[index]),fontSize: 43,),),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(note[index],style: TextStyle(color:Color(0xFF717082),fontSize: 15 ),maxLines: 2,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                )
              ),
            ],
          ),
      
    );
  }
}