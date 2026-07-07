import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/school_models.dart';

class SchoolDatabaseService {
  SchoolDatabaseService._();

  static final SchoolDatabaseService instance = SchoolDatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'rose_school_2026.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            key TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveJson(String key, Object value) async {
    final db = await database;
    await db.insert(
      'records',
      <String, Object>{'key': key, 'payload': jsonEncode(value)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> readJson(String key) async {
    final db = await database;
    final rows = await db.query('records', where: 'key = ?', whereArgs: <Object>[key], limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['payload'] as String?;
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('records');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  List<Map<String, dynamic>> attachmentsToJson(List<StudentAttachment> items) {
    return items
        .map((item) => <String, dynamic>{
              'id': item.id,
              'studentId': item.studentId,
              'title': item.title,
              'category': item.category,
              'note': item.note,
              'originalFileName': item.originalFileName,
              'storedPath': item.storedPath,
              'uploadedAt': item.uploadedAt,
              'sizeBytes': item.sizeBytes,
            })
        .toList();
  }

  List<StudentAttachment> attachmentsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => StudentAttachment(
            id: (item['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            category: item['category'].toString(),
            note: item['note'].toString(),
            originalFileName: item['originalFileName']?.toString() ?? '',
            storedPath: item['storedPath']?.toString() ?? '',
            uploadedAt: item['uploadedAt']?.toString() ?? '',
            sizeBytes: (item['sizeBytes'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> backupsToJson(List<BackupEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'name': item.name,
              'createdAt': item.createdAt,
              'fileCount': item.fileCount,
              'studentCount': item.studentCount,
              'note': item.note,
            })
        .toList();
  }

  List<BackupEntry> backupsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => BackupEntry(
            name: item['name'].toString(),
            createdAt: item['createdAt'].toString(),
            fileCount: (item['fileCount'] as num).toInt(),
            studentCount: (item['studentCount'] as num).toInt(),
            note: item['note'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> messagesToJson(List<ParentMessageEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'type': item.type,
              'subject': item.subject,
              'body': item.body,
              'date': item.date,
              'time': item.time,
              'reason': item.reason,
              'guardianEmail': item.guardianEmail,
              'guardianWhatsapp': item.guardianWhatsapp,
            })
        .toList();
  }

  List<ParentMessageEntry> messagesFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => ParentMessageEntry(
            studentId: (item['studentId'] as num).toInt(),
            type: item['type'].toString(),
            subject: item['subject'].toString(),
            body: item['body'].toString(),
            date: item['date'].toString(),
            time: item['time']?.toString() ?? '',
            reason: item['reason']?.toString() ?? '',
            guardianEmail: item['guardianEmail']?.toString() ?? '',
            guardianWhatsapp: item['guardianWhatsapp']?.toString() ?? '',
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> attendanceToJson(List<AttendanceEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'status': item.status,
              'date': item.date,
              'note': item.note,
            })
        .toList();
  }

  List<AttendanceEntry> attendanceFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AttendanceEntry(
            studentId: (item['studentId'] as num).toInt(),
            status: item['status'].toString(),
            date: item['date'].toString(),
            note: item['note'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> disciplineToJson(List<DisciplineEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'type': item.type,
              'title': item.title,
              'note': item.note,
              'date': item.date,
            })
        .toList();
  }

  List<DisciplineEntry> disciplineFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => DisciplineEntry(
            studentId: (item['studentId'] as num).toInt(),
            type: item['type'].toString(),
            title: item['title'].toString(),
            note: item['note'].toString(),
            date: item['date'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> certificatesToJson(List<CertificateEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'title': item.title,
              'kind': item.kind,
              'date': item.date,
              'note': item.note,
            })
        .toList();
  }

  List<CertificateEntry> certificatesFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => CertificateEntry(
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            kind: item['kind'].toString(),
            date: item['date'].toString(),
            note: item['note'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> examSchedulesToJson(List<ExamScheduleEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'title': item.title,
              'grade': item.grade,
              'examDate': item.examDate,
              'period': item.period,
              'hall': item.hall,
            })
        .toList();
  }

  List<ExamScheduleEntry> examSchedulesFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => ExamScheduleEntry(
            title: item['title'].toString(),
            grade: item['grade'].toString(),
            examDate: item['examDate'].toString(),
            period: item['period'].toString(),
            hall: item['hall'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> examResultsToJson(List<ExamResultEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'subject': item.subject,
              'firstTermWork': item.firstTermWork,
              'firstTermExam': item.firstTermExam,
              'secondTermWork': item.secondTermWork,
              'secondTermExam': item.secondTermExam,
              'isManuallyReviewed': item.isManuallyReviewed,
            })
        .toList();
  }

  List<ExamResultEntry> examResultsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) {
            final legacyScore = (item['score'] as num?)?.toDouble() ?? 0;
            return ExamResultEntry(
              studentId: (item['studentId'] as num).toInt(),
              subject: item['subject'].toString(),
              firstTermWork: (item['firstTermWork'] as num?)?.toDouble() ?? legacyScore,
              firstTermExam: (item['firstTermExam'] as num?)?.toDouble() ?? 0,
              secondTermWork: (item['secondTermWork'] as num?)?.toDouble() ?? legacyScore,
              secondTermExam: (item['secondTermExam'] as num?)?.toDouble() ?? 0,
              isManuallyReviewed: item['isManuallyReviewed'] == true,
            );
          },
        )
        .toList();
  }


  List<Map<String, dynamic>> accountingDonationsToJson(List<AccountingDonationEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'title': item.title,
              'amount': item.amount,
              'currency': item.currency,
              'date': item.date,
              'donationKind': item.donationKind,
              'materialType': item.materialType,
              'quantity': item.quantity,
              'note': item.note,
            })
        .toList();
  }

  List<AccountingDonationEntry> accountingDonationsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AccountingDonationEntry(
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            amount: (item['amount'] as num).toDouble(),
            currency: item['currency'].toString(),
            date: item['date'].toString(),
            donationKind: item['donationKind']?.toString() ?? 'مادية',
            materialType: item['materialType']?.toString() ?? '',
            quantity: item['quantity']?.toString() ?? '',
            note: item['note']?.toString() ?? '',
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> accountingAidsToJson(List<AccountingAidEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'title': item.title,
              'amount': item.amount,
              'currency': item.currency,
              'date': item.date,
              'aidKind': item.aidKind,
              'materialType': item.materialType,
              'quantity': item.quantity,
              'note': item.note,
            })
        .toList();
  }

