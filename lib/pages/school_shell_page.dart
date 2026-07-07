import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/seed_data.dart';
import '../models/school_models.dart';
import '../models/notification_model.dart';
import '../services/local_student_file_service.dart';
import '../services/school_database_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/employee_service.dart';
import '../services/finance_service.dart';
import '../services/meeting_service.dart';
import '../theme/app_palette.dart';
import 'dashboard_page.dart';
import 'employees_page.dart';
import 'employee_finance_review_page.dart';
import 'accounting_income_expenses_page.dart';
import 'parent_meetings_page.dart';
import 'local_data_center_page.dart';
import 'student_sorting_page.dart';

part 'school_shell_sections.dart';
part '../widgets/school_shell_widgets.dart';
part '../dialogs/school_shell_dialogs.dart';

class _NavGroup {
  const _NavGroup({
    required this.id,
    required this.title,
    required this.items,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String id;
  final String title;
  final List<_NavItem> items;
  final Color primaryColor;
  final Color secondaryColor;
}

class _NavItem {
  const _NavItem(this.id, this.label);

  final String id;
  final String label;
}

class _PageInfo {
  const _PageInfo(this.title, this.subtitle, this.hint);

  final String title;
  final String subtitle;
  final String hint;
}

class _StudentCardExportResult {
  const _StudentCardExportResult({
    required this.pdfBytes,
    required this.pdfPath,
    required this.pngPath,
  });

  final Uint8List pdfBytes;
  final String pdfPath;
  final String pngPath;
}

class _BulkExamPdfExportResult {
  const _BulkExamPdfExportResult({
    required this.pdfBytes,
    required this.pdfPath,
    required this.fileName,
    required this.title,
    required this.studentCount,
    required this.grade,
    required this.section,
  });

  final Uint8List pdfBytes;
  final String pdfPath;
  final String fileName;
  final String title;
  final int studentCount;
  final String grade;
  final String section;
}

class _LoginTag extends StatelessWidget {
  const _LoginTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class SchoolShellPage extends StatefulWidget {
  const SchoolShellPage({super.key});

  @override
  State<SchoolShellPage> createState() => _SchoolShellPageState();
}

class _SchoolShellPageState extends State<SchoolShellPage> {
  final SchoolDatabaseService _database = SchoolDatabaseService.instance;
  final LocalStudentFileService _fileStorage = LocalStudentFileService.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _studentCardBoundaryKey = GlobalKey();
  final GlobalKey _examReportBoundaryKey = GlobalKey();
  bool _isDatabaseReady = false;
  bool _isStudentCardExporting = false;
  bool _isExamReportExporting = false;
  final List<StudentRecord> _students = List<StudentRecord>.from(kInitialStudents);
  final List<StudentAttachment> _attachments = List<StudentAttachment>.from(kInitialAttachments);
  final List<BackupEntry> _backups = List<BackupEntry>.from(kInitialBackups);
  final List<ParentMessageEntry> _messages = List<ParentMessageEntry>.from(kInitialMessages);
  final List<AttendanceEntry> _attendance = List<AttendanceEntry>.from(kInitialAttendance);
  final List<DisciplineEntry> _discipline = List<DisciplineEntry>.from(kInitialDiscipline);
  final List<CertificateEntry> _certificates = List<CertificateEntry>.from(kInitialCertificates);
  final List<ExamScheduleEntry> _examSchedule = List<ExamScheduleEntry>.from(kInitialExamSchedule);
  final List<ExamResultEntry> _examResults = List<ExamResultEntry>.from(kInitialExamResults);
  final List<AccountingInvoiceEntry> _invoices = List<AccountingInvoiceEntry>.from(kInitialInvoices);
  final List<AccountingDonationEntry> _accountingDonations = List<AccountingDonationEntry>.from(kInitialAccountingDonations);
  final List<AccountingAidEntry> _accountingAids = List<AccountingAidEntry>.from(kInitialAccountingAids);
  final List<AccountingReceiptEntry> _receipts = List<AccountingReceiptEntry>.from(kInitialReceipts);
  final List<AdminUserEntry> _adminUsers = List<AdminUserEntry>.from(kInitialAdminUsers);
  SchoolIdentityEntry _schoolIdentity = kInitialSchoolIdentity;

  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _grandfatherNameController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _registryPlaceController = TextEditingController();
  final TextEditingController _registryNumberController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _firstLanguageOtherController = TextEditingController();
  final TextEditingController _secondLanguageOtherController = TextEditingController();
  final TextEditingController _spokenLanguageOtherController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _enrollmentDateController = TextEditingController();
  final TextEditingController _schoolYearController = TextEditingController();
  final TextEditingController _previousSchoolController = TextEditingController();
  final TextEditingController _failedGradesController = TextEditingController();
  final TextEditingController _otherLanguageController = TextEditingController();
  final TextEditingController _residenceController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _transportGatheringController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianRelationController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();
  final TextEditingController _guardianMobileController = TextEditingController();
  final TextEditingController _guardianWhatsappController = TextEditingController();
  final TextEditingController _guardianEmailController = TextEditingController();
  final TextEditingController _guardianWorkController = TextEditingController();
  final TextEditingController _guardianAddressController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();
  final TextEditingController _otherHobbiesController = TextEditingController();
  final TextEditingController _healthNotesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _transferNotesController = TextEditingController();
  final TextEditingController _attendanceDateController = TextEditingController();
  final TextEditingController _attendanceNoteController = TextEditingController();
  final TextEditingController _messageReasonController = TextEditingController();
  final TextEditingController _messageDateController = TextEditingController();
  final TextEditingController _messageTimeController = TextEditingController();
  final TextEditingController _messageBodyController = TextEditingController();
  final TextEditingController _disciplineDateController = TextEditingController();
  final TextEditingController _disciplineTitleController = TextEditingController();
  final TextEditingController _disciplineNoteController = TextEditingController();
  final TextEditingController _certificateDateController = TextEditingController();
  final TextEditingController _certificateTitleController = TextEditingController();
  final TextEditingController _certificateNoteController = TextEditingController();
  final TextEditingController _invoiceTitleController = TextEditingController();
  final TextEditingController _invoiceAmountController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _receiptTitleController = TextEditingController();
  final TextEditingController _receiptAmountController = TextEditingController();
  final TextEditingController _receiptDateController = TextEditingController();
  final TextEditingController _receiptNoteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _schoolEmailController = TextEditingController();
  final TextEditingController _schoolWhatsappController = TextEditingController();
  final TextEditingController _schoolMobileController = TextEditingController();
  final TextEditingController _schoolLandlineController = TextEditingController();
  final TextEditingController _schoolWebsiteController = TextEditingController();
  final TextEditingController _schoolFacebookController = TextEditingController();
  final TextEditingController _secretaryNameController = TextEditingController(); // مدير المدرسة (old name kept for sections file compat)
  final TextEditingController _supervisorNameController = TextEditingController(); // مشرف القسم (old name kept for sections file compat)
  final TextEditingController _principalNameController = TextEditingController();
  final TextEditingController _generalSupervisorController = TextEditingController(); // المشرف العام
  String _sealImagePath = '';
  String _signatureImagePath = '';
  final TextEditingController _loginUsernameController = TextEditingController(text: 'admin');
  final TextEditingController _loginPasswordController = TextEditingController(text: 'admin');
  final TextEditingController _adminUsernameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _adminConfirmPasswordController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminMobileController = TextEditingController();
  final List<TextEditingController> _transportDueControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _transportPaidControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _transportDateControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _regularDueControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _regularPaidControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _regularDateControllers = List<TextEditingController>.generate(10, (_) => TextEditingController());

  String _currentPage = 'dashboard';
  final List<NotificationItem> _notifications = [];
  int? _selectedStudentId = 1;
  String _gender = 'ذكر';
  String _status = 'نشط';
  String _bloodType = '?';
  String _firstLanguage = 'E';
  String _secondLanguage = 'E';
  String _spokenLanguage = 'E';
  String _enrollmentType = 'طالب جديد';
  String _enrollmentGrade = '1';
  final Set<String> _failedGradesSelected = <String>{};
  String _transportSubscription = 'نعم';
  final List<String> _transportCurrencies = List<String>.filled(10, 'ليرة سورية');
  final List<String> _regularCurrencies = List<String>.filled(10, 'ليرة سورية');
  String _healthStatus = 'سليم';
  bool _disabilityVisual = false;
  bool _disabilityHearing = false;
  bool _disabilityMotor = false;
  bool _disabilityLearning = false;
  bool _normalLife = true;
  bool _orphanFather = false;
  bool _orphanMother = false;
  bool _orphanParents = false;
  bool _onlyChild = false;
  bool _livesSeparate = false;
  bool _hobbyMusic = false;
  bool _hobbyDrawing = false;
  bool _hobbyComputer = false;
  bool _hobbySports = false;
  bool _initiativeSchool = false;
  bool _initiativeFinancial = false;
  bool _initiativeInKind = false;
  bool _initiativeProjects = false;
  String _attendanceStatus = 'حاضر';
  String _messageType = 'مراسلة الكترونية';
  String _disciplineType = 'مكافأة';
  String _certificateKind = 'شهادة تقدير';
  String _invoiceCurrency = 'ليرة سورية';
  String _receiptCurrency = 'ليرة سورية';
  final List<String> _studentsSortOrder = <String>['الاسم'];
  bool _showOnlyUnreviewedExamSubjects = false;
  String _accountingView = 'installments';
  int? _accountingFilterStudentId;
  String _accountingSectionFilter = 'الكل';
  bool _isAuthenticated = false;
  int? _authenticatedUserId;
  int? _selectedAdminUserId;
  String _loginError = '';
  final Set<String> _adminPermissionsDraft = <String>{};
  final Set<String> _openSections = <String>{'enrollment', 'contact'};
  final Set<TextEditingController> _noteControllersClearedOnFirstTap = <TextEditingController>{};
  final Set<String> _openNavGroups = <String>{'administration', 'secretariat', 'exams', 'accounting'};

  List<AccountingDonationEntry> _studentAccountingDonations(int studentId) {
    return _accountingDonations.where((entry) => entry.studentId == studentId).toList();
  }

  List<AccountingAidEntry> _studentAccountingAids(int studentId) {
    return _accountingAids.where((entry) => entry.studentId == studentId).toList();
  }

  AdminUserEntry? get _authenticatedUser {
    if (_authenticatedUserId == null) {
      return null;
    }
    for (final user in _adminUsers) {
      if (user.id == _authenticatedUserId) {
        return user;
      }
    }
    return null;
  }

  static const Map<String, String> _doorPermissions = <String, String>{
    'administration': 'الإدارة',
    'secretariat': 'أمانة السر',
    'exams': 'الامتحانات',
    'accounting': 'المحاسبة',
  };

  String _pageDoorId(String pageId) {
    if (const <String>{'dashboard'}.contains(pageId)) {
      return ''; // accessible to all
    }
    if (pageId == 'employees') {
      return 'secretariat';
    }
    if (const <String>{'employee_review'}.contains(pageId)) {
      return 'administration';
    }
    if (const <String>{'students', 'form', 'student_sorting', 'attendance', 'donations', 'discipline', 'certificates', 'documents', 'reports', 'student_card', 'backup', 'data_center', 'parent_meetings', 'transport', 'messages'}.contains(pageId)) {
      return 'secretariat';
    }
    if (const <String>{'admin_dashboard', 'admin_identity'}.contains(pageId)) {
      return 'administration';
    }
    if (pageId == 'exams') {
      return 'exams';
    }
    return 'accounting';
  }

  bool _userHasDoorPermission(AdminUserEntry? user, String doorId) {
    if (user == null) {
      return false;
    }
    if (doorId.isEmpty) {
      return true; // dashboard is accessible to all authenticated users
    }
    final permission = _doorPermissions[doorId] ?? '';
    return user.permissions.contains(permission);
  }

  String _firstAllowedPage(AdminUserEntry user) {
    return 'dashboard';
    /*if (_userHasDoorPermission(user, 'administration')) return 'admin_dashboard';
    if (_userHasDoorPermission(user, 'secretariat')) return 'students';
    if (_userHasDoorPermission(user, 'exams')) return 'exams';
    if (_userHasDoorPermission(user, 'accounting')) return 'accounting';
    return 'students';*/
  }

  void _loadAdminDraft([AdminUserEntry? user]) {
    _selectedAdminUserId = user?.id;
    _adminUsernameController.text = user?.username ?? '';
    _adminPasswordController.clear();
    _adminConfirmPasswordController.clear();
    _adminEmailController.text = user?.email ?? '';
    _adminMobileController.text = user?.mobile ?? '';
    _adminPermissionsDraft
      ..clear()
      ..addAll(user?.permissions ?? <String>[]);
  }

  void _loadSchoolIdentityDraft() {
    _schoolEmailController.text = _schoolIdentity.email;
    _schoolWhatsappController.text = _schoolIdentity.whatsapp;
    _schoolMobileController.text = _schoolIdentity.mobile;
    _schoolLandlineController.text = _schoolIdentity.landline;
    _schoolWebsiteController.text = _schoolIdentity.website;
    _schoolFacebookController.text = _schoolIdentity.facebookPage;
    _secretaryNameController.text = _schoolIdentity.schoolManagerName;
    _supervisorNameController.text = _schoolIdentity.sectionSupervisorName;
    _principalNameController.text = _schoolIdentity.principalName;
    _generalSupervisorController.text = _schoolIdentity.generalSupervisorName;
    _sealImagePath = _schoolIdentity.sealImagePath;
    _signatureImagePath = _schoolIdentity.signatureImagePath;
  }

  void _cancelAdminDraft() {
    _loadAdminDraft();
    setState(() {});
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _passwordMatches(String plain, String stored) {
    final hashed = _hashPassword(plain);
    return stored == hashed || stored == plain;
  }

  String? _validateAdminDraft({bool isEdit = false}) {
    if (_adminUsernameController.text.trim().isEmpty ||
        _adminEmailController.text.trim().isEmpty ||
        _adminMobileController.text.trim().isEmpty) {
      return 'يجب إدخال جميع المعلومات المطلوبة.';
    }
    if (!isEdit && (_adminPasswordController.text.trim().isEmpty || _adminConfirmPasswordController.text.trim().isEmpty)) {
      return 'يجب إدخال كلمة المرور وتأكيدها.';
    }
    if ((_adminPasswordController.text.isNotEmpty || _adminConfirmPasswordController.text.isNotEmpty) &&
        _adminPasswordController.text != _adminConfirmPasswordController.text) {
      return 'كلمة المرور وتأكيدها غير متطابقين.';
    }
    final duplicate = _adminUsers.any((user) =>
        user.username == _adminUsernameController.text.trim() && user.id != _selectedAdminUserId);
    if (duplicate) {
      return 'اسم المستخدم مستخدم مسبقًا.';
    }
    if (_adminPermissionsDraft.isEmpty) {
      return 'يجب تحديد صلاحية واحدة على الأقل.';
    }
    return null;
  }

  String? _validateSchoolIdentityDraft() {
    if (_schoolEmailController.text.trim().isEmpty ||
        _schoolWhatsappController.text.trim().isEmpty ||
        _schoolMobileController.text.trim().isEmpty ||
        _schoolLandlineController.text.trim().isEmpty ||
        _schoolWebsiteController.text.trim().isEmpty ||
        _schoolFacebookController.text.trim().isEmpty ||
        _secretaryNameController.text.trim().isEmpty ||
        _supervisorNameController.text.trim().isEmpty ||
        _principalNameController.text.trim().isEmpty) {
      return 'يجب إدخال جميع بيانات المدرسة المعتمدة.';
    }
    return null;
  }

  Future<void> _saveAdminUser() async {
    final validation = _validateAdminDraft();
    if (validation != null) {
      _showSnack(validation);
      return;
    }
    setState(() {
      _adminUsers.insert(
        0,
        AdminUserEntry(
          id: DateTime.now().microsecondsSinceEpoch,
          username: _adminUsernameController.text.trim(),
          password: _hashPassword(_adminPasswordController.text),
          email: _adminEmailController.text.trim(),
          mobile: _adminMobileController.text.trim(),
          permissions: _adminPermissionsDraft.toList(),
        ),
      );
      _loadAdminDraft();
    });
    await _persistAdminUsers();
    _showSnack('تم حفظ المستخدم بنجاح.');
  }

  Future<void> _editAdminUser() async {
    if (_selectedAdminUserId == null) {
      _showSnack('اختر مستخدمًا أولًا للتعديل.');
      return;
    }
    final validation = _validateAdminDraft(isEdit: true);
    if (validation != null) {
      _showSnack(validation);
      return;
    }
    final index = _adminUsers.indexWhere((user) => user.id == _selectedAdminUserId);
    if (index < 0) return;
    final updatedPassword = _adminPasswordController.text.trim().isEmpty
        ? _adminUsers[index].password
        : _hashPassword(_adminPasswordController.text);
    setState(() {
      _adminUsers[index] = _adminUsers[index].copyWith(
        username: _adminUsernameController.text.trim(),
        password: updatedPassword,
        email: _adminEmailController.text.trim(),
        mobile: _adminMobileController.text.trim(),
        permissions: _adminPermissionsDraft.toList(),
      );
      if (_authenticatedUserId == _selectedAdminUserId) {
        final updatedUser = _adminUsers[index];
        if (!_userHasDoorPermission(updatedUser, _pageDoorId(_currentPage))) {
          _currentPage = _firstAllowedPage(updatedUser);
        }
      }
      _loadAdminDraft(_adminUsers[index]);
    });
    await _persistAdminUsers();
    _showSnack('تم تعديل المستخدم بنجاح.');
  }

  Future<void> _deleteAdminUser() async {
    if (_selectedAdminUserId == null) {
      _showSnack('اختر مستخدمًا أولًا للحذف.');
      return;
    }
    final target = _adminUsers.firstWhere((user) => user.id == _selectedAdminUserId);
    final adminCount = _adminUsers.where((user) => user.permissions.contains('الإدارة')).length;
    if (target.permissions.contains('الإدارة') && adminCount <= 1) {
      _showSnack('لا يمكن حذف آخر مستخدم يملك صلاحية الإدارة.');
      return;
    }
    setState(() {
      _adminUsers.removeWhere((user) => user.id == _selectedAdminUserId);
      if (_authenticatedUserId == _selectedAdminUserId) {
        _authenticatedUserId = null;
        _isAuthenticated = false;
      }
      _loadAdminDraft();
    });
    await _persistAdminUsers();
    _showSnack('تم حذف المستخدم بنجاح.');
  }

  Future<void> _persistAdminUsers() async {
    await _database.saveJson('admin_users', _database.adminUsersToJson(_adminUsers));
  }

  Future<void> _saveSchoolIdentity() async {
    final validation = _validateSchoolIdentityDraft();
    if (validation != null) {
      _showSnack(validation);
      return;
    }
    setState(() {
      _schoolIdentity = _schoolIdentity.copyWith(
        email: _schoolEmailController.text.trim(),
        whatsapp: _schoolWhatsappController.text.trim(),
        mobile: _schoolMobileController.text.trim(),
        landline: _schoolLandlineController.text.trim(),
        website: _schoolWebsiteController.text.trim(),
        facebookPage: _schoolFacebookController.text.trim(),
        schoolManagerName: _secretaryNameController.text.trim(),
        sectionSupervisorName: _supervisorNameController.text.trim(),
        principalName: _principalNameController.text.trim(),
        generalSupervisorName: _generalSupervisorController.text.trim(),
        sealImagePath: _sealImagePath,
        signatureImagePath: _signatureImagePath,
      );
    });
    await _database.saveJson('school_identity', _database.schoolIdentityToJson(_schoolIdentity));
    _showSnack('تم حفظ بيانات المدرسة المعتمدة بنجاح.');
  }

  void _login() {
    final username = _loginUsernameController.text.trim();
    final password = _loginPasswordController.text;
    final match = _adminUsers.where((user) => user.username == username && _passwordMatches(password, user.password)).toList();
    if (match.isEmpty) {
      setState(() => _loginError = 'اسم المستخدم أو كلمة المرور غير صحيحة.');
      return;
    }
    final user = match.first;
    setState(() {
      _authenticatedUserId = user.id;
      _isAuthenticated = true;
      _loginError = '';
      _currentPage = _firstAllowedPage(user);
    });
    NotificationService.instance.addSimple(
      type: 'success',
      title: 'تسجيل دخول',
      body: 'تم تسجيل دخول المستخدم ${user.username} بنجاح.',
      targetPage: 'dashboard',
    );
    _showSnack('تم تسجيل الدخول بنجاح.');
  }

  void _logout() {
    setState(() {
      _authenticatedUserId = null;
      _isAuthenticated = false;
      _loginUsernameController.text = 'admin';
      _loginPasswordController.text = 'admin';
      _loginError = '';
    });
  }

  StudentRecord? get _selectedStudent {
    if (_selectedStudentId == null) {
      return null;
    }
    for (final student in _students) {
      if (student.id == _selectedStudentId) {
        return student;
      }
    }
    return null;
  }

  int _compareStudentSortValue(String firstValue, String secondValue) {
    final firstNumber = int.tryParse(firstValue.trim());
    final secondNumber = int.tryParse(secondValue.trim());
    if (firstNumber != null && secondNumber != null) {
      return firstNumber.compareTo(secondNumber);
    }
    return firstValue.compareTo(secondValue);
  }

  int _compareStudentsByCriterion(String criterion, StudentRecord first, StudentRecord second) {
    switch (criterion) {
      case 'الصف':
        return _compareStudentSortValue(_studentGradeDisplay(first), _studentGradeDisplay(second));
      case 'الشعبة':
        return _compareStudentSortValue(_studentSectionDisplay(first), _studentSectionDisplay(second));
      default:
        return first.fullName.compareTo(second.fullName);
    }
  }

  void _toggleStudentSortCriterion(String label) {
    setState(() {
      if (_studentsSortOrder.contains(label)) {
        _studentsSortOrder.remove(label);
        if (_studentsSortOrder.isEmpty) {
          _studentsSortOrder.add('الاسم');
        }
        return;
      }
      if (_studentsSortOrder.length == 1 && _studentsSortOrder.first == 'الاسم' && label != 'الاسم') {
        _studentsSortOrder
          ..clear()
          ..add(label);
        return;
      }
      _studentsSortOrder.add(label);
    });
  }

  String _studentSortOrderLabel() {
    return _studentsSortOrder.join(' ← ');
  }

  Future<void> _showStudentSortOrderDialog() async {
    final options = <String>['الاسم', 'الصف', 'الشعبة'];
    String first = _studentsSortOrder.isNotEmpty ? _studentsSortOrder[0] : 'الاسم';
    String second = _studentsSortOrder.length > 1 ? _studentsSortOrder[1] : '';
    String third = _studentsSortOrder.length > 2 ? _studentsSortOrder[2] : '';

    String normalizeOption(String? value) => value == null || value == 'بدون' ? '' : value;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildSortDropdown(String label, String currentValue, ValueChanged<String> onChanged) {
              return Expanded(
                child: DropdownButtonFormField<String>(
                  value: currentValue.isEmpty ? 'بدون' : currentValue,
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
                  ),
                  items: <String>['بدون', ...options]
                      .map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) => onChanged(normalizeOption(value)),
                ),
              );
            }

            return AlertDialog(
              title: const Text('ترتيب الفرز اليدوي'),
              content: SizedBox(
                width: 760,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'اختر ترتيب الفرز بشكل بسيط ودقيق. سيتم تطبيق الأول ثم الثاني ثم الثالث.',
                      style: TextStyle(color: AppPalette.muted, height: 1.8),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        buildSortDropdown('الأول', first, (value) => setDialogState(() => first = value)),
                        const SizedBox(width: 12),
                        buildSortDropdown('الثاني', second, (value) => setDialogState(() => second = value)),
                        const SizedBox(width: 12),
                        buildSortDropdown('الثالث', third, (value) => setDialogState(() => third = value)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8DDBF)),
                      ),
                      child: Text(
                        'الترتيب الحالي: ${[
                          if (first.isNotEmpty) first,
                          if (second.isNotEmpty && second != first) second,
                          if (third.isNotEmpty && third != first && third != second) third,
                        ].isEmpty ? 'الاسم' : [
                          if (first.isNotEmpty) first,
                          if (second.isNotEmpty && second != first) second,
                          if (third.isNotEmpty && third != first && third != second) third,
                        ].join(' ← ')}',
                        style: const TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      first = 'الاسم';
                      second = '';
                      third = '';
                    });
                  },
                  child: const Text('إعادة للوضع الافتراضي'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final order = <String>[];
                    for (final value in <String>[first, second, third]) {
                      if (value.isEmpty || order.contains(value)) {
                        continue;
                      }
                      order.add(value);
                    }
                    if (order.isEmpty) {
                      order.add('الاسم');
                    }
                    setState(() {
                      _studentsSortOrder
                        ..clear()
                        ..addAll(order);
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('تطبيق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _compareStudentsForList(StudentRecord first, StudentRecord second) {
    for (final criterion in _studentsSortOrder) {
      final compare = _compareStudentsByCriterion(criterion, first, second);
      if (compare != 0) {
        return compare;
      }
    }
    final nameCompare = first.fullName.compareTo(second.fullName);
    if (nameCompare != 0) {
      return nameCompare;
    }
    return first.serial.compareTo(second.serial);
  }

  List<StudentRecord> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    final result = _students.where((student) {
      if (query.isEmpty) {
        return true;
      }
      final haystack = <String>[
        student.fullName,
        student.serial,
        student.grade,
        student.guardianName,
        student.mobile,
        student.section,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
    result.sort(_compareStudentsForList);
    return result;
  }

  List<StudentAttachment> _studentAttachments(int studentId) {
    return _attachments.where((item) => item.studentId == studentId).toList();
  }

  StudentRecord? _studentById(int id) {
    for (final student in _students) {
      if (student.id == id) {
        return student;
      }
    }
    return null;
  }

  String _qrPayloadFor(StudentRecord student) {
    return jsonEncode(<String, String>{
      'school': 'Rose School 2026',
      'id': student.id.toString(),
      'serial': student.serial,
      'name': student.fullName,
      'grade': student.grade,
      'section': student.section,
      'registryNumber': student.registryNumber,
      'guardianMobile': student.guardianMobile,
    });
  }

  String _languageSummary(StudentRecord student) {
    final primary = student.spokenLanguage == 'أخرى'
        ? (student.spokenLanguageOther.isEmpty ? 'أخرى' : 'أخرى - ${student.spokenLanguageOther}')
        : student.spokenLanguage;
    return primary.isEmpty ? 'غير محددة' : primary;
  }

  String _studentTripleName(StudentRecord student) {
    final words = student.fullName
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    if (words.length <= 3) {
      return words.join(' ');
    }
    return words.take(3).join(' ');
  }

  String _studentHobbySummary(StudentRecord student) {
    final hobbies = <String>[
      if (student.hobbyMusic) 'موسيقا',
      if (student.hobbyDrawing) 'رسم',
      if (student.hobbyComputer) 'كمبيوتر',
      if (student.hobbySports) 'رياضة',
      if (student.otherHobbies.trim().isNotEmpty) student.otherHobbies.trim(),
    ];
    if (hobbies.isEmpty) {
      return 'غير محددة';
    }
    return hobbies.join('، ');
  }

  String _studentGradeDisplay(StudentRecord student) {
    if (student.grade.trim().isNotEmpty) {
      return student.grade.trim();
    }
    return student.enrollmentGrade.trim().isEmpty ? '-' : student.enrollmentGrade.trim();
  }

  String _studentSectionDisplay(StudentRecord student) {
    if (student.section.trim().isNotEmpty) {
      return student.section.trim();
    }
    return '?';
  }

  String _studentExportFileBase(StudentRecord student) {
    final safeName = student.fullName.trim().replaceAll(RegExp(r'\s+'), '_');
    return 'student_card_${student.id}_$safeName';
  }

  String _currentAcademicYear() {
    final now = DateTime.now();
    final startYear = now.month >= 9 ? now.year : now.year - 1;
    final endYear = startYear + 1;
    return '$startYear / $endYear';
  }

  String _timestampLabel() {
    return DateTime.now().toIso8601String();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _exportTimestampCompact() {
    final now = DateTime.now();
    return '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
  }

  String _safeFileSegment(String value) {
    final normalized = value.trim().isEmpty ? 'all' : value.trim();
    final sanitized = normalized
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return sanitized.isEmpty ? 'all' : sanitized;
  }

  String _bulkExamReportsTitle({
    required String grade,
    required String section,
    required int studentCount,
  }) {
    final gradeLabel = grade == 'الكل' ? 'كل الصفوف' : 'الصف $grade';
    final sectionLabel = section == 'الكل' ? 'كل الشعب' : 'الشعبة $section';
    return 'الجلاءات الجماعية - $gradeLabel - $sectionLabel ($studentCount)';
  }

  String _bulkExamReportsFileName({
    required String grade,
    required String section,
    required int studentCount,
  }) {
    final base = 'bulk_exam_reports_'
        'grade_${_safeFileSegment(grade == 'الكل' ? 'all_grades' : grade)}_'
        'section_${_safeFileSegment(section == 'الكل' ? 'all_sections' : section)}_'
        '${studentCount}_reports_'
        '${_exportTimestampCompact()}';
    return '$base.pdf';
  }

  bool get _hasSavedStudentSelected => _selectedStudent != null;

  Future<void> _persistStudents() async {
    await _database.saveJson('students', _database.studentsToJson(_students));
  }

  Future<void> _persistAttachments() async {
    await _database.saveJson('attachments', _database.attachmentsToJson(_attachments));
  }

  Future<void> _migrateStoredMediaFiles() async {
    var changed = false;

    for (var index = 0; index < _students.length; index++) {
      final student = _students[index];
      var updated = student;

      if (student.studentPhotoPath.isNotEmpty && !await _fileStorage.fileExists(student.studentPhotoPath)) {
        updated = updated.copyWith(studentPhotoPath: '');
        changed = true;
      }

      if (student.studentCardPdfPath.isNotEmpty && !await _fileStorage.fileExists(student.studentCardPdfPath)) {
        updated = updated.copyWith(studentCardPdfPath: '');
        changed = true;
      }

      if (student.studentCardPngPath.isNotEmpty && !await _fileStorage.fileExists(student.studentCardPngPath)) {
        updated = updated.copyWith(studentCardPngPath: '');
        changed = true;
      }

      if (student.qrFilePath.isEmpty || !await _fileStorage.fileExists(student.qrFilePath)) {
        final qrPath = await _fileStorage.generateStudentQrSvg(
          studentId: student.id,
          payload: _qrPayloadFor(student),
          serial: student.serial,
        );
        updated = updated.copyWith(qrFilePath: qrPath);
        changed = true;
      }

      if (updated != student) {
        _students[index] = updated;
      }
    }

    for (var index = 0; index < _attachments.length; index++) {
      final attachment = _attachments[index];
      if (attachment.storedPath.isNotEmpty && await _fileStorage.fileExists(attachment.storedPath)) {
        continue;
      }

      final placeholderPath = await _fileStorage.writeTextFile(
        studentId: attachment.studentId,
        bucket: 'attachments',
        baseName: attachment.title,
        content: 'مرفق تجريبي تمت هجرته إلى التخزين المحلي.\n\nالعنوان: ${attachment.title}\nالتصنيف: ${attachment.category}\nالملاحظة: ${attachment.note}',
      );
      final size = await _fileStorage.fileSize(placeholderPath);
      _attachments[index] = attachment.copyWith(
        storedPath: placeholderPath,
        originalFileName: attachment.originalFileName.isEmpty
            ? '${attachment.title}.txt'
            : attachment.originalFileName,
        uploadedAt: attachment.uploadedAt.isEmpty ? _timestampLabel() : attachment.uploadedAt,
        sizeBytes: size,
      );
      changed = true;
    }

    if (changed) {
      await _persistStudents();
      await _persistAttachments();
    }
  }

  Future<void> _ensureStudentQrFile(int studentId, {bool forceRegenerate = false}) async {
    final index = _students.indexWhere((student) => student.id == studentId);
    if (index < 0) {
      return;
    }
    final student = _students[index];
    if (!forceRegenerate && student.qrFilePath.isNotEmpty && await _fileStorage.fileExists(student.qrFilePath)) {
      return;
    }
    if (forceRegenerate && student.qrFilePath.isNotEmpty) {
      await _fileStorage.deleteFile(student.qrFilePath);
    }
    final qrPath = await _fileStorage.generateStudentQrSvg(
      studentId: student.id,
      payload: _qrPayloadFor(student),
      serial: student.serial,
    );
    _students[index] = student.copyWith(qrFilePath: qrPath);
    await _persistStudents();
  }

  Future<void> _pickStudentImage() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('احفظ سجل الطالب أولًا قبل رفع الصورة.');
      return;
    }
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (picked == null) {
      return;
    }

    final path = await _fileStorage.saveFile(
      studentId: student.id,
      bucket: 'photo',
      originalName: picked.name,
      sourcePath: picked.path,
      preferredBaseName: '${student.fullName}_photo',
    );

    final index = _students.indexWhere((item) => item.id == student.id);
    if (index < 0) {
      return;
    }
    if (_students[index].studentPhotoPath.isNotEmpty) {
      await _fileStorage.deleteFile(_students[index].studentPhotoPath);
    }

    setState(() {
      _students[index] = _students[index].copyWith(studentPhotoPath: path);
    });
    await _persistStudents();
    _showSnack('تم حفظ صورة الطالب فعليًا وربطها مع SQLite.');
  }

  Future<void> _removeStudentImage() async {
    final student = _selectedStudent;
    if (student == null || student.studentPhotoPath.isEmpty) {
      _showSnack('لا توجد صورة محفوظة لهذا الطالب.');
      return;
    }
    await _fileStorage.deleteFile(student.studentPhotoPath);
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index < 0) {
      return;
    }
    setState(() {
      _students[index] = _students[index].copyWith(studentPhotoPath: '');
    });
    await _persistStudents();
    _showSnack('تم حذف صورة الطالب من التخزين المحلي وSQLite.');
  }

  Future<void> _generateStudentQrFile() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('احفظ سجل الطالب أولًا قبل توليد QR.');
      return;
    }
    await _ensureStudentQrFile(student.id, forceRegenerate: true);
    if (!mounted) {
      return;
    }
    setState(() {});
    _showSnack('تم توليد ملف QR فعليًا وربطه مع SQLite.');
  }

  Future<void> _pickStudentQrFile() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('احفظ سجل الطالب أولًا قبل رفع QR.');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'svg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final path = await _fileStorage.saveFile(
      studentId: student.id,
      bucket: 'qr',
      originalName: file.name,
      bytes: file.bytes,
      sourcePath: file.path,
      preferredBaseName: '${student.fullName}_qr',
    );

    final index = _students.indexWhere((item) => item.id == student.id);
    if (index < 0) {
      return;
    }
    if (_students[index].qrFilePath.isNotEmpty) {
      await _fileStorage.deleteFile(_students[index].qrFilePath);
    }

    setState(() {
      _students[index] = _students[index].copyWith(qrFilePath: path);
    });
    await _persistStudents();
    _showSnack('تم حفظ ملف QR فعليًا وربطه مع SQLite.');
  }

  Future<void> _removeStudentQr() async {
    final student = _selectedStudent;
    if (student == null || student.qrFilePath.isEmpty) {
      _showSnack('لا يوجد ملف QR محفوظ لهذا الطالب.');
      return;
    }
    await _fileStorage.deleteFile(student.qrFilePath);
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index < 0) {
      return;
    }
    setState(() {
      _students[index] = _students[index].copyWith(qrFilePath: '');
    });
    await _persistStudents();
    _showSnack('تم حذف ملف QR من التخزين المحلي وSQLite.');
  }

  Future<void> _showAddAttachmentDialog() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('احفظ سجل الطالب أولًا قبل إضافة مرفق.');
      return;
    }

    final titleController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'مستند';
    PlatformFile? pickedFile;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة مرفق فعلي'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان المرفق'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: const <String>['هوية', 'شهادة', 'مستند', 'صورة', 'أخرى']
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'ملاحظة'),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                type: FileType.any,
                                withData: true,
                              );
                              if (result == null || result.files.isEmpty) {
                                return;
                              }
                              setDialogState(() {
                                pickedFile = result.files.single;
                                if (titleController.text.trim().isEmpty) {
                                  titleController.text = pickedFile!.name.split('.').first;
                                }
                              });
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('اختيار ملف'),
                          ),
                          Text(
                            pickedFile == null ? 'لم يتم اختيار ملف بعد' : pickedFile!.name,
                            style: const TextStyle(color: AppPalette.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (pickedFile == null) {
                      _showSnack('اختر ملفًا قبل الحفظ.');
                      return;
                    }
                    final title = titleController.text.trim().isEmpty ? pickedFile!.name : titleController.text.trim();
                    final storedPath = await _fileStorage.saveFile(
                      studentId: student.id,
                      bucket: 'attachments',
                      originalName: pickedFile!.name,
                      bytes: pickedFile!.bytes,
                      sourcePath: pickedFile!.path,
                      preferredBaseName: title,
                    );
                    final size = await _fileStorage.fileSize(storedPath);
                    setState(() {
                      _attachments.insert(
                        0,
                        StudentAttachment(
                          id: DateTime.now().microsecondsSinceEpoch,
                          studentId: student.id,
                          title: title,
                          category: category,
                          note: noteController.text.trim(),
                          originalFileName: pickedFile!.name,
                          storedPath: storedPath,
                          uploadedAt: _timestampLabel(),
                          sizeBytes: size,
                        ),
                      );
                    });
                    await _persistAttachments();
                    if (mounted) {
                      Navigator.pop(dialogContext);
                    }
                    _showSnack('تم حفظ المرفق فعليًا وربطه مع SQLite.');
                  },
                  child: const Text('حفظ المرفق'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    noteController.dispose();
  }

  Future<void> _deleteAttachment(StudentAttachment attachment) async {
    await _fileStorage.deleteFile(attachment.storedPath);
    setState(() {
      _attachments.removeWhere((item) => item.id == attachment.id);
    });
    await _persistAttachments();
    _showSnack('تم حذف المرفق من التخزين المحلي وSQLite.');
  }

  Future<Uint8List> _captureStudentCardPng() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    final boundary = _studentCardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('تعذر الوصول إلى بطاقة الطالب من أجل الإخراج.');
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('تعذر تحويل البطاقة إلى صورة.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _buildStudentCardPdf(Uint8List pngBytes) async {
    final document = pw.Document();
    final image = pw.MemoryImage(pngBytes);
    final cardFormat = PdfPageFormat(
      85.6 * PdfPageFormat.mm,
      54.0 * PdfPageFormat.mm,
      marginAll: 0,
    );

    document.addPage(
      pw.Page(
        pageFormat: cardFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.SizedBox.expand(
            child: pw.Image(image, fit: pw.BoxFit.fill),
          );
        },
      ),
    );

    return document.save();
  }

  Future<_StudentCardExportResult> _generateStudentCardExport(StudentRecord student) async {
    final pngBytes = await _captureStudentCardPng();
    final pdfBytes = await _buildStudentCardPdf(pngBytes);
    final baseName = _studentExportFileBase(student);

    final pngPath = await _fileStorage.saveFile(
      studentId: student.id,
      bucket: 'student_card_exports',
      originalName: '$baseName.png',
      bytes: pngBytes,
      preferredBaseName: baseName,
    );

    final pdfPath = await _fileStorage.saveFile(
      studentId: student.id,
      bucket: 'student_card_exports',
      originalName: '$baseName.pdf',
      bytes: pdfBytes,
      preferredBaseName: baseName,
    );

    final index = _students.indexWhere((item) => item.id == student.id);
    if (index >= 0) {
      final previousPdf = _students[index].studentCardPdfPath;
      final previousPng = _students[index].studentCardPngPath;
      if (previousPdf.isNotEmpty && previousPdf != pdfPath) {
        await _fileStorage.deleteFile(previousPdf);
      }
      if (previousPng.isNotEmpty && previousPng != pngPath) {
        await _fileStorage.deleteFile(previousPng);
      }
      _students[index] = _students[index].copyWith(
        studentCardPdfPath: pdfPath,
        studentCardPngPath: pngPath,
      );
      await _persistStudents();
    }

    return _StudentCardExportResult(
      pdfBytes: pdfBytes,
      pdfPath: pdfPath,
      pngPath: pngPath,
    );
  }

  Future<void> _previewStudentCard() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('لا يوجد طالب محدد للمعاينة.');
      return;
    }

    try {
      setState(() => _isStudentCardExporting = true);
      final result = await _generateStudentCardExport(student);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Text('معاينة بطاقة ${student.fullName}'),
              ),
              body: PdfPreview(
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,
                pdfFileName: _fileStorage.fileNameFromPath(result.pdfPath),
                build: (format) async => result.pdfBytes,
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      _showSnack('تعذر فتح معاينة البطاقة: $error');
    } finally {
      if (mounted) {
        setState(() => _isStudentCardExporting = false);
      }
    }
  }

  Future<void> _showStudentCardExportDialog({
    required StudentRecord student,
    required _StudentCardExportResult result,
    bool showPrintButton = false,
  }) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('تم تجهيز بطاقة ${student.fullName}'),
          content: SizedBox(
            width: 620,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('تم حفظ المخرجات الفعلية وربط مساراتها داخل SQLite:'),
                const SizedBox(height: 12),
                SelectableText('PDF: ${result.pdfPath}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SelectableText('PNG: ${result.pngPath}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 14),
                const Text(
                  'يمكنك استخدام هذه الملفات مباشرة للطباعة أو الأرشفة أو المشاركة.',
                  style: TextStyle(color: AppPalette.muted),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
            if (showPrintButton)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await Printing.layoutPdf(
                    name: _fileStorage.fileNameFromPath(result.pdfPath),
                    onLayout: (format) async => result.pdfBytes,
                  );
                },
                child: const Text('طباعة الآن'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _prepareStudentCardForPrint() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('لا يوجد طالب محدد للتصدير.');
      return;
    }

    try {
      setState(() => _isStudentCardExporting = true);
      final result = await _generateStudentCardExport(student);
      await _showStudentCardExportDialog(
        student: student,
        result: result,
        showPrintButton: true,
      );
    } catch (error) {
      _showSnack('تعذر تجهيز ملف الطباعة: $error');
    } finally {
      if (mounted) {
        setState(() => _isStudentCardExporting = false);
      }
    }
  }

  Future<void> _exportStudentCardPdfDirect() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('لا يوجد طالب محدد لتصدير PDF.');
      return;
    }

    try {
      setState(() => _isStudentCardExporting = true);
      final result = await _generateStudentCardExport(student);
      await _showStudentCardExportDialog(student: student, result: result);
    } catch (error) {
      _showSnack('تعذر تصدير PDF: $error');
    } finally {
      if (mounted) {
        setState(() => _isStudentCardExporting = false);
      }
    }
  }

  Future<void> _exportStudentCardImageDirect() async {
    final student = _selectedStudent;
    if (student == null) {
      _showSnack('لا يوجد طالب محدد لتصدير صورة البطاقة.');
      return;
    }

    try {
      setState(() => _isStudentCardExporting = true);
      final result = await _generateStudentCardExport(student);
      await _showStudentCardExportDialog(student: student, result: result);
    } catch (error) {
      _showSnack('تعذر تصدير صورة البطاقة: $error');
    } finally {
      if (mounted) {
        setState(() => _isStudentCardExporting = false);
      }
    }
  }

  Future<Uint8List> _captureBoundaryPng(GlobalKey boundaryKey, {double pixelRatio = 3}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('تعذر الوصول إلى عنصر الطباعة المطلوب.');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('تعذر تحويل العنصر إلى صورة.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _buildExamReportPdf(Uint8List pngBytes) async {
    final document = pw.Document();
    final image = pw.MemoryImage(pngBytes);
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(10, 10, 10, 26),
        build: (context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );
    return document.save();
  }

  Future<void> _previewExamReport() async {
    if (_selectedStudent == null) {
      _showSnack('لا يوجد طالب محدد لمعاينة الجلاء.');
      return;
    }
    try {
      setState(() => _isExamReportExporting = true);
      final pngBytes = await _captureBoundaryPng(_examReportBoundaryKey, pixelRatio: 2.6);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            child: Container(
              width: 1100,
              height: 760,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('معاينة الجلاء المدرسي - ${_selectedStudent!.fullName}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppPalette.deepNavySoft)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.line),
                      ),
                      child: InteractiveViewer(
                        minScale: 0.6,
                        maxScale: 3,
                        child: Center(child: Image.memory(pngBytes, fit: BoxFit.contain)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      _showSnack('تعذر فتح معاينة الجلاء: $error');
    } finally {
      if (mounted) {
        setState(() => _isExamReportExporting = false);
      }
    }
  }

  Future<void> _printExamReport() async {
    if (_selectedStudent == null) {
      _showSnack('لا يوجد طالب محدد لطباعة الجلاء.');
      return;
    }
    try {
      setState(() => _isExamReportExporting = true);
      final pngBytes = await _captureBoundaryPng(_examReportBoundaryKey, pixelRatio: 2.8);
      final pdfBytes = await _buildExamReportPdf(pngBytes);
      await Printing.layoutPdf(
        name: 'exam_report_${_selectedStudent!.id}.pdf',
        onLayout: (format) async => pdfBytes,
      );
      if (mounted) {
        _showSnack('تم تجهيز الجلاء المدرسي للطباعة بنجاح.');
      }
    } catch (error) {
      _showSnack('تعذر طباعة الجلاء المدرسي: $error');
    } finally {
      if (mounted) {
        setState(() => _isExamReportExporting = false);
      }
    }
  }

  Future<Uint8List> _buildBulkExamReportsPdf(List<Uint8List> pngPages) async {
    final document = pw.Document(
      title: 'Rose School 2026 Bulk Exam Reports',
      author: 'Rose School 2026',
      subject: 'Bulk school exam reports export',
    );
    final totalPages = pngPages.length;
    for (var index = 0; index < pngPages.length; index++) {
      final image = pw.MemoryImage(pngPages[index]);
      final pageNumber = index + 1;
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.fromLTRB(12, 10, 12, 24),
          build: (context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: const PdfColor(0.85, 0.89, 0.94), width: 1.1),
              ),
              padding: const pw.EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: pw.Column(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: const PdfColor(0.93, 0.95, 0.97), width: 0.8),
                        ),
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Image(image, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Container(width: 82, height: 3, color: const PdfColor(0.81, 0.65, 0.37)),
                      pw.Text('$pageNumber / $totalPages', style: const pw.TextStyle(fontSize: 10)),
                      pw.Container(width: 82, height: 3, color: const PdfColor(0.12, 0.48, 0.47)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return document.save();
  }

  Future<_BulkExamPdfExportResult> _generateBulkExamReportsExport({
    required String grade,
    required String section,
    required double pixelRatio,
  }) async {
    final students = _studentsByGradeAndSection(grade: grade, section: section);
    if (students.isEmpty) {
      throw StateError('لا توجد جلاءات مطابقة للصف والشعبة المحددين.');
    }
    final pngPages = await _captureBulkExamReportPngs(students, pixelRatio: pixelRatio);
    final pdfBytes = await _buildBulkExamReportsPdf(pngPages);
    final fileName = _bulkExamReportsFileName(
      grade: grade,
      section: section,
      studentCount: students.length,
    );
    final pdfPath = await _fileStorage.saveProjectFile(
      bucket: 'bulk_exam_reports',
      originalName: fileName,
      bytes: pdfBytes,
      preferredBaseName: fileName.replaceAll('.pdf', ''),
    );
    return _BulkExamPdfExportResult(
      pdfBytes: pdfBytes,
      pdfPath: pdfPath,
      fileName: fileName,
      title: _bulkExamReportsTitle(
        grade: grade,
        section: section,
        studentCount: students.length,
      ),
      studentCount: students.length,
      grade: grade,
      section: section,
    );
  }

  Future<void> _showBulkExamReportsExportDialog(_BulkExamPdfExportResult result) async {
    if (!mounted) {
      return;
    }
    final gradeLabel = result.grade == 'الكل' ? 'كل الصفوف' : result.grade;
    final sectionLabel = result.section == 'الكل' ? 'كل الشعب' : result.section;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تم تجهيز ملف الجلاءات الجماعي'),
          content: SizedBox(
            width: 640,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('تم حفظ ملف PDF الجماعي النهائي فعليًا داخل التخزين المحلي:'),
                const SizedBox(height: 12),
                SelectableText('الاسم: ${result.fileName}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SelectableText('PDF: ${result.pdfPath}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                Text('عدد الجلاءات: ${result.studentCount}'),
                const SizedBox(height: 4),
                Text('الصف: $gradeLabel'),
                const SizedBox(height: 4),
                Text('الشعبة: $sectionLabel'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  List<StudentRecord> _studentsByGradeAndSection({
    required String grade,
    required String section,
  }) {
    final result = _students.where((student) {
      if (grade != 'الكل' && _studentGradeDisplay(student) != grade) {
        return false;
      }
      if (section != 'الكل' && _studentSectionDisplay(student) != section) {
        return false;
      }
      return true;
    }).toList();
    result.sort((first, second) => first.fullName.compareTo(second.fullName));
    return result;
  }

  Future<List<Uint8List>> _captureBulkExamReportPngs(
    List<StudentRecord> students, {
    double pixelRatio = 2.9,
  }) async {
    final originalStudent = _selectedStudent;
    final images = <Uint8List>[];
    for (final student in students) {
      if (!mounted) break;
      setState(() => _loadStudent(student));
      final pngBytes = await _captureBoundaryPng(_examReportBoundaryKey, pixelRatio: pixelRatio);
      images.add(pngBytes);
    }
    if (mounted && originalStudent != null) {
      setState(() => _loadStudent(originalStudent));
    }
    return images;
  }

  Future<void> _previewBulkExamReports({
    required String grade,
    required String section,
  }) async {
    final students = _studentsByGradeAndSection(grade: grade, section: section);
    if (students.isEmpty) {
      _showSnack('لا توجد جلاءات مطابقة للصف والشعبة المحددين.');
      return;
    }
    try {
      setState(() => _isExamReportExporting = true);
      final result = await _generateBulkExamReportsExport(
        grade: grade,
        section: section,
        pixelRatio: 2.95,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(result.title),
                    Text(
                      result.fileName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              body: PdfPreview(
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,
                pdfFileName: result.fileName,
                build: (format) async => result.pdfBytes,
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      _showSnack('تعذر تجهيز معاينة الجلاءات: $error');
    } finally {
      if (mounted) {
        setState(() => _isExamReportExporting = false);
      }
    }
  }

  Future<void> _printBulkExamReports({
    required String grade,
    required String section,
  }) async {
    final students = _studentsByGradeAndSection(grade: grade, section: section);
    if (students.isEmpty) {
      _showSnack('لا توجد جلاءات مطابقة للصف والشعبة المحددين.');
      return;
    }
    try {
      setState(() => _isExamReportExporting = true);
      final result = await _generateBulkExamReportsExport(
        grade: grade,
        section: section,
        pixelRatio: 3.15,
      );
      await Printing.layoutPdf(
        name: result.fileName,
        onLayout: (format) async => result.pdfBytes,
      );
      if (mounted) {
        _showSnack('تم تجهيز ${result.studentCount} جلاء/جلاءات للطباعة الجماعية بنجاح.');
        await _showBulkExamReportsExportDialog(result);
      }
    } catch (error) {
      _showSnack('تعذر تجهيز الطباعة الجماعية للجلاءات: $error');
    } finally {
      if (mounted) {
        setState(() => _isExamReportExporting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _initializeDatabase() async {
    await NotificationService.instance.init();
    await EmployeeService.instance.init();
    await FinanceService.instance.init();
    await MeetingService.instance.init();
    if (NotificationService.instance.all.isEmpty) {
      await NotificationService.instance.addSimple(
        type: 'info',
        title: 'مرحباً بك في مدرسة روز التعليمية',
        body: 'نظام إدارة متكامل للطلاب والموظفين والمحاسبة.',
        targetPage: 'dashboard',
      );
      await NotificationService.instance.addSimple(
        type: 'success',
        title: 'تم تجهيز قاعدة البيانات',
        body: 'جميع البيانات جاهزة، يمكنك البدء بالعمل.',
        targetPage: 'students',
      );
    }
    final existing = await _database.readJson('students');
    if (existing == null) {
      await _persistAll();
    }
    await _loadFromDatabase();
    final adminUsersExisting = await _database.readJson('admin_users');
    if (adminUsersExisting == null) {
      await _persistAdminUsers();
    }
    final schoolIdentityExisting = await _database.readJson('school_identity');
    if (schoolIdentityExisting == null) {
      await _database.saveJson('school_identity', _database.schoolIdentityToJson(_schoolIdentity));
    }
    await _migrateStoredMediaFiles();
    if (!mounted) return;
    setState(() => _isDatabaseReady = true);
  }

  Future<void> _loadFromDatabase() async {
    final studentsJson = await _database.readJson('students');
    final attachmentsJson = await _database.readJson('attachments');
    final backupsJson = await _database.readJson('backups');
    final messagesJson = await _database.readJson('messages');
    final attendanceJson = await _database.readJson('attendance');
    final disciplineJson = await _database.readJson('discipline');
    final certificatesJson = await _database.readJson('certificates');
    final examScheduleJson = await _database.readJson('exam_schedule');
    final examResultsJson = await _database.readJson('exam_results');
    final invoicesJson = await _database.readJson('invoices');
    final accountingDonationsJson = await _database.readJson('accounting_donations');
    final accountingAidsJson = await _database.readJson('accounting_aids');
    final receiptsJson = await _database.readJson('receipts');
    final adminUsersJson = await _database.readJson('admin_users');
    final schoolIdentityJson = await _database.readJson('school_identity');
    var adminUsersNormalized = false;

    setState(() {
      if (studentsJson != null) {
        _students
          ..clear()
          ..addAll(_database.studentsFromJson(jsonDecode(studentsJson) as List<dynamic>));
      }
      if (attachmentsJson != null) {
        _attachments
          ..clear()
          ..addAll(_database.attachmentsFromJson(jsonDecode(attachmentsJson) as List<dynamic>));
      }
      if (backupsJson != null) {
        _backups
          ..clear()
          ..addAll(_database.backupsFromJson(jsonDecode(backupsJson) as List<dynamic>));
      }
      if (messagesJson != null) {
        _messages
          ..clear()
          ..addAll(_database.messagesFromJson(jsonDecode(messagesJson) as List<dynamic>));
      }
      if (attendanceJson != null) {
        _attendance
          ..clear()
          ..addAll(_database.attendanceFromJson(jsonDecode(attendanceJson) as List<dynamic>));
      }
      if (disciplineJson != null) {
        _discipline
          ..clear()
          ..addAll(_database.disciplineFromJson(jsonDecode(disciplineJson) as List<dynamic>));
      }
      if (certificatesJson != null) {
        _certificates
          ..clear()
          ..addAll(_database.certificatesFromJson(jsonDecode(certificatesJson) as List<dynamic>));
      }
      if (examScheduleJson != null) {
        _examSchedule
          ..clear()
          ..addAll(_database.examSchedulesFromJson(jsonDecode(examScheduleJson) as List<dynamic>));
      }
      if (examResultsJson != null) {
        _examResults
          ..clear()
          ..addAll(_database.examResultsFromJson(jsonDecode(examResultsJson) as List<dynamic>));
      }
      if (invoicesJson != null) {
        _invoices
          ..clear()
          ..addAll(_database.invoicesFromJson(jsonDecode(invoicesJson) as List<dynamic>));
      }
      if (accountingDonationsJson != null) {
        _accountingDonations
          ..clear()
          ..addAll(_database.accountingDonationsFromJson(jsonDecode(accountingDonationsJson) as List<dynamic>));
      }
      if (accountingAidsJson != null) {
        _accountingAids
          ..clear()
          ..addAll(_database.accountingAidsFromJson(jsonDecode(accountingAidsJson) as List<dynamic>));
      }
      if (receiptsJson != null) {
        _receipts
          ..clear()
          ..addAll(_database.receiptsFromJson(jsonDecode(receiptsJson) as List<dynamic>));
      }
      if (adminUsersJson != null) {
        _adminUsers
          ..clear()
          ..addAll(_database.adminUsersFromJson(jsonDecode(adminUsersJson) as List<dynamic>));
      }
      if (_adminUsers.isEmpty) {
        _adminUsers.addAll(kInitialAdminUsers.map((user) => user.copyWith(password: _hashPassword(user.password))));
        adminUsersNormalized = true;
      } else {
        for (var i = 0; i < _adminUsers.length; i++) {
          final user = _adminUsers[i];
          if (user.password.length != 64) {
            _adminUsers[i] = user.copyWith(password: _hashPassword(user.password));
            adminUsersNormalized = true;
          }
        }
      }
      if (schoolIdentityJson != null) {
        _schoolIdentity = _database.schoolIdentityFromJson(jsonDecode(schoolIdentityJson) as Map<String, dynamic>);
      }
      _loadSchoolIdentityDraft();
      _loadAdminDraft();
      if (_students.isNotEmpty) {
        _loadStudent(_students.first);
      } else {
        _selectedStudentId = null;
      }
    });

    if (adminUsersNormalized) {
      await _persistAdminUsers();
    }
  }

  Future<void> _persistAll() async {
    await _database.saveJson('students', _database.studentsToJson(_students));
    await _database.saveJson('attachments', _database.attachmentsToJson(_attachments));
    await _database.saveJson('backups', _database.backupsToJson(_backups));
    await _database.saveJson('messages', _database.messagesToJson(_messages));
    await _database.saveJson('attendance', _database.attendanceToJson(_attendance));
    await _database.saveJson('discipline', _database.disciplineToJson(_discipline));
    await _database.saveJson('certificates', _database.certificatesToJson(_certificates));
    await _database.saveJson('exam_schedule', _database.examSchedulesToJson(_examSchedule));
    await _database.saveJson('exam_results', _database.examResultsToJson(_examResults));
    await _database.saveJson('invoices', _database.invoicesToJson(_invoices));
    await _database.saveJson('accounting_donations', _database.accountingDonationsToJson(_accountingDonations));
    await _database.saveJson('accounting_aids', _database.accountingAidsToJson(_accountingAids));
    await _database.saveJson('receipts', _database.receiptsToJson(_receipts));
    await _database.saveJson('admin_users', _database.adminUsersToJson(_adminUsers));
    await _database.saveJson('school_identity', _database.schoolIdentityToJson(_schoolIdentity));
  }

  @override
  void dispose() {
    _database.close();
    for (final controller in <TextEditingController>[
      _serialController,
      _fullNameController,
      _fatherNameController,
      _motherNameController,
      _grandfatherNameController,
      _birthPlaceController,
      _birthDateController,
      _registryPlaceController,
      _registryNumberController,
      _religionController,
      _firstLanguageOtherController,
      _secondLanguageOtherController,
      _spokenLanguageOtherController,
      _gradeController,
      _sectionController,
      _enrollmentDateController,
      _schoolYearController,
      _previousSchoolController,
      _failedGradesController,
      _otherLanguageController,
      _residenceController,
      _landlineController,
      _mobileController,
      _emailController,
      _transportGatheringController,
      _guardianNameController,
      _guardianRelationController,
      _guardianPhoneController,
      _guardianMobileController,
      _guardianWhatsappController,
      _guardianEmailController,
      _guardianWorkController,
      _guardianAddressController,
      _emergencyContactNameController,
      _emergencyContactPhoneController,
      _otherHobbiesController,
      _healthNotesController,
      _notesController,
      _transferNotesController,
      _attendanceDateController,
      _attendanceNoteController,
      _messageReasonController,
      _messageDateController,
      _messageTimeController,
      _messageBodyController,
      _disciplineDateController,
      _disciplineTitleController,
      _disciplineNoteController,
      _certificateDateController,
      _certificateTitleController,
      _certificateNoteController,
      _invoiceTitleController,
      _invoiceAmountController,
      _invoiceDateController,
      _receiptTitleController,
      _receiptAmountController,
      _receiptDateController,
      _receiptNoteController,
      _searchController,
      _schoolEmailController,
      _schoolWhatsappController,
      _schoolMobileController,
      _schoolLandlineController,
      _schoolWebsiteController,
      _schoolFacebookController,
      _secretaryNameController,
      _supervisorNameController,
      _principalNameController,
      _generalSupervisorController,
      _loginUsernameController,
      _loginPasswordController,
      _adminUsernameController,
      _adminPasswordController,
      _adminConfirmPasswordController,
      _adminEmailController,
      _adminMobileController,
      ..._transportDueControllers,
      ..._transportPaidControllers,
      ..._transportDateControllers,
      ..._regularDueControllers,
      ..._regularPaidControllers,
      ..._regularDateControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearNoteFieldOnFirstTap(TextEditingController controller) {
    if (_noteControllersClearedOnFirstTap.contains(controller)) {
      return;
    }
    controller.clear();
    _noteControllersClearedOnFirstTap.add(controller);
    setState(() {});
  }

  void _loadPaymentControllers(List<PaymentEntry> entries, List<TextEditingController> dueControllers, List<TextEditingController> paidControllers, List<TextEditingController> dateControllers, List<String> currencies) {
    for (var i = 0; i < 10; i++) {
      final entry = i < entries.length ? entries[i] : const PaymentEntry(dueAmount: '', paidAmount: '', currency: 'ليرة سورية', paymentDate: '');
      dueControllers[i].text = entry.dueAmount;
      paidControllers[i].text = entry.paidAmount;
      dateControllers[i].text = entry.paymentDate;
      currencies[i] = entry.currency.isEmpty ? 'ليرة سورية' : entry.currency;
    }
  }

  List<PaymentEntry> _collectPayments(List<TextEditingController> dueControllers, List<TextEditingController> paidControllers, List<TextEditingController> dateControllers, List<String> currencies) {
    final list = <PaymentEntry>[];
    for (var i = 0; i < 10; i++) {
      final due = dueControllers[i].text.trim();
      final paid = paidControllers[i].text.trim();
      final date = dateControllers[i].text.trim();
      final currency = currencies[i];
      if (due.isEmpty && paid.isEmpty && date.isEmpty) continue;
      list.add(PaymentEntry(dueAmount: due, paidAmount: paid, currency: currency, paymentDate: date));
    }
    return list;
  }

  void _loadStudent(StudentRecord student) {
    _selectedStudentId = student.id;
    _serialController.text = student.serial;
    _fullNameController.text = student.fullName;
    _fatherNameController.text = student.fatherName;
    _motherNameController.text = student.motherName;
    _grandfatherNameController.text = student.grandfatherName;
    _birthPlaceController.text = student.birthPlace;
    _birthDateController.text = student.birthDate;
    _registryPlaceController.text = student.registryPlace;
    _registryNumberController.text = student.registryNumber;
    _religionController.text = student.religion;
    _bloodType = student.bloodType;
    _firstLanguageOtherController.text = student.firstLanguageOther;
    _secondLanguageOtherController.text = student.secondLanguageOther;
    _spokenLanguageOtherController.text = student.spokenLanguageOther;
    _gradeController.text = student.grade;
    _sectionController.text = student.section;
    _enrollmentDateController.text = student.enrollmentDate;
    _enrollmentType = student.enrollmentType.isEmpty ? 'طالب جديد' : student.enrollmentType;
    _schoolYearController.text = student.schoolYear.isEmpty ? _currentAcademicYear() : student.schoolYear;
    _previousSchoolController.text = student.previousSchool;
    _failedGradesController.text = student.failedGrades;
    _otherLanguageController.text = student.otherLanguage;
    _residenceController.text = student.residence;
    _landlineController.text = student.landline;
    _mobileController.text = student.mobile;
    _emailController.text = student.email;
    _transportGatheringController.text = student.transportGathering;
    _guardianNameController.text = student.guardianName;
    _guardianRelationController.text = student.guardianRelation;
    _guardianPhoneController.text = student.guardianPhone;
    _guardianMobileController.text = student.guardianMobile;
    _guardianWhatsappController.text = student.guardianWhatsapp;
    _guardianEmailController.text = student.guardianEmail;
    _guardianWorkController.text = student.guardianWork;
    _guardianAddressController.text = student.guardianAddress;
    _emergencyContactNameController.text = student.emergencyContactName;
    _emergencyContactPhoneController.text = student.emergencyContactPhone;
    _otherHobbiesController.text = student.otherHobbies;
    _healthNotesController.text = student.healthNotes;
    _notesController.text = student.notes;
    _transferNotesController.text = student.transferNotes;
    _gender = student.gender;
    _status = student.status;
    _firstLanguage = student.firstLanguage;
    _secondLanguage = student.secondLanguage;
    _spokenLanguage = student.spokenLanguage;
    _enrollmentGrade = student.enrollmentGrade;
    _failedGradesSelected
      ..clear()
      ..addAll(
        student.failedGrades.isEmpty || student.failedGrades == 'لا يوجد'
            ? <String>[]
            : student.failedGrades
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toSet(),
      );
    _transportSubscription = student.transportSubscription;
    _healthStatus = student.healthStatus;
    _disabilityVisual = student.disabilityVisual;
    _disabilityHearing = student.disabilityHearing;
    _disabilityMotor = student.disabilityMotor;
    _disabilityLearning = student.disabilityLearning;
    _normalLife = student.normalLife;
    _orphanFather = student.orphanFather;
    _orphanMother = student.orphanMother;
    _orphanParents = student.orphanParents;
    _onlyChild = student.onlyChild;
    _livesSeparate = student.livesSeparate;
    _hobbyMusic = student.hobbyMusic;
    _hobbyDrawing = student.hobbyDrawing;
    _hobbyComputer = student.hobbyComputer;
    _hobbySports = student.hobbySports;
    _initiativeSchool = student.initiativeSchool;
    _initiativeFinancial = student.initiativeFinancial;
    _initiativeInKind = student.initiativeInKind;
    _initiativeProjects = student.initiativeProjects;
    _attendanceDateController.text = DateTime.now().toIso8601String().split('T').first;
    _attendanceNoteController.clear();
    _attendanceStatus = 'حاضر';
    _messageType = 'مراسلة الكترونية';
    _messageReasonController.clear();
    _messageDateController.text = DateTime.now().toIso8601String().split('T').first;
    _messageTimeController.text = '10:00';
    _messageBodyController.clear();
    _disciplineDateController.text = DateTime.now().toIso8601String().split('T').first;
    _disciplineTitleController.clear();
    _disciplineNoteController.clear();
    _disciplineType = 'مكافأة';
    _certificateDateController.text = DateTime.now().toIso8601String().split('T').first;
    _certificateTitleController.clear();
    _certificateNoteController.clear();
    _certificateKind = 'شهادة تقدير';
    _invoiceDateController.text = DateTime.now().toIso8601String().split('T').first;
    _invoiceTitleController.clear();
    _invoiceAmountController.clear();
    _receiptDateController.text = DateTime.now().toIso8601String().split('T').first;
    _receiptTitleController.clear();
    _receiptAmountController.clear();
    _receiptNoteController.clear();
    _invoiceCurrency = 'ليرة سورية';
    _receiptCurrency = 'ليرة سورية';
    _loadPaymentControllers(student.transportFees, _transportDueControllers, _transportPaidControllers, _transportDateControllers, _transportCurrencies);
    _loadPaymentControllers(student.regularFees, _regularDueControllers, _regularPaidControllers, _regularDateControllers, _regularCurrencies);
  }

  void _startNewStudent() {
    _selectedStudentId = null;
    _serialController.text = _nextSerial();
    for (final controller in <TextEditingController>[
      _fullNameController,
      _fatherNameController,
      _motherNameController,
      _grandfatherNameController,
      _birthPlaceController,
      _birthDateController,
      _registryPlaceController,
      _registryNumberController,
      _religionController,
      _firstLanguageOtherController,
      _secondLanguageOtherController,
      _spokenLanguageOtherController,
      _gradeController,
      _sectionController,
      _enrollmentDateController,
      _schoolYearController,
      _previousSchoolController,
      _failedGradesController,
      _otherLanguageController,
      _residenceController,
      _landlineController,
      _mobileController,
      _emailController,
      _transportGatheringController,
      _guardianNameController,
      _guardianRelationController,
      _guardianPhoneController,
      _guardianMobileController,
      _guardianWhatsappController,
      _guardianEmailController,
      _guardianWorkController,
      _guardianAddressController,
      _emergencyContactNameController,
      _emergencyContactPhoneController,
      _otherHobbiesController,
      _healthNotesController,
      _notesController,
      _transferNotesController,
    ]) {
      controller.clear();
    }
    _gender = 'ذكر';
    _status = 'نشط';
    _bloodType = '?';
    _firstLanguage = 'E';
    _secondLanguage = 'E';
    _spokenLanguage = 'E';
    _enrollmentType = 'طالب جديد';
    _enrollmentGrade = '1';
    _sectionController.text = '?';
    _schoolYearController.text = _currentAcademicYear();
    _failedGradesSelected.clear();
    _transportSubscription = 'نعم';
    _healthStatus = 'سليم';
    _disabilityVisual = false;
    _disabilityHearing = false;
    _disabilityMotor = false;
    _disabilityLearning = false;
    _normalLife = true;
    _orphanFather = false;
    _orphanMother = false;
    _orphanParents = false;
    _onlyChild = false;
    _livesSeparate = false;
    _hobbyMusic = false;
    _hobbyDrawing = false;
    _hobbyComputer = false;
    _hobbySports = false;
    _initiativeSchool = false;
    _initiativeFinancial = false;
    _initiativeInKind = false;
    _initiativeProjects = false;
    _attendanceStatus = 'حاضر';
    _attendanceDateController.text = '';
    _attendanceNoteController.clear();
    _messageType = 'مراسلة الكترونية';
    _messageReasonController.clear();
    _messageDateController.text = '';
    _messageTimeController.text = '';
    _messageBodyController.clear();
    _disciplineDateController.text = '';
    _disciplineTitleController.clear();
    _disciplineNoteController.clear();
    _disciplineType = 'مكافأة';
    _certificateDateController.text = '';
    _certificateTitleController.clear();
    _certificateNoteController.clear();
    _certificateKind = 'شهادة تقدير';
    _invoiceDateController.text = '';
    _invoiceTitleController.clear();
    _invoiceAmountController.clear();
    _receiptDateController.text = '';
    _receiptTitleController.clear();
    _receiptAmountController.clear();
    _receiptNoteController.clear();
    _invoiceCurrency = 'ليرة سورية';
    _receiptCurrency = 'ليرة سورية';
    _loadPaymentControllers(const <PaymentEntry>[], _transportDueControllers, _transportPaidControllers, _transportDateControllers, _transportCurrencies);
    _loadPaymentControllers(const <PaymentEntry>[], _regularDueControllers, _regularPaidControllers, _regularDateControllers, _regularCurrencies);
    setState(() {
      _currentPage = 'form';
    });
  }

  String _nextSerial() {
    final highest = _students.fold<int>(0, (prev, student) {
      final parts = student.serial.split('-');
      final n = parts.isNotEmpty ? int.tryParse(parts.last) ?? 0 : 0;
      return n > prev ? n : prev;
    });
    final next = (highest + 1).toString().padLeft(4, '0');
    return 'RS-2026-$next';
  }

  Future<void> _saveStudent() async {
    final existingRecord = _selectedStudentId == null ? null : _studentById(_selectedStudentId!);
    final newRecord = StudentRecord(
      id: _selectedStudentId ?? DateTime.now().millisecondsSinceEpoch,
      serial: _serialController.text.trim().isEmpty ? _nextSerial() : _serialController.text.trim(),
      fullName: _fullNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      grandfatherName: _grandfatherNameController.text.trim(),
      guardianName: _guardianNameController.text.trim(),
      guardianRelation: _guardianRelationController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      guardianMobile: _guardianMobileController.text.trim(),
      guardianWhatsapp: _guardianWhatsappController.text.trim(),
      guardianEmail: _guardianEmailController.text.trim(),
      guardianWork: _guardianWorkController.text.trim(),
      guardianAddress: _guardianAddressController.text.trim(),
      emergencyContactName: _emergencyContactNameController.text.trim(),
      emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
      grade: _gradeController.text.trim().isEmpty ? _enrollmentGrade : _gradeController.text.trim(),
      section: _sectionController.text.trim().isEmpty ? '?' : _sectionController.text.trim(),
      gender: _gender,
      status: _status,
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      registryPlace: _registryPlaceController.text.trim(),
      registryNumber: _registryNumberController.text.trim(),
      religion: _religionController.text.trim(),
      bloodType: _bloodType,
      enrollmentDate: _enrollmentDateController.text.trim(),
      enrollmentType: _enrollmentType,
      enrollmentGrade: _enrollmentGrade,
      schoolYear: _schoolYearController.text.trim().isEmpty ? _currentAcademicYear() : _schoolYearController.text.trim(),
      previousSchool: _enrollmentType == 'طالب منقول' ? _previousSchoolController.text.trim() : '',
      failedGrades: _failedGradesSelected.isEmpty ? '' : _failedGradesSelected.join(','),
      firstLanguage: _firstLanguage,
      firstLanguageOther: _firstLanguageOtherController.text.trim(),
      secondLanguage: _secondLanguage,
      secondLanguageOther: _secondLanguageOtherController.text.trim(),
      spokenLanguage: _spokenLanguage,
      spokenLanguageOther: _spokenLanguageOtherController.text.trim(),
      otherLanguage: [_firstLanguageOtherController.text.trim(), _secondLanguageOtherController.text.trim(), _spokenLanguageOtherController.text.trim()].where((e) => e.isNotEmpty).join(' | '),
      residence: _residenceController.text.trim(),
      landline: _landlineController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      studentPhotoPath: existingRecord?.studentPhotoPath ?? '',
      qrFilePath: existingRecord?.qrFilePath ?? '',
      studentCardPdfPath: existingRecord?.studentCardPdfPath ?? '',
      studentCardPngPath: existingRecord?.studentCardPngPath ?? '',
      transportGathering: _transportGatheringController.text.trim(),
      transportSubscription: _transportSubscription,
      healthStatus: _healthStatus,
      disabilityVisual: _disabilityVisual,
      disabilityHearing: _disabilityHearing,
      disabilityMotor: _disabilityMotor,
      disabilityLearning: _disabilityLearning,
      normalLife: _normalLife,
      orphanFather: _orphanFather,
      orphanMother: _orphanMother,
      orphanParents: _orphanParents,
      onlyChild: _onlyChild,
      livesSeparate: _livesSeparate,
      hobbyMusic: _hobbyMusic,
      hobbyDrawing: _hobbyDrawing,
      hobbyComputer: _hobbyComputer,
      hobbySports: _hobbySports,
      otherHobbies: _otherHobbiesController.text.trim(),
      initiativeSchool: _initiativeSchool,
      initiativeFinancial: _initiativeFinancial,
      initiativeInKind: _initiativeInKind,
      initiativeProjects: _initiativeProjects,
      healthNotes: _healthNotesController.text.trim(),
      notes: _notesController.text.trim(),
      transferNotes: _transferNotesController.text.trim(),
      transportFees: _collectPayments(_transportDueControllers, _transportPaidControllers, _transportDateControllers, _transportCurrencies),
      regularFees: _collectPayments(_regularDueControllers, _regularPaidControllers, _regularDateControllers, _regularCurrencies),
    );

    final index = _students.indexWhere((student) => student.id == newRecord.id);
    setState(() {
      if (index >= 0) {
        _students[index] = newRecord;
      } else {
        _students.insert(0, newRecord);
      }
      _selectedStudentId = newRecord.id;
      _currentPage = 'students';
    });
    await _ensureStudentQrFile(
      newRecord.id,
      forceRegenerate: existingRecord == null || (existingRecord.qrFilePath.isEmpty),
    );
    await _persistAll();
    if (!mounted) {
      return;
    }
    setState(() {});
    _showSnack('تمت العملية بنجاح: حفظ بيانات الطالب مع تحديث رابط QR في SQLite.');
  }

  Future<void> _deleteStudent() async {
    if (_selectedStudentId == null) {
      _showSnack('لا يوجد سجل محدد للحذف.');
      return;
    }
    final studentId = _selectedStudentId!;
    final student = _studentById(studentId);
    final studentAttachments = _studentAttachments(studentId);

    if (student != null) {
      await _fileStorage.deleteFile(student.studentPhotoPath);
      await _fileStorage.deleteFile(student.qrFilePath);
      await _fileStorage.deleteFile(student.studentCardPdfPath);
      await _fileStorage.deleteFile(student.studentCardPngPath);
    }
    for (final attachment in studentAttachments) {
      await _fileStorage.deleteFile(attachment.storedPath);
    }
    await _fileStorage.deleteStudentDirectory(studentId);

    setState(() {
      _attachments.removeWhere((attachment) => attachment.studentId == studentId);
      _students.removeWhere((record) => record.id == studentId);
      if (_students.isNotEmpty) {
        _loadStudent(_students.first);
        _currentPage = 'students';
      } else {
        _startNewStudent();
      }
    });
    await _persistAll();
    _showSnack('تمت العملية بنجاح: حذف السجل وملفاته المحلية.');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDatabaseReady) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('جارٍ تهيئة قاعدة البيانات وتحميل البيانات...'),
            ],
          ),
        ),
      );
    }
    if (!_isAuthenticated) {
      return _buildLoginScreen(context);
    }
    final wide = MediaQuery.of(context).size.width > 1100;
    return Scaffold(
      body: wide
          ? Row(
              children: <Widget>[
                Expanded(child: _buildMainArea(context)),
                _buildSidebar(context),
              ],
            )
          : Column(
              children: <Widget>[
                Expanded(child: _buildMainArea(context)),
                SizedBox(height: 320, child: _buildSidebar(context)),
              ],
            ),
    );
  }

  Widget _buildLoginScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[Color(0xFF0D1D43), Color(0xFF123A78), Color(0xFF2F9A8E)],
          ),
        ),
        child: Center(
          child: Container(
            width: 980,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(34),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.20), blurRadius: 30, offset: Offset(0, 12)),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(34), bottomRight: Radius.circular(34)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0xFF16120F), Color(0xFF0F1F4A), Color(0xFF0E2F73)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset('image/logo.jpg', width: 96, height: 96, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 18),
                        const Text('مدرسة روز التعليمية', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        const Text('لوحة دخول المستخدمين إلى النظام الإداري المتكامل بهوية لونية معتمدة من الشعار الرسمي.', style: TextStyle(color: Colors.white70, height: 1.9)),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const <Widget>[
                            _LoginTag('أمانة السر'),
                            _LoginTag('المحاسبة'),
                            _LoginTag('الامتحانات'),
                            _LoginTag('الإدارة'),
                          ],
                        ),
                        const Spacer(),
                        const Text('بيانات الدخول الحالية للاختبار:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('اسم المستخدم: admin\nكلمة المرور: admin', style: TextStyle(color: Colors.white70, height: 1.8)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('تسجيل الدخول', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                        const SizedBox(height: 10),
                        const Text('أدخل بيانات المستخدم المُنشأ من قبل الإدارة للوصول إلى الأبواب المسموح بها فقط.', style: TextStyle(color: AppPalette.muted, height: 1.9)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _loginUsernameController,
                          decoration: InputDecoration(
                            labelText: 'اسم المستخدم',
                            filled: true,
                            fillColor: const Color(0xFFFBFDFF),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: true,
                          onSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            filled: true,
                            fillColor: const Color(0xFFFBFDFF),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
                          ),
                        ),
                        if (_loginError.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(_loginError, style: const TextStyle(color: AppPalette.roseRed, fontWeight: FontWeight.w700)),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            _actionButton('دخول', AppPalette.goldDark, Colors.white, _login),
                            const SizedBox(width: 10),
                            _actionButton('إعادة تعيين', const Color(0xFFEDF6FF), const Color(0xFF24436F), () {
                              setState(() {
                                _loginUsernameController.text = 'admin';
                                _loginPasswordController.text = 'admin';
                                _loginError = '';
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final groups = <_NavGroup>[
      _NavGroup(
        id: 'administration',
        title: 'الإدارة',
        primaryColor: const Color(0xFFA82A38),
        secondaryColor: const Color(0xFF10295A),
        items: const <_NavItem>[
          _NavItem('dashboard', '📊 لوحة القيادة'),
          _NavItem('employees', '👥 الموظفين'),
          _NavItem('employee_review', '🔍 مراجعة الموظفين'),
          _NavItem('admin_dashboard', 'لوحة الإدارة'),
          _NavItem('admin_identity', 'الهوية والاعتماد'),
        ],
      ),
      _NavGroup(
        id: 'secretariat',
        title: 'أمانة السر',
        primaryColor: const Color(0xFF123A78),
        secondaryColor: const Color(0xFF0D1D43),
        items: const <_NavItem>[
          _NavItem('students', 'قائمة الطلاب'),
          _NavItem('form', 'استمارة طالب'),
          _NavItem('attendance', 'الحضور والغياب'),
          _NavItem('donations', 'التبرعات'),
          _NavItem('discipline', 'المكافآت والعقوبات'),
          _NavItem('certificates', 'الشهادات'),
          _NavItem('documents', 'الوثائق والمرفقات'),
          _NavItem('reports', 'التقارير'),
          _NavItem('student_sorting', '🔍 فرز الطلاب'),
          _NavItem('student_card', 'بطاقة الطالب والطباعة'),
          _NavItem('backup', 'النسخ الاحتياطي والاستعادة'),
          _NavItem('data_center', '📁 مركز البيانات المحلي'),
          _NavItem('parent_meetings', '📅 اجتماعات أولياء الأمور'),
          _NavItem('transport', 'النقل المدرسي'),
          _NavItem('messages', 'مراسلات أولياء الأمور'),
        ],
      ),
      _NavGroup(
        id: 'exams',
        title: 'الامتحانات',
        primaryColor: const Color(0xFF1E7A79),
        secondaryColor: const Color(0xFF123A78),
        items: const <_NavItem>[_NavItem('exams', 'لوحة الامتحانات')],
      ),
      _NavGroup(
        id: 'accounting',
        title: 'المحاسبة',
        primaryColor: const Color(0xFF1E7A43),
        secondaryColor: const Color(0xFF2F9A8E),
        items: const <_NavItem>[
          _NavItem('accounting', 'لوحة المحاسبة'),
          _NavItem('income_expenses', '💰 الإيرادات والصرفيات'),
        ],
      ),
    ];
    final user = _authenticatedUser;
    final visibleGroups = groups.where((group) => _userHasDoorPermission(user, group.id)).toList();

    return Container(
      width: 308,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF16120F), Color(0xFF0F1F4A), Color(0xFF0E2F73)],
        ),
      ),
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'مدرسة روز التعليمية',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _authenticatedUser == null ? 'غير مسجل الدخول' : 'المستخدم: ${_authenticatedUser!.username}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white54, width: 2),
                  color: Colors.white10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset('image/logo.jpg', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _actionButton('تسجيل الخروج', Colors.white, AppPalette.deepNavySoft, _logout),
          const SizedBox(height: 18),
          ...visibleGroups.map(_buildNavGroup),
        ],
      ),
    );
  }

  Widget _buildNavGroup(_NavGroup group) {
    final groupContainsCurrent = group.items.any((item) => item.id == _currentPage);
    final isOpen = _openNavGroups.contains(group.id) || groupContainsCurrent;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (_openNavGroups.contains(group.id)) {
                  _openNavGroups.remove(group.id);
                } else {
                  _openNavGroups.add(group.id);
                }
              });
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: <Color>[group.primaryColor, group.secondaryColor]),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.18), blurRadius: 14, offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      group.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    isOpen ? '▾' : '◂',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: group.primaryColor.withOpacity(0.42), width: 2),
                ),
              ),
              child: Column(
                children: group.items.map((item) {
                  final active = item.id == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      hoverColor: const Color.fromRGBO(201, 160, 78, 0.18),
                      onTap: () => setState(() => _currentPage = item.id),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: active
                              ? LinearGradient(colors: <Color>[group.primaryColor, group.secondaryColor])
                              : null,
                          color: active ? null : Colors.white.withOpacity(0.06),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: active ? Colors.white : Colors.white.withOpacity(0.84),
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (active)
                              const Text('•', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainArea(BuildContext context) {
    final info = _pageInfo();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppPalette.sky, AppPalette.skyDark],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color.fromRGBO(255, 255, 255, 0.12),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.44)),
        ),
        child: Column(
          children: <Widget>[
            _buildHeader(info),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 16),
            Expanded(child: _buildPageBody()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.68),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.line),
              ),
              child: const Text(
                'هذه هي المرحلة الفعلية الأولى داخل Flutter: قائمة الطلاب واستمارة الطالب تعملان داخل القالب الحقيقي نفسه، مع الشعار الرسمي وألوان الهوية المعتمدة.',
                style: TextStyle(color: AppPalette.muted, height: 1.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PageInfo _pageInfo() {
    switch (_currentPage) {
      case 'dashboard':
        return const _PageInfo(
          '📊 لوحة القيادة',
          'الصفحة الرئيسية',
          'مرحباً بك في نظام روز التعليمي. هذه لوحة القيادة الرئيسية تعرض لك إحصائيات حية عن الطلاب والإيرادات والصرفيات وآخر الإشعارات.',
        );
      case 'employees':
        return const _PageInfo(
          '👥 الموظفين',
          'أمانة السر، الموظفين',
          'إضافة وتعديل وعرض الموظفين. أمانة السر تملأ البيانات الشخصية فقط، ثم تذهب للمراجعة المالية من الإدارة.',
        );
      case 'employee_review':
        return const _PageInfo(
          '🔍 مراجعة الموظفين',
          'الإدارة، مراجعة الموظفين',
          'مراجعة الموظفين الجدد، إقرار الرواتب والمكافآت والخصومات، أو رفض الطلب مع إيضاح السبب.',
        );
      case 'income_expenses':
        return const _PageInfo(
          '💰 الإيرادات والصرفيات',
          'المحاسبة، الإيرادات والصرفيات',
          'إدارة الإيرادات والصرفيات مع تصنيفات قابلة للتخصيص. يعرض ملخصاً شهرياً مع إمكانية إضافة وتحرير التصنيفات.',
        );
      case 'admin_dashboard':
        return const _PageInfo(
          'لوحة الإدارة',
          'الإدارة، لوحة الإدارة',
          'يعرض هذا الباب صلاحيات المستخدم الحالي والوصول إلى هوية المدرسة وإدارة المستخدمين بشكل فعلي من داخل Flutter مع حفظها في SQLite.',
        );
      case 'admin_identity':
        return const _PageInfo(
          'الهوية والاعتماد',
          'الإدارة، الهوية والاعتماد',
          'إدارة بيانات المدرسة المعتمدة وإنشاء المستخدمين وتعديل الصلاحيات وتسجيل الدخول الحقيقي من داخل التطبيق.',
        );
      case 'students':
        return const _PageInfo(
          'قائمة الطلاب',
          'أمانة السر، قائمة الطلاب',
          'اضغط على أي طالب من الجدول لفتح استمارته، أو استخدم زر طالب جديد لإضافة سجل جديد مع المحافظة على القالب البصري القديم.',
        );
      case 'form':
        return const _PageInfo(
          'استمارة الطالب',
          'أمانة السر، استمارة الطالب',
          'تم نقل استمارة الطالب فعليًا إلى Flutter مع الحفاظ على شكل الواجهة القديمة وإدراج الحقول والإضافات المطلوبة.',
        );
      case 'attendance':
        return const _PageInfo(
          'الحضور والغياب',
          'أمانة السر، الحضور والغياب',
          'تسجيل الحضور والغياب والتأخر والمأذون مع اختيار الطالب والتاريخ والملاحظات.',
        );
      case 'donations':
        return const _PageInfo(
          'التبرعات',
          'أمانة السر، التبرعات',
          'إدارة التبرعات العينية والمادية مع ربطها بسجل الطالب والبيانات المالية.',
        );
      case 'reports':
        return const _PageInfo(
          'التقارير',
          'أمانة السر، التقارير',
          'هذا القسم محفوظ حاليًا داخل الواجهة الفعلية، وسيتم ربطه لاحقًا بالتصدير الكامل إلى Excel وPDF.',
        );
      case 'student_card':
        return const _PageInfo(
          'بطاقة الطالب',
          'أمانة السر، بطاقة الطالب والطباعة',
          'يمكنك الآن معاينة البطاقة المدرسية الفعلية وتجهيزها كـ PDF وصورة جاهزة للطباعة مع اللوغو وصورة الطالب وQR.',
        );
      case 'parent_meetings':
        return const _PageInfo(
          '📅 اجتماعات أولياء الأمور',
          'أمانة السر، اجتماعات أولياء الأمور',
          'إدارة اجتماعات أولياء الأمور، تسجيل الحضور والغياب، وعرض تقارير إحصائية عن نسب الحضور.',
        );
      case 'backup':
        return const _PageInfo(
          'النسخ الاحتياطي',
          'أمانة السر، النسخ الاحتياطي والاستعادة',
          'تم إنشاء النسخة الاحتياطية الثانية، وسيتم لاحقًا ربط هذا الباب وظيفيًا داخل التطبيق نفسه.',
        );
      case 'student_sorting':
        return const _PageInfo(
          '🔍 فرز الطلاب',
          'أمانة السر، فرز الطلاب',
          'فرز الطلاب حسب الصفوف أو حسب الصف والشعبة مع ترتيب حسب الأعلى درجات.',
        );
      case 'data_center':
        return const _PageInfo(
          '📁 مركز البيانات المحلي',
          'أمانة السر، مركز البيانات',
          'إدارة قاعدة البيانات المحلية والملفات. إنشاء واستعادة النسخ الاحتياطية، مراقبة حالة التخزين، وتصدير البيانات.',
        );
      case 'transport':
        return const _PageInfo(
          'النقل المدرسي',
          'أمانة السر، النقل المدرسي',
          'استعراض الطلاب حسب حالة الاشتراك بوسائل النقل المدرسي مع أماكن الانتظار والتواصل السريع.',
        );
      case 'messages':
        return const _PageInfo(
          'مراسلات أولياء الأمور',
          'أمانة السر، مراسلات أولياء الأمور',
          'إضافة الإشعارات والاستدعاءات والملاحظات المرتبطة بكل طالب وولي أمره.',
        );
      case 'discipline':
        return const _PageInfo(
          'المكافآت والعقوبات',
          'أمانة السر، المكافآت والعقوبات',
          'تسجيل المكافآت والعقوبات لكل طالب مع التاريخ والملاحظة ونوع الإجراء.',
        );
      case 'certificates':
        return const _PageInfo(
          'الشهادات',
          'أمانة السر، الشهادات',
          'إدارة الشهادات الصادرة للطالب مثل التفوق أو المشاركة أو غيرها.',
        );
      case 'accounting':
        return const _PageInfo(
          'المحاسبة',
          'المحاسبة، القوائم الذكية للمدفوعات',
          'تم تحديث لوحة المحاسبة لتعرض القسط والتبرع والمساعدة فقط، مع فرز جميل حسب الطالب وحسب الشعبة وشاشات عرض مستقلة لكل نوع.',
        );
      case 'exams':
        return const _PageInfo(
          'الامتحانات',
          'الامتحانات، الدرجات والجلاء المدرسي',
          'إدخال درجات كل مادة للفصلين مع احتساب المحصلات تلقائيًا، وتحديث الجلاء المدرسي مع أزرار معاينة وطباعة بشكل بصري قريب من النموذج المعتمد.',
        );
      default:
        return _PageInfo(
          _pageLabel(_currentPage),
          _pageLabel(_currentPage),
          'هذا القسم محفوظ ضمن الهيكل الفعلي وسيتم استكماله تدريجيًا.',
        );
    }
  }

  static String _pageLabel(String id) {
    const labels = <String, String>{
      'dashboard': '📊 لوحة القيادة',
      'employees': '👥 الموظفين',
      'employee_review': '🔍 مراجعة الموظفين',
      'admin_dashboard': 'لوحة الإدارة',
      'admin_identity': 'الهوية والاعتماد',
      'attendance': 'الحضور والغياب',
      'donations': 'التبرعات',
      'discipline': 'المكافآت والعقوبات',
      'certificates': 'الشهادات',
      'documents': 'الوثائق والمرفقات',
      'transport': 'النقل المدرسي',
      'student_sorting': '🔍 فرز الطلاب',
      'parent_meetings': '📅 اجتماعات أولياء الأمور',
      'data_center': '📁 مركز البيانات المحلي',
      'messages': 'مراسلات أولياء الأمور',
      'exams': 'لوحة الامتحانات',
      'accounting': 'لوحة المحاسبة',
    };
    return labels[id] ?? id;
  }

  Widget _buildHeader(_PageInfo info) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _handleStudentSearch(),
                decoration: InputDecoration(
                  hintText: 'ابحث...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.95),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: _handleStudentSearch,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Notification bell
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                final unread = NotificationService.instance.unreadCount;
                if (unread > 0) {
                  NotificationService.instance.markAllAsRead();
                  setState(() {});
                  _showSnack('تم تحديد $unread إشعار/إشعارات كمقروءة.');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppPalette.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.notifications_outlined, size: 20, color: AppPalette.deepNavySoft),
                    if (NotificationService.instance.unreadCount > 0) ...<Widget>[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppPalette.roseRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${NotificationService.instance.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(info.subtitle, style: const TextStyle(color: AppPalette.muted, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  info.title,
                  style: const TextStyle(
                    color: AppPalette.deepNavy,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(247, 236, 214, 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(201, 160, 78, 0.42)),
          ),
          child: Text(
            info.hint,
            style: const TextStyle(color: Color(0xFF7B5830), height: 1.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    const stats = <Map<String, dynamic>>[
      {'value': '421', 'label': 'إناث', 'c1': AppPalette.roseRed, 'c2': Color(0xFF7E1F2A), 'icon': '♀'},
      {'value': '421', 'label': 'ذكور', 'c1': AppPalette.royalBlue, 'c2': Color(0xFF0E2F66), 'icon': '♂'},
      {'value': '798', 'label': 'نشطون', 'c1': AppPalette.leafGreen, 'c2': Color(0xFF166534), 'icon': '✓'},
      {'value': '842', 'label': 'إجمالي الطلاب', 'c1': AppPalette.gold, 'c2': AppPalette.goldDark, 'icon': '■'},
    ];

    return SizedBox(
      height: 108,
      child: Row(
        children: List<Widget>.generate(stats.length, (index) {
          final stat = stats[index];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == stats.length - 1 ? 0 : 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppPalette.line),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          stat['value'] as String,
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: AppPalette.text, height: 1),
                        ),
                        const SizedBox(height: 8),
                        Text(stat['label'] as String, style: const TextStyle(color: AppPalette.muted, fontSize: 15)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(colors: <Color>[stat['c1'] as Color, stat['c2'] as Color]),
                    ),
                    child: Center(
                      child: Text(stat['icon'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageBody() {
    switch (_currentPage) {
      case 'dashboard':
        return _dashboardPageWrapped();
      case 'employees':
        return _employeesPageWrapped();
      case 'employee_review':
        return _employeeReviewPageWrapped();
      case 'admin_dashboard':
        return _adminDashboardPage();
      case 'admin_identity':
        return _adminIdentityPage();
      case 'students':
        return _studentsPage();
      case 'form':
        return _studentFormPage();
      case 'reports':
        return _reportsPage();
      case 'student_card':
        return _studentCardPage();
      case 'attendance':
        return _attendancePage();
      case 'donations':
        return _donationsPage();
      case 'documents':
        return _documentsPage();
      case 'student_sorting':
        return _studentSortingPageWrapped();
      case 'parent_meetings':
        return _parentMeetingsPageWrapped();
      case 'backup':
        return _backupPage();
      case 'data_center':
        return _dataCenterPageWrapped();
      case 'transport':
        return _transportPage();
      case 'messages':
        return _messagesPage();
      case 'discipline':
        return _disciplinePage();
      case 'certificates':
        return _certificatesPage();
      case 'income_expenses':
        return _incomeExpensesPageWrapped();
      case 'accounting':
        return _accountingPage();
      case 'exams':
        return _examsPage();
      default:
        return _placeholderPage(_pageLabel(_currentPage));
    }
  }

  Widget _employeesPageWrapped() {
    return EmployeesPage(
      onNavigate: (pageId, {String? targetId}) {
        setState(() => _currentPage = pageId);
      },
    );
  }

  Widget _employeeReviewPageWrapped() {
    return const EmployeeFinanceReviewPage();
  }

  Widget _incomeExpensesPageWrapped() {
    return const AccountingIncomeExpensesPage();
  }

  Widget _dataCenterPageWrapped() {
    return const LocalDataCenterPage();
  }

  Widget _studentSortingPageWrapped() {
    return StudentSortingPage(students: _students);
  }

  Widget _parentMeetingsPageWrapped() {
    return ParentMeetingsPage(
      students: _students,
      onNavigate: (pageId, {String? targetId}) {
        setState(() => _currentPage = pageId);
      },
    );
  }

  Widget _dashboardPageWrapped() {
    final studentCount = _students.length;
    final maleCount = _students.where((s) => s.gender == 'ذكر').length;
    final femaleCount = _students.where((s) => s.gender == 'أنثى').length;

    double totalIncome = 0;
    for (final d in _accountingDonations) {
      totalIncome += d.amount;
    }
    for (final i in _invoices) {
      totalIncome += i.amount;
    }
    double totalExpenses = 0;
    for (final r in _receipts) {
      totalExpenses += r.amount;
    }

    return DashboardPage(
      studentCount: studentCount,
      studentMaleCount: maleCount,
      studentFemaleCount: femaleCount,
      employeeCount: 0, // will be updated when employees module is built
      userCount: _adminUsers.length,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      onNavigate: (pageId, {String? targetId}) {
        setState(() => _currentPage = pageId);
      },
      onRefresh: () => setState(() {}),
    );
  }

  Widget _adminDashboardPage() => _adminDashboardPageSection();

  Widget _adminIdentityPage() => _adminIdentityPageSection();

  Widget _studentsPage() => _studentsPageSection();

  Widget _studentFormPage() => _studentFormPageSection();

  Widget _reportsPage() => _reportsPageSection();

  Widget _studentCardPage() => _studentCardPageSection();

  Widget _attendancePage() => _attendancePageSection();

  Widget _donationsPage() => _donationsPageSection();

  Widget _accountingPage() => _accountingPageSection();

  Widget _documentsPage() => _documentsPageSection();

  Widget _backupPage() => _backupPageSection();

  Widget _transportPage() => _transportPageSection();

  Widget _messagesPage() => _messagesPageSection();

  Widget _disciplinePage() => _disciplinePageSection();

  Widget _certificatesPage() => _certificatesPageSection();

  Widget _examsPage() => _examsPageSection();

  Widget _placeholderPage(String title) => _placeholderPageSection(title);

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: bg == Colors.white ? const BorderSide(color: Color(0xFFD6E4F1)) : BorderSide.none,
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

