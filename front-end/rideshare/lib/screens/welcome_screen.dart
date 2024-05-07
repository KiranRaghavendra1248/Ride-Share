import 'package:flutter/material.dart';
import 'package:rideshare/screens/signin_screen.dart';
import 'package:rideshare/screens/signup_screen.dart';
import 'package:rideshare/theme/theme.dart';
import 'package:rideshare/widgets/custom_scaffold.dart';
import 'package:rideshare/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "RideShare",
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        )
                      ),
                      SizedBox(height:5),
                      Text(
                          "Connecting People",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.normal,
                            color: Colors.white
                          )
                      ),
                      SizedBox(height:2),
                      Text(
                          "One Ride at a Time",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.normal,
                            color: Colors.white
                          )
                      ),
                    ],
                  )
                ),
              )),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
