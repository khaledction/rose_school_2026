import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../theme/app_palette.dart';

class AccountingIncomeExpensesPage extends StatefulWidget {
  const AccountingIncomeExpensesPage({super.key});

  @override
  State<AccountingIncomeExpensesPage> createState() => _AccountingIncomeExpensesPageState();
}

class _AccountingIncomeExpensesPageState extends State<AccountingIncomeExpensesPage> {
  String _tab = 'summary'; // 'summary', 'income', 'expenses', 'categories'
  String _incomeCategoryFilter = 'الكل';
  String _expenseCategoryFilter = 'الكل';

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

  Future<void> _addExpense() async {
    final amount = double.tryParse(_expenseAmountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack('يرجى إدخال مبلغ صحيح');
      return;
    }
    if (_expenseCategoryId.isEmpty) {
      _showSnack('يرجى اختيار تصنيف الصرفية');
      return;
    }
    final category = FinanceService.instance.expenseCategories.firstWhere(
      (c) => c.id == _expenseCategoryId,
      orElse: () => const ExpenseCategory(id: '', name: 'أخرى', isDefault: true),
    );

    await FinanceService.instance.addExpense(ExpenseEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      categoryId: _expenseCategoryId,
      categoryName: category.name,
      amount: amount,
      currency: _expenseCurrency,
      date: _expenseDateController.text.trim(),
      description: _expenseDescController.text.trim(),
      employeeName: _expenseEmployeeNameController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    ));

    _clearExpenseForm();
    setState(() {});
    _showSnack('✅ تم إضافة الصرفية بنجاح');
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
          const SizedBox(height: 14),

          // ─── Tab content ─────────────────────────────────────
          if (_tab == 'summary') _buildSummary(),
          if (_tab == 'income') _buildIncomeSection(),
          if (_tab == 'expenses') _buildExpenseSection(),
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

        // List
        ...filtered.map(_buildIncomeCard),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text('لا توجد إيرادات', style: TextStyle(color: AppPalette.muted)),
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
        ...filtered.map(_buildExpenseCard),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text('لا توجد صرفيات', style: TextStyle(color: AppPalette.muted)),
          ),
      ],
    );
  }

  Widget _buildExpenseForm(List<ExpenseCategory> categories) {
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
              _field('المبلغ *', _expenseAmountController, isNumber: true),
              _field('التاريخ', _expenseDateController),
              _expenseCategoryDropdown(categories),
              _expenseCurrencyDropdown(),
              _field('البيان/الوصف', _expenseDescController, span2: true),
              _field('اسم الموظف/المورد', _expenseEmployeeNameController),
            ],
          ),
          const SizedBox(height: 12),
          _actionButton('➕ إضافة الصرفية', AppPalette.roseRed, Colors.white, _addExpense),
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
        onChanged: (v) => setState(() => _expenseCategoryId = v!),
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
