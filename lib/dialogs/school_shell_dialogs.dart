part of '../pages/school_shell_page.dart';

extension SchoolShellDialogs on _SchoolShellPageState {

  Future<void> _showStudentActionsDialog(StudentRecord student) async {
    final actions = <Map<String, String>>[
      {'title': 'استمارة الطالب', 'desc': 'فتح نموذج بيانات الطالب الكامل'},
      {'title': 'الحضور والغياب', 'desc': 'متابعة الدوام والتأخر والغياب'},
      {'title': 'التبرعات', 'desc': 'تسجيل المساهمات والمساعدات'},
      {'title': 'المكافآت والعقوبات', 'desc': 'السجل السلوكي والتكريمات'},
      {'title': 'الشهادات', 'desc': 'الشهادات وكشوف النتائج'},
      {'title': 'الامتحانات', 'desc': 'الجدول الامتحاني ونتائج الطالب'},
      {'title': 'الوثائق والمرفقات', 'desc': 'هوية الطالب والشهادات السابقة'},
      {'title': 'النقل والفصل', 'desc': 'تغيير الحالة أو النقل أو طي القيد'},
      {'title': 'الأرشيف', 'desc': 'الوصول إلى السجلات غير النشطة'},
      {'title': 'التقارير', 'desc': 'التصدير والإحصائيات'},
      {'title': 'بطاقة الطالب والطباعة', 'desc': 'بطاقة الطالب وQR'},
      {'title': 'النسخ الاحتياطي والاستعادة', 'desc': 'حماية البيانات المحلية'},
      {'title': 'النقل المدرسي', 'desc': 'الاشتراك ونقاط التجمع'},
      {'title': 'مراسلات أولياء الأمور', 'desc': 'الإشعارات والاستدعاءات'},
    ];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    gradient: LinearGradient(colors: <Color>[AppPalette.deepNavy, AppPalette.royalBlue]),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'ماذا تريد عن ${student.fullName}؟',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الوصول السريع إلى كل الأبواب المرتبطة بالطالب (${student.serial})',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: actions.map((action) {
                      return SizedBox(
                        width: 430,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            if (action['title'] == 'استمارة الطالب') {
                              setState(() => _currentPage = 'form');
                              return;
                            }
                            if (action['title'] == 'الحضور والغياب') {
                              setState(() => _currentPage = 'attendance');
                              return;
                            }
                            if (action['title'] == 'المكافآت والعقوبات') {
                              setState(() => _currentPage = 'discipline');
                              return;
                            }
                            if (action['title'] == 'الشهادات') {
                              setState(() => _currentPage = 'certificates');
                              return;
                            }
                            if (action['title'] == 'التقارير') {
                              setState(() => _currentPage = 'reports');
                              return;
                            }
                            if (action['title'] == 'بطاقة الطالب والطباعة') {
                              setState(() => _currentPage = 'student_card');
                              return;
                            }
                            if (action['title'] == 'الوثائق والمرفقات') {
                              setState(() => _currentPage = 'documents');
                              return;
                            }
                            if (action['title'] == 'النسخ الاحتياطي والاستعادة') {
                              setState(() => _currentPage = 'backup');
                              return;
                            }
                            if (action['title'] == 'النقل المدرسي') {
                              setState(() => _currentPage = 'transport');
                              return;
                            }
                            if (action['title'] == 'مراسلات أولياء الأمور') {
                              setState(() => _currentPage = 'messages');
                              return;
                            }
                            if (action['title'] == 'الامتحانات' || action['title'] == 'لوحة الامتحانات') {
                              setState(() => _currentPage = 'exams');
                              return;
                            }
                            _showSnack('Demo Flutter: فتح قسم ${action['title']} للطالب ${student.fullName}.');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.line),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.chevron_left),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        action['title']!,
                                        style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        action['desc']!,
                                        style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStudentKnowledgeDialog(StudentRecord student) async {
    final sections = <Map<String, String>>[
      {'id': 'personal', 'title': 'المعلومات الشخصية', 'desc': 'البيانات الأساسية للطالب والهوية والزمرة والجنس والديانة'},
      {'id': 'language', 'title': 'اللغة', 'desc': 'اللغة الأولى والثانية واللغة التي يجيدها الطالب'},
      {'id': 'enrollment', 'title': 'الانتساب للمدرسة', 'desc': 'تاريخ الانتساب والصف والمدرسة المنقول منها والرسوب'},
      {'id': 'contact', 'title': 'الاتصال والسكن', 'desc': 'السكن والهواتف والإيميل'},
      {'id': 'transport_section', 'title': 'النقل والمواصلات', 'desc': 'الاشتراك بالمواصلات ومكان الانتظار'},
      {'id': 'social', 'title': 'الوضع الاجتماعي', 'desc': 'الحالة الاجتماعية والعيش مع العائلة'},
      {'id': 'health', 'title': 'الوضع الصحي', 'desc': 'الحالة الصحية والإعاقة والملاحظات'},
      {'id': 'hobbies', 'title': 'الهوايات والمبادرات', 'desc': 'الهوايات والمبادرات المدرسية والعينية والمالية'},
      {'id': 'guardian', 'title': 'بيانات ولي الأمر', 'desc': 'بيانات التواصل والطوارئ الخاصة بولي الأمر'},
      {'id': 'fees', 'title': 'الأقساط والمدفوعات', 'desc': 'الدفعات والرسوم مع أو بدون مواصلات'},
      {'id': 'media', 'title': 'الصورة و QR والوثائق', 'desc': 'الصورة والوثائق وQR المرتبط بالسجل'},
    ];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    gradient: LinearGradient(colors: <Color>[AppPalette.deepNavy, AppPalette.royalBlue]),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'ماذا تريد أن تعرفه عن الطالب؟',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student.fullName,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: sections.map((section) {
                      return SizedBox(
                        width: 430,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _loadStudent(student);
                              _currentPage = 'form';
                              _openSections.clear();
                              if (section['id'] != 'personal') {
                                _openSections.add(section['id']!);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.line),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.chevron_left),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        section['title']!,
                                        style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        section['desc']!,
                                        style: const TextStyle(color: AppPalette.muted, fontSize: 12, height: 1.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStudentSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _showSnack('اكتب اسم الطالب أولًا في مربع البحث.');
      return;
    }
    final matches = _students.where((student) {
      final haystack = <String>[student.fullName, student.serial, student.guardianName, student.mobile].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
    if (matches.isEmpty) {
      _showSnack('لم يتم العثور على طالب مطابق للبحث.');
      return;
    }
    if (matches.length == 1) {
      _showStudentKnowledgeDialog(matches.first);
      return;
    }
    _showSearchMatchesDialog(matches);
  }

  Future<void> _showSearchMatchesDialog(List<StudentRecord> matches) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    gradient: LinearGradient(colors: <Color>[AppPalette.deepNavy, AppPalette.royalBlue]),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'نتائج البحث عن الطالب',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: matches.map((student) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            _showStudentKnowledgeDialog(student);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.line),
                            ),
                            child: Row(
                              children: <Widget>[
                                _studentAvatar(student, size: 42),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                                      const SizedBox(height: 4),
                                      Text('${student.serial} • ${student.grade}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_left),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
