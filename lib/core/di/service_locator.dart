import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/core/services/tmdb_service.dart';
import 'package:vibi/core/theme/theme_cubit.dart';
import 'package:vibi/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:vibi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/feed/data/datasources/graphql_feed_data_source.dart';
import 'package:vibi/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:vibi/features/feed/domain/repositories/feed_repository.dart';
import 'package:vibi/features/feed/domain/usecases/get_following_feed_usecase.dart';
import 'package:vibi/features/feed/domain/usecases/get_global_feed_usecase.dart';
import 'package:vibi/features/feed/presentation/view/cubit/feed_cubit.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/data/repositories/inbox_repository_impl.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';
import 'package:vibi/features/inbox/domain/usecases/answer_question_usecase.dart';
import 'package:vibi/features/inbox/domain/usecases/archive_question_usecase.dart';
import 'package:vibi/features/inbox/domain/usecases/delete_question_usecase.dart';
import 'package:vibi/features/inbox/domain/usecases/get_pending_questions_usecase.dart';
import 'package:vibi/features/inbox/presentation/cubits/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/archive_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/delete_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/pending_questions_cubit.dart';
import 'package:vibi/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:vibi/features/profile/data/repositories/public_profile_repository_impl.dart';
import 'package:vibi/features/profile/data/repositories/social_links_repository_impl.dart';
import 'package:vibi/features/profile/data/sources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/data/sources/graphql_social_links_datasource.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';
import 'package:vibi/features/profile/domain/usecases/add_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/delete_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_social_links_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
import 'package:vibi/features/questions/data/datasources/graphql_question_datasource.dart';
import 'package:vibi/features/questions/data/repositories/question_repository_impl.dart';
import 'package:vibi/features/questions/domain/repositories/question_repository.dart';
import 'package:vibi/features/questions/presentation/providers/question_providers.dart';
import 'package:vibi/features/reactions/data/datasources/reactions_remote_data_source.dart';
import 'package:vibi/features/reactions/data/repositories/reactions_repository_impl.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/providers/comments_cubit.dart';
import 'package:vibi/features/reactions/presentation/providers/reaction_cubit.dart';
import 'package:vibi/features/recommendation/data/repositories/recommendation_repository.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_cubit.dart';
import 'package:vibi/features/search/data/datasources/graphql_search_datasource.dart';
import 'package:vibi/features/search/data/repositories/search_repository_impl.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';
import 'package:vibi/features/search/presentation/providers/search_providers.dart';
import 'package:vibi/features/social/data/datasources/graphql_follow_datasource.dart';
import 'package:vibi/features/social/data/repositories/follow_repository_impl.dart';
import 'package:vibi/features/social/domain/repositories/follow_repository.dart';
import 'package:vibi/features/social/presentation/providers/follow_providers.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator(SharedPreferences prefs) async {
  if (getIt.isRegistered<SharedPreferences>()) return;

  _initCore(prefs);
  _initAuth();
  _initFeed();
  _initProfile();
  _initSocialLinks();
  _initSearch();
  _initQuestions();
  _initRecommendation();
  _initReactions();
  _initInbox();
  _initFollow();
}

// -----------------------------------------------------------------------------
// Core & External Services
// -----------------------------------------------------------------------------
void _initCore(SharedPreferences prefs) {
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<TmdbService>(TmdbService.new);
  getIt.registerLazySingleton<PushNotificationService>(
    PushNotificationService.new,
  );
}

