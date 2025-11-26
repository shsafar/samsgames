/**
 * Correct Hashtag Words Puzzle Generator
 *
 * Board Layout:
 *      c0  c1  c2  c3  c4
 * r0       [L0]     [R0]
 * r1   [T0][T1][T2][T3][T4]  <- Top word
 * r2       [L2] HOT [R2]
 * r3   [B0][B1][B2][B3][B4]  <- Bottom word
 * r4       [L4]     [R4]
 *
 * Intersection Constraints:
 * 1. Top[1] = Left[1]   (2nd letter of top = 2nd letter of left)
 * 2. Top[3] = Right[1]  (4th letter of top = 2nd letter of right)
 * 3. Bottom[1] = Left[3] (2nd letter of bottom = 4th letter of left)
 * 4. Bottom[3] = Right[3] (4th letter of bottom = 4th letter of right)
 */

// Word database - 5-letter words only
const wordDatabase = [
  { word: "ABOUT", hint: "Concerning or approximately" },
  { word: "ABOVE", hint: "Higher than or over" },
  { word: "ACTOR", hint: "Person who performs in plays or movies" },
  { word: "AGREE", hint: "Have the same opinion" },
  { word: "ALBUM", hint: "Collection of music or photos" },
  { word: "ALERT", hint: "Watchful and ready" },
  { word: "ALIEN", hint: "From another world" },
  { word: "ALIGN", hint: "Arrange in a straight line" },
  { word: "ALIVE", hint: "Living, not dead" },
  { word: "ALLOW", hint: "Permit or let happen" },
  { word: "ALONE", hint: "By yourself without others" },
  { word: "ALTER", hint: "Change or modify" },
  { word: "ANGEL", hint: "Heavenly spiritual being" },
  { word: "ANGER", hint: "Strong feeling of displeasure" },
  { word: "ANGLE", hint: "Space between two intersecting lines" },
  { word: "APART", hint: "Separated by distance" },
  { word: "ARENA", hint: "Large venue for sports" },
  { word: "ARROW", hint: "Pointed projectile from bow" },
  { word: "BATCH", hint: "Group produced together" },
  { word: "BEACH", hint: "Sandy shore by the ocean" },
  { word: "BEAST", hint: "Wild animal" },
  { word: "BLADE", hint: "Sharp cutting edge" },
  { word: "BLAME", hint: "Hold responsible for fault" },
  { word: "BLANK", hint: "Empty or without marks" },
  { word: "BLAST", hint: "Explosion or strong gust" },
  { word: "BLEAK", hint: "Cold, empty, and depressing" },
  { word: "BLEND", hint: "Mix together thoroughly" },
  { word: "BLESS", hint: "Ask for divine favor" },
  { word: "BLIND", hint: "Unable to see" },
  { word: "BLOCK", hint: "Solid piece or obstruct" },
  { word: "BLOOM", hint: "Flower or flourish" },
  { word: "BLUNT", hint: "Not sharp or direct" },
  { word: "BLUSH", hint: "Turn red from embarrassment" },
  { word: "BOARD", hint: "Flat piece of wood" },
  { word: "BOAST", hint: "Brag about achievements" },
  { word: "BRAIN", hint: "Organ for thinking" },
  { word: "BRAND", hint: "Make of product or mark" },
  { word: "BRASS", hint: "Yellow metal alloy" },
  { word: "BRAVE", hint: "Courageous and fearless" },
  { word: "BREAD", hint: "Baked food made from flour" },
  { word: "BREAK", hint: "Separate into pieces" },
  { word: "BRICK", hint: "Block for building walls" },
  { word: "BRIEF", hint: "Short in duration" },
  { word: "BRING", hint: "Carry something here" },
  { word: "BROAD", hint: "Wide in extent" },
  { word: "BROWN", hint: "Color of wood or chocolate" },
  { word: "BRUSH", hint: "Tool with bristles" },
  { word: "BUILD", hint: "Construct or create" },
  { word: "BUNCH", hint: "Group of things together" },
  { word: "CATCH", hint: "Grab moving object" },
  { word: "CHAIR", hint: "Furniture for sitting" },
  { word: "CHAIN", hint: "Connected metal links" },
  { word: "CHAOS", hint: "Complete disorder" },
  { word: "CHARM", hint: "Attractive quality or spell" },
  { word: "CHASE", hint: "Run after to catch" },
  { word: "CHEAP", hint: "Low in price" },
  { word: "CHEAT", hint: "Act dishonestly to win" },
  { word: "CHECK", hint: "Verify or examine" },
  { word: "CHEST", hint: "Box for storage or body part" },
  { word: "CHIEF", hint: "Leader or most important" },
  { word: "CHILD", hint: "Young person" },
  { word: "CHILL", hint: "Make cold or relax" },
  { word: "CLAIM", hint: "Assert as true" },
  { word: "CLAMP", hint: "Device for holding things tight" },
  { word: "CLASH", hint: "Violent collision or disagreement" },
  { word: "CLASS", hint: "Group of students or category" },
  { word: "CLEAN", hint: "Free from dirt" },
  { word: "CLEAR", hint: "Easy to see or understand" },
  { word: "CLICK", hint: "Short sharp sound" },
  { word: "CLIFF", hint: "Steep rock face" },
  { word: "CLIMB", hint: "Go up using hands and feet" },
  { word: "CLOCK", hint: "Device showing time" },
  { word: "CLONE", hint: "Exact genetic copy" },
  { word: "CLOSE", hint: "Near or shut" },
  { word: "CLOTH", hint: "Fabric or material" },
  { word: "CLOUD", hint: "White mass in sky" },
  { word: "CLOWN", hint: "Comic performer at circus" },
  { word: "COACH", hint: "Trainer or bus" },
  { word: "COAST", hint: "Land near the sea" },
  { word: "COVER", hint: "Place something over" },
  { word: "CRACK", hint: "Break or narrow opening" },
  { word: "CRAFT", hint: "Skill or handmade item" },
  { word: "CRASH", hint: "Violent collision or impact" },
  { word: "CRAZY", hint: "Insane or enthusiastic" },
  { word: "CREAM", hint: "Thick part of milk" },
  { word: "CRIME", hint: "Illegal act" },
  { word: "CROSS", hint: "Go across or symbol +" },
  { word: "CROWD", hint: "Large group of people" },
  { word: "CROWN", hint: "Royal headpiece worn by monarchs" },
  { word: "CRUSH", hint: "Squeeze and break" },
  { word: "DANCE", hint: "Move to music rhythmically" },
  { word: "DENSE", hint: "Closely packed together" },
  { word: "DITCH", hint: "Narrow channel or abandon" },
  { word: "DRAFT", hint: "Preliminary version" },
  { word: "DRAIN", hint: "Empty out liquid" },
  { word: "DRAMA", hint: "Theatrical performance or intense situation" },
  { word: "DRAWN", hint: "Pulled or sketched" },
  { word: "DREAM", hint: "Imagery in mind during sleep" },
  { word: "DRIFT", hint: "Move slowly or pile of snow" },
  { word: "DRINK", hint: "Swallow liquid" },
  { word: "DRIVE", hint: "Operate a vehicle" },
  { word: "DROWN", hint: "Die underwater from lack of air" },
  { word: "EARLY", hint: "Before the expected time" },
  { word: "EARTH", hint: "Our planet or soil" },
  { word: "EMPTY", hint: "Containing nothing" },
  { word: "EQUAL", hint: "The same in amount" },
  { word: "ERROR", hint: "Mistake or fault" },
  { word: "EXACT", hint: "Precise and accurate" },
  { word: "EXTRA", hint: "More than usual" },
  { word: "FAITH", hint: "Strong belief or trust" },
  { word: "FALSE", hint: "Not true or real" },
  { word: "FANCY", hint: "Elaborate or decorative" },
  { word: "FATAL", hint: "Causing death" },
  { word: "FAULT", hint: "Defect or responsibility for mistake" },
  { word: "FEAST", hint: "Large elaborate meal" },
  { word: "FENCE", hint: "Barrier enclosing area" },
  { word: "FIELD", hint: "Open area of land" },
  { word: "FIGHT", hint: "Battle or struggle" },
  { word: "FINAL", hint: "Last in series" },
  { word: "FIRST", hint: "Before all others" },
  { word: "FIXED", hint: "Repaired or attached" },
  { word: "FLAME", hint: "Visible part of fire" },
  { word: "FLASH", hint: "Brief burst of bright light" },
  { word: "FLESH", hint: "Soft tissue of body" },
  { word: "FLIGHT", hint: "Act of flying" },
  { word: "FLOAT", hint: "Rest on water surface" },
  { word: "FLOOD", hint: "Overflow of water" },
  { word: "FLOOR", hint: "Bottom surface of room" },
  { word: "FLOUR", hint: "Powder for baking" },
  { word: "FOCUS", hint: "Center of attention" },
  { word: "FORCE", hint: "Strength or power" },
  { word: "FORTH", hint: "Forward in time or space" },
  { word: "FRAME", hint: "Border around a picture" },
  { word: "FRANK", hint: "Honest and direct" },
  { word: "FRAUD", hint: "Deception for gain" },
  { word: "FRESH", hint: "New or not stale" },
  { word: "FRONT", hint: "Forward part" },
  { word: "FROST", hint: "Frozen dew or ice" },
  { word: "FRUIT", hint: "Sweet plant product with seeds" },
  { word: "GIANT", hint: "Extremely large person or thing" },
  { word: "GLASS", hint: "Transparent solid material" },
  { word: "GLIDE", hint: "Move with continuous motion" },
  { word: "GLOBE", hint: "Spherical model of Earth" },
  { word: "GLORY", hint: "Great honor or magnificence" },
  { word: "GLOVE", hint: "Hand covering" },
  { word: "GRACE", hint: "Elegance or divine favor" },
  { word: "GRADE", hint: "Score or level of quality" },
  { word: "GRAIN", hint: "Small seed or texture" },
  { word: "GRAND", hint: "Large and impressive" },
  { word: "GRANT", hint: "Give or allow formally" },
  { word: "GRAPH", hint: "Diagram showing relationship" },
  { word: "GRASP", hint: "Grip firmly or understand" },
  { word: "GRASS", hint: "Green plants covering ground" },
  { word: "GRAVE", hint: "Burial place or serious" },
  { word: "GREAT", hint: "Very good or large" },
  { word: "GREED", hint: "Excessive desire for wealth" },
  { word: "GREEN", hint: "Color of grass" },
  { word: "GREET", hint: "Welcome or acknowledge" },
  { word: "GRIEF", hint: "Deep sorrow" },
  { word: "GRILL", hint: "Cook over direct heat" },
  { word: "GRIND", hint: "Crush into powder" },
  { word: "GROSS", hint: "Disgusting or total amount" },
  { word: "GROUP", hint: "Collection of people or things" },
  { word: "GROVE", hint: "Small group of trees" },
  { word: "GUARD", hint: "Protect or watchman" },
  { word: "GUESS", hint: "Estimate without knowing" },
  { word: "GUEST", hint: "Visitor or person invited" },
  { word: "GUIDE", hint: "Show the way" },
  { word: "GUILT", hint: "Feeling of having done wrong" },
  { word: "HABIT", hint: "Regular behavior pattern" },
  { word: "HAPPY", hint: "Feeling joy" },
  { word: "HARSH", hint: "Rough or severe" },
  { word: "HATCH", hint: "Emerge from egg" },
  { word: "HEART", hint: "Organ that pumps blood" },
  { word: "HEAVY", hint: "Having great weight" },
  { word: "HENCE", hint: "Therefore or from now" },
  { word: "HORSE", hint: "Large four-legged animal" },
  { word: "HOUSE", hint: "Building to live in" },
  { word: "HUMAN", hint: "Person or relating to people" },
  { word: "IDEAL", hint: "Perfect or best possible" },
  { word: "IMAGE", hint: "Picture or representation" },
  { word: "INNER", hint: "Inside or internal" },
  { word: "INPUT", hint: "Information or data entered" },
  { word: "JOINT", hint: "Place where two things meet" },
  { word: "JUDGE", hint: "Make decisions in court" },
  { word: "KNIFE", hint: "Cutting tool with blade" },
  { word: "LARGE", hint: "Big in size" },
  { word: "LATER", hint: "After the present time" },
  { word: "LAYER", hint: "Single thickness" },
  { word: "LEARN", hint: "Gain knowledge" },
  { word: "LEASE", hint: "Rent property" },
  { word: "LEAST", hint: "Smallest amount" },
  { word: "LEAVE", hint: "Go away or depart" },
  { word: "LEGAL", hint: "Permitted by law" },
  { word: "LEMON", hint: "Yellow citrus fruit" },
  { word: "LEVEL", hint: "Flat or degree" },
  { word: "LIGHT", hint: "Brightness or not heavy" },
  { word: "LIMIT", hint: "Maximum boundary" },
  { word: "LOCAL", hint: "Nearby or from the area" },
  { word: "LOGIC", hint: "Clear reasoning" },
  { word: "LOOSE", hint: "Not tight or free" },
  { word: "LOWER", hint: "Move down or below" },
  { word: "LOYAL", hint: "Faithful and devoted" },
  { word: "LUCKY", hint: "Having good fortune" },
  { word: "LUNCH", hint: "Midday meal" },
  { word: "MAGIC", hint: "Supernatural power" },
  { word: "MAJOR", hint: "Important or greater" },
  { word: "MANGE", hint: "Skin disease in animals" },
  { word: "MATCH", hint: "Competition or corresponding pair" },
  { word: "MAYBE", hint: "Perhaps or possibly" },
  { word: "MEANS", hint: "Method or resources" },
  { word: "MEDIA", hint: "Communication channels" },
  { word: "MERCY", hint: "Compassion or forgiveness" },
  { word: "METAL", hint: "Hard shiny material" },
  { word: "MINOR", hint: "Small or less important" },
  { word: "MIXED", hint: "Combined together" },
  { word: "MODEL", hint: "Example or fashion person" },
  { word: "MONEY", hint: "Currency for buying" },
  { word: "MONTH", hint: "Period of about 30 days" },
  { word: "MORAL", hint: "Concerning right and wrong" },
  { word: "MOTOR", hint: "Machine that produces motion" },
  { word: "MOUNT", hint: "Climb up or mountain" },
  { word: "MOUSE", hint: "Small rodent" },
  { word: "MOUTH", hint: "Opening for food" },
  { word: "MUSIC", hint: "Sounds arranged artistically" },
  { word: "NAVAL", hint: "Related to navy" },
  { word: "NEVER", hint: "Not at any time" },
  { word: "NIGHT", hint: "Time of darkness" },
  { word: "NOBLE", hint: "Having high moral character" },
  { word: "NOISE", hint: "Unwanted sound" },
  { word: "NORTH", hint: "Direction toward top of map" },
  { word: "NOVEL", hint: "Book of fiction" },
  { word: "NURSE", hint: "Medical caregiver" },
  { word: "OCEAN", hint: "Vast body of salt water" },
  { word: "OFFER", hint: "Present for acceptance" },
  { word: "OFTEN", hint: "Frequently or many times" },
  { word: "ORDER", hint: "Arrangement or command" },
  { word: "OTHER", hint: "Different or alternative" },
  { word: "OUGHT", hint: "Should or duty" },
  { word: "OUTER", hint: "External or outside" },
  { word: "OWNER", hint: "Person who possesses" },
  { word: "PAINT", hint: "Colored liquid for decorating" },
  { word: "PANEL", hint: "Flat section or group of experts" },
  { word: "PANIC", hint: "Sudden overwhelming fear" },
  { word: "PAPER", hint: "Material for writing" },
  { word: "PARTY", hint: "Social gathering" },
  { word: "PEACE", hint: "State without war or conflict" },
  { word: "PHASE", hint: "Stage or period" },
  { word: "PHONE", hint: "Device for calling" },
  { word: "PIANO", hint: "Musical keyboard instrument" },
  { word: "PIECE", hint: "Part of something" },
  { word: "PILOT", hint: "Person who flies aircraft" },
  { word: "PITCH", hint: "Throw or musical frequency" },
  { word: "PLACE", hint: "Location or position" },
  { word: "PLAIN", hint: "Simple or flat land" },
  { word: "PLANT", hint: "Living organism that grows" },
  { word: "PLATE", hint: "Flat dish for food" },
  { word: "PLUCK", hint: "Pull quickly or courage" },
  { word: "PLUMP", hint: "Pleasantly fat or rounded" },
  { word: "POINT", hint: "Sharp end or purpose" },
  { word: "POUND", hint: "Unit of weight or strike" },
  { word: "POWER", hint: "Ability or energy" },
  { word: "PRESS", hint: "Push or newspapers" },
  { word: "PRICE", hint: "Cost or amount of money" },
  { word: "PRIDE", hint: "Feeling of satisfaction" },
  { word: "PRIME", hint: "Best quality or first" },
  { word: "PRINT", hint: "Produce text on paper" },
  { word: "PRIOR", hint: "Before or earlier" },
  { word: "PRIZE", hint: "Award for winning" },
  { word: "PROOF", hint: "Evidence showing truth" },
  { word: "PROUD", hint: "Feeling pleased about achievement" },
  { word: "PROVE", hint: "Demonstrate truth" },
  { word: "QUEEN", hint: "Female monarch" },
  { word: "QUEST", hint: "Search or journey" },
  { word: "QUICK", hint: "Fast or rapid" },
  { word: "QUIET", hint: "Making little noise" },
  { word: "QUITE", hint: "Completely or rather" },
  { word: "QUOTA", hint: "Fixed amount or limit" },
  { word: "QUOTE", hint: "Repeat someone's words" },
  { word: "RADIO", hint: "Device for broadcast reception" },
  { word: "RAISE", hint: "Lift up or increase" },
  { word: "RANGE", hint: "Extent or variety" },
  { word: "RAPID", hint: "Very fast" },
  { word: "RATIO", hint: "Relationship between numbers" },
  { word: "REACH", hint: "Extend to touch something" },
  { word: "REACT", hint: "Respond to something" },
  { word: "READY", hint: "Prepared or willing" },
  { word: "REALM", hint: "Kingdom or domain" },
  { word: "RELAX", hint: "Rest and become calm" },
  { word: "REPLY", hint: "Respond or answer" },
  { word: "RIGHT", hint: "Correct or opposite of left" },
  { word: "RIVAL", hint: "Competitor or opponent" },
  { word: "RIVER", hint: "Natural flowing stream of water" },
  { word: "ROUGH", hint: "Not smooth or gentle" },
  { word: "ROUND", hint: "Circular or spherical" },
  { word: "ROUTE", hint: "Path or direction" },
  { word: "ROYAL", hint: "Related to kings and queens" },
  { word: "RURAL", hint: "Relating to countryside" },
  { word: "SCALE", hint: "Device for weighing" },
  { word: "SCARE", hint: "Frighten or alarm" },
  { word: "SCENE", hint: "View or part of play" },
  { word: "SCOPE", hint: "Extent or range" },
  { word: "SCORE", hint: "Points in game or twenty" },
  { word: "SCOUT", hint: "Person searching for something" },
  { word: "SENSE", hint: "Feeling or meaning" },
  { word: "SERVE", hint: "Provide or work for" },
  { word: "SEVEN", hint: "Number after six" },
  { word: "SHADE", hint: "Area protected from sunlight" },
  { word: "SHAFT", hint: "Long narrow part" },
  { word: "SHAKE", hint: "Move rapidly back and forth" },
  { word: "SHALL", hint: "Will or must" },
  { word: "SHAPE", hint: "External form" },
  { word: "SHARE", hint: "Give portion to others" },
  { word: "SHARP", hint: "Having fine cutting edge" },
  { word: "SHEAR", hint: "Cut with scissors or shears" },
  { word: "SHEEP", hint: "Woolly farm animal" },
  { word: "SHEET", hint: "Large piece of fabric" },
  { word: "SHELF", hint: "Flat surface for storage" },
  { word: "SHELL", hint: "Hard protective covering" },
  { word: "SHIFT", hint: "Move or change position" },
  { word: "SHINE", hint: "Give out light" },
  { word: "SHIRT", hint: "Upper body garment" },
  { word: "SHOCK", hint: "Sudden surprising event" },
  { word: "SHOOT", hint: "Fire weapon or grow rapidly" },
  { word: "SHORT", hint: "Small in length" },
  { word: "SHOUT", hint: "Yell or cry loudly" },
  { word: "SHOWN", hint: "Displayed or demonstrated" },
  { word: "SIGHT", hint: "Ability to see" },
  { word: "SINCE", hint: "From then until now" },
  { word: "SIXTH", hint: "Number six in order" },
  { word: "SKILL", hint: "Ability to do something well" },
  { word: "SLASH", hint: "Cut with violent stroke" },
  { word: "SLEEP", hint: "Rest with closed eyes" },
  { word: "SLIDE", hint: "Move smoothly along surface" },
  { word: "SLICE", hint: "Thin piece cut from something" },
  { word: "SLOPE", hint: "Inclined surface" },
  { word: "SMALL", hint: "Little in size" },
  { word: "SMART", hint: "Intelligent or clever" },
  { word: "SMELL", hint: "Detect odor with nose" },
  { word: "SMILE", hint: "Happy facial expression" },
  { word: "SMOKE", hint: "Visible vapor from fire" },
  { word: "SMOOTH", hint: "Even surface without bumps" },
  { word: "SNEAK", hint: "Move quietly and secretly" },
  { word: "SOLID", hint: "Firm and stable" },
  { word: "SOUND", hint: "Noise or vibration" },
  { word: "SOUTH", hint: "Direction toward bottom of map" },
  { word: "SPACE", hint: "Empty area or cosmos" },
  { word: "SPARE", hint: "Extra or save from harm" },
  { word: "SPEAK", hint: "Talk or express in words" },
  { word: "SPEED", hint: "Rate of motion" },
  { word: "SPEND", hint: "Pay money" },
  { word: "SPICE", hint: "Aromatic plant flavoring" },
  { word: "SPITE", hint: "Desire to hurt" },
  { word: "SPLIT", hint: "Divide into parts" },
  { word: "SPOON", hint: "Utensil for eating" },
  { word: "SPORT", hint: "Physical game or activity" },
  { word: "STAFF", hint: "Employees or walking stick" },
  { word: "STAGE", hint: "Platform for performance" },
  { word: "STAIR", hint: "Step in staircase" },
  { word: "STAKE", hint: "Pointed stick or wager" },
  { word: "STALE", hint: "No longer fresh" },
  { word: "STAND", hint: "Be upright on feet" },
  { word: "START", hint: "Begin or commence" },
  { word: "STATE", hint: "Condition or region" },
  { word: "STEAK", hint: "Thick slice of beef" },
  { word: "STEAM", hint: "Water vapor from boiling" },
  { word: "STEEL", hint: "Strong metal alloy" },
  { word: "STEEP", hint: "Sharp incline" },
  { word: "STICK", hint: "Thin piece of wood" },
  { word: "STILL", hint: "Not moving or yet" },
  { word: "STOCK", hint: "Supply or shares" },
  { word: "STONE", hint: "Hard piece of rock" },
  { word: "STOOD", hint: "Past tense of stand" },
  { word: "STORE", hint: "Shop or keep for later" },
  { word: "STORM", hint: "Violent weather" },
  { word: "STORY", hint: "Tale or narrative" },
  { word: "STRAP", hint: "Strip for fastening" },
  { word: "STRIP", hint: "Long narrow piece" },
  { word: "STUCK", hint: "Unable to move" },
  { word: "STUDY", hint: "Learn by reading" },
  { word: "STYLE", hint: "Manner or fashion" },
  { word: "SUGAR", hint: "Sweet substance" },
  { word: "SUPER", hint: "Excellent or above" },
  { word: "SWEET", hint: "Pleasant sugary taste" },
  { word: "SWEPT", hint: "Cleaned with broom" },
  { word: "SWIFT", hint: "Fast moving" },
  { word: "SWING", hint: "Move back and forth" },
  { word: "SWORD", hint: "Long bladed weapon" },
  { word: "TABLE", hint: "Furniture with flat top" },
  { word: "TALES", hint: "Stories or narratives" },
  { word: "TASTE", hint: "Flavor or try food" },
  { word: "TEACH", hint: "Instruct or educate" },
  { word: "TENSE", hint: "Anxious or verb form" },
  { word: "TENTH", hint: "Number ten in order" },
  { word: "TERMS", hint: "Conditions or words" },
  { word: "THANK", hint: "Express gratitude" },
  { word: "THEFT", hint: "Act of stealing" },
  { word: "THEIR", hint: "Belonging to them" },
  { word: "THEME", hint: "Main subject or topic" },
  { word: "THERE", hint: "At that place" },
  { word: "THESE", hint: "Plural of this" },
  { word: "THICK", hint: "Having great width" },
  { word: "THING", hint: "Object or item" },
  { word: "THINK", hint: "Use mind to reason" },
  { word: "THIRD", hint: "Number three in order" },
  { word: "THORN", hint: "Sharp point on plant" },
  { word: "THOSE", hint: "Plural of that" },
  { word: "THREE", hint: "Number after two" },
  { word: "THREW", hint: "Past tense of throw" },
  { word: "THROW", hint: "Propel through air" },
  { word: "THUMB", hint: "Short thick finger" },
  { word: "TIGHT", hint: "Firmly fixed" },
  { word: "TIMER", hint: "Device measuring time" },
  { word: "TITLE", hint: "Name of book or position" },
  { word: "TODAY", hint: "This current day" },
  { word: "TOPIC", hint: "Subject of discussion" },
  { word: "TOTAL", hint: "Complete amount" },
  { word: "TOUCH", hint: "Make contact with" },
  { word: "TOUGH", hint: "Strong or difficult" },
  { word: "TOWER", hint: "Tall narrow building" },
  { word: "TRACK", hint: "Path or follow trail" },
  { word: "TRADE", hint: "Exchange of goods or services" },
  { word: "TRAIL", hint: "Path through wilderness" },
  { word: "TRAIN", hint: "Railway vehicle" },
  { word: "TRASH", hint: "Waste or garbage" },
  { word: "TREAT", hint: "Something special to enjoy" },
  { word: "TREND", hint: "General direction or style" },
  { word: "TRIAL", hint: "Test or court case" },
  { word: "TRIBE", hint: "Social group" },
  { word: "TRICK", hint: "Clever act to deceive" },
  { word: "TROUT", hint: "Freshwater fish" },
  { word: "TRUCK", hint: "Large vehicle for cargo" },
  { word: "TRUNK", hint: "Elephant nose or tree body" },
  { word: "TRUST", hint: "Believe in reliability" },
  { word: "TRUTH", hint: "What is factually correct" },
  { word: "TWICE", hint: "Two times or double" },
  { word: "UNDER", hint: "Below or beneath" },
  { word: "UNION", hint: "Joining together" },
  { word: "UNITY", hint: "Being united as one" },
  { word: "UNTIL", hint: "Up to the point that" },
  { word: "UPPER", hint: "Higher in position" },
  { word: "URBAN", hint: "Related to cities" },
  { word: "USAGE", hint: "Way of using something" },
  { word: "USUAL", hint: "Normal or typical" },
  { word: "VALID", hint: "Legally acceptable" },
  { word: "VALUE", hint: "Worth or importance" },
  { word: "VIDEO", hint: "Recording of moving images" },
  { word: "VISIT", hint: "Go to see" },
  { word: "VITAL", hint: "Essential or necessary" },
  { word: "VOCAL", hint: "Related to voice" },
  { word: "VOICE", hint: "Sound from speaking" },
  { word: "WASTE", hint: "Use carelessly" },
  { word: "WATCH", hint: "Observe or timepiece" },
  { word: "WATER", hint: "Clear liquid for drinking" },
  { word: "WHEAT", hint: "Grain for making flour" },
  { word: "WHEEL", hint: "Circular object that rotates" },
  { word: "WHERE", hint: "At what place or location" },
  { word: "WHILE", hint: "During the time that" },
  { word: "WHALE", hint: "Largest marine mammal" },
  { word: "WHITE", hint: "Color of snow" },
  { word: "WHOLE", hint: "Complete or entire" },
  { word: "WHOSE", hint: "Belonging to whom" },
  { word: "WITCH", hint: "Person with magical powers" },
  { word: "WOMAN", hint: "Adult female human" },
  { word: "WORLD", hint: "Earth and all people" },
  { word: "WORRY", hint: "Feel anxious" },
  { word: "WORSE", hint: "More bad" },
  { word: "WORST", hint: "Most bad" },
  { word: "WORTH", hint: "Value or merit" },
  { word: "WOULD", hint: "Past of will" },
  { word: "WOUND", hint: "Injury or past of wind" },
  { word: "WRIST", hint: "Joint between hand and arm" },
  { word: "WRITE", hint: "Mark letters on surface" },
  { word: "WRONG", hint: "Incorrect or immoral" },
  { word: "WROTE", hint: "Past tense of write" },
  { word: "YIELD", hint: "Produce or give way" },
  { word: "YOUNG", hint: "Not old" },
  { word: "YOUTH", hint: "Period of being young" }
];

