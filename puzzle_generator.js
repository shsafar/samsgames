// Hashtag Words Puzzle Generator
// Creates valid puzzles where all 4 words share the same middle character

// Common 5-letter words grouped by middle character (position 2)
const wordsByMiddleChar = {
  'A': [
    { word: 'Beach', hint: 'Sandy shore by the ocean' },
    { word: 'Reach', hint: 'Extend to touch something' },
    { word: 'Peace', hint: 'State without war or conflict' },
    { word: 'Frame', hint: 'Border around a picture' },
    { word: 'Place', hint: 'Location or position' },
    { word: 'Drama', hint: 'Theatrical performance or intense situation' },
    { word: 'Blame', hint: 'Hold responsible for fault' },
    { word: 'Flame', hint: 'Visible part of fire' },
    { word: 'Shade', hint: 'Area protected from sunlight' },
    { word: 'Trade', hint: 'Exchange of goods or services' },
    { word: 'Grade', hint: 'Score or level of quality' },
    { word: 'Trash', hint: 'Waste or garbage' },
    { word: 'Flash', hint: 'Brief burst of bright light' },
    { word: 'Crash', hint: 'Violent collision or impact' },
    { word: 'Brass', hint: 'Yellow metal alloy' },
    { word: 'Grass', hint: 'Green plants covering ground' },
    { word: 'Glass', hint: 'Transparent solid material' },
    { word: 'Class', hint: 'Group of students or category' }
  ],
  'E': [
    { word: 'Bread', hint: 'Baked food made from flour' },
    { word: 'Treat', hint: 'Something special to enjoy' },
    { word: 'Field', hint: 'Open area of land' },
    { word: 'Yield', hint: 'Produce or give way' },
    { word: 'Cream', hint: 'Thick part of milk' },
    { word: 'Dream', hint: 'Images during sleep or aspiration' },
    { word: 'Steam', hint: 'Water vapor from boiling' },
    { word: 'Arena', hint: 'Large venue for sports' },
    { word: 'Break', hint: 'Separate into pieces' },
    { word: 'Steak', hint: 'Thick slice of beef' },
    { word: 'Speak', hint: 'Talk or express in words' },
    { word: 'Sneak', hint: 'Move quietly and secretly' },
    { word: 'Bleak', hint: 'Cold, empty, and depressing' },
    { word: 'Steal', hint: 'Take without permission' },
    { word: 'Shear', hint: 'Cut with scissors or shears' },
    { word: 'Clear', hint: 'Easy to see or understand' },
    { word: 'Ocean', hint: 'Vast body of salt water' },
    { word: 'Clean', hint: 'Free from dirt' }
  ],
  'I': [
    { word: 'Smile', hint: 'Happy facial expression' },
    { word: 'Climb', hint: 'Go up using hands and feet' },
    { word: 'Price', hint: 'Cost or amount of money' },
    { word: 'Spice', hint: 'Aromatic plant flavoring' },
    { word: 'Twice', hint: 'Two times or double' },
    { word: 'Slice', hint: 'Thin piece cut from something' },
    { word: 'Trick', hint: 'Clever act to deceive' },
    { word: 'Brick', hint: 'Block for building walls' },
    { word: 'Thick', hint: 'Having great width' },
    { word: 'Stick', hint: 'Thin piece of wood' },
    { word: 'Quick', hint: 'Fast or rapid' },
    { word: 'Crime', hint: 'Illegal act punishable by law' },
    { word: 'Prime', hint: 'Best quality or first' },
    { word: 'Grind', hint: 'Crush into powder' },
    { word: 'Blind', hint: 'Unable to see' },
    { word: 'Point', hint: 'Sharp end or purpose' },
    { word: 'Joint', hint: 'Place where two things meet' }
  ],
  'O': [
    { word: 'Float', hint: 'Rest on water surface' },
    { word: 'Proud', hint: 'Feeling pleased about achievement' },
    { word: 'Cloud', hint: 'White mass in sky' },
    { word: 'Flour', hint: 'Powder for baking' },
    { word: 'About', hint: 'Concerning or approximately' },
    { word: 'Shout', hint: 'Yell or cry loudly' },
    { word: 'Scout', hint: 'Person searching for something' },
    { word: 'Trout', hint: 'Freshwater fish' },
    { word: 'Frost', hint: 'Ice crystals on surfaces' },
    { word: 'Cross', hint: 'Go across or symbol +' },
    { word: 'Gross', hint: 'Disgusting or total amount' },
    { word: 'Proof', hint: 'Evidence showing truth' },
    { word: 'Spoon', hint: 'Utensil for eating' },
    { word: 'Stone', hint: 'Hard piece of rock' },
    { word: 'Phone', hint: 'Device for calling' },
    { word: 'Alone', hint: 'By yourself without others' },
    { word: 'Clone', hint: 'Exact genetic copy' }
  ],
  'R': [
    { word: 'Crown', hint: 'Royal headpiece worn by monarchs' },
    { word: 'Brown', hint: 'Color of wood or chocolate' },
    { word: 'Throw', hint: 'Propel through air' },
    { word: 'Arrow', hint: 'Pointed projectile from bow' },
    { word: 'Drawn', hint: 'Pulled or sketched' },
    { word: 'Fruit', hint: 'Sweet plant product with seeds' },
    { word: 'Truck', hint: 'Large vehicle for cargo' },
    { word: 'Trend', hint: 'General direction or style' },
    { word: 'Print', hint: 'Produce text on paper' },
    { word: 'Grant', hint: 'Give or allow formally' },
    { word: 'Brand', hint: 'Make of product or mark' },
    { word: 'Grand', hint: 'Large and impressive' }
  ],
  'U': [
    { word: 'Lunch', hint: 'Midday meal' },
    { word: 'Bunch', hint: 'Group of things together' },
    { word: 'Brush', hint: 'Tool with bristles' },
    { word: 'Crush', hint: 'Squeeze and break' },
    { word: 'Blush', hint: 'Turn red from embarrassment' },
    { word: 'Plump', hint: 'Pleasantly fat or rounded' },
    { word: 'Pluck', hint: 'Pull quickly or courage' },
    { word: 'Stuck', hint: 'Unable to move' },
    { word: 'Trunk', hint: 'Elephant nose or tree body' },
    { word: 'Drunk', hint: 'Intoxicated by alcohol' }
  ],
  'H': [
    { word: 'Shock', hint: 'Sudden surprising event' },
    { word: 'Wheat', hint: 'Grain for making flour' },
    { word: 'Cheat', hint: 'Act dishonestly to win' },
    { word: 'Cheap', hint: 'Low in price' },
    { word: 'Chair', hint: 'Furniture for sitting' },
    { word: 'Sharp', hint: 'Having fine cutting edge' },
    { word: 'Chart', hint: 'Visual display of information' },
    { word: 'Whole', hint: 'Complete or entire' },
    { word: 'While', hint: 'During the time that' },
    { word: 'Whale', hint: 'Largest marine mammal' },
    { word: 'Where', hint: 'At what place or location' },
    { word: 'There', hint: 'At that place' },
    { word: 'Their', hint: 'Belonging to them' },
    { word: 'Thing', hint: 'Object or item' }
  ],
  'L': [
    { word: 'Clash', hint: 'Violent collision or disagreement' },
    { word: 'Flash', hint: 'Brief burst of light' },
    { word: 'Slash', hint: 'Cut with violent stroke' },
    { word: 'Globe', hint: 'Spherical model of Earth' },
    { word: 'Slide', hint: 'Move smoothly along surface' },
    { word: 'Glide', hint: 'Move with continuous motion' },
    { word: 'Blade', hint: 'Sharp cutting edge' },
    { word: 'Album', hint: 'Collection of music or photos' },
    { word: 'Tales', hint: 'Stories or narratives' },
    { word: 'Scale', hint: 'Device for weighing' },
    { word: 'Stale', hint: 'No longer fresh' }
  ],
  'N': [
    { word: 'Dance', hint: 'Move to music rhythmically' },
    { word: 'Fence', hint: 'Barrier enclosing area' },
    { word: 'Hence', hint: 'Therefore or from now' },
    { word: 'Since', hint: 'From then until now' },
    { word: 'Tense', hint: 'Anxious or verb form' },
    { word: 'Dense', hint: 'Closely packed together' },
    { word: 'Angel', hint: 'Heavenly spiritual being' },
    { word: 'Anger', hint: 'Strong feeling of displeasure' },
    { word: 'Mange', hint: 'Skin disease in animals' }
  ],
  'T': [
    { word: 'Match', hint: 'Competition or corresponding pair' },
    { word: 'Watch', hint: 'Observe or timepiece' },
    { word: 'Catch', hint: 'Grab moving object' },
    { word: 'Batch', hint: 'Group produced together' },
    { word: 'Witch', hint: 'Person with magical powers' },
    { word: 'Pitch', hint: 'Throw or musical frequency' },
    { word: 'Ditch', hint: 'Narrow channel or abandon' },
    { word: 'Hatch', hint: 'Emerge from egg' }
  ]
};

