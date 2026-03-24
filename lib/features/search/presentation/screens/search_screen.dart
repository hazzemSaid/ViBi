import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/presentation/providers/search_providers.dart';
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
        backgroundColor: const Color(0xFF0F1419),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1419),
          elevation: 0,
          title: const Text(
            'Search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
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
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search users, answers...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
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
                  indicatorColor: Colors.blueAccent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
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

    return BlocBuilder<UserSearchCubit, ViewState<List<UserSearchResult>>>(
      builder: (context, usersAsync) {
        if (usersAsync.status == ViewStatus.success) {
          final users = usersAsync.data ?? [];
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
            color: const Color(0xFF5A4FCF),
            backgroundColor: const Color(0xFF1C212A),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                return SearchUserTile(user: users[index]);
              },
            ),
          );
        }
        if (usersAsync.status == ViewStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5A4FCF)),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: AppSizes.s16),
              Text(
                'Error: ${usersAsync.errorMessage}',
                style: const TextStyle(color: Colors.redAccent),
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

    return BlocBuilder<
      ContentSearchCubit,
      ViewState<List<ContentSearchResult>>
    >(
      builder: (context, contentAsync) {
        if (contentAsync.status == ViewStatus.success) {
          final content = contentAsync.data ?? [];
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
            color: const Color(0xFF5A4FCF),
            backgroundColor: const Color(0xFF1C212A),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
              itemCount: content.length,
              itemBuilder: (context, index) {
                return SearchContentTile(content: content[index]);
              },
            ),
          );
        }
        if (contentAsync.status == ViewStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5A4FCF)),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: AppSizes.s16),
              Text(
                'Error: ${contentAsync.errorMessage}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.s16),
              ElevatedButton(
                onPressed: () {
                  context.read<ContentSearchCubit>().search(_searchQuery);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
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
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Icon(icon, size: 56, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSizes.s24),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
