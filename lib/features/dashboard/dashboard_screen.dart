import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../attendance/session_picker_dialog.dart';
import '../attendance/attendance_sheet_screen.dart';
import '../students/student_list_screen.dart';
import '../schedule/schedule_list_screen.dart';
import '../recap/monthly_recap_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    final todaySchedule = scheduleProvider.todaySchedule;
    final totalStudents = studentProvider.totalActiveStudents;
    final avgAttendance = attendanceProvider.averageMonthlyAttendancePercentage;
    final recentAttendances = attendanceProvider.allAttendances.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sports_martial_arts_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'MARTIAL ATTENDANCE',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Greeting & Instructor Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang kembali,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.coachName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        auth.coachDan,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Session Card matching Stitch highlight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        const Text(
                          'SESI LATIHAN HARI INI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const SessionPickerDialog(),
                            );
                          },
                          child: const Text(
                            'Ganti Sesi',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      todaySchedule?.sessionName ?? 'Latihan Taekwondo Reguler',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatter.formatDayName(DateTime.now())} • ${todaySchedule != null ? "${todaySchedule.startTime} - ${todaySchedule.endTime}" : "16:00 - 18:00"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (todaySchedule != null) {
                            attendanceProvider.startNewSession(
                              schedule: todaySchedule,
                              students: studentProvider.allStudents,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AttendanceSheetScreen(),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => const SessionPickerDialog(),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                        label: const Text(
                          'Mulai Absensi Hari Ini',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Grid
              Text(
                'Menu Cepat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.groups_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppColors.beltBlue,
                      title: 'Data Siswa',
                      subtitle: '$totalStudents Siswa Aktif',
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StudentListScreen()),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_month_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: AppColors.statusExcused,
                      title: 'Jadwal',
                      subtitle: '${scheduleProvider.schedules.length} Sesi Latihan',
                      onTap: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(3);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScheduleListScreen()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.analytics_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: AppColors.statusPresent,
                title: 'Rekap & Laporan Kehadiran',
                subtitle: 'Rata-rata kehadiran ${avgAttendance.toStringAsFixed(0)}% bulan ini',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondary),
                onTap: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(2);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MonthlyRecapScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Recent Activities Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Absensi Terakhir',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      if (onNavigateTab != null) {
                        onNavigateTab!(2);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MonthlyRecapScreen()),
                        );
                      }
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (recentAttendances.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Center(
                    child: Text('Belum ada riwayat absensi.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentAttendances.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final att = recentAttendances[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fact_check_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  att.sessionName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatShortDate(att.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${att.totalHadir} / ${att.totalStudents} Hadir',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.statusPresent,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${att.attendancePercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}



