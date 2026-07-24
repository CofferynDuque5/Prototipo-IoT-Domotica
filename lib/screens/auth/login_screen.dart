import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/config/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

/// Pantalla de inicio de sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    // Precarga el último correo recordado, si existe.
    final String? remembered =
        context.read<AuthController>().rememberedEmail;
    if (remembered != null) _emailController.text = remembered;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      remember: _remember,
    );

    if (!mounted) return;
    if (ok) {
      SnackbarHelper.show(
        context,
        '¡Bienvenido de nuevo!',
        type: SnackType.success,
      );
    } else if (auth.errorMessage != null) {
      SnackbarHelper.show(context, auth.errorMessage!, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const _LoginHeader(),
                    const SizedBox(height: 32),
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock_rounded,
                              obscure: true,
                              textInputAction: TextInputAction.done,
                              validator: Validators.password,
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (v) =>
                                      setState(() => _remember = v ?? true),
                                ),
                                const Text('Recordarme'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => context.pushNamed(
                                    RouteNames.forgotPassword,
                                  ),
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Iniciar sesión',
                              icon: Icons.login_rounded,
                              loading: auth.isBusy,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: () =>
                              context.pushNamed(RouteNames.register),
                          child: const Text('Regístrate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.home_rounded, size: 46, color: scheme.primary),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Controla tu hogar desde cualquier lugar',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
