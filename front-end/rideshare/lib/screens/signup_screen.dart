import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rideshare/screens/select_mode_screen.dart';
import 'package:rideshare/screens/signin_screen.dart';
import 'package:rideshare/theme/theme.dart';
import 'package:rideshare/ID/backend_identifier.dart';

import '../firebase_messaging/notification_listener.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage; // Add error message variable
  bool passwordVisible = false;

  bool isValidPassword(String password) {
    // Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one digit
    RegExp passwordRegex = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z]{4,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> registerUser(String name, String email, String phone, String password) async {
    String baseurl = dotenv.env["BASE_URL"] ?? "";
    String route = 'api/v1/users/Register';
    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };

    String apiUrl = '$baseurl/$route';

    try {
      // Make the API call and await the response
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: body,
      );
      dynamic responseData = json.decode(response.body);
      print(responseData);
      var userId = responseData['userId'];

      BackendIdentifier.userId = userId;
      print('You userID is: ${BackendIdentifier.userId}');
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
        return const SelectMode();
      }));
    } catch (error) {
      //setState(() {
        //errorMessage = 'Error registering user: $error';
      //});
    }
    updateFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40.0),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.bold,
                  color: lightColorScheme.primary,
                ),
              ),
              const SizedBox(height: 40.0),
              Form(
                key: _formSignupKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // full name
                    SizedBox(
                      height : 60,
                      child: TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Name', style: TextStyle(fontFamily: 'DMSans'),),
                          hintText: 'Enter full name',
                          hintStyle: const TextStyle(
                              color: Colors.black26,
                              fontFamily: 'DMSans'
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    // email
                    SizedBox(
                      height : 60,
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email', style: TextStyle(fontFamily: 'DMSans'),),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                              color: Colors.black26,
                              fontFamily: 'DMSans'
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    // password
                    SizedBox(
                      height : 60,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          if (!isValidPassword(value)) {
                            return 'Invalid password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                              fontFamily: 'DMSans',
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(
                                      () {
                                    passwordVisible = !passwordVisible;
                                  },
                                );
                              },
                            )
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    // phone number
                    SizedBox(
                      height : 60,
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number';
                          }
                          if (value.length != 10) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Phone Number', style: TextStyle(fontFamily: 'DMSans'),),
                          hintText: 'Enter phone number',
                          hintStyle: const TextStyle(
                              color: Colors.black26,
                              fontFamily: 'DMSans'
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    // i agree to the processing
                    Row(
                      children: [
                        Checkbox(
                          value: agreePersonalData,
                          onChanged: (bool? value) {
                            setState(() {
                              agreePersonalData = value!;
                            });
                          },
                          activeColor: lightColorScheme.primary,
                        ),
                        const Text(
                          'I agree to the processing of ',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          'Personal data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    // signup button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formSignupKey.currentState!.validate() && agreePersonalData) {
                            registerUser(
                              nameController.text,
                              emailController.text,
                              phoneController.text,
                              passwordController.text,
                            );
                          } else if (!agreePersonalData) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please agree to the processing of personal data'),
                              ),
                            );
                          }
                        },
                        child: const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    // already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
