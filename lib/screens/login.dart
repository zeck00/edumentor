import 'package:edumentor/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:edumentor/screens/home.dart';
import 'package:edumentor/services/auth_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:edumentor/widgets/privacy_policy_link.dart';
import 'package:edumentor/widgets/terms_conditions_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          textAlign: TextAlign.center,
          'Login Help',
          style: FontStyles.hometitle,
        ),
        content: Text(
          textAlign: TextAlign.center,
          'For login, please use your university email and password.\n\n'
          'Example:\nEmail: U1000000@sharjah.ac.ae\nPassword: password123',
          style: FontStyles.sub,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Email and Password Required!',
        text: 'Please enter your email and password to continue',
        customAsset: 'assets/error.gif',
        confirmBtnText: 'Got it!',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
        confirmBtnColor: AppColors.red,
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Please enter a valid email address',
        text: 'Please enter a valid email address to continue',
        customAsset: 'assets/error.gif',
        confirmBtnText: 'Got it!',
        confirmBtnColor: AppColors.red,
      );
      return;
    }

    // For demo purposes, accept any credentials
    await AuthService.login(_emailController.text);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: propWidth(24),
              vertical: propHeight(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: propHeight(40)),
                Container(
                  width: propWidth(150),
                  height: propWidth(150),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gray,
                        blurRadius: propWidth(10),
                        spreadRadius: propHeight(5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(propWidth(25)),
                    image: const DecorationImage(
                      image: AssetImage('assets/applogo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: propHeight(40)),
                Text(
                  'Welcome!',
                  style: FontStyles.hometitle,
                ),
                SizedBox(height: propHeight(10)),
                Text(
                  textAlign: TextAlign.center,
                  'Please sign in with your university email and password to continue',
                  style: FontStyles.sub,
                ),
                SizedBox(height: propHeight(40)),
                TextField(
                  controller: _emailController,
                  style: FontStyles.sub.copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle:
                        FontStyles.sub.copyWith(color: AppColors.darkGray),
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppColors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                ),
                SizedBox(height: propHeight(20)),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: FontStyles.sub.copyWith(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle:
                        FontStyles.sub.copyWith(color: AppColors.darkGray),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propWidth(15)),
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                ),
                SizedBox(height: propHeight(40)),
                SizedBox(
                  width: double.infinity,
                  height: propHeight(55),
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(propWidth(15)),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: FontStyles.button,
                    ),
                  ),
                ),
                SizedBox(height: propHeight(20)),
                TextButton(
                  onPressed: _showHelpDialog,
                  child: Text(
                    'Need Help?',
                    style: FontStyles.sub.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: propHeight(30)),
                const CopyrightWidget(),
                SizedBox(height: propHeight(10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PrivacyPolicyLink(),
                    Text(' | '),
                    const TermsConditionsLink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
