import 'package:flutter/material.dart';
import 'package:frontend_flutter/core/extensions/context_size.dart';

enum AuthRole { student, instructor }

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AuthRole value;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final u = context.u;

    return Container(
      padding: EdgeInsets.all(6 * u),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14 * u),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleChip(
              u: u,
              selected: value == AuthRole.student,
              icon: Icons.school_outlined,
              text: 'Student',
              onTap: () => onChanged(AuthRole.student),
            ),
          ),
          SizedBox(width: 8 * u),
          Expanded(
            child: _RoleChip(
              u: u,
              selected: value == AuthRole.instructor,
              icon: Icons.person_outline,
              text: 'Instructor',
              onTap: () => onChanged(AuthRole.instructor),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.u,
    required this.selected,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final double u;
  final bool selected;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF2C76C5) : Colors.transparent;
    final fg = selected ? Colors.white : const Color(0xFF2C76C5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * u),
      child: Container(
        height: 44 * u,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12 * u),
          border: selected
              ? null
              : Border.all(color: const Color(0xFF2C76C5).withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18 * u, color: fg),
            SizedBox(width: 8 * u),
            Text(
              text,
              style: TextStyle(
                fontSize: 14 * u,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
