class AppStrings {
  // 🔑 حقول الإدخال (Input Fields)
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';

  // 🔘 الأزرار والعمليات (Buttons & Actions)
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';

  // ⚠️ رسائل التحقق من المدخلات (Validation Messages)
  static const String emailRequired = 'البريد الإلكتروني مطلوب';
  static const String invalidEmail = 'أدخل بريداً إلكترونياً صحيحاً';
  static const String passwordRequired = 'كلمة المرور مطلوبة';
  static const String passwordTooShort =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  // 💬 نصوص إضافية للـ UI (تسهل عليك لو حبيت تستخدمها)
  static const String welcomeBack = 'مرحباً بك مجدداً';
  static const String loginSubtitle = 'سجل الدخول للمتابعة إلى حسابك';
  static const String dontHaveAccount = 'ليس لديك حساب؟ ';
  static const String registerNow = 'إنشاء حساب';

  // 🚕 فيتشر الرحلات - عام
  static const String iAmDriver = 'سواق';
  static const String iAmRider = 'راكب';

  // 🚕 فيتشر الرحلات - السواق
  static const String goOnline = 'ابدأ استقبال الرحلات';
  static const String goOffline = 'إيقاف استقبال الرحلات';
  static const String youAreOnline = 'أنت متاح الآن';
  static const String youAreOffline = 'أنت غير متاح حالياً';
  static const String newRideRequest = 'طلب رحلة جديد';
  static const String pickupFrom = 'من';
  static const String dropAt = 'إلى';
  static const String tripFare = 'الأجرة المتوقعة';
  static const String tripDistance = 'المسافة';
  static const String accept = 'قبول';
  static const String reject = 'رفض';
  static const String currentTrip = 'الرحلة الحالية';
  static const String completeTrip = 'إنهاء الرحلة';
  static const String waitingForRequests = 'في انتظار طلبات جديدة...';

  // 🚕 فيتشر الرحلات - الراكب
  static const String whereTo = 'رايح فين؟';
  static const String searchDestination = 'اكتب اسم المكان اللي رايحله';
  static const String confirmRide = 'اطلب الرحلة';
  static const String cancelRide = 'إلغاء الرحلة';
  static const String searchingForDriver = 'بندور لك على سواق قريب...';
  static const String driverOnTheWay = 'السواق في طريقه ليك';
  static const String driverArrived = 'السواق وصل مكانك';
  static const String tripInProgress = 'الرحلة جارية الآن';
  static const String tripCompleted = 'وصلت بالسلامة!';
  static const String tripCancelled = 'الرحلة اتلغت';
  static const String done = 'تم';
}
