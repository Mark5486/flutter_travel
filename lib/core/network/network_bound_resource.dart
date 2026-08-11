import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// 🌐 تحديد سياسة جلب البيانات المفضلة
enum CachePolicy {
  cacheFirst, // اقرأ من الكاش المحتفظ به، لو مش موجود روحي للنت واعمل تحديث
  networkFirst, // روح للنت الأول، لو فشل (مفيش نت) هات آخر نسخة من الكاش
  networkOnly, // نت فقط ومتحفظش حاجة
  cacheOnly, // كاش محلي فقط
}

/// 🧠 المحرك العبقري لإدارة تدفق البيانات أوفلاين/أونلاين تلقائياً
mixin NetworkBoundResource {
  Future<Either<Failure, DomainType>> executeWithPolicy<DomainType, ModelType>({
    required CachePolicy policy,
    required Future<ModelType> Function() fetchNetwork,
    required Future<ModelType?> Function() fetchLocal,
    required Future<void> Function(ModelType data) saveLocal,
    required DomainType Function(ModelType model) mapToDomain,
    required Future<bool> Function() isConnected,
  }) async {
    switch (policy) {
      // ----------------------------------------------------
      // 1. الكاش أولاً (السرعة القصوى والأوفلاين)
      // ----------------------------------------------------
      case CachePolicy.cacheFirst:
        final localData = await fetchLocal();
        if (localData != null) {
          // لو الكاش موجود، رجعه فوراً للـ UI عشان الأبلكيشن يفتح بلمح البصر
          // وفي الخلفية بنحدث الكاش لو فيه نت (Silent Refresh)
          if (await isConnected()) {
            _silentBackgroundUpdate(fetchNetwork, saveLocal);
          }
          return Right(mapToDomain(localData));
        }
        // لو مفيش كاش، اضطر يروح للشبكة
        return _fetchFromNetworkAndSave(
          fetchNetwork,
          saveLocal,
          mapToDomain,
          isConnected,
        );

      // ----------------------------------------------------
      // 2. الشبكة أولاً (لبيانات حية مثل الحضور والغياب اللحظي)
      // ----------------------------------------------------
      case CachePolicy.networkFirst:
        if (await isConnected()) {
          return _fetchFromNetworkAndSave(
            fetchNetwork,
            saveLocal,
            mapToDomain,
            isConnected,
          );
        } else {
          // لو مفيش نت، اسحب من الكاش فوراً كخيار بديل بأمان
          final localData = await fetchLocal();
          if (localData != null) {
            return Right(mapToDomain(localData));
          }
          return const Left(
            ServerFailure(
              'لا يوجد اتصال بالإنترنت ولا يوجد بيانات مسجلة محلياً.',
            ),
          );
        }

      // ----------------------------------------------------
      // 3. شبكة فقط
      // ----------------------------------------------------
      case CachePolicy.networkOnly:
        return _fetchFromNetworkAndSave(
          fetchNetwork,
          saveLocal,
          mapToDomain,
          isConnected,
        );

      // ----------------------------------------------------
      // 4. كاش محلي فقط
      // ----------------------------------------------------
      case CachePolicy.cacheOnly:
        final localData = await fetchLocal();
        if (localData != null) {
          return Right(mapToDomain(localData));
        }
        return const Left(CacheFailure('لا توجد بيانات محفظة محلياً.'));
    }
  }

  // 🛠️ وظيفة مساعدة لجلب البيانات من النت وحفظها محلياً
  Future<Either<Failure, DomainType>>
  _fetchFromNetworkAndSave<DomainType, ModelType>(
    Future<ModelType> Function() fetchNetwork,
    Future<void> Function(ModelType data) saveLocal,
    DomainType Function(ModelType model) mapToDomain,
    Future<bool> Function() isConnected,
  ) async {
    if (!await isConnected()) {
      return const Left(ServerFailure('يرجى التحقق من اتصالك بالإنترنت.'));
    }
    try {
      final remoteData = await fetchNetwork();
      await saveLocal(remoteData); // سيف في الكاش تلقائي
      return Right(mapToDomain(remoteData));
    } catch (e) {
      return Left(ServerFailure('فشل جلب البيانات من السيرفر: $e'));
    }
  }

  // 🔄 تحديث صامت للكاش في الخلفية دون تعطيل المستخدم
  void _silentBackgroundUpdate<ModelType>(
    Future<ModelType> Function() fetchNetwork,
    Future<void> Function(ModelType data) saveLocal,
  ) async {
    try {
      final remoteData = await fetchNetwork();
      await saveLocal(remoteData);
    } catch (_) {
      // فشل التحديث الصامت لا يهمنا هنا، لا نريد إزعاج المستخدم
    }
  }
}
