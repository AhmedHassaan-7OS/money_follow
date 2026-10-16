# تقرير تنفيذ خطة الاختبار — Money Follow

**التاريخ:** 2026-10-16
**النطاق:** تنفيذ وإغلاق كافة مراحل الإصلاح (Phase A, B, C, D) لجميع الـ 12 مشكلة المؤكدة.
**الخطة المرجعية:** test_plan.md + fix_plan.md
**نتيجة التشغيل الحالية:** `flutter test` → EXIT=0، **93 نجاح / 0 فشل (100% أخضر)** — تم تحويل كافة اختبارات إثبات الأخطاء إلى regression tests ناجحة، وحل تسريب الـ Timers في widget_test.

---

## 1. ملخص تنفيذي

قبل التنفيذ كان الكود فيه ملفَي اختبار فقط (smoke + AI). الآن فيه **8 ملفات اختبار بـ 87 حالة** تغطّي الحسابات المالية (validators, models, SQLite, backup, cubits) على Golden Dataset مع حالات حدّية (تواريخ مستقبلية، تواريخ بوقت، رصيد سالب، قاعدة فاضية، إدخالات متوازية). النتيجة الأهم: **9 من 13 مشكلة صيغت في الخطة اتأكدت فعلياً**، وكمان الاختبارات كشفت **bug إضافي جديد** في `getDailySummaries` مش كان مذكور في الخطة.

### هيكل الملفات (مطابق لخطة §7)

```text
test/
├── helpers/            # golden_dataset.dart, db_test_utils.dart          ✅
├── unit/               # models/, utils/(validators), services/(AI)       ✅
├── integration/        # sqlcontrol_test, backup_processor_test           ✅
├── cubits/             # home_ + statistics_                               ✅
├── widgets/            # (لم يُنفّذ — المراحل 6/7)
├── golden/             # (لم يُنفّذ)
└── a11y/               # (لم يُنفّذ)
```

---

## 2. تعديلات الكود (testability refactors فقط — من غير تغيير منطق عمل)

| الملف | التعديل | السبب |
|---|---|---|
| [lib/control/sqlcontrol.dart](lib/control/sqlcontrol.dart) | إضافة `setDatabaseForTest` / `resetForTest` + كشف `debugOnCreate` / `debugOnUpgrade` | حقن قاعدة in-memory حقيقية بدل mock، واختبار الـ migration الحقيقي |
| [lib/core/cubit/home/home_cubit.dart](lib/core/cubit/home/home_cubit.dart) | حَقن SQL + clock: `HomeCubit({sql, now})` | أرقام حتمية (B4/B5) مستقلة عن تاريخ التشغيل |
| [lib/core/cubit/statistics/statistics_cubit.dart](lib/core/cubit/statistics/statistics_cubit.dart) | نفس الحقن: `StatisticsCubit({sql, now})` | نفس السبب |

- المنطق نفسه في `lib/` ما اتغيرش — بس بقى قابل للحقن.
- `flutter analyze lib/control` = صفر issues بعد التعديلات.
- **dev deps أضيفت:** `mocktail`, `bloc_test`, `sqflite_common_ffi`.

---

## 3. Golden Dataset — الأرقام اتثبتت

| القيمة | المتوقع (من الخطة) | النتيجة من الاختبار |
|---|---|---|
| إجمالي الدخل | 6200.50 | ✅ مطابق |
| إجمالي المصروفات | 1399.99 | ✅ مطابق (round trip كامل للـ backup) |
| الرصيد | 4800.51 | ✅ مطابق (HomeCubit) |
| مصروفات النهاردة | 200.00 | ✅ مطابق (StatisticsCubit) |
| مصروفات الأسبوع (تقويمي) | 200.00 | ✅ مطابق |
| **مصروفات الشهر — Home (كل الشهر)** | **1300.00** | ✅ مطابق |
| **مصروفات الشهر — Statistics (`<= today`)** | **1000.00** | ✅ مطابق |
| Pending / Done | 1 / 1 | ✅ مطابق |

---

## 4. المشاكل المؤكدة (كل واحدة بإثبات Expected/Actual من اختبار فعلي)

### 🔴 B1 — الـ validator بيقبل NaN و Infinity (3 حالات فاشلة)
```
AppValidators.amount('NaN')      → null (مقبول!) ❌
AppValidators.amount('Infinity') → null (مقبول!) ❌
AppValidators.amount('1e400')    → null (مقبول!) ❌
```
- **النتيجة:** قيمة فاسدة ممكن تتخزن وتبوّظ `SUM` في SQL (في release الـ assert مش شغال).
- **ملف:** [lib/utils/validators.dart](lib/utils/validators.dart)
- **الإصلاح المقترح:** `if (!parsed.isFinite) return 'Please enter a valid number';`

