# MovieSync 🎬

A modern, fluid movie and TV show exploration app built with Flutter.

## ⚖️ Disclaimer

**Please read this carefully before using or contributing to this project.**

1.  **Educational Purpose Only**: This project has been developed strictly for **educational and research purposes**. It serves as a personal portfolio project to demonstrate proficiency in Flutter, API integration, and UI/UX design.
2.  **No Content Hosting**: MovieSync **does not host, store, or distribute** any media files, movies, or videos. The application acts solely as a client-side interface that fetches metadata via the TMDB API and provides a webview interface for third-party streaming providers.
3.  **Third-Party Services**: All video content is provided by external, third-party streaming services. The developer of MovieSync has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third-party websites or services.
4.  **User Responsibility**: Any use of this application for "wrongdoing," copyright infringement, or any activity that violates local laws is the **sole responsibility of the end-user**. The developer shall not be held liable for any misuse of this software.
5.  **No Warranties**: This software is provided "as is" without warranty of any kind, express or implied.

---

## 🚀 Features

-   **Stunning UI**: Netflix-inspired design with smooth transitions and premium aesthetics.
-   **TMDB Integration**: Always up-to-date data for Trending, Popular, and Top Rated content.
-   **Advanced Search**: Quickly find any movie or show across a massive database.
-   **Multi-Server Player**: Integrated webview player with support for multiple streaming providers.
-   **Built-in Ad-Shielding**: Custom Javascript injection and resource blocking to ensure a cleaner viewing experience on supported servers.
-   **Responsive Design**: Fully optimized for various screen sizes and orientations.

## ⚒️ Technical Stack & Architecture

-   **Frontend Framework**: [Flutter](https://flutter.dev/) - Utilizing the latest stable release for high-performance, cross-platform UI.
-   **State Management**: [Riverpod](https://riverpod.dev/) - Implementing a robust, type-safe reactive state management solution.
-   **Service Layer**: [The Movie Database (TMDB) API](https://www.themoviedb.org/) - Industry-standard metadata source for high-fidelity movie/TV data.
-   **Web Interface**: [adblocker_webview](https://pub.dev/packages/adblocker_webview) - Custom-patched implementation for seamless third-party player integration.
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router) - Declarative routing for deep-linking and modular navigation.
-   **Network Layer**: [Dio](https://pub.dev/packages/dio) - Advanced HTTP client with interceptors for efficient API handling.

## 📦 Installation & Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/MrAbhi2k3/MovieSync.git
    cd MovieSync
    ```
2.  **Environment Configuration**:
    Create a `.env` file in the root directory and add your TMDB API Key:
    ```env
    TMDB_API_KEY=your_api_key_here
    ```
3.  **Dependencies**:
    Run `flutter pub get` to fetch and install all required packages.
4.  **Run Application**:
    Launch the app on your emulator or physical device using:
    ```bash
    flutter run
    ```

## 👨‍💻 Author

**MrAbhi2k3**
- GitHub: [@MrAbhi2k3](https://github.com/MrAbhi2k3)

---
*Developed by MrAbhi2k3 as a testing.*
