class PaymentEntry {
  const PaymentEntry({
    required this.dueAmount,
    required this.paidAmount,
    required this.currency,
    required this.paymentDate,
  });

  final String dueAmount;
  final String paidAmount;
  final String currency;
  final String paymentDate;

  PaymentEntry copyWith({
    String? dueAmount,
    String? paidAmount,
    String? currency,
    String? paymentDate,
  }) {
    return PaymentEntry(
      dueAmount: dueAmount ?? this.dueAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      currency: currency ?? this.currency,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}

class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.serial,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.grandfatherName,
    required this.guardianName,
    required this.guardianRelation,
    required this.guardianPhone,
    required this.guardianMobile,
    required this.guardianWhatsapp,
    required this.guardianEmail,
    required this.guardianWork,
    required this.guardianAddress,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.grade,
    required this.section,
    required this.gender,
    required this.status,
    required this.birthPlace,
    required this.birthDate,
    required this.registryPlace,
    required this.registryNumber,
    required this.religion,
    required this.bloodType,
    required this.enrollmentDate,
    required this.enrollmentType,
    required this.enrollmentGrade,
    required this.schoolYear,
    required this.previousSchool,
    required this.failedGrades,
    required this.firstLanguage,
    required this.firstLanguageOther,
    required this.secondLanguage,
    required this.secondLanguageOther,
    required this.spokenLanguage,
    required this.spokenLanguageOther,
    required this.otherLanguage,
    required this.residence,
    required this.landline,
    required this.mobile,
    required this.email,
    required this.studentPhotoPath,
    required this.qrFilePath,
    required this.studentCardPdfPath,
    required this.studentCardPngPath,
    required this.transportGathering,
    required this.transportSubscription,
    required this.normalLife,
    required this.orphanFather,
    required this.orphanMother,
    required this.orphanParents,
    required this.onlyChild,
    required this.livesSeparate,
    required this.hobbyMusic,
    required this.hobbyDrawing,
    required this.hobbyComputer,
    required this.hobbySports,
    required this.otherHobbies,
    required this.initiativeSchool,
    required this.initiativeFinancial,
    required this.initiativeInKind,
    required this.initiativeProjects,
    required this.healthStatus,
    required this.disabilityVisual,
    required this.disabilityHearing,
    required this.disabilityMotor,
    required this.disabilityLearning,
    required this.healthNotes,
    required this.notes,
    required this.transferNotes,
    required this.transportFees,
    required this.regularFees,
  });

  final int id;
  final String serial;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String grandfatherName;
  final String guardianName;
  final String guardianRelation;
  final String guardianPhone;
  final String guardianMobile;
  final String guardianWhatsapp;
  final String guardianEmail;
  final String guardianWork;
  final String guardianAddress;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String grade;
  final String section;
  final String gender;
  final String status;
  final String birthPlace;
  final String birthDate;
  final String registryPlace;
  final String registryNumber;
  final String religion;
  final String bloodType;
  final String enrollmentDate;
  final String enrollmentType;
  final String enrollmentGrade;
  final String schoolYear;
  final String previousSchool;
  final String failedGrades;
  final String firstLanguage;
  final String firstLanguageOther;
  final String secondLanguage;
  final String secondLanguageOther;
  final String spokenLanguage;
  final String spokenLanguageOther;
  final String otherLanguage;
  final String residence;
  final String landline;
  final String mobile;
  final String email;
  final String studentPhotoPath;
  final String qrFilePath;
  final String studentCardPdfPath;
  final String studentCardPngPath;
  final String transportGathering;
  final String transportSubscription;
  final bool normalLife;
  final bool orphanFather;
  final bool orphanMother;
  final bool orphanParents;
  final bool onlyChild;
  final bool livesSeparate;
  final bool hobbyMusic;
  final bool hobbyDrawing;
  final bool hobbyComputer;
  final bool hobbySports;
  final String otherHobbies;
  final bool initiativeSchool;
  final bool initiativeFinancial;
  final bool initiativeInKind;
  final bool initiativeProjects;
  final String healthStatus;
  final bool disabilityVisual;
  final bool disabilityHearing;
  final bool disabilityMotor;
  final bool disabilityLearning;
  final String healthNotes;
  final String notes;
  final String transferNotes;
  final List<PaymentEntry> transportFees;
  final List<PaymentEntry> regularFees;

  StudentRecord copyWith({
    int? id,
    String? serial,
    String? fullName,
    String? fatherName,
    String? motherName,
    String? grandfatherName,
    String? guardianName,
    String? guardianRelation,
    String? guardianPhone,
    String? guardianMobile,
    String? guardianWhatsapp,
    String? guardianEmail,
    String? guardianWork,
    String? guardianAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? grade,
    String? section,
    String? gender,
    String? status,
    String? birthPlace,
    String? birthDate,
    String? registryPlace,
    String? registryNumber,
    String? religion,
    String? bloodType,
    String? enrollmentDate,
    String? enrollmentType,
    String? enrollmentGrade,
    String? schoolYear,
    String? previousSchool,
    String? failedGrades,
    String? firstLanguage,
    String? firstLanguageOther,
    String? secondLanguage,
    String? secondLanguageOther,
    String? spokenLanguage,
    String? spokenLanguageOther,
    String? otherLanguage,
    String? residence,
    String? landline,
    String? mobile,
    String? email,
    String? studentPhotoPath,
    String? qrFilePath,
    String? studentCardPdfPath,
    String? studentCardPngPath,
    String? transportGathering,
    String? transportSubscription,
    bool? normalLife,
    bool? orphanFather,
    bool? orphanMother,
    bool? orphanParents,
    bool? onlyChild,
    bool? livesSeparate,
    bool? hobbyMusic,
    bool? hobbyDrawing,
    bool? hobbyComputer,
    bool? hobbySports,
    String? otherHobbies,
    bool? initiativeSchool,
    bool? initiativeFinancial,
    bool? initiativeInKind,
    bool? initiativeProjects,
    String? healthStatus,
    bool? disabilityVisual,
    bool? disabilityHearing,
    bool? disabilityMotor,
    bool? disabilityLearning,
    String? healthNotes,
    String? notes,
    String? transferNotes,
    List<PaymentEntry>? transportFees,
    List<PaymentEntry>? regularFees,
  }) {
    return StudentRecord(
      id: id ?? this.id,
      serial: serial ?? this.serial,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      grandfatherName: grandfatherName ?? this.grandfatherName,
      guardianName: guardianName ?? this.guardianName,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianMobile: guardianMobile ?? this.guardianMobile,
      guardianWhatsapp: guardianWhatsapp ?? this.guardianWhatsapp,
      guardianEmail: guardianEmail ?? this.guardianEmail,
      guardianWork: guardianWork ?? this.guardianWork,
      guardianAddress: guardianAddress ?? this.guardianAddress,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      registryPlace: registryPlace ?? this.registryPlace,
      registryNumber: registryNumber ?? this.registryNumber,
      religion: religion ?? this.religion,
      bloodType: bloodType ?? this.bloodType,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      enrollmentType: enrollmentType ?? this.enrollmentType,
      enrollmentGrade: enrollmentGrade ?? this.enrollmentGrade,
      schoolYear: schoolYear ?? this.schoolYear,
      previousSchool: previousSchool ?? this.previousSchool,
      failedGrades: failedGrades ?? this.failedGrades,
      firstLanguage: firstLanguage ?? this.firstLanguage,
      firstLanguageOther: firstLanguageOther ?? this.firstLanguageOther,
      secondLanguage: secondLanguage ?? this.secondLanguage,
      secondLanguageOther: secondLanguageOther ?? this.secondLanguageOther,
      spokenLanguage: spokenLanguage ?? this.spokenLanguage,
      spokenLanguageOther: spokenLanguageOther ?? this.spokenLanguageOther,
      otherLanguage: otherLanguage ?? this.otherLanguage,
      residence: residence ?? this.residence,
      landline: landline ?? this.landline,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      studentPhotoPath: studentPhotoPath ?? this.studentPhotoPath,
      qrFilePath: qrFilePath ?? this.qrFilePath,
      studentCardPdfPath: studentCardPdfPath ?? this.studentCardPdfPath,
      studentCardPngPath: studentCardPngPath ?? this.studentCardPngPath,
      transportGathering: transportGathering ?? this.transportGathering,
      transportSubscription:
          transportSubscription ?? this.transportSubscription,
      normalLife: normalLife ?? this.normalLife,
      orphanFather: orphanFather ?? this.orphanFather,
      orphanMother: orphanMother ?? this.orphanMother,
      orphanParents: orphanParents ?? this.orphanParents,
      onlyChild: onlyChild ?? this.onlyChild,
      livesSeparate: livesSeparate ?? this.livesSeparate,
      hobbyMusic: hobbyMusic ?? this.hobbyMusic,
      hobbyDrawing: hobbyDrawing ?? this.hobbyDrawing,
      hobbyComputer: hobbyComputer ?? this.hobbyComputer,
      hobbySports: hobbySports ?? this.hobbySports,
      otherHobbies: otherHobbies ?? this.otherHobbies,
      initiativeSchool: initiativeSchool ?? this.initiativeSchool,
      initiativeFinancial: initiativeFinancial ?? this.initiativeFinancial,
      initiativeInKind: initiativeInKind ?? this.initiativeInKind,
      initiativeProjects: initiativeProjects ?? this.initiativeProjects,
      healthStatus: healthStatus ?? this.healthStatus,
      disabilityVisual: disabilityVisual ?? this.disabilityVisual,
      disabilityHearing: disabilityHearing ?? this.disabilityHearing,
      disabilityMotor: disabilityMotor ?? this.disabilityMotor,
      disabilityLearning: disabilityLearning ?? this.disabilityLearning,
      healthNotes: healthNotes ?? this.healthNotes,
      notes: notes ?? this.notes,
      transferNotes: transferNotes ?? this.transferNotes,
      transportFees: transportFees ?? this.transportFees,
      regularFees: regularFees ?? this.regularFees,
    );
  }
}

