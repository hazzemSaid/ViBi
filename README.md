# ViBi

A social Q&A Flutter application with anonymous questions.

**Languages / اللغات:**
- 🇬🇧 [English](README.md)
- 🇸🇦 [العربية](README.ar.md)


## 📦 Features

### Implemented ✅
- ✅ User authentication (Email/Password + Google OAuth)
- ✅ User profiles with avatars and social links
- ✅ Stories (Instagram-style 24-hour content)
- ✅ Q&A Inbox (anonymous questions)
- ✅ Feed system with following
- ✅ Follow/Unfollow system
- ✅ Search (users and content)
- ✅ Notifications with push support

### In Development 🚧
- 🚧 Direct messaging
- 🚧 Content moderation
- 🚧 Trending algorithm
- 🚧 Offline support

## 🏗️ Architecture

ViBi follows **Clean Architecture** principles:

- **Presentation Layer**: UI and state management (Riverpod)
- **Domain Layer**: Business logic and entities  
- **Data Layer**: Data sources (Supabase) and repositories

### Tech Stack
- **Frontend**: Flutter + Dart
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Routing**: GoRouter
- **API**: GraphQL

## 🤝 Contributing

**Note**

While we do accept contributions, we prioritize high quality issues and pull requests. Adhering to the below guidelines will ensure a more timely review.

### Rules

- We may not respond to your issue or PR
- We may close an issue or PR without much feedback
- We may lock discussions or contributions if our attention is getting DDOSed
- We're not going to provide support for build issues

### Guidelines

- Check for [existing issues](https://github.com/yourusername/vibi/issues) before filing a new one please
- Open an issue and give some time for discussion before submitting a PR
- Stay away from PRs like...
  - Changing "Questions" to something else across the codebase
  - Refactoring the codebase, e.g., to replace Riverpod with Provider
  - Adding entirely new features without prior discussion

Remember, we serve a wide community of users. Our day-to-day involves us constantly asking "which top priority is our top priority." If you submit well-written PRs that solve problems concisely, that's an awesome contribution. Otherwise, as much as we'd love to accept your ideas and contributions, we really don't have the bandwidth. That's what forking is for!

### Setting Up for Development

```bash
# Clone and setup
git clone https://github.com/yourusername/vibi.git
cd vibi

# Install dependencies
flutter pub get

# Run the app
flutter run

# Format code
flutter format lib/ test/

# Run tests
flutter test
```

### Environment Setup (Required)

This repository is open for frontend contributions, so production credentials are not committed.

1. Copy `.env.example` to `.env`
2. Fill all required values in `.env`
3. Run the app with `flutter run`

Important:
- Do not commit `.env`, service-account JSON files, or platform credential files.
- If a credential appears in git history, rotate/revoke it in the provider console.

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
- Use Riverpod for state management
- Add tests for new features
- Update docs for API changes

### Forking Guidelines

You have our blessing 🪄✨ to fork this application! However, it's very important to be clear to users when you're giving them a fork.

Please be sure to:

- Change all branding in the repository and UI to clearly differentiate from ViBi
- Change any support links (feedback, email, terms of service, etc) to your own systems
- Replace any analytics or error-collection systems with your own so we don't get super confused
- Clearly communicate to users that it's a fork of ViBi

### Security Disclosures

If you discover any security issues, please send an email to **security@vibi-app.dev**. The email is automatically CC'd to the entire team and we'll respond promptly.

### Are you a developer interested in building on Supabase & Flutter?

ViBi is an open source social Q&A application built on Supabase and Flutter. With Supabase, you get a scalable PostgreSQL database, authentication, real-time capabilities, and more—empowering you to build amazing applications without being locked into proprietary platforms.

### License

This project is licensed under the MIT License. By contributing, you agree that your contributions will be licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

### P.S.

We ❤️ you and all of the ways you support us. Thank you for making ViBi a great place!

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for the full license.

---

Built with ❤️ using Flutter and Supabase

**Questions? [Report a bug](https://github.com/yourusername/vibi/issues) | [Request a feature](https://github.com/yourusername/vibi/issues)**
