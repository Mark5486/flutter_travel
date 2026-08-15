import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

enum CachePolicy { cacheFirst, networkFirst, networkOnly, cacheOnly }

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
      case CachePolicy.cacheFirst:
        final localData = await fetchLocal();
        if (localData != null) {
          if (await isConnected()) {
            _silentBackgroundUpdate(fetchNetwork, saveLocal);
          }
          return Right(mapToDomain(localData));
        }
        return _fetchFromNetworkAndSave(
          fetchNetwork,
          saveLocal,
          mapToDomain,
          isConnected,
        );

      //
      case CachePolicy.networkFirst:
        if (await isConnected()) {
          return _fetchFromNetworkAndSave(
            fetchNetwork,
            saveLocal,
            mapToDomain,
            isConnected,
          );
        } else {
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

      case CachePolicy.networkOnly:
        return _fetchFromNetworkAndSave(
          fetchNetwork,
          saveLocal,
          mapToDomain,
          isConnected,
        );

      case CachePolicy.cacheOnly:
        final localData = await fetchLocal();
        if (localData != null) {
          return Right(mapToDomain(localData));
        }
        return const Left(CacheFailure('لا توجد بيانات محفظة محلياً.'));
    }
  }

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
      await saveLocal(remoteData);
      return Right(mapToDomain(remoteData));
    } catch (e) {
      return Left(ServerFailure('فشل جلب البيانات من السيرفر: $e'));
    }
  }

  void _silentBackgroundUpdate<ModelType>(
    Future<ModelType> Function() fetchNetwork,
    Future<void> Function(ModelType data) saveLocal,
  ) async {
    try {
      final remoteData = await fetchNetwork();
      await saveLocal(remoteData);
    } catch (_) {}
  }
}