class StudentAttachment {
  const StudentAttachment({
    required this.id,
    required this.studentId,
    required this.title,
    required this.category,
    required this.note,
    required this.originalFileName,
    required this.storedPath,
    required this.uploadedAt,
    required this.sizeBytes,
  });

  final int id;
  final int studentId;
  final String title;
  final String category;
  final String note;
  final String originalFileName;
  final String storedPath;
  final String uploadedAt;
  final int sizeBytes;

  StudentAttachment copyWith({
    int? id,
    int? studentId,
    String? title,
    String? category,
    String? note,
    String? originalFileName,
    String? storedPath,
    String? uploadedAt,
    int? sizeBytes,
  }) {
    return StudentAttachment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      category: category ?? this.category,
      note: note ?? this.note,
      originalFileName: originalFileName ?? this.originalFileName,
      storedPath: storedPath ?? this.storedPath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}

class BackupEntry {
  const BackupEntry({
    required this.name,
    required this.createdAt,
    required this.fileCount,
    required this.studentCount,
    required this.note,
  });

  final String name;
  final String createdAt;
  final int fileCount;
  final int studentCount;
  final String note;
}

class ParentMessageEntry {
  const ParentMessageEntry({
    required this.studentId,
    required this.type,
    required this.subject,
    required this.body,
    required this.date,
    required this.time,
    required this.reason,
    required this.guardianEmail,
    required this.guardianWhatsapp,
  });

