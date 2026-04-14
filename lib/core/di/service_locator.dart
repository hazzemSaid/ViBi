import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/theme/theme_cubit.dart';
import 'package:vibi/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:vibi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/home/data/datasources/graphql_feed_data_source.dart';
import 'package:vibi/features/home/data/repositories/feed_repository_impl.dart';
import 'package:vibi/features/home/domain/repositories/feed_repository.dart';
import 'package:vibi/features/home/domain/usecases/get_following_feed_usecase.dart';
import 'package:vibi/features/home/domain/usecases/get_global_feed_usecase.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/presentation/providers/inbox_providers.dart';
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

  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<SupabaseAuthDataSource>(
    SupabaseAuthDataSource.new,
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseAuthDataSource>()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<AuthController>(
    () => AuthController(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GraphQLFeedDataSource>(
    () => GraphQLFeedDataSource(GraphQLConfig.client),
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

  getIt.registerLazySingleton<GraphQLProfileDataSource>(
    GraphQLProfileDataSource.new,
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
  getIt.registerLazySingleton<GraphQLSocialLinksDataSource>(
    GraphQLSocialLinksDataSource.new,
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

  getIt.registerLazySingleton<GraphQLSearchDataSource>(
    GraphQLSearchDataSource.new,
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

  getIt.registerLazySingleton<GraphQLQuestionDataSource>(
    GraphQLQuestionDataSource.new,
  );
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(getIt<GraphQLQuestionDataSource>()),
  );
  getIt.registerFactory<SendQuestionCubit>(
    () => SendQuestionCubit(getIt<QuestionRepository>()),
  );

  getIt.registerLazySingleton<ReactionsRemoteDataSource>(
    ReactionsRemoteDataSource.new,
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

  getIt.registerLazySingleton<GraphQLInboxDataSource>(
    GraphQLInboxDataSource.new,
  );
  getIt.registerFactory<PendingQuestionsCubit>(
    () => PendingQuestionsCubit(getIt<GraphQLInboxDataSource>()),
  );
  getIt.registerFactory<AnswerQuestionCubit>(
    () => AnswerQuestionCubit(getIt<GraphQLInboxDataSource>()),
  );
  getIt.registerFactory<DeleteQuestionCubit>(
    () => DeleteQuestionCubit(getIt<GraphQLInboxDataSource>()),
  );

  getIt.registerLazySingleton<GraphQLFollowDataSource>(
    GraphQLFollowDataSource.new,
  );
  getIt.registerLazySingleton<FollowRepository>(
    () => FollowRepositoryImpl(getIt<GraphQLFollowDataSource>()),
  );
  getIt.registerFactory<FollowCubit>(
    () => FollowCubit(getIt<FollowRepository>()),
  );
}
