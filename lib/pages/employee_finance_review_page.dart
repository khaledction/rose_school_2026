import 'package:flutter/material.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../services/notification_service.dart';
import '../theme/app_palette.dart';

class EmployeeFinanceReviewPage extends StatefulWidget {
  const EmployeeFinanceReviewPage({super.key});

  @override
  State<EmployeeFinanceReviewPage> createState() => _EmployeeFinanceReviewPageState();
}

class _EmployeeFinanceReviewPageState extends State<EmployeeFinanceReviewPage> {
  final _salaryController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _bonusesController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _financeNotesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  String _tab = 'pending'; // 'pending', 'active', 'rejected'

  @override
  void dispose() {
    _salaryController.dispose();
    _hourlyRateController.dispose();
    _workingHoursController.dispose();
    _bonusesController.dispose();
    _deductionsController.dispose();
    _financeNotesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _loadEmployeeFinance(EmployeeRecord emp) {
    _salaryController.text = emp.salary > 0 ? emp.salary.toStringAsFixed(0) : '';
    _hourlyRateController.text = emp.hourlyRate > 0 ? emp.hourlyRate.toStringAsFixed(0) : '';
    _workingHoursController.text = emp.workingHours > 0 ? emp.workingHours.toStringAsFixed(0) : '';
    _bonusesController.text = emp.bonuses > 0 ? emp.bonuses.toStringAsFixed(0) : '';
    _deductionsController.text = emp.deductions > 0 ? emp.deductions.toStringAsFixed(0) : '';
    _financeNotesController.text = emp.financeNotes;
    _rejectionReasonController.text = emp.rejectionReason;
  }

  Future<void> _approveEmployee(EmployeeRecord emp) async {
    final salary = double.tryParse(_salaryController.text.trim()) ?? 0;
    final hourlyRate = double.tryParse(_hourlyRateController.text.trim()) ?? 0;
    final workingHours = double.tryParse(_workingHoursController.text.trim()) ?? 0;
    final bonuses = double.tryParse(_bonusesController.text.trim()) ?? 0;
    final deductions = double.tryParse(_deductionsController.text.trim()) ?? 0;

    if (salary <= 0 && hourlyRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إدخال الراتب الأساسي أو قيمة الساعة على الأقل.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final updated = emp.copyWith(
      salary: salary,
      hourlyRate: hourlyRate,
      workingHours: workingHours,
      bonuses: bonuses,
      deductions: deductions,
      financeNotes: _financeNotesController.text.trim(),
      financeUpdatedAt: DateTime.now().toIso8601String(),
      status: 'نشط',
    );

    await EmployeeService.instance.update(updated);
    await EmployeeService.instance.addFinanceLog(EmployeeFinanceLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      employeeId: emp.id,
      type: 'approval',
      amount: salary + (hourlyRate * workingHours) + bonuses - deductions,
      oldValue: 'بانتظار المراجعة',
      newValue: 'نشط',
      note: 'تمت الموافقة على الموظف ${emp.fullName}',
      createdAt: DateTime.now().toIso8601String(),
      createdBy: 'admin',
    ));

    await NotificationService.instance.addSimple(
      type: 'success',
      title: 'تم تفعيل الموظف',
      body: 'تم تفعيل الموظف ${emp.fullName} بعد المراجعة المالية.',
      targetPage: 'employees',
    );

    _clearFinanceForm();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم تفعيل الموظف ${emp.fullName}'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _rejectEmployee(EmployeeRecord emp) async {
    final reason = _rejectionReasonController.text.trim();
    final updated = emp.copyWith(
      status: 'مرفوض',
      rejectionReason: reason,
      financeUpdatedAt: DateTime.now().toIso8601String(),
    );

    await EmployeeService.instance.update(updated);
    await NotificationService.instance.addSimple(
      type: 'error',
      title: 'تم رفض الموظف',
      body: 'تم رفض الموظف ${emp.fullName} ${reason.isNotEmpty ? '- السبب: $reason' : ''}',
      targetPage: 'employees',
    );

    _clearFinanceForm();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ تم رفض الموظف ${emp.fullName}'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _updateFinance(EmployeeRecord emp) async {
    final salary = double.tryParse(_salaryController.text.trim()) ?? emp.salary;
    final hourlyRate = double.tryParse(_hourlyRateController.text.trim()) ?? emp.hourlyRate;
    final workingHours = double.tryParse(_workingHoursController.text.trim()) ?? emp.workingHours;
    final bonuses = double.tryParse(_bonusesController.text.trim()) ?? emp.bonuses;
    final deductions = double.tryParse(_deductionsController.text.trim()) ?? emp.deductions;

    final updated = emp.copyWith(
      salary: salary,
      hourlyRate: hourlyRate,
      workingHours: workingHours,
      bonuses: bonuses,
      deductions: deductions,
      financeNotes: _financeNotesController.text.trim(),
      financeUpdatedAt: DateTime.now().toIso8601String(),
    );

    await EmployeeService.instance.update(updated);
    await EmployeeService.instance.addFinanceLog(EmployeeFinanceLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      employeeId: emp.id,
      type: 'finance_update',
      amount: salary + (hourlyRate * workingHours) + bonuses - deductions,
      oldValue: emp.salary.toString(),
      newValue: salary.toString(),
      note: 'تحديث البيانات المالية للموظف ${emp.fullName}',
      createdAt: DateTime.now().toIso8601String(),
      createdBy: 'admin',
    ));

    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💰 تم تحديث البيانات المالية لـ ${emp.fullName}'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _clearFinanceForm() {
    _salaryController.clear();
    _hourlyRateController.clear();
    _workingHoursController.clear();
    _bonusesController.clear();
    _deductionsController.clear();
    _financeNotesController.clear();
    _rejectionReasonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // ─── Tabs ───────────────────────────────────────────────
        Row(
          children: <Widget>[
            _tabButton('بانتظار المراجعة', 'pending', AppPalette.goldDark),
            const SizedBox(width: 8),
            _tabButton('نشط', 'active', AppPalette.leafGreen),
            const SizedBox(width: 8),
            _tabButton('مرفوض', 'rejected', AppPalette.roseRed),
          ],
        ),
        const SizedBox(height: 14),

        // ─── Employee List + Review ────────────────────────────
        Expanded(
          child: _buildList(),
        ),
      ],
    );
  }

  Widget _tabButton(String label, String tabId, Color color) {
    final active = _tab == tabId;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _tab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? color : AppPalette.line),
          ),
          child: Center(
            child: Text(
              '$label (${_countForTab(tabId)})',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? color : AppPalette.muted,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _countForTab(String tabId) {
    switch (tabId) {
      case 'pending':
        return EmployeeService.instance.pendingReview.length;
      case 'active':
        return EmployeeService.instance.active.length;
      case 'rejected':
        return EmployeeService.instance.rejected.length;
      default:
        return 0;
    }
  }

  Widget _buildList() {
    List<EmployeeRecord> list;
    switch (_tab) {
      case 'pending':
        list = EmployeeService.instance.pendingReview;
        break;
      case 'active':
        list = EmployeeService.instance.active;
        break;
      case 'rejected':
        list = EmployeeService.instance.rejected;
        break;
      default:
        list = [];
    }

    return ListView(
      children: list.map((emp) => _buildReviewCard(emp)).toList(),
    );
  }

  Widget _buildReviewCard(EmployeeRecord emp) {
    final isPending = emp.status == 'بانتظار المراجعة';
    final isActive = emp.status == 'نشط';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Employee info header
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${emp.jobType} • ${emp.department} • ${emp.mobile}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                    if (emp.rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('سبب الرفض: ${emp.rejectionReason}', style: const TextStyle(color: AppPalette.roseRed, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              if (emp.financeUpdatedAt.isNotEmpty)
                Text('آخر تحديث: ${emp.financeUpdatedAt.split('T').first}', style: const TextStyle(color: AppPalette.muted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 14),

          // Finance fields
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _financeField('الراتب الأساسي', _salaryController),
              _financeField('قيمة الساعة', _hourlyRateController),
              _financeField('ساعات العمل (شهرياً)', _workingHoursController),
              _financeField('المكافآت', _bonusesController),
              _financeField('الخصومات', _deductionsController),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 540,
            child: TextField(
              controller: _financeNotesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات مالية',
                filled: true,
                fillColor: Color(0xFFFBFDFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD9E7F3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD9E7F3)),
                ),
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (isPending) ...[
                _actionButton('✅ قبول واعتماد', AppPalette.leafGreen, Colors.white, () => _approveEmployee(emp)),
                _actionButton('❌ رفض', AppPalette.roseRed, Colors.white, () => _rejectEmployee(emp)),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _rejectionReasonController,
                    decoration: const InputDecoration(
                      labelText: 'سبب الرفض (اختياري)',
                      filled: true,
                      fillColor: Color(0xFFFBFDFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFD9E7F3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFD9E7F3)),
                      ),
                    ),
                  ),
                ),
              ],
              if (isActive) ...[
                _actionButton('💰 حفظ التعديلات المالية', AppPalette.goldDark, Colors.white, () => _updateFinance(emp)),
              ],
              _actionButton('↩️ إلغاء', Colors.white, const Color(0xFF667586), _clearFinanceForm),
            ],
          ),

          // Show total
          if (isActive) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppPalette.leafGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '💵 الإجمالي الشهري: ${emp.monthlyTotal.toStringAsFixed(0)} ل.س',
                style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _financeField(String label, TextEditingController controller) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFBFDFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