// Build lookup index by character positions
function buildIndex() {
  const index = {
    pos1: {}, // char at index 1
    pos3: {}  // char at index 3
  };

  wordDatabase.forEach(entry => {
    const word = entry.word;
    if (word.length !== 5) return;

    const char1 = word[1];
    const char3 = word[3];

    if (!index.pos1[char1]) index.pos1[char1] = [];
    if (!index.pos3[char3]) index.pos3[char3] = [];

    index.pos1[char1].push(entry);
    index.pos3[char3].push(entry);
  });

  return index;
}

// Generate valid puzzle
function generatePuzzle(id) {
  const index = buildIndex();
  const maxAttempts = 10000;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    // Pick random top word
    const topEntry = wordDatabase[Math.floor(Math.random() * wordDatabase.length)];
    const top = topEntry.word;

    // Get characters at positions 1 and 3 of top word
    const topChar1 = top[1]; // Must match left[1]
    const topChar3 = top[3]; // Must match right[1]

    // Find potential left words (must have topChar1 at position 1)
    const leftCandidates = index.pos1[topChar1] || [];
    if (leftCandidates.length === 0) continue;

    const leftEntry = leftCandidates[Math.floor(Math.random() * leftCandidates.length)];
    const left = leftEntry.word;
    const leftChar3 = left[3]; // Must match bottom[1]

    // Find potential right words (must have topChar3 at position 1)
    const rightCandidates = index.pos1[topChar3] || [];
    if (rightCandidates.length === 0) continue;

    const rightEntry = rightCandidates[Math.floor(Math.random() * rightCandidates.length)];
    const right = rightEntry.word;
    const rightChar3 = right[3]; // Must match bottom[3]

    // Find potential bottom words
    // Must have leftChar3 at position 1 AND rightChar3 at position 3
    const bottomCandidates = (index.pos1[leftChar3] || []).filter(entry =>
      entry.word[3] === rightChar3
    );

    if (bottomCandidates.length === 0) continue;

    const bottomEntry = bottomCandidates[Math.floor(Math.random() * bottomCandidates.length)];
    const bottom = bottomEntry.word;

    // Verify all constraints
    if (
      top[1] === left[1] &&
      top[3] === right[1] &&
      bottom[1] === left[3] &&
      bottom[3] === right[3]
    ) {
      return {
        id: id,
        top: { answer: top, hint: topEntry.hint },
        bottom: { answer: bottom, hint: bottomEntry.hint },
        left: { answer: left, hint: leftEntry.hint },
        right: { answer: right, hint: rightEntry.hint }
      };
    }
  }

  return null;
}

