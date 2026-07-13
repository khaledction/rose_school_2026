part of 'school_shell_page.dart';

extension SchoolShellPageSections on _SchoolShellPageState {

  Widget _adminDashboardPageSection() {
    final user = _authenticatedUser;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _summaryTile('المستخدم الحالي', user?.username ?? '-', AppPalette.goldDark),
              const SizedBox(width: 12),
              _summaryTile('عدد المستخدمين', _adminUsers.length.toString(), AppPalette.royalBlue),
              const SizedBox(width: 12),
              _summaryTile('عدد الصلاحيات', (user?.permissions.length ?? 0).toString(), AppPalette.leafGreen),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('صلاحيات المستخدم الحالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                if (user == null || user.permissions.isEmpty)
                  const Text('لا توجد صلاحيات مرتبطة بالمستخدم الحالي.', style: TextStyle(color: AppPalette.muted))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.permissions.map((permission) => _pill(permission, const Color(0xFFEDF6FF), AppPalette.royalBlue)).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminIdentityPageSection() {
    // Labels/placeholders must match exactly.
    final identityFields = <MapEntry<String, TextEditingController>>[
      MapEntry('إيميل المدرسة المعتمد', _schoolEmailController),
      MapEntry('موبايل المدرسة واتساب', _schoolWhatsappController),
      MapEntry('موبايل المدرسة للتواصل', _schoolMobileController),
      MapEntry('هاتف المدرسة الأرضي', _schoolLandlineController),
      MapEntry('المدير العام', _secretaryNameController), // placeholder: المدير العام
      MapEntry('مشرف القسم', _supervisorNameController), // placeholder: مشرف القسم (بدل الموجه)
      MapEntry('مدير المدرسة', _principalNameController),
      MapEntry('أمين السر', _secretaryRoleNameController),
      MapEntry('المشرف العام', _generalSupervisorController),
      MapEntry('موقع المدرسة على الإنترنت', _schoolWebsiteController),
      MapEntry('صفحة المدرسة على فيسبوك', _schoolFacebookController),
    ];

    final installmentAmountFields = <MapEntry<String, TextEditingController>>[
      MapEntry('القسط السنوي', _installmentAnnualController),
      MapEntry('القسط الشهري', _installmentMonthlyController),
      MapEntry('عدد الأقساط', _installmentCountController),
      MapEntry('قيمة المواصلات شهرياً', _transportMonthlyController),
      MapEntry('قيمة المواصلات سنوياً', _transportAnnualController),
      MapEntry('قيمة منحة المواصلات', _transportGrantController),
    ];

    final adminUserFields = <MapEntry<String, TextEditingController>>[
      MapEntry('اسم المستخدم *', _adminUsernameController),
      MapEntry('الإيميل *', _adminEmailController),
      MapEntry('كلمة المرور *', _adminPasswordController),
      MapEntry('تأكيد كلمة المرور *', _adminConfirmPasswordController),
      MapEntry('الموبايل *', _adminMobileController),
    ];

    final studentOptions = _students
        .map((s) => MapEntry(s.id, '${s.fullName} — ${s.grade}/${s.section}'))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('بيانات المدرسة المعتمدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 6),
                const Text('الاعتماد الرسمي للمدرسة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppPalette.goldDark)),
                const SizedBox(height: 8),
                const Text('هذه الصفحة مخصصة للاعتماد الرسمي وبيانات التواصل المعتمدة للمدرسة (وليست مجرد بيانات اتصال عامة). يمكنك التعديل ثم الحفظ في SQLite. استخدم Tab أو Enter للانتقال للحقل التالي.', style: TextStyle(color: AppPalette.muted, height: 1.6)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    for (var i = 0; i < identityFields.length; i++)
                      _editableField(
                        identityFields[i].key,
                        identityFields[i].value,
                        span2: i >= 9,
                        focusNode: _identityFocusNodes[i],
                        nextFocusNode: i < identityFields.length - 1 ? _identityFocusNodes[i + 1] : null,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _actionButton('حفظ البيانات', AppPalette.goldDark, Colors.white, _saveSchoolIdentity),
                    _actionButton('تعديل', const Color(0xFFEDF6FF), const Color(0xFF24436F), _saveSchoolIdentity),
                    _actionButton('إضافة', const Color(0xFFE7F7EE), AppPalette.leafGreen, _saveSchoolIdentity),
                    _actionButton('إلغاء', Colors.white, const Color(0xFF667586), _loadSchoolIdentityDraft),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ─── Installment & Transport Fees Config ──────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('الأقساط والمواصلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 10),
                const Text('تحديد القيم المالية للأقساط والمواصلات. هذه القيم تُستخدم عند إضافة أقساط من باب المحاسبة.', style: TextStyle(color: AppPalette.muted)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _dropdownField(
                      'العملة',
                      _installmentCurrency,
                      const <String>['ليرة سورية', 'دولار', 'يورو'],
                      (value) => setState(() => _installmentCurrency = value),
                    ),
                    for (var i = 0; i < installmentAmountFields.length; i++)
                      _editableField(
                        installmentAmountFields[i].key,
                        installmentAmountFields[i].value,
                        focusNode: _installmentFocusNodes[i],
                        nextFocusNode: i < installmentAmountFields.length - 1 ? _installmentFocusNodes[i + 1] : null,
                      ),
                    _editableField('عدد أشهر الإعفاء', _exemptionMonthsController),
                    _dropdownField(
                      'نطاق الإعفاء',
                      _exemptionScope,
                      const <String>['الكل', 'الصف', 'الصف والشعبة', 'الطالب'],
                      (value) {
                        setState(() {
                          _exemptionScope = value;
                          if (value == 'الكل') {
                            _exemptionGrade = 'الكل';
                            _exemptionSection = 'الكل';
                            _exemptionStudentId = null;
                          } else if (value == 'الصف') {
                            _exemptionSection = 'الكل';
                            _exemptionStudentId = null;
                          } else if (value == 'الصف والشعبة') {
                            _exemptionStudentId = null;
                          }
                        });
                      },
                      span2: true,
                    ),
                    if (_exemptionScope == 'الصف' || _exemptionScope == 'الصف والشعبة')
                      _dropdownField(
                        'الصف',
                        _knownGrades.contains(_exemptionGrade) ? _exemptionGrade : 'الكل',
                        _knownGrades,
                        (value) => setState(() => _exemptionGrade = value),
                      ),
                    if (_exemptionScope == 'الصف والشعبة')
                      _dropdownField(
                        'الشعبة',
                        _knownSections.contains(_exemptionSection) ? _exemptionSection : 'الكل',
                        _knownSections,
                        (value) => setState(() => _exemptionSection = value),
                      ),
                    if (_exemptionScope == 'الطالب')
                      _dropdownField(
                        'الطالب',
                        studentOptions.any((e) => e.key == _exemptionStudentId)
                            ? studentOptions.firstWhere((e) => e.key == _exemptionStudentId).value
                            : (studentOptions.isEmpty ? 'لا يوجد طلاب' : studentOptions.first.value),
                        studentOptions.isEmpty
                            ? const <String>['لا يوجد طلاب']
                            : studentOptions.map((e) => e.value).toList(),
                        (value) {
                          final match = studentOptions.where((e) => e.value == value);
                          setState(() {
                            _exemptionStudentId = match.isEmpty ? null : match.first.key;
                          });
                        },
                        span2: true,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _actionButton('حفظ الإعدادات', AppPalette.goldDark, Colors.white, _saveInstallmentConfig),
                    _actionButton('إلغاء', Colors.white, const Color(0xFF667586), () {
                      _loadInstallmentConfig().then((_) {
                        if (mounted) setState(() {});
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('إنشاء مستخدم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 10),
                const Text('جميع الحقول مطلوبة ويجب التأكد من تطابق كلمة المرور وتأكيدها مع اختيار الصلاحيات المطلوبة.', style: TextStyle(color: AppPalette.muted)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    for (var i = 0; i < adminUserFields.length; i++)
                      _editableField(
                        adminUserFields[i].key,
                        adminUserFields[i].value,
                        span2: i == adminUserFields.length - 1,
                        focusNode: _adminUserFocusNodes[i],
                        nextFocusNode: i < adminUserFields.length - 1 ? _adminUserFocusNodes[i + 1] : null,
                      ),
                    _choiceField(
                      'الصلاحيات *',
                      <String, bool>{
                        'الإدارة': _adminPermissionsDraft.contains('الإدارة'),
                        'أمانة السر': _adminPermissionsDraft.contains('أمانة السر'),
                        'الامتحانات': _adminPermissionsDraft.contains('الامتحانات'),
                        'المحاسبة': _adminPermissionsDraft.contains('المحاسبة'),
                      },
                      (permission) {
                        setState(() {
                          if (_adminPermissionsDraft.contains(permission)) {
                            _adminPermissionsDraft.remove(permission);
                          } else {
                            _adminPermissionsDraft.add(permission);
                          }
                        });
                      },
                      span2: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _actionButton('حفظ', AppPalette.goldDark, Colors.white, _saveAdminUser),
                    _actionButton('تعديل', const Color(0xFFEDF6FF), const Color(0xFF24436F), _editAdminUser),
                    _actionButton('حذف', const Color(0xFFD46A63), Colors.white, _deleteAdminUser),
                    _actionButton('إلغاء', Colors.white, const Color(0xFF667586), _cancelAdminDraft),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('المستخدمون الحاليون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                if (_adminUsers.isEmpty)
                  const Text('لا يوجد مستخدمون بعد.', style: TextStyle(color: AppPalette.muted))
                else
                  ..._adminUsers.map((user) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _loadAdminDraft(user);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _selectedAdminUserId == user.id ? const Color(0xFFF7F3EA) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.line),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(user.username, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                      const SizedBox(height: 4),
                                      Text('${user.email} • ${user.mobile}\n${user.permissions.join('، ')}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_left),
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentsPageSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 980;
        return Column(
          children: <Widget>[
            // Header controls - wrap to avoid horizontal overflow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.line),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    '🗒️ سجل الطلاب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _studentSortChip('الاسم', Icons.sort_by_alpha_outlined),
                      _studentSortChip('الصف', Icons.school_outlined),
                      _studentSortChip('الشعبة', Icons.grid_view_rounded),
                      TextButton.icon(
                        onPressed: _showStudentSortOrderDialog,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEDF6FF),
                          foregroundColor: AppPalette.royalBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('ترتيب يدوي'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.goldDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _startNewStudent,
                        child: const Text('+ طالب جديد'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Stats panel with bounded height to protect table area
            Flexible(
              flex: narrow ? 5 : 4,
              child: _studentsGradeOverviewPanel(_filteredStudents),
            ),
            const SizedBox(height: 10),
            // Students table takes remaining space
            Expanded(
              flex: narrow ? 7 : 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppPalette.line),
                ),
                child: Column(
                  children: <Widget>[
                    _studentsTableHeader(),
                    Expanded(
                      child: _filteredStudents.isEmpty
                          ? const Center(
                              child: Text('لا يوجد طلاب ضمن العرض الحالي', style: TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700)),
                            )
                          : ListView.builder(
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                final overdue = _studentHasOverdueInstallment(student);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _loadStudent(student);
                                      _currentPage = 'form';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: overdue ? const Color(0xFFFFFBEA) : null,
                                      border: const Border(bottom: BorderSide(color: Color(0xFFEDF3F8))),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(flex: 4, child: _studentCell(student)),
                                        Expanded(flex: 2, child: Center(child: Text(student.serial, maxLines: 1, overflow: TextOverflow.ellipsis))),
                                        Expanded(flex: 2, child: Center(child: Text(_studentGradeDisplay(student), maxLines: 1, overflow: TextOverflow.ellipsis))),
                                        Expanded(flex: 2, child: Center(child: Text(student.section.isEmpty ? '-' : student.section, maxLines: 1, overflow: TextOverflow.ellipsis))),
                                        Expanded(flex: 2, child: Center(child: _statusChip(student.status))),
                                        Expanded(flex: 2, child: _studentActions(student)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _studentsGradeOverviewPanel(List<StudentRecord> students) {
    final grades = <String>['الكل', for (var i = 1; i <= 12; i++) '$i'];
    final sections = <String>['الكل', for (var i = 1; i <= 10; i++) '$i'];

    bool matchGrade(StudentRecord s, String grade) {
      if (grade == 'الكل') return true;
      final g = _studentGradeDisplay(s);
      return g == grade || g.startsWith('$grade ') || g.contains('الصف $grade');
    }

    bool matchSection(StudentRecord s, String section) {
      if (section == 'الكل') return true;
      final sec = _studentSectionDisplay(s);
      return sec == section || sec == 'شعبة $section';
    }

    final selected = students
        .where((s) => matchGrade(s, _studentsStatsGrade) && matchSection(s, _studentsStatsSection))
        .toList();
    final total = selected.length;
    final males = selected.where((s) => s.gender == 'ذكر').length;
    final females = selected.where((s) => s.gender == 'أنثى').length;
    final active = selected.where((s) => s.status == 'نشط').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'إحصاءات الطلاب',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
          ),
          const SizedBox(height: 10),
          // Filters
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: grades.contains(_studentsStatsGrade) ? _studentsStatsGrade : 'الكل',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'الصف',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFFBFDFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: grades
                      .map((g) => DropdownMenuItem<String>(value: g, child: Text(g == 'الكل' ? 'كل الصفوف' : 'الصف $g', overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _studentsStatsGrade = v ?? 'الكل';
                      _studentsStatsSection = 'الكل';
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sections.contains(_studentsStatsSection) ? _studentsStatsSection : 'الكل',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'الشعبة',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFFBFDFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: sections
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s == 'الكل' ? 'كل الشعب' : 'شعبة $s', overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _studentsStatsSection = v ?? 'الكل'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Compact summary chips (no overflow)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _softStatChip('الإجمالي', '$total', AppPalette.deepNavySoft, const Color(0xFFEDF2F7)),
              _softStatChip('الذكور', '$males', AppPalette.royalBlue, const Color(0xFFEDF6FF)),
              _softStatChip('الإناث', '$females', AppPalette.roseRed, const Color(0xFFFDECEE)),
              _softStatChip('نشطون', '$active', AppPalette.leafGreen, const Color(0xFFE7F7EE)),
            ],
          ),
          if (_studentsStatsGrade != 'الكل') ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'شعب الصف $_studentsStatsGrade',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final sec = '${index + 1}';
                  final list = students.where((s) {
                    return matchGrade(s, _studentsStatsGrade) && matchSection(s, sec);
                  }).toList();
                  final m = list.where((s) => s.gender == 'ذكر').length;
                  final f = list.where((s) => s.gender == 'أنثى').length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: list.isEmpty ? const Color(0xFFF7FAFC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalette.line),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 72,
                          child: Text('شعبة $sec', style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                        ),
                        Expanded(
                          child: Text(
                            'الإجمالي ${list.length}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text('ذكور $m', style: const TextStyle(color: AppPalette.royalBlue, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 12),
                        Text('إناث $f', style: const TextStyle(color: AppPalette.roseRed, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _softStatChip(String label, String value, Color fg, Color bg) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _studentsTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: <Color>[Color(0xFF132556), Color(0xFF0F1F45)]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(flex: 4, child: Center(child: Text('الطالب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          Expanded(flex: 2, child: Center(child: Text('التسلسل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          Expanded(flex: 2, child: Center(child: Text('الصف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          Expanded(flex: 2, child: Center(child: Text('الشعبة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          Expanded(flex: 2, child: Center(child: Text('الحالة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          Expanded(flex: 2, child: Center(child: Text('إجراءات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        ],
      ),
    );
  }

  Widget _studentSortChip(String label, IconData icon) {
    final sortIndex = _studentsSortOrder.indexOf(label);
    final active = sortIndex >= 0;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _toggleStudentSortCriterion(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? AppPalette.royalBlue : const Color(0xFFF4F8FC),
          border: Border.all(color: active ? AppPalette.royalBlue : const Color(0xFFE2EBF2)),
          boxShadow: active ? [BoxShadow(color: AppPalette.royalBlue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: active ? Colors.white : AppPalette.royalBlue.withOpacity(0.6)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: active ? Colors.white : AppPalette.deepNavySoft, fontWeight: FontWeight.w700, fontSize: 12)),
            if (active) ...<Widget>[
              const SizedBox(width: 6),
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${sortIndex + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _studentCell(StudentRecord student) {
    final hasPhoto = _fileStorage.fileExistsSync(student.studentPhotoPath);
    final isFemale = student.gender == 'أنثى';
    final overdue = _studentHasOverdueInstallment(student);
    return Row(
      children: <Widget>[
        _studentAvatar(student),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: overdue ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) : EdgeInsets.zero,
                      decoration: overdue
                          ? BoxDecoration(
                              color: const Color(0xFFFFF3BF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE6C200)),
                            )
                          : null,
                      child: Text(
                        student.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: overdue ? const Color(0xFF7A5A00) : AppPalette.deepNavySoft,
                        ),
                      ),
                    ),
                  ),
                  if (overdue) ...<Widget>[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3BF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE6C200)),
                      ),
                      child: const Text(
                        'مستحق',
                        style: TextStyle(color: Color(0xFF8A6D00), fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isFemale ? const Color(0xFFFDECEE) : const Color(0xFFEDF6FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: isFemale ? AppPalette.roseRed.withOpacity(0.35) : AppPalette.royalBlue.withOpacity(0.35)),
                    ),
                    child: Text(
                      isFemale ? 'أنثى' : 'ذكر',
                      style: TextStyle(
                        color: isFemale ? AppPalette.roseRed : AppPalette.royalBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hasPhoto ? '${student.mobile}\nصورة الطالب' : '${student.mobile}\nصورة الطالب غير مضافة بعد',
                style: const TextStyle(color: Color(0xFF8A95A3), fontSize: 12, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _studentActions(StudentRecord student) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        _hoverCircleAction(
          icon: Icons.info_outline,
          color: AppPalette.deepNavySoft,
          tooltip: 'معرفة ما تريد عن الطالب',
          onTap: () {
            setState(() => _loadStudent(student));
            _showStudentKnowledgeDialog(student);
          },
        ),
        _hoverCircleAction(
          icon: Icons.edit_outlined,
          color: AppPalette.goldDark,
          tooltip: 'فتح استمارة الطالب للتعديل',
          onTap: () {
            setState(() {
              _loadStudent(student);
              _currentPage = 'form';
            });
          },
        ),
        _hoverCircleAction(
          icon: Icons.description_outlined,
          color: AppPalette.royalBlue,
          tooltip: 'فتح الوثائق والمرفقات',
          onTap: () {
            setState(() {
              _loadStudent(student);
              _currentPage = 'documents';
            });
          },
        ),
        _hoverCircleWidgetAction(
          color: AppPalette.leafGreen,
          tooltip: 'فتح البطاقة والطباعة',
          child: ClipOval(
            child: Image.asset('image/logo.jpg', width: 18, height: 18, fit: BoxFit.cover),
          ),
          onTap: () {
            setState(() {
              _loadStudent(student);
              _currentPage = 'student_card';
            });
          },
        ),
      ],
    );
  }

  Widget _studentFormPageSection() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _mainFormPanel(),
          const SizedBox(height: 18),
          _accordion('language', '2', 'اللغة', _wrapFields(<Widget>[
            _subSectionBanner('إعدادات اللغات', subtitle: 'اختر اللغة الأولى والثانية واللغة التي يجيدها الطالب، وأدخل النص الحر عند اختيار OTHER.'),
            _choiceField(
              'اللغة الأولى',
              <String, bool>{'E': _firstLanguage == 'E', 'F': _firstLanguage == 'F', 'R': _firstLanguage == 'R', 'أخرى': _firstLanguage == 'أخرى'},
              (key) => setState(() => _firstLanguage = key),
              span2: true,
            ),
            _choiceField(
              'اللغة الثانية',
              <String, bool>{'E': _secondLanguage == 'E', 'F': _secondLanguage == 'F', 'R': _secondLanguage == 'R', 'أخرى': _secondLanguage == 'أخرى'},
              (key) => setState(() => _secondLanguage = key),
              span2: true,
            ),
            _choiceField(
              'لغة يجيدها',
              <String, bool>{'E': _spokenLanguage == 'E', 'F': _spokenLanguage == 'F', 'R': _spokenLanguage == 'R', 'أخرى': _spokenLanguage == 'أخرى'},
              (key) => setState(() => _spokenLanguage = key),
              span2: true,
            ),
            if (_firstLanguage == 'أخرى')
              _editableField('مربع نص اللغة الأولى (Other)', _firstLanguageOtherController, span2: true),
            if (_secondLanguage == 'أخرى')
              _editableField('مربع نص اللغة الثانية (Other)', _secondLanguageOtherController, span2: true),
            if (_spokenLanguage == 'أخرى')
              _editableField('مربع نص لغة يجيدها (Other)', _spokenLanguageOtherController, span2: true),
          ])),
          const SizedBox(height: 12),
          _accordion('enrollment', '3', 'الانتساب للمدرسة', _wrapFields(<Widget>[
            _choiceField(
              'نوع الانتساب للمدرسة',
              <String, bool>{
                'طالب جديد': _enrollmentType == 'طالب جديد',
                'طالب منقول': _enrollmentType == 'طالب منقول',
              },
              (key) => setState(() {
                _enrollmentType = key;
                if (key == 'طالب جديد') {
                  _failedGradesSelected.clear();
                  _failedGradesController.clear();
                }
              }),
              span2: true,
            ),
            SizedBox(
              width: 760,
              child: Row(
                children: <Widget>[
                  Expanded(child: _dateFieldCard('تاريخ الانتساب للمدرسة', _enrollmentDateController)),
                  const SizedBox(width: 12),
                  Expanded(child: _editableField('السنة الدراسية', _schoolYearController)),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                _choiceField(
                  'الصف',
                  {for (var i = 1; i <= 12; i++) '$i': _enrollmentGrade == '$i'},
                  (key) => setState(() {
                    _enrollmentGrade = key;
                    final n = int.tryParse(key) ?? 0;
                    if (n < 10 || n > 12) {
                      // keep track value but it won't show
                    } else if (_secondaryTrack != 'علمي' && _secondaryTrack != 'أدبي') {
                      _secondaryTrack = 'علمي';
                    }
                    // keep grade controller aligned for display
                    _gradeController.text = _composeStudentGradeLabel();
                  }),
                ),
                const SizedBox(width: 20),
                _choiceField(
                  'الشعبة',
                  <String, bool>{'?': _sectionController.text.isEmpty || _sectionController.text == '?', for (var i = 1; i <= 10; i++) '$i': _sectionController.text == '$i'},
                  (key) => setState(() => _sectionController.text = key),
                ),
              ],
            ),
            // Grades 10-12: scientific / literary track radios
            if ((int.tryParse(_enrollmentGrade.trim()) ?? 0) >= 10 && (int.tryParse(_enrollmentGrade.trim()) ?? 0) <= 12)
              _choiceField(
                'الفرع (للصفوف 10-12)',
                <String, bool>{
                  'علمي': _secondaryTrack == 'علمي',
                  'أدبي': _secondaryTrack == 'أدبي',
                },
                (key) => setState(() {
                  _secondaryTrack = key;
                  _gradeController.text = _composeStudentGradeLabel();
                }),
                span2: true,
              ),
            if (_enrollmentType == 'طالب منقول')
              _editableField('اسم المدرسة المنقول منها', _previousSchoolController, span2: true)
            else
              _passiveNoteField('اسم المدرسة المنقول منها', 'يظهر هذا الحقل فقط عند اختيار طالب منقول.', span2: true),
            if (_enrollmentType == 'طالب منقول')
              _choiceField(
                'الصفوف التي رسب فيها قبل الانتساب للمدرسة',
                {for (var i = 1; i <= 12; i++) '$i': _failedGradesSelected.contains('$i')},
                (key) {
                  setState(() {
                    if (_failedGradesSelected.contains(key)) {
                      _failedGradesSelected.remove(key);
                    } else {
                      _failedGradesSelected.add(key);
                    }
                    _failedGradesController.text = _failedGradesSelected.join(',');
                  });
                },
                span2: true,
              ),
          ])),
          const SizedBox(height: 12),
          _accordion('contact', '4', 'الاتصال والسكن', _stackedFields(<Widget>[
            _subSectionBanner('بيانات الاتصال الأساسية'),
            _fullWidthField('مكان السكن', _residenceController),
            _fullWidthField('الهاتف الثابت', _landlineController),
            _fullWidthField('موبايل الطالب', _mobileController),
            _fullWidthField('ايميل', _emailController),
          ])),
          const SizedBox(height: 12),
          _accordion('transport_section', '5', 'النقل والمواصلات', _wrapFields(<Widget>[
            _subSectionBanner('بيانات النقل والمواصلات', subtitle: 'يظهر مكان انتظار المدرسة بشكل واضح عند اشتراك الطالب أو إعفائه من رسوم النقل.'),
            _dropdownField(
              'مشترك بوسائل نقل المدرسة',
              _transportSubscription,
              const <String>['نعم', 'لا', 'معفى من رسوم النقل'],
              (v) => setState(() => _transportSubscription = v),
              span2: true,
            ),
            if (_transportSubscription == 'نعم' || _transportSubscription == 'معفى من رسوم النقل')
              _editableField('مكان انتظار المدرسة', _transportGatheringController, span2: true)
            else
              _passiveNoteField(
                'مكان انتظار المدرسة',
                'غير مطلوب لأن الطالب غير مشترك بوسائل نقل المدرسة.',
                span2: true,
              ),
            if (_transportSubscription == 'نعم')
              _passiveNoteField(
                'قسط النقل المدفوع',
                _transportPaymentSummary(),
                span2: true,
              ),
          ])),
          const SizedBox(height: 12),
          _accordion('social', '6', 'الوضع الاجتماعي', _wrapFields(<Widget>[
            _choiceField(
              'الوضع الاجتماعي',
              <String, bool>{
                'حياة طبيعية': _normalLife,
                'يتيم الأب': _orphanFather,
                'يتيم الأم': _orphanMother,
                'يتيم الوالدين': _orphanParents,
                'وحيد': _onlyChild,
                'يعيش في مكان مفصل عن العائلة': _livesSeparate,
              },
              (key) {
                setState(() {
                  if (key == 'حياة طبيعية') _normalLife = !_normalLife;
                  if (key == 'يتيم الأب') _orphanFather = !_orphanFather;
                  if (key == 'يتيم الأم') _orphanMother = !_orphanMother;
                  if (key == 'يتيم الوالدين') _orphanParents = !_orphanParents;
                  if (key == 'وحيد') _onlyChild = !_onlyChild;
                  if (key == 'يعيش في مكان مفصل عن العائلة') _livesSeparate = !_livesSeparate;
                });
              },
              span2: true,
            ),
          ])),
          const SizedBox(height: 12),
          _accordion('health', '7', 'الوضع الصحي', _stackedFields(<Widget>[
            _subSectionBanner('الحالة الصحية العامة'),
            _fullWidthDropdown('الحالة الصحية', _healthStatus, const <String>['سليم', 'مرض عضوي', 'حالة نفسية', 'إعاقة'], (v) => setState(() {
              _healthStatus = v;
              if (v != 'إعاقة') {
                _disabilityVisual = false;
                _disabilityHearing = false;
                _disabilityMotor = false;
                _disabilityLearning = false;
              }
            })),
            if (_healthStatus == 'إعاقة')
              _subSectionBanner('تفاصيل الإعاقة', subtitle: 'يمكن تحديد أكثر من نوع واحد عند الحاجة.'),
            if (_healthStatus == 'إعاقة')
              _choiceField(
                'الإعاقة (اختيار من متعدد)',
                <String, bool>{
                  'بصرية': _disabilityVisual,
                  'سمعية': _disabilityHearing,
                  'حركية': _disabilityMotor,
                  'تعلم': _disabilityLearning,
                },
                (key) {
                  setState(() {
                    if (key == 'بصرية') _disabilityVisual = !_disabilityVisual;
                    if (key == 'سمعية') _disabilityHearing = !_disabilityHearing;
                    if (key == 'حركية') _disabilityMotor = !_disabilityMotor;
                    if (key == 'تعلم') _disabilityLearning = !_disabilityLearning;
                  });
                },
                span2: true,
              ),
            _fullWidthField('ملاحظات صحية', _healthNotesController, maxLines: 4),
          ])),
          const SizedBox(height: 12),
          _accordion('hobbies', '8', 'الهوايات والمبادرات', _wrapFields(<Widget>[
            _choiceField('الهوايات والمبادرات', <String, bool>{'موسيقا': _hobbyMusic, 'رسم': _hobbyDrawing, 'كمبيوتر': _hobbyComputer, 'رياضة': _hobbySports}, (key) {
              setState(() {
                if (key == 'موسيقا') _hobbyMusic = !_hobbyMusic;
                if (key == 'رسم') _hobbyDrawing = !_hobbyDrawing;
                if (key == 'كمبيوتر') _hobbyComputer = !_hobbyComputer;
                if (key == 'رياضة') _hobbySports = !_hobbySports;
              });
            }),
            _editableField('غير ذلك', _otherHobbiesController),
            _choiceField(
              'المبادرات',
              <String, bool>{
                'مدرسية': _initiativeSchool,
                'مالية': _initiativeFinancial,
                'عينية': _initiativeInKind,
                'اختراعات ومشاريع': _initiativeProjects,
              },
              (key) {
                setState(() {
                  if (key == 'مدرسية') _initiativeSchool = !_initiativeSchool;
                  if (key == 'مالية') _initiativeFinancial = !_initiativeFinancial;
                  if (key == 'عينية') _initiativeInKind = !_initiativeInKind;
                  if (key == 'اختراعات ومشاريع') _initiativeProjects = !_initiativeProjects;
                });
              },
              span2: true,
            ),
          ])),
          const SizedBox(height: 12),
          _accordion('fees', '9', 'الأقساط والمدفوعات', _feesSection()),
          const SizedBox(height: 12),
          _accordion('guardian', '10', 'بيانات ولي الأمر', _wrapFields(<Widget>[
            _editableField('اسم ولي الأمر', _guardianNameController),
            _editableField('صلة القرابة', _guardianRelationController),
            _editableField('هاتف ولي الأمر', _guardianPhoneController),
            _editableField('موبايل ولي الأمر', _guardianMobileController),
            _editableField('رقم الوتس اب', _guardianWhatsappController),
            _editableField('ايميل ولي الأمر', _guardianEmailController),
            _editableField('عمل ولي الأمر', _guardianWorkController),
            _editableField('اسم جهة اتصال طارئة', _emergencyContactNameController),
            _editableField('هاتف الطوارئ', _emergencyContactPhoneController),
            _editableField('عنوان ولي الأمر', _guardianAddressController, span2: true, maxLines: 3),
          ])),
          const SizedBox(height: 12),
          _accordion('media', '11', 'الصورة و QR والوثائق', _mediaBlock()),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'إجراءات الاستمارة',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('حفظ', AppPalette.goldDark, Colors.white, _saveStudent),
                  _actionButton('تعديل', const Color(0xFFEDF6FF), const Color(0xFF24436F), _saveStudent),
                  _actionButton('حذف', const Color(0xFFD46A63), Colors.white, _deleteStudent),
                  _actionButton('تفريغ النموذج', Colors.white, const Color(0xFF667586), _startNewStudent),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mainFormPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[Color(0xFF191919), Color(0xFF101010)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(color: AppPalette.goldDark, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('المعلومات الشخصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    SizedBox(height: 2),
                    Text('التسلسل، الهوية، الطالب — تنقّل بـ Tab أو Enter', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Photo + serial under it
                SizedBox(
                  width: 210,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD9E7F3)),
                          gradient: const LinearGradient(colors: <Color>[Color(0xFFE8F4FF), Colors.white]),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: (_selectedStudent != null && _fileStorage.fileExistsSync(_selectedStudent!.studentPhotoPath))
                              ? Image.file(File(_selectedStudent!.studentPhotoPath), fit: BoxFit.cover)
                              : Center(child: Image.asset('image/logo.jpg', width: 64, height: 64, fit: BoxFit.contain)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('رقم التسلسل', style: TextStyle(fontSize: 12, color: AppPalette.muted, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 6),
                      _serialValueBox(),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: _actionButton('📷 رفع صورة', AppPalette.goldDark, Colors.white, _pickStudentImage),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: _actionButton('حذف الصورة', Colors.white, const Color(0xFF667586), _removeStudentImage),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'الصورة الشخصية للطالب',
                        style: TextStyle(color: AppPalette.muted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Fields
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: _compactLabeledField('الاسم *', _tabInput(_fullNameController, hint: 'اسم الطالب', node: _formFocusNodes[0], nextNode: _formFocusNodes[1]))),
                          const SizedBox(width: 10),
                          Expanded(child: _compactLabeledField('الأب', _tabInput(_fatherNameController, hint: 'اسم الأب', node: _formFocusNodes[1], nextNode: _formFocusNodes[2]))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(child: _compactLabeledField('الكنية', _tabInput(_nicknameController, hint: 'الكنية', node: _formFocusNodes[2], nextNode: _formFocusNodes[3]))),
                          const SizedBox(width: 10),
                          Expanded(child: _compactLabeledField('اسم الأم', _tabInput(_motherNameController, hint: 'اسم الأم', node: _formFocusNodes[3], nextNode: _formFocusNodes[4]))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(child: _compactLabeledField('الجد', _tabInput(_grandfatherNameController, hint: 'الجد', node: _formFocusNodes[4], nextNode: _formFocusNodes[5]))),
                          const SizedBox(width: 10),
                          Expanded(child: _compactLabeledField('مكان الولادة', _tabInput(_birthPlaceController, hint: 'مكان الولادة', node: _formFocusNodes[5], nextNode: _formFocusNodes[6]))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(child: _compactLabeledField('تاريخ الولادة', _datePickerField(_birthDateController, hint: 'تاريخ الولادة'))),
                          const SizedBox(width: 10),
                          Expanded(child: _compactLabeledField('مكان القيد', _tabInput(_registryPlaceController, hint: 'مكان القيد', node: _formFocusNodes[7], nextNode: _formFocusNodes[8]))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(child: _compactLabeledField('رقم القيد', _tabInput(_registryNumberController, hint: 'رقم القيد', node: _formFocusNodes[8], nextNode: null))),
                          const SizedBox(width: 10),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // gender / religion / blood side by side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 3, child: _compactLabeledField('الجنس', _genderChoices())),
                          const SizedBox(width: 8),
                          Expanded(flex: 2, child: _compactLabeledField('الديانة', _religionDropdown())),
                          const SizedBox(width: 8),
                          Expanded(flex: 5, child: _compactLabeledField('زمرة الدم', _bloodTypeChoices())),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _compactLabeledField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 12, color: AppPalette.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _tabInput(TextEditingController controller, {required String hint, required FocusNode node, FocusNode? nextNode, int maxLines = 1}) {
    return TextField(
      controller: controller,
      focusNode: node,
      maxLines: maxLines,
      textInputAction: nextNode != null ? TextInputAction.next : TextInputAction.done,
      onEditingComplete: nextNode != null ? () => nextNode.requestFocus() : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFBFDFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
      ),
    );
  }

  Widget _primaryFormRow(String label, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EDF4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, color: AppPalette.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _serialValueBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141820),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Text(_serialController.text, style: const TextStyle(color: AppPalette.gold, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Text('—', style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _simpleInput(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    VoidCallback? onTap,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      onTap: onTap,
      textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      onEditingComplete: nextFocusNode != null ? () => nextFocusNode.requestFocus() : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFBFDFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final parsed = DateTime.tryParse(controller.text);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? DateTime(now.year - 10),
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      controller.text = '${picked.year}-$mm-$dd';
      setState(() {});
    }
  }

  Widget _datePickerField(TextEditingController controller, {required String hint}) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickDate(controller),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          tooltip: 'اختيار التاريخ',
          onPressed: () => _pickDate(controller),
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        filled: true,
        fillColor: const Color(0xFFFBFDFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
        ),
      ),
    );
  }

  Widget _bloodTypeChoices() {
    const bloods = <String>['?','O+','O-','A+','A-','B+','B-','AB+','AB-'];
    return SizedBox(
      height: 48,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E7F3)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: bloods.map((type) {
              final active = _bloodType == type;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: InkWell(
                  onTap: () => setState(() => _bloodType = type),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                      border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                    ),
                    child: Text(type, style: TextStyle(color: active ? Colors.white : const Color(0xFF29446F), fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _genderChoices() {
    return SizedBox(
      height: 48,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E7F3)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _gender = 'ذكر'),
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _gender == 'ذكر' ? AppPalette.royalBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('ذكر', style: TextStyle(
                    color: _gender == 'ذكر' ? Colors.white : AppPalette.deepNavySoft,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  )),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _gender = 'أنثى'),
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _gender == 'أنثى' ? AppPalette.roseRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('أنثى', style: TextStyle(
                    color: _gender == 'أنثى' ? Colors.white : AppPalette.deepNavySoft,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _religionDropdown() {
    return SizedBox(
      height: 48,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E7F3)),
        ),
        alignment: Alignment.center,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _religionController.text.isEmpty ? 'إسلامية' : _religionController.text,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w700, fontSize: 13),
            items: const <String>['إسلامية', 'مسيحية', 'أخرى']
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _religionController.text = v);
            },
          ),
        ),
      ),
    );
  }

  Widget _languageChoices() {
    return const SizedBox.shrink();
  }

  Widget _accordion(String id, String number, String title, Widget body) {
    final active = _openSections.contains(id);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFE8EDF4), width: active ? 1.6 : 1),
        boxShadow: active
            ? const <BoxShadow>[BoxShadow(color: Color.fromRGBO(167, 122, 46, 0.18), blurRadius: 12, offset: Offset(0, 4))]
            : const <BoxShadow>[BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.03), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(18),
            hoverColor: const Color.fromRGBO(201, 160, 78, 0.12),
            onTap: () {
              setState(() {
                if (active) {
                  _openSections.remove(id);
                } else {
                  _openSections.add(id);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: active ? AppPalette.goldDark : null,
                gradient: active ? const LinearGradient(colors: <Color>[AppPalette.goldDark, AppPalette.gold]) : null,
              ),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : AppPalette.royalBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: TextStyle(
                          color: active ? AppPalette.goldDark : Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            color: active ? Colors.white : const Color(0xFF27385F),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          active ? 'قسم مفتوح' : 'اضغط للفتح',
                          style: TextStyle(
                            color: active ? Colors.white.withOpacity(0.9) : AppPalette.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: active ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    child: Icon(Icons.expand_more, color: active ? Colors.white : const Color(0xFF27385F)),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: body,
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapFields(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(spacing: 12, runSpacing: 12, children: children),
    );
  }

  Widget _stackedFields(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _fullWidthField(String label, TextEditingController controller, {int maxLines = 1}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _simpleInput(controller, hint: label, maxLines: maxLines),
          ],
        ),
      ),
    );
  }

  Widget _fullWidthDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFBFDFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
              ),
              items: options.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _subSectionBanner(String title, {String? subtitle}) {
    return SizedBox(
      width: 760,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DDBF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: AppPalette.goldDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _editableField(
    String label,
    TextEditingController controller, {
    bool span2 = false,
    int maxLines = 1,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    return SizedBox(
      width: span2 ? 760 : 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _simpleInput(
              controller,
              hint: label,
              maxLines: maxLines,
              focusNode: focusNode,
              nextFocusNode: nextFocusNode,
              onTap: (label.contains('ملاحظات') || label.contains('ملاحظة'))
                  ? () => _clearNoteFieldOnFirstTap(controller)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _passiveNoteField(String label, String note, {bool span2 = false}) {
    return SizedBox(
      width: span2 ? 760 : 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DDBF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(color: Color(0xFF7B5830), height: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _dateFieldCard(String label, TextEditingController controller, {bool span2 = false}) {
    return SizedBox(
      width: span2 ? 760 : 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _datePickerField(controller, hint: label),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> options, ValueChanged<String> onChanged, {bool span2 = false}) {
    return SizedBox(
      width: span2 ? 760 : 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFBFDFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                ),
              ),
              items: options.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceField(String label, Map<String, bool> options, ValueChanged<String> onTap, {bool span2 = false}) {
    return SizedBox(
      width: span2 ? 760 : 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.entries.map((entry) {
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onTap(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: entry.value ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                      border: Border.all(color: entry.value ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: entry.value ? Colors.white : const Color(0xFF29446F),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _transportPaymentSummary() {
    final student = _selectedStudent;
    if (student == null) {
      return 'لا يوجد طالب محدد حاليًا.';
    }
    final notices = _transportAccountingEntries(student.id);
    if (notices.isEmpty) {
      return 'لم يتم تسجيل إشعار دفع رسوم النقل من باب المحاسبة حتى الآن.';
    }
    final latest = notices.first;
    return 'تم تسجيل دفع رسوم النقل من باب المحاسبة: ${latest['title']}\n${latest['subtitle']}';
  }

  List<Map<String, String>> _transportAccountingEntries(int studentId) {
    final items = <Map<String, String>>[];
    for (final entry in _studentInvoices(studentId)) {
      items.add(<String, String>{
        'title': 'قسط - ${entry.title}',
        'subtitle': 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date}',
      });
    }
    for (final entry in _studentReceipts(studentId)) {
      items.add(<String, String>{
        'title': 'دفعة مقبوضة - ${entry.title}',
        'subtitle': 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date}',
      });
    }
    return items;
  }

  List<Widget> _buildLinkedAccountingHistory(int studentId) {
    final entries = <Map<String, String>>[];
    for (final entry in _studentInvoices(studentId)) {
      entries.add(<String, String>{
        'title': 'قسط - ${entry.title}',
        'subtitle': 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date}',
      });
    }
    for (final entry in _studentAccountingDonations(studentId)) {
      entries.add(<String, String>{
        'title': 'تبرع - ${_donationDisplayTitle(entry)}',
        'subtitle': _donationDisplaySubtitle(entry),
      });
    }
    for (final entry in _studentAccountingAids(studentId)) {
      entries.add(<String, String>{
        'title': 'مساعدة - ${_aidDisplayTitle(entry)}',
        'subtitle': _aidDisplaySubtitle(entry),
      });
    }
    for (final entry in _studentReceipts(studentId)) {
      entries.add(<String, String>{
        'title': 'مقبوض - ${entry.title}',
        'subtitle': 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date}',
      });
    }
    if (entries.isEmpty) {
      return <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.line),
          ),
          child: const Text('لا توجد سجلات محاسبية مرتبطة بهذا الطالب حتى الآن.', style: TextStyle(color: AppPalette.muted)),
        ),
      ];
    }
    return entries.map((entry) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
          const SizedBox(height: 4),
          Text(entry['subtitle']!, style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
        ],
      ),
    )).toList();
  }

  Widget _feesSection() {
    final student = _selectedStudent;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          _subSectionBanner(
            'الأقساط والمدفوعات',
            subtitle: 'تم إخفاء سجل رسوم 1 وما يشابهه هنا، وأصبح العرض يعتمد فقط على السجلات التي تتم إضافتها من باب المحاسبة.',
          ),
          const SizedBox(height: 12),
          if (student != null && student.transportSubscription == 'نعم') ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F7EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCDE8D8)),
              ),
              child: Text(
                _transportPaymentSummary(),
                style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800, height: 1.8),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (student != null) ...<Widget>[
            _subSectionBanner('سجل المحاسبة المرتبط', subtitle: 'يظهر هنا ما تمت إضافته من باب الأقساط والدفعات: قسط أو مقبوض.'),
            const SizedBox(height: 12),
            ..._buildLinkedAccountingHistory(student.id),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.line),
              ),
              child: const Text('لا يوجد طالب محدد حاليًا.', style: TextStyle(color: AppPalette.muted)),
            ),
        ],
      ),
    );
  }

  Widget _mediaBlock() {
    final student = _selectedStudent;
    final docs = student == null ? <StudentAttachment>[] : _studentAttachments(student.id);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: <Widget>[
          SizedBox(
            width: 370,
            child: _mediaCard(
              'صورة الطالب',
              Column(
                children: <Widget>[
                  _buildStudentPhotoPreview(student),
                  const SizedBox(height: 10),
                  Text(
                    student == null || student.studentPhotoPath.isEmpty
                        ? 'لم يتم حفظ صورة محلية بعد.'
                        : 'الملف المحفوظ: ${_fileStorage.fileNameFromPath(student.studentPhotoPath)}',
                    style: const TextStyle(color: AppPalette.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _actionButton('رفع صورة الطالب', AppPalette.goldDark, Colors.white, _pickStudentImage),
                      _actionButton('حذف الصورة', Colors.white, const Color(0xFF667586), _removeStudentImage),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 370,
            child: _mediaCard(
              'QR المتولد تلقائيًا',
              Column(
                children: <Widget>[
                  _buildQrPreview(student),
                  const SizedBox(height: 10),
                  Text(
                    student == null || student.qrFilePath.isEmpty
                        ? 'سيُحفظ QR كملف فعلي داخل مجلد التطبيق.'
                        : 'الملف المحفوظ: ${_fileStorage.fileNameFromPath(student.qrFilePath)}',
                    style: const TextStyle(color: AppPalette.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _actionButton('توليد QR', AppPalette.goldDark, Colors.white, _generateStudentQrFile),
                      _actionButton('رفع ملف QR', const Color(0xFFEDF6FF), const Color(0xFF24436F), _pickStudentQrFile),
                      _actionButton('حذف QR', Colors.white, const Color(0xFF667586), _removeStudentQr),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 370,
            child: _mediaCard(
              'الوثائق والمرفقات',
              Column(
                children: <Widget>[
                  if (docs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8DDBF)),
                      ),
                      child: const Text(
                        'لا توجد مرفقات محفوظة لهذا الطالب حتى الآن.',
                        style: TextStyle(color: AppPalette.muted),
                      ),
                    )
                  else
                    ...docs.take(3).map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _miniDoc(doc),
                        )),
                  _actionButton('إضافة مرفق', const Color(0xFFEDF6FF), const Color(0xFF24436F), _showAddAttachmentDialog),
                  if (docs.length > 3) ...<Widget>[
                    const SizedBox(height: 8),
                    Text('يوجد ${docs.length} مرفقات مرتبطة بهذا السجل.', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Color(0xFF22355D), fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildStudentPhotoPreview(StudentRecord? student) {
    final hasPhoto = student != null && _fileStorage.fileExistsSync(student.studentPhotoPath);
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCFE0EE)),
        gradient: const LinearGradient(colors: <Color>[Color(0xFFE8F4FF), Colors.white]),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: hasPhoto
            ? Image.file(File(student!.studentPhotoPath), fit: BoxFit.cover, width: double.infinity)
            : Center(
                child: Image.asset('image/logo.jpg', width: 70, height: 70, fit: BoxFit.contain),
              ),
      ),
    );
  }

  Widget _buildQrPreview(StudentRecord? student) {
    final hasQr = student != null && _fileStorage.fileExistsSync(student.qrFilePath);
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCFE0EE)),
        color: Colors.white,
      ),
      child: hasQr
          ? Center(
              child: (student!.qrFilePath.toLowerCase().endsWith('.svg'))
                  ? SvgPicture.file(File(student.qrFilePath), fit: BoxFit.contain)
                  : Image.file(File(student.qrFilePath), fit: BoxFit.contain),
            )
          : const Center(
              child: Text(
                'لا يوجد QR محفوظ بعد',
                style: TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Widget _miniDoc(StudentAttachment attachment) {
    final exists = _fileStorage.fileExistsSync(attachment.storedPath);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(attachment.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
          const SizedBox(height: 4),
          Text(
            '${attachment.category} • ${attachment.originalFileName.isEmpty ? _fileStorage.fileNameFromPath(attachment.storedPath) : attachment.originalFileName}',
            style: const TextStyle(color: AppPalette.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            exists ? 'محفوظ فعليًا داخل التطبيق' : 'الملف غير موجود حاليًا',
            style: TextStyle(
              color: exists ? AppPalette.leafGreen : AppPalette.roseRed,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportsPageSection() {
    final total = _students.length;
    final transport = _countBy(_students, (s) => s.transportSubscription);
    final gender = _countBy(_students, (s) => s.gender);
    final status = _countBy(_students, (s) => s.status);
    final grades = _countBy(_students, (s) => s.grade);
    final disability = _disabilityCounts();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '📊 مركز التقارير',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('تصدير Excel / CSV', AppPalette.goldDark, Colors.white, () => _showSnack('Demo Flutter: تم تجهيز ملف CSV متوافق مع Excel.')),
                  _actionButton('تقرير النقل CSV', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => _showSnack('Demo Flutter: تم تجهيز تقرير النقل بصيغة CSV.')),
                  _actionButton('تقرير Printable / PDF', Colors.white, const Color(0xFF667586), () => _showSnack('Demo Flutter: تم تجهيز تقرير قابل للطباعة والحفظ كـ PDF.')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _summaryTile('إجمالي عدد الطلاب', total.toString(), AppPalette.goldDark),
              const SizedBox(width: 12),
              _summaryTile('إجمالي عدد المعلمين', EmployeeService.instance.all.where((e) => e.jobType == 'معلم').length.toString(), AppPalette.royalBlue),
              const SizedBox(width: 12),
              _summaryTile('إجمالي عدد الموظفين', EmployeeService.instance.all.length.toString(), AppPalette.leafGreen),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _chartCard('حسب حالة القيد', status, total),
              _chartCard('حسب الصف', grades, total),
              _chartCard('حسب الجنس', gender, total),
              _chartCard('حسب النقل', transport, total),
              _chartCard('حسب الإعاقة', disability, total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentCardPageSection() {
    final student = _selectedStudent ?? _students.first;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🪪 بطاقة الطالب',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton(
                    _isStudentCardExporting ? 'جارٍ تجهيز المعاينة...' : 'معاينة البطاقة',
                    AppPalette.goldDark,
                    Colors.white,
                    _isStudentCardExporting ? () {} : _previewStudentCard,
                  ),
                  _actionButton(
                    _isStudentCardExporting ? 'جارٍ تجهيز ملف الطباعة...' : 'تجهيز ملف للطباعة',
                    const Color(0xFFEDF6FF),
                    const Color(0xFF24436F),
                    _isStudentCardExporting ? () {} : _prepareStudentCardForPrint,
                  ),
                  _actionButton(
                    _isStudentCardExporting ? 'جارٍ تصدير PDF...' : 'تصدير PDF',
                    Colors.white,
                    AppPalette.deepNavySoft,
                    _isStudentCardExporting ? () {} : _exportStudentCardPdfDirect,
                  ),
                  _actionButton(
                    _isStudentCardExporting ? 'جارٍ تصدير الصورة...' : 'تصدير صورة البطاقة',
                    const Color(0xFFF7F3EA),
                    AppPalette.goldDark,
                    _isStudentCardExporting ? () {} : _exportStudentCardImageDirect,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('اختيار الطالب', style: TextStyle(color: AppPalette.muted, fontSize: 12, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: student.id,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFBFDFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                              ),
                            ),
                            items: _students
                                .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.fullName)))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              final selected = _students.firstWhere((s) => s.id == value);
                              setState(() => _loadStudent(selected));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                RepaintBoundary(
                  key: _studentCardBoundaryKey,
                  child: _studentCardCanvas(student),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCardCanvas(StudentRecord student) {
    // Standard ID-1 visual (85.6 × 54 mm) with clearer readable layout.
    return Center(
      child: SizedBox(
        width: 460,
        child: AspectRatio(
          aspectRatio: 85.6 / 54.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD0DCEC), width: 1.2),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.10), blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: <Widget>[
                  // Header band
                  Container(
                    height: 74,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Color(0xFF123A78), Color(0xFF1E7A79), Color(0xFF2F9A8E)],
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset('image/logo.jpg', width: 46, height: 46, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/logo.jpg', width: 46, height: 46, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('مدرسة روز التعليمية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                              SizedBox(height: 2),
                              Text('البطاقة المدرسية', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: <Widget>[
                          // Photo
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD9E7F3), width: 3),
                              color: const Color(0xFFF4F8FC),
                            ),
                            child: ClipOval(
                              child: _fileStorage.fileExistsSync(student.studentPhotoPath)
                                  ? Image.file(File(student.studentPhotoPath), fit: BoxFit.cover)
                                  : Center(child: Image.asset('image/logo.jpg', width: 42, height: 42, fit: BoxFit.contain)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  student.fullName.isEmpty ? '—' : student.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                                ),
                                const SizedBox(height: 8),
                                _cardInfoLine('الصف', _studentGradeDisplay(student)),
                                _cardInfoLine('الشعبة', _studentSectionDisplay(student)),
                                _cardInfoLine('السنة الدراسية', student.schoolYear.isEmpty ? _currentAcademicYear() : student.schoolYear),
                                _cardInfoLine('الجنس', student.gender.isEmpty ? '—' : student.gender),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // QR
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 78,
                                height: 78,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppPalette.line),
                                ),
                                child: _fileStorage.fileExistsSync(student.qrFilePath)
                                    ? (student.qrFilePath.toLowerCase().endsWith('.svg')
                                        ? SvgPicture.file(File(student.qrFilePath), fit: BoxFit.contain)
                                        : Image.file(File(student.qrFilePath), fit: BoxFit.contain))
                                    : const Center(child: Icon(Icons.qr_code_2, color: AppPalette.muted)),
                              ),
                              const SizedBox(height: 6),
                              const Text('QR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppPalette.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFFF7F3EA),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.verified_outlined, size: 14, color: AppPalette.goldDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'الرقم العام: ${student.serial.isEmpty ? '—' : student.serial}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                          ),
                        ),
                        Text(
                          student.status.isEmpty ? '—' : student.status,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppPalette.goldDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCardPatternBand({required bool top}) {
    final colors = top
        ? const <Color>[Color(0xFF2F9A8E), Color(0xFF1E7A79), AppPalette.royalBlue, AppPalette.deepNavy]
        : const <Color>[Color(0xFF74C36A), Color(0xFF2F9A8E), Color(0xFF1E7A79), AppPalette.royalBlue];
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
          ),
        ),
        GridView.builder(
          itemCount: 40,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
          ),
          itemBuilder: (context, index) {
            final palette = top
                ? <Color>[Colors.white, const Color(0xFF6FD0B0), const Color(0xFF3CA0A4), const Color(0xFF2A7AB8)]
                : <Color>[Colors.white, const Color(0xFF9AE18B), const Color(0xFF6EC0A0), const Color(0xFF4A9FC2)];
            final color = palette[index % palette.length].withOpacity(index.isEven ? 0.08 : 0.15);
            return Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _studentCardPhoto(StudentRecord student, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 11),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(13, 29, 67, 0.12),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: _fileStorage.fileExistsSync(student.studentPhotoPath)
            ? Image.file(File(student.studentPhotoPath), fit: BoxFit.cover)
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFFE8F4FF), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    _studentTripleName(student).isEmpty
                        ? 'ط'
                        : _studentTripleName(student).substring(0, _studentTripleName(student).length >= 2 ? 2 : 1),
                    style: const TextStyle(
                      color: AppPalette.royalBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 42,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _studentCardInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: AppPalette.deepNavySoft,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                color: AppPalette.goldDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppPalette.text,
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCardBarcode(StudentRecord student, double width) {
    final seed = '${student.serial}${student.registryNumber}${student.id}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(72, (index) {
              final code = seed.codeUnitAt(index % seed.length);
              final factor = ((code + index * 5) % 5) + 1;
              final barHeight = 34.0 + factor * 6.5;
              final isDark = (code + index) % 4 != 1;
              return Container(
                width: index % 3 == 0 ? 2.2 : 1.3,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: .5),
                color: isDark ? Colors.black : Colors.transparent,
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          student.serial,
          style: const TextStyle(
            color: AppPalette.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _studentCardQrBadge(StudentRecord student, double size) {
    return Container(
      width: size,
      height: size + 18,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBF2)),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _fileStorage.fileExistsSync(student.qrFilePath)
                ? (student.qrFilePath.toLowerCase().endsWith('.svg')
                    ? SvgPicture.file(File(student.qrFilePath), fit: BoxFit.contain)
                    : Image.file(File(student.qrFilePath), fit: BoxFit.contain))
                : const Center(
                    child: Text(
                      'QR',
                      style: TextStyle(
                        color: AppPalette.deepNavySoft,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          const Text(
            'QR',
            style: TextStyle(
              color: AppPalette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _countBy(List<StudentRecord> students, String Function(StudentRecord) selector) {
    final result = <String, int>{};
    for (final student in students) {
      final key = selector(student).isEmpty ? 'غير محدد' : selector(student);
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> _disabilityCounts() {
    final result = <String, int>{};
    for (final student in _students) {
      if (student.healthStatus != 'إعاقة') continue;
      if (student.disabilityVisual) result['بصرية'] = (result['بصرية'] ?? 0) + 1;
      if (student.disabilityHearing) result['سمعية'] = (result['سمعية'] ?? 0) + 1;
      if (student.disabilityMotor) result['حركية'] = (result['حركية'] ?? 0) + 1;
      if (student.disabilityLearning) result['تعلم'] = (result['تعلم'] ?? 0) + 1;
    }
    if (result.isEmpty) {
      result['لا يوجد'] = 0;
    }
    return result;
  }

  String _healthSummary(StudentRecord student) {
    if (student.healthStatus != 'إعاقة') {
      return student.healthStatus;
    }
    final selected = <String>[
      if (student.disabilityVisual) 'بصرية',
      if (student.disabilityHearing) 'سمعية',
      if (student.disabilityMotor) 'حركية',
      if (student.disabilityLearning) 'تعلم',
    ];
    if (selected.isEmpty) return 'إعاقة';
    return 'إعاقة: ${selected.join('، ')}';
  }

  String _transportGatheringSummary(StudentRecord student) {
    if (student.transportSubscription == 'نعم') {
      return student.transportGathering.isEmpty ? 'غير محدد' : student.transportGathering;
    }
    if (student.transportSubscription == 'معفى من رسوم النقل') {
      return 'اختياري / معفى من الرسوم';
    }
    return 'غير مطلوب';
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(String title, Map<String, int> values, int total) {
    return SizedBox(
      width: 420,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
            const SizedBox(height: 12),
            ...values.entries.map((entry) {
              final percent = total == 0 ? 0.0 : entry.value / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text('${entry.value}', style: const TextStyle(color: AppPalette.muted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: percent,
                        backgroundColor: const Color(0xFFECF3F8),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.royalBlue),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }

  Widget _factCard(String label, String value) {
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(value.isEmpty ? '-' : value, style: const TextStyle(color: AppPalette.text, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _attendancePageSection() {
    final student = _selectedStudent ?? _students.first;
    final entries = _attendance.where((entry) => entry.studentId == student.id).toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🗓️ الحضور والغياب',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('تسجيل الحالة', AppPalette.goldDark, Colors.white, _addDemoAttendance),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                  _actionButton('تصدير Excel', const Color(0xFFE7F7EE), AppPalette.leafGreen, () => _showAttendanceExportDialog(asPdf: false)),
                  _actionButton('تصدير PDF', const Color(0xFFF7F3EA), AppPalette.goldDark, () => _showAttendanceExportDialog(asPdf: true)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'تسجيل حالة يومية للطالب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _dropdownStudentPicker(student),
                    _dropdownField('الحالة', _attendanceStatus, const <String>['حاضر', 'غائب', 'متأخر', 'مأذون'], (v) => setState(() => _attendanceStatus = v)),
                    _dateFieldCard('تاريخ التسجيل', _attendanceDateController),
                    _editableField('ملاحظات', _attendanceNoteController, span2: true, maxLines: 3),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'سجل الحضور والغياب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  const Text('لا توجد سجلات حضور/غياب لهذا الطالب حتى الآن.', style: TextStyle(color: AppPalette.muted))
                else
                  ...entries.map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.line),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(entry.status, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                  const SizedBox(height: 4),
                                  Text('${entry.date}\n${entry.note}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _attendance.remove(entry));
                                _showSnack('تم حذف سجل الحضور/الغياب بنجاح.');
                              },
                              icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownStudentPicker(StudentRecord student) {
    return SizedBox(
      width: 374,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('اختيار الطالب', style: TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: student.id,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFBFDFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                ),
              ),
              items: _students
                  .map(
                    (s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(
                        '${s.fullName}  •  ${_studentGradeDisplay(s)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = _students.firstWhere((s) => s.id == value);
                setState(() {
                  _examCycleOverride = null; // auto model from the new student's grade
                  _loadStudent(selected);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PaymentEntry> _activeFeeEntries(StudentRecord student) {
    return student.transportSubscription == 'نعم' ? student.transportFees : student.regularFees;
  }

  double _sumFeeDue(StudentRecord student) {
    return _activeFeeEntries(student).fold(0, (sum, e) => sum + (double.tryParse(e.dueAmount) ?? 0));
  }

  double _sumFeePaid(StudentRecord student) {
    return _activeFeeEntries(student).fold(0, (sum, e) => sum + (double.tryParse(e.paidAmount) ?? 0));
  }

  List<AccountingInvoiceEntry> _studentInvoices(int studentId) {
    return _invoices.where((entry) => entry.studentId == studentId).toList();
  }

  List<AccountingReceiptEntry> _studentReceipts(int studentId) {
    return _receipts.where((entry) => entry.studentId == studentId).toList();
  }

  Future<void> _showSecretariatDonationDialog() async {
    await _openDonationEntryFlow();
  }

  Future<void> _openDonationEntryFlow() async {
    final kind = await _showEntryKindChoiceDialog(title: 'نوع التبرع');
    if (kind == null) return;
    await _showDonationEntryEditor(initialKind: kind);
  }

  Future<void> _openAidEntryFlow() async {
    final kind = await _showEntryKindChoiceDialog(title: 'نوع المساعدة');
    if (kind == null) return;
    await _showAidEntryEditor(initialKind: kind);
  }

  Future<String?> _showEntryKindChoiceDialog({required String title}) async {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: _actionButton('مادية', AppPalette.goldDark, Colors.white, () => Navigator.pop(dialogContext, 'مادية')),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _actionButton('عينية', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => Navigator.pop(dialogContext, 'عينية')),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDonationEntryEditor({required String initialKind}) async {
    final student = _selectedStudent ?? _students.first;
    final items = _studentAccountingDonations(student.id);
    final materialTypeController = TextEditingController();
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final today = DateTime.now().toIso8601String().split('T').first;
    String kind = initialKind;
    AccountingDonationEntry? selectedEntry;

    Map<String, dynamic> createPaymentDraft({
      String info = '',
      String amount = '',
      String date = '',
      String currency = 'ليرة سورية',
      String otherCurrency = '',
    }) {
      return <String, dynamic>{
        'infoController': TextEditingController(text: info),
        'amountController': TextEditingController(text: amount),
        'dateController': TextEditingController(text: date.isEmpty ? today : date),
        'currency': currency,
        'otherCurrencyController': TextEditingController(text: otherCurrency),
      };
    }

    final List<Map<String, dynamic>> paymentDrafts = <Map<String, dynamic>>[
      createPaymentDraft(),
    ];

    void disposePaymentDraft(Map<String, dynamic> draft) {
      (draft['infoController'] as TextEditingController).dispose();
      (draft['amountController'] as TextEditingController).dispose();
      (draft['dateController'] as TextEditingController).dispose();
      (draft['otherCurrencyController'] as TextEditingController).dispose();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void loadEntry(AccountingDonationEntry entry) {
              selectedEntry = entry;
              kind = entry.donationKind;
              materialTypeController.text = entry.materialType;
              quantityController.text = entry.quantity;
              noteController.text = entry.note;
              dateController.text = entry.date;
              for (final draft in paymentDrafts) {
                disposePaymentDraft(draft);
              }
              paymentDrafts.clear();
              if (kind == 'مادية') {
                paymentDrafts.add(
                  createPaymentDraft(
                    info: entry.title,
                    amount: entry.amount == 0 ? '' : entry.amount.toStringAsFixed(0),
                    date: entry.date,
                    currency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(entry.currency) ? entry.currency : 'أخرى',
                    otherCurrency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(entry.currency) ? '' : entry.currency,
                  ),
                );
              } else {
                paymentDrafts.add(createPaymentDraft());
              }
            }

            String effectiveCurrencyFor(Map<String, dynamic> draft) {
              final selectedCurrency = draft['currency'] as String;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              return selectedCurrency == 'أخرى'
                  ? (otherCurrencyController.text.trim().isEmpty ? 'أخرى' : otherCurrencyController.text.trim())
                  : selectedCurrency;
            }

            void addPaymentDraft() {
              setDialogState(() => paymentDrafts.add(createPaymentDraft()));
            }

            void removePaymentDraftAt(int index) {
              if (paymentDrafts.length == 1) return;
              setDialogState(() {
                final removed = paymentDrafts.removeAt(index);
                disposePaymentDraft(removed);
              });
            }

            void autofillPaymentDraft(Map<String, dynamic> draft) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final localDateController = draft['dateController'] as TextEditingController;
              if (infoController.text.trim().isEmpty) {
                infoController.text = 'معلومات الدفع';
              }
              if (amountController.text.trim().isEmpty) {
                amountController.text = '0';
              }
              localDateController.text = today;
              draft['currency'] = 'ليرة سورية';
              (draft['otherCurrencyController'] as TextEditingController).clear();
              setDialogState(() {});
            }

            Widget paymentDraftCard(Map<String, dynamic> draft, int index) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final localDateController = draft['dateController'] as TextEditingController;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              final selectedCurrency = draft['currency'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDBF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('قالب الدفع ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.goldDark))),
                        if (paymentDrafts.length > 1)
                          IconButton(
                            onPressed: () => removePaymentDraftAt(index),
                            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: infoController, decoration: const InputDecoration(labelText: 'معلومات الدفع')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: localDateController, decoration: const InputDecoration(labelText: 'التاريخ')),
                    const SizedBox(height: 12),
                    const Text('العملة', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const <String>['ليرة سورية', 'دولار', 'يورو', 'أخرى'].map((currency) {
                        final active = selectedCurrency == currency;
                        return InkWell(
                          onTap: () => setDialogState(() => draft['currency'] = currency),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: active ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                              border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                            ),
                            child: Text(currency, style: TextStyle(color: active ? Colors.white : const Color(0xFF29446F), fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedCurrency == 'أخرى') ...<Widget>[
                      const SizedBox(height: 12),
                      TextField(controller: otherCurrencyController, decoration: const InputDecoration(labelText: 'أدخل العملة الأخرى')),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text(kind == 'مادية' ? 'إضافة تبرع مادي' : 'إضافة تبرع عيني'),
              content: SizedBox(
                width: 660,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (items.isNotEmpty) ...<Widget>[
                        const Text('السجلات الحالية', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                        const SizedBox(height: 8),
                        ...items.map((entry) => InkWell(
                              onTap: () => setDialogState(() => loadEntry(entry)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedEntry == entry ? const Color(0xFFF7F3EA) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppPalette.line),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(_donationDisplayTitle(entry), style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(_donationDisplaySubtitle(entry), style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.5)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_left),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                      if (kind == 'مادية') ...<Widget>[
                        ...paymentDrafts.asMap().entries.map((entry) => paymentDraftCard(entry.value, entry.key)),
                        _actionButton('إضافة قالب دفع', const Color(0xFFE7F7EE), AppPalette.leafGreen, addPaymentDraft),
                      ] else ...<Widget>[
                        TextField(controller: materialTypeController, decoration: const InputDecoration(labelText: 'نوع المادة')),
                        const SizedBox(height: 12),
                        TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'الكمية / العدد'),
                        ),
                        const SizedBox(height: 12),
                        TextField(controller: dateController, decoration: const InputDecoration(labelText: 'التاريخ')),
                        const SizedBox(height: 12),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          onTap: () => _clearNoteFieldOnFirstTap(noteController),
                          decoration: const InputDecoration(labelText: 'ملاحظات'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
                TextButton(
                  onPressed: () {
                    if (kind == 'مادية') {
                      final validDrafts = paymentDrafts.where((draft) {
                        final info = (draft['infoController'] as TextEditingController).text.trim();
                        final amount = (draft['amountController'] as TextEditingController).text.trim();
                        return info.isNotEmpty || amount.isNotEmpty;
                      }).toList();
                      if (validDrafts.isEmpty) {
                        _showSnack('أضف قالب دفع واحدًا على الأقل قبل الحفظ.');
                        return;
                      }
                      setState(() {
                        for (final draft in validDrafts) {
                          final info = (draft['infoController'] as TextEditingController).text.trim();
                          final amount = double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0;
                          final date = (draft['dateController'] as TextEditingController).text.trim().isEmpty
                              ? today
                              : (draft['dateController'] as TextEditingController).text.trim();
                          _accountingDonations.insert(
                            0,
                            AccountingDonationEntry(
                              studentId: student.id,
                              title: info.isEmpty ? 'معلومات الدفع' : info,
                              amount: amount,
                              currency: effectiveCurrencyFor(draft),
                              date: date,
                              donationKind: kind,
                              materialType: '',
                              quantity: '',
                              note: '',
                            ),
                          );
                        }
                      });
                      _persistAll();
                      Navigator.pop(dialogContext);
                      _showSnack('تم حفظ ${validDrafts.length} قالب/قوالب تبرع بنجاح.');
                      return;
                    }

                    final entry = AccountingDonationEntry(
                      studentId: student.id,
                      title: materialTypeController.text.trim().isEmpty ? 'تبرع عيني' : materialTypeController.text.trim(),
                      amount: 0,
                      currency: '',
                      date: dateController.text.trim().isEmpty ? today : dateController.text.trim(),
                      donationKind: kind,
                      materialType: materialTypeController.text.trim(),
                      quantity: quantityController.text.trim(),
                      note: noteController.text.trim(),
                    );
                    setState(() => _accountingDonations.insert(0, entry));
                    _persistAll();
                    Navigator.pop(dialogContext);
                    _showSnack('تم حفظ التبرع بنجاح.');
                  },
                  child: const Text('حفظ'),
                ),
                TextButton(
                  onPressed: selectedEntry == null
                      ? null
                      : () {
                          if (kind == 'مادية') {
                            final draft = paymentDrafts.first;
                            final index = _accountingDonations.indexOf(selectedEntry!);
                            if (index >= 0) {
                              setState(() {
                                _accountingDonations[index] = AccountingDonationEntry(
                                  studentId: selectedEntry!.studentId,
                                  title: (draft['infoController'] as TextEditingController).text.trim().isEmpty
                                      ? 'معلومات الدفع'
                                      : (draft['infoController'] as TextEditingController).text.trim(),
                                  amount: double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0,
                                  currency: effectiveCurrencyFor(draft),
                                  date: (draft['dateController'] as TextEditingController).text.trim().isEmpty
                                      ? today
                                      : (draft['dateController'] as TextEditingController).text.trim(),
                                  donationKind: kind,
                                  materialType: '',
                                  quantity: '',
                                  note: '',
                                );
                              });
                              _persistAll();
                            }
                            Navigator.pop(dialogContext);
                            _showSnack('تم تعديل التبرع بنجاح.');
                            return;
                          }

                          final index = _accountingDonations.indexOf(selectedEntry!);
                          if (index >= 0) {
                            setState(() {
                              _accountingDonations[index] = AccountingDonationEntry(
                                studentId: selectedEntry!.studentId,
                                title: materialTypeController.text.trim().isEmpty ? 'تبرع عيني' : materialTypeController.text.trim(),
                                amount: 0,
                                currency: '',
                                date: dateController.text.trim().isEmpty ? selectedEntry!.date : dateController.text.trim(),
                                donationKind: kind,
                                materialType: materialTypeController.text.trim(),
                                quantity: quantityController.text.trim(),
                                note: noteController.text.trim(),
                              );
                            });
                            _persistAll();
                          }
                          Navigator.pop(dialogContext);
                          _showSnack('تم تعديل التبرع بنجاح.');
                        },
                  child: const Text('تعديل'),
                ),
                TextButton(
                  onPressed: selectedEntry == null
                      ? null
                      : () {
                          setState(() => _accountingDonations.remove(selectedEntry));
                          _persistAll();
                          Navigator.pop(dialogContext);
                          _showSnack('تم حذف التبرع بنجاح.');
                        },
                  child: const Text('حذف', style: TextStyle(color: AppPalette.roseRed)),
                ),
              ],
            );
          },
        );
      },
    );

    materialTypeController.dispose();
    quantityController.dispose();
    noteController.dispose();
    dateController.dispose();
    for (final draft in paymentDrafts) {
      disposePaymentDraft(draft);
    }
  }

  Future<void> _showAidEntryEditor({required String initialKind}) async {
    final student = _selectedStudent ?? _students.first;
    final items = _studentAccountingAids(student.id);
    final materialTypeController = TextEditingController();
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final today = DateTime.now().toIso8601String().split('T').first;
    String kind = initialKind;
    AccountingAidEntry? selectedEntry;

    Map<String, dynamic> createPaymentDraft({
      String info = '',
      String amount = '',
      String date = '',
      String currency = 'ليرة سورية',
      String otherCurrency = '',
    }) {
      return <String, dynamic>{
        'infoController': TextEditingController(text: info),
        'amountController': TextEditingController(text: amount),
        'dateController': TextEditingController(text: date.isEmpty ? today : date),
        'currency': currency,
        'otherCurrencyController': TextEditingController(text: otherCurrency),
      };
    }

    final List<Map<String, dynamic>> paymentDrafts = <Map<String, dynamic>>[
      createPaymentDraft(),
    ];

    void disposePaymentDraft(Map<String, dynamic> draft) {
      (draft['infoController'] as TextEditingController).dispose();
      (draft['amountController'] as TextEditingController).dispose();
      (draft['dateController'] as TextEditingController).dispose();
      (draft['otherCurrencyController'] as TextEditingController).dispose();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void loadEntry(AccountingAidEntry entry) {
              selectedEntry = entry;
              kind = entry.aidKind;
              materialTypeController.text = entry.materialType;
              quantityController.text = entry.quantity;
              noteController.text = entry.note;
              dateController.text = entry.date;
              for (final draft in paymentDrafts) {
                disposePaymentDraft(draft);
              }
              paymentDrafts.clear();
              if (kind == 'مادية') {
                paymentDrafts.add(
                  createPaymentDraft(
                    info: entry.title,
                    amount: entry.amount == 0 ? '' : entry.amount.toStringAsFixed(0),
                    date: entry.date,
                    currency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(entry.currency) ? entry.currency : 'أخرى',
                    otherCurrency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(entry.currency) ? '' : entry.currency,
                  ),
                );
              } else {
                paymentDrafts.add(createPaymentDraft());
              }
            }

            String effectiveCurrencyFor(Map<String, dynamic> draft) {
              final selectedCurrency = draft['currency'] as String;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              return selectedCurrency == 'أخرى'
                  ? (otherCurrencyController.text.trim().isEmpty ? 'أخرى' : otherCurrencyController.text.trim())
                  : selectedCurrency;
            }

            void addPaymentDraft() {
              setDialogState(() => paymentDrafts.add(createPaymentDraft()));
            }

            void removePaymentDraftAt(int index) {
              if (paymentDrafts.length == 1) return;
              setDialogState(() {
                final removed = paymentDrafts.removeAt(index);
                disposePaymentDraft(removed);
              });
            }

            void autofillPaymentDraft(Map<String, dynamic> draft) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final localDateController = draft['dateController'] as TextEditingController;
              if (infoController.text.trim().isEmpty) {
                infoController.text = 'معلومات الدفع';
              }
              if (amountController.text.trim().isEmpty) {
                amountController.text = '0';
              }
              localDateController.text = today;
              draft['currency'] = 'ليرة سورية';
              (draft['otherCurrencyController'] as TextEditingController).clear();
              setDialogState(() {});
            }

            Widget paymentDraftCard(Map<String, dynamic> draft, int index) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final localDateController = draft['dateController'] as TextEditingController;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              final selectedCurrency = draft['currency'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDBF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('قالب الدفع ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.goldDark))),
                        if (paymentDrafts.length > 1)
                          IconButton(
                            onPressed: () => removePaymentDraftAt(index),
                            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: infoController, decoration: const InputDecoration(labelText: 'معلومات الدفع')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: localDateController, decoration: const InputDecoration(labelText: 'التاريخ')),
                    const SizedBox(height: 12),
                    const Text('العملة', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const <String>['ليرة سورية', 'دولار', 'يورو', 'أخرى'].map((currency) {
                        final active = selectedCurrency == currency;
                        return InkWell(
                          onTap: () => setDialogState(() => draft['currency'] = currency),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: active ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                              border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                            ),
                            child: Text(currency, style: TextStyle(color: active ? Colors.white : const Color(0xFF29446F), fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedCurrency == 'أخرى') ...<Widget>[
                      const SizedBox(height: 12),
                      TextField(controller: otherCurrencyController, decoration: const InputDecoration(labelText: 'أدخل العملة الأخرى')),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text(kind == 'مادية' ? 'إضافة مساعدة مادية' : 'إضافة مساعدة عينية'),
              content: SizedBox(
                width: 660,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (items.isNotEmpty) ...<Widget>[
                        const Text('السجلات الحالية', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                        const SizedBox(height: 8),
                        ...items.map((entry) => InkWell(
                              onTap: () => setDialogState(() => loadEntry(entry)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedEntry == entry ? const Color(0xFFF7F3EA) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppPalette.line),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(_aidDisplayTitle(entry), style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(_aidDisplaySubtitle(entry), style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.5)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_left),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                      if (kind == 'مادية') ...<Widget>[
                        ...paymentDrafts.asMap().entries.map((entry) => paymentDraftCard(entry.value, entry.key)),
                        _actionButton('إضافة قالب دفع', const Color(0xFFE7F7EE), AppPalette.leafGreen, addPaymentDraft),
                      ] else ...<Widget>[
                        TextField(controller: materialTypeController, decoration: const InputDecoration(labelText: 'نوع المادة')),
                        const SizedBox(height: 12),
                        TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'الكمية'),
                        ),
                        const SizedBox(height: 12),
                        TextField(controller: dateController, decoration: const InputDecoration(labelText: 'التاريخ')),
                        const SizedBox(height: 12),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          onTap: () => _clearNoteFieldOnFirstTap(noteController),
                          decoration: const InputDecoration(labelText: 'ملاحظات'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
                TextButton(
                  onPressed: () {
                    if (kind == 'مادية') {
                      final validDrafts = paymentDrafts.where((draft) {
                        final info = (draft['infoController'] as TextEditingController).text.trim();
                        final amount = (draft['amountController'] as TextEditingController).text.trim();
                        return info.isNotEmpty || amount.isNotEmpty;
                      }).toList();
                      if (validDrafts.isEmpty) {
                        _showSnack('أضف قالب دفع واحدًا على الأقل قبل الحفظ.');
                        return;
                      }
                      setState(() {
                        for (final draft in validDrafts) {
                          final info = (draft['infoController'] as TextEditingController).text.trim();
                          final amount = double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0;
                          final date = (draft['dateController'] as TextEditingController).text.trim().isEmpty
                              ? today
                              : (draft['dateController'] as TextEditingController).text.trim();
                          _accountingAids.insert(
                            0,
                            AccountingAidEntry(
                              studentId: student.id,
                              title: info.isEmpty ? 'معلومات الدفع' : info,
                              amount: amount,
                              currency: effectiveCurrencyFor(draft),
                              date: date,
                              aidKind: kind,
                              materialType: '',
                              quantity: '',
                              note: '',
                            ),
                          );
                        }
                      });
                      _persistAll();
                      Navigator.pop(dialogContext);
                      _showSnack('تم حفظ ${validDrafts.length} قالب/قوالب مساعدة بنجاح.');
                      return;
                    }

                    final entry = AccountingAidEntry(
                      studentId: student.id,
                      title: materialTypeController.text.trim().isEmpty ? 'مساعدة عينية' : materialTypeController.text.trim(),
                      amount: 0,
                      currency: '',
                      date: dateController.text.trim().isEmpty ? today : dateController.text.trim(),
                      aidKind: kind,
                      materialType: materialTypeController.text.trim(),
                      quantity: quantityController.text.trim(),
                      note: noteController.text.trim(),
                    );
                    setState(() => _accountingAids.insert(0, entry));
                    _persistAll();
                    Navigator.pop(dialogContext);
                    _showSnack('تم حفظ المساعدة بنجاح.');
                  },
                  child: const Text('حفظ'),
                ),
                TextButton(
                  onPressed: selectedEntry == null
                      ? null
                      : () {
                          if (kind == 'مادية') {
                            final draft = paymentDrafts.first;
                            final index = _accountingAids.indexOf(selectedEntry!);
                            if (index >= 0) {
                              setState(() {
                                _accountingAids[index] = AccountingAidEntry(
                                  studentId: selectedEntry!.studentId,
                                  title: (draft['infoController'] as TextEditingController).text.trim().isEmpty
                                      ? 'معلومات الدفع'
                                      : (draft['infoController'] as TextEditingController).text.trim(),
                                  amount: double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0,
                                  currency: effectiveCurrencyFor(draft),
                                  date: (draft['dateController'] as TextEditingController).text.trim().isEmpty
                                      ? today
                                      : (draft['dateController'] as TextEditingController).text.trim(),
                                  aidKind: kind,
                                  materialType: '',
                                  quantity: '',
                                  note: '',
                                );
                              });
                              _persistAll();
                            }
                            Navigator.pop(dialogContext);
                            _showSnack('تم تعديل المساعدة بنجاح.');
                            return;
                          }

                          final index = _accountingAids.indexOf(selectedEntry!);
                          if (index >= 0) {
                            setState(() {
                              _accountingAids[index] = AccountingAidEntry(
                                studentId: selectedEntry!.studentId,
                                title: materialTypeController.text.trim().isEmpty ? 'مساعدة عينية' : materialTypeController.text.trim(),
                                amount: 0,
                                currency: '',
                                date: dateController.text.trim().isEmpty ? selectedEntry!.date : dateController.text.trim(),
                                aidKind: kind,
                                materialType: materialTypeController.text.trim(),
                                quantity: quantityController.text.trim(),
                                note: noteController.text.trim(),
                              );
                            });
                            _persistAll();
                          }
                          Navigator.pop(dialogContext);
                          _showSnack('تم تعديل المساعدة بنجاح.');
                        },
                  child: const Text('تعديل'),
                ),
                TextButton(
                  onPressed: selectedEntry == null
                      ? null
                      : () {
                          setState(() => _accountingAids.remove(selectedEntry));
                          _persistAll();
                          Navigator.pop(dialogContext);
                          _showSnack('تم حذف المساعدة بنجاح.');
                        },
                  child: const Text('حذف', style: TextStyle(color: AppPalette.roseRed)),
                ),
              ],
            );
          },
        );
      },
    );

    materialTypeController.dispose();
    quantityController.dispose();
    noteController.dispose();
    dateController.dispose();
    for (final draft in paymentDrafts) {
      disposePaymentDraft(draft);
    }
  }

  String _donationDisplayTitle(AccountingDonationEntry entry) {
    return entry.donationKind == 'عينية'
        ? (entry.materialType.isEmpty ? 'تبرع عيني' : entry.materialType)
        : entry.title;
  }

  String _donationDisplaySubtitle(AccountingDonationEntry entry) {
    if (entry.donationKind == 'عينية') {
      final quantity = entry.quantity.isEmpty ? '-' : entry.quantity;
      final noteSuffix = entry.note.isEmpty ? '' : '\n${entry.note}';
      return 'عينية • الكمية/العدد: $quantity • ${entry.date}$noteSuffix';
    }
    return 'مادية • ${entry.amount.toStringAsFixed(0)} ${entry.currency} • ${entry.date}';
  }

  String _aidDisplayTitle(AccountingAidEntry entry) {
    return entry.aidKind == 'عينية'
        ? (entry.materialType.isEmpty ? 'مساعدة عينية' : entry.materialType)
        : entry.title;
  }

  String _aidDisplaySubtitle(AccountingAidEntry entry) {
    if (entry.aidKind == 'عينية') {
      final quantity = entry.quantity.isEmpty ? '-' : entry.quantity;
      final noteSuffix = entry.note.isEmpty ? '' : '\n${entry.note}';
      return 'عينية • الكمية: $quantity • ${entry.date}$noteSuffix';
    }
    return 'مادية • ${entry.amount.toStringAsFixed(0)} ${entry.currency} • ${entry.date}';
  }

  Widget _donationsPageSection() {
    return Center(
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.line),
        ),
        child: const Text(
          'تم حذف شاشات التبرعات والمساعدات من باب الأقساط والدفعات.
استخدم «الإيرادات والصرفيات» عند الحاجة لتسجيل إيرادات أخرى.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppPalette.muted, height: 1.8, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  double _sumAccountingDonations(int studentId) {
    return _studentAccountingDonations(studentId)
        .where((entry) => entry.donationKind == 'مادية')
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  double _sumAccountingAids(int studentId) {
    return _studentAccountingAids(studentId)
        .where((entry) => entry.aidKind == 'مادية')
        .fold<double>(0, (sum, e) => sum + e.amount);
  }


  String _todayIsoDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseFlexibleDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }
    final parts = value.split(RegExp(r'[/-]'));
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  /// Monthly installment window: day 1..5 of current month.
  bool _isInsideInstallmentPaymentWindow([DateTime? now]) {
    final n = now ?? DateTime.now();
    return n.day >= 1 && n.day <= 5;
  }

  /// Overdue after day 5 if student has invoices and no receipt this month.
  bool _studentHasOverdueInstallment(StudentRecord student, [DateTime? now]) {
    final n = now ?? DateTime.now();
    if (n.day <= 5) {
      return false;
    }
    final invoices = _studentInvoices(student.id);
    if (invoices.isEmpty) {
      return false;
    }
    final receipts = _studentReceipts(student.id);
    final paidThisMonth = receipts.any((r) {
      final d = _parseFlexibleDate(r.date);
      return d != null && d.year == n.year && d.month == n.month;
    });
    return !paidThisMonth;
  }

  List<StudentRecord> _studentsWithOverdueInstallments([DateTime? now]) {
    final n = now ?? DateTime.now();
    return _students.where((s) => _studentHasOverdueInstallment(s, n)).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  IncomeCategory _resolveIncomeCategory(String preferredId, String preferredName) {
    final cats = FinanceService.instance.incomeCategories;
    for (final c in cats) {
      if (c.id == preferredId) {
        return c;
      }
    }
    for (final c in cats) {
      if (c.name == preferredName) {
        return c;
      }
    }
    if (cats.isNotEmpty) {
      return cats.first;
    }
    return IncomeCategory(id: preferredId, name: preferredName, isDefault: true);
  }

  Future<void> _pushIncomeFromAccounting({
    required String preferredCategoryId,
    required String preferredCategoryName,
    required double amount,
    required String currency,
    required String date,
    required String description,
    required int studentId,
    required String studentName,
  }) async {
    if (amount <= 0) {
      return;
    }
    await FinanceService.instance.init();
    final cat = _resolveIncomeCategory(preferredCategoryId, preferredCategoryName);
    await FinanceService.instance.addIncome(
      IncomeEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        categoryId: cat.id,
        categoryName: cat.name,
        amount: amount,
        currency: currency.isEmpty ? 'ليرة سورية' : currency,
        date: date.isEmpty ? _todayIsoDate() : date,
        description: description,
        studentId: studentId,
        studentName: studentName,
        createdBy: _authenticatedUser?.username ?? 'system',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<bool> _confirmInstallmentSaveDialog({
    required String studentName,
    required double amount,
    required String currency,
    required String date,
    required String installmentLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد إدخال القسط', style: TextStyle(fontWeight: FontWeight.w900)),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'تم إدخال قسط للطالب ($studentName) بقيمة ${amount.toStringAsFixed(0)} $currency بتاريخ $date.',
                    style: const TextStyle(height: 1.7, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    installmentLabel,
                    style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط «موافق» للحفظ، أو «إلغاء» لعدم حفظ الإدخال.',
                    style: TextStyle(color: AppPalette.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.goldDark,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      },
    );
    return result == true;
  }

  Future<void> _showInstallmentPresetDialog({String presetType = 'normal'}) async {
    if (_students.isEmpty) {
      _showSnack('لا يوجد طلاب لإضافة قسط.');
      return;
    }

    StudentRecord student = _selectedStudent ?? _students.first;
    int selectedStudentId = student.id;

    String emoji = '💵';
    String title = 'قسط عادي';
    String note = '';
    double unitAmount = 0;

    final monthly = double.tryParse(_installmentMonthlyController.text.trim()) ?? 20000;
    final transportMonthly = double.tryParse(_transportMonthlyController.text.trim()) ?? 5000;
    final grantAmount = double.tryParse(_transportGrantController.text.trim()) ?? 25000;
    final maxCount = (int.tryParse(_installmentCountController.text.trim()) ?? 10).clamp(1, 36);
    final exemptionMonths = int.tryParse(_exemptionMonthsController.text.trim()) ?? 3;
    final currency = const <String>['ليرة سورية', 'دولار', 'يورو'].contains(_installmentCurrency)
        ? _installmentCurrency
        : 'ليرة سورية';

    switch (presetType) {
      case 'normal':
        emoji = '💵';
        title = 'قسط عادي';
        unitAmount = monthly;
        note = 'كل ضغطة تضيف قسطًا واحدًا فقط بالقيمة المحددة من الإدارة.';
        break;
      case 'transport':
        emoji = '💵🚌';
        title = 'قسط مع مواصلات';
        unitAmount = monthly + transportMonthly;
        note = 'كل ضغطة تضيف قسطًا واحدًا = (قسط شهري + مواصلات) من إعدادات الإدارة.';
        break;
      case 'grant':
        emoji = '💵🚌🎁';
        title = 'قسط مع منحة مواصلات';
        unitAmount = monthly + grantAmount;
        note = 'كل ضغطة تضيف قسطًا واحدًا = (قسط شهري + منحة مواصلات). إعفاء $exemptionMonths شهراً من الإدارة.';
        break;
    }

    final titlePrefix = '$emoji $title';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            student = _students.firstWhere((s) => s.id == selectedStudentId, orElse: () => _students.first);
            final items = _studentInvoices(student.id);
            final existingCount = items.where((e) => e.title.startsWith(titlePrefix)).length;
            final remaining = (maxCount - existingCount).clamp(0, maxCount);
            final nextIndex = existingCount + 1;
            final canAdd = remaining > 0 && unitAmount > 0;
            final paidTotal = _studentReceipts(student.id).fold<double>(0, (sum, e) => sum + e.amount);

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Row(
                  children: <Widget>[
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 580,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButtonFormField<int>(
                        value: selectedStudentId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'الطالب',
                          filled: true,
                          fillColor: Color(0xFFFBFDFF),
                        ),
                        items: _students
                            .map(
                              (s) => DropdownMenuItem<int>(
                                value: s.id,
                                child: Text('${s.fullName} • ${_studentGradeDisplay(s)}', overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedStudentId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8DDBF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'قيمة القسط الواحد (من الإدارة — غير قابلة للتعديل)',
                              style: TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${unitAmount.toStringAsFixed(0)} $currency',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الحد الأقصى من الإدارة: $maxCount قسط',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المضاف: $existingCount  •  المتبقي: $remaining',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: remaining == 0 ? AppPalette.roseRed : const Color(0xFF0F5C5A),
                              ),
                            ),
                            if (canAdd) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                'سيتم الآن إضافة: قسط $nextIndex/$maxCount',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.goldDark),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(note, style: const TextStyle(color: AppPalette.muted, height: 1.5, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'الدفعات المسجّلة لهذا الطالب: ${paidTotal.toStringAsFixed(0)} $currency',
                        style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800),
                      ),
                      if (!canAdd) ...<Widget>[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF0C7C7)),
                          ),
                          child: Text(
                            remaining == 0
                                ? 'تم الوصول للحد الأقصى ($maxCount قسط) لهذا النوع.'
                                : 'لا يمكن إضافة قسط حاليًا.',
                            style: const TextStyle(color: AppPalette.roseRed, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ],
                      if (items.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        const Text('الأقساط الحالية للطالب', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final entry = items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBFDFF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppPalette.line),
                                ),
                                child: Text(
                                  '${entry.title} • ${entry.amount.toStringAsFixed(0)} ${entry.currency} • ${entry.date}',
                                  style: const TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w700),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.goldDark,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: !canAdd
                        ? null
                        : () async {
                            // ONE installment only per click + explicit confirm dialog.
                            final today = DateTime.now();
                            final due = DateTime(today.year, today.month + existingCount, today.day);
                            final dueLabel =
                                '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
                            final studentName = student.fullName;
                            final installmentTitle = '$titlePrefix — قسط $nextIndex/$maxCount';
                            final confirmed = await _confirmInstallmentSaveDialog(
                              studentName: studentName,
                              amount: unitAmount,
                              currency: currency,
                              date: dueLabel,
                              installmentLabel: installmentTitle,
                            );
                            if (!confirmed) {
                              return;
                            }
                            setState(() {
                              _selectedStudentId = selectedStudentId;
                              _invoices.insert(
                                0,
                                AccountingInvoiceEntry(
                                  studentId: selectedStudentId,
                                  title: installmentTitle,
                                  amount: unitAmount,
                                  currency: currency,
                                  date: dueLabel,
                                ),
                              );
                              _accountingView = 'installments';
                              _accountingFilterStudentId = selectedStudentId;
                            });
                            await _persistAll();
                            await _pushIncomeFromAccounting(
                              preferredCategoryId: 'tuition',
                              preferredCategoryName: 'أقساط دراسية',
                              amount: unitAmount,
                              currency: currency,
                              date: dueLabel,
                              description: 'قسط: $installmentTitle — الطالب: $studentName',
                              studentId: selectedStudentId,
                              studentName: studentName,
                            );
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              final left = maxCount - nextIndex;
                              _showSnack(
                                left > 0
                                    ? 'تمت إضافة قسط $nextIndex/$maxCount للطالب $studentName. المتبقي: $left'
                                    : 'تمت إضافة آخر قسط ($nextIndex/$maxCount) للطالب $studentName.',
                              );
                            }
                          },
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: Text(canAdd ? 'إضافة قسط $nextIndex/$maxCount' : 'لا تبقى أقساط'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showStudentPaymentDialog({StudentRecord? student}) async {
    final target = student ?? _selectedStudent ?? (_students.isEmpty ? null : _students.first);
    if (target == null) {
      _showSnack('لا يوجد طالب لإضافة دفعة.');
      return;
    }

    final titleController = TextEditingController(text: 'دفعة');
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    String currency = const <String>['ليرة سورية', 'دولار', 'يورو'].contains(_installmentCurrency)
        ? _installmentCurrency
        : 'ليرة سورية';
    int selectedStudentId = target.id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('💵 إضافة دفعة'),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      value: selectedStudentId,
                      decoration: const InputDecoration(labelText: 'الطالب'),
                      items: _students
                          .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.fullName)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedStudentId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'بيان الدفعة', hintText: 'دفعة'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'المبلغ', hintText: 'المبلغ'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: currency,
                      decoration: const InputDecoration(labelText: 'العملة'),
                      items: const <String>['ليرة سورية', 'دولار', 'يورو']
                          .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => currency = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'التاريخ', hintText: 'YYYY-MM-DD'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'ملاحظة', hintText: 'ملاحظة'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0;
                    if (amount <= 0) {
                      _showSnack('أدخل مبلغ دفعة صالحاً.');
                      return;
                    }
                    final payTitle = titleController.text.trim().isEmpty ? 'دفعة' : titleController.text.trim();
                    final payDate = dateController.text.trim().isEmpty
                        ? DateTime.now().toIso8601String().split('T').first
                        : dateController.text.trim();
                    final payNote = noteController.text.trim().isEmpty ? 'دفعة من المحاسبة' : noteController.text.trim();
                    final studentName = _students
                        .firstWhere((s) => s.id == selectedStudentId, orElse: () => _students.first)
                        .fullName;
                    setState(() {
                      _receipts.insert(
                        0,
                        AccountingReceiptEntry(
                          studentId: selectedStudentId,
                          title: payTitle,
                          amount: amount,
                          currency: currency,
                          date: payDate,
                          note: payNote,
                        ),
                      );
                      _accountingView = 'payments';
                      _accountingFilterStudentId = selectedStudentId;
                    });
                    await _persistAll();
                    await _pushIncomeFromAccounting(
                      preferredCategoryId: 'tuition',
                      preferredCategoryName: 'أقساط دراسية',
                      amount: amount,
                      currency: currency,
                      date: payDate,
                      description: 'دفعة: $payTitle — الطالب: $studentName${payNote.isEmpty ? '' : ' — $payNote'}',
                      studentId: selectedStudentId,
                      studentName: studentName,
                    );
                    await NotificationService.instance.markInstallmentPaidForStudent(
                      studentId: selectedStudentId,
                      studentName: studentName,
                      amount: amount,
                      currency: currency,
                      date: payDate,
                    );
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                    _showSnack('تمت إضافة الدفعة إلى حساب الطالب وترحيلها للإيرادات.');
                  },
                  child: const Text('حفظ الدفعة'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
  }

  Future<void> _showInstallmentDialog() async {
    await _showInstallmentPresetDialog(presetType: 'normal');
  }

  Future<void> _showAccountingDonationDialog() async {
    await _openDonationEntryFlow();
  }

  Future<void> _showAccountingAidDialog() async {
    await _openAidEntryFlow();
  }

  Future<void> _showAccountingEntryDialog({
    required String dialogTitle,
    required List<Map<String, dynamic>> existingItems,
    required void Function(String title, double amount, String currency, String date) onSave,
    required void Function(Object raw, String title, double amount, String currency, String date) onEdit,
    required void Function(Object raw) onDelete,
    double initialAmount = 0,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    Map<String, dynamic> createDraft({
      String info = '',
      String amount = '',
      String date = '',
      String currency = 'ليرة سورية',
      String otherCurrency = '',
    }) {
      return <String, dynamic>{
        'infoController': TextEditingController(text: info),
        'amountController': TextEditingController(text: amount),
        'dateController': TextEditingController(text: date.isEmpty ? today : date),
        'currency': currency,
        'otherCurrencyController': TextEditingController(text: otherCurrency),
      };
    }

    final defaultCurrency = const <String>['ليرة سورية', 'دولار', 'يورو'].contains(_installmentCurrency)
        ? _installmentCurrency
        : 'ليرة سورية';
    final List<Map<String, dynamic>> paymentDrafts = <Map<String, dynamic>>[
      createDraft(
        amount: initialAmount > 0 ? initialAmount.toStringAsFixed(0) : '',
        currency: defaultCurrency,
      ),
    ];
    Object? selectedRaw;

    void disposeDraft(Map<String, dynamic> draft) {
      (draft['infoController'] as TextEditingController).dispose();
      (draft['amountController'] as TextEditingController).dispose();
      (draft['dateController'] as TextEditingController).dispose();
      (draft['otherCurrencyController'] as TextEditingController).dispose();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String effectiveCurrencyFor(Map<String, dynamic> draft) {
              final selectedCurrency = draft['currency'] as String;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              return selectedCurrency == 'أخرى'
                  ? (otherCurrencyController.text.trim().isEmpty ? 'أخرى' : otherCurrencyController.text.trim())
                  : selectedCurrency;
            }

            void addDraft() {
              setDialogState(() {
                paymentDrafts.add(createDraft(currency: defaultCurrency));
              });
            }

            void removeDraftAt(int index) {
              if (paymentDrafts.length == 1) {
                return;
              }
              setDialogState(() {
                final removed = paymentDrafts.removeAt(index);
                disposeDraft(removed);
              });
            }

            void autofillDraft(Map<String, dynamic> draft) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final dateController = draft['dateController'] as TextEditingController;
              if (infoController.text.trim().isEmpty) {
                infoController.text = 'معلومات الدفع';
              }
              if (amountController.text.trim().isEmpty) {
                amountController.text = '0';
              }
              dateController.text = today;
              draft['currency'] = defaultCurrency;
              (draft['otherCurrencyController'] as TextEditingController).clear();
              setDialogState(() {});
            }

            void loadItem(Map<String, dynamic> item) {
              for (final draft in paymentDrafts) {
                disposeDraft(draft);
              }
              paymentDrafts
                ..clear()
                ..add(
                  createDraft(
                    info: item['title']?.toString() ?? '',
                    amount: (item['amount'] as num).toStringAsFixed(0),
                    date: item['date']?.toString() ?? today,
                    currency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(item['currency'].toString())
                        ? item['currency'].toString()
                        : 'أخرى',
                    otherCurrency: const <String>['ليرة سورية', 'دولار', 'يورو'].contains(item['currency'].toString())
                        ? ''
                        : item['currency'].toString(),
                  ),
                );
              selectedRaw = item['raw'];
            }

            Widget paymentDraftCard(Map<String, dynamic> draft, int index) {
              final infoController = draft['infoController'] as TextEditingController;
              final amountController = draft['amountController'] as TextEditingController;
              final dateController = draft['dateController'] as TextEditingController;
              final otherCurrencyController = draft['otherCurrencyController'] as TextEditingController;
              final selectedCurrency = draft['currency'] as String;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDBF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('قالب الدفع ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.goldDark)),
                        ),
                        if (paymentDrafts.length > 1)
                          IconButton(
                            onPressed: () => removeDraftAt(index),
                            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: infoController,
                      decoration: const InputDecoration(labelText: 'معلومات الدفع'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'التاريخ'),
                    ),
                    const SizedBox(height: 12),
                    const Text('العملة', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const <String>['ليرة سورية', 'دولار', 'يورو', 'أخرى'].map((currency) {
                        final active = selectedCurrency == currency;
                        return InkWell(
                          onTap: () => setDialogState(() => draft['currency'] = currency),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: active ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                              border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                            ),
                            child: Text(currency, style: TextStyle(color: active ? Colors.white : const Color(0xFF29446F), fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedCurrency == 'أخرى') ...<Widget>[
                      const SizedBox(height: 12),
                      TextField(
                        controller: otherCurrencyController,
                        decoration: const InputDecoration(labelText: 'أدخل العملة الأخرى'),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text(dialogTitle),
              content: SizedBox(
                width: 680,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (existingItems.isNotEmpty) ...<Widget>[
                        const Text('السجلات الحالية', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                        const SizedBox(height: 8),
                        ...existingItems.map((item) => InkWell(
                              onTap: () => setDialogState(() => loadItem(item)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedRaw == item['raw'] ? const Color(0xFFF7F3EA) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppPalette.line),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(item['title'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text('${(item['amount'] as num).toStringAsFixed(0)} ${item['currency']} • ${item['date']}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_left),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                      ...paymentDrafts.asMap().entries.map((entry) => paymentDraftCard(entry.value, entry.key)),
                      _actionButton('إضافة قالب دفع', const Color(0xFFE7F7EE), AppPalette.leafGreen, addDraft),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إغلاق'),
                ),
                TextButton(
                  onPressed: () {
                    final validDrafts = paymentDrafts.where((draft) {
                      final info = (draft['infoController'] as TextEditingController).text.trim();
                      final amount = (draft['amountController'] as TextEditingController).text.trim();
                      return info.isNotEmpty || amount.isNotEmpty;
                    }).toList();
                    if (validDrafts.isEmpty) {
                      _showSnack('أضف قالب دفع واحدًا على الأقل قبل الحفظ.');
                      return;
                    }
                    for (final draft in validDrafts) {
                      final info = (draft['infoController'] as TextEditingController).text.trim();
                      final amount = double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0;
                      final date = (draft['dateController'] as TextEditingController).text.trim().isEmpty
                          ? today
                          : (draft['dateController'] as TextEditingController).text.trim();
                      onSave(info.isEmpty ? 'معلومات الدفع' : info, amount, effectiveCurrencyFor(draft), date);
                    }
                    Navigator.pop(dialogContext);
                    _showSnack('تم حفظ ${validDrafts.length} قالب/قوالب دفع بنجاح.');
                  },
                  child: const Text('حفظ'),
                ),
                TextButton(
                  onPressed: selectedRaw == null
                      ? null
                      : () {
                          final draft = paymentDrafts.first;
                          final info = (draft['infoController'] as TextEditingController).text.trim();
                          final amount = double.tryParse((draft['amountController'] as TextEditingController).text.trim()) ?? 0;
                          final date = (draft['dateController'] as TextEditingController).text.trim().isEmpty
                              ? today
                              : (draft['dateController'] as TextEditingController).text.trim();
                          onEdit(selectedRaw!, info.isEmpty ? 'معلومات الدفع' : info, amount, effectiveCurrencyFor(draft), date);
                          Navigator.pop(dialogContext);
                          _showSnack('تم تعديل السجل بنجاح.');
                        },
                  child: const Text('تعديل'),
                ),
                TextButton(
                  onPressed: selectedRaw == null
                      ? null
                      : () {
                          onDelete(selectedRaw!);
                          Navigator.pop(dialogContext);
                          _showSnack('تم حذف السجل بنجاح.');
                        },
                  child: const Text('حذف', style: TextStyle(color: AppPalette.roseRed)),
                ),
              ],
            );
          },
        );
      },
    );

    for (final draft in paymentDrafts) {
      disposeDraft(draft);
    }
  }

  Widget _accountingSummaryBox(String label, String value, Color color) {
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _accountingCollectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  List<String> _accountingAvailableSections() {
    final sections = _students
        .map(_studentSectionDisplay)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort(_compareAccountingSectionValues);
    return <String>['الكل', ...sections];
  }

  int _compareAccountingSectionValues(String first, String second) {
    if (first == second) return 0;
    if (first == '?') return -1;
    if (second == '?') return 1;
    final firstNumber = int.tryParse(first);
    final secondNumber = int.tryParse(second);
    if (firstNumber != null && secondNumber != null) {
      return firstNumber.compareTo(secondNumber);
    }
    return first.compareTo(second);
  }

  int _compareAccountingStudents(StudentRecord first, StudentRecord second) {
    final sectionCompare = _compareAccountingSectionValues(
      _studentSectionDisplay(first),
      _studentSectionDisplay(second),
    );
    if (sectionCompare != 0) {
      return sectionCompare;
    }
    return first.fullName.compareTo(second.fullName);
  }

  int _compareAccountingEntryMeta(int firstStudentId, String firstDate, int secondStudentId, String secondDate) {
    final firstStudent = _studentById(firstStudentId);
    final secondStudent = _studentById(secondStudentId);
    if (firstStudent != null && secondStudent != null) {
      final studentCompare = _compareAccountingStudents(firstStudent, secondStudent);
      if (studentCompare != 0) {
        return studentCompare;
      }
    }
    return secondDate.compareTo(firstDate);
  }

  bool _accountingMatchesFilters(int studentId) {
    final student = _studentById(studentId);
    if (student == null) {
      return false;
    }
    if (_accountingFilterStudentId != null && student.id != _accountingFilterStudentId) {
      return false;
    }
    if (_accountingSectionFilter != 'الكل' && _studentSectionDisplay(student) != _accountingSectionFilter) {
      return false;
    }
    return true;
  }

  List<StudentRecord> _accountingFilteredStudents() {
    final result = _students.where((student) {
      if (_accountingFilterStudentId != null && student.id != _accountingFilterStudentId) {
        return false;
      }
      if (_accountingSectionFilter != 'الكل' && _studentSectionDisplay(student) != _accountingSectionFilter) {
        return false;
      }
      return true;
    }).toList();
    result.sort(_compareAccountingStudents);
    return result;
  }

  List<AccountingInvoiceEntry> _filteredAccountingInvoices() {
    final result = _invoices.where((entry) => _accountingMatchesFilters(entry.studentId)).toList();
    result.sort((first, second) => _compareAccountingEntryMeta(first.studentId, first.date, second.studentId, second.date));
    return result;
  }

  List<AccountingDonationEntry> _filteredAccountingDonations() {
    final result = _accountingDonations.where((entry) => _accountingMatchesFilters(entry.studentId)).toList();
    result.sort((first, second) => _compareAccountingEntryMeta(first.studentId, first.date, second.studentId, second.date));
    return result;
  }

  List<AccountingAidEntry> _filteredAccountingAids() {
    final result = _accountingAids.where((entry) => _accountingMatchesFilters(entry.studentId)).toList();
    result.sort((first, second) => _compareAccountingEntryMeta(first.studentId, first.date, second.studentId, second.date));
    return result;
  }

  String _accountingScopeText(int studentCount) {
    final studentLabel = _accountingFilterStudentId == null
        ? 'كل الطلاب'
        : (_studentById(_accountingFilterStudentId!)?.fullName ?? 'طالب محدد');
    final sectionLabel = _accountingSectionFilter == 'الكل'
        ? 'كل الشعب'
        : 'الشعبة $_accountingSectionFilter';
    return '$studentLabel • $sectionLabel • عدد الطلاب الظاهرين: $studentCount';
  }

  Widget _accountingFilterCard({
    required String label,
    required Widget child,
    double width = 290,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FBFF)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1EBF3)),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.05), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _accountingTypeCard({
    required String id,
    required String title,
    required String subtitle,
    required int count,
    required String value,
    required Color accent,
    required Color soft,
    required IconData icon,
  }) {
    final active = _accountingView == id;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => setState(() => _accountingView = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 362,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: active
              ? LinearGradient(colors: <Color>[accent, accent.withOpacity(0.80)])
              : null,
          color: active ? null : Colors.white,
          border: Border.all(color: active ? accent : AppPalette.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: active ? accent.withOpacity(0.18) : const Color.fromRGBO(20, 40, 90, 0.06),
              blurRadius: active ? 22 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: active ? Colors.white.withOpacity(0.18) : soft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: active ? Colors.white : accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: active ? Colors.white : AppPalette.deepNavySoft,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: active ? Colors.white70 : AppPalette.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(active ? Icons.check_circle : Icons.chevron_left, color: active ? Colors.white : accent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? Colors.white.withOpacity(0.14) : const Color(0xFFF7FAFD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('عدد السجلات', style: TextStyle(color: active ? Colors.white70 : AppPalette.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('$count', style: TextStyle(color: active ? Colors.white : accent, fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? Colors.white.withOpacity(0.14) : const Color(0xFFF7FAFD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('القيمة / الملخص', style: TextStyle(color: active ? Colors.white70 : AppPalette.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(value, style: TextStyle(color: active ? Colors.white : accent, fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountingFocusedPanel({
    Key? key,
    required String title,
    required String subtitle,
    required Color accent,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(20, 40, 90, 0.06),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _accountingRecordTile({
    required StudentRecord student,
    required String title,
    required String subtitle,
    required String pillText,
    required Color accent,
    required Color soft,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FBFF)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.05), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 16)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.7)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _pill(student.fullName, const Color(0xFFF4F8FC), AppPalette.deepNavySoft),
                    _pill('الشعبة ${_studentSectionDisplay(student)}', const Color(0xFFEDF6FF), AppPalette.royalBlue),
                    _pill('الصف ${_studentGradeDisplay(student)}', const Color(0xFFF7F3EA), AppPalette.goldDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              pillText,
              style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAccountingInstallmentTiles(List<AccountingInvoiceEntry> entries) {
    return entries.map((entry) {
      final student = _studentById(entry.studentId);
      if (student == null) return const SizedBox.shrink();
      return _accountingRecordTile(
        student: student,
        title: entry.title,
        subtitle: 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date} • للقراءة فقط',
        pillText: 'قسط',
        accent: AppPalette.goldDark,
        soft: const Color(0xFFF7F3EA),
        icon: Icons.account_balance_wallet_outlined,
      );
    }).toList();
  }

  List<Widget> _buildAccountingPaymentTiles(List<AccountingReceiptEntry> entries) {
    return entries.map((entry) {
      final student = _studentById(entry.studentId);
      if (student == null) return const SizedBox.shrink();
      return _accountingRecordTile(
        student: student,
        title: entry.title,
        subtitle: 'المبلغ: ${entry.amount.toStringAsFixed(0)} ${entry.currency} • التاريخ: ${entry.date.isEmpty ? 'بدون تاريخ' : entry.date}${entry.note.isEmpty ? '' : ' • ${entry.note}'}',
        pillText: 'دفعة',
        accent: const Color(0xFF0F766E),
        soft: const Color(0xFFE8F8F5),
        icon: Icons.payments_outlined,
      );
    }).toList();
  }

  List<Widget> _buildAccountingDonationTiles(List<AccountingDonationEntry> entries) {
    return entries.map((entry) {
      final student = _studentById(entry.studentId);
      if (student == null) return const SizedBox.shrink();
      return _accountingRecordTile(
        student: student,
        title: _donationDisplayTitle(entry),
        subtitle: _donationDisplaySubtitle(entry),
        pillText: entry.donationKind,
        accent: AppPalette.royalBlue,
        soft: const Color(0xFFEDF6FF),
        icon: Icons.volunteer_activism_outlined,
      );
    }).toList();
  }

  List<Widget> _buildAccountingAidTiles(List<AccountingAidEntry> entries) {
    return entries.map((entry) {
      final student = _studentById(entry.studentId);
      if (student == null) return const SizedBox.shrink();
      return _accountingRecordTile(
        student: student,
        title: _aidDisplayTitle(entry),
        subtitle: _aidDisplaySubtitle(entry),
        pillText: entry.aidKind,
        accent: AppPalette.leafGreen,
        soft: const Color(0xFFE7F7EE),
        icon: Icons.favorite_outline,
      );
    }).toList();
  }

  Widget _accountingPageSection() {
    if (_students.isEmpty) {
      return Center(
        child: Container(
          width: 620,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppPalette.line),
          ),
          child: const Text(
            'لا يوجد طلاب بعد. أضف طالبًا أولًا لكي تظهر الأقساط والدفعات.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.muted, height: 1.8),
          ),
        ),
      );
    }

    final currentStudent = _selectedStudent ?? _students.first;
    final filteredStudents = _accountingFilteredStudents();
    final installmentEntries = _filteredAccountingInvoices();
    final donationEntries = _filteredAccountingDonations();
    final aidEntries = _filteredAccountingAids();
    final filteredStudentIds = filteredStudents.map((student) => student.id).toSet();
    final receiptEntries = _receipts.where((entry) => filteredStudentIds.contains(entry.studentId)).toList();
    final feesDue = filteredStudents.fold<double>(0, (sum, student) => sum + _sumFeeDue(student));
    final feesPaid = filteredStudents.fold<double>(0, (sum, student) => sum + _sumFeePaid(student));
    final installmentsTotal = installmentEntries.fold<double>(0, (sum, entry) => sum + entry.amount);
    final donationsTotal = donationEntries.where((entry) => entry.donationKind == 'مادية').fold<double>(0, (sum, entry) => sum + entry.amount);
    final receiptsTotal = receiptEntries.fold<double>(0, (sum, entry) => sum + entry.amount);
    final discountTotal = aidEntries.where((entry) => entry.aidKind == 'مادية').fold<double>(0, (sum, entry) => sum + entry.amount);
    final totalAmount = feesDue + installmentsTotal;
    final paidAmount = feesPaid + receiptsTotal + donationsTotal;
    final netAmount = totalAmount - discountTotal;
    final remainingAmount = netAmount - paidAmount;

    late final String focusedTitle;
    late final String focusedSubtitle;
    late final Color focusedAccent;
    late final IconData focusedIcon;
    late final List<Widget> focusedChildren;

    // donations/aids screens removed from this board.
    if (_accountingView == 'donations' || _accountingView == 'aids') {
      _accountingView = 'installments';
    }
    switch (_accountingView) {
      case 'payments':
        focusedTitle = 'شاشة الدفعات';
        focusedSubtitle = '${_accountingScopeText(filteredStudents.length)} • عرض ${receiptEntries.length} دفعة';
        focusedAccent = const Color(0xFF0F766E);
        focusedIcon = Icons.payments_outlined;
        focusedChildren = receiptEntries.isEmpty
            ? const <Widget>[Text('لا توجد دفعات ضمن الفرز الحالي. استخدم زر «دفعة» لإضافة دفعة.', style: TextStyle(color: AppPalette.muted))]
            : _buildAccountingPaymentTiles(receiptEntries);
        break;
      default:
        focusedTitle = 'شاشة الأقساط (قراءة فقط)';
        focusedSubtitle = '${_accountingScopeText(filteredStudents.length)} • عرض ${installmentEntries.length} سجلًا';
        focusedAccent = AppPalette.goldDark;
        focusedIcon = Icons.account_balance_wallet_outlined;
        focusedChildren = installmentEntries.isEmpty
            ? const <Widget>[Text('لا توجد أقساط مضافة ضمن الفرز الحالي.', style: TextStyle(color: AppPalette.muted))]
            : _buildAccountingInstallmentTiles(installmentEntries);
        break;
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '💰 الأقساط والدفعات',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('💵 قسط عادي', const Color(0xFFF7F3EA), AppPalette.goldDark, () {
                    setState(() => _accountingView = 'installments');
                    _showInstallmentPresetDialog(presetType: 'normal');
                  }),
                  _actionButton('💵🚌 قسط مع مواصلات', const Color(0xFFEDF6FF), AppPalette.royalBlue, () {
                    setState(() => _accountingView = 'installments');
                    _showInstallmentPresetDialog(presetType: 'transport');
                  }),
                  _actionButton('💵🚌🎁 قسط مع منحة مواصلات', const Color(0xFFE7F7EE), AppPalette.leafGreen, () {
                    setState(() => _accountingView = 'installments');
                    _showInstallmentPresetDialog(presetType: 'grant');
                  }),
                  _actionButton('💵 دفعة', const Color(0xFFE8F8F5), const Color(0xFF0F766E), () {
                    setState(() => _accountingView = 'payments');
                    _showStudentPaymentDialog();
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _accountingSummaryBox('المبلغ الكلي', totalAmount.toStringAsFixed(0), AppPalette.goldDark),
              _accountingSummaryBox('المتبقي', remainingAmount.toStringAsFixed(0), remainingAmount <= 0 ? AppPalette.royalBlue : AppPalette.roseRed),
              _accountingSummaryBox('المدفوع', paidAmount.toStringAsFixed(0), AppPalette.leafGreen),
              _accountingSummaryBox('الحسم', discountTotal.toStringAsFixed(0), AppPalette.royalBlue),
              _accountingSummaryBox('الصافي', netAmount.toStringAsFixed(0), AppPalette.deepNavySoft),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: <Color>[Color(0xFF1F335D), Color(0xFF123A78), Color(0xFF2F9A8E)]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.10), blurRadius: 16, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text('الأقساط والدفعات', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                            SizedBox(height: 6),
                            Text('تنسيق أحدث وأكثر انسيابية مع الحفاظ على نفس المعلومات الأساسية وربطها الكامل بالمحاسبة.', style: TextStyle(color: Colors.white70, height: 1.7)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(_accountingScopeText(filteredStudents.length), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _subSectionBanner(
                  'الأقساط والدفعات',
                  subtitle: 'الأقساط والدفعات فقط. كل قسط/دفعة يُرحَّل تلقائيًا للإيرادات. شاشات التبرعات/المساعدات أُزيلت من هذا الباب.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _accountingFilterCard(
                      label: 'الطالب المخصص للإضافة / الاستعراض',
                      child: DropdownButtonFormField<String>(
                        value: _accountingFilterStudentId?.toString() ?? 'all',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFBFDFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                        ),
                        items: <DropdownMenuItem<String>>[
                          const DropdownMenuItem<String>(value: 'all', child: Text('كل الطلاب')),
                          ..._students.map((student) => DropdownMenuItem<String>(value: student.id.toString(), child: Text(student.fullName))),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == 'all') {
                              _accountingFilterStudentId = null;
                            } else {
                              _accountingFilterStudentId = int.tryParse(value);
                              _accountingSectionFilter = 'الكل';
                              final selected = _studentById(_accountingFilterStudentId!);
                              if (selected != null) {
                                _loadStudent(selected);
                              }
                            }
                          });
                        },
                      ),
                    ),
                    _accountingFilterCard(
                      label: 'فرز حسب الشعبة',
                      child: DropdownButtonFormField<String>(
                        value: _accountingAvailableSections().contains(_accountingSectionFilter) ? _accountingSectionFilter : 'الكل',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFBFDFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                        ),
                        items: _accountingAvailableSections()
                            .map((section) => DropdownMenuItem<String>(value: section, child: Text(section == 'الكل' ? 'كل الشعب' : 'الشعبة $section')))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _accountingSectionFilter = value);
                          }
                        },
                      ),
                    ),
                    _accountingFilterCard(
                      label: 'الطالب النشط للإدخال',
                      child: Text(
                        currentStudent.fullName,
                        style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                    _accountingFilterCard(
                      label: 'ملخص الفرز الحالي',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_accountingScopeText(filteredStudents.length), style: const TextStyle(color: AppPalette.deepNavySoft, height: 1.7, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          _actionButton('إلغاء الفرز', Colors.white, const Color(0xFF667586), () {
                            setState(() {
                              _accountingFilterStudentId = null;
                              _accountingSectionFilter = 'الكل';
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: <Widget>[
                    _accountingTypeCard(
                      id: 'installments',
                      title: 'الأقساط',
                      subtitle: 'عرض فقط — بدون تعديل من المحاسبة.',
                      count: installmentEntries.length,
                      value: installmentsTotal.toStringAsFixed(0),
                      accent: AppPalette.goldDark,
                      soft: const Color(0xFFF7F3EA),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    _accountingTypeCard(
                      id: 'payments',
                      title: 'الدفعات',
                      subtitle: 'دفعات يضيفها المحاسب مباشرة لحساب الطالب.',
                      count: receiptEntries.length,
                      value: receiptsTotal.toStringAsFixed(0),
                      accent: const Color(0xFF0F766E),
                      soft: const Color(0xFFE8F8F5),
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _accountingFocusedPanel(
                    key: ValueKey<String>(_accountingView),
                    title: focusedTitle,
                    subtitle: focusedSubtitle,
                    accent: focusedAccent,
                    icon: focusedIcon,
                    children: focusedChildren,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> feeEntriesWidgets({required List<PaymentEntry> feeEntries}) {
    if (feeEntries.isEmpty) {
      return const <Widget>[Text('لا توجد دفعات رسوم مسجلة حتى الآن.', style: TextStyle(color: AppPalette.muted))];
    }
    return feeEntries.asMap().entries.map((entry) => _accountingFeeTile(entry.key + 1, entry.value)).toList();
  }

  Widget _accountingFeeTile(int number, PaymentEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppPalette.line)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('دفعة رسوم $number', style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 4),
                Text('المستحق: ${entry.dueAmount.isEmpty ? '0' : entry.dueAmount} • المقبوض: ${entry.paidAmount.isEmpty ? '0' : entry.paidAmount} • ${entry.currency}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountingEntryTile(String title, double amount, String currency, String date) {
    return _accountingEntryRichTile(title, '${amount.toStringAsFixed(0)} $currency • $date');
  }

  Widget _accountingEntryRichTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppPalette.line)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentsPageSection() {
    final student = _selectedStudent ?? _students.first;
    final docs = _attachments.where((item) => item.studentId == student.id).toList();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '📎 الوثائق والمرفقات',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('إضافة مرفق', AppPalette.goldDark, Colors.white, _showAddAttachmentDialog),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppPalette.line)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('اختيار الطالب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: student.id,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFBFDFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                          ),
                        ),
                        items: _students.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.fullName))).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final selected = _students.firstWhere((s) => s.id == value);
                          setState(() => _loadStudent(selected));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppPalette.line)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('وثائق ${student.fullName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                      const SizedBox(height: 12),
                      if (docs.isEmpty)
                        const Text('لا توجد مرفقات إضافية لهذا الطالب حتى الآن.', style: TextStyle(color: AppPalette.muted))
                      else
                        ...docs.map((doc) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppPalette.line),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${doc.category} • ${doc.originalFileName.isEmpty ? _fileStorage.fileNameFromPath(doc.storedPath) : doc.originalFileName}\n${doc.note.isEmpty ? 'بدون ملاحظة' : doc.note}\n${_fileStorage.fileExistsSync(doc.storedPath) ? 'محفوظ محليًا' : 'الملف غير موجود'} • ${doc.sizeBytes} بايت',
                                          style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteAttachment(doc),
                                    icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backupPageSection() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🗂️ النسخ الاحتياطي والاستعادة',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('إنشاء نسخة احتياطية الآن', AppPalette.goldDark, Colors.white, _createDemoBackup),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _summaryTile('عدد النسخ', _backups.length.toString(), AppPalette.goldDark),
              const SizedBox(width: 12),
              _summaryTile('عدد الطلاب الحالي', _students.length.toString(), AppPalette.royalBlue),
              const SizedBox(width: 12),
              _summaryTile('الحالة', 'محلي', AppPalette.leafGreen),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppPalette.line)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('قائمة النسخ الاحتياطية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                ..._backups.map((backup) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppPalette.line),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(backup.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                const SizedBox(height: 4),
                                Text('${backup.createdAt} • ملفات: ${backup.fileCount} • طلاب: ${backup.studentCount}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                                const SizedBox(height: 4),
                                Text(backup.note, style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 6,
                            children: <Widget>[
                              IconButton(
                                onPressed: () => _showSnack('تمت استعادة النسخة ${backup.name} (Demo).'),
                                icon: const Icon(Icons.restore, color: AppPalette.royalBlue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDemoAttachment() async {
    await _showAddAttachmentDialog();
  }

  void _createDemoBackup() {
    final now = DateTime.now();
    final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _backups.insert(0, BackupEntry(
        name: 'backup_demo_$stamp.zip',
        createdAt: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        fileCount: 150 + _attachments.length,
        studentCount: _students.length,
        note: 'نسخة تم إنشاؤها من داخل واجهة Flutter الفعلية.',
      ));
    });
    _showSnack('تم إنشاء نسخة احتياطية جديدة بنجاح.');
  }

  void _addDemoAttendance() {
    final student = _selectedStudent ?? _students.first;
    setState(() {
      _attendance.insert(
        0,
        AttendanceEntry(
          studentId: student.id,
          status: _attendanceStatus,
          date: _attendanceDateController.text.trim().isEmpty
              ? DateTime.now().toIso8601String().split('T').first
              : _attendanceDateController.text.trim(),
          note: _attendanceNoteController.text.trim().isEmpty
              ? 'تمت إضافته من داخل واجهة Flutter الفعلية (Demo).'
              : _attendanceNoteController.text.trim(),
        ),
      );
    });
    _attendanceNoteController.clear();
    _persistAll();
    _showSnack('تم تسجيل حالة الحضور/الغياب بنجاح.');
  }

  Widget _transportPageSection() {
    final groups = <String>['نعم', 'لا', 'معفى من رسوم النقل'];
    String titleFor(String value) {
      switch (value) {
        case 'نعم':
          return 'المشتركون بالمواصلات';
        case 'لا':
          return 'غير المشتركين';
        default:
          return 'المعفون من رسوم النقل';
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🚌 النقل المدرسي',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              _actionButton(
                'تحديث العرض',
                const Color(0xFFEDF6FF),
                const Color(0xFF24436F),
                () => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: groups.map((group) {
              final students = _students
                  .where((student) => student.transportSubscription == group)
                  .toList();
              return SizedBox(
                width: 420,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppPalette.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titleFor(group),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.deepNavySoft,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (students.isEmpty)
                        const Text(
                          'لا يوجد طلاب في هذه الفئة حاليًا.',
                          style: TextStyle(color: AppPalette.muted),
                        )
                      else
                        ...students.map((student) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppPalette.line),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          student.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppPalette.deepNavySoft,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'مكان الانتظار: ${_transportGatheringSummary(student)}\nالهاتف: ${student.mobile}${student.transportSubscription == 'نعم' && _transportAccountingEntries(student.id).isNotEmpty ? '\nتم تسديد رسوم النقل من باب المحاسبة' : ''}',
                                          style: const TextStyle(
                                            color: AppPalette.muted,
                                            fontSize: 11,
                                            height: 1.6,
                                          ),
                                        ),
                                        if (student.transportSubscription == 'نعم' && _transportAccountingEntries(student.id).isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE7F7EE),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'إشعار: تم تسجيل دفع رسوم النقل في باب المحاسبة.',
                                              style: TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800, fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  _statusChip(student.transportSubscription),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _messagesPageSection() {
    final student = _selectedStudent ?? _students.first;
    final messages = _messages
        .where((message) => message.studentId == student.id)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '✉️ مراسلات أولياء الأمور',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('إضافة مراسلة', AppPalette.goldDark, Colors.white, _showParentInvitationDialog),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'اختيار الطالب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
                const SizedBox(height: 12),
                _dropdownStudentPicker(student),
                const SizedBox(height: 16),
                if (messages.isEmpty)
                  const Text(
                    'لا توجد مراسلات لهذا الطالب حتى الآن.',
                    style: TextStyle(color: AppPalette.muted),
                  )
                else
                  ...messages.map((message) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.line),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    message.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppPalette.deepNavySoft,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${message.type} • ${message.date} • ${message.time.isEmpty ? 'بدون وقت' : message.time}\nسبب الدعوة: ${message.reason.isEmpty ? '-' : message.reason}\n${message.body}\n${message.guardianEmail.isEmpty ? '' : 'Email: ${message.guardianEmail}\n'}${message.guardianWhatsapp.isEmpty ? '' : 'WhatsApp: ${message.guardianWhatsapp}'}',
                                    style: const TextStyle(
                                      color: AppPalette.muted,
                                      fontSize: 11,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _messages.remove(message));
                                _showSnack('تم حذف المراسلة بنجاح.');
                              },
                              icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disciplinePageSection() {
    final student = _selectedStudent ?? _students.first;
    final entries = _discipline.where((entry) => entry.studentId == student.id).toList();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🏅 المكافآت والعقوبات',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('إضافة إجراء', AppPalette.goldDark, Colors.white, _addDemoDiscipline),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('اختيار الطالب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                _dropdownStudentPicker(student),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _dropdownField('نوع الإجراء', _disciplineType, const <String>['مكافأة', 'عقوبة'], (v) => setState(() => _disciplineType = v)),
                    _dateFieldCard('تاريخ الإجراء', _disciplineDateController),
                    _editableField('السبب', _disciplineTitleController),
                    _editableField('ملاحظة', _disciplineNoteController, span2: true, maxLines: 3),
                  ],
                ),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  const Text('لا توجد مكافآت أو عقوبات لهذا الطالب حتى الآن.', style: TextStyle(color: AppPalette.muted))
                else
                  ...entries.map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.line),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                  const SizedBox(height: 4),
                                  Text('${entry.type} • ${entry.date}\n${entry.note}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _discipline.remove(entry));
                                _showSnack('تم حذف الإجراء بنجاح.');
                              },
                              icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificatesPageSection() {
    final student = _selectedStudent ?? _students.first;
    final entries = _certificates.where((entry) => entry.studentId == student.id).toList();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '📜 الشهادات',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _actionButton('إضافة شهادة', AppPalette.goldDark, Colors.white, _addDemoCertificate),
                  _actionButton('تحديث القائمة', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => setState(() {})),
                  _actionButton('تصدير شهادة PDF', const Color(0xFFE7F7EE), AppPalette.leafGreen, _exportSelectedStudentCertificatePdf),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('اختيار الطالب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                _dropdownStudentPicker(student),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _dropdownField('نوع الشهادة', _certificateKind, const <String>['شهادة تقدير', 'شهادة مشاركة', 'بيان نجاح', 'شهادة أخرى'], (v) => setState(() => _certificateKind = v)),
                    if (_certificateKind == 'شهادة أخرى')
                      _editableField('تسمية الشهادة', _certificateTitleController),
                    _dateFieldCard('تاريخ الشهادة', _certificateDateController),
                    _editableField('عنوان الشهادة', _certificateTitleController),
                    _editableField('ملاحظة', _certificateNoteController, span2: true, maxLines: 3),
                  ],
                ),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  const Text('لا توجد شهادات لهذا الطالب حتى الآن.', style: TextStyle(color: AppPalette.muted))
                else
                  ...entries.map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.line),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                  const SizedBox(height: 4),
                                  Text('${entry.kind} • ${entry.date}\n${entry.note}', style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6)),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'تصدير PDF',
                              onPressed: () => _exportCertificatePdf(student, entry),
                              icon: const Icon(Icons.picture_as_pdf_outlined, color: AppPalette.leafGreen),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _certificates.remove(entry));
                                _showSnack('تم حذف الشهادة بنجاح.');
                              },
                              icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showAttendanceExportDialog({required bool asPdf}) async {
    final current = _selectedStudent ?? (_students.isEmpty ? null : _students.first);
    if (current == null) {
      _showSnack('لا يوجد طلاب لتصدير الحضور.');
      return;
    }
    String mode = 'student'; // student | class
    String selectedGrade = _studentGradeDisplay(current);
    String selectedSection = _studentSectionDisplay(current);
    int selectedStudentId = current.id;
    final grades = _studentGradeOptions();
    if (!grades.contains(selectedGrade) && grades.isNotEmpty) selectedGrade = grades.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final sections = <String>{'الكل'};
            for (final s in _students) {
              if (_studentGradeDisplay(s) == selectedGrade) {
                sections.add(_studentSectionDisplay(s));
              }
            }
            final sectionList = sections.toList();
            if (!sectionList.contains(selectedSection)) selectedSection = 'الكل';
            final studentsForPick = _students.where((s) {
              final g = _studentGradeDisplay(s) == selectedGrade;
              final sec = selectedSection == 'الكل' || _studentSectionDisplay(s) == selectedSection;
              return g && sec;
            }).toList();
            if (studentsForPick.isNotEmpty && !studentsForPick.any((s) => s.id == selectedStudentId)) {
              selectedStudentId = studentsForPick.first.id;
            }

            return AlertDialog(
              title: Text(asPdf ? 'تصدير الحضور PDF' : 'تصدير الحضور Excel'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: mode,
                      decoration: const InputDecoration(labelText: 'نطاق التصدير'),
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('طالب محدد')),
                        DropdownMenuItem(value: 'class', child: Text('صف وشعبة')),
                      ],
                      onChanged: (v) => setDialogState(() => mode = v ?? 'student'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: grades.contains(selectedGrade) ? selectedGrade : (grades.isEmpty ? null : grades.first),
                      decoration: const InputDecoration(labelText: 'الصف'),
                      items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setDialogState(() {
                        selectedGrade = v ?? selectedGrade;
                        selectedSection = 'الكل';
                      }),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSection,
                      decoration: const InputDecoration(labelText: 'الشعبة'),
                      items: sectionList.map((s) => DropdownMenuItem(value: s, child: Text(s == 'الكل' ? 'كل الشعب' : s))).toList(),
                      onChanged: (v) => setDialogState(() => selectedSection = v ?? 'الكل'),
                    ),
                    if (mode == 'student') ...<Widget>[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: selectedStudentId,
                        decoration: const InputDecoration(labelText: 'الطالب'),
                        items: studentsForPick.map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName))).toList(),
                        onChanged: (v) => setDialogState(() => selectedStudentId = v ?? selectedStudentId),
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _exportAttendance(
                      asPdf: asPdf,
                      mode: mode,
                      grade: selectedGrade,
                      section: selectedSection,
                      studentId: selectedStudentId,
                    );
                  },
                  child: const Text('تصدير'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportAttendance({
    required bool asPdf,
    required String mode,
    required String grade,
    required String section,
    required int studentId,
  }) async {
    List<StudentRecord> students;
    String scopeLabel;
    if (mode == 'student') {
      final student = _studentById(studentId) ?? _selectedStudent ?? _students.first;
      students = <StudentRecord>[student];
      scopeLabel = 'طالب_${student.fullName}';
    } else {
      students = _students.where((s) {
        final gOk = _studentGradeDisplay(s) == grade;
        final sOk = section == 'الكل' || _studentSectionDisplay(s) == section;
        return gOk && sOk;
      }).toList();
      scopeLabel = 'صف_${grade}_شعبة_${section}';
    }

    final rows = <Map<String, String>>[];
    for (final student in students) {
      final entries = _attendance.where((e) => e.studentId == student.id).toList();
      if (entries.isEmpty) {
        rows.add({
          'student': student.fullName,
          'serial': student.serial,
          'grade': _studentGradeDisplay(student),
          'section': _studentSectionDisplay(student),
          'status': '-',
          'date': '-',
          'note': 'لا سجلات',
        });
      } else {
        for (final entry in entries) {
          rows.add({
            'student': student.fullName,
            'serial': student.serial,
            'grade': _studentGradeDisplay(student),
            'section': _studentSectionDisplay(student),
            'status': entry.status,
            'date': entry.date,
            'note': entry.note,
          });
        }
      }
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final reports = await AppStoragePathsService.instance.reportsDir;
    if (asPdf) {
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => pw.Column(children: [
            pw.Text('مدرسة روز التعليمية', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('تقرير الحضور والغياب • $scopeLabel', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
          ]),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('مشرف القسم: ${_supervisorNameController.text.isEmpty ? 'مشرف القسم' : _supervisorNameController.text}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('صفحة ${context.pageNumber}/${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('مدير المدرسة: ${_principalNameController.text.isEmpty ? 'مدير المدرسة' : _principalNameController.text}', style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          build: (context) => <pw.Widget>[
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: 0.4),
              children: <pw.TableRow>[
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: <String>['الطالب', 'التسلسل', 'الصف', 'الشعبة', 'الحالة', 'التاريخ', 'ملاحظة']
                      .map((h) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))))
                      .toList(),
                ),
                ...rows.map((r) => pw.TableRow(
                      children: <String>[r['student']!, r['serial']!, r['grade']!, r['section']!, r['status']!, r['date']!, r['note']!]
                          .map((c) => pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c, style: const pw.TextStyle(fontSize: 8))))
                          .toList(),
                    )),
              ],
            ),
          ],
        ),
      );
      final bytes = await doc.save();
      final filePath = p.join(reports.path, 'attendance_${mode}_$stamp.pdf');
      await File(filePath).writeAsBytes(bytes, flush: true);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'attendance_$mode.pdf');
      _showSnack('تم تصدير PDF الحضور: $filePath');
    } else {
      final buffer = StringBuffer();
      buffer.writeln('الطالب,التسلسل,الصف,الشعبة,الحالة,التاريخ,ملاحظة');
      for (final r in rows) {
        buffer.writeln('"${r['student']}","${r['serial']}","${r['grade']}","${r['section']}","${r['status']}","${r['date']}","${r['note']}"');
      }
      final filePath = p.join(reports.path, 'attendance_${mode}_$stamp.csv');
      await File(filePath).writeAsString(buffer.toString(), flush: true);
      _showSnack('تم تصدير Excel/CSV الحضور: $filePath');
    }
  }


  Future<void> _exportSelectedStudentCertificatePdf() async {
    final student = _selectedStudent ?? (_students.isEmpty ? null : _students.first);
    if (student == null) {
      _showSnack('لا يوجد طالب.');
      return;
    }
    final entries = _certificates.where((e) => e.studentId == student.id).toList();
    if (entries.isEmpty) {
      _showSnack('لا توجد شهادات لهذا الطالب.');
      return;
    }
    await _exportCertificatePdf(student, entries.first);
  }

  Future<void> _exportCertificatePdf(StudentRecord student, CertificateEntry entry) async {
    final schoolName = 'مدرسة روز التعليمية';
    final supervisor = _supervisorNameController.text.trim().isEmpty ? 'مشرف القسم' : _supervisorNameController.text.trim();
    final manager = _principalNameController.text.trim().isEmpty
        ? (_secretaryNameController.text.trim().isEmpty ? 'مدير المدرسة' : _secretaryNameController.text.trim())
        : _principalNameController.text.trim();

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: <pw.Widget>[
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(16),
                  border: pw.Border.all(color: PdfColors.blueGrey200),
                ),
                child: pw.Column(
                  children: <pw.Widget>[
                    pw.Text(schoolName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('شهادة رسمية', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 28),
              pw.Center(child: pw.Text(entry.kind, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text(entry.title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 24),
              pw.Text('تُمنح هذه الشهادة إلى الطالب/ة: ${student.fullName}', style: const pw.TextStyle(fontSize: 13)),
              pw.SizedBox(height: 8),
              pw.Text('الصف: ${_studentGradeDisplay(student)}    الشعبة: ${_studentSectionDisplay(student)}', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Text('التاريخ: ${entry.date}', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 16),
              pw.Text(entry.note.isEmpty ? 'مع تمنياتنا بالتوفيق.' : entry.note, style: const pw.TextStyle(fontSize: 12)),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: <pw.Widget>[
                    pw.Text('مشرف القسم', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.SizedBox(height: 6),
                    pw.Text(supervisor, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 16),
                    pw.Container(width: 120, height: 1, color: PdfColors.grey600),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: <pw.Widget>[
                    pw.Text('مدير المدرسة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.SizedBox(height: 6),
                    pw.Text(manager, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 16),
                    pw.Container(width: 120, height: 1, color: PdfColors.grey600),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    final reports = await AppStoragePathsService.instance.reportsDir;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(reports.path, 'certificate_${student.id}_$stamp.pdf');
    await File(filePath).writeAsBytes(bytes, flush: true);
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'certificate_${student.fullName}.pdf');
    _showSnack('تم تصدير الشهادة PDF: $filePath');
  }

  Future<void> _showManageExamSubjectsDialog(StudentRecord student) async {
    // Avoid DropdownButton onChanged -> Navigator.pop (causes framework
    // assertion: '_dependents.isEmpty': is not true when overlay is still open).
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final subjects = _examSubjectsForStudent(student);

            Future<void> runRenameOrDelete(String action) async {
              if (subjects.isEmpty) {
                if (mounted) {
                  _showSnack('لا توجد مواد حالياً.');
                }
                return;
              }

              String selected = subjects.first;
              final nameController = TextEditingController(text: selected);
              try {
                final ok = await showDialog<bool>(
                  context: dialogContext,
                  builder: (ctx) {
                    return StatefulBuilder(
                      builder: (context, setLocal) {
                        return AlertDialog(
                          title: Text(action == 'rename' ? 'تعديل اسم مادة' : 'حذف مادة'),
                          content: SizedBox(
                            width: 420,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DropdownButtonFormField<String>(
                                  value: selected,
                                  decoration: const InputDecoration(labelText: 'المادة'),
                                  items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setLocal(() {
                                      selected = v;
                                      nameController.text = v;
                                    });
                                  },
                                ),
                                if (action == 'rename') ...<Widget>[
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(labelText: 'الاسم الجديد'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(action == 'rename' ? 'حفظ' : 'حذف'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
                if (ok != true) {
                  return;
                }

                if (action == 'rename') {
                  final newName = nameController.text.trim();
                  if (newName.isEmpty) {
                    if (mounted) {
                      _showSnack('الاسم الجديد مطلوب.');
                    }
                    return;
                  }
                  if (newName != selected && subjects.contains(newName)) {
                    if (mounted) {
                      _showSnack('الاسم الجديد موجود مسبقاً.');
                    }
                    return;
                  }
                  setState(() {
                    final idx = _customExamSubjects.indexOf(selected);
                    if (idx >= 0) {
                      _customExamSubjects[idx] = newName;
                    } else if (!_customExamSubjects.contains(newName)) {
                      _customExamSubjects = <String>[..._customExamSubjects, newName];
                    }
                    for (var i = 0; i < _examResults.length; i++) {
                      final r = _examResults[i];
                      if (r.studentId == student.id && r.subject == selected) {
                        _examResults[i] = ExamResultEntry(
                          studentId: r.studentId,
                          subject: newName,
                          firstTermWork: r.firstTermWork,
                          firstTermExam: r.firstTermExam,
                          secondTermWork: r.secondTermWork,
                          secondTermExam: r.secondTermExam,
                          isManuallyReviewed: r.isManuallyReviewed,
                        );
                      }
                    }
                    for (var i = 0; i < _examSchedule.length; i++) {
                      final s = _examSchedule[i];
                      if (s.title == selected) {
                        _examSchedule[i] = ExamScheduleEntry(
                          title: newName,
                          grade: s.grade,
                          examDate: s.examDate,
                          period: s.period,
                          hall: s.hall,
                        );
                      }
                    }
                  });
                  await _persistAll();
                  if (!mounted) {
                    return;
                  }
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                  _showSnack('تم تعديل اسم المادة إلى "$newName".');
                } else {
                  setState(() {
                    _customExamSubjects = _customExamSubjects.where((s) => s != selected).toList();
                    _examResults.removeWhere((r) => r.studentId == student.id && r.subject == selected);
                    _examSchedule.removeWhere((s) => s.title == selected);
                  });
                  await _persistAll();
                  if (!mounted) {
                    return;
                  }
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                  _showSnack('تم حذف المادة "$selected" ونتائجها المرتبطة.');
                }
              } finally {
                nameController.dispose();
              }
            }

            Future<void> runAddSubject() async {
              // Close parent first, then open add dialog on the next frame so
              // any open dropdown/route overlay finishes disposing cleanly.
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              await Future<void>.delayed(Duration.zero);
              if (!mounted) {
                return;
              }
              await _showAddExamSubjectDialog(student);
            }

            return AlertDialog(
              title: const Text('إدارة المواد'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'المواد الحالية: ${subjects.length}',
                        style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _actionButton('إضافة مادة', AppPalette.goldDark, Colors.white, () {
                          // Schedule after the current pointer/gesture frame.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            runAddSubject();
                          });
                        }),
                        _actionButton('تعديل اسم', const Color(0xFFEDF6FF), const Color(0xFF24436F), () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            runRenameOrDelete('rename');
                          });
                        }),
                        _actionButton('حذف مادة', const Color(0xFFFFF1F1), AppPalette.roseRed, () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            runRenameOrDelete('delete');
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 220,
                      child: subjects.isEmpty
                          ? const Center(
                              child: Text('لا توجد مواد حالياً.', style: TextStyle(color: AppPalette.muted)),
                            )
                          : ListView.builder(
                              itemCount: subjects.length,
                              itemBuilder: (context, index) {
                                final subject = subjects[index];
                                final isCustom = _customExamSubjects.contains(subject);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBFDFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppPalette.line),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          subject,
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                                        ),
                                      ),
                                      Text(
                                        isCustom ? 'مخصصة' : 'أساسية',
                                        style: TextStyle(
                                          color: isCustom ? AppPalette.goldDark : AppPalette.muted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddExamSubjectDialog(StudentRecord student) async {
    _newExamSubjectController.text = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('➕ إضافة مادة جديدة'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: _newExamSubjectController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'اسم المادة',
                hintText: 'مثال: الروبوتات',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_newExamSubjectController.text.trim()),
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
    final name = (result ?? '').trim();
    if (name.isEmpty) return;
    if (_examSubjectsForStudent(student).contains(name) || _customExamSubjects.contains(name)) {
      _showSnack('المادة موجودة مسبقًا ضمن الخيارات.');
      return;
    }
    setState(() {
      _customExamSubjects = <String>[..._customExamSubjects, name];
    });
    await _persistAll();
    _showSnack('تمت إضافة المادة "$name" وستظهر ضمن خيارات وخصائص باقي المواد.');
  }


  Future<void> _showParentInvitationDialog() async {
    final initialStudent = _selectedStudent ?? _students.first;
    var selectedStudentId = initialStudent.id;
    void syncGuardianFields(StudentRecord currentStudent) {
      _guardianEmailController.text = currentStudent.guardianEmail;
      _guardianWhatsappController.text = currentStudent.guardianWhatsapp;
    }

    _messageType = 'مراسلة الكترونية';
    _messageReasonController.clear();
    _messageDateController.text = DateTime.now().toIso8601String().split('T').first;
    _messageTimeController.text = '10:00';
    _messageBodyController.clear();
    syncGuardianFields(initialStudent);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentStudent = _students.firstWhere((student) => student.id == selectedStudentId);
            return AlertDialog(
              title: const Text('دعوة ولي / أولياء الأمور'),
              content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('نوع المراسلة', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <String>['مراسلة الكترونية', 'مراسلة ورقية'].map((option) {
                          final active = _messageType == option;
                          return InkWell(
                            onTap: () => setDialogState(() => _messageType = option),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: active ? AppPalette.goldDark : const Color(0xFFEDF5FB),
                                border: Border.all(color: active ? AppPalette.goldDark : const Color(0xFFD8E7F4)),
                              ),
                              child: Text(option, style: TextStyle(color: active ? Colors.white : const Color(0xFF29446F), fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        value: selectedStudentId,
                        decoration: const InputDecoration(labelText: 'اختيار الطالب'),
                        items: _students.map((student) => DropdownMenuItem<int>(value: student.id, child: Text(student.fullName))).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedStudentId = value;
                            syncGuardianFields(_students.firstWhere((student) => student.id == value));
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: _messageReasonController, decoration: const InputDecoration(labelText: 'سبب الدعوة')),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(child: TextField(controller: _messageDateController, decoration: const InputDecoration(labelText: 'التاريخ'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: _messageTimeController, decoration: const InputDecoration(labelText: 'الساعة'))),
                        ],
                      ),
                      if (_messageType == 'مراسلة الكترونية') ...<Widget>[
                        const SizedBox(height: 12),
                        TextField(controller: _guardianEmailController, decoration: const InputDecoration(labelText: 'ايميل ولي الأمر')),
                        const SizedBox(height: 12),
                        TextField(controller: _guardianWhatsappController, decoration: const InputDecoration(labelText: 'رقم وتس الاب لولي الأمر')),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _messageBodyController,
                        maxLines: 4,
                        onTap: () => _clearNoteFieldOnFirstTap(_messageBodyController),
                        decoration: const InputDecoration(labelText: 'مضمون الدعوة'),
                      ),
                      if (_messageType == 'مراسلة ورقية') ...<Widget>[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppPalette.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.asset('image/logo.jpg', width: 46, height: 46, fit: BoxFit.cover),
                                  const SizedBox(width: 12),
                                  const Expanded(child: Text('مدرسة روز التعليمية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppPalette.deepNavySoft))),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text('دعوة ولي / أولياء الأمور', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              const SizedBox(height: 10),
                              Text('الطالب: ${currentStudent.fullName}'),
                              Text('سبب الدعوة: ${_messageReasonController.text.isEmpty ? '-' : _messageReasonController.text}'),
                              Text('التاريخ: ${_messageDateController.text.isEmpty ? '-' : _messageDateController.text}    الساعة: ${_messageTimeController.text.isEmpty ? '-' : _messageTimeController.text}'),
                              const SizedBox(height: 10),
                              Text(_messageBodyController.text.isEmpty ? 'يرجى مراجعة إدارة المدرسة.' : _messageBodyController.text, style: const TextStyle(height: 1.7)),
                              const SizedBox(height: 22),
                              Row(
                                children: const <Widget>[
                                  Expanded(child: Text('الخاتم', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700))),
                                  Expanded(child: Text('التوقيع', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _messages.insert(0, ParentMessageEntry(
                        studentId: currentStudent.id,
                        type: _messageType,
                        subject: 'دعوة ولي / أولياء الأمور',
                        body: _messageBodyController.text.trim().isEmpty ? 'يرجى مراجعة إدارة المدرسة.' : _messageBodyController.text.trim(),
                        date: _messageDateController.text.trim(),
                        time: _messageTimeController.text.trim(),
                        reason: _messageReasonController.text.trim(),
                        guardianEmail: _guardianEmailController.text.trim(),
                        guardianWhatsapp: _guardianWhatsappController.text.trim(),
                      ));
                    });
                    _persistAll();
                    Navigator.pop(dialogContext);
                    _showSnack('تم إرسال المراسلة بنجاح.');
                  },
                  child: const Text('إرسال'),
                ),
                TextButton(
                  onPressed: () {
                    _showSnack('تم تجهيز الدعوة للطباعة.');
                  },
                  child: const Text('طباعة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addDemoDiscipline() {
    final student = _selectedStudent ?? _students.first;
    setState(() {
      _discipline.insert(
        0,
        DisciplineEntry(
          studentId: student.id,
          type: _disciplineType,
          title: _disciplineTitleController.text.trim().isEmpty ? 'إجراء جديد' : _disciplineTitleController.text.trim(),
          note: _disciplineNoteController.text.trim().isEmpty ? 'تمت إضافته من داخل Flutter.' : _disciplineNoteController.text.trim(),
          date: _disciplineDateController.text.trim().isEmpty ? DateTime.now().toIso8601String().split('T').first : _disciplineDateController.text.trim(),
        ),
      );
    });
    _disciplineTitleController.clear();
    _disciplineNoteController.clear();
    _showSnack('تمت إضافة الإجراء بنجاح.');
  }

  void _addDemoCertificate() {
    final student = _selectedStudent ?? _students.first;
    setState(() {
      _certificates.insert(
        0,
        CertificateEntry(
          studentId: student.id,
          title: _certificateTitleController.text.trim().isEmpty ? 'شهادة جديدة' : _certificateTitleController.text.trim(),
          kind: _certificateKind,
          date: _certificateDateController.text.trim().isEmpty ? DateTime.now().toIso8601String().split('T').first : _certificateDateController.text.trim(),
          note: _certificateNoteController.text.trim().isEmpty ? 'تمت إضافتها من داخل Flutter.' : _certificateNoteController.text.trim(),
        ),
      );
    });
    _certificateTitleController.clear();
    _certificateNoteController.clear();
    _persistAll();
    _showSnack('تمت إضافة الشهادة بنجاح.');
  }

  void _addDemoInvoice() {
    final student = _selectedStudent ?? _students.first;
    setState(() {
      _invoices.insert(
        0,
        AccountingInvoiceEntry(
          studentId: student.id,
          title: _invoiceTitleController.text.trim().isEmpty ? 'فاتورة جديدة' : _invoiceTitleController.text.trim(),
          amount: double.tryParse(_invoiceAmountController.text.trim()) ?? 0,
          currency: _invoiceCurrency,
          date: _invoiceDateController.text.trim().isEmpty ? DateTime.now().toIso8601String().split('T').first : _invoiceDateController.text.trim(),
        ),
      );
    });
    _invoiceTitleController.clear();
    _invoiceAmountController.clear();
    _persistAll();
    _showSnack('تمت إضافة الفاتورة بنجاح.');
  }

  void _addDemoReceipt() {
    final student = _selectedStudent ?? _students.first;
    setState(() {
      _receipts.insert(
        0,
        AccountingReceiptEntry(
          studentId: student.id,
          title: _receiptTitleController.text.trim().isEmpty ? 'مقبوض جديد' : _receiptTitleController.text.trim(),
          amount: double.tryParse(_receiptAmountController.text.trim()) ?? 0,
          currency: _receiptCurrency,
          date: _receiptDateController.text.trim().isEmpty ? DateTime.now().toIso8601String().split('T').first : _receiptDateController.text.trim(),
          note: _receiptNoteController.text.trim().isEmpty ? 'تمت إضافته من داخل Flutter.' : _receiptNoteController.text.trim(),
        ),
      );
    });
    _receiptTitleController.clear();
    _receiptAmountController.clear();
    _receiptNoteController.clear();
    _persistAll();
    _showSnack('تمت إضافة المقبوض بنجاح.');
  }

  // ===================== Exam cycles / stages =====================
  // cycle1: grades 1-4
  // cycle2: grades 5-6
  // prep: grades 7-9
  // secondary_literary / secondary_scientific: grades 10-12

  static const String kExamCycle1 = 'cycle1';
  static const String kExamCycle2 = 'cycle2';
  static const String kExamCyclePrep = 'prep';
  static const String kExamCycleSecondaryLiterary = 'secondary_literary';
  static const String kExamCycleSecondaryScientific = 'secondary_scientific';

  String _examCycleLabel(String cycleId) {
    switch (cycleId) {
      case kExamCycle1:
        return 'الحلقة الأولى (1 - 2 - 3 - 4)';
      case kExamCycle2:
        return 'الحلقة الثانية (5 - 6)';
      case kExamCyclePrep:
        return 'المرحلة الإعدادية (7 - 8 - 9)';
      case kExamCycleSecondaryLiterary:
        return 'المرحلة الثانوية - الأدبي (10 - 11 - 12)';
      case kExamCycleSecondaryScientific:
        return 'المرحلة الثانوية - العلمي (10 - 11 - 12)';
      default:
        return cycleId;
    }
  }

  List<MapEntry<String, String>> get _examCycleOptions => <MapEntry<String, String>>[
        MapEntry(kExamCycle1, _examCycleLabel(kExamCycle1)),
        MapEntry(kExamCycle2, _examCycleLabel(kExamCycle2)),
        MapEntry(kExamCyclePrep, _examCycleLabel(kExamCyclePrep)),
        MapEntry(kExamCycleSecondaryLiterary, _examCycleLabel(kExamCycleSecondaryLiterary)),
        MapEntry(kExamCycleSecondaryScientific, _examCycleLabel(kExamCycleSecondaryScientific)),
      ];

  /// Normalize Arabic grade text into a number when possible.
  int _studentGradeNumber(StudentRecord student) {
    final raw = '${student.enrollmentGrade} ${student.grade} ${_studentGradeDisplay(student)}'.trim();
    // Prefer standalone grade digits 1..12 first.
    final allDigits = RegExp(r'(?<!\d)(1[0-2]|[1-9])(?!\d)').allMatches(raw).toList();
    if (allDigits.isNotEmpty) {
      // enrollmentGrade is usually short and reliable; try it alone first.
      final enrollmentOnly = RegExp(r'^(1[0-2]|[1-9])$').firstMatch(student.enrollmentGrade.trim());
      if (enrollmentOnly != null) {
        return int.parse(enrollmentOnly.group(1)!);
      }
      return int.parse(allDigits.first.group(1)!);
    }

    const words = <String, int>{
      'الحادي عشر': 11,
      'الثاني عشر': 12,
      'الاول': 1,
      'الأول': 1,
      'الثاني': 2,
      'الثالث': 3,
      'الرابع': 4,
      'الخامس': 5,
      'السادس': 6,
      'السابع': 7,
      'الثامن': 8,
      'التاسع': 9,
      'العاشر': 10,
    };
    // Longer keys first.
    final ordered = words.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    final normalized = raw
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');
    for (final entry in ordered) {
      final key = entry.key.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
      if (normalized.contains(key)) {
        return entry.value;
      }
    }
    return 0;
  }

  bool _studentIsScientificTrack(StudentRecord student) {
    final raw = '${student.grade} ${student.enrollmentGrade} ${_studentGradeDisplay(student)}'.toLowerCase();
    return raw.contains('علمي') || raw.contains('scientific') || raw.contains('science');
  }

  bool _studentIsLiteraryTrack(StudentRecord student) {
    final raw = '${student.grade} ${student.enrollmentGrade} ${_studentGradeDisplay(student)}'.toLowerCase();
    return raw.contains('ادبي') || raw.contains('أدبي') || raw.contains('literary') || raw.contains('ادبية') || raw.contains('أدبية');
  }

  String _detectExamCycleForStudent(StudentRecord student) {
    final n = _studentGradeNumber(student);
    if (n >= 1 && n <= 4) return kExamCycle1;
    if (n == 5 || n == 6) return kExamCycle2;
    if (n >= 7 && n <= 9) return kExamCyclePrep;
    if (n >= 10 && n <= 12) {
      if (_studentIsLiteraryTrack(student)) return kExamCycleSecondaryLiterary;
      return kExamCycleSecondaryScientific; // default scientific for 10-12
    }
    // Fallbacks when grade number is unknown.
    if (_studentIsLiteraryTrack(student)) return kExamCycleSecondaryLiterary;
    if (_studentIsScientificTrack(student)) return kExamCycleSecondaryScientific;
    final g = student.grade;
    if (g.contains('سابع') || g.contains('ثامن') || g.contains('تاسع')) return kExamCyclePrep;
    if (g.contains('خامس') || g.contains('سادس')) return kExamCycle2;
    if (g.contains('اول') || g.contains('أول') || g.contains('ثاني') || g.contains('ثالث') || g.contains('رابع')) {
      return kExamCycle1;
    }
    return kExamCyclePrep;
  }

  String _activeExamCycleForStudent(StudentRecord student) {
    return _examCycleOverride ?? _detectExamCycleForStudent(student);
  }

  bool _isMiddleCycleGrade(StudentRecord student) => _activeExamCycleForStudent(student) == kExamCyclePrep;
  bool _isUpperPrimaryGrade(StudentRecord student) => _activeExamCycleForStudent(student) == kExamCycle2;
  bool _isLowerPrimaryGrade(StudentRecord student) => _activeExamCycleForStudent(student) == kExamCycle1;

  List<String> _subjectsForExamCycle(String cycleId) {
    switch (cycleId) {
      case kExamCycle1:
        // Grades 1-4 official form.
        return <String>[
          'أنشطة',
          'اجتماعيات',
          'التربية الدينية',
          'التربية الرياضية',
          'التربية الموسيقية',
          'الرياضيات',
          'العلوم والتربية الصحية',
          'الفنون الجمالية',
          'اللغة الإنكليزية',
          'مهارات شفوية',
          'مهارات كتابية',
        ];
      case kExamCycle2:
        // Grades 5-6 official form.
        return <String>[
          'اجتماعيات',
          'التربية الدينية',
          'التربية الرياضية',
          'التربية الموسيقية',
          'الرياضيات',
          'العلوم والتربية الصحية',
          'الفنون الجمالية',
          'اللغة الإنكليزية',
          'سلوك',
          'مهارات شفوية',
          'مهارات كتابية',
        ];
      case kExamCyclePrep:
        // Grades 7-9 official form.
        return <String>[
          'اجتماعيات',
          'التربية الدينية',
          'التربية الرياضية',
          'التربية الموسيقية',
          'الرياضيات',
          'العلوم العامة',
          'الفنون الجمالية',
          'اللغة الأجنبية',
          'اللغة الإنكليزية',
          'اللغة العربية',
          'تكنلوجيا المعلومات والاتصالات',
          'سلوك',
        ];
      case kExamCycleSecondaryLiterary:
        return <String>[
          'اللغة العربية',
          'اللغة الإنكليزية',
          'اللغة الفرنسية',
          'التاريخ',
          'الجغرافيا',
          'الفلسفة',
          'التربية الدينية',
          'الوطنية',
          'المعلوماتية',
          'التربية الرياضية',
        ];
      case kExamCycleSecondaryScientific:
        return <String>[
          'اللغة العربية',
          'اللغة الإنكليزية',
          'اللغة الفرنسية',
          'الرياضيات',
          'الفيزياء',
          'الكيمياء',
          'علم الأحياء',
          'التربية الدينية',
          'الوطنية',
          'المعلوماتية',
          'التربية الرياضية',
        ];
      default:
        return _subjectsForExamCycle(kExamCyclePrep);
    }
  }

  List<String> _defaultSubjectsForStudent(StudentRecord student) {
    return _subjectsForExamCycle(_activeExamCycleForStudent(student));
  }

  void _appendExamSubject(List<String> subjects, String subject) {
    final trimmed = subject.trim();
    if (trimmed.isEmpty || subjects.contains(trimmed)) {
      return;
    }
    subjects.add(trimmed);
  }

  List<ExamResultEntry> _studentExamResults(int studentId) {
    return _examResults.where((entry) => entry.studentId == studentId).toList();
  }

  /// Official subjects only for the active cycle of this student.
  /// Custom subjects are optional extras and do not replace the official model.
  List<String> _examSubjectsForStudent(StudentRecord student, {bool includeExtras = false}) {
    final subjects = <String>[..._defaultSubjectsForStudent(student)];
    if (!includeExtras) {
      return subjects;
    }
    for (final subject in _customExamSubjects) {
      _appendExamSubject(subjects, subject);
    }
    return subjects;
  }

  ExamResultEntry _examResultForStudentSubject(StudentRecord student, String subject) {
    final index = _examResults.indexWhere((entry) => entry.studentId == student.id && entry.subject == subject);
    if (index >= 0) {
      return _examResults[index];
    }
    return ExamResultEntry(
      studentId: student.id,
      subject: subject,
      firstTermWork: 0,
      firstTermExam: 0,
      secondTermWork: 0,
      secondTermExam: 0,
      isManuallyReviewed: false,
    );
  }

  String _formatExamNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _normalizeSubjectKey(String subject) {
    return subject
        .trim()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }

  /// Official marks for grades 1 / 2 / 3 / 4 (same scale for all four).
  /// From the attached school report form: max total 1100, min total 451.
  Map<String, double>? _lowerPrimaryOfficialMarks(String subject) {
    final key = _normalizeSubjectKey(subject);
    bool has(String part) => key.contains(_normalizeSubjectKey(part));

    // All subjects on the 1-4 official form are max 100 / min 41.
    if (has('انشط') || has('أنشط')) return const <String, double>{'min': 41, 'max': 100};
    if (has('مهارات شفوي') || (has('مهارات') && has('شفو'))) {
      return const <String, double>{'min': 41, 'max': 100};
    }
    if (has('مهارات كتاب') || (has('مهارات') && has('كتاب'))) {
      return const <String, double>{'min': 41, 'max': 100};
    }
    if (has('اجتماع') || has('دراسات')) return const <String, double>{'min': 41, 'max': 100};
    if (has('دين')) return const <String, double>{'min': 41, 'max': 100};
    if (has('رياضه') || has('رياضيه') || has('رياضية')) {
      return const <String, double>{'min': 41, 'max': 100};
    }
    if (has('موسيق')) return const <String, double>{'min': 41, 'max': 100};
    if (has('رياضيات')) return const <String, double>{'min': 41, 'max': 100};
    if (has('علوم') || has('صح')) return const <String, double>{'min': 41, 'max': 100};
    if (has('فنون') || has('جمالي')) return const <String, double>{'min': 41, 'max': 100};
    if (has('انكليز') || has('انجليز')) return const <String, double>{'min': 41, 'max': 100};
    if (has('عربي') || has('العربيه')) return const <String, double>{'min': 41, 'max': 100};
    if (has('سلوك')) return const <String, double>{'min': 41, 'max': 100};
    return null;
  }

  /// Official marks for grades 5 / 6 (same scale for both).
  /// From the attached school report form: max total 1100, min total 460.
  Map<String, double>? _upperPrimaryOfficialMarks(String subject) {
    final key = _normalizeSubjectKey(subject);
    bool has(String part) => key.contains(_normalizeSubjectKey(part));

    // Skills first so they are not swallowed by broader matches.
    if (has('مهارات شفوي') || (has('مهارات') && has('شفو'))) {
      return const <String, double>{'min': 50, 'max': 100};
    }
    if (has('مهارات كتاب') || (has('مهارات') && has('كتاب'))) {
      return const <String, double>{'min': 50, 'max': 100};
    }
    if (has('سلوك')) return const <String, double>{'min': 40, 'max': 100};
    if (has('اجتماع') || has('دراسات')) return const <String, double>{'min': 40, 'max': 100};
    if (has('دين')) return const <String, double>{'min': 40, 'max': 100};
    if (has('رياضه') || has('رياضيه') || has('رياضية')) {
      return const <String, double>{'min': 40, 'max': 100};
    }
    if (has('موسيق')) return const <String, double>{'min': 40, 'max': 100};
    if (has('رياضيات')) return const <String, double>{'min': 40, 'max': 100};
    if (has('علوم') || has('صح')) return const <String, double>{'min': 40, 'max': 100};
    if (has('فنون') || has('جمالي')) return const <String, double>{'min': 40, 'max': 100};
    if (has('انكليز') || has('انجليز')) return const <String, double>{'min': 40, 'max': 100};
    if (has('عربي') || has('العربيه')) return const <String, double>{'min': 40, 'max': 100};
    return null;
  }

  /// Official marks for grades 7 / 8 / 9 (same scale for all three).
  /// From the attached school report form: max total 4200, min total 1780.
  Map<String, double>? _middleCycleOfficialMarks(String subject) {
    final key = _normalizeSubjectKey(subject);
    bool has(String part) => key.contains(_normalizeSubjectKey(part));

    // Subject -> [min, max]
    if (has('سلوك')) return const <String, double>{'min': 120, 'max': 200};
    if (has('عربي') || has('العربيه')) return const <String, double>{'min': 300, 'max': 600};
    if (has('رياضيات')) return const <String, double>{'min': 240, 'max': 600};
    if (has('اجتماع') || has('دراسات')) return const <String, double>{'min': 240, 'max': 600};
    if (has('انكليز') || has('انجليز')) return const <String, double>{'min': 160, 'max': 400};
    if (has('فرنس') || has('اجنب') || has('اجنبيه') || has('اجنبية')) {
      return const <String, double>{'min': 160, 'max': 400};
    }
    if (has('علوم') || has('فيزياء') || has('كيمياء') || has('احياء')) {
      return const <String, double>{'min': 160, 'max': 400};
    }
    if (has('دين')) return const <String, double>{'min': 80, 'max': 200};
    if (has('رياضه') || has('رياضيه') || has('رياضية')) {
      return const <String, double>{'min': 80, 'max': 200};
    }
    if (has('موسيق')) return const <String, double>{'min': 80, 'max': 200};
    if (has('فنون') || has('جمالي')) return const <String, double>{'min': 80, 'max': 200};
    if (has('معلوم') || has('تكنلوج') || has('تكنولوج') || has('اتصا')) {
      return const <String, double>{'min': 80, 'max': 200};
    }
    return null;
  }

  Map<String, double>? _officialMarksForStudent(StudentRecord? student, String subject) {
    if (student == null) {
      // Prefer the most specific known table when student grade is unknown.
      return _middleCycleOfficialMarks(subject) ??
          _upperPrimaryOfficialMarks(subject) ??
          _lowerPrimaryOfficialMarks(subject);
    }
    if (_isLowerPrimaryGrade(student)) {
      return _lowerPrimaryOfficialMarks(subject);
    }
    if (_isUpperPrimaryGrade(student)) {
      return _upperPrimaryOfficialMarks(subject);
    }
    if (_isMiddleCycleGrade(student)) {
      return _middleCycleOfficialMarks(subject);
    }
    return null;
  }

  /// Official-style max mark per subject (الدرجة العظمى).
  /// Grades 1-4, 5-6, and 7-9 each have their own official scale.
  double _examSubjectMaxMark(String subject, [StudentRecord? student]) {
    final official = _officialMarksForStudent(student, subject);
    if (official != null) {
      return official['max']!;
    }

    // Fallback for other grades until their official tables are provided.
    final key = _normalizeSubjectKey(subject);
    bool has(String part) => key.contains(_normalizeSubjectKey(part));
    if (has('مهارات')) return 100;
    if (has('سلوك')) return 100;
    if (has('عربي') || has('العربيه')) return 600;
    if (has('رياضيات')) return 600;
    if (has('اجتماع') || has('دراسات')) return 600;
    if (has('انكليز') || has('انجليز')) return 400;
    if (has('فرنس') || has('اجنب') || has('اجنبيه')) return 400;
    if (has('علوم') || has('فيزياء') || has('كيمياء') || has('احياء') || has('صح')) return 400;
    if (has('دين') || has('رياضه') || has('رياضيه') || has('موسيق') || has('فنون') || has('جمالي') || has('معلوم') || has('تكنلوج') || has('تكنولوج') || has('اتصا') || has('تاريخ') || has('جغراف') || has('فلسف') || has('وطن')) {
      return 200;
    }
    return 100;
  }

  /// Official-style pass mark (الدرجة الدنيا).
  double _examSubjectMinMark(String subject, [StudentRecord? student]) {
    final official = _officialMarksForStudent(student, subject);
    if (official != null) {
      return official['min']!;
    }

    final maxMark = _examSubjectMaxMark(subject, student);
    final key = _normalizeSubjectKey(subject);
    if (key.contains('مهارات')) return 50;
    if (key.contains('سلوك')) return maxMark * 0.4;
    if (key.contains('عربي') || key.contains('العربيه')) return maxMark * 0.5;
    return maxMark * 0.4;
  }

  double _clampExamScore(double value, double maxMark) {
    if (value.isNaN || value.isInfinite) return 0;
    if (value < 0) return 0;
    if (value > maxMark) return maxMark;
    return value;
  }

  /// Term total matches official form: (أعمال + امتحان) / 2
  double _examTermTotal(double work, double exam) => (work + exam) / 2;

  double _examFinalAverage(double firstTotal, double secondTotal) => (firstTotal + secondTotal) / 2;

  double _examSubjectFinal(StudentRecord student, String subject) {
    final e = _examResultForStudentSubject(student, subject);
    final t1 = _examTermTotal(e.firstTermWork, e.firstTermExam);
    final t2 = _examTermTotal(e.secondTermWork, e.secondTermExam);
    return _examFinalAverage(t1, t2);
  }

  Map<String, double> _examReportTotals(StudentRecord student, List<String> subjects) {
    var sumMin = 0.0;
    var sumMax = 0.0;
    var sumFirst = 0.0;
    var sumSecond = 0.0;
    var sumFinal = 0.0;
    for (final subject in subjects) {
      final e = _examResultForStudentSubject(student, subject);
      sumMin += _examSubjectMinMark(subject, student);
      sumMax += _examSubjectMaxMark(subject, student);
      sumFirst += _examTermTotal(e.firstTermWork, e.firstTermExam);
      sumSecond += _examTermTotal(e.secondTermWork, e.secondTermExam);
      sumFinal += _examFinalAverage(
        _examTermTotal(e.firstTermWork, e.firstTermExam),
        _examTermTotal(e.secondTermWork, e.secondTermExam),
      );
    }
    final percent = sumMax <= 0 ? 0.0 : (sumFinal / sumMax) * 100;
    return <String, double>{
      'min': sumMin,
      'max': sumMax,
      'first': sumFirst,
      'second': sumSecond,
      'final': sumFinal,
      'percent': percent,
    };
  }

  String _examResultLabel(double finalTotal, double maxTotal) {
    if (maxTotal <= 0) return '-';
    final ratio = finalTotal / maxTotal;
    if (ratio >= 0.4) return 'ناجح';
    return 'راسب';
  }

  int _countCompletedExamSubjects(StudentRecord student) {
    return _studentExamResults(student.id)
        .where((entry) => entry.firstTermTotal > 0 || entry.secondTermTotal > 0)
        .length;
  }

  int _countReviewedExamSubjects(StudentRecord student) {
    return _studentExamResults(student.id)
        .where((entry) => entry.isManuallyReviewed)
        .length;
  }

  List<String> _visibleExamSubjectsForStudent(StudentRecord student) {
    final subjects = _examSubjectsForStudent(student);
    if (!_showOnlyUnreviewedExamSubjects) {
      return subjects;
    }
    return subjects
        .where((subject) => !_examResultForStudentSubject(student, subject).isManuallyReviewed)
        .toList();
  }

  Future<void> _markAllExamSubjectsReviewed(StudentRecord student) async {
    final subjects = _examSubjectsForStudent(student);
    if (subjects.isEmpty) {
      _showSnack('لا توجد مواد لهذا الطالب لتدقيقها.');
      return;
    }
    setState(() {
      for (final subject in subjects) {
        final index = _examResults.indexWhere((item) => item.studentId == student.id && item.subject == subject);
        if (index >= 0) {
          _examResults[index] = _examResults[index].copyWith(isManuallyReviewed: true);
        } else {
          _examResults.add(
            ExamResultEntry(
              studentId: student.id,
              subject: subject,
              firstTermWork: 0,
              firstTermExam: 0,
              secondTermWork: 0,
              secondTermExam: 0,
              isManuallyReviewed: true,
            ),
          );
        }
      }
    });
    await _persistAll();
    if (!mounted) {
      return;
    }
    _showSnack('تم التدقيق على كل المواد للطالب بنجاح.');
  }

  double _averageFinalForStudent(StudentRecord student) {
    final subjects = _examSubjectsForStudent(student);
    final active = subjects.where((subject) {
      final e = _examResultForStudentSubject(student, subject);
      return e.firstTermWork > 0 || e.firstTermExam > 0 || e.secondTermWork > 0 || e.secondTermExam > 0;
    }).toList();
    if (active.isEmpty) {
      return 0;
    }
    final sum = active.fold<double>(0, (total, subject) => total + _examSubjectFinal(student, subject));
    return sum / active.length;
  }

  bool _isFirstTermEntered(ExamResultEntry entry) {
    return entry.firstTermWork != 0 || entry.firstTermExam != 0;
  }

  bool _isSecondTermEntered(ExamResultEntry entry) {
    return entry.secondTermWork != 0 || entry.secondTermExam != 0;
  }

  bool _allFirstTermEnteredForStudent(StudentRecord student, {ExamResultEntry? override}) {
    final subjects = _examSubjectsForStudent(student);
    if (subjects.isEmpty) return false;
    for (final subject in subjects) {
      final entry = override != null && override.subject == subject
          ? override
          : _examResultForStudentSubject(student, subject);
      if (!_isFirstTermEntered(entry)) {
        return false;
      }
    }
    return true;
  }

  bool _allSecondTermEnteredForStudent(StudentRecord student, {ExamResultEntry? override}) {
    final subjects = _examSubjectsForStudent(student);
    if (subjects.isEmpty) return false;
    for (final subject in subjects) {
      final entry = override != null && override.subject == subject
          ? override
          : _examResultForStudentSubject(student, subject);
      if (!_isSecondTermEntered(entry)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _showExamCompletionDialog(List<String> messages) async {
    if (messages.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تنبيه إدخال الدرجات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map((message) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(message, style: const TextStyle(height: 1.8)),
                    ))
                .toList(),
          ),
          actions: <Widget>[
            _actionButton('موافق', AppPalette.goldDark, Colors.white, () => Navigator.of(dialogContext).pop()),
          ],
        );
      },
    );
  }

  Future<void> _saveExamSubjectResult({
    required StudentRecord student,
    required String subject,
    required double firstTermWork,
    required double firstTermExam,
    required double secondTermWork,
    required double secondTermExam,
    bool? isManuallyReviewed,
  }) async {
    final current = _examResultForStudentSubject(student, subject);
    final maxMark = _examSubjectMaxMark(subject, student);
    final entry = ExamResultEntry(
      studentId: student.id,
      subject: subject,
      firstTermWork: _clampExamScore(firstTermWork, maxMark),
      firstTermExam: _clampExamScore(firstTermExam, maxMark),
      secondTermWork: _clampExamScore(secondTermWork, maxMark),
      secondTermExam: _clampExamScore(secondTermExam, maxMark),
      isManuallyReviewed: isManuallyReviewed ?? current.isManuallyReviewed,
    );
    final index = _examResults.indexWhere((item) => item.studentId == student.id && item.subject == subject);
    setState(() {
      if (index >= 0) {
        _examResults[index] = entry;
      } else {
        _examResults.add(entry);
      }
    });
    await _persistAll();
  }

  Future<void> _toggleExamSubjectReviewed(StudentRecord student, String subject) async {
    final existing = _examResultForStudentSubject(student, subject);
    final reviewed = !existing.isManuallyReviewed;
    await _saveExamSubjectResult(
      student: student,
      subject: subject,
      firstTermWork: existing.firstTermWork,
      firstTermExam: existing.firstTermExam,
      secondTermWork: existing.secondTermWork,
      secondTermExam: existing.secondTermExam,
      isManuallyReviewed: reviewed,
    );
    if (!mounted) {
      return;
    }
    _showSnack(reviewed ? 'تم وضع علامة تدقيق المادة.' : 'تم إلغاء علامة تدقيق المادة.');
  }

  Future<void> _showExamSubjectEditor(StudentRecord student, String subject) async {
    const reviewAccent = Color(0xFF5A62D6);
    final existing = _examResultForStudentSubject(student, subject);
    final maxMark = _examSubjectMaxMark(subject, student);
    final minMark = _examSubjectMinMark(subject, student);
    final firstWorkController = TextEditingController(text: _formatExamNumber(existing.firstTermWork));
    final firstExamController = TextEditingController(text: _formatExamNumber(existing.firstTermExam));
    final secondWorkController = TextEditingController(text: _formatExamNumber(existing.secondTermWork));
    final secondExamController = TextEditingController(text: _formatExamNumber(existing.secondTermExam));
    var reviewedManually = existing.isManuallyReviewed;

    double parseNumber(TextEditingController controller) {
      return double.tryParse(controller.text.trim()) ?? 0;
    }

    void enforceMax(TextEditingController controller, void Function(void Function()) setDialogState) {
      final raw = parseNumber(controller);
      final clamped = _clampExamScore(raw, maxMark);
      if (raw != clamped) {
        controller.text = _formatExamNumber(clamped);
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        setDialogState(() {});
        _showSnack('لا يمكن إدخال درجة أعلى من العلامة العظمى (${_formatExamNumber(maxMark)}) لمادة $subject.');
      } else {
        setDialogState(() {});
      }
    }

    Widget termField(String label, TextEditingController controller, void Function(void Function()) setDialogState) {
      return Expanded(
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: (_) => enforceMax(controller, setDialogState),
          decoration: InputDecoration(
            labelText: label,
            helperText: 'الحد الأقصى: ${_formatExamNumber(maxMark)}',
            filled: true,
            fillColor: const Color(0xFFFBFDFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
            ),
          ),
        ),
      );
    }

    Widget buildTermPanel({
      required String title,
      required TextEditingController workController,
      required TextEditingController examController,
      required String totalLabel,
      required void Function(void Function()) setDialogState,
      required Future<void> Function(bool edited) onSubmit,
      required VoidCallback onCancel,
    }) {
      final work = parseNumber(workController);
      final exam = parseNumber(examController);
      final total = _examTermTotal(work, exam);
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
            const SizedBox(height: 8),
            Text(
              'العلامة العظمى للمادة: ${_formatExamNumber(maxMark)} • الدرجة الدنيا: ${_formatExamNumber(minMark)}',
              style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                termField('درجة الأعمال', workController, setDialogState),
                const SizedBox(width: 12),
                termField('درجة الامتحان', examController, setDialogState),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8DDBF)),
              ),
              child: Text(
                '$totalLabel: ${_formatExamNumber(total)}  = (${_formatExamNumber(work)} + ${_formatExamNumber(exam)}) ÷ 2',
                style: const TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _actionButton('حفظ', AppPalette.goldDark, Colors.white, () => onSubmit(false)),
                _actionButton('تعديل', const Color(0xFFEDF6FF), const Color(0xFF24436F), () => onSubmit(true)),
                _actionButton('إلغاء', Colors.white, const Color(0xFF667586), onCancel),
              ],
            ),
          ],
        ),
      );
    }

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> persistAndClose(bool edited) async {
                final firstWork = _clampExamScore(parseNumber(firstWorkController), maxMark);
                final firstExam = _clampExamScore(parseNumber(firstExamController), maxMark);
                final secondWork = _clampExamScore(parseNumber(secondWorkController), maxMark);
                final secondExam = _clampExamScore(parseNumber(secondExamController), maxMark);

                final updatedEntry = ExamResultEntry(
                  studentId: student.id,
                  subject: subject,
                  firstTermWork: firstWork,
                  firstTermExam: firstExam,
                  secondTermWork: secondWork,
                  secondTermExam: secondExam,
                  isManuallyReviewed: reviewedManually,
                );
                final beforeFirst = _allFirstTermEnteredForStudent(student);
                final beforeSecond = _allSecondTermEnteredForStudent(student);
                final afterFirst = _allFirstTermEnteredForStudent(student, override: updatedEntry);
                final afterSecond = _allSecondTermEnteredForStudent(student, override: updatedEntry);

                await _saveExamSubjectResult(
                  student: student,
                  subject: subject,
                  firstTermWork: firstWork,
                  firstTermExam: firstExam,
                  secondTermWork: secondWork,
                  secondTermExam: secondExam,
                  isManuallyReviewed: reviewedManually,
                );
                if (!mounted) {
                  return;
                }

                await Future<void>.delayed(Duration.zero);
                if (!mounted) {
                  return;
                }
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }

                final messages = <String>[];
                if (!beforeFirst && afterFirst) {
                  messages.add('تم إدخال جميع درجات مواد الفصل الأول للطالب.');
                }
                if (!beforeSecond && afterSecond) {
                  messages.add('تم إدخال جميع درجات مواد الفصل الثاني للطالب.');
                }
                if (messages.isNotEmpty) {
                  await _showExamCompletionDialog(messages);
                } else if (mounted) {
                  _showSnack(edited ? 'تم تعديل درجات مادة $subject بنجاح.' : 'تم حفظ درجات مادة $subject بنجاح.');
                }
              }

              final firstTotal = _examTermTotal(parseNumber(firstWorkController), parseNumber(firstExamController));
              final secondTotal = _examTermTotal(parseNumber(secondWorkController), parseNumber(secondExamController));
              final finalAverage = _examFinalAverage(firstTotal, secondTotal);
              final percent = maxMark <= 0 ? 0.0 : (finalAverage / maxMark) * 100;

              return AlertDialog(
                title: Text(subject),
                content: SizedBox(
                  width: 860,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'الطالب: ${student.fullName} • الصف: ${_studentGradeDisplay(student)} • الشعبة: ${_studentSectionDisplay(student)}',
                          style: const TextStyle(color: AppPalette.muted, height: 1.8),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppPalette.line),
                          ),
                          child: Text(
                            'العلامة العظمى: ${_formatExamNumber(maxMark)} • الدرجة الدنيا: ${_formatExamNumber(minMark)} • لا يُسمح بتجاوز العظمى في الأعمال أو الامتحان.',
                            style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppPalette.line),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                reviewedManually ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: reviewedManually ? reviewAccent : AppPalette.muted,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'علامة تدقيق المادة اليدوية',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft),
                                ),
                              ),
                              Tooltip(
                                message: reviewedManually ? 'تم تدقيق المادة' : 'وضع علامة تدقيق المادة',
                                child: Switch.adaptive(
                                  value: reviewedManually,
                                  activeColor: reviewAccent,
                                  onChanged: (value) => setDialogState(() => reviewedManually = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        buildTermPanel(
                          title: 'درجات الفصل الأول',
                          workController: firstWorkController,
                          examController: firstExamController,
                          totalLabel: 'محصلة الفصل الأول',
                          setDialogState: setDialogState,
                          onSubmit: persistAndClose,
                          onCancel: () {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                        buildTermPanel(
                          title: 'درجات الفصل الثاني',
                          workController: secondWorkController,
                          examController: secondExamController,
                          totalLabel: 'محصلة الفصل الثاني',
                          setDialogState: setDialogState,
                          onSubmit: persistAndClose,
                          onCancel: () {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppPalette.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('المحصلة النهائية للمادة', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                              const SizedBox(height: 8),
                              Text(
                                '(${_formatExamNumber(firstTotal)} + ${_formatExamNumber(secondTotal)}) ÷ 2 = ${_formatExamNumber(finalAverage)}',
                                style: const TextStyle(color: AppPalette.muted, height: 1.8),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'النسبة المئوية: ${_formatExamNumber(percent)}% من ${_formatExamNumber(maxMark)}',
                                style: const TextStyle(color: AppPalette.royalBlue, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('إغلاق'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      firstWorkController.dispose();
      firstExamController.dispose();
      secondWorkController.dispose();
      secondExamController.dispose();
    }
  }

  Widget _examSummaryTile(String label, String value, Color color, IconData icon) {
    return SizedBox(
      width: 260,
      child: Container(
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
                children: <Widget>[
                  Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examSubjectCard(StudentRecord student, String subject) {
    const reviewAccent = Color(0xFF5A62D6);
    const reviewSoft = Color(0xFFEEF0FF);
    final entry = _examResultForStudentSubject(student, subject);
    final firstDone = _isFirstTermEntered(entry);
    final secondDone = _isSecondTermEntered(entry);
    final reviewedManually = entry.isManuallyReviewed;

    Widget statusChip(String label, bool done, Color bg, Color fg) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: done ? bg : const Color(0xFFFDE8EC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: done ? bg : const Color(0xFFF3C4CB)),
        ),
        child: Text(
          done ? 'تم الإدخال - $label' : 'بانتظار الإدخال - $label',
          style: TextStyle(color: done ? fg : const Color(0xFFC44C5B), fontWeight: FontWeight.w900, fontSize: 11),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _showExamSubjectEditor(student, subject),
      child: Container(
        width: 272,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: reviewedManually ? const Color(0xFFF8F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: reviewedManually ? const Color(0xFFC9D0FF) : AppPalette.line, width: reviewedManually ? 1.4 : 1),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: reviewedManually ? reviewAccent.withOpacity(0.08) : const Color.fromRGBO(20, 40, 90, 0.05),
              blurRadius: reviewedManually ? 16 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book_outlined, color: AppPalette.royalBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft, fontSize: 16)),
                      ),
                      Tooltip(
                        message: reviewedManually ? 'تم تدقيق المادة' : 'وضع علامة تدقيق المادة',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _toggleExamSubjectReviewed(student, subject),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                reviewedManually ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: reviewedManually ? reviewAccent : const Color(0xFF97A6B7),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_left, color: AppPalette.royalBlue),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (reviewedManually)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: reviewSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFC9D0FF)),
                    ),
                    child: const Text(
                      'مدققة يدويًا',
                      style: TextStyle(color: reviewAccent, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),
                statusChip('الفصل الأول', firstDone, const Color(0xFFF7E6BF), AppPalette.goldDark),
                statusChip('الفصل الثاني', secondDone, const Color(0xFFDFF3E5), AppPalette.leafGreen),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'العلامة العظمى: ${_formatExamNumber(_examSubjectMaxMark(subject, student))} • الدنيا: ${_formatExamNumber(_examSubjectMinMark(subject, student))}',
                style: const TextStyle(color: Color(0xFF1F6B69), fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'محصلة الفصل الأول: ${_formatExamNumber(_examTermTotal(entry.firstTermWork, entry.firstTermExam))}',
                style: const TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F7EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'محصلة الفصل الثاني: ${_formatExamNumber(_examTermTotal(entry.secondTermWork, entry.secondTermExam))}',
                style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.line),
              ),
              child: Text(
                'المحصلة النهائية: ${_formatExamNumber(_examSubjectFinal(student, subject))}  •  ${_formatExamNumber((_examSubjectFinal(student, subject) / _examSubjectMaxMark(subject, student)) * 100)}%',
                style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            _actionButton('فتح درجات المادة', AppPalette.goldDark, Colors.white, () => _showExamSubjectEditor(student, subject)),
          ],
        ),
      ),
    );
  }

  Widget _examReportCard(StudentRecord student, List<String> subjects) {
    // NOTE: Flutter Table always lays columns left -> right (does NOT reverse in RTL).
    // Official Arabic form visual order on paper (right -> left):
    //   المادة | الدنيا | العظمى | أعمال1 | امتحان1 | محصلة1 | أعمال2 | امتحان2 | محصلة2 | المحصلة
    // So children[0] must be the LEFTMOST column (المحصلة), and children[last] the RIGHTMOST (المادة).
    final totals = _examReportTotals(student, subjects);
    final year = student.schoolYear.isEmpty ? _currentAcademicYear() : student.schoolYear;
    const schoolName = 'مدرسة روز التعليمية';
    final directorate = 'السويداء';
    final complexName = student.registryPlace.trim().isEmpty ? 'المجمع' : student.registryPlace.trim();
    final principal = _principalNameController.text.trim().isEmpty
        ? (_secretaryNameController.text.trim().isEmpty ? 'مدير المدرسة' : _secretaryNameController.text.trim())
        : _principalNameController.text.trim();
    final supervisor = _supervisorNameController.text.trim().isEmpty ? 'مشرف القسم' : _supervisorNameController.text.trim();
    final generalSupervisor = _generalSupervisorController.text.trim().isEmpty
        ? 'المشرف العام'
        : _generalSupervisorController.text.trim();
    final resultLabel = _examResultLabel(totals['final']!, totals['max']!);

    Widget metaPair(String label, String value) {
      return Container(
        margin: const EdgeInsets.only(left: 4, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD3DEE4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: const BoxDecoration(
                color: Color(0xFFE4ECEE),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2F4F4F)),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 64, maxWidth: 150),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF172727)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // left -> right widths matching children order above
    const colWidths = <int, TableColumnWidth>{
      0: FlexColumnWidth(1.1),  // المحصلة (يسار)
      1: FlexColumnWidth(1.05), // محصلة 2
      2: FlexColumnWidth(1.05), // امتحان 2
      3: FlexColumnWidth(1.05), // أعمال 2
      4: FlexColumnWidth(1.05), // محصلة 1
      5: FlexColumnWidth(1.05), // امتحان 1
      6: FlexColumnWidth(1.05), // أعمال 1
      7: FlexColumnWidth(0.95), // العظمى
      8: FlexColumnWidth(0.95), // الدنيا
      9: FlexColumnWidth(1.85), // المادة (يمين)
    };

    // Fill the whole A4 sheet: no large empty whitespace.
    return Container(
      width: _SchoolShellPageState._examReportCardWidth,
      height: _SchoolShellPageState._examReportCardWidth * 297 / 210,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header: logo + school name on VISUAL LEFT of the page.
            // In RTL Row, last child is on the left.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 96),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'الجلاء المدرسي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F6F6D),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        year,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F6F6D),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.asset('image/logo.jpg', width: 44, height: 44, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        schoolName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F6B69),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Meta chips — RTL wrap starts from the right
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD8E3E8)),
              ),
              child: Wrap(
                alignment: WrapAlignment.start,
                children: <Widget>[
                  metaPair('المديرية', directorate),
                  metaPair('المجمع', complexName),
                  metaPair('المدرسة', schoolName),
                  metaPair('الصف', _studentGradeDisplay(student)),
                  metaPair('الشعبة', _studentSectionDisplay(student)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD8E3E8)),
              ),
              child: Wrap(
                alignment: WrapAlignment.start,
                children: <Widget>[
                  metaPair('اسم الطالب', student.fullName),
                  metaPair('اسم الأم', student.motherName),
                  metaPair('المواليد', '${student.birthPlace} ${student.birthDate}'.trim()),
                  metaPair('الرقم في السجل العام', student.serial),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Stretch subject rows to fill remaining A4 height (no large empty gap).
                  final totalRows = 2 + subjects.length + 1; // 2 headers + subjects + totals
                  final available = constraints.maxHeight;
                  // Stretch grade rows to fill almost all remaining height.
                  // Signatures sit right under the table; white space is only BELOW names.
                  final headerH = 34.0;
                  final totalsH = 30.0;
                  final remainingForSubjects = (available - (headerH * 2) - totalsH).clamp(120.0, available);
                  final subjectH = subjects.isEmpty
                      ? 28.0
                      : (remainingForSubjects / subjects.length).clamp(24.0, 56.0);

                  Widget cell(
                    String value, {
                    bool isHeader = false,
                    bool bold = false,
                    Color? textColor,
                    Color? cellColor,
                    double height = 28,
                  }) {
                    return SizedBox(
                      height: height,
                      child: _examReportCell(
                        value,
                        isHeader: isHeader,
                        bold: bold,
                        textColor: textColor,
                        cellColor: cellColor,
                      ),
                    );
                  }

                  TableRow buildSubjectRow(String subject, {required bool zebra}) {
                    final e = _examResultForStudentSubject(student, subject);
                    final maxMark = _examSubjectMaxMark(subject, student);
                    final minMark = _examSubjectMinMark(subject, student);
                    final first = _examTermTotal(e.firstTermWork, e.firstTermExam);
                    final second = _examTermTotal(e.secondTermWork, e.secondTermExam);
                    final finalAvg = _examFinalAverage(first, second);
                    final bg = zebra ? const Color(0xFFF3F7F7) : Colors.white;
                    return TableRow(
                      decoration: BoxDecoration(color: bg),
                      children: <Widget>[
                        cell(_formatExamNumber(finalAvg), bold: true, cellColor: const Color(0xFFEAF2FF), height: subjectH),
                        cell(_formatExamNumber(second), bold: true, cellColor: const Color(0xFFEDF8F1), height: subjectH),
                        cell(_formatExamNumber(e.secondTermExam), height: subjectH),
                        cell(_formatExamNumber(e.secondTermWork), height: subjectH),
                        cell(_formatExamNumber(first), bold: true, cellColor: const Color(0xFFFFF7EA), height: subjectH),
                        cell(_formatExamNumber(e.firstTermExam), height: subjectH),
                        cell(_formatExamNumber(e.firstTermWork), height: subjectH),
                        cell(_formatExamNumber(maxMark), bold: true, textColor: const Color(0xFF0F5C5A), height: subjectH),
                        cell(_formatExamNumber(minMark), textColor: const Color(0xFF5A6B6B), height: subjectH),
                        cell(subject, bold: true, height: subjectH),
                      ],
                    );
                  }

                  final fillRows = <TableRow>[
                    for (var i = 0; i < subjects.length; i++) buildSubjectRow(subjects[i], zebra: i.isOdd),
                  ];

                  final fillTotals = TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFEEF4F4)),
                    children: <Widget>[
                      cell(_formatExamNumber(totals['final']!), bold: true, cellColor: const Color(0xFFE8F2FF), height: totalsH),
                      cell(_formatExamNumber(totals['second']!), bold: true, cellColor: const Color(0xFFDFF3E5), height: totalsH),
                      cell('', cellColor: const Color(0xFFDFF3E5), height: totalsH),
                      cell('', cellColor: const Color(0xFFDFF3E5), height: totalsH),
                      cell(_formatExamNumber(totals['first']!), bold: true, cellColor: const Color(0xFFF7E6BF), height: totalsH),
                      cell('', cellColor: const Color(0xFFF7E6BF), height: totalsH),
                      cell('', cellColor: const Color(0xFFF7E6BF), height: totalsH),
                      cell(_formatExamNumber(totals['max']!), bold: true, cellColor: const Color(0xFFE7F3F2), height: totalsH),
                      cell(_formatExamNumber(totals['min']!), bold: true, cellColor: const Color(0xFFE7F3F2), height: totalsH),
                      cell('المجموع', isHeader: true, cellColor: const Color(0xFF1F6B69), height: totalsH),
                    ],
                  );

                  return Container(
                    width: double.infinity,
                    height: available,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1F6B69), width: 1.1),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Table(
                        border: TableBorder.all(color: const Color(0xFF1F6B69), width: 0.85),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: colWidths,
                        children: <TableRow>[
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFF1F6B69)),
                            children: <Widget>[
                              cell('المحصلة', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('الفصل الثاني', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('الفصل الأول', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('الدرجة\nالعظمى', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('الدرجة\nالدنيا', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('المادة', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                            ],
                          ),
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFF2A7E7C)),
                            children: <Widget>[
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('المحصلة', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('درجة\nالامتحان', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('درجة\nالأعمال', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('المحصلة', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('درجة\nالامتحان', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('درجة\nالأعمال', isHeader: true, cellColor: const Color(0xFF2A7E7C), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                              cell('', isHeader: true, cellColor: const Color(0xFF1F6B69), height: headerH),
                            ],
                          ),
                          ...fillRows,
                          fillTotals,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7E1E8)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'النتيجة النهائية: $resultLabel',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: resultLabel == 'ناجح' ? const Color(0xFF1E7A43) : AppPalette.roseRed,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'المجموع: ${_formatExamNumber(totals['final']!)} / ${_formatExamNumber(totals['max']!)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF123A78), fontSize: 12.5),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'النسبة: ${_formatExamNumber(totals['percent']!)}%',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F6B69), fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Signatures immediately under grades; white space only under the names.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('التوقيعات الإدارية', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w900, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text('مدير المدرسة: $principal', textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800, fontSize: 11)),
                      const SizedBox(height: 3),
                      Text('مشرف القسم: $supervisor', textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 10.5)),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1.0, color: Color(0xFFB7C5D6)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Text('الخاتم', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w900, fontSize: 11)),
                      SizedBox(height: 22),
                      Divider(thickness: 1.0, color: Color(0xFFB7C5D6)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('المشرف العام', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w900, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(generalSupervisor, textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 10.5)),
                      Text('اسم المدير: $principal', textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 10.5)),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1.0, color: Color(0xFFB7C5D6)),
                    ],
                  ),
                ),
              ],
            ),
            // Clean white margin under signatures (bottom of A4).
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _examReportCell(
    String text, {
    bool isHeader = false,
    bool bold = false,
    Color? textColor,
    Color? cellColor,
  }) {
    return Container(
      color: cellColor ?? Colors.transparent,
      // Fill A4 height: taller cells reduce empty whitespace under the table.
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isHeader ? Colors.white : (textColor ?? const Color(0xFF152525)),
          fontWeight: isHeader || bold ? FontWeight.w900 : FontWeight.w700,
          fontSize: isHeader ? 10 : 11.5,
          height: 1.15,
        ),
      ),
    );
  }

  List<String> _studentGradeOptions() {
    final values = _students.map(_studentGradeDisplay).where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
    return <String>['الكل', ...values];
  }

  List<String> _studentSectionOptions() {
    final values = _students.map(_studentSectionDisplay).where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
    return <String>['الكل', ...values];
  }

  Future<void> _showBulkExamReportsDialog() async {
    String selectedGrade = 'الكل';
    String selectedSection = 'الكل';

    List<StudentRecord> filteredStudents() {
      return _studentsByGradeAndSection(grade: selectedGrade, section: selectedSection);
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final matches = filteredStudents();
            return AlertDialog(
              title: const Text('طباعة الجلاءات'),
              content: SizedBox(
                width: 860,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('حدد الصف والشعبة ثم اطبع كل الجلاءات المطابقة دفعة واحدة أو عاين/اطبع جلاء طالب محدد.', style: TextStyle(color: AppPalette.muted, height: 1.8)),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGrade,
                              decoration: const InputDecoration(labelText: 'الصف'),
                              items: _studentGradeOptions().map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() => selectedGrade = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedSection,
                              decoration: const InputDecoration(labelText: 'الشعبة'),
                              items: _studentSectionOptions().map((value) => DropdownMenuItem<String>(value: value, child: Text(value == 'الكل' ? value : 'الشعبة $value'))).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() => selectedSection = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppPalette.line),
                        ),
                        child: Text('عدد الجلاءات المطابقة: ${matches.length}', style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8DDBF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('اسم ملف PDF الجماعي النهائي', style: TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(
                              _bulkExamReportsFileName(
                                grade: selectedGrade,
                                section: selectedSection,
                                studentCount: matches.length,
                              ),
                              style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _actionButton('معاينة جماعية', const Color(0xFFF7F3EA), AppPalette.goldDark, matches.isEmpty ? () {} : () async {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                            await Future<void>.delayed(Duration.zero);
                            if (!mounted) return;
                            await _previewBulkExamReports(grade: selectedGrade, section: selectedSection);
                          }),
                          _actionButton('طباعة جماعية', const Color(0xFFE7F7EE), AppPalette.leafGreen, matches.isEmpty ? () {} : () async {
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.of(dialogContext).pop();
                            }
                            await Future<void>.delayed(Duration.zero);
                            if (!mounted) return;
                            await _printBulkExamReports(grade: selectedGrade, section: selectedSection);
                          }),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (matches.isEmpty)
                        const Text('لا توجد جلاءات مطابقة للصف والشعبة المحددين.', style: TextStyle(color: AppPalette.muted))
                      else
                        ...matches.map((student) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppPalette.line),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                                        const SizedBox(height: 4),
                                        Text('${_studentGradeDisplay(student)} • الشعبة ${_studentSectionDisplay(student)}', style: const TextStyle(color: AppPalette.muted)),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: <Widget>[
                                      _actionButton('معاينة', const Color(0xFFF7F3EA), AppPalette.goldDark, () async {
                                        if (Navigator.of(dialogContext).canPop()) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                        await Future<void>.delayed(Duration.zero);
                                        if (!mounted) return;
                                        setState(() => _loadStudent(student));
                                        await WidgetsBinding.instance.endOfFrame;
                                        await _previewExamReport();
                                      }),
                                      _actionButton('طباعة', const Color(0xFFE7F7EE), AppPalette.leafGreen, () async {
                                        if (Navigator.of(dialogContext).canPop()) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                        await Future<void>.delayed(Duration.zero);
                                        if (!mounted) return;
                                        setState(() => _loadStudent(student));
                                        await WidgetsBinding.instance.endOfFrame;
                                        await _printExamReport();
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إغلاق')),
              ],
            );
          },
        );
      },
    );
  }

  Widget _examActionChip(String label, IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: AppPalette.gold.withOpacity(0.14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppPalette.line),
            boxShadow: const [BoxShadow(color: Color.fromRGBO(18, 58, 120, 0.06), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  int _countEnteredFirstTermSubjects(StudentRecord student) {
    final subjects = _examSubjectsForStudent(student);
    var n = 0;
    for (final subject in subjects) {
      if (_isFirstTermEntered(_examResultForStudentSubject(student, subject))) n++;
    }
    return n;
  }

  int _countEnteredSecondTermSubjects(StudentRecord student) {
    final subjects = _examSubjectsForStudent(student);
    var n = 0;
    for (final subject in subjects) {
      if (_isSecondTermEntered(_examResultForStudentSubject(student, subject))) n++;
    }
    return n;
  }

  double _examEntryProgressPercent(StudentRecord student) {
    final subjects = _examSubjectsForStudent(student);
    if (subjects.isEmpty) return 0;
    // Progress over both terms: each subject has 2 terms.
    final totalSlots = subjects.length * 2;
    var done = 0;
    for (final subject in subjects) {
      final e = _examResultForStudentSubject(student, subject);
      if (_isFirstTermEntered(e)) done++;
      if (_isSecondTermEntered(e)) done++;
    }
    return (done * 100.0) / totalSlots;
  }

  Widget _examsPageSection() {
    if (_students.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد طلاب لإظهار الجلاء المدرسي. أضف طالبًا أولاً من أمانة السر.',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.muted),
          textAlign: TextAlign.center,
        ),
      );
    }
    final student = _selectedStudent ?? _students.first;
    // Always prefer automatic model from the selected student's grade.
    // (Manual dropdown may set a temporary override; changing student clears it in _loadStudent.)
    final subjects = _examSubjectsForStudent(student);
    final visibleSubjects = _visibleExamSubjectsForStudent(student);
    final reviewedCount = _countReviewedExamSubjects(student);
    final unreviewedCount = subjects.length - reviewedCount;
    final firstEntered = _countEnteredFirstTermSubjects(student);
    final secondEntered = _countEnteredSecondTermSubjects(student);
    final progress = _examEntryProgressPercent(student);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Title + action chips in one horizontal wrap (side by side, not stacked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  '📚 الدرجات والجلاء المدرسي',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _examActionChip('تحديث', Icons.refresh, AppPalette.sky, AppPalette.deepNavySoft, () => setState(() {})),
                    _examActionChip('إدارة المواد', Icons.edit_note_rounded, AppPalette.ivory, AppPalette.goldDark, () => _showManageExamSubjectsDialog(student)),
                    if (subjects.isNotEmpty)
                      _examActionChip('أول مادة', Icons.menu_book, AppPalette.goldDark, Colors.white, () => _showExamSubjectEditor(student, subjects.first)),
                    _examActionChip('تدقيق الكل', Icons.verified, const Color(0xFF123A78), Colors.white, () => _markAllExamSubjectsReviewed(student)),
                    _examActionChip(
                      _showOnlyUnreviewedExamSubjects ? 'كل المواد' : 'غير المدققة',
                      Icons.filter_alt,
                      _showOnlyUnreviewedExamSubjects ? AppPalette.roseRed : Colors.white,
                      _showOnlyUnreviewedExamSubjects ? Colors.white : AppPalette.deepNavySoft,
                      () => setState(() => _showOnlyUnreviewedExamSubjects = !_showOnlyUnreviewedExamSubjects),
                    ),
                    _examActionChip(_isExamReportExporting ? '...' : 'معاينة الجلاء', Icons.visibility, AppPalette.ivory, AppPalette.goldDark, _isExamReportExporting ? () {} : _previewExamReport),
                    _examActionChip(_isExamReportExporting ? '...' : 'طباعة الجلاء', Icons.print, AppPalette.leafGreen, Colors.white, _isExamReportExporting ? () {} : _printExamReport),
                    _examActionChip('طباعة جماعية', Icons.library_books, AppPalette.royalBlue, Colors.white, _showBulkExamReportsDialog),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('اختيار الطالب ونموذج الجلاء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: <Widget>[
                    _dropdownStudentPicker(student),
                    SizedBox(
                      width: 420,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE1EBF3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('نموذج الجلاء / الحلقة أو المرحلة', style: TextStyle(color: Color(0xFF7E8D9D), fontSize: 12, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _activeExamCycleForStudent(student),
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFFBFDFF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFD9E7F3)),
                                ),
                              ),
                              items: _examCycleOptions
                                  .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  final auto = _detectExamCycleForStudent(student);
                                  _examCycleOverride = value == auto ? null : value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF7F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC7E4E1)),
                  ),
                  child: Text(
                    'صف الطالب: ${_studentGradeDisplay(student)}'
                    '  •  النموذج: ${_examCycleLabel(_activeExamCycleForStudent(student))}'
                    '${_examCycleOverride == null ? ' (تلقائي حسب صف الطالب)' : ' (تعديل يدوي مؤقت)'}'
                    '  •  عدد المواد: ${subjects.length}',
                    style: const TextStyle(color: Color(0xFF1F6B69), fontWeight: FontWeight.w800, height: 1.6),
                  ),
                ),
                const SizedBox(height: 16),
                // Summary tiles: totals + entered terms + progress
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _examSummaryTile('إجمالي المواد', subjects.length.toString(), AppPalette.deepNavySoft, Icons.menu_book_rounded),
                    _examSummaryTile('المواد المدققة', reviewedCount.toString(), const Color(0xFF5A62D6), Icons.verified_outlined),
                    _examSummaryTile('غير المدققة', unreviewedCount.toString(), AppPalette.roseRed, Icons.pending_actions_rounded),
                    _examSummaryTile('الفصل الأول (مُدخَل)', '$firstEntered / ${subjects.length}', AppPalette.goldDark, Icons.looks_one_rounded),
                    _examSummaryTile('الفصل الثاني (مُدخَل)', '$secondEntered / ${subjects.length}', AppPalette.leafGreen, Icons.looks_two_rounded),
                    _examSummaryTile('نسبة الإنجاز', '${progress.toStringAsFixed(0)}%', const Color(0xFF0F766E), Icons.pie_chart_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar 0-100
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppPalette.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text('نسبة إنجاز إدخال الدرجات', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                          ),
                          Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F766E))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (progress / 100).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE5EEF5),
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الفصل الأول: $firstEntered مادة  •  الفصل الثاني: $secondEntered مادة',
                        style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _subSectionBanner(
                  'إدخال درجات المواد',
                  subtitle: 'عند اختيار الطالب يتبدل نموذج الجلاء تلقائيًا حسب صفه. كل مادة تُفتح في نافذة مستقلة مع منع تجاوز العلامة العظمى.',
                ),
                const SizedBox(height: 16),
                if (_showOnlyUnreviewedExamSubjects)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC9D0FF)),
                    ),
                    child: const Text(
                      'الفلتر مفعل الآن: يتم عرض المواد غير المدققة فقط.',
                      style: TextStyle(color: Color(0xFF5A62D6), fontWeight: FontWeight.w900),
                    ),
                  ),
                if (visibleSubjects.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppPalette.line),
                    ),
                    child: Text(
                      _showOnlyUnreviewedExamSubjects
                          ? 'لا توجد مواد غير مدققة لهذا الطالب حاليًا.'
                          : 'لا توجد مواد لهذا الطالب حاليًا.',
                      style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: visibleSubjects.map((subject) => _examSubjectCard(student, subject)).toList(),
                  ),
                const SizedBox(height: 18),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _SchoolShellPageState._examReportCardWidth),
                    child: AspectRatio(
                      aspectRatio: 210 / 297,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: _SchoolShellPageState._examReportCardWidth,
                          height: _SchoolShellPageState._examReportCardWidth * 297 / 210,
                          child: RepaintBoundary(
                            key: _examReportBoundaryKey,
                            child: _examReportCard(student, subjects),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderPageSection(String title) {
    return Center(
      child: Container(
        width: 640,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
            const SizedBox(height: 12),
            const Text(
              'هذا الباب محفوظ الآن ضمن Flutter الفعلي، وسيتم استكماله بعد اعتماد صفحة قائمة الطلاب واستمارة الطالب.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.muted, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

}
