// ============================================================
// date_ranges — نقاط البداية والنهاية للفلاتر الزمنية.
//
// قرار المستخدم (خطة الإصلاح Phase B):
//  • التواريخ المستقبلية مبتدخلش في "مصروفات الشهر/الأسبوع/اليوم" ولا الرصيد الحالي.
//  • الأسبوع تقويمي بيبدأ حسب لغة/منطقة الجهاز.
// كل الدوال pure عشان تُختبر لوحدها، وبتنتج strings بصيغة yyyy-MM-dd
// متوافقة مع تخزين SQL (الفترة علئل النهاية النصية كحد شامل).
// ============================================================

import 'dart:ui' as ui;

import 'package:intl/intl.dart';

String fmtDay(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// الحد الشامل لليوم: yyyy-MM-dd مع الوقت (يعني بيشمل كل سجلات اليوم حتى T23:59).
String dayEndStr(DateTime today) => fmtDay(today);

/// بداية الشهر التقويمي.
String monthStart(DateTime now) => fmtDay(DateTime(now.year, now.month, 1));

/// بداية الأسبوع التقويمي حسب أول يوم في الأسبوع المطلوب.
/// [firstDayOfWeek] من قيم DateTime: monday=1 … sunday=7.
DateTime weekStartDateTime(DateTime now, int firstDayOfWeek) {
  final daysSinceStart = (now.weekday - firstDayOfWeek + 7) % 7;
  return DateTime(now.year, now.month, now.day - daysSinceStart);
}

String weekStart(DateTime now, int firstDayOfWeek) =>
    fmtDay(weekStartDateTime(now, firstDayOfWeek));

/// أول يوم في الأسبوع القادم (حد غير شامل للأحد/السابع من الأسبوع الجاري).
String weekEndExclusive(DateTime now, int firstDayOfWeek) {
  final start = weekStartDateTime(now, firstDayOfWeek);
  return fmtDay(DateTime(start.year, start.month, start.day + 7));
}

/// أول يوم في السنة التقويمية.
String yearStart(DateTime now) => fmtDay(DateTime(now.year, 1, 1));

/// يوم بعد [dateStr] (yyyy-MM-dd) — حد غير شامل لمقارنات `<` (آمن ضد التوقيت الصيفي DST).
String nextDayStr(String dateStr) {
  final dayPart = dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
  final d = DateTime.parse('${dayPart}T00:00');
  return fmtDay(DateTime(d.year, d.month, d.day + 1));
}

/// هل تاريخ السجل (ممكن فيه وقت) صاحب يوم معين؟
bool sameDayStr(String recordDate, String dayStr) {
  return recordDate.split('T').first == dayStr;
}

/// هل تاريخ السجل قبل/في يوم معين (لتحليل) — عند التطبيع دوما التدقيق بوقت.
bool isOnOrBefore(String recordDate, String dayStr) {
  final rec = recordDate.split('T').first;
  return rec.compareTo(dayStr) <= 0;
}

/// أول يوم في الأسبوع حسب اللغة/المنطقة: يفهم عربي (السبت)،
/// أوروبي (الاتنين)، وافتراضي إنجليزي (الاتنين).
int firstDayOfWeekForLocale(String languageCode) {
  switch (languageCode.toLowerCase()) {
    case 'ar':
      return DateTime.saturday;
    case 'de':
    case 'fr':
    case 'es':
    case 'it':
    case 'nl':
      return DateTime.monday;
    case 'en':
      return DateTime.monday; // التطبيق مصمم عربي/إنجليزي — الاتنين هو الافتراضي
    default:
      return DateTime.monday;
  }
}

/// بداية الأسبوع التقويمي من لغة النظام الحالية.
String weekStartForSystemLocale(DateTime now) {
  final lang = ui.PlatformDispatcher.instance.locale.languageCode;
  return weekStart(now, firstDayOfWeekForLocale(lang));
}

/// نهاية الأسبوع (غير شاملة) من لغة النظام الحالية.
String weekEndExclusiveForSystemLocale(DateTime now) {
  final lang = ui.PlatformDispatcher.instance.locale.languageCode;
  return weekEndExclusive(now, firstDayOfWeekForLocale(lang));
}
