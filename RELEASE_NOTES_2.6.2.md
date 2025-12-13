# Sam's Games - Version 2.6.2 Release Notes

## 🎯 New Feature: Per-Game Archive Access

### NYT Games-Style Archive Button

We've added a new Archive button to every game card, inspired by The New York Times Games experience!

#### **What's New:**

- ✨ **Archive Button on Every Game** - Each of the 13 games now has a dedicated Archive button
- 📅 **Weekly Calendar View** - See the current week's puzzles at a glance
- 🎨 **Game-Specific Branding** - Calendar boxes use each game's unique color theme
- ✅ **Completion Tracking** - Green circle with white checkmark shows completed puzzles
- 🔒 **Subscription Paywall** - Non-subscribers see an attractive upgrade prompt
- 🎯 **Direct Archive Access** - Subscribers go straight to the full archive

#### **How It Works:**

1. **Tap the "Archive" button** on any game card
2. **See the current week** with completion status
3. **Subscribe to unlock** full archive access (or use test mode to try it!)
4. **Subscribed users** go directly to the full archive view

#### **UI Consistency:**

- Calendar boxes match each game's brand color (Blue for X-Numbers, Purple for Words In Shapes, etc.)
- Completed puzzles show the app's standard green circle with white checkmark
- Today's puzzle is highlighted
- Smooth shadows and polished design throughout

---

## 🛠️ Technical Improvements

### New Components

- **XNumbersArchiveView.swift** (Generic archive view for all games)
  - Accepts `gameType` parameter
  - Dynamic brand colors per game
  - Shows game-specific icons
  - Subscription checking logic
  - Clean paywall UI with "Explore over 390 past puzzles" message

### Updated Components

- **MainMenuView.swift**
  - Archive button added to all game cards
  - Consistent styling across all games
  - Shadow effects for depth

- **StatisticsView.swift**
  - Toggle subscription test mode (tap "Statistics" 5 times)
  - Cycle between subscribed/unsubscribed every 5 taps
  - Reset counter after each toggle

---

## 🎨 Design Details

### Color-Coded Archives

Each game's archive uses its unique brand color:
- **SumStacks**: Orange
- **WordStacks**: Mint
- **X-Numbers**: Blue
- **Words In Shapes**: Purple
- **JushBox**: Green
- **Double Bubble**: Pink
- **Diamond Stack**: Indigo
- **Hashtag Words**: Teal
- **TraceWiz**: Cyan
- **Arrow Race**: Red
- **DiskBreak**: Yellow
- **WaterTable**: Blue (lighter)
- **Atomic Nails**: Gray

### Completion Indicators

- **Incomplete past days**: Game icon on brand-colored background
- **Today (not completed)**: White checkmark on brand-colored background
- **Completed puzzles**: Green circle with white checkmark on light green background

---

## 🧪 Testing Features

### Subscription Toggle (Developer Testing)

1. Open **Statistics** screen
2. Tap "Statistics" text **5 times** within 2 seconds
3. Toggles between subscribed ↔ unsubscribed
4. Counter resets to 0 after each toggle
5. Alert confirms the change

---

## 📝 Files Modified

### New Files
- `SamsGames/Views/XNumbersArchiveView.swift` - Generic archive paywall view

### Modified Files
- `SamsGames/Views/MainMenuView.swift` - Added Archive button to all games
- `SamsGames/Views/StatisticsView.swift` - Improved subscription toggle testing

---

## 🎯 User Experience

This update brings a **premium, polished feel** to the app:
- Encourages subscription conversions with attractive archive access
- Makes it easy to revisit past puzzles
- Consistent with industry-leading puzzle apps (NYT Games)
- Maintains the app's clean, modern design language

---

**Version**: 2.6.2
**Release Date**: December 13, 2025
**Build**: TBD

---

## 🚀 What's Next

Future enhancements could include:
- Calendar navigation for older months
- Puzzle difficulty indicators in calendar
- Streak visualization
- Share completion screenshots

---

**Enjoy exploring your puzzle archives!** 🎉
