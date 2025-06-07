import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:royal_clothes/db/database_helper.dart';
import 'package:royal_clothes/views/login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPasswordVisible = false; // Melihat Password

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    String caesarEncrypt(String text, int key) {
  return String.fromCharCodes(text.runes.map((char) {
    if (char >= 65 && char <= 90) {
      // Uppercase
      return ((char - 65 + key) % 26) + 65;
    } else if (char >= 97 && char <= 122) {
      // Lowercase
      return ((char - 97 + key) % 26) + 97;
    } else {
      // Non-alphabetic characters stay the same
      return char;
    }
  }));
}



    setState(() => isLoading = true);
    final name = caesarEncrypt(nameController.text.trim(), 7);
    final email = caesarEncrypt(emailController.text.trim(), 14);

    final password = passwordController.text;

    final db = DBHelper();
    final exists = await db.userExists(email);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email already registered.")),
      );
    } else {
      await db.insertUser(name, email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }

    setState(() => isLoading = false);
  }

  Widget makeInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Color? textColor,
    Color? borderColor,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textColor ?? Colors.white,
            fontFamily: 'Garamond',
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          style: TextStyle(color: textColor ?? Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor ?? Colors.white54),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor ?? Color.fromARGB(255, 16, 5, 107)),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor ?? Colors.white54),
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: textColor ?? Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : null,
              ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color.fromARGB(255, 6, 30, 135),
            ],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/illustration.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                          fontFamily: 'Garamond',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "Create an account, It's free",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontFamily: 'Garamond',
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: makeInput(
                        label: "Name",
                        controller: nameController,
                        textColor: Colors.white,
                        borderColor: Color(0xFFFFD700),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: makeInput(
                        label: "Email",
                        controller: emailController,
                        textColor: Colors.white,
                        borderColor: Color(0xFFFFD700),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1300),
                      child: makeInput(
                        label: "Password",
                        controller: passwordController,
                        obscureText: true,
                        textColor: Colors.white,
                        borderColor: Color(0xFFFFD700),
                        isPassword: true,
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: makeInput(
                        label: "Confirm Password",
                        controller: confirmPasswordController,
                        obscureText: true,
                        textColor: Colors.white,
                        borderColor: Color(0xFFFFD700),
                        isPassword: true,
                      ),
                    ),
                    SizedBox(height: 40),
                    FadeInUp(
                      duration: Duration(milliseconds: 1500),
                      child: Container(
                        padding: EdgeInsets.only(top: 3, left: 3),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: _registerUser,
                          color: Color(0xFFFFD700),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black87,
                              fontFamily: 'Garamond',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Garamond',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              " Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFFFFD700),
                                fontFamily: 'Garamond',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
