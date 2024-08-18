import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Navbar extends StatefulWidget {
  final User? user; // The User object
  final Future<void> Function()
      handleGoogleSignIn; // The sign-in callback function

  const Navbar({
    Key? key,
    required this.user,
    required this.handleGoogleSignIn,
  }) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    bool isSignedIn =
        widget.user != null; // Determine sign-in state based on user object

    return Drawer(
      child: Column(
        children: [
          // Background image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/background_image.jpeg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: isSignedIn
                            ? NetworkImage(widget.user?.photoURL ?? '')
                            : AssetImage('assets/images/avatar.jpg')
                                as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      // Profile name and other text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSignedIn
                                ? widget.user?.displayName ?? 'Pavan Naik'
                                : 'Welcome, Guest!',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isSignedIn
                                ? widget.user?.email ??
                                    'Pavanpnaik321@gmail.com'
                                : 'Please sign in to access Email.',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          // Sign-in / Sign-out button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SignInButton(
              Buttons.google,
              // Google button style
              text: isSignedIn ? 'Sign Out' : 'Sign in with Google',
              onPressed: () async {
                if (isSignedIn) {
                  // If the user is signed in, sign them out
                  await FirebaseAuth.instance.signOut();
                  setState(() {}); // Update the UI
                } else {
                  // Otherwise, trigger the sign-in function
                  await widget.handleGoogleSignIn();
                  setState(() {}); // Update the UI
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
