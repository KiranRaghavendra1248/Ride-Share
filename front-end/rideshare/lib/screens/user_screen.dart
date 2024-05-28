import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rideshare/ID/backend_identifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = ""; // Example name
  String email = ""; // Example email
  String phone = ""; // Example phone number
  File? _image;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details when the screen initializes
  }

  Future<void> _fetchUserDetails() async {
    String baseurl = dotenv.env["BASE_URL"] ?? "";
    int user_id = BackendIdentifier.userId;
    String route = 'api/v1/users/$user_id';
    String apiUrl = '$baseurl/$route';

    try {
      final response = await http.get(
          Uri.parse(apiUrl)
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        setState(() {
          name = responseData['userDetails']['name'] ?? ""; // Replace 'name' with the actual field name
          print(name);
          email = responseData['userDetails']['email'] ?? ""; // Replace 'email' with the actual field name
          phone = responseData['userDetails']['phone'] ?? ""; // Replace 'phone' with the actual field name
        });
        nameController.text = name;
        phoneController.text = phone;
      } else {
        // Handle error
        print('Failed to fetch user details');
      }
    } catch (error) {
      // Handle network error
      print('Error: $error');
    }
  }

  Future<void> _getImage() async {
    // Add image picking functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfo('Name:', name),
                      SizedBox(height: 15),
                      _buildProfileInfo('Email:', email),
                      SizedBox(height: 15),
                      _buildProfileInfo('Phone:', phone),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    child: _image != null
                        ? ClipOval(
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                        : Icon(
                      Icons.camera_alt_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: _showEditProfileDialog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 20, // Increase font size
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'DMSans',
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _showEditProfileDialog() {
    TextEditingController phoneEditingController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneEditingController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newPhone = phoneEditingController.text.trim();
                if (newPhone.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a 10-digit phone number'),
                    ),
                  );
                } else {
                  setState(() {
                    name = nameController.text;
                    phone = newPhone;
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
