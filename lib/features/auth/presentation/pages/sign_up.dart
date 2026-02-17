import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/AuthTextField.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/RoleSelector.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/PrimaryButton.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  AuthRole _role = AuthRole.student;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18 * u),
          child: Column(
            children: [
              SizedBox(height: 10 * u),

              // Верхняя панель: стрелка назад + заголовок по центру
              Row(
                children: [
                  IconButton(
                    onPressed: () => Future.delayed(Duration.zero, () {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                    }),
                    icon: Icon(Icons.arrow_back_ios_new, size: 18 * u),
                    splashRadius: 22 * u,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18 * u,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B1F2A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * u), // балансирует IconButton слева
                ],
              ),

              SizedBox(height: 10 * u),

              // Белая карточка с полями (как на макете)
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16 * u, 16 * u, 16 * u, 18 * u),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18 * u),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18 * u,
                          offset: Offset(0, 8 * u),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: 'Name',
                          controller: _nameCtrl,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 12 * u),

                        AuthTextField(
                          label: 'Email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 12 * u),

                        AuthTextField(
                          label: 'Password',
                          controller: _passwordCtrl,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscure,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              size: 20 * u,
                              color: const Color(0xFF6B7280),
                            ),
                            splashRadius: 22 * u,
                          ),
                        ),
                        SizedBox(height: 16 * u),

                        Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 13 * u,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 8 * u),

                        RoleSelector(
                          value: _role,
                          onChanged: (r) => setState(() => _role = r),
                        ),

                        SizedBox(height: 16 * u),

                        PrimaryButton(
                          text: 'Sign Up',
                          onPressed: () {
                            context.go("/welcome");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 14 * u),
            ],
          ),
        ),
      ),
    );
  }
}
