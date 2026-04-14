import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/home/presentation/providers/feed_state.dart';
import 'package:vibi/features/home/presentation/widgets/feed_empty_state.dart';
import 'package:vibi/features/home/presentation/widgets/feed_error_state.dart';
import 'package:vibi/features/home/presentation/widgets/feed_load_more_indicator.dart';
import 'package:vibi/features/home/presentation/widgets/feed_loading_state.dart';
import 'package:vibi/features/home/presentation/widgets/home_app_bar.dart';
import 'package:vibi/features/home/presentation/widgets/post_item.dart';
import 'package:vibi/features/home/presentation/widgets/stories_section.dart';
import 'package:vibi/features/home/presentation/widgets/suggested_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  late final GlobalFeedCubit _globalFeedCubit;
  bool _isBottomBarVisible = true;

  @override
  void initState() {
    super.initState();
    _globalFeedCubit = getIt<GlobalFeedCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isBottomBarVisible) {
      _isBottomBarVisible = false;
    } else if (direction == ScrollDirection.forward && !_isBottomBarVisible) {
      _isBottomBarVisible = true;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _globalFeedCubit.fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _globalFeedCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalFeedCubit>.value(
      value: _globalFeedCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _globalFeedCubit.refresh,
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            cacheExtent: 1500,
            slivers: [
              const HomeAppBar(),
              SliverList(
                delegate: SliverChildListDelegate(const [
                  SizedBox(height: 8),
                  StoriesSection(),
                  Divider(height: 1),
                ]),
              ),
              BlocBuilder<GlobalFeedCubit, FeedState>(
                buildWhen: (previous, current) {
                  if (previous is FeedLoaded && current is FeedLoaded) {
                    return previous.items.length != current.items.length ||
                        previous.hasMore != current.hasMore;
                  }
                  return previous != current;
                },
                builder: (context, feedState) {
                  if (feedState is FeedLoaded) {
                    final items = feedState.items;
                    if (items.isEmpty) return const FeedEmptyState();
                    final hasMore = feedState.hasMore;
                    final itemIndexById = <String, int>{
                      for (var i = 0; i < items.length; i++) items[i].id: i,
                    };

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == items.length) {
                            return const FeedLoadMoreIndicator();
                          }

                          final item = items[index];
                          return Column(
                            key: ValueKey('column_${item.id}'),
                            children: [
                              RepaintBoundary(
                                child: PostItem(
                                  key: ValueKey('post_${item.id}'),
                                  item: item,
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                height: 1,
                              ),
                              if (index == 0) ...const [
                                SuggestedSection(
                                  key: ValueKey('suggested_section'),
                                ),
                                Divider(height: 1),
                              ],
                            ],
                          );
                        },
                        childCount: items.length + (hasMore ? 1 : 0),
                        findChildIndexCallback: (Key key) {
                          if (key is ValueKey<String> &&
                              key.value.startsWith('column_')) {
                            final id = key.value.substring(7);
                            return itemIndexById[id];
                          }
                          return null;
                        },
                      ),
                    );
                  }
                  if (feedState is FeedLoading || feedState is FeedInitial) {
                    return const FeedLoadingState();
                  }
                  return FeedErrorState(
                    message: (feedState as FeedFailure).message,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
