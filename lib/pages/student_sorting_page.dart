import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/school_models.dart';
import '../services/app_storage_paths_service.dart';
import '../theme/app_palette.dart';

class StudentSortingPage extends StatefulWidget {
  const StudentSortingPage({
    super.key,
    required this.students,
    this.examResults = const [],
    this.schoolName = 'مدرسة روز التعليمية',
    this.sectionSupervisorName = 'مشرف القسم',
    this.schoolManagerName = 'مدير المدرسة',
  });

  final List<StudentRecord> students;
  final List<ExamResultEntry> examResults;
  final String schoolName;
  final String sectionSupervisorName;
  final String schoolManagerName;

  @override
  State<StudentSortingPage> createState() => _StudentSortingPageState();
}

class _StudentSortingPageState extends State<StudentSortingPage> {
  String _sortMode = 'grade'; // grade | grade_section
  String _selectedGrade = '';
  String _selectedSection = '';
  bool _descending = true;
  List<_RankedStudent> _ranked = <_RankedStudent>[];
  Map<int, int> _schoolWideRank = <int, int>{};
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _applySort();
  }

  @override
  void didUpdateWidget(covariant StudentSortingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students || oldWidget.examResults != widget.examResults) {
      _applySort();
    }
  }

  List<String> get _availableGrades {
    final grades = widget.students
        .map((s) => s.grade.trim())
        .where((g) => g.isNotEmpty && g != '?')
        .toSet()
        .toList()
      ..sort((a, b) {
        final ai = int.tryParse(a) ?? 0;
        final bi = int.tryParse(b) ?? 0;
        if (ai != 0 || bi != 0) return ai.compareTo(bi);
        return a.compareTo(b);
      });
    return grades;
  }

  List<String> get _availableSections {
    final source = _selectedGrade.isEmpty
        ? widget.students
        : widget.students.where((s) => s.grade.trim() == _selectedGrade);
    final sections = source
        .map((s) => s.section.trim())
        .where((s) => s.isNotEmpty && s != '?')
        .toSet()
        .toList()
      ..sort();
    return sections;
  }

  double _studentScore(int studentId) {
    double total = 0;
    int count = 0;
    for (final r in widget.examResults) {
      if (r.studentId == studentId) {
        total += r.finalAverage;
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  void _applySort() {
    // School-wide ranking (among scored students)
    final schoolScored = widget.students
        .map((s) => (student: s, score: _studentScore(s.id)))
        .where((e) => e.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final schoolRanks = <int, int>{};
    for (var i = 0; i < schoolScored.length; i++) {
      schoolRanks[schoolScored[i].student.id] = i + 1;
    }
    _schoolWideRank = schoolRanks;

    Iterable<StudentRecord> source = widget.students;
    if (_selectedGrade.isNotEmpty) {
      source = source.where((s) => s.grade.trim() == _selectedGrade);
    }
    if (_sortMode == 'grade_section' && _selectedSection.isNotEmpty) {
      source = source.where((s) => s.section.trim() == _selectedSection);
    }

    final list = source.map((s) {
      final score = _studentScore(s.id);
      return _RankedStudent(
        student: s,
        average: score,
        schoolRank: schoolRanks[s.id],
      );
    }).toList();

    if (_sortMode == 'grade_section' && _selectedGrade.isEmpty) {
      // Group by grade then section then score
      list.sort((a, b) {
        final g = a.student.grade.compareTo(b.student.grade);
        if (g != 0) return g;
        final sec = a.student.section.compareTo(b.student.section);
        if (sec != 0) return sec;
        return _descending ? b.average.compareTo(a.average) : a.average.compareTo(b.average);
      });
    } else if (_sortMode == 'grade' && _selectedGrade.isEmpty) {
      list.sort((a, b) {
        final g = a.student.grade.compareTo(b.student.grade);
        if (g != 0) return g;
        return _descending ? b.average.compareTo(a.average) : a.average.compareTo(b.average);
      });
    } else {
      list.sort((a, b) => _descending ? b.average.compareTo(a.average) : a.average.compareTo(b.average));
    }

    // Local ranks within current filtered list (by average, ties share sequential order)
    final byScore = List<_RankedStudent>.from(list)
      ..sort((a, b) => b.average.compareTo(a.average));
    final localRank = <int, int>{};
    for (var i = 0; i < byScore.length; i++) {
      localRank[byScore[i].student.id] = i + 1;
    }

    setState(() {
      _ranked = list
          .map((e) => e.copyWith(localRank: localRank[e.student.id] ?? 0))
          .toList();
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _exportPdf() async {
    if (_ranked.isEmpty) {
      _showSnack('لا توجد بيانات للتصدير.');
      return;
    }
    setState(() => _exporting = true);
    try {
      final doc = pw.Document();
      final scope = _sortMode == 'grade_section'
          ? 'حسب الصف والشعبة${_selectedGrade.isEmpty ? '' : ' — الصف $_selectedGrade'}${_selectedSection.isEmpty ? '' : ' / شعبة $_selectedSection'}'
          : 'حسب الصف${_selectedGrade.isEmpty ? '' : ' — الصف $_selectedGrade'}';
      final order = _descending ? 'تنازلي' : 'تصاعدي';

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(widget.schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('فرز الطلاب حسب المعدل والدرجات', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('$scope • $order', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Text('Rose School 2026', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(45),
                1: const pw.FlexColumnWidth(2.4),
                2: const pw.FixedColumnWidth(45),
                3: const pw.FixedColumnWidth(45),
                4: const pw.FixedColumnWidth(50),
                5: const pw.FlexColumnWidth(2.2),
              },
              children: <pw.TableRow>[
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: <String>['الترتيب', 'اسم الطالب', 'الصف', 'الشعبة', 'المعدل', 'ملاحظة']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                          ))
                      .toList(),
                ),
                ..._ranked.map((row) {
                  final note = (row.schoolRank != null && row.schoolRank! <= 3)
                      ? 'من أعلى 3 على مستوى المدرسة (المرتبة ${row.schoolRank})'
                      : (row.schoolRank != null ? 'ترتيب المدرسة: ${row.schoolRank}' : '');
                  final cells = <String>[
                    '${row.localRank}',
                    row.student.fullName,
                    row.student.grade,
                    row.student.section,
                    row.average > 0 ? row.average.toStringAsFixed(1) : '--',
                    note,
                  ];
                  return pw.TableRow(
                    children: cells
                        .map((c) => pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(c, style: const pw.TextStyle(fontSize: 8)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 28),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text('مشرف القسم', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.SizedBox(height: 6),
                    pw.Text(widget.sectionSupervisorName, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 18),
                    pw.Container(width: 120, height: 1, color: PdfColors.grey600),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: <pw.Widget>[
                    pw.Text('مدير المدرسة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.SizedBox(height: 6),
                    pw.Text(widget.schoolManagerName, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 18),
                    pw.Container(width: 120, height: 1, color: PdfColors.grey600),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      final bytes = await doc.save();
      final reports = await AppStoragePathsService.instance.reportsDir;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = p.join(reports.path, 'student_sorting_$stamp.pdf');
      await File(filePath).writeAsBytes(bytes, flush: true);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'student_sorting_$stamp.pdf');
      _showSnack('تم تصدير PDF: $filePath');
    } catch (e) {
      _showSnack('تعذر تصدير PDF: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportExcelCsv() async {
    if (_ranked.isEmpty) {
      _showSnack('لا توجد بيانات للتصدير.');
      return;
    }
    setState(() => _exporting = true);
    try {
      final buffer = StringBuffer();
      buffer.writeln('الترتيب,اسم الطالب,الصف,الشعبة,المعدل,ترتيب على مستوى المدرسة,ملاحظة');
      for (final row in _ranked) {
        final note = (row.schoolRank != null && row.schoolRank! <= 3)
            ? 'من أعلى 3 على مستوى المدرسة'
            : '';
        buffer.writeln(
          '${row.localRank},'
          '"${row.student.fullName}",'
          '"${row.student.grade}",'
          '"${row.student.section}",'
          '${row.average > 0 ? row.average.toStringAsFixed(1) : ''},'
          '${row.schoolRank ?? ''},'
          '"$note"',
        );
      }
      final reports = await AppStoragePathsService.instance.reportsDir;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = p.join(reports.path, 'student_sorting_$stamp.csv');
      await File(filePath).writeAsString(buffer.toString(), flush: true);
      // Also put a JSON companion for Excel import tools if needed
      final jsonPath = p.join(reports.path, 'student_sorting_$stamp.json');
      await File(jsonPath).writeAsString(
        jsonEncode(_ranked
            .map((r) => {
                  'rank': r.localRank,
                  'name': r.student.fullName,
                  'grade': r.student.grade,
                  'section': r.student.section,
                  'average': r.average,
                  'schoolRank': r.schoolRank,
                })
            .toList()),
        flush: true,
      );
      await Clipboard.setData(ClipboardData(text: filePath));
      _showSnack('تم تصدير Excel/CSV: $filePath');
    } catch (e) {
      _showSnack('تعذر تصدير Excel: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
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
                  '🔍 فرز الطلاب حسب المعدل والدرجات',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft),
                ),
              ),
              _actionButton(
                _exporting ? 'جارٍ التصدير...' : '📄 PDF',
                Colors.white,
                AppPalette.deepNavySoft,
                _exporting ? () {} : _exportPdf,
              ),
              const SizedBox(width: 8),
              _actionButton(
                _exporting ? '...' : '📊 Excel',
                const Color(0xFFE7F7EE),
                AppPalette.leafGreen,
                _exporting ? () {} : _exportExcelCsv,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Controls
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
                    _sortChip('📋 حسب الصفوف', 'grade'),
                    _sortChip('📋 حسب الصفوف والشعب معاً', 'grade_section'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 180,
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
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSection.isEmpty ? null : _selectedSection,
                          hint: const Text('كل الشعب'),
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
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _descending = !_descending;
                          _applySort();
                        });
                      },
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
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Official table card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.line),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.06), blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              children: <Widget>[
                // Header with logo + school name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[Color(0xFF123A78), Color(0xFF1E7A79)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.asset(
                          'image/logo.jpg',
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 58,
                            height: 58,
                            color: Colors.white24,
                            child: const Icon(Icons.school, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.schoolName,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'جدول فرز الطلاب حسب المعدل والدرجات',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'العدد: ${_ranked.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F7FB)),
                    columns: const <DataColumn>[
                      DataColumn(label: Text('الترتيب', style: TextStyle(fontWeight: FontWeight.w900))),
                      DataColumn(label: Text('اسم الطالب', style: TextStyle(fontWeight: FontWeight.w900))),
                      DataColumn(label: Text('الصف', style: TextStyle(fontWeight: FontWeight.w900))),
                      DataColumn(label: Text('الشعبة', style: TextStyle(fontWeight: FontWeight.w900))),
                      DataColumn(label: Text('المعدل', style: TextStyle(fontWeight: FontWeight.w900))),
                      DataColumn(label: Text('ملاحظة الترتيب', style: TextStyle(fontWeight: FontWeight.w900))),
                    ],
                    rows: _ranked.isEmpty
                        ? <DataRow>[
                            const DataRow(
                              cells: <DataCell>[
                                DataCell(Text('--')),
                                DataCell(Text('لا توجد نتائج ضمن الفرز الحالي')),
                                DataCell(Text('--')),
                                DataCell(Text('--')),
                                DataCell(Text('--')),
                                DataCell(Text('--')),
                              ],
                            ),
                          ]
                        : _ranked.map((row) {
                            final topSchool = row.schoolRank != null && row.schoolRank! <= 3;
                            final note = topSchool
                                ? '⭐ من أعلى 3 على مستوى المدرسة (المرتبة ${row.schoolRank})'
                                : (row.schoolRank != null ? 'ترتيب المدرسة: ${row.schoolRank}' : '—');
                            return DataRow(
                              color: WidgetStateProperty.resolveWith((_) {
                                if (topSchool) return const Color(0xFFFFF8E8);
                                if (row.localRank <= 3) return const Color(0xFFF3FAF6);
                                return null;
                              }),
                              cells: <DataCell>[
                                DataCell(Text('${row.localRank}', style: const TextStyle(fontWeight: FontWeight.w800))),
                                DataCell(Text(row.student.fullName, style: const TextStyle(fontWeight: FontWeight.w700))),
                                DataCell(Text(row.student.grade)),
                                DataCell(Text(row.student.section)),
                                DataCell(Text(row.average > 0 ? row.average.toStringAsFixed(1) : '--')),
                                DataCell(
                                  Text(
                                    note,
                                    style: TextStyle(
                                      color: topSchool ? AppPalette.goldDark : AppPalette.muted,
                                      fontWeight: topSchool ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                  ),
                ),

                // Footer signatures
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE6EEF5))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('مشرف القسم', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                            const SizedBox(height: 6),
                            Text(widget.sectionSupervisorName, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            Container(height: 1, color: const Color(0xFFB7C5D6)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const Text('مدير المدرسة', style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.deepNavySoft)),
                            const SizedBox(height: 6),
                            Text(widget.schoolManagerName, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            Container(height: 1, color: const Color(0xFFB7C5D6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String mode) {
    final active = _sortMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        setState(() {
          _sortMode = mode;
          if (mode == 'grade') _selectedSection = '';
          _applySort();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppPalette.royalBlue : const Color(0xFFEDF6FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppPalette.royalBlue : AppPalette.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppPalette.royalBlue,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFBFDFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9E7F3))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppPalette.line),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }
}

class _RankedStudent {
  const _RankedStudent({
    required this.student,
    required this.average,
    this.schoolRank,
    this.localRank = 0,
  });

  final StudentRecord student;
  final double average;
  final int? schoolRank;
  final int localRank;

  _RankedStudent copyWith({int? localRank}) {
    return _RankedStudent(
      student: student,
      average: average,
      schoolRank: schoolRank,
      localRank: localRank ?? this.localRank,
    );
  }
}
