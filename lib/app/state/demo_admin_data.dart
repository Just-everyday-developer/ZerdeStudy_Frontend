// Demo data for the admin panel

class AdminUserEntry {
  const AdminUserEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.lastLoginAt,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'Student', 'Teacher', 'Moderator', 'Admin'
  final String status; // 'Active', 'Banned', 'Pending'
  final String joinedAt;
  final String lastLoginAt;
}

const List<AdminUserEntry> kAdminUsers = [
  AdminUserEntry(
    id: 'u1',
    name: 'Talgat',
    email: 'talgat@example.com',
    role: 'Admin',
    status: 'Active',
    joinedAt: '12 Jan 2026',
    lastLoginAt: 'Just now',
  ),
  AdminUserEntry(
    id: 'u2',
    name: 'Nursultan',
    email: 'nur@zerde.kz',
    role: 'Moderator',
    status: 'Active',
    joinedAt: '15 Jan 2026',
    lastLoginAt: '2 hours ago',
  ),
  AdminUserEntry(
    id: 'u3',
    name: 'Mira',
    email: 'mira@example.com',
    role: 'Teacher',
    status: 'Active',
    joinedAt: '20 Jan 2026',
    lastLoginAt: 'Yesterday',
  ),
  AdminUserEntry(
    id: 'u4',
    name: 'Dias',
    email: 'dias@test.kz',
    role: 'Student',
    status: 'Banned',
    joinedAt: '01 Feb 2026',
    lastLoginAt: '1 month ago',
  ),
  AdminUserEntry(
    id: 'u5',
    name: 'Aruzhan',
    email: 'aru@example.com',
    role: 'Student',
    status: 'Active',
    joinedAt: '05 Feb 2026',
    lastLoginAt: '3 hours ago',
  ),
];

class AdminSystemMetric {
  const AdminSystemMetric({
    required this.label,
    required this.value,
    required this.trend, // 'up', 'down', 'stable'
    required this.status, // 'good', 'warning', 'critical'
  });

  final String label;
  final String value;
  final String trend;
  final String status;
}

const List<AdminSystemMetric> kAdminMetrics = [
  AdminSystemMetric(label: 'CPU Load', value: '14%', trend: 'stable', status: 'good'),
  AdminSystemMetric(label: 'Memory Usage', value: '2.4 GB / 8 GB', trend: 'up', status: 'good'),
  AdminSystemMetric(label: 'Active Connections', value: '1,240', trend: 'up', status: 'good'),
  AdminSystemMetric(label: 'Database Latency', value: '12ms', trend: 'stable', status: 'good'),
  AdminSystemMetric(label: 'Storage', value: '68%', trend: 'up', status: 'warning'),
];
