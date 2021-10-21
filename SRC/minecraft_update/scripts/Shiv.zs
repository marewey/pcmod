print("Script starting!");
import crafttweaker.api.BlastFurnaceManager;
import crafttweaker.api.FurnaceManager;

//=== SMELTING TOOLS to RESOURCES
//REMOVE some stuff
blastFurnace.removeRecipe(<item:minecraft:gold_nugget>);
blastFurnace.removeRecipe(<item:minecraft:iron_nugget>);
furnace.removeRecipe(<item:minecraft:iron_nugget>);
//ADD some stuff
blastFurnace.addRecipe("dhelmet2d",<item:minecraft:diamond> * 2, <item:minecraft:diamond_helmet>, 0.7, 210);
blastFurnace.addRecipe("dchest2d",<item:minecraft:diamond> * 4, <item:minecraft:diamond_chestplate>, 0.7, 410);
blastFurnace.addRecipe("dleg2d",<item:minecraft:diamond> * 3, <item:minecraft:diamond_leggings>, 0.7, 310);
blastFurnace.addRecipe("dboot2d",<item:minecraft:diamond> * 1, <item:minecraft:diamond_boots>, 0.7, 110);
blastFurnace.addRecipe("ihelmet2i",<item:minecraft:iron_ingot> * 2, <item:minecraft:iron_helmet>, 0.7, 220);
blastFurnace.addRecipe("ichest2i",<item:minecraft:iron_ingot> * 4, <item:minecraft:iron_chestplate>, 0.7, 420);
blastFurnace.addRecipe("ileg2i",<item:minecraft:iron_ingot> * 3, <item:minecraft:iron_leggings>, 0.7, 120);
blastFurnace.addRecipe("iboot2i",<item:minecraft:iron_ingot> * 1, <item:minecraft:iron_boots>, 0.7, 120);
blastFurnace.addRecipe("ghelmet2g",<item:minecraft:gold_ingot> * 2, <item:minecraft:golden_helmet>, 0.7, 200);
blastFurnace.addRecipe("gchest2g",<item:minecraft:gold_ingot> * 4, <item:minecraft:golden_chestplate>, 0.7, 400);
blastFurnace.addRecipe("gleg2g",<item:minecraft:gold_ingot> * 3, <item:minecraft:golden_leggings>, 0.7, 300);
blastFurnace.addRecipe("gboot2g",<item:minecraft:gold_ingot> * 1, <item:minecraft:golden_boots>, 0.7, 100);
blastFurnace.addRecipe("dsword2d",<item:minecraft:diamond> * 1, <item:minecraft:diamond_sword>, 0.7, 100);
blastFurnace.addRecipe("dpick2d",<item:minecraft:diamond> * 1, <item:minecraft:diamond_pickaxe>, 0.7, 100);
blastFurnace.addRecipe("daxe2d",<item:minecraft:diamond> * 1, <item:minecraft:diamond_axe>, 0.7, 100);
blastFurnace.addRecipe("dhoe2d",<item:minecraft:diamond> * 1, <item:minecraft:diamond_hoe>, 0.7, 100);
blastFurnace.addRecipe("isword2i",<item:minecraft:iron_ingot> * 1, <item:minecraft:iron_sword>, 0.7, 100);
blastFurnace.addRecipe("ipick2i",<item:minecraft:iron_ingot> * 1, <item:minecraft:iron_pickaxe>, 0.7, 100);
blastFurnace.addRecipe("iaxe2i",<item:minecraft:iron_ingot> * 1, <item:minecraft:iron_axe>, 0.7, 100);
blastFurnace.addRecipe("ihoe2i",<item:minecraft:iron_ingot> * 1, <item:minecraft:iron_hoe>, 0.7, 100);
blastFurnace.addRecipe("ishov2i",<item:minecraft:iron_nugget> * 4, <item:minecraft:iron_shovel>, 0.7, 65);
blastFurnace.addRecipe("gsword2g",<item:minecraft:gold_ingot> * 1, <item:minecraft:golden_sword>, 0.7, 100);
blastFurnace.addRecipe("gpick2g",<item:minecraft:gold_ingot> * 1, <item:minecraft:golden_pickaxe>, 0.7, 100);
blastFurnace.addRecipe("gaxe2g",<item:minecraft:gold_ingot> * 1, <item:minecraft:golden_axe>, 0.7, 100);
blastFurnace.addRecipe("ghoe2g",<item:minecraft:gold_ingot> * 1, <item:minecraft:golden_hoe>, 0.7, 100);
blastFurnace.addRecipe("gshov2g",<item:minecraft:gold_nugget> * 4, <item:minecraft:golden_shovel>, 0.7, 55);
blastFurnace.addRecipe("dha2d",<item:minecraft:diamond> * 8, <item:minecraft:diamond_horse_armor>, 0.7, 800);
blastFurnace.addRecipe("iha2i",<item:minecraft:iron_ingot> * 8, <item:minecraft:iron_horse_armor>, 0.7, 800);
blastFurnace.addRecipe("gha2g",<item:minecraft:gold_ingot> * 8, <item:minecraft:golden_horse_armor>, 0.7, 800);
furnace.addRecipe("chelmet2c",<item:minecraft:iron_nugget> * 11, <item:minecraft:chainmail_helmet>, 0.5, 130);
furnace.addRecipe("cchest2c",<item:minecraft:iron_nugget> * 18, <item:minecraft:chainmail_chestplate>, 0.5, 200);
furnace.addRecipe("cleg2c",<item:minecraft:iron_nugget> * 15, <item:minecraft:chainmail_leggings>, 0.5, 160);
furnace.addRecipe("cboot2c",<item:minecraft:iron_nugget> * 9, <item:minecraft:chainmail_boots>, 0.5, 100);

//GOLD APPLE CHANGE
craftingTable.addShaped("lolarecipe32",<item:minecraft:enchanted_golden_apple>,
 [[<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>],
  [<item:minecraft:gold_block>,<item:minecraft:apple>,<item:minecraft:gold_block>],
  [<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>]]);

//WOOL to STRING
craftingTable.addShapeless("lolarecipe81",<item:minecraft:string>*4,[<tag:items:minecraft:wool>]);
craftingTable.addShapeless("lolarecipe56",<item:minecraft:chest>,[<item:quark:oak_chest>]);

//TCon Creative Modifier
//craftingTable.addShapeless("creativemodifier0",<tconstruct:materials:50>,[<tconstruct:materials:14>,<tconstruct:materials:14>,<item:minecraft:nether_star>,<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>,<item:minecraft:gold_block>]);

//BIRCH to PAPER
craftingTable.addShapeless("lolarecipe21test",<item:minecraft:paper>*4,[<item:minecraft:birch_log>,<item:minecraft:birch_log>]);

//STRING to WEB
craftingTable.addShaped("lolarecipe17",<item:minecraft:cobweb>,
 [[<tag:items:forge:string>,<tag:items:forge:string>,<tag:items:forge:string>],
  [<tag:items:forge:string>,<tag:items:forge:string>,<tag:items:forge:string>],
  [<tag:items:forge:string>,<tag:items:forge:string>,<tag:items:forge:string>]]);

print("Script ending!");