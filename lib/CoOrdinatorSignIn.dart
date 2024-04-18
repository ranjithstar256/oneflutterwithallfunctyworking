import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CoordinatorFiles/AddEventPage.dart';
import 'CoordinatorFiles/CoOrdinatorSignUp.dart';
import 'CoordinatorFiles/ViewingGameRegistrationsPage.dart';
import 'Registrations/ForgotPasswordPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyAppeeee());
}

class MyAppeeee extends StatelessWidget {
  const MyAppeeee({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coordinator Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkIfLoggedIn(), // Check if user is already logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // If user is already logged in, navigate to main content
          if (snapshot.data == true) {
            return CoordinatorActionScreen();
          } else {
            // Otherwise, navigate to login page
            //return CoordinatorLoginScreenn();
            return SignInTen();
          }
        },
      ),
    );
  }
}

class SignInTen extends StatefulWidget {
  const SignInTen({Key? key}) : super(key: key);

  @override
  State<SignInTen> createState() => _SignInTenState();
}

class _SignInTenState extends State<SignInTen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _coordinatorIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _coordinatorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginCoordinator() async {
    String coordinatorId = _coordinatorIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('coordinators')
          .where('coordinatorid', isEqualTo: coordinatorId)
          .where('cooripassword', isEqualTo: password)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // Save logged in status and coordinator ID
        await setLoggedIn(true);
        await setcoid(coordinatorId);

        // Navigate to the action screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CoordinatorActionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: Column(
                    children: [buildCard(size), buildFooter(size)],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(Size size) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: size.width * 0.9,
      height: size.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //logo & login text here
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.03,
                ),
                richText(24),
              ],
            ),
          ),

          //email , password textField and rememberForget text here
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                emailTextField(size),
                SizedBox(
                  height: size.height * 0.02,
                ),
                passwordTextField(size),
                SizedBox(
                  height: size.height * 0.01,
                ),
              ],
            ),
          ),

          //sign in button, 'don't have account' text and social button here
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //sign in button here
                signInButton(size),
                SizedBox(
                  height: size.height * 0.02,
                ),
                buildRemember_ForgetSection(size, context),
                SizedBox(
                  height: size.height * 0.02,
                ),
                //don't have account text here
                buildNoAccountText(),
                SizedBox(
                  height: size.height * 0.02,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: const Color(0xFF21899C),
          letterSpacing: 2.000000061035156,
        ),
        children: const [
          TextSpan(
            text: 'Coordinator',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: '  LOGIN',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 12,
      child: TextFormField(
        controller: _coordinatorIdController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'Enter your college id',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          fillColor: _coordinatorIdController.text.isNotEmpty
              ? Colors.transparent
              : const Color.fromRGBO(248, 247, 251, 1),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: _coordinatorIdController.text.isEmpty
                  ? Colors.transparent
                  : const Color.fromRGBO(44, 185, 176, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Color.fromRGBO(44, 185, 176, 1),
            ),
          ),
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: _coordinatorIdController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color.fromRGBO(44, 185, 176, 1),
            size: 16,
          ),
          suffix: Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: const Color.fromRGBO(44, 185, 176, 1),
            ),
            child: _coordinatorIdController.text.isEmpty
                ? const Center()
                : const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
                  ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your college ID';
          }
          // You can add additional validation for email format here

          return null;
        },
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return SizedBox(
      height: size.height / 12,
      child: TextFormField(
        controller: _passwordController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          fillColor: _passwordController.text.isNotEmpty
              ? Colors.transparent
              : const Color.fromRGBO(248, 247, 251, 1),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: _passwordController.text.isEmpty
                  ? Colors.transparent
                  : const Color.fromRGBO(44, 185, 176, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Color.fromRGBO(44, 185, 176, 1),
            ),
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: _passwordController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color.fromRGBO(44, 185, 176, 1),
            size: 16,
          ),
          suffix: Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: const Color.fromRGBO(44, 185, 176, 1),
            ),
            child: _passwordController.text.isEmpty
                ? const Center()
                : const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
                  ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          if (value.length > 16) {
            return 'Password cannot be more than 16 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget signInButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          // Validation passed, perform sign-in action
          _loginCoordinator();
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: const Color(0xFF21899C),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C2E84).withOpacity(0.2),
              offset: const Offset(0, 15.0),
              blurRadius: 60.0,
            ),
          ],
        ),
        child: Text(
          'Sign in',
          style: GoogleFonts.inter(
            fontSize: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildRemember_ForgetSection(Size size, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to ForgotPasswordPage when "Forgot password?" is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
          );
        },
        child: Row(
          children: [
            const Spacer(),
            Text(
              'Forgot password?',
              style: GoogleFonts.inter(
                fontSize: 13.0,
                color: const Color(0xFF21899C),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoAccountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Expanded(
            flex: 2,
            child: Divider(
              color: Color(0xFF969AA8),
            )),
        Expanded(
          flex: 3,
          child: Text(
            'Don’t Have Account?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
              fontWeight: FontWeight.w500,
              height: 1.67,
            ),
          ),
        ),
        const Expanded(
            flex: 2,
            child: Divider(
              color: Color(0xFF969AA8),
            )),
      ],
    );
  }

  Widget buildFooter(Size size) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.03),
      child: GestureDetector(
        onTap: () {
          // Navigate to CoordinatorLoginPage when "Sign Up here" is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoOrdinatorSignUp()),
          );
        },
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: Colors.black,
            ),
            children: const [
              TextSpan(
                text: 'Don’t have an account? ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Sign Up here',
                style: TextStyle(
                  color: Color(0xFFFF7248),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

Future<void> setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('coordinloggedin', value);
}

Future<void> setcoid(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('coordinid', value);
}

Future<bool> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('coordinloggedin') ?? false;
}

Future<String?> getcoid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('coordinid');
}

class CoordinatorActionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getcoid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          String coordinatorId = snapshot.data.toString();
          Fluttertoast.showToast(
            msg: coordinatorId ?? 'No coordinator ID found',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text('Choose an action'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setLoggedIn(true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRegistrationPage(
                              coordinatorId: coordinatorId),
                        ),
                      );
                    },
                    child: const Text('View Registration'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setLoggedIn(true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEventPage(coordinatorId: coordinatorId),
                        ),
                      );
                    },
                    child: const Text('Add Event'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('No coordinator ID found');
        }
      },
    );
  }
}
