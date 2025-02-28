import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/components/button.dart';
import 'package:my_app/components/g_button.dart';
import 'package:my_app/components/text_field.dart';
import 'package:my_app/utils/validators.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = null; // Don't show error for empty field
        _isNameValid = false;
      } else if (value.length < 3) {
        _nameError = "Name must be at least 3 characters";
        _isNameValid = false;
      } else {
        _nameError = null;
        _isNameValid = true;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null; // Don't show error for empty field
        _isEmailValid = false;
      } else if (!Validators.isValidEmail(value)) {
        _emailError = "Please enter a valid email address";
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null; // Don't show error for empty field
        _isPasswordValid = false;
      } else if (!Validators.isValidPassword(value)) {
        _passwordError = "Password must be at least 8 characters with 1 number";
        _isPasswordValid = false;
      } else {
        _passwordError = null;
        _isPasswordValid = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;

    final double logoSize = isTablet ? 60.0 : 42.0;
    final double horizontalPadding = screenSize.width * 0.05;
    final double verticalSpacing = screenSize.height * 0.03;
    final double titleSize = isTablet ? 36.0 : 28.0;
    final double subtitleSize = isTablet ? 16.0 : 13.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double contentWidth = constraints.maxWidth;
            if (isTablet) {
              contentWidth = constraints.maxWidth * 0.7;
            }

            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: verticalSpacing),
                      Hero(
                        tag: 'appLogo',
                        child: SvgPicture.asset(
                          'lib/assets/images/meteor.svg',
                          width: logoSize,
                          height: logoSize,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 2),

                      Text(
                        'Create an account',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 0.3),
                      Text(
                        'Please enter your details to sign up',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: verticalSpacing),

                      // Full name with validation
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        errorText: _nameError,
                        isValid: _isNameValid,
                        suffixIcon: const FaIcon(
                          FontAwesomeIcons.user,
                          size: 18,
                        ),
                        onChanged: _validateName,
                      ),

                      // Email with validation
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        errorText: _emailError,
                        isValid: _isEmailValid,
                        suffixIcon: const FaIcon(
                          FontAwesomeIcons.solidEnvelope,
                          size: 18,
                        ),
                        onChanged: _validateEmail,
                      ),

                      // Password with validation
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        errorText: _passwordError,
                        isValid: _isPasswordValid,
                        obscureText: obscurePassword,
                        onChanged: _validatePassword,
                        suffixIcon: Container(
                          width: 40,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: FaIcon(
                              obscurePassword
                                  ? FontAwesomeIcons.solidEyeSlash
                                  : FontAwesomeIcons.solidEye,
                              color: Colors.grey[800],
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 1.5),
                      Button(
                        buttonText: "Sign Up",
                        onPressed:
                            (_isNameValid && _isEmailValid && _isPasswordValid)
                                ? () {
                                  // Handle successful signup
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Signup successful!'),
                                    ),
                                  );
                                }
                                : null,
                      ),
                      SizedBox(height: verticalSpacing * 0.7),
                      GoogleButton(buttonText: "Sign up with Google"),
                      SizedBox(height: verticalSpacing * 3),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: subtitleSize,
                              color: Colors.grey[700],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
