// Validation script for Hashtag Words puzzles
const fs = require('fs');

// Read the HTML file
const htmlPath = './SamsGames/SamsGames/Games/HashtagWords/hashtagwords.html';
const htmlContent = fs.readFileSync(htmlPath, 'utf8');

// Extract puzzle data
const extractPuzzles = (levelName) => {
  const regex = new RegExp(`const ${levelName} = \\[([\\s\\S]*?)\\];`, 'm');
  const match = htmlContent.match(regex);
  if (!match) return [];

  const puzzleText = match[1];
  const puzzles = [];
  const puzzleRegex = /{\s*id:\s*"([^"]+)",\s*top:\s*{\s*answer:\s*"([^"]+)"[^}]*},\s*bottom:\s*{\s*answer:\s*"([^"]+)"[^}]*},\s*left:\s*{\s*answer:\s*"([^"]+)"[^}]*},\s*right:\s*{\s*answer:\s*"([^"]+)"[^}]*}\s*}/g;

  let puzzleMatch;
  while ((puzzleMatch = puzzleRegex.exec(puzzleText)) !== null) {
    puzzles.push({
      id: puzzleMatch[1],
      top: puzzleMatch[2],
      bottom: puzzleMatch[3],
      left: puzzleMatch[4],
      right: puzzleMatch[5]
    });
  }

  return puzzles;
};

// Get middle character (position 2 for 5-char words, considering # for 4-char)
const getMiddleChar = (word) => {
  // Remove # symbol
  const cleanWord = word.replace('#', '');

  if (cleanWord.length === 4) {
    // For 4-letter words: positions are 0,1,2,3 - middle intersection is between 1 and 2
    // The # indicates which end, so middle is still at index 1 or 2
    if (word.startsWith('#')) {
      return cleanWord[1]; // Second char of 4-letter word
    } else {
      return cleanWord[2]; // Third char of 4-letter word
    }
  } else if (cleanWord.length === 5) {
    return cleanWord[2]; // Middle char at index 2
  }

  return null;
};

// Validate a single puzzle
const validatePuzzle = (puzzle) => {
  const topChar = getMiddleChar(puzzle.top);
  const bottomChar = getMiddleChar(puzzle.bottom);
  const leftChar = getMiddleChar(puzzle.left);
  const rightChar = getMiddleChar(puzzle.right);

  // The center forms two words:
  // Vertical (top to bottom): topChar + centerChar + bottomChar
  // Horizontal (left to right): leftChar + centerChar + rightChar

  // For valid intersection, we need:
  // topChar and bottomChar should be same as leftChar and rightChar form a pattern

  // Actually, let me reconsider the logic:
  // In hashtag game, all 4 words intersect at the CENTER cell
  // So the middle character of each word should all be THE SAME

  const errors = [];

  if (topChar !== bottomChar) {
    errors.push(`Top middle '${topChar}' != Bottom middle '${bottomChar}'`);
  }

  if (leftChar !== rightChar) {
    errors.push(`Left middle '${leftChar}' != Right middle '${rightChar}'`);
  }

  if (topChar !== leftChar) {
    errors.push(`Top middle '${topChar}' != Left middle '${leftChar}'`);
  }

  // All should be the same character
  if (!(topChar === bottomChar && bottomChar === leftChar && leftChar === rightChar)) {
    errors.push(`All middle characters must be the same. Got: T='${topChar}', B='${bottomChar}', L='${leftChar}', R='${rightChar}'`);
  }

  return errors;
};

// Main validation
console.log('🔍 Validating Hashtag Words Puzzles...\n');

const levels = [
  { name: 'PUZZLES_L1', label: 'Level 1' },
  { name: 'PUZZLES_L2', label: 'Level 2' },
  { name: 'PUZZLES_L3', label: 'Level 3' }
];

let totalPuzzles = 0;
let invalidPuzzles = 0;
const invalidList = [];

levels.forEach(level => {
  console.log(`\n${'='.repeat(50)}`);
  console.log(`${level.label} (${level.name})`);
  console.log('='.repeat(50));

  const puzzles = extractPuzzles(level.name);
  console.log(`Total puzzles: ${puzzles.length}\n`);

  puzzles.forEach(puzzle => {
    totalPuzzles++;
    const errors = validatePuzzle(puzzle);

    if (errors.length > 0) {
      invalidPuzzles++;
      console.log(`❌ ${puzzle.id}:`);
      console.log(`   Top: ${puzzle.top}`);
      console.log(`   Bottom: ${puzzle.bottom}`);
      console.log(`   Left: ${puzzle.left}`);
      console.log(`   Right: ${puzzle.right}`);
      errors.forEach(err => console.log(`   ERROR: ${err}`));
      console.log('');

      invalidList.push({
        level: level.label,
        ...puzzle,
        errors
      });
    }
  });
});

console.log('\n' + '='.repeat(50));
console.log('SUMMARY');
console.log('='.repeat(50));
console.log(`Total puzzles checked: ${totalPuzzles}`);
console.log(`Valid puzzles: ${totalPuzzles - invalidPuzzles}`);
console.log(`Invalid puzzles: ${invalidPuzzles}`);

if (invalidPuzzles > 0) {
  console.log('\n⚠️  VALIDATION FAILED!');
  console.log(`\nFound ${invalidPuzzles} invalid puzzle(s) that need to be fixed:`);
  invalidList.forEach(puzzle => {
    console.log(`\n  ${puzzle.level} - ${puzzle.id}:`);
    console.log(`    ${puzzle.top} / ${puzzle.bottom} / ${puzzle.left} / ${puzzle.right}`);
  });
} else {
  console.log('\n✅ All puzzles are valid!');
}

process.exit(invalidPuzzles > 0 ? 1 : 0);
