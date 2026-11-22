import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Menampilkan dialog konfirmasi dan mengembalikan `true` jika isian dibuang.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Buang perubahan?'),
      content: const Text(
        'Isian formulir belum disimpan dan akan hilang jika kamu keluar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Lanjut mengisi'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Buang'),
        ),
      ],
    ),
  );
  return shouldDiscard ?? false;
}

/// Menahan tombol kembali selama formulir punya isian yang belum disimpan.
class UnsavedChangesScope extends StatelessWidget {
  final bool hasUnsavedChanges;
  final Widget child;

  const UnsavedChangesScope({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  Future<void> _handleBlockedPop(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (!await confirmDiscardChanges(context)) return;

    // Form yang dibuka dari drawer bisa menjadi satu-satunya route.
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBlockedPop(context);
      },
      child: child,
    );
  }
}
