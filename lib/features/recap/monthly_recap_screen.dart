import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/student_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';

class MonthlyRecapScreen extends StatelessWidget {
  const MonthlyRecapScreen({super.key});

  void _showStudentDetailRecap(
    BuildContext context,
    StudentModel student,
    StudentMonthlyStat stat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: student.beltRank.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            student.beltRank.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.outlineVariant),

                // Stat Counters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailBox(label: 'Total Sesi', value: '${stat.totalSessions}'),
                    _DetailBox(
                        label: 'Hadir',
                        value: '${stat.hadirCount}',
                        color: AppColors.statusPresent),
                    _DetailBox(
                        label: 'Izin',
                        value: '${stat.izinCount}',
                        color: AppColors.statusExcused),
                    _DetailBox(
                        label: 'Alfa',
                        value: '${stat.alfaCount}',
                        color: AppColors.statusAbsent),
                  ],
                ),
                const SizedBox(height: 16),

                // Percentage Indicator
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Persentase Kehadiran',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        '${stat.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: stat.percentage >= 75
                              ? AppColors.statusPresent
                              : (stat.percentage >= 50
                                  ? AppColors.statusExcused
                                  : AppColors.statusAbsent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final studentProvider = context.watch<StudentProvider>();

    final students = studentProvider.allStudents;
    final stats = attendanceProvider.getStudentMonthlyStats(students);

    final totalSessions = attendanceProvider.totalMonthlySessions;
    final avgAttendance = attendanceProvider.averageMonthlyAttendancePercentage;
    final lowAttendanceCount =
        stats.where((s) => s.totalSessions > 0 && s.percentage < 50.0).length;

    final monthLabel =
        DateFormatter.formatMonthYear(attendanceProvider.selectedRecapMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rekap Kehadiran Bulanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Header matching Stitch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performa Dojang',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Evaluasi kehadiran siswa per bulan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => attendanceProvider.previousMonth(),
                      ),
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => attendanceProvider.nextMonth(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bento Grid Summary Cards
            Row(
              children: [
                // Total Sessions
                Expanded(
                  child: _BentoCard(
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppColors.tertiary,
                    label: 'TOTAL SESI',
                    value: '$totalSessions',
                    subtext: 'Latihan bulan ini',
                  ),
                ),
                const SizedBox(width: 12),
                // Avg Attendance %
                Expanded(
                  child: _BentoCard(
                    icon: Icons.insights_rounded,
                    iconColor: AppColors.primary,
                    label: 'RATA-RATA %',
                    value: '${avgAttendance.toStringAsFixed(0)}%',
                    subtext: 'Tingkat Kehadiran',
                    progressValue: avgAttendance / 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Low Attendance Alert Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERHATIAN PELATIH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$lowAttendanceCount Siswa kehadiran < 50%',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Student Performance Table
            Text(
              'Rincian Kehadiran per Siswa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),

            if (stats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Belum ada data siswa.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = stats[index];
                  final student = item.student;
                  final pct = item.percentage;

                  Color progressColor = AppColors.statusPresent;
                  if (pct < 50) {
                    progressColor = AppColors.statusAbsent;
                  } else if (pct < 75) {
                    progressColor = AppColors.statusExcused;
                  }

                  return InkWell(
                    onTap: () => _showStudentDetailRecap(context, student, item),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: student.beltRank.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      student.beltRank.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Counters summary
                              Row(
                                children: [
                                  _MiniChip(
                                      label: 'H: ${item.hadirCount}',
                                      color: AppColors.statusPresent),
                                  const SizedBox(width: 4),
                                  _MiniChip(
                                      label: 'I: ${item.izinCount}',
                                      color: AppColors.statusExcused),
                                  const SizedBox(width: 4),
                                  _MiniChip(
                                      label: 'A: ${item.alfaCount}',
                                      color: AppColors.statusAbsent),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: progressColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.totalSessions > 0 ? pct / 100 : 0,
                              minHeight: 5,
                              backgroundColor: AppColors.surfaceContainerLow,
                              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;
  final double? progressValue;

  const _BentoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 4,
                backgroundColor: AppColors.surfaceContainerLow,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DetailBox({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}