// Generate multiple puzzles
function generatePuzzles(count, levelPrefix) {
  const puzzles = [];
  const usedCombinations = new Set();
  let puzzleNum = 11; // Start from 11 since originals are 1-10

  while (puzzles.length < count) {
    const puzzle = generatePuzzle(`${levelPrefix}-${puzzleNum}`);

    if (puzzle) {
      // Check for duplicate combinations
      const key = [puzzle.top.answer, puzzle.bottom.answer, puzzle.left.answer, puzzle.right.answer].sort().join('|');

      if (!usedCombinations.has(key)) {
        usedCombinations.add(key);
        puzzles.push(puzzle);
        puzzleNum++;
        console.log(`Generated puzzle ${puzzles.length}/${count}: ${puzzle.id}`);
      }
    }
  }

  return puzzles;
}

// Format puzzle for HTML
function formatPuzzle(puzzle) {
  return `    {
      id: "${puzzle.id}",
      top:    { answer: "${puzzle.top.answer}", hint: "${puzzle.top.hint}" },
      bottom: { answer: "${puzzle.bottom.answer}", hint: "${puzzle.bottom.hint}" },
      left:   { answer: "${puzzle.left.answer}", hint: "${puzzle.left.hint}" },
      right:  { answer: "${puzzle.right.answer}", hint: "${puzzle.right.hint}" }
    }`;
}

