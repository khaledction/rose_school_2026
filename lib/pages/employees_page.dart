import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/employee_model.dart';
import '../services/app_storage_paths_service.dart';
import '../services/employee_service.dart';
import '../services/notification_service.dart';
import '../theme/app_palette.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({
    super.key,
    required this.onNavigate,
  });

  final void Function(String pageId, {String? targetId}) onNavigate;

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'سوري');
  final _birthDateController = TextEditingController();
  final _residenceController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hireDateController = TextEditingController();
  final _notesController = TextEditingController();

  static const List<String> _qualificationOptions = <String>[
    'دكتوراه',
    'ماجستير',
    'دراسات عليا',
    'دبلوم تأهيل تربوي',
    'اجازة 6 سنوات',
    'اجازة 5 سنوات',
    'اجازة 4 سنوات',
    'معهد متوسط',
    'رياض أطفال',
    'شهادة الثانوية',
    'شهادة التعليم الأساسي',
    'الأبتدائية',
    'يجيد القراءة و الكتابة',
  ];

  /// مواد الجلاء (بدون تكرار) + خيار عام
  static const List<String> _specializationOptions = <String>[
    'أنشطة',
    'اجتماعيات',
    'التربية الدينية',
    'التربية الرياضية',
    'التربية الموسيقية',
    'الرياضيات',
    'العلوم والتربية الصحية',
    'العلوم العامة',
    'الفنون الجمالية',
    'اللغة الإنكليزية',
    'اللغة الأجنبية',
    'اللغة العربية',
    'اللغة الفرنسية',
    'مهارات شفوية',
    'مهارات كتابية',
    'سلوك',
    'تكنلوجيا المعلومات والاتصالات',
    'المعلوماتية',
    'التاريخ',
    'الجغرافيا',
    'الفلسفة',
    'الوطنية',
    'الفيزياء',
    'الكيمياء',
    'علم الأحياء',
    'إداري',
    'أخرى',
  ];

  static const List<String> _departmentOptions = <String>[
    'روضة',
    'نشاطات وترفيه',
    'التعليم الاساسي ( 1 - 4 )',
    'التعليم الاساسي ( 5 - 6 )',
    'التعليم الاساسي ( 7 - 9 )',
    'الثانوي',
    'الإداري',
    'العمالة',
    'أخر',
  ];

  String _department = 'روضة';
  String _departmentOther = '';
  final _departmentOtherController = TextEditingController();
  String _qualification = 'شهادة الثانوية';
  String _specialization = 'الرياضيات';
  String _jobType = 'معلم';
  String _gender = 'ذكر';
  String _photoPath = '';
  int? _selectedEmployeeId;
  bool _showForm = false;
  String _filterStatus = 'الكل';

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _nationalityController.dispose();
    _birthDateController.dispose();
    _residenceController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _hireDateController.dispose();
    _notesController.dispose();
    _departmentOtherController.dispose();
    super.dispose();
  }

  List<EmployeeRecord> get _filteredEmployees {
    final all = EmployeeService.instance.all;
    if (_filterStatus == 'الكل') return all;
    return all.where((e) => e.status == _filterStatus).toList();
  }

  void _clearForm() {
    _selectedEmployeeId = null;
    _fullNameController.clear();
    _nationalIdController.clear();
    _nationalityController.text = 'سوري';
    _birthDateController.clear();
    _residenceController.clear();
    _mobileController.clear();
    _emailController.clear();
    _qualificationController.clear();
    _specializationController.clear();
    _hireDateController.clear();
    _department = _departmentOptions.first;
    _departmentOther = '';
    _departmentOtherController.clear();
    _qualification = _qualificationOptions.first;
    _specialization = _specializationOptions.first;
    _notesController.clear();
    _jobType = 'معلم';
    _gender = 'ذكر';
    _photoPath = '';
  }

  void _loadEmployee(EmployeeRecord emp) {
    _selectedEmployeeId = emp.id;
    _fullNameController.text = emp.fullName;
    _nationalIdController.text = emp.nationalId;
    _nationalityController.text = emp.nationality;
    _birthDateController.text = emp.birthDate;
    _residenceController.text = emp.residence;
    _mobileController.text = emp.mobile;
    _emailController.text = emp.email;
    _qualificationController.text = emp.qualification;
    _specializationController.text = emp.specialization;
    _hireDateController.text = emp.hireDate;
    if (_departmentOptions.contains(emp.department)) {
      _department = emp.department;
      _departmentOther = '';
    _departmentOtherController.clear();
    } else if (emp.department.isEmpty) {
      _department = _departmentOptions.first;
      _departmentOther = '';
    _departmentOtherController.clear();
    } else {
      _department = 'أخر';
      _departmentOther = emp.department;
    }
    _qualification = _qualificationOptions.contains(emp.qualification)
        ? emp.qualification
        : (emp.qualification.isEmpty ? _qualificationOptions.first : emp.qualification);
    _specialization = _specializationOptions.contains(emp.specialization)
        ? emp.specialization
        : (emp.specialization.isEmpty ? _specializationOptions.first : emp.specialization);
    // keep controllers in sync for legacy display
    _qualificationController.text = _qualification;
    _specializationController.text = _specialization;
    _notesController.text = emp.notes;
    _jobType = emp.jobType;
    _gender = (emp.gender == 'أنثى') ? 'أنثى' : 'ذكر';
    _photoPath = emp.photoPath;
    _showForm = true;
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final paths = AppStoragePathsService.instance;
    final empDir = await paths.employeeFilesDir(DateTime.now().millisecondsSinceEpoch);
    final file = File(picked.path);
    final targetPath = '${empDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await file.copy(targetPath);
    setState(() => _photoPath = targetPath);
  }

  String _nextEmployeeSerial() {
    return 'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  Future<void> _saveEmployee() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الاسم الكامل مطلوب.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_nationalIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم السجل المدني مطلوب.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final employee = EmployeeRecord(
      id: _selectedEmployeeId ?? DateTime.now().millisecondsSinceEpoch,
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      nationality: _nationalityController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      residence: _residenceController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      qualification: _qualification,
      specialization: _specialization,
      hireDate: _hireDateController.text.trim(),
      jobType: _jobType,
      department: _department == 'أخر'
          ? (() {
              final other = _departmentOtherController.text.trim().isEmpty
                  ? _departmentOther.trim()
                  : _departmentOtherController.text.trim();
              return other.isEmpty ? 'أخر' : other;
            })()
          : _department,
      gender: _gender,
      photoPath: _photoPath,
      notes: _notesController.text.trim(),
      status: 'بانتظار المراجعة',
    );

    if (_selectedEmployeeId != null) {
      await EmployeeService.instance.update(employee);
    } else {
      await EmployeeService.instance.add(employee);
    }

    await NotificationService.instance.addSimple(
      type: 'warning',
      title: 'موظف جديد بانتظار المراجعة',
      body: 'الموظف ${employee.fullName} بانتظار مراجعة المدير.',
      targetPage: 'employee_review',
      targetId: employee.id.toString(),
      roles: ['الإدارة'],
    );
    await NotificationService.instance.addSimple(
      type: 'info',
      title: 'تم إضافة موظف',
      body: 'تم إضافة ${employee.fullName}، بانتظار المراجعة المالية من الإدارة.',
      targetPage: 'employees',
    );

    setState(() {
      _clearForm();
      _showForm = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ الموظف ${employee.fullName} بنجاح. بانتظار مراجعة المدير.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _deleteEmployee(int id) async {
    final emp = EmployeeService.instance.byId(id);
    if (emp == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف ${emp.fullName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: AppPalette.roseRed))),
        ],
      ),
    );
    if (confirm != true) return;
    await EmployeeService.instance.remove(id);
    setState(() {});
  }

  List<EmployeeRecord> get _allEmployees => EmployeeService.instance.all;
  int get _maleEmployees => _allEmployees.where((e) => e.gender != 'أنثى').length;
  int get _femaleEmployees => _allEmployees.where((e) => e.gender == 'أنثى').length;
  int get _maleTeachers => _allEmployees.where((e) => e.jobType == 'معلم' && e.gender != 'أنثى').length;
  int get _femaleTeachers => _allEmployees.where((e) => e.jobType == 'معلم' && e.gender == 'أنثى').length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // ─── Toggle form button ───────────────────────────────
          Row(
            children: <Widget>[
              _actionButton(
                _showForm ? 'إغلاق النموذج' : '➕ إضافة موظف جديد',
                AppPalette.goldDark, Colors.white,
                () => setState(() => _showForm = !_showForm),
              ),
              const SizedBox(width: 10),
              _actionButton('تحديث', const Color(0xFFEDF6FF), const Color(0xFF24436F), () async {
                await EmployeeService.instance.init();
                setState(() {});
              }),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                  DropdownMenuItem(value: 'بانتظار المراجعة', child: Text('بانتظار المراجعة')),
                  DropdownMenuItem(value: 'نشط', child: Text('نشط')),
                  DropdownMenuItem(value: 'مرفوض', child: Text('مرفوض')),
                ],
                onChanged: (v) => setState(() => _filterStatus = v!),
              ),
              const Spacer(),
              Text('العدد: ${_filteredEmployees.length}', style: const TextStyle(color: AppPalette.muted)),
            ],
          ),
          const SizedBox(height: 12),
          _employeeStatsRow(),

          // ─── Employee Form ────────────────────────────────────
          if (_showForm) ...<Widget>[
            const SizedBox(height: 14),
            _buildForm(),
          ],

          const SizedBox(height: 14),

          // ─── Employee List ────────────────────────────────────
          ..._filteredEmployees.map(_buildEmployeeCard),
          if (_filteredEmployees.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('لا يوجد موظفون', style: TextStyle(color: AppPalette.muted))),
            ),
        ],
      ),
    );
  }

  Widget _employeeStatsRow() {
    return Row(
      children: <Widget>[
        _statCard('الموظفون الذكور', '$_maleEmployees', AppPalette.royalBlue),
        const SizedBox(width: 10),
        _statCard('الموظفات الإناث', '$_femaleEmployees', AppPalette.roseRed),
        const SizedBox(width: 10),
        _statCard('المعلمون الذكور', '$_maleTeachers', AppPalette.deepNavySoft),
        const SizedBox(width: 10),
        _statCard('المعلمات الإناث', '$_femaleTeachers', AppPalette.goldDark),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppPalette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppPalette.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.line),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('📝 استمارة موظف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
            const SizedBox(height: 6),
            const Text('جميع الحقول المطلوبة هي: الاسم الكامل، رقم السجل المدني، المواصلات. باقي الحقول اختيارية.', style: TextStyle(color: AppPalette.muted, fontSize: 12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _field('الاسم الكامل *', _fullNameController, span2: true),
                _field('رقم السجل المدني *', _nationalIdController),
                _field('الجنسية', _nationalityController),
                _field('تاريخ الميلاد', _birthDateController),
                _field('مكان الإقامة', _residenceController, span2: true),
                _field('رقم الموبايل', _mobileController),
                _field('البريد الإلكتروني', _emailController),
                _qualificationDropdown(),
                _specializationDropdown(),
                _field('تاريخ التعيين', _hireDateController),
                _departmentDropdown(),
                if (_department == 'أخر')
                  SizedBox(
                    width: 540,
                    child: TextFormField(
                      controller: _departmentOtherController,
                      onChanged: (v) => _departmentOther = v,
                      decoration: const InputDecoration(
                        labelText: 'حدد القسم (أخر)',
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
                _jobTypeDropdown(),
                _genderDropdown(),
                _field('ملاحظات', _notesController, span2: true, maxLines: 3),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _actionButton('📷 صورة شخصية', const Color(0xFFEDF6FF), AppPalette.royalBlue, _pickImage),
                const SizedBox(width: 10),
                if (_photoPath.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppPalette.leafGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('✅ تم رفع صورة', style: TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _actionButton('💾 حفظ', AppPalette.goldDark, Colors.white, _saveEmployee),
                _actionButton('إلغاء', Colors.white, const Color(0xFF667586), () {
                  setState(() {
                    _clearForm();
                    _showForm = false;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeRecord emp) {
    final statusColor = emp.status == 'نشط'
        ? AppPalette.leafGreen
        : emp.status == 'مرفوض'
            ? AppPalette.roseRed
            : AppPalette.goldDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _loadEmployee(emp)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.line),
          ),
          child: Row(
            children: <Widget>[
              // Photo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: emp.photoPath.isEmpty
                      ? const LinearGradient(colors: [Color(0xFF1D4D9C), Color(0xFF377FD8)])
                      : null,
                ),
                child: ClipOval(
                  child: emp.photoPath.isNotEmpty
                      ? Image.file(File(emp.photoPath), fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(emp.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${emp.jobType} • ${emp.department.isNotEmpty ? emp.department : 'بدون قسم'} • ${emp.mobile}',
                      style: const TextStyle(color: AppPalette.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 20),
                onPressed: () => _deleteEmployee(emp.id),
              ),
              const Icon(Icons.chevron_left, color: AppPalette.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {bool span2 = false, int maxLines = 1}) {
    return SizedBox(
      width: span2 ? 540 : 260,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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

  Widget _qualificationDropdown() {
    final value = _qualificationOptions.contains(_qualification) ? _qualification : _qualificationOptions.first;
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: _qualificationOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() {
          _qualification = v ?? _qualificationOptions.first;
          _qualificationController.text = _qualification;
        }),
        decoration: const InputDecoration(
          labelText: 'المؤهل العلمي',
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

  Widget _specializationDropdown() {
    final options = <String>[..._specializationOptions];
    if (_specialization.isNotEmpty && !options.contains(_specialization)) {
      options.insert(0, _specialization);
    }
    final value = options.contains(_specialization) ? _specialization : options.first;
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: options.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() {
          _specialization = v ?? options.first;
          _specializationController.text = _specialization;
        }),
        decoration: const InputDecoration(
          labelText: 'الاختصاص',
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

  Widget _departmentDropdown() {
    return SizedBox(
      width: 540,
      child: DropdownButtonFormField<String>(
        value: _departmentOptions.contains(_department) ? _department : _departmentOptions.first,
        isExpanded: true,
        items: _departmentOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() {
          _department = v ?? _departmentOptions.first;
          if (_department != 'أخر') {
            _departmentOther = '';
    _departmentOtherController.clear();
          }
        }),
        decoration: const InputDecoration(
          labelText: 'القسم *',
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

  Widget _jobTypeDropdown() {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: _jobType,
        items: kJobTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _jobType = v!),
        decoration: const InputDecoration(
          labelText: 'نوع الوظيفة *',
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

  Widget _genderDropdown() {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: _gender,
        items: const <String>['ذكر', 'أنثى'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _gender = v ?? 'ذكر'),
        decoration: const InputDecoration(
          labelText: 'الجنس *',
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
              border: Border.all(color: bg == Colors.white ? const Color(0xFFD6E4F1) : bg.withOpacity(0.2)),
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
}
