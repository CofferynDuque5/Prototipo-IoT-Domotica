import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

/// Pantalla de recuperación de contraseña.
///
/// Envía un correo de restablecimiento mediante Firebase Authentication.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.sendPasswordReset(_emailController.text);

    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
      SnackbarHelper.show(
        context,
        'Enlace de recuperación enviado',
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
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: _sent
                      ? _SuccessMessage(email: _emailController.text)
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.lock_reset_rounded,
                                size: 56,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Introduce tu correo y te enviaremos un enlace '
                                'para restablecer tu contraseña.',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                validator: Validators.email,
                                onSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Enviar enlace',
                                icon: Icons.send_rounded,
                                loading: auth.isBusy,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                ).animate().fadeIn().slideY(begin: 0.12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final String email;
  const _SuccessMessage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_rounded,
            size: 64, color: Color(0xFF22C55E)),
        const SizedBox(height: 16),
        Text(
          'Solicitud enviada',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Si existe una cuenta asociada a $email, recibirás instrucciones '
          'para restablecer tu contraseña.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Volver al inicio',
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
