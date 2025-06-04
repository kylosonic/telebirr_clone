import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart'; // ← add this
import '../database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    // Prefill the phone number so user doesn't have to type it
    _phoneController.text = '+251945124578';
  }

  void _login(BuildContext context) async {
    final users = await _dbHelper.getUsers();
    if (users.any((u) => u['phone'] == _phoneController.text)) {
      if (context.mounted) Navigator.pushNamed(context, '/home');
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Phone number not found')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const greyLight = Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBEF),
      body: SafeArea(
        child: Column(
          children: [
            // Full-width white bar with logos
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/ethio_telecom_logo.png',
                    height: 32.5,
                  ),
                  Image.asset('assets/images/telebirr_logo.png', height: 30),
                ],
              ),
            ),

            // The rest of the content, padded horizontally
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: Text('English ▼', style: TextStyle(fontSize: 16)),
                    ),

                    // ——— push the center block lower by adding a little top space
                    // Welcome marquee
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: SizedBox(
                        height: 30, // fix height so marquee scrolls in a box
                        child: Marquee(
                          text: 'Welcome to telebirr SuperApp!   ',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          velocity: 50,
                          blankSpace: 100,
                          pauseAfterRound: const Duration(seconds: 1),
                        ),
                      ),
                    ),

                    // All-in-One with a bit of top padding
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'All-in-One',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),
                    ),

                    // Login + underline (no extra padding here)
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 3,
                      margin: const EdgeInsets.only(top: 6, bottom: 20),
                      color: const Color(0xFF00A859),
                    ),

                    // “Mobile Number” label in light grey with top padding
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mobile Number',
                          style: TextStyle(fontSize: 12, color: greyLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input field
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 44,
                        maxHeight: 44,
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 203, 202, 202),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 203, 202, 202),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xFF00A859),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // “Next” button with top padding
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Create account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Create New Account",
                            style: TextStyle(color: Color(0xFF00A859)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // teleHub & Help
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text(
                          'teleHub',
                          style: TextStyle(color: Color(0xFF00A859)),
                        ),
                        Text(
                          'Help',
                          style: TextStyle(color: Color(0xFF00A859)),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Footer
                    const Text(
                      'Terms and Conditions',
                      style: TextStyle(color: Color(0xFF00A859)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '@2023 Ethio telecom. All rights reserved 1.0.0 version',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
