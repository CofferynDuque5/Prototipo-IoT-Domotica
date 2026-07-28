import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Pantalla de bienvenida (Splash).
///
/// El [AppRouter] se encarga de redirigir automáticamente al login o al
/// dashboard en cuanto se resuelve el estado de autenticación; aquí solo se
/// presenta la marca con animaciones de entrada.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.brandGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: 28),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.4),
              const SizedBox(height: 8),
              Text(
                'Domótica inteligente en tiempo real',
                style: TextStyle(color: Colors.white.withOpacity(0.85)),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 48),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.6,
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
