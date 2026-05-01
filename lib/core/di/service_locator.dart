import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/core/services/tmdb_service.dart';
import 'package:vibi/core/theme/theme_cubit.dart';
import 'package:vibi/features/auth/data/datasources/auth_datasource.dart';
import 'package:vibi/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:vibi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibi/features/feed/data/datasources/graphql_feed_data_source.dart';
import 'package:vibi/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:vibi/features/feed/domain/repositories/feed_repository.dart';
import 'package:vibi/features/feed/domain/usecases/get_following_feed_usecase.dart';
import 'package:vibi/features/feed/domain/usecases/get_global_feed_usecase.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:vibi/features/follow/data/datasources/follow_datasource.dart';
import 'package:vibi/features/follow/data/datasources/follow_remote_datasource.dart';
import 'package:vibi/features/follow/data/repositories/follow_repository_impl.dart';
import 'package:vibi/features/follow/domain/repositories/follow_repository.dart';
import 'package:vibi/features/follow/domain/usecases/get_followers_usecase.dart';
import 'package:vibi/features/follow/domain/usecases/get_following_usecase.dart';
import 'package:vibi/features/follow/presentation/cubit/follow/follow_cubit.dart';
import 'package:vibi/features/follow/presentation/cubit/followers/followers_cubit.dart';
import 'package:vibi/features/follow/presentation/cubit/followings/followings_cubit.dart';
import 'package:vibi/features/inbox/data/datasources/inbox_datasource.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/data/repositories/inbox_repository_impl.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';
import 'package:vibi/features/answer/data/datasources/answer_datasource.dart';
import 'package:vibi/features/answer/data/datasources/graphql_answer_datasource.dart';
import 'package:vibi/features/answer/data/repositories/answer_repository_impl.dart';
import 'package:vibi/features/answer/domain/repositories/answer_repository.dart';
import 'package:vibi/features/answer/domain/usecase/answer_question_usecase.dart';
import 'package:vibi/features/answer/domain/usecase/archive_question_usecase.dart';
import 'package:vibi/features/answer/domain/usecase/delete_question_usecase.dart';
import 'package:vibi/features/inbox/domain/usecases/get_pending_questions_usecase.dart';
import 'package:vibi/features/answer/presentation/cubit/question_answer/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubit/question_archive/archive_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubit/question_delete/delete_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubit/padding_question/pending_questions_cubit.dart';
import 'package:vibi/features/profile/data/datasources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/data/datasources/social_links_datasource.dart';
import 'package:vibi/features/profile/data/datasources/graphql_social_links_datasource.dart';
import 'package:vibi/features/profile/data/datasources/profile_datasource.dart';
import 'package:vibi/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:vibi/features/profile/data/repositories/public_profile_repository_impl.dart';
import 'package:vibi/features/profile/data/repositories/social_links_repository_impl.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';
import 'package:vibi/features/profile/domain/usecases/add_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/delete_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_social_links_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/get_public_profile_by_username_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/get_public_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/get_user_answers_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:vibi/features/profile/presentation/cubit/answer_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/public_profile_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/social_links_cubit.dart';
import 'package:vibi/features/sendQuestion/data/datasources/question_datasource.dart';
import 'package:vibi/features/sendQuestion/data/datasources/graphql_question_datasource.dart';
import 'package:vibi/features/sendQuestion/data/repositories/question_repository_impl.dart';
import 'package:vibi/features/sendQuestion/domain/repositories/question_repository.dart';
import 'package:vibi/features/sendQuestion/presentation/cubit/question_providers.dart';
import 'package:vibi/features/reactions/data/datasources/reactions_remote_data_source.dart';
import 'package:vibi/features/reactions/data/repositories/reactions_repository_impl.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/cubit/comments_cubit.dart';
import 'package:vibi/features/reactions/presentation/cubit/reaction_cubit.dart';
import 'package:vibi/features/recommendation/data/repositories/recommendation_repository.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_cubit.dart';
import 'package:vibi/features/search/data/datasources/search_datasource.dart';
import 'package:vibi/features/search/data/datasources/graphql_search_datasource.dart';
import 'package:vibi/features/search/data/repositories/search_repository_impl.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';
import 'package:vibi/features/search/presentation/providers/search_providers.dart';

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
  _initAnswer();
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
  getIt.registerLazySingleton<AuthDataSource>(
    SupabaseAuthDataSource.new,
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<AuthActionCubit>(
    () => AuthActionCubit(
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
  getIt.registerLazySingleton<ProfileDataSource>(
    () => GraphQLProfileDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileDataSource>()),
  );
  getIt.registerLazySingleton<FetchUserProfileUseCase>(
    () => FetchUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UploadProfileImageUseCase>(
    () => UploadProfileImageUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getIt<FetchUserProfileUseCase>(),
      getIt<UpdateUserProfileUseCase>(),
      getIt<UploadProfileImageUseCase>(),
    ),
  );
  getIt.registerLazySingleton<PublicProfileRepository>(
    () => PublicProfileRepositoryImpl(getIt<ProfileDataSource>()),
  );
  getIt.registerLazySingleton<GetPublicProfileUseCase>(
    () => GetPublicProfileUseCase(getIt<PublicProfileRepository>()),
  );
  getIt.registerLazySingleton<GetPublicProfileByUsernameUseCase>(
    () => GetPublicProfileByUsernameUseCase(getIt<PublicProfileRepository>()),
  );
  getIt.registerLazySingleton<GetUserAnswersUseCase>(
    () => GetUserAnswersUseCase(getIt<PublicProfileRepository>()),
  );
  getIt.registerFactory<PublicProfileCubit>(
    () => PublicProfileCubit(
      getPublicProfileUseCase: getIt<GetPublicProfileUseCase>(),
      getPublicProfileByUsernameUseCase:
          getIt<GetPublicProfileByUsernameUseCase>(),
    ),
  );
  getIt.registerFactory<UserAnswersCubit>(
    () => UserAnswersCubit(getIt<GetUserAnswersUseCase>()),
  );
}

// -----------------------------------------------------------------------------
// Social Links Feature
// -----------------------------------------------------------------------------
void _initSocialLinks() {
  getIt.registerLazySingleton<SocialLinksDataSource>(
    () => GraphQLSocialLinksDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<SocialLinksRepository>(
    () => SocialLinksRepositoryImpl(getIt<SocialLinksDataSource>()),
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
  getIt.registerLazySingleton<SearchDataSource>(
    () => GraphQLSearchDataSource(ferryClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(getIt<SearchDataSource>()),
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
  getIt.registerLazySingleton<QuestionDataSource>(
    () => GraphQLQuestionDataSource(),
  );
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(getIt<QuestionDataSource>()),
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
  getIt.registerLazySingleton<InboxDataSource>(
    () => GraphQLInboxDataSource(graphQLClient: GraphQLConfig.ferryClient),
  );
  getIt.registerFactory<InboxRepository>(
    () => InboxRepositoryImpl(getIt<InboxDataSource>()),
  );
  getIt.registerFactory<GetPendingQuestionsUseCase>(
    () => GetPendingQuestionsUseCase(getIt<InboxRepository>()),
  );
  getIt.registerFactory<PendingQuestionsCubit>(
    () => PendingQuestionsCubit(getIt<GetPendingQuestionsUseCase>()),
  );
  getIt.registerLazySingleton<ArchiveQuestionUseCase>(
    () => ArchiveQuestionUseCase(getIt<AnswerRepository>()),
  );
  getIt.registerFactory<ArchiveQuestionCubit>(
    () => ArchiveQuestionCubit(
      archiveQuestionUseCase: getIt<ArchiveQuestionUseCase>(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Answer Feature
// -----------------------------------------------------------------------------
void _initAnswer() {
  getIt.registerLazySingleton<AnswerDataSource>(
    () => GraphQLAnswerDataSource(graphQLClient: GraphQLConfig.ferryClient),
  );
  getIt.registerLazySingleton<AnswerRepository>(
    () => AnswerRepositoryImpl(getIt<AnswerDataSource>()),
  );
  getIt.registerFactory<AnswerQuestionUseCase>(
    () => AnswerQuestionUseCase(getIt<AnswerRepository>()),
  );
  getIt.registerFactory<DeleteQuestionUseCase>(
    () => DeleteQuestionUseCase(getIt<AnswerRepository>()),
  );
  getIt.registerFactory<AnswerQuestionCubit>(
    () => AnswerQuestionCubit(getIt<AnswerQuestionUseCase>()),
  );
  getIt.registerFactory<DeleteQuestionCubit>(
    () => DeleteQuestionCubit(getIt<DeleteQuestionUseCase>()),
  );
}

// -----------------------------------------------------------------------------
// Social (Follow) Feature
// -----------------------------------------------------------------------------
void _initFollow() {
  getIt.registerLazySingleton<FollowDataSource>(() => FollowRemoteDatasource());
  getIt.registerLazySingleton<FollowRepository>(
    () => FollowRepositoryImpl(getIt<FollowDataSource>()),
  );
  getIt.registerFactory<FollowCubit>(
    () => FollowCubit(getIt<FollowRepository>()),
  );
  getIt.registerLazySingleton<GetFollowersUseCase>(
    () => GetFollowersUseCase(getIt<FollowRepository>()),
  );
  getIt.registerLazySingleton<GetFollowingUseCase>(
    () => GetFollowingUseCase(getIt<FollowRepository>()),
  );
  getIt.registerFactory<FollowersCubit>(
    () => FollowersCubit(getFollowersUseCase: getIt<GetFollowersUseCase>()),
  );
  getIt.registerFactory<FollowingCubit>(
    () => FollowingCubit(getFollowingUseCase: getIt<GetFollowingUseCase>()),
  );
}
