import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "John Doe"; // Example name
  String email = "johndoe@gmail.com"; // Example email
  String phone = "1234567890"; // Example phone number
  File? _image;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = name;
    phoneController.text = phone;
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
                    backgroundColor: Colors.purple,
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
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'DMSans',
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
