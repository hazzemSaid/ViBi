import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_cubit.dart';
import 'package:vibi/features/recommendation/presentation/cubits/recommendation_flow_state.dart';
import 'package:vibi/core/common/widgets/media_card.dart';
import 'package:vibi/features/recommendation/presentation/widgets/trending_view.dart';
class RecommendSearchScreen extends StatefulWidget {
  const RecommendSearchScreen({
    super.key,
    required this.recipientId,
    this.initialAnonymous = false,
  });

  final String recipientId;
  final bool initialAnonymous;

  @override
  State<RecommendSearchScreen> createState() => _RecommendSearchScreenState();
}

class _RecommendSearchScreenState extends State<RecommendSearchScreen> {
  final _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Recommendation Sent',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recommendation was delivered successfully.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendationFlowCubit>(
      create: (_) {
        final cubit = getIt<RecommendationFlowCubit>();
        cubit.initialize(isAnonymous: widget.initialAnonymous);
        return cubit;
      },
      child: BlocConsumer<RecommendationFlowCubit, RecommendationFlowState>(
        listenWhen: (previous, current) =>
            previous.isSuccess != current.isSuccess,
        listener: (context, state) async {
          if (!state.isSuccess) return;

          final navigator = Navigator.of(context);
          final cubit = context.read<RecommendationFlowCubit>();
          await _showSuccessDialog(context);
          if (!mounted) return;
          cubit.clearSuccessFlag();
          navigator.pop(true);
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final cubit = context.read<RecommendationFlowCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFF0B0C10),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0B0C10),
              title: const Text(
                'Recommend Movie/TV',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1113),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: cubit.onQueryChanged,
                        enabled: !state.isSending,
                        autofocus: true,
                        style: const TextStyle(color: Color(0xFFF5F6F8), fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search movies, actors...',
                          hintStyle: const TextStyle(color: Color(0xFF8F9198), fontSize: 15),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8F9198), size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          suffixIcon: state.query.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    cubit.onQueryChanged('');
                                  },
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8F9198)),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Send anonymously',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: state.isAnonymous,
                            onChanged: state.isSending
                                ? null
                                : cubit.setAnonymous,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        if (state.results.isEmpty && !state.isSearching)
                          if (state.query.trim().isEmpty)
                            TrendingView(
                              selectedMedia: state.selectedMedia,
                              isSending: state.isSending,
                              onMediaSelected: cubit.setSelectedMedia,
                            )
                          else
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'No results found. Try another title.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(
                                      alpha: 0.62,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                        else
                          ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: state.results.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final media = state.results[index];
                              final isSelected =
                                  state.selectedMedia?.tmdbId == media.tmdbId &&
                                  state.selectedMedia?.mediaType ==
                                      media.mediaType;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: MediaCard(
                                  media: media,
                                  compact: true,
                                  showOverview: false,
                                  onTap: state.isSending
                                      ? null
                                      : () => cubit.setSelectedMedia(media),
                                ),
                              );
                            },
                          ),
                        if (state.isSearching)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.canSend
                            ? () => cubit.sendRecommendation(
                                recipientId: widget.recipientId,
                              )
                            : null,
                        icon: state.isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          state.selectedMedia == null
                              ? 'Select a movie/TV first'
                              : 'Send Recommendation',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