  final int studentId;
  final String type;
  final String subject;
  final String body;
  final String date;
  final String time;
  final String reason;
  final String guardianEmail;
  final String guardianWhatsapp;
}

class AttendanceEntry {
  const AttendanceEntry({
    required this.studentId,
    required this.status,
    required this.date,
    required this.note,
  });

  final int studentId;
  final String status;
  final String date;
  final String note;
}

class DisciplineEntry {
  const DisciplineEntry({
    required this.studentId,
    required this.type,
    required this.title,
    required this.note,
    required this.date,
  });

  final int studentId;
  final String type;
  final String title;
  final String note;
  final String date;
}

class CertificateEntry {
  const CertificateEntry({
    required this.studentId,
    required this.title,
    required this.kind,
    required this.date,
    required this.note,
  });

  final int studentId;
  final String title;
  final String kind;
  final String date;
  final String note;
}

class ExamScheduleEntry {
  const ExamScheduleEntry({
    required this.title,
    required this.grade,
    required this.examDate,
    required this.period,
    required this.hall,
  });

  final String title;
  final String grade;
  final String examDate;
  final String period;
  final String hall;
}

class ExamResultEntry {
  const ExamResultEntry({
    required this.studentId,
    required this.subject,
    required this.firstTermWork,
    required this.firstTermExam,
    required this.secondTermWork,
    required this.secondTermExam,
    this.isManuallyReviewed = false,
  });

