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
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapAuthError(e.code)));
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'حدث خطأ أثناء الاتصال بقاعدة البيانات.'),
      );
    } on FormatException {
      return const Left(ServerFailure('حدث خطأ أثناء معالجة البيانات.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
        return 'كلمة المرور ضعيفة.';

      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';

      case 'too-many-requests':
        return 'عدد كبير من المحاولات، حاول لاحقًا.';

      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت.';

      case 'invalid-credential':
        return 'بيانات تسجيل الدخول غير صحيحة.';

      default:
        return 'حدث خطأ غير متوقع.';
    }
  }
}
