import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';
import 'package:go_router/go_router.dart';

class WelcomePageBottom extends StatelessWidget {
  const WelcomePageBottom({super.key});

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: context.h * 0.55,
        padding: EdgeInsets.fromLTRB(
          24 * context.u,
          22 * context.u,
          24 * context.u,
          (24 * context.u) + safeBottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50 * context.u),
            topRight: Radius.circular(50 * context.u),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24 * context.u,
              offset: Offset(0, -6 * context.u),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Кнопка Log In (синяя)
            SizedBox(
              width: double.infinity,
              height: 54 * context.u,
              child: _loginBtn(context),
            ),
            SizedBox(height: 14 * context.u),

            // Кнопка Sign Up (белая с обводкой)
            SizedBox(
              width: double.infinity,
              height: 54 * context.u,
              child: _signUpBtn(context),
            ),

            const Spacer(),

            // Небольшой “воздух” снизу, чтобы кнопки не прилипали к краю на маленьких экранах
            SizedBox(height: 10 * context.u),
          ],
        ),
      ),
    );
  }
}

Widget _loginBtn(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      context.go('/login');
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2C76C5),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14 * context.u),
      ),
    ),
    child: Text(
      'Log In',
      style: TextStyle(fontSize: 16 * context.u, fontWeight: FontWeight.w700),
    ),
  );
}

Widget _signUpBtn(BuildContext context) {
  return OutlinedButton(
    onPressed: () {
      context.go('/signup');
    },
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2C76C5),
      side: BorderSide(
        color: const Color(0xFF2C76C5).withOpacity(0.35),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14 * context.u),
      ),
    ),
    child: Text(
      'Sign Up',
      style: TextStyle(fontSize: 16 * context.u, fontWeight: FontWeight.w700),
    ),
  );
}
