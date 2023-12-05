import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _signup() async {
    String apiUrl = 'http://127.0.0.1:5000/signup'; // Replace with your actual backend URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'dob': _dobController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.body == "Success") {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Handle other status codes if needed
        print('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any potential network or server errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill
                      )
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-1.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(duration: Duration(milliseconds: 1200), child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-2.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        child: FadeInUp(duration: Duration(milliseconds: 1600), child: Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("SignUp", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeInUp(duration: Duration(milliseconds: 1800), child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color.fromRGBO(143, 148, 251, 1)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  // border: Border(bottom: BorderSide(color:  Color.fromRGBO(143, 148, 251, 1)))
                              ),
                              child: Column(
                                children : [
                              TextField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "First Name",
                                    hintStyle: TextStyle(color: Colors.grey[700])
                                ),
                              ),
                                  const Divider(color: Color.fromRGBO(143, 148, 251, 1), height: 1),
                              TextField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Last Name",
                                    hintStyle: TextStyle(color: Colors.grey[700])
                                ),
                              ),
                                  const Divider(color: Color.fromRGBO(143, 148, 251, 1), height: 1),
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.grey[700])
                                    ),
                                  ),
                                  const Divider(color: Color.fromRGBO(143, 148, 251, 1), height: 1),
                                  TextField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Phone Number",
                                        hintStyle: TextStyle(color: Colors.grey[700])
                                    ),
                                  ),
                                  const Divider(color: Color.fromRGBO(143, 148, 251, 1), height: 1),
                                  TextField(
                                    controller: _dobController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "DOB (MM/DD/YYYY)",
                                        hintStyle: TextStyle(color: Colors.grey[700])
                                    ),
                                  ),
                                  const Divider(color: Color.fromRGBO(143, 148, 251, 1), height: 1),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle: TextStyle(color: Colors.grey[700])
                                    ),
                                  ),
                              ]
                              ),
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 40,),
                      FadeInUp(duration: Duration(milliseconds: 1900), child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(143, 148, 251, 1),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text("SignUp", style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                        ),
                      )),

                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Signup Page'),
  //     ),
  //     body: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           TextField(
  //             controller: _firstNameController,
  //             decoration: InputDecoration(labelText: 'First Name'),
  //           ),
  //           SizedBox(height: 16.0),
  //           TextField(
  //             controller: _lastNameController,
  //             decoration: InputDecoration(labelText: 'Last Name'),
  //           ),
  //           SizedBox(height: 16.0),
  //           TextField(
  //             controller: _emailController,
  //             decoration: InputDecoration(labelText: 'Email'),
  //           ),
  //           SizedBox(height: 16.0),
  //           TextField(
  //             controller: _phoneController,
  //             decoration: InputDecoration(labelText: 'Phone'),
  //           ),
  //           SizedBox(height: 16.0),
  //           TextField(
  //             controller: _dobController,
  //             decoration: InputDecoration(labelText: 'Date of Birth'),
  //           ),
  //           SizedBox(height: 16.0),
  //           TextField(
  //             controller: _passwordController,
  //             obscureText: true,
  //             decoration: InputDecoration(labelText: 'Password'),
  //           ),
  //           SizedBox(height: 32.0),
  //           ElevatedButton(
  //             onPressed: _signup,
  //             child: Text('Signup'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
