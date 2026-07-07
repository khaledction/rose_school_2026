import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/finance_models.dart';
import '../models/school_models.dart';
import 'app_storage_paths_service.dart';
import 'school_database_service.dart';

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  // ─── JSON Export ──────────────────────────────────────────────

  Future<String> exportAllToJson() async {
    final db = SchoolDatabaseService.instance;
    final data = <String, dynamic>{};

    final keys = [
      'students', 'attachments', 'backups', 'messages', 'attendance',
      'discipline', 'certificates', 'exam_schedule', 'exam_results',
      'invoices', 'accounting_donations', 'accounting_aids', 'receipts',
      'admin_users', 'school_identity', 'employees', 'employee_finance_logs',
      'notifications', 'parent_meetings', 'finance_categories', 'finance_entries',
    ];

    for (final key in keys) {
      final json = await db.readJson(key);
      if (json != null) {
        data[key] = jsonDecode(json);
      }
    }

    data['exportedAt'] = DateTime.now().toIso8601String();
    data['appVersion'] = '1.0.0';
    data['schoolName'] = 'Rose School 2026';

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final paths = AppStoragePathsService.instance;
    final reportsDir = await paths.reportsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reportsDir.path, 'data_snapshot_$timestamp.json');
    await File(filePath).writeAsString(jsonStr, flush: true);

    return filePath;
  }

  // ─── CSV Export ───────────────────────────────────────────────

  Future<String> exportStudentsToCsv() async {
    final db = SchoolDatabaseService.instance;
    final studentsJson = await db.readJson('students');
    if (studentsJson == null) return '';

    final students = (jsonDecode(studentsJson) as List<dynamic>)
        .map((e) => StudentRecord(
              id: (e['id'] as num).toInt(),
              serial: e['serial']?.toString() ?? '',
              fullName: e['fullName']?.toString() ?? '',
              fatherName: e['fatherName']?.toString() ?? '',
              motherName: e['motherName']?.toString() ?? '',
              grandfatherName: e['grandfatherName']?.toString() ?? '',
              guardianName: e['guardianName']?.toString() ?? '',
              guardianRelation: e['guardianRelation']?.toString() ?? '',
              guardianPhone: e['guardianPhone']?.toString() ?? '',
              guardianMobile: e['guardianMobile']?.toString() ?? '',
              guardianWhatsapp: e['guardianWhatsapp']?.toString() ?? '',
              guardianEmail: e['guardianEmail']?.toString() ?? '',
              guardianWork: e['guardianWork']?.toString() ?? '',
              guardianAddress: e['guardianAddress']?.toString() ?? '',
              emergencyContactName: e['emergencyContactName']?.toString() ?? '',
              emergencyContactPhone: e['emergencyContactPhone']?.toString() ?? '',
              grade: e['grade']?.toString() ?? '',
              section: e['section']?.toString() ?? '',
              gender: e['gender']?.toString() ?? '',
              status: e['status']?.toString() ?? '',
              birthPlace: e['birthPlace']?.toString() ?? '',
              birthDate: e['birthDate']?.toString() ?? '',
              registryPlace: e['registryPlace']?.toString() ?? '',
              registryNumber: e['registryNumber']?.toString() ?? '',
              religion: e['religion']?.toString() ?? '',
              bloodType: e['bloodType']?.toString() ?? '',
              enrollmentDate: e['enrollmentDate']?.toString() ?? '',
              enrollmentType: e['enrollmentType']?.toString() ?? 'طالب جديد',
              enrollmentGrade: e['enrollmentGrade']?.toString() ?? '',
              schoolYear: e['schoolYear']?.toString() ?? '',
              previousSchool: e['previousSchool']?.toString() ?? '',
              failedGrades: e['failedGrades']?.toString() ?? '',
              firstLanguage: e['firstLanguage']?.toString() ?? '',
              firstLanguageOther: e['firstLanguageOther']?.toString() ?? '',
              secondLanguage: e['secondLanguage']?.toString() ?? '',
              secondLanguageOther: e['secondLanguageOther']?.toString() ?? '',
              spokenLanguage: e['spokenLanguage']?.toString() ?? '',
              spokenLanguageOther: e['spokenLanguageOther']?.toString() ?? '',
              otherLanguage: e['otherLanguage']?.toString() ?? '',
              residence: e['residence']?.toString() ?? '',
              landline: e['landline']?.toString() ?? '',
              mobile: e['mobile']?.toString() ?? '',
              email: e['email']?.toString() ?? '',
              studentPhotoPath: e['studentPhotoPath']?.toString() ?? '',
              qrFilePath: e['qrFilePath']?.toString() ?? '',
              studentCardPdfPath: e['studentCardPdfPath']?.toString() ?? '',
              studentCardPngPath: e['studentCardPngPath']?.toString() ?? '',
              transportGathering: e['transportGathering']?.toString() ?? '',
              transportSubscription: e['transportSubscription']?.toString() ?? '',
              normalLife: e['normalLife'] == true,
              orphanFather: e['orphanFather'] == true,
              orphanMother: e['orphanMother'] == true,
              orphanParents: e['orphanParents'] == true,
              onlyChild: e['onlyChild'] == true,
              livesSeparate: e['livesSeparate'] == true,
              hobbyMusic: e['hobbyMusic'] == true,
              hobbyDrawing: e['hobbyDrawing'] == true,
              hobbyComputer: e['hobbyComputer'] == true,
              hobbySports: e['hobbySports'] == true,
              otherHobbies: e['otherHobbies']?.toString() ?? '',
              initiativeSchool: e['initiativeSchool'] == true,
              initiativeFinancial: e['initiativeFinancial'] == true,
              initiativeInKind: e['initiativeInKind'] == true,
              initiativeProjects: e['initiativeProjects'] == true,
              healthStatus: e['healthStatus']?.toString() ?? '',
              disabilityVisual: e['disabilityVisual'] == true,
              disabilityHearing: e['disabilityHearing'] == true,
              disabilityMotor: e['disabilityMotor'] == true,
              disabilityLearning: e['disabilityLearning'] == true,
              healthNotes: e['healthNotes']?.toString() ?? '',
              notes: e['notes']?.toString() ?? '',
              transferNotes: e['transferNotes']?.toString() ?? '',
              transportFees: [],
              regularFees: [],
            ))
        .toList();

    final headers = [
      'التسلسل', 'الاسم', 'اسم الأب', 'اسم الأم', 'الصف', 'الشعبة',
      'الجنس', 'الحالة', 'تاريخ الميلاد', 'مكان الولادة',
      'رقم الموبايل', 'ولي الأمر', 'هاتف ولي الأمر',
    ];

    final rows = students.map((s) => [
      s.serial, s.fullName, s.fatherName, s.motherName,
      s.grade, s.section, s.gender, s.status,
      s.birthDate, s.birthPlace, s.mobile,
      s.guardianName, s.guardianMobile,
    ]).toList();

    final csv = _buildCsv(headers, rows);
    final paths = AppStoragePathsService.instance;
    final reportsDir = await paths.reportsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reportsDir.path, 'students_export_$timestamp.csv');
    await File(filePath).writeAsString(csv, flush: true);

    return filePath;
  }

  Future<String> exportAccountingToCsv() async {
    final db = SchoolDatabaseService.instance;
    final invoicesJson = await db.readJson('invoices');
    final donationsJson = await db.readJson('accounting_donations');
    final aidsJson = await db.readJson('accounting_aids');

    final headers = ['النوع', 'الطالب', 'العنوان', 'المبلغ', 'العملة', 'التاريخ', 'ملاحظات'];
    final rows = <List<String>>[];

    if (invoicesJson != null) {
      final items = jsonDecode(invoicesJson) as List<dynamic>;
      for (final item in items) {
        rows.add([
          'قسط',
          (item['studentId'] as num?)?.toString() ?? '',
          item['title']?.toString() ?? '',
          (item['amount'] as num?)?.toString() ?? '0',
          item['currency']?.toString() ?? '',
          item['date']?.toString() ?? '',
          '',
        ]);
      }
    }

    if (donationsJson != null) {
      final items = jsonDecode(donationsJson) as List<dynamic>;
      for (final item in items) {
        rows.add([
          'تبرع',
          (item['studentId'] as num?)?.toString() ?? '',
          item['title']?.toString() ?? '',
          (item['amount'] as num?)?.toString() ?? '0',
          item['currency']?.toString() ?? '',
          item['date']?.toString() ?? '',
          item['note']?.toString() ?? '',
        ]);
      }
    }

    final csv = _buildCsv(headers, rows);
    final paths = AppStoragePathsService.instance;
    final reportsDir = await paths.reportsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reportsDir.path, 'accounting_export_$timestamp.csv');
    await File(filePath).writeAsString(csv, flush: true);

    return filePath;
  }

  Future<String> exportExamResultsToCsv() async {
    final db = SchoolDatabaseService.instance;
    final resultsJson = await db.readJson('exam_results');
    if (resultsJson == null) return '';

    final results = jsonDecode(resultsJson) as List<dynamic>;
    final headers = ['الطالب', 'المادة', 'أعمال أول', 'امتحان أول', 'أعمال ثان', 'امتحان ثان', 'مدقق'];
    final rows = results.map((item) => [
      (item['studentId'] as num?)?.toString() ?? '',
      item['subject']?.toString() ?? '',
      (item['firstTermWork'] as num?)?.toString() ?? '0',
      (item['firstTermExam'] as num?)?.toString() ?? '0',
      (item['secondTermWork'] as num?)?.toString() ?? '0',
      (item['secondTermExam'] as num?)?.toString() ?? '0',
      item['isManuallyReviewed'] == true ? 'نعم' : 'لا',
    ]).toList();

    final csv = _buildCsv(headers, rows);
    final paths = AppStoragePathsService.instance;
    final reportsDir = await paths.reportsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reportsDir.path, 'exam_results_export_$timestamp.csv');
    await File(filePath).writeAsString(csv, flush: true);

    return filePath;
  }

  Future<String> exportFinanceToCsv() async {
    final service = FinanceService.instance;
    final summary = service.thisMonthSummary;

    final headers = ['التصنيف', 'النوع', 'المبلغ'];
    final rows = <List<String>>[];

    for (final entry in summary.incomeByCategory.entries) {
      rows.add([entry.key, 'إيراد', entry.value.toStringAsFixed(0)]);
    }
    for (final entry in summary.expensesByCategory.entries) {
      rows.add([entry.key, 'صرفية', entry.value.toStringAsFixed(0)]);
    }
    rows.add(['', 'صافي', summary.netIncome.toStringAsFixed(0)]);

    final csv = _buildCsv(headers, rows);
    final paths = AppStoragePathsService.instance;
    final reportsDir = await paths.reportsDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reportsDir.path, 'finance_summary_$timestamp.csv');
    await File(filePath).writeAsString(csv, flush: true);

    return filePath;
  }

  String _buildCsv(List<String> headers, List<List<String>> rows) {
    final buf = StringBuffer();
    buf.writeln(headers.map((h) => _csvEscape(h)).join(','));
    for (final row in rows) {
      buf.writeln(row.map((cell) => _csvEscape(cell)).join(','));
    }
    return buf.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
