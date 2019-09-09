import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class notesNotification{
  var flutterlocalnotification= FlutterLocalNotificationsPlugin();
  String note,color;
  DateTime time;
  notesNotification(String note,String color,DateTime time)
  {
    this.note=note;
    this.color=color;
    this.time=time;
    
  }

   





}