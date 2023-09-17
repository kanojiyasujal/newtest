import '../Login.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can add a logout action here
                // For now, let's navigate back to the login/signup page
                Navigator.pop(LoginPage() as BuildContext);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
  
}