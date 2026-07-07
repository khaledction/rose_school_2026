import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/meeting_models.dart';
import '../models/school_models.dart';
import '../services/app_storage_paths_service.dart';
import '../services/meeting_service.dart';
import '../services/notification_service.dart';
import '../theme/app_palette.dart';

class ParentMeetingsPage extends StatefulWidget {
  const ParentMeetingsPage({
    super.key,
    required this.students,
    required this.onNavigate,
  });

  final List<StudentRecord> students;
  final void Function(String pageId, {String? targetId}) onNavigate;

  @override
  State<ParentMeetingsPage> createState() => _ParentMeetingsPageState();
}

class _ParentMeetingsPageState extends State<ParentMeetingsPage> {
  String _view = 'list'; // 'list', 'add', 'attendance', 'report'

  // Meeting form
  final _titleController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected meeting
  String? _selectedMeetingId;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _dateController.text = DateTime.now().toIso8601String().split('T').first;
    _timeController.clear();
    _locationController.clear();
    _notesController.clear();
  }

  Future<void> _addMeeting() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack('يرجى إدخال عنوان الاجتماع');
      return;
    }
    if (_dateController.text.trim().isEmpty) {
      _showSnack('يرجى إدخال تاريخ الاجتماع');
      return;
    }

    await MeetingService.instance.addMeeting(ParentMeeting(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    ));

    await NotificationService.instance.addSimple(
      type: 'info',
      title: 'اجتماع أولياء أمور جديد',
      body: 'تم تحديد اجتماع: ${_titleController.text.trim()} بتاريخ ${_dateController.text.trim()}',
      targetPage: 'parent_meetings',
    );

    _clearForm();
    setState(() => _view = 'list');
    _showSnack('✅ تم إضافة الاجتماع بنجاح');
  }

  void _startAttendance(String meetingId) {
    setState(() {
      _selectedMeetingId = meetingId;
      _view = 'attendance';
    });
  }

  Future<void> _generateAttendanceList() async {
    if (_selectedMeetingId == null) return;
    final meeting = MeetingService.instance.meetingById(_selectedMeetingId!);
    if (meeting == null) return;

    // Build attendance records for all students
    final existing = MeetingService.instance.attendanceForMeeting(_selectedMeetingId!);
    if (existing.isNotEmpty) {
      _showSnack('تم تسجيل الحضور مسبقاً، يمكنك تعديله');
      return;
    }

    final records = widget.students.map((s) => MeetingAttendance(
          meetingId: _selectedMeetingId!,
          studentId: s.id,
          studentName: s.fullName,
          grade: s.grade,
          section: s.section,
          guardianName: s.guardianName,
          status: 'ghaeb',
        )).toList();

    await MeetingService.instance.saveAttendance(records);
    setState(() {});
    _showSnack('تم تجهيز قائمة الحضور (${records.length} طالب)');
  }

  Future<void> _saveAttendance(String meetingId, int studentId, String status) async {
    await MeetingService.instance.updateAttendanceStatus(meetingId, studentId, status);
  }

  Future<void> _printReport(String meetingId) async {
    try {
      final report = MeetingService.instance.reportForMeeting(meetingId);
      final pdf = await _buildReportPdf(report);
      await Printing.layoutPdf(
        name: 'meeting_report_${report.meeting.title}.pdf',
        onLayout: (format) async => pdf,
      );
      _showSnack('تم تجهيز التقرير للطباعة');
    } catch (e) {
      _showSnack('خطأ في طباعة التقرير: $e');
    }
  }

  Future<Uint8List> _buildReportPdf(MeetingReport report) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Header(level: 0, text: 'تقرير اجتماع أولياء الأمور'),
              pw.SizedBox(height: 12),
              pw.Text('عنوان الاجتماع: ${report.meeting.title}'),
              pw.Text('التاريخ: ${report.meeting.date} ${report.meeting.time.isNotEmpty ? "- ${report.meeting.time}" : ""}'),
              pw.Text('المكان: ${report.meeting.location.isNotEmpty ? report.meeting.location : "غير محدد"}'),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('ملخص الحضور:'),
              pw.Text('إجمالي الطلاب: ${report.totalStudents}'),
              pw.Text('الحاضرون: ${report.presentCount}'),
              pw.Text('الغائبون: ${report.absentCount}'),
              pw.Text('نسبة الحضور: ${report.attendancePercentage.toStringAsFixed(1)}%'),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Header(level: 1, text: 'كشف الحضور'),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['#', 'الطالب', 'الصف', 'الشعبة', 'ولي الأمر', 'الحالة'],
                data: List<List<String>>.generate(report.attendanceList.length, (i) {
                  final a = report.attendanceList[i];
                  return [
                    (i + 1).toString(),
                    a.studentName,
                    a.grade,
                    a.section,
                    a.guardianName,
                    a.status == 'hader' ? '✅ حاضر' : '❌ غائب',
                  ];
                }),
              ),
            ],
          );
        },
      ),
    );
    return doc.save();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // ─── Top action bar ───────────────────────────────────
          Row(
            children: <Widget>[
              _viewButton('📋 الاجتماعات', 'list'),
              const SizedBox(width: 8),
              _viewButton('➕ اجتماع جديد', 'add'),
              if (_selectedMeetingId != null) ...[
                const SizedBox(width: 8),
                _viewButton('📝 تسجيل حضور', 'attendance'),
                const SizedBox(width: 8),
                _viewButton('📊 التقرير', 'report'),
              ],
            ],
          ),
          const SizedBox(height: 14),

          if (_view == 'list') _buildMeetingList(),
          if (_view == 'add') _buildAddMeetingForm(),
          if (_view == 'attendance') _buildAttendanceView(),
          if (_view == 'report') _buildReportView(),
        ],
      ),
    );
  }

  Widget _viewButton(String label, String viewId) {
    final active = _view == viewId;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _view = viewId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppPalette.deepNavy.withOpacity(0.1) : Colors.white.withOpacity(0.8),
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

  // ─── Meeting List ──────────────────────────────────────────────

  Widget _buildMeetingList() {
    final meetings = MeetingService.instance.meetings;
    if (meetings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: <Widget>[
              Icon(Icons.event_note, size: 64, color: AppPalette.muted),
              SizedBox(height: 12),
              Text('لا توجد اجتماعات بعد', style: TextStyle(color: AppPalette.muted, fontSize: 16)),
              SizedBox(height: 8),
              Text('اضف اجتماع جديد للبدء', style: TextStyle(color: AppPalette.muted)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: meetings.map((m) => _buildMeetingCard(m)).toList(),
    );
  }

  Widget _buildMeetingCard(ParentMeeting m) {
    final attendance = MeetingService.instance.attendanceForMeeting(m.id);
    final present = attendance.where((a) => a.status == 'hader').length;
    final total = attendance.length;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '--';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedMeetingId = m.id;
            _view = 'attendance';
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPalette.royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event, color: AppPalette.royalBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppPalette.goldDark.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${m.date} ${m.time.isNotEmpty ? m.time : ''}',
                            style: const TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الحضور: $present/$total ($percentage%)${m.location.isNotEmpty ? " • ${m.location}" : ""}',
                      style: const TextStyle(color: AppPalette.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 20),
                onPressed: () async {
                  await MeetingService.instance.deleteMeeting(m.id);
                  if (_selectedMeetingId == m.id) {
                    _selectedMeetingId = null;
                  }
                  setState(() {});
                  _showSnack('تم حذف الاجتماع');
                },
              ),
              const Icon(Icons.chevron_left, color: AppPalette.muted),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Add Meeting Form ──────────────────────────────────────────

  Widget _buildAddMeetingForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('📅 اجتماع جديد لأولياء الأمور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
          const SizedBox(height: 6),
          const Text('أدخل بيانات الاجتماع، ثم ستتمكن من تسجيل حضور الطلاب.', style: TextStyle(color: AppPalette.muted, fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _field('عنوان الاجتماع *', _titleController, span2: true),
              _field('التاريخ *', _dateController),
              _field('الوقت', _timeController),
              _field('المكان', _locationController, span2: true),
              _field('ملاحظات', _notesController, span2: true, maxLines: 3),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _actionButton('💾 حفظ الاجتماع', AppPalette.goldDark, Colors.white, _addMeeting),
              _actionButton('إلغاء', Colors.white, const Color(0xFF667586), () => setState(() => _view = 'list')),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Attendance View ───────────────────────────────────────────

  Widget _buildAttendanceView() {
    if (_selectedMeetingId == null) {
      return const Text('اختر اجتماعاً أولاً', style: TextStyle(color: AppPalette.muted));
    }

    final meeting = MeetingService.instance.meetingById(_selectedMeetingId!);
    if (meeting == null) {
      return const Text('الاجتماع غير موجود', style: TextStyle(color: AppPalette.muted));
    }

    final attendance = MeetingService.instance.attendanceForMeeting(_selectedMeetingId!);
    final present = attendance.where((a) => a.status == 'hader').length;
    final total = attendance.length;

    return Column(
      children: <Widget>[
        // Meeting info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.line),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 16)),
                    Text('${meeting.date} ${meeting.time}', style: const TextStyle(color: AppPalette.muted)),
                  ],
                ),
              ),
              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppPalette.leafGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$present / $total حاضر', style: const TextStyle(color: AppPalette.leafGreen, fontWeight: FontWeight.w800)),
                ),
              const SizedBox(width: 8),
              _actionButton('🖨️ طباعة التقرير', AppPalette.royalBlue, Colors.white, () => _printReport(_selectedMeetingId!)),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Generate list button
        if (total == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _actionButton('🔄 تجهيز قائمة الحضور (${widget.students.length} طالب)', AppPalette.goldDark, Colors.white, _generateAttendanceList),
          ),

        const SizedBox(height: 8),

        // Attendance grid
        ...attendance.map((a) => _buildAttendanceRow(a)),
        if (attendance.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('لم يتم تجهيز قائمة الحضور بعد. اضغط على "تجهيز قائمة الحضور".', style: TextStyle(color: AppPalette.muted)),
          ),
      ],
    );
  }

  Widget _buildAttendanceRow(MeetingAttendance a) {
    final isPresent = a.status == 'hader';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isPresent ? 0.92 : 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPresent ? AppPalette.leafGreen.withOpacity(0.3) : AppPalette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final newStatus = isPresent ? 'ghaeb' : 'hader';
          _saveAttendance(_selectedMeetingId!, a.studentId, newStatus);
          setState(() {});
        },
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isPresent ? AppPalette.leafGreen : AppPalette.roseRed,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.w600, color: AppPalette.deepNavySoft)),
            ),
            Text('الصف ${a.grade}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
            const SizedBox(width: 12),
            Text(a.guardianName, style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── Report View ───────────────────────────────────────────────

  Widget _buildReportView() {
    if (_selectedMeetingId == null) {
      return const Text('اختر اجتماعاً أولاً', style: TextStyle(color: AppPalette.muted));
    }

    try {
      final report = MeetingService.instance.reportForMeeting(_selectedMeetingId!);
      if (report.attendanceList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(30),
          child: Text('لا توجد بيانات حضور لهذا الاجتماع', style: TextStyle(color: AppPalette.muted)),
        );
      }

      return Column(
        children: <Widget>[
          // Summary cards
          Row(
            children: <Widget>[
              _reportCard('إجمالي الطلاب', report.totalStudents.toString(), AppPalette.royalBlue),
              const SizedBox(width: 10),
              _reportCard('الحاضرون', report.presentCount.toString(), AppPalette.leafGreen),
              const SizedBox(width: 10),
              _reportCard('الغائبون', report.absentCount.toString(), AppPalette.roseRed),
              const SizedBox(width: 10),
              _reportCard('نسبة الحضور', '${report.attendancePercentage.toStringAsFixed(1)}%', AppPalette.goldDark),
            ],
          ),
          const SizedBox(height: 14),

          // Attendance list
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('📋 كشف الحضور', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft)),
                const SizedBox(height: 10),
                ...report.attendanceList.map((a) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFEEF2F7))),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            a.status == 'hader' ? Icons.check_circle : Icons.cancel,
                            color: a.status == 'hader' ? AppPalette.leafGreen : AppPalette.roseRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(a.studentName, style: const TextStyle(color: AppPalette.deepNavySoft))),
                          Text('${a.grade} - ${a.section}', style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                          const SizedBox(width: 12),
                          Text(a.status == 'hader' ? 'حاضر' : 'غائب',
                              style: TextStyle(
                                color: a.status == 'hader' ? AppPalette.leafGreen : AppPalette.roseRed,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                _actionButton('🖨️ طباعة التقرير', AppPalette.royalBlue, Colors.white, () => _printReport(_selectedMeetingId!)),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return Text('خطأ: $e', style: const TextStyle(color: AppPalette.roseRed));
    }
  }

  Widget _reportCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          children: <Widget>[
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ────────────────────────────────────────────

  Widget _field(String label, TextEditingController controller, {bool span2 = false, int maxLines = 1}) {
    return SizedBox(
      width: span2 ? 540 : 260,
      child: TextField(
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

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
