import 'dart:convert';

import '../models/meeting_models.dart';
import 'school_database_service.dart';

class MeetingService {
  MeetingService._();

  static final MeetingService instance = MeetingService._();

  List<ParentMeeting> _meetings = [];
  List<MeetingAttendance> _attendance = [];
  bool _initialized = false;

  List<ParentMeeting> get meetings => List<ParentMeeting>.unmodifiable(_meetings);

  List<MeetingAttendance> get attendance =>
      List<MeetingAttendance>.unmodifiable(_attendance);

  List<MeetingAttendance> attendanceForMeeting(String meetingId) =>
      _attendance.where((a) => a.meetingId == meetingId).toList();

  ParentMeeting? meetingById(String id) {
    for (final m in _meetings) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> init() async {
    if (_initialized) return;
    final json = await SchoolDatabaseService.instance.readJson('parent_meetings');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      _meetings = (data['meetings'] as List<dynamic>?)
              ?.map((e) => ParentMeeting.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _attendance = (data['attendance'] as List<dynamic>?)
              ?.map((e) => MeetingAttendance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }
    _initialized = true;
  }

  Future<void> addMeeting(ParentMeeting meeting) async {
    _meetings.insert(0, meeting);
    await _persist();
  }

  Future<void> deleteMeeting(String id) async {
    _meetings.removeWhere((m) => m.id == id);
    _attendance.removeWhere((a) => a.meetingId == id);
    await _persist();
  }

  Future<void> saveAttendance(List<MeetingAttendance> records) async {
    if (records.isEmpty) return;
    final meetingId = records.first.meetingId;
    _attendance.removeWhere((a) => a.meetingId == meetingId);
    _attendance.addAll(records);
    await _persist();
  }

  Future<void> updateAttendanceStatus(String meetingId, int studentId, String status) async {
    final index = _attendance.indexWhere(
      (a) => a.meetingId == meetingId && a.studentId == studentId,
    );
    if (index >= 0) {
      _attendance[index] = _attendance[index].copyWith(status: status);
    }
    await _persist();
  }

  MeetingReport reportForMeeting(String meetingId, {List<int>? allStudentIds}) {
    final meeting = meetingById(meetingId);
    if (meeting == null) {
      throw Exception('Meeting not found');
    }
    final attendanceList = attendanceForMeeting(meetingId);
    final present = attendanceList.where((a) => a.status == 'hader').length;
    final absent = attendanceList.where((a) => a.status == 'ghaeb').length;
    final total = attendanceList.length;
    final percentage = total > 0 ? (present / total * 100) : 0.0;

    return MeetingReport(
      meeting: meeting,
      totalStudents: total,
      presentCount: present,
      absentCount: absent,
      attendancePercentage: percentage,
      attendanceList: attendanceList,
    );
  }

  /// Get attendance status for a student across all meetings
  String? lastMeetingStatusForStudent(int studentId) {
    final sorted =
        List<ParentMeeting>.from(_meetings)..sort((a, b) => b.date.compareTo(a.date));
    for (final meeting in sorted) {
      for (final att in _attendance) {
        if (att.meetingId == meeting.id && att.studentId == studentId) {
          return att.status;
        }
      }
    }
    return null;
  }

  String? lastMeetingDateForStudent(int studentId) {
    final sorted =
        List<ParentMeeting>.from(_meetings)..sort((a, b) => b.date.compareTo(a.date));
    for (final meeting in sorted) {
      for (final att in _attendance) {
        if (att.meetingId == meeting.id && att.studentId == studentId) {
          return meeting.date;
        }
      }
    }
    return null;
  }

  Future<void> _persist() async {
    await SchoolDatabaseService.instance.saveJson('parent_meetings', {
      'meetings': _meetings.map((m) => m.toJson()).toList(),
      'attendance': _attendance.map((a) => a.toJson()).toList(),
    });
  }
}
