import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/notification_helper.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class AttendanceSummaryDialog extends StatelessWidget {
  const AttendanceSummaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final authProvider = context.read<AuthProvider>();

    // total students
    final hadir = attendanceProvider.activeHadirCount;
    final izin = attendanceProvider.activeIzinCount;
    final alfa = attendanceProvider.activeAlfaCount;
    final unselected = attendanceProvider.activeUnselectedCount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Header matching Stitch design
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.fact_check_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Simpan Absensi?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan semua data kehadiran sudah sesuai sebelum menyimpan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
            const SizedBox(height: 20),

            // Summary Breakdown Chips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Hadir',
                        count: hadir,
                        color: AppColors.statusPresent,
                        icon: Icons.check_circle_rounded,
                      ),
                      Container(width: 1, height: 36, color: AppColors.outlineVariant),
                      _StatColumn(
                        label: 'Izin',
                        count: izin,
                        color: AppColors.statusExcused,
                        icon: Icons.info_rounded,
                      ),
                      Container(width: 1, height: 36, color: AppColors.outlineVariant),
                      _StatColumn(
                        label: 'Alfa',
                        count: alfa,
                        color: AppColors.statusAbsent,
                        icon: Icons.cancel_rounded,
                      ),
                    ],
                  ),
                  if (unselected > 0) ...[
                    const Divider(height: 20, color: AppColors.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 16, color: AppColors.statusExcused),
                        const SizedBox(width: 6),
                        Text(
                          '$unselected siswa belum diabsen',
                          style: const TextStyle(
                            color: AppColors.statusExcused,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons matching Stitch
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.outlineVariant, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final coach = authProvider.coachName;
                        await attendanceProvider.saveCurrentSession(coach);
                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          Navigator.pop(context); // return from attendance screen
                          NotificationHelper.showSuccess(
                            context,
                            'Absensi sesi ${attendanceProvider.currentSchedule?.sessionName ?? ""} berhasil disimpan!',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ya, Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}


