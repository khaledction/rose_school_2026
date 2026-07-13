import 'dart:convert';

import '../models/finance_models.dart';
import 'school_database_service.dart';

class FinanceService {
  FinanceService._();

  static final FinanceService instance = FinanceService._();

  List<IncomeCategory> _incomeCategories = [];
  List<ExpenseCategory> _expenseCategories = [];
  List<IncomeEntry> _incomes = [];
  List<ExpenseEntry> _expenses = [];
  bool _initialized = false;

  // ─── Getters ──────────────────────────────────────────────────

  List<IncomeCategory> get incomeCategories =>
      List<IncomeCategory>.unmodifiable(_incomeCategories);

  List<ExpenseCategory> get expenseCategories =>
      List<ExpenseCategory>.unmodifiable(_expenseCategories);

  List<IncomeEntry> get incomes => List<IncomeEntry>.unmodifiable(_incomes);

  List<ExpenseEntry> get expenses => List<ExpenseEntry>.unmodifiable(_expenses);

  // ─── Init ─────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    await _loadCategories();
    await _loadEntries();
    _initialized = true;
  }

  Future<void> _loadCategories() async {
    final json = await SchoolDatabaseService.instance.readJson('finance_categories');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      _incomeCategories = (data['income'] as List<dynamic>?)
              ?.map((e) => IncomeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _expenseCategories = (data['expense'] as List<dynamic>?)
              ?.map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }
    if (_incomeCategories.isEmpty) {
      _incomeCategories.addAll(kDefaultIncomeCategories);
    }
    if (_expenseCategories.isEmpty) {
      _expenseCategories.addAll(kDefaultExpenseCategories);
    } else {
      for (var i = 0; i < _expenseCategories.length; i++) {
        final c = _expenseCategories[i];
        if (c.id == 'salaries' && c.name != 'رواتب و أجور') {
          _expenseCategories[i] = ExpenseCategory(id: c.id, name: 'رواتب و أجور', isDefault: c.isDefault);
        }
      }
      final hasSalaries = _expenseCategories.any((c) => c.id == 'salaries' || c.name.contains('رواتب'));
      if (!hasSalaries) {
        _expenseCategories.insert(0, const ExpenseCategory(id: 'salaries', name: 'رواتب و أجور', isDefault: true));
      }
    }
  }

  Future<void> _loadEntries() async {
    final json = await SchoolDatabaseService.instance.readJson('finance_entries');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      _incomes = (data['incomes'] as List<dynamic>?)
              ?.map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _expenses = (data['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }
  }

  // ─── Category Management ──────────────────────────────────────

  Future<void> addIncomeCategory(String name) async {
    _incomeCategories.insert(
      0,
      IncomeCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    await _persistCategories();
  }

  Future<void> removeIncomeCategory(String id) async {
    final cat = _incomeCategories.firstWhere((c) => c.id == id);
    if (cat.isDefault) return; // can't remove default
    _incomeCategories.removeWhere((c) => c.id == id);
    await _persistCategories();
  }

  Future<void> addExpenseCategory(String name) async {
    _expenseCategories.insert(
      0,
      ExpenseCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    await _persistCategories();
  }

  Future<void> removeExpenseCategory(String id) async {
    final cat = _expenseCategories.firstWhere((c) => c.id == id);
    if (cat.isDefault) return;
    _expenseCategories.removeWhere((c) => c.id == id);
    await _persistCategories();
  }

  // ─── Entries Management ───────────────────────────────────────

  Future<void> addIncome(IncomeEntry entry) async {
    _incomes.insert(0, entry);
    await _persistEntries();
  }

  Future<void> addExpense(ExpenseEntry entry) async {
    _expenses.insert(0, entry);
    await _persistEntries();
  }

  Future<void> removeIncome(String id) async {
    _incomes.removeWhere((e) => e.id == id);
    await _persistEntries();
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _persistEntries();
  }

  // ─── Summary ──────────────────────────────────────────────────

  FinancialSummary summaryForPeriod({String? startDate, String? endDate}) {
    var incomes = _incomes;
    var expenses = _expenses;

    if (startDate != null) {
      incomes = incomes.where((e) => e.date.compareTo(startDate) >= 0).toList();
      expenses = expenses.where((e) => e.date.compareTo(startDate) >= 0).toList();
    }
    if (endDate != null) {
      incomes = incomes.where((e) => e.date.compareTo(endDate) <= 0).toList();
      expenses = expenses.where((e) => e.date.compareTo(endDate) <= 0).toList();
    }

    final totalIncome = incomes.fold<double>(0, (sum, e) => sum + e.amount);
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final incomeByCategory = <String, double>{};
    for (final e in incomes) {
      incomeByCategory[e.categoryName] =
          (incomeByCategory[e.categoryName] ?? 0) + e.amount;
    }

    final expensesByCategory = <String, double>{};
    for (final e in expenses) {
      expensesByCategory[e.categoryName] =
          (expensesByCategory[e.categoryName] ?? 0) + e.amount;
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netIncome: totalIncome - totalExpenses,
      incomeByCategory: incomeByCategory,
      expensesByCategory: expensesByCategory,
    );
  }

  FinancialSummary get thisMonthSummary {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1)
        .toIso8601String()
        .split('T')
        .first;
    final endOfMonth = DateTime(now.year, now.month + 1, 0)
        .toIso8601String()
        .split('T')
        .first;
    return summaryForPeriod(startDate: startOfMonth, endDate: endOfMonth);
  }

  // ─── Persist ──────────────────────────────────────────────────

  Future<void> _persistCategories() async {
    await SchoolDatabaseService.instance.saveJson('finance_categories', {
      'income': _incomeCategories.map((c) => c.toJson()).toList(),
      'expense': _expenseCategories.map((c) => c.toJson()).toList(),
    });
  }

  Future<void> _persistEntries() async {
    await SchoolDatabaseService.instance.saveJson('finance_entries', {
      'incomes': _incomes.map((e) => e.toJson()).toList(),
      'expenses': _expenses.map((e) => e.toJson()).toList(),
    });
  }
}
