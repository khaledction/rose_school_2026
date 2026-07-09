class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.nationality,
    required this.birthDate,
    required this.residence,
    required this.mobile,
    required this.email,
    required this.qualification,
    required this.specialization,
    required this.hireDate,
    required this.jobType,
    required this.department,
    this.gender = 'ذكر',
    this.photoPath = '',
    this.notes = '',
    this.status = 'بانتظار المراجعة',
    this.rejectionReason = '',
    // ─── Finance fields (admin only) ───
    this.salary = 0,
    this.hourlyRate = 0,
    this.workingHours = 0,
    this.bonuses = 0,
    this.deductions = 0,
    this.financeNotes = '',
    this.financeUpdatedAt = '',
  });

  final int id;
  final String fullName;
  final String nationalId;
  final String nationality;
  final String birthDate;
  final String residence;
  final String mobile;
  final String email;
  final String qualification;
  final String specialization;
  final String hireDate;
  final String jobType;
  final String department;
  final String gender; // ذكر | أنثى
  final String photoPath;
  final String notes;
  final String status; // 'بانتظار المراجعة', 'نشط', 'مرفوض'
  final String rejectionReason;
  final double salary;
  final double hourlyRate;
  final double workingHours;
  final double bonuses;
  final double deductions;
  final String financeNotes;
  final String financeUpdatedAt;

  double get monthlyTotal => (salary) + (hourlyRate * workingHours) + bonuses - deductions;

  EmployeeRecord copyWith({
    int? id,
    String? fullName,
    String? nationalId,
    String? nationality,
    String? birthDate,
    String? residence,
    String? mobile,
    String? email,
    String? qualification,
    String? specialization,
    String? hireDate,
    String? jobType,
    String? department,
    String? gender,
    String? photoPath,
    String? notes,
    String? status,
    String? rejectionReason,
    double? salary,
    double? hourlyRate,
    double? workingHours,
    double? bonuses,
    double? deductions,
    String? financeNotes,
    String? financeUpdatedAt,
  }) {
    return EmployeeRecord(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      nationality: nationality ?? this.nationality,
      birthDate: birthDate ?? this.birthDate,
      residence: residence ?? this.residence,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      hireDate: hireDate ?? this.hireDate,
      jobType: jobType ?? this.jobType,
      department: department ?? this.department,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      salary: salary ?? this.salary,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      workingHours: workingHours ?? this.workingHours,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      financeNotes: financeNotes ?? this.financeNotes,
      financeUpdatedAt: financeUpdatedAt ?? this.financeUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'nationalId': nationalId,
        'nationality': nationality,
        'birthDate': birthDate,
        'residence': residence,
        'mobile': mobile,
        'email': email,
        'qualification': qualification,
        'specialization': specialization,
        'hireDate': hireDate,
        'jobType': jobType,
        'department': department,
        'gender': gender,
        'photoPath': photoPath,
        'notes': notes,
        'status': status,
        'rejectionReason': rejectionReason,
        'salary': salary,
        'hourlyRate': hourlyRate,
        'workingHours': workingHours,
        'bonuses': bonuses,
        'deductions': deductions,
        'financeNotes': financeNotes,
        'financeUpdatedAt': financeUpdatedAt,
      };

  factory EmployeeRecord.fromJson(Map<String, dynamic> json) => EmployeeRecord(
        id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        fullName: json['fullName']?.toString() ?? '',
        nationalId: json['nationalId']?.toString() ?? '',
        nationality: json['nationality']?.toString() ?? '',
        birthDate: json['birthDate']?.toString() ?? '',
        residence: json['residence']?.toString() ?? '',
        mobile: json['mobile']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        qualification: json['qualification']?.toString() ?? '',
        specialization: json['specialization']?.toString() ?? '',
        hireDate: json['hireDate']?.toString() ?? '',
        jobType: json['jobType']?.toString() ?? '',
        department: json['department']?.toString() ?? '',
        gender: json['gender']?.toString() ?? 'ذكر',
        photoPath: json['photoPath']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
        status: json['status']?.toString() ?? 'بانتظار المراجعة',
        rejectionReason: json['rejectionReason']?.toString() ?? '',
        salary: (json['salary'] as num?)?.toDouble() ?? 0,
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
        workingHours: (json['workingHours'] as num?)?.toDouble() ?? 0,
        bonuses: (json['bonuses'] as num?)?.toDouble() ?? 0,
        deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
        financeNotes: json['financeNotes']?.toString() ?? '',
        financeUpdatedAt: json['financeUpdatedAt']?.toString() ?? '',
      );
}

/// Finance transaction record for employee (salary change, bonus, etc.)
class EmployeeFinanceLog {
  const EmployeeFinanceLog({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.amount,
    required this.oldValue,
    required this.newValue,
    required this.note,
    required this.createdAt,
    required this.createdBy,
  });

  final String id;
  final int employeeId;
  final String type; // 'salary_change', 'bonus', 'deduction', 'hourly_rate_change', 'hours_change'
  final double amount;
  final String oldValue;
  final String newValue;
  final String note;
  final String createdAt;
  final String createdBy;

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'type': type,
        'amount': amount,
        'oldValue': oldValue,
        'newValue': newValue,
        'note': note,
        'createdAt': createdAt,
        'createdBy': createdBy,
      };

  factory EmployeeFinanceLog.fromJson(Map<String, dynamic> json) => EmployeeFinanceLog(
        id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
        type: json['type']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        oldValue: json['oldValue']?.toString() ?? '',
        newValue: json['newValue']?.toString() ?? '',
        note: json['note']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        createdBy: json['createdBy']?.toString() ?? '',
      );
}

/// Constants for job types
const List<String> kJobTypes = [
  'معلم',
  'إداري',
  'فني',
  'حارس',
  'عامل',
  'أخرى',
];

/// Constants for employee statuses
const List<String> kEmployeeStatuses = [
  'بانتظار المراجعة',
  'نشط',
  'مرفوض',
];
