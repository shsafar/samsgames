# Sam's Games - Setup Instructions

## 📋 Quick Start Guide

### Step 1: Create Xcode Project

1. **Open Xcode**

2. **File → New → Project**

3. **Choose template**: iOS → App

4. **Configure project**:
   - **Product Name**: `SamsGames`
   - **Team**: Select your team (or None for simulator only)
   - **Organization Identifier**: `com.zyousoft`
   - **Bundle Identifier**: `com.zyousoft.SamsGames`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: Leave unchecked
   - **Core Data**: Leave unchecked

5. **Click Next**, save to:
   ```
   /Users/samirsafar/Desktop/SamsGames/
   ```

### Step 2: Add Core Framework Files

Drag these files into your Xcode project:

**From `/Users/samirsafar/Desktop/SamsGames/SamsGames/`:**

1. **Main App**:
   - `SamsGamesApp.swift` (replaces default)

2. **Services**:
   - `Services/DailyPuzzleManager.swift`
   - `Services/StatisticsManager.swift`

3. **Views**:
   - `Views/MainMenuView.swift`
   - `Views/ArchiveView.swift`
   - `Views/StatisticsView.swift`

**When adding files:**
- ✅ Check "Copy items if needed"
- ✅ Check "Create groups"
- ✅ Add to target: "SamsGames"

### Step 3: Test Core Framework

1. **Build**: Press ⌘ + B
2. **Run**: Press ⌘ + R
3. **Expected**:
   - Main menu shows 2 game cards
   - Cards say "Coming Soon" when tapped
   - Archive button shows calendar icon
   - Statistics button shows chart icon

### Step 4: Integrate Word In Shapes (Next)

**Location**: `/Users/samirsafar/Desktop/WordInShapesModern/WordInShapesModern/`

1. **Copy folders** to SamsGames project:
   ```
   Models/
   Services/
   ViewModels/
   ```

2. **Add to Xcode** (drag into project)

3. **Create wrapper view**:
   - Modify game to use dailyPuzzleManager.getSeedForToday()
   - Call dailyPuzzleManager.markCompleted() on finish
   - Call statisticsManager.recordCompletion() on finish

4. **Update MainMenuView.swift**:
   Replace "Coming Soon" text with actual game view

### Step 5: Integrate X-Numbers (After Word In Shapes)

**Location**: `/Users/samirsafar/Desktop/x-numbers/X-Numbers-Modern/X-Numbers/X-Numbers/`

1. **Extract logic** from `FixedXNumbersGame.swift` (2,278 lines)

2. **Modularize into**:
   - Models/XNumbersGame.swift
   - ViewModels/XNumbersViewModel.swift
   - Services/XNumbersGenerator.swift

3. **Add to project** and connect to DailyPuzzleManager

4. **Update MainMenuView.swift**

### Step 6: Polish & Test

1. **Add app icon** to Assets.xcassets
2. **Test daily rotation**:
   - Change system date to tomorrow
   - Verify new puzzle loads
   - Verify streak updates

3. **Test archive**:
   - Play yesterday's puzzle
   - Verify completion tracking

4. **Test statistics**:
   - Complete puzzles on multiple days
   - Verify streak calculation

---

## 🔧 Troubleshooting

### "Cannot find 'DailyPuzzleManager' in scope"
- Make sure all Service files are added to target
- Check that files are in correct folders

### "No such module 'SwiftUI'"
- Ensure iOS Deployment Target is 15.0+
- Clean build folder: Product → Clean Build Folder (⌘ + Shift + K)

### Game views not showing
- Check that game files are added to target
- Verify import statements at top of files

### Daily puzzle not resetting
- Check system timezone settings
- Verify DailyPuzzleManager.checkForNewDay() is called on app launch

---

## 📱 Testing Checklist

### Core Framework:
- [ ] App launches without errors
- [ ] Main menu displays game cards
- [ ] Can open Archive view
- [ ] Can open Statistics view
- [ ] Game cards show correct icons

### Daily Puzzle System:
- [ ] Puzzle generates based on today's date
- [ ] Same puzzle loads when reopening app same day
- [ ] New puzzle loads next day
- [ ] Completion status persists

### Statistics:
- [ ] Completing game updates stats
- [ ] Streak increments on consecutive days
- [ ] Longest streak tracks correctly
- [ ] History shows completed dates

### Archive:
- [ ] Last 30 days display
- [ ] Can play previous puzzles
- [ ] Completion status shows correctly

---

## 🎯 Development Workflow

### Daily Development:
```bash
# 1. Navigate to project
cd /Users/samirsafar/Desktop/SamsGames

# 2. Open in Xcode
open SamsGames.xcodeproj

# 3. Make changes

# 4. Test (⌘ + R)

# 5. Commit to git
git add .
git commit -m "Description of changes"
```

### Adding a New Game:
1. Add game type to `GameType` enum
2. Add case to `gameView(for:)` in MainMenuView
3. Create game wrapper view
4. Connect to DailyPuzzleManager
5. Test!

---

## 📂 Project Organization

```
SamsGames/
├── SamsGames.xcodeproj
├── SamsGames/
│   ├── SamsGamesApp.swift
│   ├── Services/
│   │   ├── DailyPuzzleManager.swift
│   │   └── StatisticsManager.swift
│   ├── Views/
│   │   ├── MainMenuView.swift
│   │   ├── ArchiveView.swift
│   │   └── StatisticsView.swift
│   ├── Models/ (to be added)
│   ├── ViewModels/ (to be added)
│   └── Resources/ (to be added)
└── README.md
```

---

## 🚀 Ready to Start!

Once Xcode project is created and core files are added:
1. Build and run to verify framework works
2. Start integrating first game (Word In Shapes recommended)
3. Test thoroughly
4. Add second game (X-Numbers)
5. Polish and prepare for App Store!

---

**Last Updated**: January 2025
**Status**: Core framework ready, awaiting game integration
