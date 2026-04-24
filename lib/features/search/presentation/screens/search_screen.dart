import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/search/presentation/providers/search_providers.dart';
import 'package:vibi/features/search/presentation/providers/search_state.dart';
import 'package:vibi/features/search/presentation/widgets/search_content_tile.dart';
import 'package:vibi/features/search/presentation/widgets/search_user_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late final UserSearchCubit _userSearchCubit;
  late final ContentSearchCubit _contentSearchCubit;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userSearchCubit = getIt<UserSearchCubit>();
    _contentSearchCubit = getIt<ContentSearchCubit>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _userSearchCubit.close();
    _contentSearchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserSearchCubit>.value(value: _userSearchCubit),
        BlocProvider<ContentSearchCubit>.value(value: _contentSearchCubit),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'Search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.s16,
                    vertical: AppSizes.s8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search users, answers...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                      ),
                      prefixIcon: ImageIcon(
                        AssetImage(AppAssets.iconSearch),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _userSearchCubit.search('');
                                _contentSearchCubit.search('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s16,
                        vertical: AppSizes.s12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _userSearchCubit.search(value);
                      _contentSearchCubit.search(value);
                    },
                  ),
                ),
                // Tab bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).colorScheme.secondary,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'USERS'),
                    Tab(text: 'CONTENT'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildUsersTab(), _buildContentTab()],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_searchQuery.trim().isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'Search for users',
        subtitle: 'Find people by name or username',
      );
    }

    return BlocBuilder<UserSearchCubit, UserSearchState>(
      builder: (context, state) {
        if (state is UserSearchLoaded) {
          final users = state.results;
          if (users.isEmpty) {
            return _buildEmptyState(
              icon: Icons.person_off_outlined,
              title: 'No users found',
              subtitle: 'Try a different search term',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _userSearchCubit.search(_searchQuery);
            },
            color: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                return SearchUserTile(user: users[index]);
              },
            ),
          );
        }
        if (state is UserSearchLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        if (state is UserSearchFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSizes.s16),
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.s16),
                ElevatedButton(
                  onPressed: () {
                    _userSearchCubit.search(_searchQuery);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContentTab() {
    if (_searchQuery.trim().isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Search for content',
        subtitle: 'Find answers and questions',
      );
    }

    return BlocBuilder<ContentSearchCubit, ContentSearchState>(
      builder: (context, state) {
        if (state is ContentSearchLoaded) {
          final content = state.results;
          if (content.isEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off,
              title: 'No content found',
              subtitle: 'Try a different search term',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _contentSearchCubit.search(_searchQuery);
            },
            color: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
              itemCount: content.length,
              itemBuilder: (context, index) {
                return SearchContentTile(content: content[index]);
              },
            ),
          );
        }
        if (state is ContentSearchLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        if (state is ContentSearchFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSizes.s16),
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.s16),
                ElevatedButton(
                  onPressed: () {
                    _contentSearchCubit.search(_searchQuery);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            child: Icon(
              icon,
              size: 56,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSizes.s24),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
