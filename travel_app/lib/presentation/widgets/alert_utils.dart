import 'package:flutter/material.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);
const kTextGrey = Color(0xFF757575);

enum DialogType {
  success,
  error,
  warning,
  info,
  loading,
}

class DialogUtils {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    bool showCloseButton = true,
    Widget? customContent,
    Duration? autoDismissAfter,
  }) {
    final dialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: _DialogContent(
        type: type,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        customContent: customContent,
      ),
    );

    final dialogFuture = showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );

    if (autoDismissAfter != null) {
      Future.delayed(autoDismissAfter, () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return dialogFuture;
  }

  static Future<T?> showSuccessDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    Duration? autoDismissAfter,
  }) {
    return showCustomDialog<T>(
      context: context,
      type: DialogType.success,
      title: title,
      message: message,
      primaryButtonText: buttonText ?? 'OK',
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
      autoDismissAfter: autoDismissAfter,
    );
  }

  static Future<T?> showErrorDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showCustomDialog<T>(
      context: context,
      type: DialogType.error,
      title: title,
      message: message,
      primaryButtonText: buttonText ?? 'OK',
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }

  static Future<bool?> showWarningDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showCustomDialog<bool>(
      context: context,
      type: DialogType.warning,
      title: title,
      message: message,
      primaryButtonText: confirmText ?? 'Ya',
      secondaryButtonText: cancelText ?? 'Batal',
      onPrimaryPressed: () {
        Navigator.of(context).pop(true);
        onConfirm?.call();
      },
      onSecondaryPressed: () {
        Navigator.of(context).pop(false);
        onCancel?.call();
      },
    );
  }

  static Future<T?> showInfoDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showCustomDialog<T>(
      context: context,
      type: DialogType.info,
      title: title,
      message: message,
      primaryButtonText: buttonText ?? 'Mengerti',
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }

  static Future<T?> showLoadingDialog<T>({
    required BuildContext context,
    required String message,
    bool barrierDismissible = false,
  }) {
    return showCustomDialog<T>(
      context: context,
      type: DialogType.loading,
      title: '',
      message: message,
      barrierDismissible: barrierDismissible,
      showCloseButton: false,
    );
  }

  static void dismissDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _DialogContent extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool showCloseButton;
  final Widget? customContent;

  const _DialogContent({
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty || showCloseButton)
            Row(
              children: [
                if (type != DialogType.loading) _buildIcon(),
                if (title.isNotEmpty) ...[
                  if (type != DialogType.loading) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
                if (showCloseButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    color: kTextGrey,
                  ),
              ],
            ),
          if (type == DialogType.loading) ...[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
            ),
            const SizedBox(height: 16),
          ],
          if (title.isNotEmpty && type != DialogType.loading)
            const SizedBox(height: 16),
          if (message.isNotEmpty)
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color:
                    type == DialogType.loading ? kPrimaryBlue : Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          if (customContent != null) ...[
            const SizedBox(height: 16),
            customContent!,
          ],
          if (type != DialogType.loading &&
              (primaryButtonText != null || secondaryButtonText != null)) ...[
            const SizedBox(height: 24),
            _buildButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case DialogType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case DialogType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case DialogType.info:
        iconData = Icons.info;
        iconColor = kPrimaryBlue;
        break;
      case DialogType.loading:
        iconData = Icons.info;
        iconColor = kPrimaryBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (secondaryButtonText != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onSecondaryPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextGrey,
                side: BorderSide(color: kBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(secondaryButtonText!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPrimaryButtonColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(primaryButtonText!),
            ),
          ),
        ],
      );
    } else if (primaryButtonText != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPrimaryPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getPrimaryButtonColor(),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          child: Text(primaryButtonText!),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _getPrimaryButtonColor() {
    switch (type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.error:
        return Colors.red;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
      case DialogType.loading:
        return kPrimaryBlue;
    }
  }
}
