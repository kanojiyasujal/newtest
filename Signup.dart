import 'Login.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
 final _formKey = GlobalKey <FormState>();
 final  _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _passToggle=true;
 
  
  @override
  void dispose(){
_emailController.dispose();
 _passwordController.dispose();
 super.dispose();
}

  

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                  
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffix: InkWell(
                      onTap: () {
                        setState(() {
                          _passToggle = !_passToggle;
                        });
                      },
                      child: Icon(
                        _passToggle ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  obscureText: _passToggle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Valid form, proceed with signup
                    SignUp();
                  }
                },
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future SignUp() async{
     showDialog(context: context,barrierDismissible: false, 
    builder: (context)=> Center(child: CircularProgressIndicator()));
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(), password: _passwordController.text.trim());
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    }on FirebaseAuthException catch(e){
      if(e.code =='email-already-in-use'){
        showDialog(context: context, 
        builder:(context)=> AlertDialog(
          title: Text('SignUp Failed'),
          content: Text('An account aith this email  already exists'),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text('OK'),
            ),
          ],
        ));
      }else{
        print(e);
      }
    }finally{
     Navigator.of(context).pop();
    }
      navigatorKey.currentState!.popUntil((route)=> route.isFirst);
  }
}