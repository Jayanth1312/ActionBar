# ActionBar
ActionBar is a versatile Flutter application that provides quick access to various actions and information through a simple command-based interface. It's designed to streamline common tasks like web searches, weather checks, setting alarms, and more.

## Features

### Web Search and Summarization
- Use `@w [query]` to search the web and get AI-summarized results
- View concise summaries of web content with source attribution
- Copy summaries to clipboard with a single tap
- Save summaries directly to your notes app
- Click on source icons to visit original websites

### Weather Information
- Type `weather in [city]` to get current weather conditions
- View detailed weather data including temperature, feels like, humidity, wind, and more
- Clean, visually appealing weather cards with appropriate icons and color schemes

### Quick Actions
- **Email**: `@m [email] [subject]` to compose an email
- **YouTube**: `@yt [query]` to search YouTube
- **Google Search**: `@[query]` for direct Google searches
- **Notes**: `@n [title]` to create a new note
- **Alarms**: `@a [hour] [minute] [am/pm]` to set alarms (e.g., `@a 8 30 am` or `@a 17 45`)
- **Timers**: `@t [time]` to set timers (e.g., `@t 5min` or `@t 1hr 30min`)
- **Web results**: `@w [query]` to scrape the top 3 websites and give the data to the gemini model for summarized data presentation (e.g., `@w what is an android intent`)

### User Interface
- Clean, modern interface with dark mode support
- Suggestion chips for quick access to common commands
- Status messages for action feedback
- Responsive design that works across different screen sizes

## Technical Details

### Architecture
- Flutter-based UI with Material Design components
- Native integration with Android system services via Method Channels
- Integration with Gemini AI for web content summarization
- Secure API key management using environment variables

### Device Compatibility
- Special handling for OnePlus devices (notes, alarms, timers) also for google specifics like keepnotes and googl clock also
- Fallback mechanisms for different Android manufacturers
- Cross-platform support with appropriate fallbacks

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio or VS Code with Flutter extensions
- API key for Gemini AI
- API key for weather forecasts

### Setup
1. Clone the repository
2. Create a `.env` file in the project root with your API keys:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   OPEN_WEATHER_API_KEY=your_open_weather_api_key
   ```
3. Run `flutter pub get` to install dependencies
4. Connect a device or start an emulator
5. Run `flutter run` to start the application

## Dependencies
- `flutter_dotenv`: For secure environment variable management
- `http`: For API requests
- `url_launcher`: For launching URLs and apps
- `android_intent_plus`: For Android-specific intents
- `flutter/services`: For clipboard functionality and method channels

## Future Enhancements
- iOS-specific native integrations
- Additional AI-powered features
- Voice command support
- Customizable themes and layouts
- Widget support for quick access from home screen
- Importantly text based suggestion filtering, meaning when i started typing a number it automatically filters the suggestions and shows only alarm and timer, for faster actions
