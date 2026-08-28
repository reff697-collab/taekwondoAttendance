import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/notification_helper.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../attendance/attendance_sheet_screen.dart';
import 'schedule_form_screen.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Jadwal?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus sesi "${schedule.sessionName}" hari ${schedule.day}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ScheduleProvider>().deleteSchedule(schedule.id);
                Navigator.pop(ctx);
                NotificationHelper.showSuccess(context, 'Jadwal telah dihapus');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final studentProvider = context.read<StudentProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    final schedules = scheduleProvider.schedules;
    final currentDay = DateTime.now().weekday;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Latihan Dojang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => scheduleProvider.loadSchedules(),
          ),
        ],
      ),
      body: schedules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 54, color: AppColors.secondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada jadwal latihan.',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: schedules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sch = schedules[index];
                final isToday = sch.dayOfWeek == currentDay;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                      width: isToday ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isToday ? AppColors.primary : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                sch.day.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isToday ? Colors.white : AppColors.onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (sch.category != null && sch.category!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Text(
                                  sch.category!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded,
                                  size: 20, color: AppColors.secondary),
                              onSelected: (action) {
                                if (action == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScheduleFormScreen(schedule: sch),
                                    ),
                                  );
                                } else if (action == 'delete') {
                                  _showDeleteConfirmation(context, sch);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 18, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sch.sessionName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${sch.startTime} - ${sch.endTime}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quick Action to start attendance for this schedule
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              attendanceProvider.startNewSession(
                                schedule: sch,
                                students: studentProvider.allStudents,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AttendanceSheetScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                            label: const Text('Buka Absensi Sesi Ini'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primaryFixedDim),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScheduleFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

