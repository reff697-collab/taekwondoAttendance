import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/notification_helper.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';

class ScheduleFormScreen extends StatefulWidget {
  final ScheduleModel? schedule;

  const ScheduleFormScreen({super.key, this.schedule});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  late String _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nameController = TextEditingController(text: s?.sessionName ?? '');
    _categoryController = TextEditingController(text: s?.category ?? 'Reguler');
    _selectedDay = s?.day ?? 'Senin';

    _startTime = s != null ? _parseTime(s.startTime) : const TimeOfDay(hour: 16, minute: 0);
    _endTime = s != null ? _parseTime(s.endTime) : const TimeOfDay(hour: 18, minute: 0);
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 16, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  int _dayToWeekday(String day) {
    switch (day) {
      case 'Senin':
        return 1;
      case 'Selasa':
        return 2;
      case 'Rabu':
        return 3;
      case 'Kamis':
        return 4;
      case 'Jumat':
        return 5;
      case 'Sabtu':
        return 6;
      case 'Minggu':
        return 7;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
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
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduleProvider = context.read<ScheduleProvider>();
    final isEdit = widget.schedule != null;

    final startStr = _formatTimeOfDay(_startTime);
    final endStr = _formatTimeOfDay(_endTime);
    final weekday = _dayToWeekday(_selectedDay);

    if (isEdit) {
      final updated = widget.schedule!.copyWith(
        sessionName: _nameController.text.trim(),
        day: _selectedDay,
        dayOfWeek: weekday,
        startTime: startStr,
        endTime: endStr,
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      );
      await scheduleProvider.updateSchedule(updated);
      if (mounted) {
        NotificationHelper.showSuccess(context, 'Jadwal latihan berhasil diperbarui');
        Navigator.pop(context);
      }
    } else {
      await scheduleProvider.addSchedule(
        sessionName: _nameController.text.trim(),
        day: _selectedDay,
        dayOfWeek: weekday,
        startTime: startStr,
        endTime: endStr,
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      );
      if (mounted) {
        NotificationHelper.showSuccess(context, 'Jadwal latihan baru berhasil ditambahkan');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.schedule != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Jadwal Latihan' : 'Tambah Jadwal Latihan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Sesi Latihan',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _nameController,
                        label: 'Nama Sesi / Kelas *',
                        hint: 'contoh: Kyorugi & Sparring Sore',
                        prefixIcon: Icons.sports_martial_arts_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama sesi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pilihan Hari
                      Text(
                        'Hari Latihan *',
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
                          child: DropdownButton<String>(
                            value: _selectedDay,
                            isExpanded: true,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDay = val;
                                });
                              }
                            },
                            items: _days.map((day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(
                                  day,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Waktu Jam Mulai & Selesai
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jam Mulai *',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickTime(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.outlineVariant),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded,
                                            size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTimeOfDay(_startTime),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jam Selesai *',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickTime(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.outlineVariant),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded,
                                            size: 18, color: AppColors.secondary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTimeOfDay(_endTime),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _categoryController,
                        label: 'Kategori / Kelompok (Opsional)',
                        hint: 'contoh: Reguler, Kadet Prestasi, Poomsae Dasar',
                        prefixIcon: Icons.category_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              PrimaryButton(
                text: isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal',
                icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

