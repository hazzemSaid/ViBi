# Inbox Feature Contribution Guide

This guide helps contributors make safe and consistent changes in the Inbox feature.

## Quick Start

1. Read the architecture map below.
2. Make your change in the right layer.
3. Run the validation checklist before opening a PR.

## What Inbox Does

Inbox currently supports:

1. Viewing pending questions (anonymous or user-attributed).
2. Filtering questions in the inbox UI.
3. Pull-to-refresh and pagination.
4. Answering a question.
5. Deleting a question.
6. Realtime updates when question status changes in Supabase.
7. Sharing answers through the new story editor screen.

## Architecture Map

Inbox follows layered architecture:

1. presentation: UI, cubits, local UI state.
2. domain: entities, repository contract, use cases.
3. data: GraphQL datasource, models, repository implementation.

Core files:

1. Screens
  - presentation/screens/inbox_screen.dart
  - presentation/screens/answer_screen.dart
  - presentation/screens/share_answer_screen.dart
2. Cubits
  - presentation/cubits/pending_questions_cubit.dart
  - presentation/cubits/answer_question_cubit.dart
  - presentation/cubits/delete_question_cubit.dart
3. States
  - presentation/state/pending_questions_state.dart
  - presentation/state/answer_question_state.dart
  - presentation/state/delete_question_state.dart
  - presentation/state/answer_screen_visibility.dart
4. Share widgets (new share flow)
  - presentation/widgets/share_answer/share_answer_models.dart
  - presentation/widgets/share_answer/share_story_top_bar.dart
  - presentation/widgets/share_answer/share_story_preview.dart
  - presentation/widgets/share_answer/share_story_controls.dart
5. Domain
  - domain/entities/inbox_question.dart
  - domain/repositories/inbox_repository.dart
  - domain/usecases/get_pending_questions_usecase.dart
  - domain/usecases/answer_question_usecase.dart
  - domain/usecases/delete_question_usecase.dart
6. Data
  - data/datasources/graphql_inbox_datasource.dart
  - data/models/inbox_question_model.dart
  - data/repositories/inbox_repository_impl.dart

## Routing and Dependency Injection

1. Route entry: /inbox in lib/core/routing/app_router.dart.
2. DI registration: lib/core/di/service_locator.dart.
3. Inbox uses get_it registrations only.

Registered dependencies:

1. GraphQLInboxDataSource
2. InboxRepository
3. GetPendingQuestionsUseCase
4. AnswerQuestionUseCase
5. DeleteQuestionUseCase
6. PendingQuestionsCubit
7. AnswerQuestionCubit
8. DeleteQuestionCubit

## State Model

Inbox uses explicit feature states:

1. PendingQuestionsState: list lifecycle, pagination, load-more state.
2. AnswerQuestionState: answer action lifecycle.
3. DeleteQuestionState: delete action lifecycle.

Do not reintroduce generic state wrappers for these action flows.

## Realtime Contract

PendingQuestionsCubit subscribes to Postgres changes with:

1. Channel: inbox_questions_<currentUserId>
2. Table: public.questions
3. Filter: recipient_id == currentUserId

Expected status values:

1. pending
2. answered
3. deleted

If status semantics change in backend, update:

1. pending_questions_cubit.dart transition logic
2. UI assumptions about which items stay visible

## Typical Change Recipes

### Add a new inbox action (example: archive)

1. Add use case in domain/usecases.
2. Extend repository contract in domain/repositories/inbox_repository.dart.
3. Implement in data/repositories/inbox_repository_impl.dart.
4. Add datasource operation in data/datasources/graphql_inbox_datasource.dart.
5. Add dedicated cubit and state if action has independent lifecycle.
6. Register dependencies in lib/core/di/service_locator.dart.
7. Wire UI in inbox_screen.dart.

### Add a new filter tab

1. Extend QuestionFilter in inbox_screen.dart.
2. Update _filterQuestions.
3. Add tab UI in top filter row.
4. Verify filtered counts and empty state behavior.

### Add a new share preset

1. Add preset to presentation/widgets/share_answer/share_answer_models.dart.
2. Verify chip preview, selection, and screenshot result in ShareAnswerScreen.

## Coding Guidelines

1. Keep screens orchestration-focused.
2. Move large visual sections into widgets under presentation/widgets.
3. Keep business rules in cubits/use cases.
4. Keep DI in service_locator.dart only.
5. Avoid stale debug prints in production paths.

## Validation Checklist Before PR

1. Analyzer passes on touched files.
2. No stale imports or references to deleted files.
3. Realtime subscription still unsubscribes in close().
4. Refresh and pagination still work correctly.
5. Error and loading states are visible and actionable.
6. Share flow opens ShareAnswerScreen and captures correctly.

Suggested commands:

1. dart analyze lib/features/inbox
2. rg "features/inbox" lib

## Widget Usage Status (April 2026)

Current active widget group:

1. presentation/widgets/share_answer/* used by ShareAnswerScreen.

Removed legacy share stack:

1. lib/core/services/instagram_share_service.dart
2. presentation/widgets/answer_share_card.dart
3. presentation/widgets/answer_share_card/*

Other removed unused widgets:

1. presentation/widgets/full_answer_modal.dart
2. presentation/widgets/inbox_question_card.dart

## Good First Contributions

1. Add cubit tests under test/features/inbox.
2. Add widget tests for InboxScreen and ShareAnswerScreen.
3. Replace datasource debug prints with structured logging.
4. Improve user-facing error copy for network and permission failures.
