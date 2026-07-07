class ParentMeeting {
  const ParentMeeting({
    required this.id,
    required this.title,
    required this.date,
    this.time = '',
    this.location = '',
    this.grades = const [],
    this.notes = '',
    required this.createdAt,
  });

  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final List<String> grades; // empty = all grades
  final String notes;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'location': location,
        'grades': grades,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory ParentMeeting.fromJson(Map<String, dynamic> json) => ParentMeeting(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        grades: (json['grades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        notes: json['notes']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

class MeetingAttendance {
  const MeetingAttendance({
    required this.meetingId,
    required this.studentId,
    this.studentName = '',
    this.grade = '',
    this.section = '',
    this.guardianName = '',
    this.status = 'ghaeb', // 'hader' or 'ghaeb'
    this.notes = '',
  });

  final String meetingId;
  final int studentId;
  final String studentName;
  final String grade;
  final String section;
  final String guardianName;
  final String status;
  final String notes;

  Map<String, dynamic> toJson() => {
        'meetingId': meetingId,
        'studentId': studentId,
        'studentName': studentName,
        'grade': grade,
        'section': section,
        'guardianName': guardianName,
        'status': status,
        'notes': notes,
      };

  factory MeetingAttendance.fromJson(Map<String, dynamic> json) => MeetingAttendance(
        meetingId: json['meetingId']?.toString() ?? '',
        studentId: (json['studentId'] as num?)?.toInt() ?? 0,
        studentName: json['studentName']?.toString() ?? '',
        grade: json['grade']?.toString() ?? '',
        section: json['section']?.toString() ?? '',
        guardianName: json['guardianName']?.toString() ?? '',
        status: json['status']?.toString() ?? 'ghaeb',
        notes: json['notes']?.toString() ?? '',
      );

  MeetingAttendance copyWith({
    String? meetingId,
    int? studentId,
    String? studentName,
    String? grade,
    String? section,
    String? guardianName,
    String? status,
    String? notes,
  }) {
    return MeetingAttendance(
      meetingId: meetingId ?? this.meetingId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      guardianName: guardianName ?? this.guardianName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class MeetingReport {
  const MeetingReport({
    required this.meeting,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
    required this.attendanceList,
  });

  final ParentMeeting meeting;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;
  final List<MeetingAttendance> attendanceList;
}