  final int studentId;
  final String subject;
  final double firstTermWork;
  final double firstTermExam;
  final double secondTermWork;
  final double secondTermExam;
  final bool isManuallyReviewed;

  double get firstTermTotal => firstTermWork + firstTermExam;
  double get secondTermTotal => secondTermWork + secondTermExam;
  double get finalAverage => (firstTermTotal + secondTermTotal) / 2;

  ExamResultEntry copyWith({
    int? studentId,
    String? subject,
    double? firstTermWork,
    double? firstTermExam,
    double? secondTermWork,
    double? secondTermExam,
    bool? isManuallyReviewed,
  }) {
    return ExamResultEntry(
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      firstTermWork: firstTermWork ?? this.firstTermWork,
      firstTermExam: firstTermExam ?? this.firstTermExam,
      secondTermWork: secondTermWork ?? this.secondTermWork,
      secondTermExam: secondTermExam ?? this.secondTermExam,
      isManuallyReviewed: isManuallyReviewed ?? this.isManuallyReviewed,
    );
  }
}

class AccountingInvoiceEntry {
  const AccountingInvoiceEntry({
    required this.studentId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
  });

  final int studentId;
  final double amount;
  final String title;
  final String currency;
  final String date;
}


class AccountingDonationEntry {
  const AccountingDonationEntry({
    required this.studentId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.donationKind,
    required this.materialType,
    required this.quantity,
    required this.note,
  });

  final int studentId;
  final double amount;
  final String title;
  final String currency;
  final String date;
  final String donationKind;
  final String materialType;
  final String quantity;
  final String note;
}

class AccountingAidEntry {
  const AccountingAidEntry({
    required this.studentId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.aidKind,
    required this.materialType,
    required this.quantity,
    required this.note,
  });

  final int studentId;
  final double amount;
  final String title;
  final String currency;
  final String date;
  final String aidKind;
  final String materialType;
  final String quantity;
  final String note;
}

class AccountingReceiptEntry {
  const AccountingReceiptEntry({
    required this.studentId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.note,
  });

  final int studentId;
  final double amount;
  final String title;
  final String currency;
  final String date;
  final String note;
}

class SchoolIdentityEntry {
  const SchoolIdentityEntry({
    required this.email,
    required this.whatsapp,
    required this.mobile,
    required this.landline,
    required this.website,
    required this.facebookPage,
    required this.secretaryName,
    required this.supervisorName,
    required this.principalName,
  });

  final String email;
  final String whatsapp;
  final String mobile;
  final String landline;
  final String website;
  final String facebookPage;
  final String secretaryName;
  final String supervisorName;
  final String principalName;

  SchoolIdentityEntry copyWith({
    String? email,
    String? whatsapp,
    String? mobile,
    String? landline,
    String? website,
    String? facebookPage,
    String? secretaryName,
    String? supervisorName,
    String? principalName,
  }) {
    return SchoolIdentityEntry(
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      mobile: mobile ?? this.mobile,
      landline: landline ?? this.landline,
      website: website ?? this.website,
      facebookPage: facebookPage ?? this.facebookPage,
      secretaryName: secretaryName ?? this.secretaryName,
      supervisorName: supervisorName ?? this.supervisorName,
      principalName: principalName ?? this.principalName,
    );
  }
}

class AdminUserEntry {
  const AdminUserEntry({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.mobile,
    required this.permissions,
  });

  final int id;
  final String username;
  final String password;
  final String email;
  final String mobile;
  final List<String> permissions;

  AdminUserEntry copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? mobile,
    List<String>? permissions,
  }) {
    return AdminUserEntry(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      permissions: permissions ?? this.permissions,
    );
  }
}
