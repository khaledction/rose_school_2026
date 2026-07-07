import 'package:flutter/material.dart';

import '../models/school_models.dart';
import '../services/school_database_service.dart';
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
  String _sortMode = 'grade'; // 'grade' or 'grade_section'
  String _selectedGrade = '';
  String _selectedSection = '';
  List<StudentRecord> _sorted = [];
  bool _showExamScores = false;

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

    if (_sortMode == 'grade') {
      if (_selectedGrade.isEmpty) {
        // Group by grade
        result = List.from(students);
        result.sort((a, b) => a.grade.compareTo(b.grade));
      } else {
        result = students.where((s) => s.grade.trim() == _selectedGrade).toList();
        result.sort((a, b) => a.fullName.compareTo(b.fullName));
      }
    } else {
      // grade_section
      if (_selectedGrade.isEmpty || _selectedSection.isEmpty) {
        result = [];
      } else {
        result = students
            .where((s) =>
                s.grade.trim() == _selectedGrade &&
                s.section.trim() == _selectedSection)
            .toList();

        if (_showExamScores) {
          // Sort by exam average descending
          result.sort((a, b) {
            final avgA = _studentAverage(a.id);
            final avgB = _studentAverage(b.id);
            return avgB.compareTo(avgA);
          });
        } else {
          result.sort((a, b) => a.fullName.compareTo(b.fullName));
        }
      }
    }

    setState(() => _sorted = result);
  }

  double _studentAverage(int studentId) {
    // Calculate average from exam results stored in SchoolDatabaseService
    // For now, calculate from the available data in examResults
    // Since we don't have direct access to private _examResults, use a simplified approach
    return 0; // Placeholder - will be calculated with exam data
  }

  String _studentExamSummary(StudentRecord student) {
    // Placeholder for exam score display
    return '';
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
              // Export button
              _actionButton('📄 تصدير PDF', Colors.white, AppPalette.deepNavySoft, () {
                _showSnack('سيتم تفعيل تصدير PDF لاحقاً.');
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
                Row(
                  children: <Widget>[
                    // Sort mode chips
                    _sortModeChip('📋 حسب الصفوف', 'grade'),
                    const SizedBox(width: 8),
                    _sortModeChip('📋 حسب الصف + الشعبة', 'grade_section'),
                  ],
                ),
                const SizedBox(height: 14),

                // Filters
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    // Grade filter
                    SizedBox(
                      width: 260,
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade.isEmpty ? null : _selectedGrade,
                        hint: const Text('اختر الصف'),
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
                        decoration: _inputDecoration('الصف'),
                      ),
                    ),

                    // Section filter (only for grade_section mode)
                    if (_sortMode == 'grade_section')
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection.isEmpty ? null : _selectedSection,
                          hint: const Text('اختر الشعبة'),
                          items: _availableSections
                              .map((s) => DropdownMenuItem(value: s, child: Text('الشعبة $s')))
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

                    if (_sortMode == 'grade_section' && _selectedGrade.isNotEmpty && _selectedSection.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppPalette.goldDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('ترتيب حسب: ', style: TextStyle(color: AppPalette.muted, fontSize: 12)),
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => setState(() {
                                _showExamScores = !_showExamScores;
                                _applySort();
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showExamScores ? AppPalette.royalBlue : const Color(0xFFEDF6FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _showExamScores ? '🏆 الأعلى درجات' : '📛 الاسم',
                                  style: TextStyle(
                                    color: _showExamScores ? Colors.white : AppPalette.royalBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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

  Widget _sortModeChip(String label, String mode) {
    final active = _sortMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _sortMode = mode;
          _selectedSection = '';
          _applySort();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppPalette.deepNavy.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppPalette.deepNavy : AppPalette.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active ? AppPalette.deepNavy : AppPalette.muted,
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppPalette.goldDark, AppPalette.gold]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'الصف $grade',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${students.length} طالب',
                    style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  _actionButton('تصدير', const Color(0xFFEDF6FF), AppPalette.royalBlue, () {
                    _showSnack('سيتم تفعيل التصدير لاحقاً');
                  }),
                ],
              ),
              const SizedBox(height: 10),
              ...students.asMap().entries.map((entry) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: entry.key < students.length - 1
                              ? const Color(0xFFEEF2F7)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppPalette.royalBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: AppPalette.royalBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value.fullName,
                            style: const TextStyle(
                              color: AppPalette.deepNavySoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'شعبة ${entry.value.section.isEmpty ? '?' : entry.value.section}',
                          style: const TextStyle(color: AppPalette.muted, fontSize: 12),
                        ),
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppPalette.goldDark, AppPalette.gold]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedGrade.isNotEmpty
                      ? 'الصف $_selectedGrade${_selectedSection.isNotEmpty ? ' - الشعبة $_selectedSection' : ''}'
                      : 'النتائج',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_sorted.length} طالب',
                style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700),
              ),
              if (_showExamScores && _sorted.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.royalBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'مرتب حسب الأعلى درجات',
                      style: TextStyle(color: AppPalette.royalBlue, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: entry.key < _sorted.length - 1
                            ? const Color(0xFFEEF2F7)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Rank
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: entry.key < 3
                              ? [AppPalette.goldDark, AppPalette.royalBlue, AppPalette.leafGreen][entry.key]
                                  .withOpacity(0.15)
                              : AppPalette.muted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: entry.key < 3
                                  ? [AppPalette.goldDark, AppPalette.royalBlue, AppPalette.leafGreen][entry.key]
                                  : AppPalette.muted,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Medal for top 3
                      if (entry.key < 3)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            ['🥇', '🥈', '🥉'][entry.key],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(width: 6),
                      // Student info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              entry.value.fullName,
                              style: const TextStyle(
                                color: AppPalette.deepNavySoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${entry.value.serial}',
                              style: const TextStyle(color: AppPalette.muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Grade + Section
                      if (_sortMode == 'grade' && _selectedGrade.isEmpty) ...[
                        Text(
                          'شعبة ${entry.value.section.isEmpty ? '?' : entry.value.section}',
                          style: const TextStyle(color: AppPalette.muted, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Exam score (for grade_section + showExamScores)
                      if (_showExamScores && _sortMode == 'grade_section') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppPalette.goldDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _studentExamSummary(entry.value),
                            style: const TextStyle(
                              color: AppPalette.goldDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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
