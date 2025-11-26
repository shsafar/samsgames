// Validation script for correct puzzles
const fs = require('fs');

// Read the generated puzzles file
const content = fs.readFileSync('correct_generated_puzzles.txt', 'utf8');

// Extract puzzle objects
const puzzleMatches = content.matchAll(/{\s*id:\s*"([^"]+)",\s*top:\s*{\s*answer:\s*"([^"]+)"[^}]+},\s*bottom:\s*{\s*answer:\s*"([^"]+)"[^}]+},\s*left:\s*{\s*answer:\s*"([^"]+)"[^}]+},\s*right:\s*{\s*answer:\s*"([^"]+)"[^}]+}\s*}/g);

let totalPuzzles = 0;
let validPuzzles = 0;
let invalidPuzzles = 0;

for (const match of puzzleMatches) {
  const [, id, top, bottom, left, right] = match;
  totalPuzzles++;

  // Validate constraints
  const errors = [];

  if (top[1] !== left[1]) {
    errors.push(`Top[1]='${top[1]}' != Left[1]='${left[1]}'`);
  }
  if (top[3] !== right[1]) {
    errors.push(`Top[3]='${top[3]}' != Right[1]='${right[1]}'`);
  }
  if (bottom[1] !== left[3]) {
    errors.push(`Bottom[1]='${bottom[1]}' != Left[3]='${left[3]}'`);
  }
  if (bottom[3] !== right[3]) {
    errors.push(`Bottom[3]='${bottom[3]}' != Right[3]='${right[3]}'`);
  }

  if (errors.length > 0) {
    console.log(`❌ INVALID: ${id}`);
    console.log(`   Top: ${top}, Bottom: ${bottom}, Left: ${left}, Right: ${right}`);
    errors.forEach(err => console.log(`   ${err}`));
    invalidPuzzles++;
  } else {
    validPuzzles++;
  }
}

console.log(`\n=== VALIDATION SUMMARY ===`);
console.log(`Total puzzles: ${totalPuzzles}`);
console.log(`Valid puzzles: ${validPuzzles} ✓`);
console.log(`Invalid puzzles: ${invalidPuzzles} ❌`);

if (invalidPuzzles === 0) {
  console.log(`\n🎉 All puzzles are valid!`);
} else {
  console.log(`\n⚠️  Some puzzles are invalid and need to be fixed.`);
  process.exit(1);
}
