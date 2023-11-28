import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biketogether/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class Authentication {
  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Errore",
            style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
          ),
        ),
      );
    }
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async{
    FirebaseApp firebaseApp = await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,);
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(title : "biketogether"
              ),
        ),
      );
    }
    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          }
        } catch (e) {
          // ...
        }
      }
    }

    return user;
  }
}

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {


          User? user =
          await Authentication.signInWithGoogle(context: context);

          if (user != null) {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(
                  title: "biketogether",
                ),
              ),
            );
          }

        },
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Effettua il Login con Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInScreenState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(width: 20.0, height: 100.0),
              const Text(
                'Be',
                style: TextStyle(fontSize: 43.0),
              ),
              const SizedBox(width: 20.0, height: 100.0),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 40.0,
                  fontFamily: 'Horizon',
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    RotateAnimatedText('AWESOME'),
                    RotateAnimatedText('OPTIMISTIC'),
                    RotateAnimatedText('DIFFERENT'),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*Column(
            children: [
              const SizedBox(height: 30
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  'Biketogether',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                  ),
                ),
              ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    FutureBuilder(future: Authentication.initializeFirebase(context: context), builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error initializing Firebase');
                      } else if (snapshot.connectionState == ConnectionState.done) {
                        return GoogleSignInButton();
                      }
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      );
                    },),
                  ],
                ),
              ),



            ],
          ),*/