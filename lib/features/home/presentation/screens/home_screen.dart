import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/home/presentation/widgets/feed_empty_state.dart';
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
      setState(() => _isBottomBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isBottomBarVisible) {
      setState(() => _isBottomBarVisible = true);
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
        backgroundColor: const Color(0xFF0F1419),
        body: RefreshIndicator(
          onRefresh: _globalFeedCubit.refresh,
          color: const Color(0xFF5A4FCF),
          backgroundColor: const Color(0xFF1C212A),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const HomeAppBar(),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  const StoriesSection(),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                ]),
              ),
              BlocBuilder<GlobalFeedCubit, ViewState<List<FeedItem>>>(
                builder: (context, feedAsync) {
                  if (feedAsync.status == ViewStatus.success) {
                    final items = feedAsync.data ?? [];
                    if (items.isEmpty) return const FeedEmptyState();
                    final hasMore = _globalFeedCubit.hasMore;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF5A4FCF),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            PostItem(item: items[index]),
                            Divider(
                              color: Colors.white.withOpacity(0.05),
                              height: 1,
                            ),
                            if (index == 0) ...[
                              const SuggestedSection(),
                              Divider(
                                color: Colors.white.withOpacity(0.05),
                                height: 1,
                              ),
                            ],
                          ],
                        );
                      }, childCount: items.length + (hasMore ? 1 : 0)),
                    );
                  }
                  if (feedAsync.status == ViewStatus.loading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5A4FCF),
                        ),
                      ),
                    );
                  }
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: ${feedAsync.errorMessage}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
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
