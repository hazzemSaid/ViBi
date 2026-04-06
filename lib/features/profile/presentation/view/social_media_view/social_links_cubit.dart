import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/usecases/add_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/delete_social_link_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_social_links_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_social_link_usecase.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_media_cubit_state.dart';

class SocialLinksCubit extends Cubit<SocialLinksState> {
  final String userId;
  final FetchSocialLinksUseCase _fetchSocialLinksUseCase;
  final AddSocialLinkUseCase _addSocialLinkUseCase;
  final UpdateSocialLinkUseCase _updateSocialLinkUseCase;
  final DeleteSocialLinkUseCase _deleteSocialLinkUseCase;

  SocialLinksCubit({
    required this.userId,
    required FetchSocialLinksUseCase fetchSocialLinksUseCase,
    required AddSocialLinkUseCase addSocialLinkUseCase,
    required UpdateSocialLinkUseCase updateSocialLinkUseCase,
    required DeleteSocialLinkUseCase deleteSocialLinkUseCase,
  }) : _fetchSocialLinksUseCase = fetchSocialLinksUseCase,
       _addSocialLinkUseCase = addSocialLinkUseCase,
       _updateSocialLinkUseCase = updateSocialLinkUseCase,
       _deleteSocialLinkUseCase = deleteSocialLinkUseCase,
       super(const SocialLinksInitial()) {
    _loadLinks();
  }

  List<SocialLink> get currentLinks {
    final current = state;
    if (current is SocialLinksLoaded) return current.links;
    if (current is SocialLinksLoading) return current.previousLinks;
    if (current is SocialLinksFailure) return current.previousLinks;
    return const <SocialLink>[];
  }

  void _emitError(String message) {
    emit(SocialLinksFailure(message, previousLinks: currentLinks));
  }

  Future<void> addLink({
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) async {
    emit(SocialLinksLoading(previousLinks: currentLinks));
    final result = await _addSocialLinkUseCase(
      userId: userId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
    );

    await result.fold((error) async {
      _emitError(error);
      throw Exception(error);
    }, (_) => _loadLinks());
  }

  Future<void> updateLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) async {
    emit(SocialLinksLoading(previousLinks: currentLinks));
    final result = await _updateSocialLinkUseCase(
      linkId: linkId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
      isActive: isActive,
    );

    await result.fold((error) async {
      _emitError(error);
      throw Exception(error);
    }, (_) => _loadLinks());
  }

  Future<void> toggleLink(SocialLink link, bool isActive) async {
    await updateLink(
      linkId: link.id,
      platform: link.platform,
      url: link.url,
      title: link.title,
      displayLabel: link.displayLabel,
      displayOrder: link.displayOrder,
      isActive: isActive,
    );
  }

  Future<void> reorderLinks(
    List<SocialLink> links,
    int oldIndex,
    int newIndex,
  ) async {
    if (links.isEmpty) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 || oldIndex >= links.length) return;
    if (newIndex < 0 || newIndex >= links.length) return;

    final items = List<SocialLink>.from(links);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    emit(SocialLinksLoading(previousLinks: currentLinks));

    for (var index = 0; index < items.length; index++) {
      final link = items[index];
      if (link.displayOrder == index) continue;

      final result = await _updateSocialLinkUseCase(
        linkId: link.id,
        platform: link.platform,
        url: link.url,
        title: link.title,
        displayLabel: link.displayLabel,
        displayOrder: index,
        isActive: link.isActive,
      );

      final failed = result.fold((error) => error, (_) => null);
      if (failed != null) {
        _emitError(failed);
        throw Exception(failed);
      }
    }

    await _loadLinks();
  }

  /// Swaps two items in the list by index (for move-up / move-down actions).
  /// Unlike [reorderLinks], this does NOT apply the ReorderableListView
  /// index adjustment, so [oldIndex] and [newIndex] are used as-is.
  /// Typically called with adjacent indices for move-up/move-down, but
  /// any valid index pair is accepted.
  Future<void> swapLinks(
    List<SocialLink> links,
    int oldIndex,
    int newIndex,
  ) async {
    if (links.isEmpty) return;
    if (oldIndex < 0 || oldIndex >= links.length) return;
    if (newIndex < 0 || newIndex >= links.length) return;

    final items = List<SocialLink>.from(links);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    emit(SocialLinksLoading(previousLinks: currentLinks));

    for (var index = 0; index < items.length; index++) {
      final link = items[index];
      if (link.displayOrder == index) continue;

      final result = await _updateSocialLinkUseCase(
        linkId: link.id,
        platform: link.platform,
        url: link.url,
        title: link.title,
        displayLabel: link.displayLabel,
        displayOrder: index,
        isActive: link.isActive,
      );

      final failed = result.fold((error) => error, (_) => null);
      if (failed != null) {
        _emitError(failed);
        throw Exception(failed);
      }
    }

    await _loadLinks();
  }

  Future<void> _loadLinks() async {
    emit(SocialLinksLoading(previousLinks: currentLinks));
    final result = await _fetchSocialLinksUseCase(userId);
    result.fold(_emitError, (links) => emit(SocialLinksLoaded(links)));
  }

  Future<void> deleteLink(String linkId) async {
    emit(SocialLinksLoading(previousLinks: currentLinks));
    final result = await _deleteSocialLinkUseCase(linkId);
    result.fold((error) {
      _emitError(error);
      throw Exception(error);
    }, (_) => _loadLinks());
  }

  Future<void> refresh() => _loadLinks();
}
