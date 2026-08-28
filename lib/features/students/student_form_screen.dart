import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/belt_badge.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/notification_helper.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentModel? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  late BeltRank _selectedBelt;
  late DateTime _selectedJoinDate;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _phoneController = TextEditingController(text: s?.phoneNumber ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _selectedBelt = s?.beltRank ?? BeltRank.putih;
    _selectedJoinDate = s?.joinDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoinDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedJoinDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final studentProvider = context.read<StudentProvider>();
    final isEdit = widget.student != null;

    if (isEdit) {
      final updated = widget.student!.copyWith(
        name: _nameController.text.trim(),
        beltRank: _selectedBelt,
        joinDate: _selectedJoinDate,
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      await studentProvider.updateStudent(updated);
      if (mounted) {
        NotificationHelper.showSuccess(context, 'Data siswa berhasil diperbarui');
        Navigator.pop(context);
      }
    } else {
      await studentProvider.addStudent(
        name: _nameController.text.trim(),
        beltRank: _selectedBelt,
        joinDate: _selectedJoinDate,
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (mounted) {
        NotificationHelper.showSuccess(context, 'Siswa baru berhasil ditambahkan');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Data Siswa' : 'Tambah Siswa Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Siswa',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // Nama Siswa
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap Siswa *',
                        hint: 'contoh: Ahmad Pratama',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama siswa wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tingkat Sabuk Dropdown
                      Text(
                        'Tingkat Sabuk Taekwondo *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BeltRank>(
                            value: _selectedBelt,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.secondary),
                            onChanged: (BeltRank? newRank) {
                              if (newRank != null) {
                                setState(() {
                                  _selectedBelt = newRank;
                                });
                              }
                            },
                            items: BeltRank.values.map((BeltRank rank) {
                              return DropdownMenuItem<BeltRank>(
                                value: rank,
                                child: BeltBadge(beltRank: rank, showLabel: true, size: 14),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Gabung
                      Text(
                        'Tanggal Bergabung *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickJoinDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined,
                                  color: AppColors.secondary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                DateFormatter.formatShortDate(_selectedJoinDate),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.secondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // No Telepon (Opsional)
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon / WhatsApp (Opsional)',
                        hint: '0812xxxxxxxx',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Catatan Tambahan (Opsional)
                      CustomTextField(
                        controller: _notesController,
                        label: 'Catatan Khusus (Opsional)',
                        hint: 'Misal: Riwayat asma, atlet kejurda...',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              PrimaryButton(
                text: isEdit ? 'Simpan Perubahan' : 'Tambah Siswa',
                icon: isEdit ? Icons.save_rounded : Icons.person_add_rounded,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