// Generate valid puzzle combinations
function generatePuzzles(middleChar, count = 10) {
  const words = wordsByMiddleChar[middleChar];
  if (!words || words.length < 4) {
    console.log(`⚠️  Not enough words for middle char '${middleChar}'`);
    return [];
  }

  const puzzles = [];
  const used = new Set();

  // Try to generate unique combinations
  let attempts = 0;
  const maxAttempts = count * 100;

  while (puzzles.length < count && attempts < maxAttempts) {
    attempts++;

    // Randomly pick 4 different words
    const indices = [];
    while (indices.length < 4) {
      const idx = Math.floor(Math.random() * words.length);
      if (!indices.includes(idx)) {
        indices.push(idx);
      }
    }

    const [topIdx, bottomIdx, leftIdx, rightIdx] = indices;
    const combo = [topIdx, bottomIdx, leftIdx, rightIdx].sort().join('-');

    // Check if we've used this combination
    if (used.has(combo)) continue;

    const puzzle = {
      top: words[topIdx],
      bottom: words[bottomIdx],
      left: words[leftIdx],
      right: words[rightIdx],
      middleChar: middleChar
    };

    puzzles.push(puzzle);
    used.add(combo);
  }

  return puzzles;
}

// Generate puzzles for each level
function generateLevel(levelName, targetCount) {
  console.log(`\n${'='.repeat(50)}`);
  console.log(`Generating ${levelName}`);
  console.log('='.repeat(50));

  const allPuzzles = [];
  const middleChars = Object.keys(wordsByMiddleChar);

  // Distribute puzzles across different middle characters
  const puzzlesPerChar = Math.ceil(targetCount / middleChars.length);

  for (const char of middleChars) {
    const puzzles = generatePuzzles(char, puzzlesPerChar);
    allPuzzles.push(...puzzles);

    if (allPuzzles.length >= targetCount) break;
  }

  // Trim to exact count
  return allPuzzles.slice(0, targetCount);
}

