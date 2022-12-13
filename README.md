# KoLMafia volcanoPrep.ash

This is a script to automate the prep before volcano mining:

* Messaging a buffbot for relevant buffs (`Ode to Booze, Elemental Saucesphere, Astral Shell`), if wanted
* Uses the the Mime Army Shotglass if available
* Uses the relevant class chocoaltes if available
* Uses milk of magnesium if available
* Eating/drinking until full to maximize adventures
* Uses spleen items for maximizing adv
* Pre-purchases items needed for the bunker quest, up to the supplied prices
  * And crafts SMOOCH bracers
* Puts on the Smooth Velvet outfit and gets the top floor Volcoino
* Visits the bunker and turns in the appropriate item if you can, in order of least expensive to most (if there are multiple available options) to get a Volcoino

The following are the configuration options of the scripts; to change, simply change the values int the top of the script.

```java
string smoothOutfit = "Smooth Velvet"; // What the name of your already existing Smooth Velvet full outfit is
item booze = $item[hacked gibson];
item food = $item[spooky hi mein];
// Has to be perfectly divisable into leftover liver space, like elemental caipiroska
item boozeExtra = $item[perfect old-fashioned]; // 3 fullness
item spleenItem = $item[groose grease]; // 4 fullness
// Single fullness item for mime army shotglass
item mimeShotglassBooze = $item[elemental caipiroska];

// Always keep a stock of the quest items that can be bought in mall, up to a certain max price
// Not including superduperheated metal, which is too expensive
// Change the second value in each item list to change max price
int [item, int] questItems = {
$item[New Age healing crystal]: {5: 200},
$item[SMOOCH bottlecap] : {1: 6000},
$item[gooey lava globs]: {5: 5000},
$item[smooth velvet bra]: {3: 15000},
$item[superheated metal]: {15: 8200}
};
```

