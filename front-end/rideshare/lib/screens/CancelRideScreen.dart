import 'package:flutter/material.dart';
import '../ID/backend_identifier.dart'; // Make sure this path is correct.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'RideListScreen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  Future<void> fetchDriverList(BuildContext context) async {
    final base_url = dotenv.env['BASE_URL'] ?? "http://your-api-url.com";
    final userID = BackendIdentifier.userId;
    final String route = "api/v1/users/$userID/driverList"; // This might need to change if it should be fetching rides instead of drivers
    var url = Uri.parse('$base_url/$route');

    try {
      var response = await http.post(
        url,
        body: json.encode({'userID': userID.toString()}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Data received: ${data['data']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideListScreen(rides: data['data']),  // Here 'drivers' is changed to 'rides'
          ),
        );
      } else {
        print("Failed to fetch drivers. Status code: ${response.statusCode}");
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Choose the Mode",
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.normal,
            )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () => fetchDriverList(context),
                child: const Text(
                  "Driver",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Add your logic for Rider
                  // Example: Navigator.push to a new Rider screen
                },
                child: const Text(1`
                  "Rider",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

