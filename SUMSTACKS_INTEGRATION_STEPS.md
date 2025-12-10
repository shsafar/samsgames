# SumStacks Integration - Remaining Manual Steps

## ✅ COMPLETED FILES

1. `/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Games/SumStacks/sumstacks.html`
2. `/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Games/SumStacks/SumStacksGameView.swift`
3. `/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Games/SumStacks/SumStacksInstructionsView.swift`
4. `/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Views/GameInstructionsView.swift` - Updated to include SumStacks case

## 📝 REMAINING MANUAL STEPS IN XCODE

### 1. Find and Update GameType Enum

**Search for:** `enum GameType` in your Xcode project

**Add this case after `.wordStacks`:**
```swift
case sumStacks
```

**Also update the display name property (if it exists):**
```swift
var displayName: String {
    switch self {
    // ... other cases ...
    case .wordStacks: return "WordStacks"
    case .sumStacks: return "SumStacks"
    }
}
```

---

### 2. Find and Update DailyPuzzleManager

**Search for:** `class DailyPuzzleManager` or `DailyPuzzleManager.swift`

**Add these properties after the wordStacks completion properties:**
```swift
@Published var sumStacksCompleted = false
@Published var sumStacksCompletionDate: Date?
```

**Update the `isCompletedToday` function to include:**
```swift
case .sumStacks:
    return isSameDay(sumStacksCompletionDate, Date())
```

**Update the `markCompleted` function to include:**
```swift
case .sumStacks:
    sumStacksCompleted = true
    sumStacksCompletionDate = Date()
```

**Update the `checkForNewDay` function to reset SumStacks:**
```swift
if !isSameDay(sumStacksCompletionDate, currentDate) {
    sumStacksCompleted = false
}
```

---

### 3. Find and Update StatisticsManager

**Search for:** `class StatisticsManager` or `StatisticsManager.swift`

**Add recording support for SumStacks completions:**
```swift
func recordCompletion(_ gameType: GameType) {
    switch gameType {
    // ... other cases ...
    case .sumStacks:
        // Add statistics tracking if needed
        break
    }
}
```

---

### 4. Find and Update Main Menu / ContentView

**Search for:** `MainMenuView` or `ContentView` or the view with game navigation buttons

**Add SumStacks navigation button** (copy the pattern from WordStacks):
```swift
NavigationLink(destination: SumStacksGameView()
    .environmentObject(dailyPuzzleManager)
    .environmentObject(statisticsManager)) {
    GameButton(
        title: "SumStacks",
        icon: "sumstackicon",  // You'll need to create this icon
        description: "Stack numbers to reach target sums"
    )
}
```

---

### 5. Create Game Icons

**Required icon files** (in Assets.xcassets or appropriate location):

1. `sumstackicon.png` (1x - ~29x29 or appropriate size)
2. `sumstackicon@2x.png` (2x - ~58x58)
3. `sumstackicon@3x.png` (3x - ~87x87)

**Design suggestion:** Use numbers stacked vertically with a colorful gradient (orange/yellow theme to match the game)

---

### 6. Add SumStacks to Xcode Project

1. Open Xcode
2. Right-click on the "Games" folder
3. Select "Add Files to..."
4. Navigate to `/Users/samirsafar/Desktop/SamsGames/SamsGames/SamsGames/Games/SumStacks/`
5. Select all three files:
   - `sumstacks.html`
   - `SumStacksGameView.swift`
   - `SumStacksInstructionsView.swift`
6. Make sure "Copy items if needed" is checked
7. Make sure your target is selected
8. Click "Add"

---

### 7. Update Archive View (if exists)

**Search for:** `ArchiveView` or similar

**Add SumStacks to the archive list:**
```swift
case .sumStacks:
    NavigationLink(destination: SumStacksGameView(archiveMode: true, archiveDate: date)) {
        // Archive cell UI
    }
```

---

## 🎨 ICON CREATION TIPS

For the SumStacks icon, consider:
- Numbers 1, 2, 3 stacked vertically
- Orange/yellow gradient background
- Simple geometric shapes (hexagon, pentagon, square)
- Keep it simple and recognizable at small sizes

---

## ✅ TESTING CHECKLIST

After completing all steps:

- [ ] Build succeeds without errors
- [ ] SumStacks appears in main menu
- [ ] Can start a new SumStacks game
- [ ] Daily puzzle mode works (same puzzle each day)
- [ ] Archive mode works (can play past dates)
- [ ] Game completion triggers success alert
- [ ] Already completed screen shows after completing today's puzzle
- [ ] Instructions view displays correctly
- [ ] Game icons display properly

---

## 📄 FILES CREATED/MODIFIED

### Created:
1. `SamsGames/SamsGames/SamsGames/Games/SumStacks/sumstacks.html`
2. `SamsGames/SamsGames/SamsGames/Games/SumStacks/SumStacksGameView.swift`
3. `SamsGames/SamsGames/SamsGames/Games/SumStacks/SumStacksInstructionsView.swift`

### Modified:
1. `SamsGames/SamsGames/SamsGames/Views/GameInstructionsView.swift`

### Need to Modify:
1. GameType enum file (location unknown - search in Xcode)
2. DailyPuzzleManager file (location unknown - search in Xcode)
3. StatisticsManager file (location unknown - search in Xcode)
4. Main menu/ContentView file (location unknown - search in Xcode)
5. ArchiveView file if it exists

---

**Last Updated:** December 9, 2024
