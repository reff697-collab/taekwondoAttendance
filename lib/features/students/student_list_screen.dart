import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/notification_helper.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              const Text('Hapus Siswa?'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${student.name}" dari daftar aktif siswa?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<StudentProvider>().deleteStudent(student.id);
                Navigator.pop(ctx);
                NotificationHelper.showSuccess(context, '${student.name} telah dihapus');
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
    final studentProvider = context.watch<StudentProvider>();
    final students = studentProvider.filteredStudents;
    final selectedBelt = studentProvider.selectedBeltFilter;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Siswa Taekwondo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => studentProvider.loadStudents(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => studentProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari nama siswa...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          studentProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Belt Filter Horizontal Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _BeltFilterChip(
                  label: 'Semua (${studentProvider.allStudents.length})',
                  isSelected: selectedBelt == null,
                  onTap: () => studentProvider.setBeltFilter(null),
                ),
                ...BeltRank.values.map((rank) {
                  final count = studentProvider.allStudents
                      .where((s) => s.beltRank == rank)
                      .length;
                  if (count == 0 && selectedBelt != rank) return const SizedBox.shrink();

                  return _BeltFilterChip(
                    label: '${rank.displayName} ($count)',
                    color: rank.primaryColor,
                    isSelected: selectedBelt == rank,
                    onTap: () => studentProvider.setBeltFilter(
                      selectedBelt == rank ? null : rank,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Students List
          Expanded(
            child: studentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded,
                                size: 54, color: AppColors.secondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada data siswa ditemukan',
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: students.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final student = students[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.outlineVariant),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                children: [
                                  // Belt color bar matching Stitch design
                                  Container(
                                    width: 5,
                                    height: 64,
                                    color: student.beltRank.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: student.beltRank.primaryColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: student.beltRank == BeltRank.putih
                                                        ? AppColors.outlineVariant
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                student.beltRank.displayName,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '• Bergabung ${DateFormatter.formatShortDate(student.joinDate)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.secondary.withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Action Popup
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: AppColors.secondary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                StudentFormScreen(student: student),
                                          ),
                                        );
                                      } else if (action == 'delete') {
                                        _showDeleteConfirmation(context, student);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit Siswa'),
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
                                            Text('Hapus',
                                                style: TextStyle(color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Tambah Siswa',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BeltFilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _BeltFilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

