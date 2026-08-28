import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/notification_helper.dart';
import '../../providers/attendance_provider.dart';

import 'attendance_summary_dialog.dart';

class AttendanceSheetScreen extends StatefulWidget {
  const AttendanceSheetScreen({super.key});

  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNoteBottomSheet(
      BuildContext context, String studentId, String studentName, String? currentNote) {
    final noteController = TextEditingController(text: currentNote ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keterangan Absensi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Siswa: $studentName (Opsional)',
                style: TextStyle(color: AppColors.secondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Misal: Sakit demam, Izin ujian sekolah, Dispensasi lomba...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (currentNote != null && currentNote.isNotEmpty) ...[
                    TextButton(
                      onPressed: () {
                        context.read<AttendanceProvider>().setStudentNote(studentId, '');
                        Navigator.pop(ctx);
                        NotificationHelper.showInfo(context, 'Keterangan dihapus');
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Hapus Catatan'),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AttendanceProvider>()
                          .setStudentNote(studentId, noteController.text);
                      Navigator.pop(ctx);
                      NotificationHelper.showInfo(context, 'Keterangan disimpan');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final schedule = attendanceProvider.currentSchedule;
    final records = attendanceProvider.currentRecords;

    final dateStr = DateFormatter.formatFullDate(attendanceProvider.currentSessionDate);

    final filteredRecords = records.values.where((r) {
      return _searchQuery.isEmpty ||
          r.studentName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule?.sessionName ?? 'Absensi Sesi Latihan',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              attendanceProvider.markAllPresent();
              NotificationHelper.showInfo(context, 'Semua siswa ditandai Hadir');
            },
            icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
            label: const Text(
              'Semua Hadir',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Sticky Live Counter Bar matching Stitch header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Kehadiran Siswa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${attendanceProvider.activeHadirCount} / ${attendanceProvider.activeTotalStudents} Hadir',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search Box
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama siswa...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      fillColor: AppColors.surfaceContainerLow,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Students
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(
                    child: Text('Tidak ada siswa yang sesuai pencarian.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredRecords[index];
                      final isSelected = item.status != AttendanceStatus.unselected;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : AppColors.outlineVariant,
                            width: isSelected ? 1.2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // Belt indicator dot & student details
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.beltRank.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: item.beltRank == BeltRank.putih
                                      ? AppColors.outlineVariant
                                      : Colors.black12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.studentName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        item.beltRank.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (item.note != null && item.note!.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryFixed,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.note!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Fast Action Buttons: [ H ] [ I ] [ A ] [ 📝 ]
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AttendanceStatusButton(
                                  label: 'H',
                                  activeColor: AppColors.statusPresent,
                                  isSelected: item.status == AttendanceStatus.hadir,
                                  onTap: () {
                                    attendanceProvider.setStudentStatus(
                                      item.studentId,
                                      item.status == AttendanceStatus.hadir
                                          ? AttendanceStatus.unselected
                                          : AttendanceStatus.hadir,
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                _AttendanceStatusButton(
                                  label: 'I',
                                  activeColor: AppColors.statusExcused,
                                  isSelected: item.status == AttendanceStatus.izin,
                                  onTap: () {
                                    attendanceProvider.setStudentStatus(
                                      item.studentId,
                                      item.status == AttendanceStatus.izin
                                          ? AttendanceStatus.unselected
                                          : AttendanceStatus.izin,
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                _AttendanceStatusButton(
                                  label: 'A',
                                  activeColor: AppColors.statusAbsent,
                                  isSelected: item.status == AttendanceStatus.alfa,
                                  onTap: () {
                                    attendanceProvider.setStudentStatus(
                                      item.studentId,
                                      item.status == AttendanceStatus.alfa
                                          ? AttendanceStatus.unselected
                                          : AttendanceStatus.alfa,
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_note_rounded, size: 22),
                                      color: item.note != null && item.note!.isNotEmpty
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                      onPressed: () {
                                        _showNoteBottomSheet(
                                          context,
                                          item.studentId,
                                          item.studentName,
                                          item.note,
                                        );
                                      },
                                    ),
                                    if (item.note != null && item.note!.isNotEmpty)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // FAB matching Stitch Submit Attendance
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AttendanceSummaryDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text(
          'Selesai & Simpan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class _AttendanceStatusButton extends StatelessWidget {
  final String label;
  final Color activeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AttendanceStatusButton({
    required this.label,
    required this.activeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : activeColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : activeColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}


