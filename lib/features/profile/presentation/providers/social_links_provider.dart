import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/profile/data/sources/graphql_social_links_datasource.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

class SocialLinksCubit extends Cubit<ViewState<List<SocialLink>>> {
  final String userId;
  final GraphQLSocialLinksDataSource dataSource;

  SocialLinksCubit({
    required this.userId,
    GraphQLSocialLinksDataSource? dataSource,
  }) : dataSource = dataSource ?? GraphQLSocialLinksDataSource(),
       super(const ViewState(status: ViewStatus.loading)) {
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      emit(const ViewState(status: ViewStatus.loading));
      final links = await dataSource.fetchSocialLinks(userId);
      emit(ViewState(status: ViewStatus.success, data: links));
    } catch (error) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$error'));
    }
  }

  Future<void> deleteLink(String linkId) async {
    try {
      await dataSource.deleteSocialLink(linkId);
      // Refresh the list after deletion
      await _loadLinks();
    } catch (error) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$error'));
      rethrow;
    }
  }

  Future<void> refresh() => _loadLinks();
}

GraphQLSocialLinksDataSource get socialLinksDataSource =>
    getIt<GraphQLSocialLinksDataSource>();
