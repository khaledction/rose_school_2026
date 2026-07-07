import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/school_models.dart';
import '../services/school_database_service.dart';
import '../theme/app_palette.dart';

class AdminPasswordDialog {
  static Future<bool> requirePassword(BuildContext context) async {
    final controller = TextEditingController();
    int attempts = 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: <Widget>[
                  Icon(Icons.lock_outline, color: AppPalette.goldDark),
                  SizedBox(width: 10),
                  Text('🔐 تأكيد هوية المدير'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'هذه العملية تتطلب صلاحية المدير. يرجى إدخال كلمة المرور.',
                      style: TextStyle(color: AppPalette.muted, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      obscureText: true,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة مرور المدير',
                        filled: true,
                        fillColor: const Color(0xFFFBFDFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                        ),
                      ),
                    ),
                    if (attempts >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'تم تجاوز عدد المحاولات المسموح. انتظر دقيقة.',
                          style: const TextStyle(color: AppPalette.roseRed, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (attempts >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تجاوز عدد المحاولات'), behavior: SnackBarBehavior.floating),
                      );
                      return;
                    }
                    attempts++;
                    final password = controller.text;
                    final isValid = await _verifyAdminPassword(password);
                    if (isValid) {
                      Navigator.pop(dialogContext, true);
                    } else {
                      controller.clear();
                      setDialogState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('كلمة المرور غير صحيحة (المحاولة $attempts/3)'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppPalette.roseRed,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.goldDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result ?? false;
  }

  static Future<bool> _verifyAdminPassword(String password) async {
    final db = SchoolDatabaseService.instance;
    final json = await db.readJson('admin_users');
    if (json == null) return false;

    final users = (jsonDecode(json) as List<dynamic>)
        .map((e) => AdminUserEntry(
              id: (e['id'] as num).toInt(),
              username: e['username'].toString(),
              password: e['password'].toString(),
              email: e['email'].toString(),
              mobile: e['mobile'].toString(),
              permissions: (e['permissions'] as List<dynamic>).map((p) => p.toString()).toList(),
            ))
        .toList();

    final hashedInput = sha256.convert(utf8.encode(password)).toString();

    for (final user in users) {
      if (user.permissions.contains('الإدارة')) {
        if (user.password == hashedInput || user.password == password) {
          return true;
        }
      }
    }
    return false;
  }
}
