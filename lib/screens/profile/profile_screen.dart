import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';

/// Pantalla de perfil del usuario. Permite ver y editar el nombre.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<AuthController>().user?.nombre ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final AuthController auth = context.read<AuthController>();
    final bool ok = await auth.updateName(_nameController.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _editing = false);
      SnackbarHelper.show(context, 'Perfil actualizado',
          type: SnackType.success);
    } else {
      SnackbarHelper.show(context, 'No se pudo actualizar el perfil',
          type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();
    final user = auth.user;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: scheme.primary.withOpacity(0.15),
                    child: Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.nombre ?? 'Usuario',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              GlassContainer(
                child: _editing
                    ? Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Editar nombre',
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nombre completo',
                              icon: Icons.person_rounded,
                              textInputAction: TextInputAction.done,
                              validator: Validators.name,
                              onSubmitted: (_) => _save(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        setState(() => _editing = false),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PrimaryButton(
                                    label: 'Guardar',
                                    loading: auth.isBusy,
                                    onPressed: _save,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Datos personales',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              TextButton.icon(
                                onPressed: () =>
                                    setState(() => _editing = true),
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('Editar'),
                              ),
                            ],
                          ),
                          InfoRow(
                            icon: Icons.person_rounded,
                            label: 'Nombre',
                            value: user?.nombre ?? '—',
                          ),
                          InfoRow(
                            icon: Icons.email_rounded,
                            label: 'Correo electrónico',
                            value: user?.email ?? '—',
                          ),
                          InfoRow(
                            icon: Icons.fingerprint_rounded,
                            label: 'ID de usuario',
                            value: user?.uid ?? '—',
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
