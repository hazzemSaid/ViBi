# ViBi Social App

Welcome friends! This is the codebase for the ViBi social app.

## Languages / اللغات

- 🇬🇧 [English](README.md)
- 🇸🇦 [العربية](README.ar.md)

## Get The App

- Web: [Website](https://www.vibi.social/)
- iOS: Coming soon
- Android: Coming soon

## Development Resources

This is a Flutter application, written in the Dart programming language.

It builds on Supabase services (authentication, PostgreSQL, storage, and real-time features), plus GraphQL APIs for core social and feed functionality.


### Core Features

- User authentication (Email/Password + Google OAuth)
- User profiles with avatars and social links
- Stories (24-hour social content)
- Q&A inbox (anonymous questions)
- Feed system with following
- Follow/Unfollow system
- Search (users and content)
- Notifications with push support

### In Development

- Direct messaging
- Content moderation
- Trending algorithm
- Offline support

### Architecture

ViBi follows Clean Architecture principles:

- Presentation Layer: UI and state management (Bloc/cubit)
- Domain Layer: Business logic and entities
- Data Layer: Data sources (Supabase) and repositories

### Tech Stack

- Frontend: Flutter + Dart
- State Management: Bloc/cubit
- Backend: Supabase (PostgreSQL)
- Authentication: Supabase Auth
- Routing: GoRouter
- API: GraphQL

## Contributions

### Note

While we do accept contributions, we prioritize high quality issues and pull requests. Adhering to the below guidelines will ensure a more timely review.

### Rules

- We may not respond to your issue or PR.
- We may close an issue or PR without much feedback.
- We may lock discussions or contributions if our attention is getting DDOSed.
- We're not going to provide support for build issues.

### Guidelines

- Check for [existing issues](https://github.com/yourusername/vibi/issues) before filing a new one please.
- Open an issue and give some time for discussion before submitting a PR.
- Stay away from PRs like...
  - Changing "Questions" to something else across the codebase.
  - Refactoring the codebase, e.g., to replace Bloc/cubit with Provider.
  - Adding entirely new features without prior discussion.

Remember, we serve a wide community of users. Our day-to-day involves us constantly asking "which top priority is our top priority." If you submit well-written PRs that solve problems concisely, that's an awesome contribution. Otherwise, as much as we'd love to accept your ideas and contributions, we really don't have the bandwidth. That's what forking is for.

### Contribution Scope

Public contributions are currently frontend-focused:

- UI and UX improvements
- Flutter feature and bug fixes in client code
- Tests and documentation updates

Out of scope for public PRs (unless maintainers request it):

- Database schema and migration changes
- Backend infrastructure and production credential updates
- Security policy and production deployment configuration

### Code Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Null safety is required
- Use Bloc/cubit for state management
- Add tests for new features
- Update docs for API changes

## Forking Guidelines

You have our blessing to fork this application. However, it's very important to be clear to users when you're giving them a fork.

Please be sure to:

- Change all branding in the repository and UI to clearly differentiate from ViBi.
- Change any support links (feedback, email, terms of service, etc) to your own systems.
- Replace any analytics or error-collection systems with your own so we don't get super confused.
- Clearly communicate to users that it's a fork of ViBi.

## Security Disclosures

If you discover any security issues, please send an email to **security@vibi-app.dev**. The email is automatically CC'd to the entire team and we'll respond promptly.

## Are You A Developer Interested In Building On Supabase And Flutter?

ViBi is an open source social Q&A application built on Supabase and Flutter. With Supabase, you get a scalable PostgreSQL database, authentication, real-time capabilities, and more, empowering you to build amazing applications without being locked into proprietary platforms.

## License (MIT)

See [LICENSE](./LICENSE) for the full license.

### P.S.

We love you and all of the ways you support us. Thank you for making ViBi a great place!
