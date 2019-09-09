import 'dart:typed_data';
import 'package:notes_by_kaival/reminderNotes.dart';
import 'package:notes_by_kaival/reminderNotesDatabaseHelper.dart';
import 'package:notes_by_kaival/syncedNotes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sync_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings/settings.dart';
import 'databaseHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signInWithGoogle.dart';
import 'signInWithGoogle.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:io';
class mainScreen extends StatefulWidget {
  @override
  _mainScreenState createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> with WidgetsBindingObserver{
  String greetings="Good ";
  final dbhelper=DatabaseHelper.instance;
  final reminderdbhelper=ReminderNotesDb.instance;
  final sync_notes=SyncNotes();
  final syncednote=syncedNotes();
  Color usercolor= Colors.red;
  bool oncetapped=false;
  List<Color> colors=[Colors.red,Colors.green,Colors.blue,Colors.deepOrange,Colors.green,Colors.yellow,Colors.purple];
  int count=0;
  int remindercounts=0;
  List note=[];
  String searchtext;
  List filternames=List();
  List colorNote=[];
  List id=[];
  TextEditingController searchController=TextEditingController();
  List noteNoteReminder=[];
  List colorNoteNoteReminder=[];
  List idNoteReminder=[];
  int selectedId;
  String addednote;
  bool isLoading=true;
  final FocusNode _textfield=FocusNode();
  GlobalKey<FormState> _key=GlobalKey();
  GlobalKey<ScaffoldState> scaffoldkey=GlobalKey<ScaffoldState>();
  TextEditingController tc= TextEditingController();
  final FirebaseAuth auth=FirebaseAuth.instance;
  FirebaseUser user;
  bool syncing=false;
  bool signedIn=false;
  bool connected=false;
  String notifynote;
  DateTime notifytime=DateTime.now();
  int notifyindex;
  String notifycolor;
  String reminderbtntext="Add a Reminder?";
  bool issearching=false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  checkforNetwork() async{
    var connectivityResult= await (Connectivity().checkConnectivity());
    if(connectivityResult==ConnectivityResult.mobile){
      connected=true;
    }
    else if(connectivityResult==ConnectivityResult.wifi)
    {
      connected=true;
    }
    else{
      connected=false;
    }
  }
  
  getUser() async {
   if(signedIn){
     user=await auth.currentUser();
     print("USER UID:"+user.uid);
   }
  }
 


 @override
void didChangeAppLifecycleState(AppLifecycleState state) {
if (state == AppLifecycleState.resumed) {
  checkforNetwork();
  signInWithGoogle().whenComplete((){
                        setState(() {
                          signedIn=true; 
                          isLoading=false;
                          print("SIGNED IN");
                        });});
               //do your stuff
}
}
@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void initState()
  {
    super.initState();
    checkforNetwork();
    greetings+=getGreetings()+"!";
   signInWithGoogle().whenComplete((){
                        setState(() {
                          signedIn=true; 
                          isLoading=false;
                          print("SIGNED IN");
                          print("USER UID:"+user.uid);
                        });});
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid=AndroidInitializationSettings('notepad');
    var initializationSettingsIos=IOSInitializationSettings();
    var initializationSettings=InitializationSettings(initializationSettingsAndroid,initializationSettingsIos); 
    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification:onSelectNotification);
    setupScreen();
    sync_notes.initFirebase();
    WidgetsBinding.instance.addObserver(this);
  }
  Color parsefromString(String color)
  {
    String values=color.split('(0x')[1].split(')')[0];
    int colorval=int.parse(values,radix:16);
    Color originalColor= Color(colorval);
    return originalColor;
  }
  _launchURL() async {
  const url = 'https://github.com/kaival750';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
_launchURLINSTA() async {
  const url = 'https://www.instagram.com/kaival.dart/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      resizeToAvoidBottomInset:false,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color:Color(0xFF641fdd)),
      ),
      drawer: Theme(
        data:Theme.of(context).copyWith(
                 canvasColor:Color(0xFF641fdd), //This will change the drawer background to blue.
                 //other styles
              ) ,
              child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
                child: Drawer(
            child: ListView(
              children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title:connected?!signedIn?ListTile(
                          leading: Image(height: 20,width: 20,image:AssetImage('icon/google.png'),),                      
                          title: RaisedButton(
                            onPressed:(){
                              checkforNetwork();
                              if(connected==true){
                            signInWithGoogle().whenComplete((){
                            setState(() {
                              signedIn=true; 
                              isLoading=false;
                              print("SIGNED IN");
                            });});}
                            else{
                              scaffoldkey.currentState.showSnackBar(SnackBar(
                              content: Text("Please Connect to the Internet"),
                              duration: Duration(seconds: 3),
                                action: SnackBarAction(
                                label: "Turn On",
                              textColor: Colors.blue,
                                onPressed:Settings.openWiFiSettings,
                                  ) ,
                                ));
                            }
                            },
                          child: Text("Login with Google",style: TextStyle(color: Colors.black),),
                          color: Colors.white,
                          elevation: 0.0,
                          )
                        ):
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child:UserAccountsDrawerHeader(
                         accountEmail:Text(""+email,style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic),),
                         accountName: Text(""+name,style: TextStyle(fontSize: 20),),
                         onDetailsPressed: (){
                           print("pressed");
                         },
                         currentAccountPicture: CircleAvatar(radius: 30,child: ClipOval(child: Image.network(imageUrl),),),
                        ))
                        :ListTile(
                        title:ListTile(
                          leading: Image(height: 20,width: 20,image:AssetImage('icon/google.png'),),                      
                          title: RaisedButton(
                            onPressed:(){
                              checkforNetwork();
                              if(connected==true){
                            signInWithGoogle().whenComplete((){
                            setState(() {
                              signedIn=true; 
                              isLoading=false;
                              print("SIGNED IN");
                              
                            });});}
                            else{
                              scaffoldkey.currentState.showSnackBar(SnackBar(
                              content: Text("Please Connect to the Internet"),
                              duration: Duration(seconds: 3),
                                action: SnackBarAction(
                                label: "Turn On",
                              textColor: Colors.blue,
                                onPressed:Settings.openWiFiSettings,
                                  ) ,
                                ));
                            }
                            },
                          child: Text("Login with Google",style: TextStyle(color: Colors.black),),
                          color: Colors.white,
                          elevation: 0.0,
                          ),
                        )
                      ),
                    ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child:
                       Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.notifications_active,color: Color(0xFFfc4103),),
                            trailing: Text(""+remindercounts.toString(),style: TextStyle(color:Color(0xFFfc4103)),),
                            title: Text("Reminder Notes"),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>reminderNotes()
                              ));
                            },
                          )
                        ],
                      ),
                    ),
                    signedIn?Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child:
                       Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.assignment_turned_in,color:Colors.brown,),
                            title: Text("Synced Notes"),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>syncedNotes()
                              ));
                            },
                          )
                        ],
                      ),
                      ):
                      Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child:
                       Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.assignment_turned_in,color:Colors.grey,),
                            title: Text("Synced Notes"),
                            onTap: (){
                              
                              
                            },
                          )
                        ],
                      ),
                      ),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: <Widget>[
                          ExpansionTile(
                            leading: Icon(Icons.settings,color: Colors.grey,),
                            title:Text("Settings"),
                            children: <Widget>[
                              signedIn?ListTile(
                                leading: Icon(Icons.sync,color: Colors.orange,),
                                title: Text("Sync Now"),
                                onTap:(){ 
                                  sync_notes.initFirebase();
                                  if(count>0){
                                    if(oncetapped==false){
                                    setState(() {
                                         oncetapped=true; 
                                        });
                                    Fluttertoast.showToast(msg:"Tap Again to Sync",toastLength: Toast.LENGTH_SHORT);
                                        syncData();
                                        
                                  }
                                  else{
                                    setState(() {
                                     syncing=true; 
                                    });
                                    for(int i=0;i<count;i++){
                                      sync_notes.syncMyNotes(int.parse(id[i]), note[i], colorNote[i], user.uid);
                                      setState(() {
                                      syncing=false; 
                                    });
                                    }
                  
                                    
                                  }
                                  }
                                  else{
                                    Fluttertoast.showToast(msg: "No Notes To Sync",toastLength: Toast.LENGTH_SHORT);
                                  }
                                  
                                   

                                  },
                                trailing: syncing?CircularProgressIndicator():Text(""),
                              ):
                              ListTile(),
                            ],
                            initiallyExpanded: false,
                          ),
                          ListTile(
                            leading: Icon(Icons.exit_to_app,color: Colors.red,),
                            title: Text("SignOut"),
                            
                            onTap: (){
                              if(signedIn==true)
                              {
                              signOutGoogle();
                              setState(() {
                              signedIn=false;
                               });
                            }
                            else{
                              scaffoldkey.currentState.showSnackBar(SnackBar(
                              content: Text("Please SignIn first!"),
                              duration: Duration(seconds: 3),));
                            }
                            }
                          ),
                          ListTile(
                            leading: Icon(Icons.close,color: Color(0xFF641fdd),),
                            title: Text("Close"),
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],

                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child:
                       Column(
                        children: <Widget>[
                          ExpansionTile(
                            leading: Icon(Icons.developer_mode,color: Color(0xFF362d45),),
                            title: Text("Developed By Kaival Patel"),
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.perm_device_information,color: Colors.amber[800],),
                                title: Text("Github"),
                                onTap: _launchURL,
                              ),
                              ListTile(
                                leading: Icon(Icons.person,color: Colors.green[900],),
                                title: Text("Instagram"),
                                onTap: _launchURLINSTA,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    
                  ],
                ),
            ),
        ),
      ),
      backgroundColor:Color(0xFFFFFFFF),
      floatingActionButton: Container(
        height: 60.0,
        width: 200.0,
        child: FloatingActionButton.extended(
          onPressed:(){ moveToAddScreen(context);},
          backgroundColor: Color(0xFF641fdd),
          label: Text("Add new task",style: TextStyle(color: Colors.white,fontSize:17),),
        ),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10),),
              Align(
                child:Text(greetings,style: TextStyle(color: Color(0xFF3D416B),fontSize: 45,fontWeight: FontWeight.bold),),
                alignment: Alignment.center, 
              ),
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
                         selectedId=int.parse(id[index],); 
                        });
                        moveToUpdateScreen(context, note[index].toString(),colorNote[index].toString());
                        
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
  
  

  Future onSelectNotification(String payload) async {
  List<String > input = payload.split("+");
  int id=int.parse(input[1]);
   return showDialog(
     context: context,
     builder: (_) {
      return Card(
          child: AlertDialog(
            title:Text("Notes Reminder",style: TextStyle(color:Color(0xFF641FDD),fontSize:25,)),
            content: Text(input[0]),
            actions: <Widget>[
              RaisedButton(
                child: Text("Okay",style: TextStyle(color: Colors.white),),
                color: Color(0xFF641FDD),
                onPressed: (){
                Navigator.of(context).pop();
                setupScreen();}
              ),

            ],
          )
        );
     }
   );
  }
 Future<void >_showNotificationWithDefaultSound(int id) async {
   var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
  var scheduledNotificationDateTime =
        notifytime.add(Duration(seconds: 5));
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Notes Reminder ID', 'Notes Reminder', 'Notes',sound: 'doubt',enableLights: true,
      enableVibration: true,vibrationPattern: vibrationPattern,
      playSound: true,
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(id, 'Notes',notifynote, scheduledNotificationDateTime, platformChannelSpecifics,payload: notifynote+"+"+notifyindex.toString());
}
  
  

  String getGreetings()
  {
    var hour=DateTime.now().hour;
    print("Hour:$hour");
    if(hour<12)
    {
      return 'Morning';
    }
    else if(hour<17)
    {
      return 'Afternoon';
    }
    else{
      return 'Evening';
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

   Future<int> _getCountforreminder() async
  {
    int result=await reminderdbhelper.queryRowCount();
    setState(() {
     remindercounts=result; 
    });
    print("COUNT OF REMINDER TASK:$remindercounts");
    return result;
  }
  void _delete(int id) async{
    final result=await dbhelper.delete(id);
    if(result>0){
      Fluttertoast.showToast(msg:"Note Deleted Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Note Deletion Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print("Deleted Row:$result");
  }


  void _update(int id,String text,String color) async{
    Map<String, dynamic> row = {
      DatabaseHelper.columnId:id,
      DatabaseHelper.columnNote:text,
      DatabaseHelper.columnColor  : color.toString(),
    };
    final result=await dbhelper.update(row);
    if(result>0){
      Fluttertoast.showToast(msg:"Note Updated Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Note Updation Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print("Row Updated:$result");
  }

  void _insert(int primarykey,String text,Color color) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnId:primarykey,
      DatabaseHelper.columnNote:text,
      DatabaseHelper.columnColor:color.toString(),
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

  void _insertintonotesreminderdb(int primarykey,String text,Color color) async{
    Map<String, dynamic> row = {
      ReminderNotesDb.columnId:primarykey,
      ReminderNotesDb.columnNote:text,
      ReminderNotesDb.columnColor:color.toString(),
    };
    final id = await reminderdbhelper.insert(row);
    if(id>0){
      Fluttertoast.showToast(msg:"Reminder Saved Successfully",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.blue,textColor: Colors.white);
    }
    else{
      Fluttertoast.showToast(msg:"Reminder Saving Failure",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.white,textColor: Colors.red);

    }
    print('inserted row id: $id');
    print('Primary key passed:$primarykey');
  }
  void _queryReminder() async {
    final allclRows = await reminderdbhelper.queryColumn();
    final allColorRows= await reminderdbhelper.queryColors();
     final allIdRows= await reminderdbhelper.queryId();
    print('query all rows:');
    setState(() {
      noteNoteReminder.clear();
      allclRows.forEach((row) => noteNoteReminder.add(row.values.toString().replaceFirst('(', ')').replaceAll(')', '')));
      colorNoteNoteReminder.clear();
      allColorRows.forEach((row)=>colorNoteNoteReminder.add(row.values.toString()));
      idNoteReminder.clear();
      allIdRows.forEach((row)=>idNoteReminder.add(row.values.toString().replaceFirst('(', ')').replaceAll(')', '')));
  
    });
    print(noteNoteReminder);
    print(colorNoteNoteReminder);
    print(idNoteReminder);
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
  void moveToAddScreen(BuildContext context)
  {
    tc.text="";
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc)
      {
        return Container(

          color:Colors.transparent,
        child: Container(
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
                          validator: (input){
                            if(input.isEmpty){
                              return 'Add a Note';
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardAppearance: Brightness.dark,
                          focusNode: _textfield,
                          /*onFieldSubmitted: (term){
                            _textfield.unfocus();
                            SystemChrome.restoreSystemUIOverlays();
                          },*/
                          controller: tc,
                          onSaved: (input)=>addednote=input,
                          maxLines: 7,
                          style: TextStyle(color: Colors.black,fontSize: 18),
                          decoration: InputDecoration(
                            labelText:  "Drop your Task here",
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
                        usercolor=color;
                      },
                      selectedColor: usercolor
                    ) ,
                    ),
                    ListTile(
                      leading: Icon(Icons.save,color: Colors.green,),
                       title: RaisedButton(
                        onPressed:(){
                            if(tc.text.isNotEmpty)
                            {
                              if(_key.currentState.validate()){
                                _key.currentState.save();
                                if(id.length==0){
                                   _insert(1,tc.text,usercolor);
                                }
                                else{
                                  _insert(int.parse(id.last)+1,tc.text,usercolor);
                                }
                               
                              }
                              setupScreen();
                              Navigator.of(context).pop();
                              SystemChrome.restoreSystemUIOverlays();
                           }
                           else{
                             Fluttertoast.showToast(
                               msg:"Please Provide the Task",
                               toastLength: Toast.LENGTH_SHORT,
                               gravity: ToastGravity.CENTER,
                               backgroundColor: Colors.grey,
                               textColor: Color(0xFF641FDD),
                               fontSize: 16.0,
                             );
                           }
                          
                        },
                        color: Colors.green,
                        child:Text("Save Task",style: TextStyle(color:Colors.white),),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.alarm_add,color: Colors.blue,),
                      title: RaisedButton(
                      color: Colors.blue,
                      child: Text("Add Reminder and Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),),
                      elevation: 0.0,
                      onPressed: ()async{
                        DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        currentTime: DateTime.now(),
                        onChanged: (datetime){
                          print("CHANGED:$datetime");
                        },
                        onConfirm: (datetime) async {
                          print("CONFIRMED AT:"+DateTime.now().toString());
                          print("SCHEDULED TIME:"+datetime.toString());
                          if(tc.text.isNotEmpty)
                            {
                              if(_key.currentState.validate()){
                                _key.currentState.save();
                                if(idNoteReminder.length==0){
                                   _insertintonotesreminderdb(1,tc.text,usercolor);
                                  setState(() {
                                   notifyindex=1; 
                                  });
                                }
                                else{
                                  _insertintonotesreminderdb(int.parse(idNoteReminder.last)+1,tc.text,usercolor);
                                 setState(() {
                                   notifyindex=int.parse(idNoteReminder.last)+1; 
                                  });
                            
                                }
                               setState(() {
                               notifycolor=usercolor.toString();
                               notifynote=tc.text;
                               notifytime=datetime; 
                              });
                              }
                               await _showNotificationWithDefaultSound(notifyindex);
                              setupScreen();
                                  Navigator.of(context).pop();
                                  SystemChrome.restoreSystemUIOverlays();
                              
                           }
                           else{
                             Fluttertoast.showToast(
                               msg:"Please Provide the Task",
                               toastLength: Toast.LENGTH_SHORT,
                               gravity: ToastGravity.CENTER,
                               backgroundColor: Colors.grey,
                               textColor: Color(0xFF641FDD),
                               fontSize: 16.0,
                             );
                           }
                        
                      }
                    );
                      }
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
                      leading: Icon(Icons.update,color: Colors.blue,),
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
                      leading: Icon(Icons.delete,color: Colors.red,),
                      title:
                      RaisedButton(
                      onPressed:(){
                        setState(() {
                          _delete(selectedId);
                        });
                        
                        setupScreen();
                        Navigator.of(context).pop();
                        SystemChrome.restoreSystemUIOverlays();
                      },
                      color: Colors.white,
                      child: Text("Delete Task",style: TextStyle(color:Colors.red)),

                    ),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications_active,color: Colors.green,),
                      title:
                      RaisedButton(
                      color: Colors.green,
                      child: Text("Update Notes To Reminder",style: TextStyle(color:Colors.white)),
                      onPressed: ()async{
                        DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        currentTime: DateTime.now(),
                        onChanged: (datetime){
                          print("CHANGED:$datetime");
                        },
                        onConfirm: (datetime) async {
                          print("CONFIRMED AT:"+DateTime.now().toString());
                          print("SCHEDULED TIME:"+datetime.toString());
                          
                              if(idNoteReminder.isEmpty){
                              _insertintonotesreminderdb(1,note,usercolor);
                              _delete(selectedId);
                              notifyindex=1;
                              }
                              else{
                              _insertintonotesreminderdb((int.parse(idNoteReminder.last))+1,note,usercolor);
                              _delete(selectedId);
                              notifyindex=int.parse(idNoteReminder.last)+1;
                              }
                              setState(() {
                               notifycolor=usercolor.toString();
                               notifynote=tc.text;
                               notifytime=datetime; 
                              });
                            await _showNotificationWithDefaultSound(notifyindex);
                            setupScreen();
                            Navigator.of(context).pop();
                            SystemChrome.restoreSystemUIOverlays();
                         },
                         locale: LocaleType.en
                        );
                       
                        }
                      ),
                    ),
                
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }


  
  void setupScreen()
  {
    _getCount();
    _getCountforreminder();
    _query();
    _queryReminder();
   }
   
  void syncData(){
    getUser();
    _getCount();
    _query();
    for(int i=0;i<count;i++){
    sync_notes.syncMyNotes(id[i], note[i], colorNote[i], user.uid);
    }
    setState(() {
      oncetapped=true; 
     });
  }
    
}
