/*
Script for auto-doing the menial parts of volcano mining. Assumes:
- Enough One day tickets, potion of detection, spooky hi mein,
  Hacked gibson, perfect old-fashioned
- No food or booze or spleen consumed
- Optional: milk of magnesium, chocolate stolen accordion, groose grease
*/

//**** Change customizable here ****//

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

//**** END CUSTOMIZABLE ****//

item [Class] chocolatesPerClass = {
    $class[disco bandit]: $item[chocolate disco ball],
    $class[pastamancer]: $item[chocolate pasta spoon],
    $class[seal clubber]: $item[chocolate seal-clubbing club],
    $class[accordion thief]: $item[chocolate stolen accordion],
    $class[turtle tamer]: $item[chocolate turtle totem],
    $class[sauceror]: $item[chocolate saucepan]
};

//**** Getting adventures ****//

refresh_status();
int advStart = my_adventures();
int amtDrink = max(0, floor((inebriety_limit() - my_inebriety()) / booze.inebriety));
int amtEat = max(0, floor((fullness_limit() - my_fullness()) / food.fullness));
int amtDrinkExtra = max(0, floor((inebriety_limit() - my_inebriety() - (amtDrink * booze.inebriety)) / boozeExtra.inebriety));
int amtSpleen = max(0, floor((spleen_limit() - my_spleen_use()) / spleenItem.spleen));

// Checks
if (item_amount(food) < amtEat) abort(`Not enough {food.plural}`);
if (item_amount(booze) < amtDrink) abort(`Not enough {booze.plural}`);
if (item_amount(boozeExtra) < amtDrinkExtra) abort(`Not enough {boozeExtra.plural}`);

if (user_confirm("Message buff bot for buffs?", 4000, true)) {
    chat_private("Flesh_Puppet", "Ode to Booze 400");
    chat_private("Flesh_Puppet", "Elemental Saucesphere 400");
    chat_private("Flesh_Puppet", "Astral Shell 400");
}

// Get the adventures, most optimal I know so far

if (item_amount($item[mime army shotglass]) > 0 && !to_boolean(get_property("_mimeArmyShotglassUsed"))) {
    if (mimeShotglassBooze.inebriety > 1) print(`Incorrect inebriety of {mimeShotglassBooze}, needs to be 1`, "red");
    else drink(1, mimeShotglassBooze);
}
if (get_property("_chocolatesUsed") <= 0) {
    item chocolate = chocolatesPerClass[my_class()];
    if (item_amount(chocolate) < 2 || !use(2, chocolate)) print(`Could not use {chocolate.plural}`, "green");
}
if (item_amount($item[milk of magnesium]) > 0) use(1, $item[milk of magnesium]);

eat(amtEat, food);
drink(amtDrink, booze);
drink(amtDrinkExtra, boozeExtra);
if (item_amount(spleenItem) >= amtSpleen) chew(amtSpleen, spleenItem);
else print(`Not enough {spleenItem.plural}, did not use`, "green");

int advAfter = my_adventures();

print(`Gained {(advAfter - advStart)} adventures, now have {advAfter}`, "green");

if (item_amount($item[potion of detection]) < 40) abort(`**WARNING**: NOT ENOUGH {$item[potion of detection].plural}, GO BUY SOME`);

if (!user_confirm("Do volcano part of script?", 4000, true)) abort("Stopped after gaining adventures");

//**** Get volcoinos ****//

// Pre-purchase items needed for bunker quest
foreach qItem, num in questItems {
    if (item_amount(qItem) < num) {
        if (buy(num, qItem, questItems[qItem][num]) != num) {
            print(`**WARNING**: Didn't buy enough of {qItem} at max price {questItems[qItem][num]}, have {item_amount(qItem)}`, "red");
        }
    }
}
// SMOOCH bracers need to be crafted, not bought
if (item_amount($item[SMOOCH bracers]) < 3) {
    if (!create(3, $item[SMOOCH bracers])) print(`**WARNING**: couldn't make enough of SMOOCH bracers, have {item_amount($item[SMOOCH bracers])}`, "red");
}

// Put on the smooth velvet outfit
cli_execute("checkpoint");
if (!have_outfit(smoothOutfit) || !outfit(smoothOutfit)) abort(`Can't wear the smooth velvet outfit pieces {smoothOutfit}`);

// Visit volcano and The Towering Inferno Discotheque
buffer page = visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
if (page.contains_text("know where that is")) { // No access to volcano
    item ticket = $item[one-day ticket to That 70s Volcano];

    // Use a ticket to gain access to the Volcano
    if (item_amount(ticket) < 1) abort("Need to buy more volcano tickets");
    if (!user_confirm("Use a volcano ticket?", 4000, false)) abort("Not using ticket and can't access Volcano");
    use(1, ticket);

    page = visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
    if (page.contains_text("know where that is")) abort("Couldn't use ticket or still can't access for some reason");
}

// Get volcoino from the tower
if (!(available_choice_options() contains 7))
    print("Can't find 6th floor of tower!", "red");
else {
    print(`Doing choice 7: {available_choice_options()[7]}`, "green");
    run_choice(7);
}
cli_execute("outfit checkpoint");


// Get volcoino from the bunker
questItems[$item[SMOOCH bracers]] = {3: 0}; // Add SMOOCH bracers to list now that it isn't being used for purchasing
if (!to_boolean(get_property("_volcanoItemRedeemed"))) {
    visit_url("place.php?whichplace=airport_hot&action=airport4_questhub");
    boolean couldRetrieve = false;

    foreach qItem in questItems {
        if (couldRetrieve) break;
        for ind from 1 to 3 {
            if (to_item(get_property( "_volcanoItem" + ind)) == qItem) {
                print(`Doing choice {ind} to turn in {qItem}`, "green");
                if (item_amount(qItem) < to_int(get_property( "_volcanoItemCount" + ind)))
                    print(`**WARNING**: Couldn't turn in {qItem}, don't own enough! Increase mall max price to auto-purchase and rerun script`, "red");
                else {
                    run_choice(ind);
                    couldRetrieve = true;
                }
                break;
            }
        }
    }
    if (!couldRetrieve) print("No purchased items to turn in today", "green");
}


print("-------- FINISHED volcano prep! --------", "green");
refresh_status();