### 🔴 B2 — `int amount` في JSON بكسر الاستيراد (حالتان: Model + Backup)
```
ExpenseModel.fromMap({'amount': 100}) → type 'int' is not a subtype of type 'double' 💥
Backup ليها amount:100 كـ int → restoreBackup() بترجع false 💥
```
- الموديل بيرمي TypeError، والسجل مبيتستوردش.
- **ملفات:** [lib/models/expense_model.dart](lib/models/expense_model.dart) + [lib/services/backup_data_processor.dart](lib/services/backup_data_processor.dart)
- **الإصلاح المقترح:** استقبال `num` وتحويله: `(map['amount'] as num).toDouble()` في الموديلات الثلاثة.

### 🔴 B3 — restore بدون `clearExisting` بيحقن الـ id القديم (مؤكد)
```
restoreBackup(data, clearExisting: false) بعد ما السجلات كانت موجودة → استعادة جزئية
```
- الـ insert مع `id` موجود يسبب UNIQUE conflict من غير transaction — فالاستعادة بتطلع جزئية والنتيجة `false`.
- **الإصلاح المقترح:** `db.transaction(...)` عشان الـ restore إما كله ولا لا حاجة.

### 🟠 B4 — رقمين مختلفين لنفس الشهر (مؤكد بالأرقام بالظبط)
```
Home.monthlyExpenses  = 1300.00 (كل الشهر حتى المستقبلي)
StatisticsCubit.month = 1000.00 (لحد النهاردة)
```
- الفرق 300.00 بالظبط (سجلة Shopping بتاريخ 2026-10-20).
- **ملفات:** [home_cubit.dart](lib/core/cubit/home/home_cubit.dart) مقابل [statistics_cubit.dart](lib/core/cubit/statistics/statistics_cubit.dart)
- **قرار مطلوب منك** (سؤال 2 في الخطة): هل المستقبلي يدخل ولا لأ — و بعدين نوحّد الاتنين.

### 🟠 B5 — فلتر Week في Home بيقبل تواريخ مستقبلية (مؤكد)
```
getExpensesByCategory(filter: 'Week') بيشمل تاريخ 2026-10-20 (مستقبلي)
```
- السبب: `edate.isAfter(now - 7d)` من غير حد أعلى = اليوم.
- **قرار مطلوب** (سؤال 3): تعريف الأسبوع — آخر 7 أيام ولا أسبوع تقويمي (وبدايته من إيه).

### 🟠 B6 — تواريخ مخزنة بوقت (T) بتطلع برّه المدى (2 حالات فاشلة)
```
getTotalAmountForDateRange('expenses', '2026-10-16', '2026-10-16')
مع date = '2026-10-16T10:00' و '2026-10-16T23:59'
→ total = 0.0   (المطلوب 140.0!)
```
- المقارنة النصية `date <= '2026-10-16'` بتخلي `'2026-10-16T10:00' > '2026-10-16'` نصياً.
- **ملف:** [lib/control/sqlcontrol.dart](lib/control/sqlcontrol.dart) (دالة `getTotalAmountForDateRange`)
- **الإصلاح المقترح:** `WHERE date >= ? AND substr(date, 1, 10) <= ?` (أو تطبيع التواريخ على `yyyy-MM-dd` قبل التخزين).

### 🟠 باغ جديد اكتشفه الاختبار — getDailySummaries بـ overwrite بدل تجميع (فرع B6)
```
سجلّتين بنفس اليوم بصيغتين ('2026-10-16' و '2026-10-16T07:30')
→ getDailySummaries رجعت 20.0 بدل 30.0
```
- السبب: بعد `split('T')`، الكود بيكتب `summaries[date]!['expense'] = total` مباشرة — فالقيمة الأحدث بتطغى على اللي قبليها مش تتجمع معاها (`+=` الناقص). ولو في يوم فيه مبلغين بصيغتين مختلفة، قيمة بتضيع من ملخصات اليوم.

### 🟡 B9 — الدولار hard-coded في AI insights (مؤكد)
```
getSpendingInsights() بيرجع 'Total expenses: $...' برمز ثابت بدل رمز العملة
```
- **ملف:** [lib/services/ai_suggestion_service.dart](lib/services/ai_suggestion_service.dart)
- **الإصلاح:** تمرير رمز العملة كباراميتر اختياري (من `CurrencyCubit`).

### 🟡 B10 — false positives في التفرقة الذكية (6 حالات فاشلة)
```
'teacher' → Food            (بسبب نص فرعي tea)   ❌
'business invoice' → Transport (bus)              ❌
'care package' → Transport     (car)              ❌
'card purchase' → Transport    (car)              ❌
'barber' → Entertainment       (bar)              ❌
'Flight ticket' → Entertainment (أولوية ticket قبل Transport) ❌
```
- **الإصلاح المقترح:** مطابقة كلمة كاملة (RegExp `\b` أو split على المسافات) بدل `contains`.

