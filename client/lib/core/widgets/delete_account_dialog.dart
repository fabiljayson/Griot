import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Confirmation dialog for account deletion
class DeleteAccountDialog extends StatefulWidget {
  final Function()? onConfirm;

  const DeleteAccountDialog({
    super.key,
    this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, {Function()? onConfirm}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteAccountDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _confirmed = false;
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action is irreversible. All your data will be permanently deleted.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // What will be deleted
          const Text(
            'The following data will be deleted:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          _buildDeleteItem('Your profile and account information'),
          _buildDeleteItem('Your story contributions'),
          _buildDeleteItem('Your reading history and progress'),
          _buildDeleteItem('Your badges and achievements'),
          _buildDeleteItem('Your search history'),
          
          const SizedBox(height: 16),
          
          // Confirmation checkbox
          Row(
            children: [
              Checkbox(
                value: _confirmed,
                onChanged: (value) {
                  setState(() {
                    _confirmed = value ?? false;
                  });
                },
                activeColor: Colors.red,
              ),
              const Expanded(
                child: Text(
                  'I understand this action cannot be undone',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.warmGray),
          ),
        ),
        ElevatedButton(
          onPressed: _confirmed
              ? () {
                  widget.onConfirm?.call();
                  Navigator.of(context).pop(true);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Delete Account'),
        ),
      ],
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.close_rounded,
            size: 16,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
