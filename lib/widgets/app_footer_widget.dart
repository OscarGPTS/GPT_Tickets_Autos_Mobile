import 'package:flutter/material.dart';

class AppFooterWidget extends StatelessWidget {
  const AppFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'lib/assets/logo.png',
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 32,
                  color: scheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          
          // Descripción
          Text(
            'Sistema de gestión de requisición de vehículos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Versión y copyright
          Text(
            'Versión 1.0.0',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2025 Todos los derechos reservados.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
