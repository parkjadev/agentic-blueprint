import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/router/routes.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/form_fields.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;
    final confirmationSent = useState(false);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        context.showError(next.message);
      }
    });

    if (confirmationSent.value) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Check your email',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a confirmation link to '
                    '${emailController.text.trim()}. '
                    'Tap the link to activate your account.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colours.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create account',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get started with your new account',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colours.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: nameController,
                    label: 'Name',
                    hint: 'Your full name',
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  EmailField(
                    controller: emailController,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: passwordController,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              final needsConfirmation = await ref
                                  .read(authStateProvider.notifier)
                                  .register(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  );
                              if (!context.mounted) return;
                              if (needsConfirmation) {
                                confirmationSent.value = true;
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.go(Routes.login),
                    child: const Text('Already have an account? Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
