# GitOrbit

GitOrbit is a streamlined, lightweight Flutter application for iOS designed to connect to your Git instance via an API key. Built with a stunning Tokyo Dark aesthetic, it aims to give you a fast overview of your repository's activity directly from your pocket.

## Features
- **Minimalist Design**: Featuring a "Tokyo Night" inspired dark theme.
- **Fast and Lean**: Built using Flutter and the `provider` state management pattern for a snappy, no-bloat experience.
- **Secure Configuration**: Uses `flutter_dotenv` to load sensitive API credentials locally. These files are excluded from source control.

### Core Sections
The app features a Bottom Navigation Bar offering 5 distinct tabs:

1. **Activity Dashboard**: A global feed of recent events across your organization (pushes, issues, merged requests). We fetch events from all team members in parallel and merge them into a chronological timeline, annotated with the repository name.
2. **Projects**: Your repositories, elegantly categorized by their parent Group/Organization.
   - **Lazy Loading**: Groups load instantly. Tapping a group loads its projects.
   - **Drill-down Tracing**: Tap any project to see its **Branches** (with `merged` and `protected` status). Tap any branch to see its full **Commit History** (including the author, date, and short hash).
3. **Team Analytics**: A quick look at your active team members. It filters the team to only show users with **> 0 activities in the last 7 days**, sorted by their weekly activity in descending order.
4. **Activity Heatmap**: A dedicated, GitHub-style horizontal heatmap spanning the last 30 days. It visually scales activity with dynamic coloring, grouping days chronologically with dynamic month labels indicating the date range.
5. **Thermometer**: See what's HOT 🔥 and what's COLD 🧊 in your organization based on recent repository activity.

## Setup & Configuration

1. **Clone the repository** (or use the existing folder).
2. **Create a `.env` file** at the root of the project:
   ```env
   API_URL="https://gitlab.com" # Or your custom Git instance URL
   API_KEY="your_personal_access_token_here"
   ```
3. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the Application**:
   ```bash
   flutter run
   ```

## Architecture
- **State Management**: `provider`
- **Network**: `http` via a lightweight custom `GitClient`
- **Theme**: Custom `TokyoDarkTheme` ensuring visual excellence across iOS devices.

---

*This application was built almost entirely using [Gemini 3.1](https://deepmind.google/technologies/gemini/), which is the AI model used as the primary coding assistant for this project.*