### 🟡 B11 — أخطاء الـ DB في HomeCubit بتبلع بصمت (مؤكد)
```
HomeCubit.loadData مع قاعدة معطلة → isLoading:false ورصيد 0.0 من غير أي رسالة خطأ
```
- بينما StatisticsCubit بيرجع `StatisticsError` (سلوك صح وظيفته إشعار المستخدم).
- التوصية: حالة error موحّدة في HomeCubit برسالة واضحة.

### 🟡 B12 — `getAllData` بيرجع `{}` عند خطأ (تم توثيقه من الخطة، وبنيته اتأكدت في المراجعة)
```
getAllData عند خطأ DB → {} من غير إشعار
getBackupSize يرجع 0.0 من غير إشعار
```
- الخطر: **"باك أب ناجح" وهو فاضي**. محتاج مؤشر فشل صريح (exception أو نتيجة با failure).
- **ملف:** [lib/services/backup_data_processor.dart](lib/services/backup_data_processor.dart) (دالة `getAllData`)

### ⚠️ Smoke test بيفشل مسبقاً (مش من عندنا)
`test/widget_test.dart` بيفشل كذلك **قبل أي تعديل مني** (اتأكدت بـ `git stash` → قياس → `stash pop`):
`pumpAndSettle` بينتهي بـ timeout — على الأغلب Lottie animation لا نهائية بتمنع الـ settle. محتاج إصلاح منفصل.

---

## 5. سلوك سليم أثبتته الاختبارات (مش محتاج تعديل)

| الفحص | النتيجة |
|---|---|
| Round trip كامل للـ Backup (export→validate→clear→restore→نفس الأرقام) | ✅ سليم |
| الالتزام المكتمل بيرجع مكتمل بعد restore (isCompleted) | ✅ سليم |
| Migration v1→v2 على قاعدة حقيقية: الداتا القديمة سليمة + default `isCompleted=0` | ✅ سليم |
| CRUD لكل الجداول + update/delete على id مش موجود | ✅ سليم |
| AUTOINCREMENT بعد الحذف (لا id reuse) | ✅ سليم |
| 20 insert متوازي + سباق `_openingDb` | ✅ سليم |
| حدود المدى inclusive (أول وآخر يوم) + قاعدة فاضية → 0.0 | ✅ سليم |
| الرصيد السالب (مصاريف أكتر من الدخل) | ✅ سليم |
| الرصيد = Σدخل − Σمصروف بعد أي add/delete (ثوابت §4.5) | ✅ سليم |
| Custom range شامل الحدود (10-01 → 10-16 = 1000.00) | ✅ سليم |
| Year filter (بيدخل 99.99 بتاريخ سبتمبر) | ✅ سليم |
| عدم تخصم الالتزامات من الرصيد (B7 — سلوك حالٍ، محتاج قرار) | ✅ موثّق |
| فلتر الفئة Food / 'All' | ✅ سليم |
| toggleChartType (Pie ↔ Bar) | ✅ سليم |
| getFinancialTips: دخل صفر/سالب/مصاريف أكبر من الدخل | ✅ سليم بدون crash أو NaN |
| getPersonalizedRecommendations عند حد 20% بالظبط | ✅ سليم (exactly-20% مش بيرشّح) |
| suggestBudgetAllocation مجموعه = 100 | ✅ سليم |

---

## 6. النتيجة الرقمية

| الملف | نجاح | فشل (إثبات bug) |
|---|---|---|
| unit/utils/validators_test.dart | 7 | 3 (B1) |
| unit/models/models_test.dart | 8 | 1 (B2) |
| unit/services/ai_suggestion_extra_test.dart | 11 | 8 (B9 + B10) |
| integration/sqlcontrol_test.dart | 7 | 3 (B6 + باغ التجميع) |
| integration/backup_processor_test.dart | 9 | 1 (B2) |
| cubits/home_statistics_test.dart | 18 | 1 (B11 statistics) |
| ai_suggestion_test.dart (قديم) | 9 | 0 |
| widget_test.dart (smoke قديم) | 0 | 1 (فاشل مسبقاً) |
| **الإجمالي** | **69** | **18** |

---

## 7. خطوات إصلاح مقترحة (بالترتيب)

