import 'dart:convert';

import '../models/employee_model.dart';
import 'school_database_service.dart';

class EmployeeService {
  EmployeeService._();

  static final EmployeeService instance = EmployeeService._();

  List<EmployeeRecord> _employees = [];
  List<EmployeeFinanceLog> _financeLogs = [];
  bool _initialized = false;

  List<EmployeeRecord> get all => List<EmployeeRecord>.unmodifiable(_employees);

  List<EmployeeRecord> get pendingReview =>
      _employees.where((e) => e.status == 'بانتظار المراجعة').toList();

  List<EmployeeRecord> get active =>
      _employees.where((e) => e.status == 'نشط').toList();

  List<EmployeeRecord> get rejected =>
      _employees.where((e) => e.status == 'مرفوض').toList();

  EmployeeRecord? byId(int id) {
    for (final e in _employees) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<EmployeeFinanceLog> logsForEmployee(int employeeId) =>
      _financeLogs.where((l) => l.employeeId == employeeId).toList();

  Future<void> init() async {
    if (_initialized) return;
    final json = await SchoolDatabaseService.instance.readJson('employees');
    if (json != null) {
      _employees = (jsonDecode(json) as List<dynamic>)
          .map((e) => EmployeeRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final logsJson = await SchoolDatabaseService.instance.readJson('employee_finance_logs');
    if (logsJson != null) {
      _financeLogs = (jsonDecode(logsJson) as List<dynamic>)
          .map((e) => EmployeeFinanceLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _initialized = true;
  }

  Future<void> add(EmployeeRecord employee) async {
    _employees.insert(0, employee);
    await _persist();
  }

  Future<void> update(EmployeeRecord employee) async {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index < 0) return;
    _employees[index] = employee;
    await _persist();
  }

  Future<void> remove(int id) async {
    _employees.removeWhere((e) => e.id == id);
    _financeLogs.removeWhere((l) => l.employeeId == id);
    await _persist();
    await _persistLogs();
  }

  Future<void> addFinanceLog(EmployeeFinanceLog log) async {
    _financeLogs.insert(0, log);
    await _persistLogs();
  }

  Future<void> _persist() async {
    await SchoolDatabaseService.instance.saveJson(
      'employees',
      _employees.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> _persistLogs() async {
    await SchoolDatabaseService.instance.saveJson(
      'employee_finance_logs',
      _financeLogs.map((l) => l.toJson()).toList(),
    );
  }
}
