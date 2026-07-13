import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../services/employee_service.dart';
import '../services/notification_service.dart';
import '../models/employee_model.dart';
import '../theme/app_palette.dart';

class AccountingIncomeExpensesPage extends StatefulWidget {
  const AccountingIncomeExpensesPage({super.key});

  @override
  State<AccountingIncomeExpensesPage> createState() => _AccountingIncomeExpensesPageState();
}

class _AccountingIncomeExpensesPageState extends State<AccountingIncomeExpensesPage> {
  String _tab = 'summary'; // 'summary', 'income', 'expenses', 'categories', 'reports'
  String _incomeCategoryFilter = 'الكل';
  String _expenseCategoryFilter = 'الكل';
  int? _selectedSalaryEmployeeId;
  String _reportScope = 'all'; // all | jobType | employee | category
  String _reportJobType = 'الكل';
  int? _reportEmployeeId;
  String _reportCategoryId = 'الكل';

  // Form controllers
  final _incomeAmountController = TextEditingController();
  final _incomeDateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
  final _incomeDescController = TextEditingController();
  final _incomeStudentNameController = TextEditingController();
  String _incomeCategoryId = '';
  String _incomeCurrency = 'ليرة سورية';

  final _expenseAmountController = TextEditingController();
  final _expenseDateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
  final _expenseDescController = TextEditingController();
  final _expenseEmployeeNameController = TextEditingController();
  String _expenseCategoryId = '';
  String _expenseCurrency = 'ليرة سورية';

  // New category
  final _newCategoryController = TextEditingController();
  String _newCategoryType = 'income';

  @override
  void dispose() {
    _incomeAmountController.dispose();
    _incomeDateController.dispose();
    _incomeDescController.dispose();
    _incomeStudentNameController.dispose();
    _expenseAmountController.dispose();
    _expenseDateController.dispose();
    _expenseDescController.dispose();
    _expenseEmployeeNameController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _clearIncomeForm() {
    _incomeAmountController.clear();
    _incomeDateController.text = DateTime.now().toIso8601String().split('T').first;
    _incomeDescController.clear();
    _incomeStudentNameController.clear();
    _incomeCategoryId = '';
    _incomeCurrency = 'ليرة سورية';
  }

  void _clearExpenseForm() {
    _expenseAmountController.clear();
    _expenseDateController.text = DateTime.now().toIso8601String().split('T').first;
    _expenseDescController.clear();
    _expenseEmployeeNameController.clear();
    _expenseCategoryId = '';
    _expenseCurrency = 'ليرة سورية';
  }

  Future<void> _addIncome() async {
    final amount = double.tryParse(_incomeAmountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack('يرجى إدخال مبلغ صحيح');
      return;
    }
    if (_incomeCategoryId.isEmpty) {
      _showSnack('يرجى اختيار تصنيف الإيراد');
      return;
    }
    final category = FinanceService.instance.incomeCategories.firstWhere(
      (c) => c.id == _incomeCategoryId,
      orElse: () => const IncomeCategory(id: '', name: 'آخر', isDefault: true),
    );

    await FinanceService.instance.addIncome(IncomeEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      categoryId: _incomeCategoryId,
      categoryName: category.name,
      amount: amount,
      currency: _incomeCurrency,
      date: _incomeDateController.text.trim(),
      description: _incomeDescController.text.trim(),
      studentName: _incomeStudentNameController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    ));

    _clearIncomeForm();
    setState(() {});
    _showSnack('✅ تم إضافة الإيراد بنجاح');
  }

  bool get _isSalaryCategory {
    final cats = FinanceService.instance.expenseCategories;
    ExpenseCategory? cat;
    for (final c in cats) {
      if (c.id == _expenseCategoryId) {
        cat = c;
        break;
      }
    }
    if (cat == null) return false;
    return cat.id == 'salaries' || cat.name.contains('رواتب') || cat.name.contains('أجور');
  }