  List<AccountingAidEntry> accountingAidsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AccountingAidEntry(
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            amount: (item['amount'] as num).toDouble(),
            currency: item['currency'].toString(),
            date: item['date'].toString(),
            aidKind: item['aidKind']?.toString() ?? 'مادية',
            materialType: item['materialType']?.toString() ?? '',
            quantity: item['quantity']?.toString() ?? '',
            note: item['note']?.toString() ?? '',
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> invoicesToJson(List<AccountingInvoiceEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'title': item.title,
              'amount': item.amount,
              'currency': item.currency,
              'date': item.date,
            })
        .toList();
  }

  List<AccountingInvoiceEntry> invoicesFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AccountingInvoiceEntry(
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            amount: (item['amount'] as num).toDouble(),
            currency: item['currency'].toString(),
            date: item['date'].toString(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> receiptsToJson(List<AccountingReceiptEntry> items) {
    return items
        .map((item) => <String, dynamic>{
              'studentId': item.studentId,
              'title': item.title,
              'amount': item.amount,
              'currency': item.currency,
              'date': item.date,
              'note': item.note,
            })
        .toList();
  }

  List<AccountingReceiptEntry> receiptsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AccountingReceiptEntry(
            studentId: (item['studentId'] as num).toInt(),
            title: item['title'].toString(),
            amount: (item['amount'] as num).toDouble(),
            currency: item['currency'].toString(),
            date: item['date'].toString(),
            note: item['note'].toString(),
          ),
        )
        .toList();
  }

  Map<String, dynamic> schoolIdentityToJson(SchoolIdentityEntry identity) {
    return <String, dynamic>{
      'email': identity.email,
      'whatsapp': identity.whatsapp,
      'mobile': identity.mobile,
      'landline': identity.landline,
      'website': identity.website,
      'facebookPage': identity.facebookPage,
      'secretaryName': identity.secretaryName,
      'supervisorName': identity.supervisorName,
      'principalName': identity.principalName,
    };
  }

  SchoolIdentityEntry schoolIdentityFromJson(Map<String, dynamic> item) {
    return SchoolIdentityEntry(
      email: item['email']?.toString() ?? '',
      whatsapp: item['whatsapp']?.toString() ?? '',
      mobile: item['mobile']?.toString() ?? '',
      landline: item['landline']?.toString() ?? '',
      website: item['website']?.toString() ?? '',
      facebookPage: item['facebookPage']?.toString() ?? '',
      secretaryName: item['secretaryName']?.toString() ?? '',
      supervisorName: item['supervisorName']?.toString() ?? '',
      principalName: item['principalName']?.toString() ?? '',
    );
  }

  List<Map<String, dynamic>> adminUsersToJson(List<AdminUserEntry> users) {
    return users
        .map((user) => <String, dynamic>{
              'id': user.id,
              'username': user.username,
              'password': user.password,
              'email': user.email,
              'mobile': user.mobile,
              'permissions': user.permissions,
            })
        .toList();
  }

  List<AdminUserEntry> adminUsersFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => AdminUserEntry(
            id: (item['id'] as num).toInt(),
            username: item['username'].toString(),
            password: item['password'].toString(),
            email: item['email'].toString(),
            mobile: item['mobile'].toString(),
            permissions: (item['permissions'] as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> studentsToJson(List<StudentRecord> students) {
    return students
        .map(
          (student) => <String, dynamic>{
            'id': student.id,
            'serial': student.serial,
            'fullName': student.fullName,
            'fatherName': student.fatherName,
            'motherName': student.motherName,
            'grandfatherName': student.grandfatherName,
            'guardianName': student.guardianName,
            'guardianRelation': student.guardianRelation,
            'guardianPhone': student.guardianPhone,
            'guardianMobile': student.guardianMobile,
            'guardianWhatsapp': student.guardianWhatsapp,
            'guardianEmail': student.guardianEmail,
            'guardianWork': student.guardianWork,
            'guardianAddress': student.guardianAddress,
            'emergencyContactName': student.emergencyContactName,
            'emergencyContactPhone': student.emergencyContactPhone,
            'grade': student.grade,
            'section': student.section,
            'gender': student.gender,
            'status': student.status,
            'birthPlace': student.birthPlace,
            'birthDate': student.birthDate,
            'registryPlace': student.registryPlace,
            'registryNumber': student.registryNumber,
            'religion': student.religion,
            'bloodType': student.bloodType,
            'enrollmentDate': student.enrollmentDate,
            'enrollmentType': student.enrollmentType,
            'enrollmentGrade': student.enrollmentGrade,
            'schoolYear': student.schoolYear,
            'previousSchool': student.previousSchool,
            'failedGrades': student.failedGrades,
            'firstLanguage': student.firstLanguage,
            'firstLanguageOther': student.firstLanguageOther,
            'secondLanguage': student.secondLanguage,
            'secondLanguageOther': student.secondLanguageOther,
            'spokenLanguage': student.spokenLanguage,
            'spokenLanguageOther': student.spokenLanguageOther,
            'otherLanguage': student.otherLanguage,
            'residence': student.residence,
            'landline': student.landline,
            'mobile': student.mobile,
            'email': student.email,
            'studentPhotoPath': student.studentPhotoPath,
            'qrFilePath': student.qrFilePath,
            'studentCardPdfPath': student.studentCardPdfPath,
            'studentCardPngPath': student.studentCardPngPath,
            'transportGathering': student.transportGathering,
            'transportSubscription': student.transportSubscription,
            'normalLife': student.normalLife,
            'orphanFather': student.orphanFather,
            'orphanMother': student.orphanMother,
            'orphanParents': student.orphanParents,
            'onlyChild': student.onlyChild,
            'livesSeparate': student.livesSeparate,
            'hobbyMusic': student.hobbyMusic,
            'hobbyDrawing': student.hobbyDrawing,
            'hobbyComputer': student.hobbyComputer,
            'hobbySports': student.hobbySports,
            'otherHobbies': student.otherHobbies,
            'initiativeSchool': student.initiativeSchool,
            'initiativeFinancial': student.initiativeFinancial,
            'initiativeInKind': student.initiativeInKind,
            'initiativeProjects': student.initiativeProjects,
            'healthStatus': student.healthStatus,
            'disabilityVisual': student.disabilityVisual,
            'disabilityHearing': student.disabilityHearing,
            'disabilityMotor': student.disabilityMotor,
            'disabilityLearning': student.disabilityLearning,
            'healthNotes': student.healthNotes,
            'notes': student.notes,
            'transferNotes': student.transferNotes,
            'transportFees': student.transportFees.map((e) => {'dueAmount': e.dueAmount, 'paidAmount': e.paidAmount, 'currency': e.currency, 'paymentDate': e.paymentDate}).toList(),
            'regularFees': student.regularFees.map((e) => {'dueAmount': e.dueAmount, 'paidAmount': e.paidAmount, 'currency': e.currency, 'paymentDate': e.paymentDate}).toList(),
          },
        )
        .toList();
  }

  List<StudentRecord> studentsFromJson(List<dynamic> items) {
    return items
        .map(
          (item) => StudentRecord(
            id: (item['id'] as num).toInt(),
            serial: item['serial'].toString(),
            fullName: item['fullName'].toString(),
            fatherName: item['fatherName'].toString(),
            motherName: item['motherName'].toString(),
            grandfatherName: item['grandfatherName'].toString(),
            guardianName: item['guardianName'].toString(),
            guardianRelation: item['guardianRelation'].toString(),
            guardianPhone: item['guardianPhone'].toString(),
            guardianMobile: item['guardianMobile'].toString(),
            guardianWhatsapp: item['guardianWhatsapp']?.toString() ?? '',
            guardianEmail: item['guardianEmail']?.toString() ?? '',
            guardianWork: item['guardianWork'].toString(),
            guardianAddress: item['guardianAddress'].toString(),
            emergencyContactName: item['emergencyContactName'].toString(),
            emergencyContactPhone: item['emergencyContactPhone'].toString(),
            grade: item['grade'].toString(),
            section: item['section'].toString(),
            gender: item['gender'].toString(),
            status: item['status'].toString(),
            birthPlace: item['birthPlace'].toString(),
            birthDate: item['birthDate'].toString(),
            registryPlace: item['registryPlace'].toString(),
            registryNumber: item['registryNumber'].toString(),
            religion: item['religion'].toString(),
            bloodType: item['bloodType'].toString(),
            enrollmentDate: item['enrollmentDate'].toString(),
            enrollmentType: item['enrollmentType']?.toString() ?? 'طالب جديد',
            enrollmentGrade: item['enrollmentGrade'].toString(),
            schoolYear: item['schoolYear']?.toString() ?? '',
            previousSchool: item['previousSchool'].toString(),
            failedGrades: item['failedGrades'].toString(),
            firstLanguage: item['firstLanguage'].toString(),
            firstLanguageOther: item['firstLanguageOther'].toString(),
            secondLanguage: item['secondLanguage'].toString(),
            secondLanguageOther: item['secondLanguageOther'].toString(),
            spokenLanguage: item['spokenLanguage'].toString(),
            spokenLanguageOther: item['spokenLanguageOther'].toString(),
            otherLanguage: item['otherLanguage'].toString(),
            residence: item['residence'].toString(),
            landline: item['landline'].toString(),
            mobile: item['mobile'].toString(),
            email: item['email'].toString(),
            studentPhotoPath: item['studentPhotoPath']?.toString() ?? '',
            qrFilePath: item['qrFilePath']?.toString() ?? '',
            studentCardPdfPath: item['studentCardPdfPath']?.toString() ?? '',
            studentCardPngPath: item['studentCardPngPath']?.toString() ?? '',
            transportGathering: item['transportGathering'].toString(),
            transportSubscription: item['transportSubscription'].toString(),
            normalLife: item['normalLife'] as bool,
            orphanFather: item['orphanFather'] as bool,
            orphanMother: item['orphanMother'] as bool,
            orphanParents: item['orphanParents'] as bool,
            onlyChild: item['onlyChild'] as bool,
            livesSeparate: item['livesSeparate'] as bool,
            hobbyMusic: item['hobbyMusic'] as bool,
            hobbyDrawing: item['hobbyDrawing'] as bool,
            hobbyComputer: item['hobbyComputer'] as bool,
            hobbySports: item['hobbySports'] as bool,
            otherHobbies: item['otherHobbies'].toString(),
            initiativeSchool: item['initiativeSchool'] as bool,
            initiativeFinancial: item['initiativeFinancial'] as bool,
            initiativeInKind: item['initiativeInKind'] as bool,
            initiativeProjects: item['initiativeProjects'] as bool,
            healthStatus: item['healthStatus'].toString(),
            disabilityVisual: item['disabilityVisual'] as bool,
            disabilityHearing: item['disabilityHearing'] as bool,
            disabilityMotor: item['disabilityMotor'] as bool,
            disabilityLearning: item['disabilityLearning'] as bool,
            healthNotes: item['healthNotes'].toString(),
            notes: item['notes'].toString(),
            transferNotes: item['transferNotes'].toString(),
            transportFees: (item['transportFees'] as List<dynamic>).map((e) => PaymentEntry(dueAmount: e['dueAmount'].toString(), paidAmount: e['paidAmount'].toString(), currency: e['currency'].toString(), paymentDate: e['paymentDate'].toString())).toList(),
            regularFees: (item['regularFees'] as List<dynamic>).map((e) => PaymentEntry(dueAmount: e['dueAmount'].toString(), paidAmount: e['paidAmount'].toString(), currency: e['currency'].toString(), paymentDate: e['paymentDate'].toString())).toList(),
          ),
        )
        .toList();
  }
}
