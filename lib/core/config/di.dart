import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/favorites/data/datasources/favorite_local_datasource.dart';
import '../../features/favorites/data/models/favorite_model.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';

import '../../features/favorites/domain/repositories/favorite_repository.dart';

import '../../features/favorites/domain/usecase/get_favorite_listing_usecase.dart';
import '../../features/favorites/domain/usecase/toggle_favorite_usecase.dart';
import '../../features/favorites/presentation/bloc/favorite_bloc.dart';
import '../../features/chat/data/datasource/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import '../../features/chat/domain/usecases/get_user_by_uid_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/hosting/data/datasources/user_remote_data_source.dart';
import '../../features/hosting/data/repositories/user_repository_impl.dart';
import '../../features/hosting/domain/repositories/user_repository.dart';
import '../../features/hosting/domain/usecases/get_listing_by_id_usecase.dart';
import '../../features/hosting/domain/usecases/get_users_use_case.dart';
import '../../features/hosting/presentation/bloc/user/users_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import 'supabase_config.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/onboarding_local_data_source.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/onboarding_repository_impl.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/onboarding_repository.dart';

import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/auth_state_changes_use_case.dart';
import '../../features/auth/domain/usecases/is_onboarding_completed_use_case.dart';
import '../../features/auth/domain/usecases/complete_onboarding_use_case.dart';

import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_session/auth_session_bloc.dart';

import '../../features/hosting/data/datasources/listing_image_upload_data_source.dart';
import '../../features/hosting/data/datasources/listing_remote_data_source.dart';
import '../../features/hosting/data/repositories/listing_image_repository_impl.dart';
import '../../features/hosting/data/repositories/listing_repository_impl.dart';

import '../../features/hosting/domain/repositories/listing_image_repository.dart';
import '../../features/hosting/domain/repositories/listing_repository.dart';
import '../../features/hosting/domain/usecases/create_listing_usecase.dart';
import '../../features/hosting/domain/usecases/get_my_listings_usecase.dart';
import '../../features/hosting/domain/usecases/update_listing_usecase.dart';
import '../../features/hosting/domain/usecases/delete_listing_usecase.dart';
import '../../features/hosting/domain/usecases/upload_listing_images_usecase.dart';
import '../../features/hosting/presentation/bloc/hosting/hosting_bloc.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_listings_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Discovery feature imports
import '../../features/discovery/presentation/bloc/discovery_bloc.dart';

// Applications feature imports
import '../../features/applications/presentation/bloc/application_bloc.dart';
import '../../features/applications/domain/usecases/submit_application_usecase.dart';
import '../../features/applications/domain/usecases/cancel_application_usecase.dart';
import '../../features/applications/domain/usecases/get_submitted_applications_usecase.dart';
import '../../features/applications/domain/usecases/get_received_applications_usecase.dart';
import '../../features/applications/domain/usecases/set_application_status_usecase.dart';
import '../../features/applications/domain/repositories/application_repository.dart';
import '../../features/applications/data/repositories/application_repository_impl.dart';
import '../../features/applications/data/datasources/application_remote_data_source.dart';

