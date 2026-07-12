import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._();
  static PermissionService get instance => _instance;
  PermissionService._();

  /// Solicita un permiso específico y muestra un diálogo si es necesario.
  Future<bool> requestPermission(Permission permission, {
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final status = await permission.status;
    
    if (status.isGranted) return true;

    // Si fue denegado previamente, explicar por qué lo necesitamos
    if (status.isDenied || status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final proceed = await _showExplanationDialog(context, title, message);
      if (!proceed) return false;
    }

    final result = await permission.request();
    
    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context);
      }
      return false;
    }

    return result.isGranted;
  }

  Future<bool> _showExplanationDialog(BuildContext context, String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso necesario'),
        content: const Text('Este permiso es esencial para esta función. Por favor, actívalo en los ajustes de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Ir a ajustes'),
          ),
        ],
      ),
    );
  }
}
