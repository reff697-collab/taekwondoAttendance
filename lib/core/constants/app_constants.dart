import 'package:flutter/material.dart';
import 'app_colors.dart';

enum BeltRank {
  putih,
  kuning,
  kuningStrip,
  hijau,
  hijauStrip,
  biru,
  biruStrip,
  merah,
  merahStrip,
  hitamDan1,
  hitamDan2,
  hitamDan3,
  hitamDan4,
}

extension BeltRankExtension on BeltRank {
  String get displayName {
    switch (this) {
      case BeltRank.putih:
        return 'Sabuk Putih';
      case BeltRank.kuning:
        return 'Sabuk Kuning';
      case BeltRank.kuningStrip:
        return 'Sabuk Kuning Strip';
      case BeltRank.hijau:
        return 'Sabuk Hijau';
      case BeltRank.hijauStrip:
        return 'Sabuk Hijau Strip';
      case BeltRank.biru:
        return 'Sabuk Biru';
      case BeltRank.biruStrip:
        return 'Sabuk Biru Strip';
      case BeltRank.merah:
        return 'Sabuk Merah';
      case BeltRank.merahStrip:
        return 'Sabuk Merah Strip';
      case BeltRank.hitamDan1:
        return 'Dan I Black Belt';
      case BeltRank.hitamDan2:
        return 'Dan II Black Belt';
      case BeltRank.hitamDan3:
        return 'Dan III Black Belt';
      case BeltRank.hitamDan4:
        return 'Dan IV Black Belt';
    }
  }

  Color get primaryColor {
    switch (this) {
      case BeltRank.putih:
        return AppColors.beltWhite;
      case BeltRank.kuning:
      case BeltRank.kuningStrip:
        return AppColors.beltYellow;
      case BeltRank.hijau:
      case BeltRank.hijauStrip:
        return AppColors.beltGreen;
      case BeltRank.biru:
      case BeltRank.biruStrip:
        return AppColors.beltBlue;
      case BeltRank.merah:
      case BeltRank.merahStrip:
        return AppColors.beltRed;
      case BeltRank.hitamDan1:
      case BeltRank.hitamDan2:
      case BeltRank.hitamDan3:
      case BeltRank.hitamDan4:
        return AppColors.beltBlack;
    }
  }

  Color? get stripColor {
    switch (this) {
      case BeltRank.kuningStrip:
        return AppColors.beltGreen;
      case BeltRank.hijauStrip:
        return AppColors.beltBlue;
      case BeltRank.biruStrip:
        return AppColors.beltRed;
      case BeltRank.merahStrip:
        return AppColors.beltBlack;
      default:
        return null;
    }
  }
}

enum AttendanceStatus {
  hadir,
  izin,
  alfa,
  unselected,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get code {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'H';
      case AttendanceStatus.izin:
        return 'I';
      case AttendanceStatus.alfa:
        return 'A';
      case AttendanceStatus.unselected:
        return '-';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'Hadir';
      case AttendanceStatus.izin:
        return 'Izin';
      case AttendanceStatus.alfa:
        return 'Alfa';
      case AttendanceStatus.unselected:
        return 'Belum Absen';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.hadir:
        return AppColors.statusPresent;
      case AttendanceStatus.izin:
        return AppColors.statusExcused;
      case AttendanceStatus.alfa:
        return AppColors.statusAbsent;
      case AttendanceStatus.unselected:
        return AppColors.secondary;
    }
  }
}