  Future<void> _ensureSalaryCategoryPresent() async {
    await FinanceService.instance.init();
    final cats = FinanceService.instance.expenseCategories;
    final has = cats.any((c) => c.id == 'salaries' || c.name.contains('رواتب'));
    if (!has) {
      await FinanceService.instance.addExpenseCategory('رواتب و أجور');
    }
  }

  Future<void> _addExpense() async {
    await _ensureSalaryCategoryPresent();
    if (_expenseCategoryId.isEmpty) {
      _showSnack('يرجى اختيار تصنيف الصرفية');
      return;
    }
    final category = FinanceService.instance.expenseCategories.firstWhere(
      (c) => c.id == _expenseCategoryId,
      orElse: () => const ExpenseCategory(id: '', name: 'أخرى', isDefault: true),
    );

    double amount;
    int? employeeId;
    String employeeName = _expenseEmployeeNameController.text.trim();
    String description = _expenseDescController.text.trim();

    if (_isSalaryCategory) {
      if (_selectedSalaryEmployeeId == null) {
        _showSnack('اختر الموظف لصرف الراتب');
        return;
      }
      final emp = EmployeeService.instance.byId(_selectedSalaryEmployeeId!);
      if (emp == null) {
        _showSnack('الموظف غير موجود');
        return;
      }
      // Locked salary from admin review (no edit from accounting).
      amount = emp.monthlyTotal > 0 ? emp.monthlyTotal : emp.salary;
      if (amount <= 0) {
        _showSnack('لا يوجد راتب معتمد لهذا الموظف من الإدارة.');
        return;
      }
      employeeId = emp.id;
      employeeName = emp.fullName;
      if (description.isEmpty) {
        description = 'صرف راتب/أجر — ${emp.jobType} / ${emp.department}';
      }
    } else {
      amount = double.tryParse(_expenseAmountController.text.trim()) ?? 0;
      if (amount <= 0) {
        _showSnack('يرجى إدخال مبلغ صحيح');
        return;
      }
    }

    final entryId = DateTime.now().microsecondsSinceEpoch.toString();
    final date = _expenseDateController.text.trim().isEmpty
        ? DateTime.now().toIso8601String().split('T').first
        : _expenseDateController.text.trim();

    await FinanceService.instance.addExpense(ExpenseEntry(
      id: entryId,
      categoryId: category.id.isEmpty ? _expenseCategoryId : category.id,
      categoryName: category.name,
      amount: amount,
      currency: _expenseCurrency,
      date: date,
      description: description,
      employeeId: employeeId,
      employeeName: employeeName,
      createdAt: DateTime.now().toIso8601String(),
    ));

    if (_isSalaryCategory && employeeId != null) {
      await EmployeeService.instance.addFinanceLog(EmployeeFinanceLog(
        id: entryId,
        employeeId: employeeId,
        type: 'salary_paid',
        amount: amount,
        oldValue: '',
        newValue: amount.toStringAsFixed(0),
        note: description,
        createdAt: DateTime.now().toIso8601String(),
        createdBy: 'accounting',
      ));
      await NotificationService.instance.addSimple(
        type: 'success',
        title: 'تسليم راتب — $employeeName',
        body: 'تم تسليم راتب/أجر للموظف $employeeName بقيمة ${amount.toStringAsFixed(0)} $_expenseCurrency بتاريخ $date.',
        targetPage: 'employee_review',
        targetId: employeeId.toString(),
        roles: const ['الإدارة'],
        category: 'salary_paid',
        meta: {
          'employeeId': employeeId.toString(),
          'employeeName': employeeName,
          'amount': amount.toStringAsFixed(0),
          'date': date,
        },
      );
    }

    _clearExpenseForm();
    _selectedSalaryEmployeeId = null;
    setState(() {});
    _showSnack(_isSalaryCategory ? '✅ تم صرف الراتب وتسجيله في سجل الموظف' : '✅ تم إضافة الصرفية بنجاح');
  }

  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) {
      _showSnack('يرجى إدخال اسم التصنيف');
      return;
    }
    if (_newCategoryType == 'income') {
      await FinanceService.instance.addIncomeCategory(name);
    } else {
      await FinanceService.instance.addExpenseCategory(name);
    }
    _newCategoryController.clear();
    setState(() {});
    _showSnack('✅ تم إضافة التصنيف "${name}"');
  }

  Future<void> _removeCategory(String id, bool isIncome) async {
    if (isIncome) {
      await FinanceService.instance.removeIncomeCategory(id);
    } else {
      await FinanceService.instance.removeExpenseCategory(id);
    }
    setState(() {});
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // ─── Tabs ────────────────────────────────────────────
          _buildTabs(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: _actionButton('تحديث', const Color(0xFFEDF6FF), const Color(0xFF24436F), () async {
              await FinanceService.instance.init();
              await EmployeeService.instance.init();
              setState(() {});
              _showSnack('تم تحديث البيانات المالية.');
            }),
          ),
          const SizedBox(height: 14),

          // ─── Tab content ─────────────────────────────────────
          if (_tab == 'summary') _buildSummary(),
          if (_tab == 'income') _buildIncomeSection(),
          if (_tab == 'expenses') _buildExpenseSection(),
          if (_tab == 'reports') _buildReportsSection(),
          if (_tab == 'categories') _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const tabs = <Map<String, String>>[
      {'id': 'summary', 'label': '📊 الملخص'},
      {'id': 'income', 'label': '💰 الإيرادات'},
      {'id': 'expenses', 'label': '💸 الصرفيات'},
      {'id': 'reports', 'label': '📑 الكشوفات'},
      {'id': 'categories', 'label': '🏷️ التصنيفات'},
    ];

    return Row(
      children: tabs.map((t) {
        final active = _tab == t['id'];
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _tab = t['id']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? AppPalette.deepNavy.withOpacity(0.1) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: active ? AppPalette.deepNavy : AppPalette.line),
              ),
              child: Center(
                child: Text(
                  t['label']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active ? AppPalette.deepNavy : AppPalette.muted,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Summary Tab ──────────────────────────────────────────────

  Widget _buildSummary() {
    final summary = FinanceService.instance.thisMonthSummary;
    return Column(
      children: <Widget>[
        // Main cards
        Row(
          children: <Widget>[
            _summaryCard('💰 إجمالي الإيرادات', summary.totalIncome.toStringAsFixed(0), 'ل.س', AppPalette.leafGreen),
            const SizedBox(width: 10),
            _summaryCard('💸 إجمالي الصرفيات', summary.totalExpenses.toStringAsFixed(0), 'ل.س', AppPalette.roseRed),
            const SizedBox(width: 10),
            _summaryCard(
              '📊 صافي الشهر',
              summary.netIncome.toStringAsFixed(0),
              'ل.س',
              summary.netIncome >= 0 ? AppPalette.goldDark : AppPalette.roseRed,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Income by category
        if (summary.incomeByCategory.isNotEmpty) ...<Widget>[
          _buildCategoryBreakdown('📈 الإيرادات حسب التصنيف', summary.incomeByCategory, AppPalette.leafGreen),
          const SizedBox(height: 12),
        ],

        // Expenses by category
        if (summary.expensesByCategory.isNotEmpty) ...<Widget>[
          _buildCategoryBreakdown('📉 الصرفيات حسب التصنيف', summary.expensesByCategory, AppPalette.roseRed),
        ],

        if (summary.incomeByCategory.isEmpty && summary.expensesByCategory.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('لا توجد معاملات مالية لهذا الشهر', style: TextStyle(color: AppPalette.muted))),
          ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1.1)),
            Text(unit, style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(String title, Map<String, double> data, Color color) {
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 15)),
          const SizedBox(height: 10),
          ...entries.take(8).map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(e.key, style: const TextStyle(color: AppPalette.deepNavySoft))),
                    Text('${e.value.toStringAsFixed(0)} ل.س', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Income Tab ───────────────────────────────────────────────

  Widget _buildIncomeSection() {
    final categories = FinanceService.instance.incomeCategories;
    final filtered = _incomeCategoryFilter == 'الكل'
        ? FinanceService.instance.incomes
        : FinanceService.instance.incomes.where((e) => e.categoryId == _incomeCategoryFilter).toList();

    return Column(
      children: <Widget>[
        // Add form
        _buildIncomeForm(categories),
        const SizedBox(height: 14),

        // Filter
        Row(
          children: <Widget>[
            const Text('تصنيف: ', style: TextStyle(fontWeight: FontWeight.w700)),
            DropdownButton<String>(
              value: _incomeCategoryFilter,
              items: [
                const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _incomeCategoryFilter = v!),
            ),
            const Spacer(),
            Text('(${filtered.length}) إيراد', style: const TextStyle(color: AppPalette.muted)),
          ],
        ),
        const SizedBox(height: 8),

        _countAccordion(
          title: 'سجل الإيرادات',
          count: filtered.length,
          child: Column(
            children: <Widget>[
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد إيرادات', style: TextStyle(color: AppPalette.muted)),
                )
              else
                ...filtered.map(_buildIncomeCard),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeForm(List<IncomeCategory> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('💰 إضافة إيراد جديد', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _field('المبلغ *', _incomeAmountController, isNumber: true),
              _field('التاريخ', _incomeDateController),
              _incomeCategoryDropdown(categories),
              _incomeCurrencyDropdown(),
              _field('البيان/الوصف', _incomeDescController, span2: true),
              _field('اسم الطالب', _incomeStudentNameController),
            ],
          ),
          const SizedBox(height: 12),
          _actionButton('➕ إضافة الإيراد', AppPalette.leafGreen, Colors.white, _addIncome),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(IncomeEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.line),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('${entry.amount.toStringAsFixed(0)} ${entry.currency}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.leafGreen, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppPalette.leafGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(entry.categoryName,
                          style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${entry.date} • ${entry.description.isNotEmpty ? entry.description : 'بدون بيان'}',
                    style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                if (entry.studentName.isNotEmpty)
                  Text('طالب: ${entry.studentName}', style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 20),
            onPressed: () async {
              await FinanceService.instance.removeIncome(entry.id);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ─── Expenses Tab ─────────────────────────────────────────────

  Widget _buildExpenseSection() {
    final categories = FinanceService.instance.expenseCategories;
    final filtered = _expenseCategoryFilter == 'الكل'
        ? FinanceService.instance.expenses
        : FinanceService.instance.expenses.where((e) => e.categoryId == _expenseCategoryFilter).toList();

    return Column(
      children: <Widget>[
        _buildExpenseForm(categories),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            const Text('تصنيف: ', style: TextStyle(fontWeight: FontWeight.w700)),
            DropdownButton<String>(
              value: _expenseCategoryFilter,
              items: [
                const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _expenseCategoryFilter = v!),
            ),
            const Spacer(),
            Text('(${filtered.length}) صرفية', style: const TextStyle(color: AppPalette.muted)),
          ],
        ),
        const SizedBox(height: 8),
        _countAccordion(
          title: 'سجل الصرفيات',
          count: filtered.length,
          child: Column(
            children: <Widget>[
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد صرفيات', style: TextStyle(color: AppPalette.muted)),
                )
              else
                ...filtered.map(_buildExpenseCard),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseForm(List<ExpenseCategory> categories) {
    final salaryMode = _isSalaryCategory;
    final employees = EmployeeService.instance.active;
    if (employees.isEmpty) {
      // fallback all
    }
    final employeeList = employees.isNotEmpty ? employees : EmployeeService.instance.all;
    EmployeeRecord? selectedEmp;
    if (_selectedSalaryEmployeeId != null) {
      selectedEmp = EmployeeService.instance.byId(_selectedSalaryEmployeeId!);
    }
    final lockedSalary = selectedEmp == null
        ? 0.0
        : (selectedEmp.monthlyTotal > 0 ? selectedEmp.monthlyTotal : selectedEmp.salary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('💸 إضافة صرفية جديدة', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _expenseCategoryDropdown(categories),
              _field('التاريخ', _expenseDateController),
              _expenseCurrencyDropdown(),
              if (salaryMode) ...<Widget>[
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<int>(
                    value: _selectedSalaryEmployeeId,
                    isExpanded: true,
                    items: employeeList
                        .map((e) => DropdownMenuItem<int>(
                              value: e.id,
                              child: Text('${e.fullName} • ${e.jobType}', overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSalaryEmployeeId = v),
                    decoration: const InputDecoration(
                      labelText: 'الموظف *',
                      filled: true,
                      fillColor: Color(0xFFFBFDFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFD9E7F3)),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DDBF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('الراتب المعتمد (من الإدارة — غير قابل للتعديل)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppPalette.goldDark)),
                      const SizedBox(height: 6),
                      Text(
                        selectedEmp == null ? '—' : '${lockedSalary.toStringAsFixed(0)} $_expenseCurrency',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                      ),
                    ],
                  ),
                ),
                _field('ملاحظة', _expenseDescController, span2: true),
              ] else ...<Widget>[
                _field('المبلغ *', _expenseAmountController, isNumber: true),
                _field('البيان/الوصف', _expenseDescController, span2: true),
                _field('اسم الموظف/المورد', _expenseEmployeeNameController),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _actionButton(
            salaryMode ? '💵 صرف الراتب' : '➕ إضافة الصرفية',
            AppPalette.roseRed,
            Colors.white,
            _addExpense,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.line),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('${entry.amount.toStringAsFixed(0)} ${entry.currency}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.roseRed, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppPalette.roseRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(entry.categoryName,
                          style: const TextStyle(color: AppPalette.roseRed, fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${entry.date} • ${entry.description.isNotEmpty ? entry.description : 'بدون بيان'}',
                    style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                if (entry.employeeName.isNotEmpty)
                  Text('موظف: ${entry.employeeName}', style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 20),
            onPressed: () async {
              await FinanceService.instance.removeExpense(entry.id);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ─── Categories Tab ───────────────────────────────────────────

  Widget _buildCategoriesSection() {
    final incomeCats = FinanceService.instance.incomeCategories;
    final expenseCats = FinanceService.instance.expenseCategories;

    return Column(
      children: <Widget>[
        // Income categories
        _buildCategoryList('💰 تصنيفات الإيرادات', incomeCats, true),
        const SizedBox(height: 16),

        // Expense categories
        _buildCategoryList('💸 تصنيفات الصرفيات', expenseCats, false),
        const SizedBox(height: 16),

        // Add new category
        _buildAddCategoryForm(),
      ],
    );
  }

  Widget _buildCategoryList(String title, List<dynamic> categories, bool isIncome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 15)),
          const SizedBox(height: 10),
          if (categories.isEmpty)
            const Text('لا توجد تصنيفات', style: TextStyle(color: AppPalette.muted))
          else
            ...categories.map<Widget>((c) {
              final cat = c as dynamic;
              final isDefault = cat.isDefault as bool;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEEF2F7))),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(cat.name as String, style: const TextStyle(color: AppPalette.deepNavySoft))),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppPalette.goldDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('افتراضي', style: TextStyle(color: AppPalette.goldDark, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    if (!isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 18),
                        onPressed: () => _removeCategory(cat.id as String, isIncome),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAddCategoryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🏷️ إضافة تصنيف جديد', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'اسم التصنيف الجديد',
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
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _newCategoryType,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('إيراد')),
                  DropdownMenuItem(value: 'expense', child: Text('صرفية')),
                ],
                onChanged: (v) => setState(() => _newCategoryType = v!),
              ),
              const SizedBox(width: 12),
              _actionButton('➕ إضافة', AppPalette.goldDark, Colors.white, _addCategory),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Reports Tab ──────────────────────────────────────────────

  Widget _buildReportsSection() {
    final expenses = FinanceService.instance.expenses;
    final incomes = FinanceService.instance.incomes;
    final employees = EmployeeService.instance.all;
    final jobTypes = <String>{'الكل', ...employees.map((e) => e.jobType).where((e) => e.isNotEmpty)};
    final categories = FinanceService.instance.expenseCategories;

    List<ExpenseEntry> filteredExpenses = expenses;
    if (_reportScope == 'jobType' && _reportJobType != 'الكل') {
      final ids = employees.where((e) => e.jobType == _reportJobType).map((e) => e.id).toSet();
      filteredExpenses = expenses.where((e) => e.employeeId != null && ids.contains(e.employeeId)).toList();
    } else if (_reportScope == 'employee' && _reportEmployeeId != null) {
      filteredExpenses = expenses.where((e) => e.employeeId == _reportEmployeeId).toList();
    } else if (_reportScope == 'category' && _reportCategoryId != 'الكل') {
      filteredExpenses = expenses.where((e) => e.categoryId == _reportCategoryId).toList();
    }

    final salaryOnly = filteredExpenses.where((e) => e.categoryId == 'salaries' || e.categoryName.contains('رواتب') || e.categoryName.contains('أجور')).toList();
    final salaryTotal = salaryOnly.fold<double>(0, (s, e) => s + e.amount);
    final expenseTotal = filteredExpenses.fold<double>(0, (s, e) => s + e.amount);
    final incomeTotal = incomes.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppPalette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('📑 كشوفات الرواتب والأجور والصرفيات', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  DropdownButton<String>(
                    value: _reportScope,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('كل الموظفين / عام')),
                      DropdownMenuItem(value: 'jobType', child: Text('حسب الفئة/الوظيفة')),
                      DropdownMenuItem(value: 'employee', child: Text('حسب موظف')),
                      DropdownMenuItem(value: 'category', child: Text('حسب تصنيف الصرفية')),
                    ],
                    onChanged: (v) => setState(() => _reportScope = v ?? 'all'),
                  ),
                  if (_reportScope == 'jobType')
                    DropdownButton<String>(
                      value: jobTypes.contains(_reportJobType) ? _reportJobType : 'الكل',
                      items: jobTypes.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                      onChanged: (v) => setState(() => _reportJobType = v ?? 'الكل'),
                    ),
                  if (_reportScope == 'employee')
                    DropdownButton<int?>(
                      value: _reportEmployeeId,
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('اختر موظفًا')),
                        ...employees.map((e) => DropdownMenuItem<int?>(value: e.id, child: Text(e.fullName))),
                      ],
                      onChanged: (v) => setState(() => _reportEmployeeId = v),
                    ),
                  if (_reportScope == 'category')
                    DropdownButton<String>(
                      value: _reportCategoryId,
                      items: [
                        const DropdownMenuItem(value: 'الكل', child: Text('كل التصنيفات')),
                        ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (v) => setState(() => _reportCategoryId = v ?? 'الكل'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _reportChip('إجمالي الرواتب/الأجور (نطاق)', salaryTotal),
                  _reportChip('إجمالي الصرفيات (نطاق)', expenseTotal),
                  _reportChip('إجمالي كل الإيرادات', incomeTotal),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _reportListCard(
          title: '💵 كشف الرواتب والأجور',
          empty: 'لا توجد رواتب/أجور ضمن النطاق.',
          rows: salaryOnly
              .map((e) => '${e.date} • ${e.employeeName.isEmpty ? '—' : e.employeeName} • ${e.amount.toStringAsFixed(0)} ${e.currency} • ${e.description}')
              .toList(),
        ),
        const SizedBox(height: 12),
        _reportListCard(
          title: '💸 كشف عام للصرفيات',
          empty: 'لا توجد صرفيات.',
          rows: filteredExpenses
              .map((e) => '${e.date} • ${e.categoryName} • ${e.amount.toStringAsFixed(0)} ${e.currency} • ${e.employeeName.isEmpty ? e.description : e.employeeName}')
              .toList(),
        ),
        const SizedBox(height: 12),
        _reportListCard(
          title: '💰 كشف عام للإيرادات',
          empty: 'لا توجد إيرادات.',
          rows: incomes
              .map((e) => '${e.date} • ${e.categoryName} • ${e.amount.toStringAsFixed(0)} ${e.currency} • ${e.studentName.isEmpty ? e.description : e.studentName}')
              .toList(),
        ),
      ],
    );
  }

  Widget _reportChip(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppPalette.deepNavySoft)),
        ],
      ),
    );
  }

  Widget _reportListCard({required String title, required List<String> rows, required String empty}) {
    return _countAccordion(
      title: title,
      count: rows.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (rows.isEmpty)
            Text(empty, style: const TextStyle(color: AppPalette.muted))
          else
            ...rows.take(200).map((r) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFDFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.line),
                  ),
                  child: Text(r, style: const TextStyle(height: 1.5, fontWeight: FontWeight.w700, fontSize: 12)),
                )),
        ],
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────

  Widget _field(String label, TextEditingController controller, {bool span2 = false, bool isNumber = false}) {
    return SizedBox(
      width: span2 ? 540 : 260,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _incomeCategoryDropdown(List<IncomeCategory> categories) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: _incomeCategoryId.isEmpty ? null : _incomeCategoryId,
        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
        onChanged: (v) => setState(() => _incomeCategoryId = v!),
        decoration: const InputDecoration(
          labelText: 'التصنيف *',
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
      ),
    );
  }

  Widget _expenseCategoryDropdown(List<ExpenseCategory> categories) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: _expenseCategoryId.isEmpty ? null : _expenseCategoryId,
        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
        onChanged: (v) => setState(() {
          _expenseCategoryId = v!;
          if (!_isSalaryCategory) {
            _selectedSalaryEmployeeId = null;
          }
        }),
        decoration: const InputDecoration(
          labelText: 'التصنيف *',
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
      ),
    );
  }

  Widget _incomeCurrencyDropdown() {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: _incomeCurrency,
        items: const [
          DropdownMenuItem(value: 'ليرة سورية', child: Text('ل.س')),
          DropdownMenuItem(value: 'دولار أمريكي', child: const Text(r'$')),
          DropdownMenuItem(value: 'يورو', child: Text('€')),
        ],
        onChanged: (v) => setState(() => _incomeCurrency = v!),
        decoration: const InputDecoration(
          labelText: 'العملة',
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
      ),
    );
  }

  Widget _expenseCurrencyDropdown() {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: _expenseCurrency,
        items: const [
          DropdownMenuItem(value: 'ليرة سورية', child: Text('ل.س')),
          DropdownMenuItem(value: 'دولار أمريكي', child: const Text(r'$')),
          DropdownMenuItem(value: 'يورو', child: Text('€')),
        ],
        onChanged: (v) => setState(() => _expenseCurrency = v!),
        decoration: const InputDecoration(
          labelText: 'العملة',
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
      ),
    );
  }


  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          hoverColor: AppPalette.gold.withOpacity(0.16),
          splashColor: AppPalette.gold.withOpacity(0.22),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bg == Colors.white ? const Color(0xFFD6E4F1) : bg.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: fg)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _countAccordion({
    required String title,
    required int count,
    required Widget child,
    bool forceCollapseWhenMany = true,
  }) {
    final expanded = !(forceCollapseWhenMany && count > 5);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.line),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF6FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.royalBlue)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more),
            ],
          ),
          children: <Widget>[child],
        ),
      ),
    );
  }

}