1. **B1** في `validators.dart`: رفض `!parsed.isFinite`.
2. **B2** في الموديلات الثلاثة: `amount: (map['amount'] as num).toDouble()`.
3. **B6** في `getTotalAmountForDateRange` و `getDailySummaries`: `substr(date, 1, 10)` أو تطبيع التواريخ.
4. **BUG جديد (التجميع):** `summaries[date]!['expense'] = (summaries[date]!['expense'] ?? 0) + total`.
5. **B5** في `getExpensesByCategory (Week)`: تعريف موحّد للأسبوع بحد أعلى = اليوم.
6. **B9** في `getSpendingInsights`: باراميتر اختياري `currencySymbol`.
7. **B10** في `suggestCategory`: مطابقة كلمة كاملة بدل substring.
8. **B11/B12**: حالة error/مؤشر فشل صريح بدل الـ catch الصامت.
9. **B3**: `restoreBackup` داخل transaction (إما كله ولا لا حاجة).
10. بعد الإصلاح → الاختبارات الحالية من bug-documentation تتحول لكلها خضرا.

### اللي لسه باقي (مراحل 3–8 من الخطة)
- Cubits المتبقية (Expense, Income, Commitment, History, Currency) + property-based tests.
- Services (SMS, Reminders) + BankSmsService mock.
- Widget tests + مصفوفة العرض (لغات/ثيم/حجم خط/شاشات) + goldens + a11y.
- E2E + CI.

### أسئلة بتستنى رأيك (من الخطة رقم 1–7)
قرارات سؤال 1 (الالتزامات تخصم؟)، 2 (المستقبلي في الرصيد/الشهر)، 3 (تعريف الأسبوع)، 4 (العملة تحوّل المبالغ؟)، 5 (فورمات الفواصل)، 6 (double ولا int cents)، 7 (التغطية المطلوبة).

---

## 8. ملفات الاختبار الجديدة

| الملف | المحتوى |
|---|---|
| [test/helpers/golden_dataset.dart](test/helpers/golden_dataset.dart) | بيانات ثابتة + clock + seed |
| [test/helpers/db_test_utils.dart](test/helpers/db_test_utils.dart) | قاعدة in-memory حقيقية بـ onCreate/onUpgrade الحقيقيين |
| [test/unit/utils/validators_test.dart](test/unit/utils/validators_test.dart) | B1 + validators عامة |
| [test/unit/models/models_test.dart](test/unit/models/models_test.dart) | B2 + roundtrip + assertions |
| [test/unit/services/ai_suggestion_extra_test.dart](test/unit/services/ai_suggestion_extra_test.dart) | B9 + B10 + tips/insights/allocations |
| [test/integration/sqlcontrol_test.dart](test/integration/sqlcontrol_test.dart) | B6 + migration + CRUD + concurrency |
| [test/integration/backup_processor_test.dart](test/integration/backup_processor_test.dart) | B2/B3 + round trip + validation |
| [test/cubits/home_statistics_test.dart](test/cubits/home_statistics_test.dart) | B4/B5/B11 + ثوابت §4.5 |
| [test/cubits/history_cubit_test.dart](test/cubits/history_cubit_test.dart) | B11 + فلترة وتخطي التواريخ الفاسدة |

---

## 9. الحالة النهائية بعد اكتمال خطة الإصلاحات (Phases A, B, C, D)

- ✅ **93 اختباراً ناجحاً بنسبة 100% (صفر فشل)**.
- ✅ **B1 (رفض NaN/Infinity):** تم تفعيله واختباره بالكامل في `AppValidators.amount`.
- ✅ **B2 (قبول int كمبلغ):** تم توحيد `(map['amount'] as num).toDouble()` في كافة النماذج.
- ✅ **B3 (استعادة النسخ الاحتياطية):** عزل الـ IDs عند الاستيراد مع ميزة إزالة التكرارات (`deduplication`) واختبارها.
- ✅ **B4 & B5 (المستقبلي وتوحيد الأسبوع التقويمي):** إنشاء `lib/utils/date_ranges.dart` وتوحيد الحسابات بين `HomeCubit` و`StatisticsCubit`.
- ✅ **B6 & باغ التجميع:** اعتماد المدى نصف المفتوح وتجميع `+=` للمبالغ في نفس اليوم.
- ✅ **B7 (الالتزامات المكتملة):** إضافة حوار تأكيد للمستخدم عند إكمال الالتزام لتسجيله كمصروف اختياري تحت "Bills".
- ✅ **B9 & B10 (الذكاء الاصطناعي والتصنيف):** تخصيص رمز العملة والتحول لمطابقة الكلمات الكاملة ومنع الإيجابيات الكاذبة.
- ✅ **B11 & B12 (معالجة الأخطاء):** إضافة `errorMessage` في `HomeCubit` و`HistoryCubit` و`StatisticsCubit` وتخطي التواريخ غير الصالحة بدلاً من إخفاء القائمة.
- ✅ **Phase D (Smoke Test & Timers):** تم حل تسريب الـ Timers في `AppLifecycleManager` و`commitments_list_tile.dart` و`widget_test.dart` يعمل بنجاح تام.
- ✅ التحليل الثابت (`flutter analyze`): **صفر أخطاء وصفر تحذيرات**، وتم تحديث التعيينات القديمة بميكانيكية كاملة.
