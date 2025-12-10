# Release Notes - Version 1.9.5

## Bug Fixes & Improvements

### SumStacks
- **Fixed shape positioning**: Shapes are now properly centered horizontally to prevent truncation on the edges
- **Improved scrolling**: Added iOS momentum scrolling support for smooth touch scrolling on the game board
- **Better gameplay experience**: All shapes now stay within the visible area while maintaining full scrollability

### WordStacks
- **Archive completion tracking**: Completed archive puzzles now properly display checkmarks in the archive list
- **Archive replay prevention**: Once you complete an archive puzzle, it shows the completion screen if you try to play it again
- **Consistent behavior**: Archive mode now works exactly like regular daily puzzles for tracking completions

### User Interface
- **Archive button improvement**: Changed the calendar icon to "Archive" text label for better clarity and discoverability
- **Easier navigation**: Users can now more easily identify how to access past puzzles

## Technical Details
- Enhanced `SumStacksGameView.swift` to properly handle archive mode completion tracking
- Updated `WebWordStacksGameView.swift` to record completions for specific archive dates
- Modified `sumstacks.html` to center shapes at 50% width and enable iOS touch scrolling
- Improved `MainMenuView.swift` toolbar button for better user experience

---

**What's Coming Next**: More game improvements and new features based on user feedback!
