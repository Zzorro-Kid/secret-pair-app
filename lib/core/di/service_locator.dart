import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Features
import 'package:secretpairapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:secretpairapp/features/auth/data/sources/firebase_auth_source.dart';
import 'package:secretpairapp/features/auth/data/sources/local_auth_source.dart';
import 'package:secretpairapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:secretpairapp/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:secretpairapp/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:secretpairapp/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:secretpairapp/features/pair/data/repositories/pair_repository_impl.dart';
import 'package:secretpairapp/features/pair/data/sources/firestore_pair_source.dart';
import 'package:secretpairapp/features/pair/domain/repositories/pair_repository.dart';
import 'package:secretpairapp/features/pair/domain/usecases/create_pair_usecase.dart';
import 'package:secretpairapp/features/pair/domain/usecases/join_pair_usecase.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_bloc.dart';

import 'package:secretpairapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:secretpairapp/features/chat/data/sources/firestore_chat_source.dart';
import 'package:secretpairapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:secretpairapp/features/chat/domain/usecases/listen_messages_usecase.dart';
import 'package:secretpairapp/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:secretpairapp/features/chat/domain/usecases/delete_message_after_timer_usecase.dart';
import 'package:secretpairapp/features/chat/presentation/bloc/chat_bloc.dart';

import 'package:secretpairapp/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:secretpairapp/features/gallery/data/sources/firebase_storage_source.dart';
import 'package:secretpairapp/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:secretpairapp/features/gallery/domain/usecases/upload_media_usecase.dart';
import 'package:secretpairapp/features/gallery/domain/usecases/mark_as_viewed_usecase.dart';
import 'package:secretpairapp/features/gallery/presentation/bloc/gallery_bloc.dart';

import 'package:secretpairapp/features/panic/data/repositories/panic_repository_impl.dart';
import 'package:secretpairapp/features/panic/data/sources/local_panic_source.dart';
import 'package:secretpairapp/features/panic/domain/repositories/panic_repository.dart';
import 'package:secretpairapp/features/panic/domain/usecases/wipe_all_data_usecase.dart';
import 'package:secretpairapp/features/panic/presentation/cubit/panic_cubit.dart';

// Core Utils
import 'package:secretpairapp/core/utils/screenshot_detector.dart';
import 'package:secretpairapp/core/utils/panic_manager.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ============================================================
  // External Dependencies
  // ============================================================
  
  // Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Local storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ============================================================
  // Core Utils
  // ============================================================
  
  sl.registerLazySingleton<ScreenshotDetector>(
    () => ScreenshotDetector(
      firestore: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<PanicManager>(
    () => PanicManager(
      firestore: sl(),
      storage: sl(),
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  // ============================================================
  // Feature: Auth
  // ============================================================
  
  // Data sources
  sl.registerLazySingleton<FirebaseAuthSource>(
    () => FirebaseAuthSource(firebaseAuth: sl()),
  );
  
  sl.registerLazySingleton<LocalAuthSource>(
    () => LocalAuthSource(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuthSource: sl(),
      localAuthSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // ============================================================
  // Feature: Pair
  // ============================================================
  
  // Data sources
  sl.registerLazySingleton<FirestorePairSource>(
    () => FirestorePairSource(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<PairRepository>(
    () => PairRepositoryImpl(firestorePairSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreatePairUseCase(sl()));
  sl.registerLazySingleton(() => JoinPairUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => PairBloc(
      createPairUseCase: sl(),
      joinPairUseCase: sl(),
    ),
  );

  // ============================================================
  // Feature: Chat
  // ============================================================
  
  // Data sources
  sl.registerLazySingleton<FirestoreChatSource>(
    () => FirestoreChatSource(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(firestoreChatSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => ListenMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMessageAfterTimerUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ChatBloc(
      listenMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      deleteMessageAfterTimerUseCase: sl(),
    ),
  );

  // ============================================================
  // Feature: Gallery
  // ============================================================
  
  // Data sources
  sl.registerLazySingleton<FirebaseStorageSource>(
    () => FirebaseStorageSource(
      storage: sl(),
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(firebaseStorageSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsViewedUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => GalleryBloc(
      uploadMediaUseCase: sl(),
      markAsViewedUseCase: sl(),
    ),
  );

  // ============================================================
  // Feature: Panic
  // ============================================================
  
  // Data sources
  sl.registerLazySingleton<LocalPanicSource>(
    () => LocalPanicSource(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PanicRepository>(
    () => PanicRepositoryImpl(localPanicSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => WipeAllDataUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => PanicCubit(
      wipeAllDataUseCase: sl(),
      panicManager: sl(),
    ),
  );
}