// -----------------------------------------------------------------------------
// Auth Feature
// -----------------------------------------------------------------------------
void _initAuth() {
  getIt.registerLazySingleton<SupabaseAuthDataSource>(
    SupabaseAuthDataSource.new,
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseAuthDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<AuthController>(
    () => AuthController(
      getIt<AuthRepository>(),
      getIt<PushNotificationService>(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Feed Feature
// -----------------------------------------------------------------------------
void _initFeed() {
  getIt.registerLazySingleton<GraphQLFeedDataSource>(
    () => GraphQLFeedDataSource(GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt<GraphQLFeedDataSource>()),
  );
  getIt.registerLazySingleton<GetGlobalFeedUseCase>(
    () => GetGlobalFeedUseCase(getIt<FeedRepository>()),
  );
  getIt.registerLazySingleton<GetFollowingFeedUseCase>(
    () => GetFollowingFeedUseCase(getIt<FeedRepository>()),
  );
  getIt.registerFactory<GlobalFeedCubit>(
    () => GlobalFeedCubit(getIt<GetGlobalFeedUseCase>()),
  );
  getIt.registerFactory<FollowingFeedCubit>(
    () => FollowingFeedCubit(getIt<GetFollowingFeedUseCase>()),
  );
}

// -----------------------------------------------------------------------------
// Profile Feature
// -----------------------------------------------------------------------------
void _initProfile() {
  getIt.registerLazySingleton<GraphQLProfileDataSource>(
    () => GraphQLProfileDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<GraphQLProfileDataSource>()),
  );
  getIt.registerLazySingleton<FetchUserProfileUseCase>(
    () => FetchUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getIt<FetchUserProfileUseCase>(),
      getIt<UpdateUserProfileUseCase>(),
      getIt<ProfileRepository>(),
    ),
  );
  getIt.registerLazySingleton<PublicProfileRepository>(
    () => PublicProfileRepositoryImpl(getIt<GraphQLProfileDataSource>()),
  );
  getIt.registerFactory<PublicProfileCubit>(
    () => PublicProfileCubit(getIt<PublicProfileRepository>()),
  );
  getIt.registerFactory<UserAnswersCubit>(
    () => UserAnswersCubit(getIt<PublicProfileRepository>()),
  );
  getIt.registerFactory<FollowersCubit>(
    () => FollowersCubit(getIt<GraphQLProfileDataSource>()),
  );
  getIt.registerFactory<FollowingCubit>(
    () => FollowingCubit(getIt<GraphQLProfileDataSource>()),
  );
}

// -----------------------------------------------------------------------------
// Social Links Feature
// -----------------------------------------------------------------------------
void _initSocialLinks() {
  getIt.registerLazySingleton<GraphQLSocialLinksDataSource>(
    () => GraphQLSocialLinksDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<SocialLinksRepository>(
    () => SocialLinksRepositoryImpl(getIt<GraphQLSocialLinksDataSource>()),
  );
  getIt.registerLazySingleton<FetchSocialLinksUseCase>(
    () => FetchSocialLinksUseCase(getIt<SocialLinksRepository>()),
  );
  getIt.registerLazySingleton<AddSocialLinkUseCase>(
    () => AddSocialLinkUseCase(getIt<SocialLinksRepository>()),
  );
  getIt.registerLazySingleton<UpdateSocialLinkUseCase>(
    () => UpdateSocialLinkUseCase(getIt<SocialLinksRepository>()),
  );
  getIt.registerLazySingleton<DeleteSocialLinkUseCase>(
    () => DeleteSocialLinkUseCase(getIt<SocialLinksRepository>()),
  );
  getIt.registerFactoryParam<SocialLinksCubit, String, dynamic>(
    (userId, _) => SocialLinksCubit(
      userId: userId,
      fetchSocialLinksUseCase: getIt<FetchSocialLinksUseCase>(),
      addSocialLinkUseCase: getIt<AddSocialLinkUseCase>(),
      updateSocialLinkUseCase: getIt<UpdateSocialLinkUseCase>(),
      deleteSocialLinkUseCase: getIt<DeleteSocialLinkUseCase>(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Search Feature
// -----------------------------------------------------------------------------
void _initSearch() {
  getIt.registerLazySingleton<GraphQLSearchDataSource>(
    () => GraphQLSearchDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(getIt<GraphQLSearchDataSource>()),
  );
  getIt.registerFactory<UserSearchCubit>(
    () => UserSearchCubit(getIt<SearchRepository>()),
  );
  getIt.registerFactory<ContentSearchCubit>(
    () => ContentSearchCubit(getIt<SearchRepository>()),
  );
}

// -----------------------------------------------------------------------------
// Questions Feature
// -----------------------------------------------------------------------------
void _initQuestions() {
  getIt.registerLazySingleton<GraphQLQuestionDataSource>(
    () => GraphQLQuestionDataSource(),
  );
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(getIt<GraphQLQuestionDataSource>()),
  );
  getIt.registerFactory<SendQuestionCubit>(
    () => SendQuestionCubit(getIt<QuestionRepository>()),
  );
}

// -----------------------------------------------------------------------------
// Recommendation Feature
// -----------------------------------------------------------------------------
void _initRecommendation() {
  getIt.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepository(
      tmdb: getIt<TmdbService>(),
      supabase: Supabase.instance.client,
    ),
  );
  getIt.registerFactory<RecommendationFlowCubit>(
    () => RecommendationFlowCubit(getIt<RecommendationRepository>()),
  );
}

// -----------------------------------------------------------------------------
// Reactions Feature
// -----------------------------------------------------------------------------
void _initReactions() {
  getIt.registerLazySingleton<ReactionsRemoteDataSource>(
    () => ReactionsRemoteDataSource(),
  );
  getIt.registerLazySingleton<ReactionsRepository>(
    () => ReactionsRepositoryImpl(getIt<ReactionsRemoteDataSource>()),
  );
  getIt.registerFactory<ReactionCubit>(
    () => ReactionCubit(getIt<ReactionsRepository>()),
  );
  getIt.registerFactory<CommentsCubit>(
    () => CommentsCubit(getIt<ReactionsRepository>()),
  );
}

// -----------------------------------------------------------------------------
// Inbox Feature
// -----------------------------------------------------------------------------
void _initInbox() {
  getIt.registerLazySingleton<GraphQLInboxDataSource>(
    () => GraphQLInboxDataSource(graphQLClient: GraphQLConfig.ferryClient),
  );
  getIt.registerFactory<InboxRepository>(
    () => InboxRepositoryImpl(getIt<GraphQLInboxDataSource>()),
  );
  getIt.registerFactory<GetPendingQuestionsUseCase>(
    () => GetPendingQuestionsUseCase(getIt<InboxRepository>()),
  );
  getIt.registerFactory<AnswerQuestionUseCase>(
    () => AnswerQuestionUseCase(getIt<InboxRepository>()),
  );
  getIt.registerFactory<DeleteQuestionUseCase>(
    () => DeleteQuestionUseCase(getIt<InboxRepository>()),
  );
  getIt.registerFactory<PendingQuestionsCubit>(
    () => PendingQuestionsCubit(getIt<GetPendingQuestionsUseCase>()),
  );
  getIt.registerFactory<AnswerQuestionCubit>(
    () => AnswerQuestionCubit(getIt<AnswerQuestionUseCase>()),
  );
  getIt.registerFactory<DeleteQuestionCubit>(
    () => DeleteQuestionCubit(getIt<DeleteQuestionUseCase>()),
  );
  getIt.registerLazySingleton<ArchiveQuestionUseCase>(
    () => ArchiveQuestionUseCase(getIt<InboxRepository>()),
  );
  getIt.registerFactory<ArchiveQuestionCubit>(
    () => ArchiveQuestionCubit(
      archiveQuestionUseCase: getIt<ArchiveQuestionUseCase>(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Social (Follow) Feature
// -----------------------------------------------------------------------------
void _initFollow() {
  getIt.registerLazySingleton<GraphQLFollowDataSource>(
    () => GraphQLFollowDataSource(),
  );
  getIt.registerLazySingleton<FollowRepository>(
    () => FollowRepositoryImpl(getIt<GraphQLFollowDataSource>()),
  );
  getIt.registerFactory<FollowCubit>(
    () => FollowCubit(getIt<FollowRepository>()),
  );
}
