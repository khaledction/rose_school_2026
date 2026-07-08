import 'package:flutter/material.dart';

import '../models/school_models.dart';
import '../theme/app_palette.dart';

class StudentSortingPage extends StatefulWidget {
  const StudentSortingPage({
    super.key,
    required this.students,
  });

  final List<StudentRecord> students;

  @override
  State<StudentSortingPage> createState() => _StudentSortingPageState();
}

class _StudentSortingPageState extends State<StudentSortingPage> {
  String _sortMode = 'grade';
  String _selectedGrade = '';
  String _selectedSection = '';
  List<StudentRecord> _sorted = [];
  bool _descending = false;

  @override
  void initState() {
    super.initState();
    _applySort();
  }

  List<String> get _availableGrades {
    final grades = widget.students
        .map((s) => s.grade.trim())
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    grades.sort();
    return grades;
  }

  List<String> get _availableSections {
    final sections = widget.students
        .where((s) => _selectedGrade.isEmpty || s.grade.trim() == _selectedGrade)
        .map((s) => s.section.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    sections.sort();
    return sections;
  }

  void _applySort() {
    final students = widget.students;
    List<StudentRecord> result;

    if (_sortMode == 'name') {
      result = List.from(students);
      result.sort((a, b) => _descending
          ? b.fullName.compareTo(a.fullName)
          : a.fullName.compareTo(b.fullName));
    } else if (_sortMode == 'grade') {
      if (_selectedGrade.isEmpty) {
        result = List.from(students);
        result.sort((a, b) => a.grade.compareTo(b.grade));
      } else {
        result = students.where((s) => s.grade.trim() == _selectedGrade).toList();
        result.sort((a, b) => _descending
            ? b.fullName.compareTo(a.fullName)
            : a.fullName.compareTo(b.fullName));
      }
    } else {
      if (_selectedGrade.isEmpty || _selectedSection.isEmpty) {
        result = [];
      } else {
        result = students
            .where((s) => s.grade.trim() == _selectedGrade && s.section.trim() == _selectedSection)
            .toList();
        result.sort((a, b) {
          final scoreA = _studentScore(a.id);
          final scoreB = _studentScore(b.id);
          return _descending
              ? scoreA.compareTo(scoreB)
              : scoreB.compareTo(scoreA);
        });
      }
    }

    setState(() => _sorted = result);
  }

  double _studentScore(int studentId) {
    double total = 0;
    int count = 0;
    for (final s in widget.students) {
      if (s.id == studentId) {
        total += double.tryParse(s.grade) ?? 0;
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  String _scoreDisplay(StudentRecord student) {
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '🔍 فرز الطلاب',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              _actionButton('📄 تصدير PDF', Colors.white, AppPalette.deepNavySoft, () {
                _showSnack('سيتم تفعيل التصدير لاحقاً');
              }),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Sort controls ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('خيارات الفرز', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 15)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _sortChip('📛 حسب الاسم', 'name'),
                    _sortChip('📋 حسب الصفوف', 'grade'),
                    _sortChip('📋 حسب الصف + الشعبة', 'grade_section'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    // Grade filter (always visible)
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade.isEmpty ? null : _selectedGrade,
                        hint: const Text('كل الصفوف'),
                        items: _availableGrades
                            .map((g) => DropdownMenuItem(value: g, child: Text('الصف $g')))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedGrade = v ?? '';
                            _selectedSection = '';
                            _applySort();
                          });
                        },
                        decoration: _inputDecoration('اختر الصف'),
                      ),
                    ),
                    if (_sortMode == 'grade_section') ...<Widget>[
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection.isEmpty ? null : _selectedSection,
                          hint: const Text('اختر'),
                          items: _availableSections
                              .map((s) => DropdownMenuItem(value: s, child: Text('شعبة $s')))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedSection = v ?? '';
                              _applySort();
                            });
                          },
                          decoration: _inputDecoration('الشعبة'),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Ascending/Descending toggle
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        _descending = !_descending;
                        _applySort();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _descending ? AppPalette.royalBlue : const Color(0xFFEDF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _descending ? AppPalette.royalBlue : AppPalette.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              _descending ? Icons.arrow_downward : Icons.arrow_upward,
                              size: 16,
                              color: _descending ? Colors.white : AppPalette.royalBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _descending ? 'تنازلي' : 'تصاعدي',
                              style: TextStyle(
                                color: _descending ? Colors.white : AppPalette.royalBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_sortMode == 'grade_section' && _selectedGrade.isNotEmpty && _selectedSection.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppPalette.goldDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppPalette.goldDark.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.info_outline, size: 14, color: AppPalette.goldDark),
                        const SizedBox(width: 6),
                        Text(
                          'الفرز حسب الصف $_selectedGrade (كل الشعب) ثم داخل الشعبة $_selectedSection حسب المعدل',
                          style: const TextStyle(color: AppPalette.goldDark, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── Results ────────────────────────────────────────
          if (_sortMode == 'grade' && _selectedGrade.isEmpty)
            _buildGradeGroupedView()
          else
            _buildFlatListView(),

          if (_sorted.isEmpty && !(_sortMode == 'grade' && _selectedGrade.isEmpty))
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Icon(Icons.search_off, size: 64, color: AppPalette.muted),
                    SizedBox(height: 12),
                    Text('اختر الصف للعرض', style: TextStyle(color: AppPalette.muted, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String mode) {
    final active = _sortMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _sortMode = mode;
          _selectedSection = '';
          if (mode == 'name') _selectedGrade = '';
          _applySort();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [Color(0xFF123A78), Color(0xFF1E7A79)])
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? Colors.transparent : AppPalette.line),
          boxShadow: active
              ? [BoxShadow(color: const Color(0xFF123A78).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppPalette.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeGroupedView() {
    final byGrade = <String, List<StudentRecord>>{};
    for (final s in _sorted) {
      byGrade.putIfAbsent(s.grade.trim(), () => []).add(s);
    }
    final sortedGrades = byGrade.keys.toList()..sort();

    return Column(
      children: sortedGrades.map((grade) {
        final students = byGrade[grade]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppPalette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppPalette.goldDark, AppPalette.gold]),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Text('الصف $grade', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Text('${students.length} طالب', style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ...students.asMap().entries.map((entry) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: entry.key < students.length - 1 ? const Color(0xFFEEF2F7) : Colors.transparent,
                      )),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: AppPalette.royalBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                          child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: AppPalette.royalBlue, fontWeight: FontWeight.w800, fontSize: 12))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value.fullName, style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w600))),
                        Text('شعبة ${entry.value.section.isEmpty ? '?' : entry.value.section}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlatListView() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppPalette.goldDark, AppPalette.gold]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  _selectedGrade.isNotEmpty
                      ? 'الصف $_selectedGrade${_selectedSection.isNotEmpty ? ' شعبة $_selectedSection' : ''}'
                      : 'النتائج',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Text('${_sorted.length} طالب', style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(_descending ? 'تنازلي' : 'تصاعدي', style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          if (_sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('لا يوجد طلاب في هذا التصنيف', style: TextStyle(color: AppPalette.muted))),
            )
          else
            ..._sorted.asMap().entries.map((entry) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(
                      color: entry.key < _sorted.length - 1 ? const Color(0xFFEEF2F7) : Colors.transparent,
                    )),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Rank with medal for top 3
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: entry.key < 3
                              ? [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)][entry.key].withOpacity(0.2)
                              : AppPalette.muted.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: entry.key < 3
                              ? Text(['🥇', '🥈', '🥉'][entry.key], style: const TextStyle(fontSize: 18))
                              : Text('${entry.key + 1}', style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Student info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(entry.value.fullName, style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w700)),
                            Text(entry.value.serial, style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      // Section for grade view
                      if (_sortMode == 'grade' && _selectedGrade.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('شعبة ${entry.value.section.isEmpty ? '?' : entry.value.section}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                        ),
                      // Score badge for grade_section mode
                      if (_sortMode == 'grade_section')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppPalette.leafGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _scoreDisplay(entry.value),
                            style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
