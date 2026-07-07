part of '../pages/school_shell_page.dart';

extension SchoolShellWidgets on _SchoolShellPageState {
  Widget _statusChip(String value) {
    Color background;
    Color foreground;

    switch (value) {
      case 'نشط':
      case 'نعم':
        background = const Color(0xFFE6F6EC);
        foreground = AppPalette.leafGreen;
        break;
      case 'منقطع':
      case 'لا':
        background = const Color(0xFFFDE9E8);
        foreground = AppPalette.roseRed;
        break;
      case 'معفى من رسوم النقل':
        background = const Color(0xFFF7F3EA);
        foreground = AppPalette.goldDark;
        break;
      default:
        background = const Color(0xFFEDF6FF);
        foreground = AppPalette.royalBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _studentAvatar(
    StudentRecord student, {
    double size = 44,
    double borderWidth = 0,
  }) {
    final hasPhoto = _fileStorage.fileExistsSync(student.studentPhotoPath);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto
            ? null
            : const LinearGradient(
                colors: <Color>[Color(0xFF1D4D9C), Color(0xFF377FD8)],
              ),
        border: borderWidth > 0
            ? Border.all(color: Colors.white, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.file(File(student.studentPhotoPath), fit: BoxFit.cover)
            : Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: size * 0.56,
              ),
      ),
    );
  }

  Widget _hoverCircleAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 180),
      verticalOffset: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F45),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      child: _HoverCircleActionButton(
        color: color,
        onTap: onTap,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _hoverCircleWidgetAction({
    required Widget child,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 180),
      verticalOffset: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F45),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      child: _HoverCircleActionButton(
        color: color,
        onTap: onTap,
        child: child,
      ),
    );
  }
}


class _HoverCircleActionButton extends StatefulWidget {
  const _HoverCircleActionButton({
    required this.child,
    required this.color,
    required this.onTap,
  });

  final Widget child;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_HoverCircleActionButton> createState() => _HoverCircleActionButtonState();
}

class _HoverCircleActionButtonState extends State<_HoverCircleActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.55) : Colors.transparent,
              width: 1.6,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _hovered ? widget.color : const Color(0xFFE2EBF2),
                width: _hovered ? 1.6 : 1,
              ),
              boxShadow: _hovered
                  ? <BoxShadow>[
                      BoxShadow(
                        color: widget.color.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
