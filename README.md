# Sam's Games - Daily Puzzle Collection

A unified iOS app featuring multiple daily puzzle games, inspired by NYT Games.

**Created**: January 2025
**Developer**: zYouSoft, Inc
**Owner**: Samir Hanna Safar

---

## 📱 Project Overview

Sam's Games combines multiple puzzle games into one unified iOS application where users can:
- Play **one puzzle per day** for each game
- Track **completion streaks** and statistics
- Access **archive of previous puzzles** (last 30 days)
- Enjoy **randomly generated** puzzles with timezone-based daily rotation

---

## 🎮 Games Included

### 1. X-Numbers
**Type**: Cross-sum puzzle (Kakuro variant)
**Status**: Ready to integrate
**Location**: `/Users/samirsafar/Desktop/x-numbers/X-Numbers-Modern/X-Numbers/`
**Features**:
- Multiple board sizes (4x4, 6x6, Hexagonal)
- Coin/reward system
- Native Swift/SwiftUI implementation

### 2. Word In Shapes
**Type**: Word search in geometric shapes
**Status**: Ready to integrate
**Location**: `/Users/samirsafar/Desktop/WordInShapesModern/WordInShapesModern/`
**Features**:
- 7x7 grid with 7 shape types
- 10 target words per puzzle
- Clean modular architecture

---

## 📂 Project Structure

```
Sam's Games/
├── Sam's GamesApp.swift (App entry point)
│
├── Services/
│   ├── DailyPuzzleManager.swift (Timezone-based daily puzzles)
│   └── StatisticsManager.swift (Streaks, history, stats)
│
├── Views/
│   ├── MainMenuView.swift (NYT Games-style card interface)
│   ├── ArchiveView.swift (Browse previous 30 days)
│   └── StatisticsView.swift (Show streaks and stats)
│
├── Models/ (Game-specific models to be added)
├── ViewModels/ (Game-specific view models)
└── Resources/ (Assets, images, etc.)
```

---

## 🗂️ File Locations

### Main Project
```
/Users/samirsafar/Desktop/SamsGames/
```

### Core Files Created
| File | Purpose |
|------|---------|
| `SamsGamesApp.swift` | App entry point with environment objects |
| `Services/DailyPuzzleManager.swift` | Handles daily puzzle logic, date-based seeds |
| `Services/StatisticsManager.swift` | Tracks streaks, history, statistics |
| `Views/MainMenuView.swift` | Main game selection menu |
| `Views/ArchiveView.swift` | Calendar view for previous puzzles |
| `Views/StatisticsView.swift` | Statistics and streaks display |

---

## 🔧 Key Features Implemented

