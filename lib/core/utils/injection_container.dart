import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// استيراد ملفات الإشعارات

final sl = GetIt.instance;

Future<void> init() async {
  //! 1. الـ Features (ميزات التطبيق)

  // -- [ ميزة الإشعارات ] --
  // الـ Provider

  //! 2. الـ Core (الأدوات الأساسية والمشتركة)
  // (هنا مسجّل عندك الـ Auth والـ Database والـ Network Info)

  //! 3. الـ External (المكتبات الخارجية)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // 👈 تأكد إن الـ AuthProvider والـ UseCases الخاصة بالـ Auth متسجلين هنا برضه عشان الـ main يشتغل بسلام!
}
