import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';

mixin FirebaseErrorHandler {
  Future<Either<Failure, T>> executeSafely<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(_mapFirebaseError(e)));
    } on FormatException {
      return const Left(ServerFailure('حدث خطأ أثناء معالجة البيانات.'));
    } catch (e) {
      return const Left(ServerFailure('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.'));
    }
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول إلى هذه البيانات.';
      case 'unavailable':
        return 'الخدمة غير متوفرة حالياً، تحقق من اتصالك بالإنترنت.';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة.';
      default:
        return e.message ?? 'حدث خطأ أثناء الاتصال بقاعدة البيانات.';
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح.';
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'too-many-requests':
        return 'عدد محاولات كثير، يرجى المحاولة لاحقاً.';
      case 'network-request-failed':
        return 'تحقق من الاتصال بالإنترنت.';
      case 'invalid-credential':
        return 'بيانات تسجيل الدخول غير صحيحة.';
      default:
        return 'حدث خطأ أثناء المصادقة.';
    }
  }
}