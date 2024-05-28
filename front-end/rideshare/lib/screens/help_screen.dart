import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Contact Us:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.deepPurple, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'rideshare.uci@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Phone:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '+1-(989)-567-2234',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please feel free to reach out to us via email or phone if you have any questions, feedback, or need assistance with our services.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