// Format puzzle for HTML output
function formatPuzzle(puzzle, id) {
  return `    {
      id: "${id}",
      top:    { answer: "${puzzle.top.word.toUpperCase()}", hint: "${puzzle.top.hint}" },
      bottom: { answer: "${puzzle.bottom.word.toUpperCase()}", hint: "${puzzle.bottom.hint}" },
      left:   { answer: "${puzzle.left.word.toUpperCase()}", hint: "${puzzle.left.hint}" },
      right:  { answer: "${puzzle.right.word.toUpperCase()}", hint: "${puzzle.right.hint}" }
    }`;
}

// Main execution
console.log('🎮 Hashtag Words Puzzle Generator');
console.log('Generating valid puzzles with shared middle characters...\n');

// Generate puzzles for each level
const level1Puzzles = generateLevel('Level 1', 30);
const level2Puzzles = generateLevel('Level 2', 30);
const level3Puzzles = generateLevel('Level 3', 30);

// Output Level 1
console.log('\n\n// ========== LEVEL 1 NEW PUZZLES ==========');
level1Puzzles.forEach((puzzle, idx) => {
  console.log(formatPuzzle(puzzle, `L1-${idx + 11}`));
  if (idx < level1Puzzles.length - 1) console.log(',');
});

// Output Level 2
console.log('\n\n// ========== LEVEL 2 NEW PUZZLES ==========');
level2Puzzles.forEach((puzzle, idx) => {
  console.log(formatPuzzle(puzzle, `L2-${idx + 11}`));
  if (idx < level2Puzzles.length - 1) console.log(',');
});

// Output Level 3
console.log('\n\n// ========== LEVEL 3 NEW PUZZLES ==========');
level3Puzzles.forEach((puzzle, idx) => {
  console.log(formatPuzzle(puzzle, `L3-${idx + 21}`));
  if (idx < level3Puzzles.length - 1) console.log(',');
});

console.log('\n\n✅ Generated:');
console.log(`   Level 1: ${level1Puzzles.length} puzzles`);
console.log(`   Level 2: ${level2Puzzles.length} puzzles`);
console.log(`   Level 3: ${level3Puzzles.length} puzzles`);
console.log(`   Total: ${level1Puzzles.length + level2Puzzles.length + level3Puzzles.length} new puzzles`);
