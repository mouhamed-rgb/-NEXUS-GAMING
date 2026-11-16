# NEXUS — مجتمع اللاعبين

NEXUS تطبيق Flutter لبناء مجتمعات ألعاب عامة وخاصة، مع قنوات نصية وقواعد وأدوار للأعضاء.

## الحالة الحالية
هذه هي الدفعة التأسيسية للمشروع. تتضمن واجهة Flutter أولية، مخطط Supabase، وخادم Node.js تمهيدياً لإصدار رموز LiveKit بعد إضافة التحقق الأمني. ليست المكالمات أو الدردشة الحية جاهزة للإنتاج قبل إعداد الخدمات واختبار سياسات الوصول.

## المتطلبات
- Flutter stable وDart المتوافقان مع `app/pubspec.yaml`
- مشروع Supabase
- Node.js 20 أو أحدث للخادم
- حساب LiveKit Cloud للمكالمات عند تفعيلها

## تشغيل التطبيق
1. افتح مجلد `app` في VS Code.
2. نفّذ `flutter pub get`.
3. أنشئ ملف `app/.env` محلياً اعتماداً على `app/.env.example`.
4. ضع Supabase URL وAnon Key في الملف المحلي.
5. نفّذ `flutter run`.

## قاعدة البيانات
شغّل `supabase/schema.sql` في SQL Editor داخل مشروع Supabase. راجع سياسات RLS قبل فتح التسجيل العام.

## بناء APK
Workflow موجود في `.github/workflows/android.yml`. شغّله من تبويب Actions بعد رفع الملفات. يمكن تنزيل APK من Artifacts عند نجاح البناء.

## الأمان
لا تضع مفاتيح `service_role` أو LiveKit API Secret داخل Flutter أو GitHub repository. أضف أسرار الخادم في إعدادات الاستضافة فقط. يجب أن يتحقق خادم LiveKit من هوية المستخدم وعضويته في الغرفة قبل إصدار أي token.