// Main execution
console.log("=== Hashtag Words Puzzle Generator ===\n");
console.log("Generating Level 1 puzzles (30)...");
const level1Puzzles = generatePuzzles(30, "L1");

console.log("\nGenerating Level 2 puzzles (30)...");
const level2Puzzles = generatePuzzles(30, "L2");

console.log("\nGenerating Level 3 puzzles (30)...");
const level3Puzzles = generatePuzzles(30, "L3");

// Output formatted puzzles
console.log("\n=== LEVEL 1 PUZZLES ===");
console.log(level1Puzzles.map(formatPuzzle).join(',\n'));

console.log("\n\n=== LEVEL 2 PUZZLES ===");
console.log(level2Puzzles.map(formatPuzzle).join(',\n'));

console.log("\n\n=== LEVEL 3 PUZZLES ===");
console.log(level3Puzzles.map(formatPuzzle).join(',\n'));

console.log("\n\n=== SUMMARY ===");
console.log(`Total puzzles generated: ${level1Puzzles.length + level2Puzzles.length + level3Puzzles.length}`);
console.log(`Level 1: ${level1Puzzles.length} puzzles`);
console.log(`Level 2: ${level2Puzzles.length} puzzles`);
console.log(`Level 3: ${level3Puzzles.length} puzzles`);
