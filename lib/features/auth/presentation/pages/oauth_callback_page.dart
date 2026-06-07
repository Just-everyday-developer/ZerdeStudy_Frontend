import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_flutter/app/routing/app_routes.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/auth_controller.dart';

class OAuthCallbackPage extends ConsumerStatefulWidget {
  const OAuthCallbackPage({
    super.key,
    required this.provider,
    required this.code,
  });

  final String provider;
  final String code;

  @override
  ConsumerState<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends ConsumerState<OAuthCallbackPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer until after the frame is built — Riverpod 3.x throws if provider
    // state is modified during the build phase (which includes initState).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _processCallback();
    });
  }

  Future<void> _processCallback() async {
    debugPrint('[OAuth] callback started — provider=${widget.provider} code_len=${widget.code.length}');
    final notifier = ref.read(authControllerProvider.notifier);
    final String? error;

    if (widget.provider == 'google') {
      debugPrint('[OAuth] calling handleGoogleCallback…');
      error = await notifier.handleGoogleCallback(widget.code);
    } else {
      debugPrint('[OAuth] calling handleGithubCallback…');
      error = await notifier.handleGithubCallback(widget.code);
    }

    debugPrint('[OAuth] handler returned — error=$error mounted=$mounted');
    if (!mounted) return;

    if (error != null) {
      setState(() => _error = error);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Authentication Failed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Completing authentication...'),
          ],
        ),
      ),
    );
  }
}

class SMaterial extends StatelessWidget {
  const SMaterial({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: child,
    );
  }
}