### ✅ Daily Puzzle System
- **Timezone-based** daily rotation (same day = same puzzle for user's timezone)
- Date-based seed generation ensures consistency
- Auto-resets at midnight user local time

### ✅ Statistics Tracking
- Games played count
- Current streak (consecutive days)
- Longest streak
- Completion history by date

### ✅ Archive System
- Browse last 30 days of puzzles
- Play any previous day's puzzle
- See completion status for each date/game

### ✅ Main Menu
- NYT Games-style card interface
- Shows completion status (✓ green checkmark)
- Displays current streak with flame icon
- Clean, modern UI

---

## 📋 Implementation Status

### Phase 1: Core Framework ✅ COMPLETE
- [x] Project structure created
- [x] DailyPuzzleManager with timezone logic
- [x] StatisticsManager with streak tracking
- [x] Main menu with game cards
- [x] Archive view for previous puzzles
- [x] Statistics view for streaks

### Phase 2: Game Integration 🔨 IN PROGRESS
- [ ] Integrate Word In Shapes (easier, modular architecture)
- [ ] Integrate X-Numbers (requires refactoring)
- [ ] Add daily puzzle wrapper to each game
- [ ] Connect game completion to statistics

### Phase 3: Polish & Testing ⏳ PENDING
- [ ] Consistent UI/UX across games
- [ ] App icon and splash screen
- [ ] Test daily puzzle rotation
- [ ] Test statistics accuracy
- [ ] Prepare for App Store

---

## 🎯 Next Steps

### Immediate (Next Session):
1. **Integrate Word In Shapes First**
   - Copy Models, Services, ViewModels folders
   - Wrap game view with daily puzzle logic
   - Connect to DailyPuzzleManager
   - Test completion tracking

2. **Then Integrate X-Numbers**
   - Extract logic from 2,278-line FixedXNumbersGame.swift
   - Modularize into separate files
   - Add daily puzzle wrapper
   - Preserve coin/reward system

### To Create in Xcode:
You'll need to manually create the Xcode project:
1. Open Xcode
2. File → New → Project
3. iOS → App
4. Name: "SamsGames"
5. Bundle ID: com.zyousoft.SamsGames
6. Interface: SwiftUI
7. Save to: `/Users/samirsafar/Desktop/SamsGames/`
8. Add all created .swift files to the project

---

## 🏗️ Technical Architecture

### Daily Puzzle Logic
```swift
// Each game gets a seed based on today's date
let seed = dailyPuzzleManager.getSeedForToday()
// seed = "2025-01-12".hashValue

// Use seed for random generation
var generator = SeededRandomGenerator(seed: seed)
// Generate puzzle with consistent results
```

### Completion Flow
```swift
// 1. User completes puzzle
// 2. Game calls:
dailyPuzzleManager.markCompleted(.xNumbers)

// 3. Statistics manager updates:
statisticsManager.recordCompletion(.xNumbers)

// 4. UI updates to show checkmark and streak
```

### Data Persistence
- **UserDefaults** for lightweight data
- **Codable** protocol for serialization
- Automatic save on completion

---

## 📊 Game Types Enum

```swift
enum GameType: String, CaseIterable {
    case xNumbers = "X-Numbers"
    case wordInShapes = "Word In Shapes"
    // Easy to add more games!
}
```

---

## 🎨 UI Design

### Main Menu
- Card-based layout (like NYT Games)
- Each card shows:
  - Game icon
  - Game name
  - Description
  - Completion status (✓ or →)
  - Current streak (🔥 flame icon)

### Color Scheme
- Completed: Green accent
- Active: Blue accent
- Streak: Orange flame
- Background: System grouped background

---

## 💾 Data Storage

### DailyPuzzleManager Keys
- `completedToday`: Set of completed games (reset daily)
- `lastCheckDate`: Last date app was opened

### StatisticsManager Keys
- `gameStatistics`: Dictionary of all game statistics
  - Games played
  - Current streak
  - Longest streak
  - Completion history (date → boolean)

---

## 🚀 Future Enhancements

### Potential Features:
- [ ] Push notifications for daily puzzles
- [ ] Share results to social media
- [ ] Leaderboards / multiplayer
- [ ] More games (Sudoku, Crossword, etc.)
- [ ] Dark mode themes
- [ ] Achievements system
- [ ] Monthly challenges

---

## 📝 Notes

### Why This Architecture?
1. **Modular**: Easy to add new games
2. **Scalable**: Clean separation of concerns
3. **Maintainable**: Each game is independent
4. **Lightweight**: No external dependencies
5. **Native**: 100% Swift/SwiftUI

### Design Decisions:
- **Timezone-based**: Same puzzle for users in same timezone on same day
- **30-day archive**: Balance between features and storage
- **UserDefaults**: Perfect for this amount of data
- **No backend**: Everything client-side for simplicity

---

## 👨‍💻 Development

### Prerequisites
- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- iOS 15.0+ deployment target

### Build Instructions
1. Open `SamsGames.xcodeproj` in Xcode
2. Select target device (simulator or physical)
3. Press ⌘ + R to build and run

### Testing
- Test daily reset at midnight
- Test streak counting across multiple days
- Test archive browsing
- Test completion persistence

---

## 📞 Contact

**Developer**: zYouSoft, Inc
**Owner**: Samir Hanna Safar
**Email**: samir@zyousoft.com

---

## 📄 License

© 2025 zYouSoft, Inc. All rights reserved.

---

**Current Status**: Core framework complete, ready for game integration!
**Last Updated**: January 2025
**Version**: 1.0.0 (Foundation)