// Notifications feature imports
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notifications/domain/usecases/save_fcm_token_usecase.dart';
import '../../features/notifications/domain/usecases/send_notification_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../services/push_notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  // Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Applications data source & repository
  getIt.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      notificationRemoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(
      remoteDataSource: getIt<ApplicationRemoteDataSource>(),
    ),
  );

  // Applications use cases
  getIt.registerLazySingleton<SubmitApplicationUseCase>(
    () => SubmitApplicationUseCase(repository: getIt<ApplicationRepository>()),
  );
  getIt.registerLazySingleton<CancelApplicationUseCase>(
    () => CancelApplicationUseCase(repository: getIt<ApplicationRepository>()),
  );
  getIt.registerLazySingleton<GetSubmittedApplicationsUseCase>(
    () => GetSubmittedApplicationsUseCase(
      repository: getIt<ApplicationRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetReceivedApplicationsUseCase>(
    () => GetReceivedApplicationsUseCase(
      repository: getIt<ApplicationRepository>(),
    ),
  );
  getIt.registerLazySingleton<SetApplicationStatusUseCase>(
    () =>
        SetApplicationStatusUseCase(repository: getIt<ApplicationRepository>()),
  );
  getIt.registerLazySingleton<GetListingByIdUseCase>(
    () => GetListingByIdUseCase(repository: getIt<ListingRepository>()),
  );
  // Applications bloc (single registration)
  getIt.registerFactory<ApplicationBloc>(
    () => ApplicationBloc(
      submitApplicationUseCase: getIt<SubmitApplicationUseCase>(),
      cancelApplicationUseCase: getIt<CancelApplicationUseCase>(),
      getSubmittedApplicationsUseCase: getIt<GetSubmittedApplicationsUseCase>(),
      getReceivedApplicationsUseCase: getIt<GetReceivedApplicationsUseCase>(),
      setApplicationStatusUseCase: getIt<SetApplicationStatusUseCase>(),
      getListingByIdUseCase: getIt<GetListingByIdUseCase>(),
    ),
  );
  getIt.registerFactory<OnboardingBloc>(
  () => OnboardingBloc(
    isOnboardingCompletedUseCase:
        getIt<IsOnboardingCompletedUseCase>(),
    completeOnboardingUseCase:
        getIt<CompleteOnboardingUseCase>(),
  ),
);

  if (SupabaseConfig.isConfigured) {
    getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }

  // HTTP client used to reach the Supabase Edge Functions.
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        // Uploads of up to six images can take a while on slow connections.
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
    ),
  );

  // Auth data source & repository
  getIt.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Onboarding local data source
  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: getIt<AuthDataSource>()),
  );
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: getIt<OnboardingLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<AuthStateChangesUseCase>(
    () => AuthStateChangesUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<IsOnboardingCompletedUseCase>(
    () =>
        IsOnboardingCompletedUseCase(repository: getIt<OnboardingRepository>()),
  );
  getIt.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(repository: getIt<OnboardingRepository>()),
  );

  // Profile data source & repository
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );
  // Profile use cases
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(repository: getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(repository: getIt<ProfileRepository>()),
  );

  // Listing data source & repository
  getIt.registerLazySingleton<ListingRemoteDataSource>(
    () => ListingRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(
      remoteDataSource: getIt<ListingRemoteDataSource>(),
    ),
  );

  // Listing image upload data source & repository
  getIt.registerLazySingleton<ListingImageUploadDataSource>(
    () => ListingImageUploadDataSourceImpl(
      dio: getIt<Dio>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<ListingImageRepository>(
    () => ListingImageRepositoryImpl(
      uploadDataSource: getIt<ListingImageUploadDataSource>(),
    ),
  );

  // Home data source & repository
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
  );

  // Use cases for hosting and home
  getIt.registerLazySingleton<CreateListingUseCase>(
    () => CreateListingUseCase(repository: getIt<ListingRepository>()),
  );
  getIt.registerLazySingleton<GetMyListingsUseCase>(
    () => GetMyListingsUseCase(repository: getIt<ListingRepository>()),
  );
  getIt.registerLazySingleton<UpdateListingUseCase>(
    () => UpdateListingUseCase(repository: getIt<ListingRepository>()),
  );
  getIt.registerLazySingleton<DeleteListingUseCase>(
    () => DeleteListingUseCase(repository: getIt<ListingRepository>()),
  );
  getIt.registerLazySingleton<UploadListingImagesUseCase>(
    () =>
        UploadListingImagesUseCase(repository: getIt<ListingImageRepository>()),
  );
  getIt.registerLazySingleton<GetHomeListingsUseCase>(
    () => GetHomeListingsUseCase(getIt<HomeRepository>()),
  );

  // BLoC registrations
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUseCase: getIt<RegisterUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
  getIt.registerFactory<AuthSessionBloc>(
    () => AuthSessionBloc(
      authStateChangesUseCase: getIt<AuthStateChangesUseCase>(),
    ),
  );
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    ),
  );
  getIt.registerFactory<HostingBloc>(
    () => HostingBloc(
      createListingUseCase: getIt<CreateListingUseCase>(),
      getMyListingsUseCase: getIt<GetMyListingsUseCase>(),
      updateListingUseCase: getIt<UpdateListingUseCase>(),
      deleteListingUseCase: getIt<DeleteListingUseCase>(),
      uploadListingImagesUseCase: getIt<UploadListingImagesUseCase>(),
    ),
  );
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getHomeListingsUseCase: getIt<GetHomeListingsUseCase>()),
  );
  // Discovery reuses the Home listing flow so there is a single source of
  // truth for listings; only the search/filter state is Discovery specific.
  getIt.registerFactory<DiscoveryBloc>(
    () =>
        DiscoveryBloc(getHomeListingsUseCase: getIt<GetHomeListingsUseCase>()),
  );
  // Chat data source & repository
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
      notificationRemoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
  );

  // Chat use cases
  getIt.registerLazySingleton<GetConversationsUseCase>(
    () => GetConversationsUseCase(repository: getIt<ChatRepository>()),
  );

  getIt.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(repository: getIt<ChatRepository>()),
  );

  getIt.registerLazySingleton<GetOrCreateConversationUseCase>(
    () => GetOrCreateConversationUseCase(repository: getIt<ChatRepository>()),
  );

  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: getIt<ChatRepository>()),
  );

  getIt.registerLazySingleton<GetUserByUidUseCase>(
    () => GetUserByUidUseCase(repository: getIt<ChatRepository>()),
  );
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      getConversationsUseCase: getIt<GetConversationsUseCase>(),
      getMessagesUseCase: getIt<GetMessagesUseCase>(),
      getOrCreateConversationUseCase: getIt<GetOrCreateConversationUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      getUserByUidUseCase: getIt<GetUserByUidUseCase>(),
    ),
  );

  // ==================== Favorites ====================
  getIt.registerLazySingleton<Box<FavoriteModel>>(
    () => Hive.box<FavoriteModel>('STAY_FAVORITE_BOX'),
  );
  // Local data source
  getIt.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSource(favoriteBox: getIt<Box<FavoriteModel>>()),
  );

  // Repository
  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      localDataSource: getIt<FavoriteLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetFavoriteListingUseCase>(
    () => GetFavoriteListingUseCase(repository: getIt<FavoriteRepository>()),
  );

  getIt.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(repository: getIt<FavoriteRepository>()),
  );

  // BLoC
  getIt.registerFactory<FavoritesBloc>(
    () => FavoritesBloc(
      getFavoriteListingUseCase: getIt<GetFavoriteListingUseCase>(),
      toggleFavoriteUseCase: getIt<ToggleFavoriteUseCase>(),
    ),
  );

  // ==================== Notifications ====================
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(),
  );

  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      dio: getIt.isRegistered<Dio>() ? getIt<Dio>() : null,
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SendNotificationUseCase>(
    () => SendNotificationUseCase(repository: getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(repository: getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(
      repository: getIt<NotificationRepository>(),
    ),
  );
  getIt.registerLazySingleton<MarkAllNotificationsAsReadUseCase>(
    () => MarkAllNotificationsAsReadUseCase(
      repository: getIt<NotificationRepository>(),
    ),
  );
  getIt.registerLazySingleton<SaveFcmTokenUseCase>(
    () => SaveFcmTokenUseCase(repository: getIt<NotificationRepository>()),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
      markNotificationAsReadUseCase: getIt<MarkNotificationAsReadUseCase>(),
      markAllNotificationsAsReadUseCase:
          getIt<MarkAllNotificationsAsReadUseCase>(),
    ),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
  () => UserRemoteDataSourceImpl(
    getIt<FirebaseFirestore>(),
  ),
);

getIt.registerLazySingleton<UserRepository>(
  () => UserRepositoryImpl(
    getIt<UserRemoteDataSource>(),
  ),
);

getIt.registerLazySingleton<GetUsersUseCase>(
  () => GetUsersUseCase(
    getIt<UserRepository>(),
  ),
);

getIt.registerFactory<UsersBloc>(
  () => UsersBloc(
    getUsersUseCase: getIt<GetUsersUseCase>(),
  ),
);
}
