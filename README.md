<p align="center">
  <img src="assets/images/logo1.png" width="250" height="250" alt="ViBi Logo">
</p>

<h1 align="center">ViBi Social</h1>

<p align="center">
  <strong>Connect, Ask, and Share. The modern open-source social Q&A platform.</strong>
</p>

<p align="center">
  <a href="https://www.vibi.social/">Website</a> •
  <a href="#key-features">Features</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 🌍 Languages / اللغات

- 🇬🇧 [English](README.md)
- 🇸🇦 [العربية](README.ar.md)

## 🚀 About ViBi

ViBi is a powerful open-source social application built with Flutter and Supabase. It combines the engagement of modern social media with a dedicated Q&A system, allowing users to connect, follow their favorite creators, and ask questions (anonymously or publicly).

## ✨ Key Features

- **🔐 Robust Auth**: Secure Email/Password and Google OAuth login via Supabase.
- **👤 Rich Profiles**: Customizable user profiles with avatars, bios, and integrated social links.
- **📥 Smart Inbox**: A dedicated space for receiving and managing questions.
- **💬 Anonymous Q&A**: Ask and answer questions with optional anonymity.
- **📱 Dynamic Feed**: Real-time social feed showing content from people you follow.
- **📸 Stories**: Share ephemeral social content that lasts for 24 hours.
- **🔍 Advanced Search**: Find users and specific content quickly and efficiently.
- **🔔 Notifications**: Stay updated with real-time push notifications.

## 🏗 Architecture

The project is built using **Clean Architecture** principles to ensure scalability, testability, and maintainability:

- **Presentation Layer**: UI logic and state management using `Bloc/Cubit`.
- **Domain Layer**: Pure business logic, entities, and use case definitions.
- **Data Layer**: Repository implementations and data sources (GraphQL, Supabase, Rest).

*Recently refactored to enforce strict separation of concerns, standardized error handling with `Either`, and centralized common widgets.*

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- **Backend**: [Supabase](https://supabase.com/) (PostgreSQL, Storage, Real-time)
- **State Management**: [Bloc/Cubit](https://pub.dev/packages/flutter_bloc)
- **API Layer**: [GraphQL](https://graphql.org/) (via [Ferry](https://pub.dev/packages/ferry))
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Error Handling**: [Dartz](https://pub.dev/packages/dartz) (Functional Programming patterns)

## 🛠 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Dart SDK
- A Supabase project (for local development, you'll need your own API keys)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/hazzemSaid/ViBi.git
   cd ViBi
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment**:
   Create a `.env` file in the root directory with your Supabase and Google OAuth credentials.

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🤝 Contributing

We welcome high-quality contributions! Please follow these steps:

1. Check for [existing issues](https://github.com/hazzemSaid/ViBi/issues).
2. Open a new issue to discuss major changes before submitting a PR.
3. Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
4. Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`).

*Note: Current contribution scope is primarily frontend-focused.*

## 🛡 Security

If you discover any security issues, please email us at **security@vibi-app.dev**.

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by the ViBi Team
</p>
