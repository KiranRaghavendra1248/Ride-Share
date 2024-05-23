import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../ID/backend_identifier.dart';
import '../components/network_utililty.dart';
import '../model/constants.dart';
import 'ride_request_dialog.dart';

class NotificationHandler extends StatelessWidget {
  final RemoteMessage remoteMessage;

  NotificationHandler({required this.remoteMessage});

  @override
  Widget build(BuildContext context) {
    if (remoteMessage.data['type'] == Notif_RideRequest) {
      return RideRequestDialog(
        remoteMessage: remoteMessage,
        onAccept: (data) async {
          await makePostRequest(
            dotenv.env["BASE_URL"] ?? "",
            'api/v1/users/${BackendIdentifier.userId}/confirmRide',
            {
              'confirmed': true,
              'offeredRideID': data['offeredRideId'],
              'requestedPassengerID': data['requestedPassengerId']
            },
          );
          Navigator.of(context).pop();
        },
        onDecline: (data) async {
          await makePostRequest(
            dotenv.env["BASE_URL"] ?? "",
            'api/v1/users/${BackendIdentifier.userId}/confirmRide',
            {
              'confirmed': false,
              'offeredRideID': data['offeredRideId'],
              'requestedPassengerID': data['requestedPassengerId']
            },
          );
          Navigator.of(context).pop();
        },
      );
    }
    else if (remoteMessage.data['type'] == Notif_RideConfirm) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        title: Text("Your ride request has been confirmed", style : TextStyle(fontSize:20, fontFamily: 'DMSans',color: Colors.indigo)),
        content: Text("Please check your active rides for more details and to track the ride", style : TextStyle(fontSize: 16, fontFamily: 'DMSans')),
          actions: <Widget>[
            TextButton(
                child: Text('OK',style : TextStyle(fontSize: 18, fontFamily: 'DMSans',color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),]
      );
    }
    else if (remoteMessage.data['type'] == Notif_RideReject) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text("Ride request rejected by driver", style : TextStyle(fontSize: 20, fontFamily: 'DMSans',color: Colors.redAccent)),
        content: Text("Please check other available rides to register another request", style : TextStyle(fontSize: 16, fontFamily: 'DMSans')),
          actions: <Widget>[
                      TextButton(
                      child: Text('OK',style : TextStyle(fontSize: 18, fontFamily: 'DMSans',color: Colors.blue)),
                      onPressed: () {
                      Navigator.of(context).pop();
                      }),]
      );
    }
    // for other notification types, we should add a different dialog boxes
    // Return an empty container if the notification type is not handled
    return Container(

    );
  }
}
