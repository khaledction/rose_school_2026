// ─── Income Categories ──────────────────────────────────────────

class IncomeCategory {
  const IncomeCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDefault': isDefault,
      };

  factory IncomeCategory.fromJson(Map<String, dynamic> json) => IncomeCategory(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        isDefault: json['isDefault'] == true,
      );
}

const List<IncomeCategory> kDefaultIncomeCategories = [
  IncomeCategory(id: 'tuition', name: 'أقساط دراسية', isDefault: true),
  IncomeCategory(id: 'donations', name: 'تبرعات', isDefault: true),
  IncomeCategory(id: 'aids', name: 'مساعدات', isDefault: true),
  IncomeCategory(id: 'cafeteria', name: 'مقصف', isDefault: true),
  IncomeCategory(id: 'activities', name: 'أنشطة', isDefault: true),
  IncomeCategory(id: 'other_income', name: 'آخر', isDefault: true),
];

// ─── Expense Categories ─────────────────────────────────────────

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDefault': isDefault,
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => ExpenseCategory(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        isDefault: json['isDefault'] == true,
      );
}

const List<ExpenseCategory> kDefaultExpenseCategories = [
  ExpenseCategory(id: 'salaries', name: 'رواتب و أجور', isDefault: true),
  ExpenseCategory(id: 'electricity', name: 'فواتير كهرباء', isDefault: true),
  ExpenseCategory(id: 'water', name: 'فواتير ماء', isDefault: true),
  ExpenseCategory(id: 'internet', name: 'فواتير إنترنت', isDefault: true),
  ExpenseCategory(id: 'maintenance', name: 'صيانة', isDefault: true),
  ExpenseCategory(id: 'stationery', name: 'قرطاسية', isDefault: true),
  ExpenseCategory(id: 'rent', name: 'إيجار', isDefault: true),
  ExpenseCategory(id: 'other_expense', name: 'أخرى', isDefault: true),
];

// ─── Income Entry ───────────────────────────────────────────────

class IncomeEntry {
  const IncomeEntry({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    this.currency = 'ليرة سورية',
    required this.date,
    this.description = '',
    this.studentId,
    this.studentName = '',
    this.createdBy = '',
    this.createdAt = '',
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final double amount;
  final String currency;
  final String date;
  final String description;
  final int? studentId;
  final String studentName;
  final String createdBy;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'amount': amount,
        'currency': currency,
        'date': date,
        'description': description,
        'studentId': studentId,
        'studentName': studentName,
        'createdBy': createdBy,
        'createdAt': createdAt,
      };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
        id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        categoryId: json['categoryId']?.toString() ?? '',
        categoryName: json['categoryName']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'ليرة سورية',
        date: json['date']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        studentId: (json['studentId'] as num?)?.toInt(),
        studentName: json['studentName']?.toString() ?? '',
        createdBy: json['createdBy']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

// ─── Expense Entry ──────────────────────────────────────────────

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    this.currency = 'ليرة سورية',
    required this.date,
    this.description = '',
    this.employeeId,
    this.employeeName = '',
    this.attachmentPath = '',
    this.createdBy = '',
    this.createdAt = '',
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final double amount;
  final String currency;
  final String date;
  final String description;
  final int? employeeId;
  final String employeeName;
  final String attachmentPath;
  final String createdBy;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'amount': amount,
        'currency': currency,
        'date': date,
        'description': description,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'attachmentPath': attachmentPath,
        'createdBy': createdBy,
        'createdAt': createdAt,
      };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) => ExpenseEntry(
        id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        categoryId: json['categoryId']?.toString() ?? '',
        categoryName: json['categoryName']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'ليرة سورية',
        date: json['date']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        employeeId: (json['employeeId'] as num?)?.toInt(),
        employeeName: json['employeeName']?.toString() ?? '',
        attachmentPath: json['attachmentPath']?.toString() ?? '',
        createdBy: json['createdBy']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

// ─── Financial Summary ──────────────────────────────────────────

class FinancialSummary {
  const FinancialSummary({
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.netIncome = 0,
    this.incomeByCategory = const {},
    this.expensesByCategory = const {},
  });

  final double totalIncome;
  final double totalExpenses;
  final double netIncome;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expensesByCategory;
}
