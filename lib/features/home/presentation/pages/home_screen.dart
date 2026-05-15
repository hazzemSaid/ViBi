import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_caching.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_state.dart';
import 'package:vibi/features/feed/presentation/widgets/feed_empty_state.dart';
import 'package:vibi/features/feed/presentation/widgets/feed_error_state.dart';
import 'package:vibi/features/feed/presentation/widgets/feed_load_more_indicator.dart';
import 'package:vibi/features/feed/presentation/widgets/feed_loading_state.dart';
import 'package:vibi/features/home/presentation/widgets/home_app_bar.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/post_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  late final GlobalFeedCubit _globalFeedCubit;
  late final FollowingFeedCubit _followingFeedCubit;
  bool _isBottomBarVisible = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _globalFeedCubit = getIt<GlobalFeedCubit>();
    _followingFeedCubit = getIt<FollowingFeedCubit>();
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
      if (_selectedTab == 0) {
        _globalFeedCubit.fetchMore();
      } else {
        _followingFeedCubit.fetchMore();
      }
    }
  }

  void _onTabSelected(int index) {
    if (index == _selectedTab) return;
    setState(() {
      _selectedTab = index;
    });
    _scrollController.jumpTo(0);
  }

  Future<void> _onRefresh() {
    if (_selectedTab == 0) {
      return _globalFeedCubit.refresh();
    }
    return _followingFeedCubit.refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GlobalFeedCubit>.value(value: _globalFeedCubit),
        BlocProvider<FollowingFeedCubit>.value(value: _followingFeedCubit),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return _buildFeed(constraints);
          },
        ),
      ),
    );
  }

  Widget _buildFeed(BoxConstraints constraints) {
    final isLargeScreen = constraints.maxWidth > 800;
    Widget feed = RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        controller: _scrollController,
        cacheExtent: AppCaching.feedCacheExtent,
        slivers: [
          HomeAppBar(
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
          ),
          if (_selectedTab == 0)
            _buildGlobalFeed()
          else
            _buildFollowingFeed(),
        ],
      ),
    );
    if (isLargeScreen) {
      feed = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: feed,
        ),
      );
    }
    return feed;
  }

  Widget _buildGlobalFeed() {
    return BlocBuilder<GlobalFeedCubit, FeedState>(
      buildWhen: (previous, current) {
        if (previous is FeedLoaded && current is FeedLoaded) {
          return previous.items.length != current.items.length ||
              previous.hasMore != current.hasMore;
        }
        return previous != current;
      },
      builder: (context, feedState) {
        return feedState.when(
          initial: () => const FeedLoadingState(),
          loading: () => const FeedLoadingState(),
          failure: (message, _) => FeedErrorState(message: message),
          loaded: (items, hasMore) {
            if (items.isEmpty) return const FeedEmptyState();
            final Map<String, int> itemIndexById = <String, int>{
              for (var i = 0; i < items.length; i++) items[i].id: i,
            };
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == items.length) {
                    return const FeedLoadMoreIndicator();
                  }
                  final FeedItem item = items[index];
                  return Column(
                    key: ValueKey('column_${item.id}'),
                    children: [
                      RepaintBoundary(
                        child: PostItem(
                          key: ValueKey('post_${item.id}'),
                          item: item,
                        ),
                      ),
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
          },
        );
      },
    );
  }

  Widget _buildFollowingFeed() {
    return BlocBuilder<FollowingFeedCubit, FeedState>(
      buildWhen: (previous, current) {
        if (previous is FeedLoaded && current is FeedLoaded) {
          return previous.items.length != current.items.length ||
              previous.hasMore != current.hasMore;
        }
        return previous != current;
      },
      builder: (context, feedState) {
        return feedState.when(
          initial: () => const FeedLoadingState(),
          loading: () => const FeedLoadingState(),
          failure: (message, _) => FeedErrorState(message: message),
          loaded: (items, hasMore) {
            if (items.isEmpty) return const FeedEmptyState();
            final Map<String, int> itemIndexById = <String, int>{
              for (var i = 0; i < items.length; i++) items[i].id: i,
            };
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == items.length) {
                    return const FeedLoadMoreIndicator();
                  }
                  final FeedItem item = items[index];
                  return Column(
                    key: ValueKey('column_${item.id}'),
                    children: [
                      RepaintBoundary(
                        child: PostItem(
                          key: ValueKey('post_${item.id}'),
                          item: item,
                        ),
                      ),
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
          },
        );
      },
    );
  }
}
