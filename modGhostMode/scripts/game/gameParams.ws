/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


struct SDurabilityThreshold
{
	var thresholdMax : float;	
	var multiplier : float;		
	var difficulty : EDifficultyMode;
};


import class W3GameParams extends CObject
{
	private var dm : CDefinitionsManagerAccessor;					
	private var main : SCustomNode;									
	
	
	public const var BASE_ABILITY_TAG : name;																					
	public const var PASSIVE_BONUS_ABILITY_TAG : name;																			
		default BASE_ABILITY_TAG = 'base';
		default PASSIVE_BONUS_ABILITY_TAG = 'passive';
	private var forbiddenAttributes : array<name>;				
																
																
	public var GLOBAL_ENEMY_ABILITY : name;						
		default GLOBAL_ENEMY_ABILITY = 'all_NPC_ability';
	
	public var ENEMY_BONUS_PER_LEVEL : name;					
		default ENEMY_BONUS_PER_LEVEL = 'NPCLevelBonus';
		
	public var ENEMY_BONUS_FISTFIGHT_LOW : name;					
		default ENEMY_BONUS_FISTFIGHT_LOW = 'NPCLevelModFistFightLower';
	
	public var ENEMY_BONUS_FISTFIGHT_HIGH : name;					
		default ENEMY_BONUS_FISTFIGHT_HIGH = 'NPCLevelModFistFightHigher';
		
	public var ENEMY_BONUS_LOW : name;					
		default ENEMY_BONUS_LOW = 'NPCLevelBonusLow';
		
	public var ENEMY_BONUS_HIGH : name;					
		default ENEMY_BONUS_HIGH = 'NPCLevelBonusHigh';
		
	public var ENEMY_BONUS_DEADLY : name;					
		default ENEMY_BONUS_DEADLY = 'NPCLevelBonusDeadly';
		
	public var MONSTER_BONUS_PER_LEVEL : name;					
		default MONSTER_BONUS_PER_LEVEL = 'MonsterLevelBonus';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP = 'MonsterLevelBonusGroup';
		
	public var MONSTER_BONUS_PER_LEVEL_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_ARMORED = 'MonsterLevelBonusArmored';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED = 'MonsterLevelBonusGroupArmored';
		
	public var MONSTER_BONUS_LOW : name;						
		default MONSTER_BONUS_LOW = 'MonsterLevelBonusLow';
		
	public var MONSTER_BONUS_HIGH : name;						
		default MONSTER_BONUS_HIGH = 'MonsterLevelBonusHigh';
		
	public var MONSTER_BONUS_DEADLY : name;						
		default MONSTER_BONUS_DEADLY = 'MonsterLevelBonusDeadly';
	
	public var BOSS_NGP_BONUS : name;
		default BOSS_NGP_BONUS = 'BossNGPLevelBonus';
		
	public var GLOBAL_PLAYER_ABILITY : name;					
		default GLOBAL_PLAYER_ABILITY = 'all_PC_ability';
	
	public const var NOT_A_SKILL_ABILITY_TAG : name;			
		default NOT_A_SKILL_ABILITY_TAG = 'NotASkill';
	
	
	public const var ALCHEMY_COOKED_ITEM_TYPE_POTION, ALCHEMY_COOKED_ITEM_TYPE_BOMB, ALCHEMY_COOKED_ITEM_TYPE_OIL : string;		
	public const var OIL_ABILITY_TAG : name;																					
	public const var QUANTITY_INCREASED_BY_ALCHEMY_TABLE : int;
		default ALCHEMY_COOKED_ITEM_TYPE_POTION = "Potion";
		default ALCHEMY_COOKED_ITEM_TYPE_BOMB = "Bomb";
		default ALCHEMY_COOKED_ITEM_TYPE_OIL = "Oil";	 
		default	OIL_ABILITY_TAG = 'OilBonus';
		default QUANTITY_INCREASED_BY_ALCHEMY_TABLE = 1;
	
	
	public const var ATTACK_NAME_LIGHT, ATTACK_NAME_HEAVY, ATTACK_NAME_SUPERHEAVY, ATTACK_NAME_SPEED_BASED, ATTACK_NO_DAMAGE : name;		
		default ATTACK_NAME_LIGHT = 'attack_light';
		default ATTACK_NAME_HEAVY = 'attack_heavy';
		default ATTACK_NAME_SUPERHEAVY = 'attack_super_heavy';
		default ATTACK_NAME_SPEED_BASED = 'attack_speed_based';		
		default ATTACK_NO_DAMAGE = 'attack_no_damage';		
	
	
	public const var MAX_DYNAMICALLY_SPAWNED_BOATS : int;		
		default MAX_DYNAMICALLY_SPAWNED_BOATS = 5;
	
	
	public const var MAX_THROW_RANGE : float;					
	public const var UNDERWATER_THROW_RANGE : float;					
	public const var PROXIMITY_PETARD_IDLE_DETONATION_TIME : float;		
	public const var BOMB_THROW_DELAY : float;							
		default MAX_THROW_RANGE = 25.0;
		default UNDERWATER_THROW_RANGE = 5.0;
		default PROXIMITY_PETARD_IDLE_DETONATION_TIME = 10.0;
		default BOMB_THROW_DELAY = 2.f;
		
	
	public const var CONTAINER_DYNAMIC_DESTROY_TIMEOUT : int;	
		default CONTAINER_DYNAMIC_DESTROY_TIMEOUT = 900;
		
	
	public const var CRITICAL_HIT_CHANCE : name;					
	public const var CRITICAL_HIT_DAMAGE_BONUS : name;				
	public const var CRITICAL_HIT_REDUCTION : name;					
	public const var CRITICAL_HIT_FX : name;						
	public const var HEAD_SHOT_CRIT_CHANCE_BONUS : float;			
	public const var HEAD_SHOT_DAMAGE_BONUS : float; //modSigns		
	public const var BACK_ATTACK_CRIT_CHANCE_BONUS : float;			
	public const var BACK_ATTACK_DAMAGE_BONUS : float; //modSigns
	
		default CRITICAL_HIT_CHANCE = 'critical_hit_chance';
		default CRITICAL_HIT_FX = 'critical_hit';
		default CRITICAL_HIT_DAMAGE_BONUS = 'critical_hit_damage_bonus';
		default CRITICAL_HIT_REDUCTION = 'critical_hit_damage_reduction';
		default HEAD_SHOT_CRIT_CHANCE_BONUS = 0.5;
		default HEAD_SHOT_DAMAGE_BONUS = 0.25; //modSigns
		default BACK_ATTACK_CRIT_CHANCE_BONUS = 0.5;
		default BACK_ATTACK_DAMAGE_BONUS = 0.25; //modSigns
	
	
	public const var DAMAGE_NAME_DIRECT, DAMAGE_NAME_PHYSICAL, DAMAGE_NAME_SILVER, DAMAGE_NAME_SLASHING, DAMAGE_NAME_PIERCING, DAMAGE_NAME_BLUDGEONING, DAMAGE_NAME_RENDING, DAMAGE_NAME_ELEMENTAL, DAMAGE_NAME_FIRE, DAMAGE_NAME_FORCE, DAMAGE_NAME_FROST, DAMAGE_NAME_POISON, DAMAGE_NAME_SHOCK, DAMAGE_NAME_MORALE, DAMAGE_NAME_STAMINA : name;
		default DAMAGE_NAME_DIRECT 		= 'DirectDamage';
		default DAMAGE_NAME_PHYSICAL 	= 'PhysicalDamage';
		default DAMAGE_NAME_SILVER 		= 'SilverDamage';
		default DAMAGE_NAME_SLASHING	= 'SlashingDamage';
		default DAMAGE_NAME_PIERCING 	= 'PiercingDamage';
		default DAMAGE_NAME_BLUDGEONING = 'BludgeoningDamage';
		default DAMAGE_NAME_RENDING	 	= 'RendingDamage';
		default DAMAGE_NAME_ELEMENTAL	= 'ElementalDamage';
		default DAMAGE_NAME_FIRE 		= 'FireDamage';
		default DAMAGE_NAME_FORCE 		= 'ForceDamage';
		default DAMAGE_NAME_FROST 		= 'FrostDamage';
		default DAMAGE_NAME_POISON 		= 'PoisonDamage';
		default DAMAGE_NAME_SHOCK 		= 'ShockDamage';
		default DAMAGE_NAME_MORALE 		= 'MoraleDamage';
		default DAMAGE_NAME_STAMINA 	= 'StaminaDamage';
		
	public const var FOCUS_DRAIN_PER_HIT : float;					
	public const var UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY, UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY : name;		
	public const var MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS 	: float;		
	public const var ARMOR_VALUE_NAME : name;
	public const var LOW_HEALTH_EFFECT_SHOW : float;				
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS : float;					
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP : float;				
	public const var ARCHER_DAMAGE_BONUS_NGP : float;				

		default MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS = 70;
		default ARMOR_VALUE_NAME = 'armor';		
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS = 2;
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP = 6;
		default ARCHER_DAMAGE_BONUS_NGP = 2;
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY = 'combat_radial_blur';
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY = 'combat_radial_blur_big';
		default FOCUS_DRAIN_PER_HIT = 0.02;
		default LOW_HEALTH_EFFECT_SHOW = 0.3;
	
	public const var IGNI_SPELL_POWER_MILT : float;
		default	IGNI_SPELL_POWER_MILT = 1.0f;
		
	public const var INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN : float;					
		default INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN = 15.f;
	
	
	public var DIFFICULTY_TAG_EASY, DIFFICULTY_TAG_MEDIUM, DIFFICULTY_TAG_HARD, DIFFICULTY_TAG_HARDCORE : name;			
	public var DIFFICULTY_TAG_DIFF_ABILITY : name;																		
	public var DIFFICULTY_HP_MULTIPLIER, DIFFICULTY_DMG_MULTIPLIER : name;												
	public var DIFFICULTY_TAG_IGNORE : name;																			
	
		default DIFFICULTY_TAG_DIFF_ABILITY = 'DifficultyModeAbility';		
		default DIFFICULTY_TAG_EASY			= 'Easy';
		default DIFFICULTY_TAG_MEDIUM		= 'Medium';
		default DIFFICULTY_TAG_HARD			= 'Hard';
		default DIFFICULTY_TAG_HARDCORE 	= 'Hardcore';
		default DIFFICULTY_HP_MULTIPLIER 	= 'health_final_multiplier';
		default DIFFICULTY_DMG_MULTIPLIER 	= 'damage_final_multiplier';
		default DIFFICULTY_TAG_IGNORE		= 'IgnoreDifficultyAbilities';
		
	
	public const var DISMEMBERMENT_ON_DEATH_CHANCE : int;				
		default DISMEMBERMENT_ON_DEATH_CHANCE = 30;
		
	
	public const var FINISHER_ON_DEATH_CHANCE : int;					
		default FINISHER_ON_DEATH_CHANCE = 30;		
	
	
	public const var DURABILITY_ARMOR_LOSE_CHANCE, DURABILITY_WEAPON_LOSE_CHANCE : int;			
	public const var DURABILITY_ARMOR_LOSE_VALUE : float;										
	private const var DURABILITY_WEAPON_LOSE_VALUE, DURABILITY_WEAPON_LOSE_VALUE_HARDCORE : float;
	public const var DURABILITY_ARMOR_CHEST_WEIGHT, DURABILITY_ARMOR_PANTS_WEIGHT, DURABILITY_ARMOR_BOOTS_WEIGHT, DURABILITY_ARMOR_GLOVES_WEIGHT, DURABILITY_ARMOR_MISS_WEIGHT : int; 
	protected var durabilityThresholdsWeapon, durabilityThresholdsArmor : array<SDurabilityThreshold>;					
	public const var TAG_REPAIR_CONSUMABLE_ARMOR, TAG_REPAIR_CONSUMABLE_STEEL, TAG_REPAIR_CONSUMABLE_SILVER : name;		
	public const var ITEM_DAMAGED_DURABILITY : int;												
	public var INTERACTIVE_REPAIR_OBJECT_MAX_DURS : array<int>;									
		
		default TAG_REPAIR_CONSUMABLE_ARMOR = 'RepairArmor';
		default TAG_REPAIR_CONSUMABLE_STEEL = 'RepairSteel';
		default TAG_REPAIR_CONSUMABLE_SILVER = 'RepairSilver';
		
		default ITEM_DAMAGED_DURABILITY = 75;					//modSigns
	
		default DURABILITY_ARMOR_LOSE_CHANCE = 100;
		default DURABILITY_WEAPON_LOSE_CHANCE = 100;
		default DURABILITY_ARMOR_LOSE_VALUE = 0.5;				//modSigns
		default DURABILITY_WEAPON_LOSE_VALUE = 0.05;			//modSigns
		default DURABILITY_WEAPON_LOSE_VALUE_HARDCORE = 0.05;	//modSigns
		
		
		default DURABILITY_ARMOR_MISS_WEIGHT = 10;
		default DURABILITY_ARMOR_CHEST_WEIGHT = 50;			
		default DURABILITY_ARMOR_BOOTS_WEIGHT = 15;
		default DURABILITY_ARMOR_PANTS_WEIGHT = 15;
		default DURABILITY_ARMOR_GLOVES_WEIGHT = 10;
	
	
	public const var CFM_SLOWDOWN_RATIO : float;					
		default CFM_SLOWDOWN_RATIO = 0.01;
	
	
	public const var LIGHT_HIT_FX, LIGHT_HIT_BACK_FX, LIGHT_HIT_PARRIED_FX, LIGHT_HIT_BACK_PARRIED_FX, HEAVY_HIT_FX, HEAVY_HIT_BACK_FX, HEAVY_HIT_PARRIED_FX, HEAVY_HIT_BACK_PARRIED_FX : name;
		default LIGHT_HIT_FX = 'light_hit';			
		default LIGHT_HIT_BACK_FX = 'light_hit_back';
		default LIGHT_HIT_PARRIED_FX = 'light_hit_parried';
		default LIGHT_HIT_BACK_PARRIED_FX = 'light_hit_back_parried';
		default HEAVY_HIT_FX = 'heavy_hit';
		default HEAVY_HIT_BACK_FX = 'heavy_hit_back';
		default HEAVY_HIT_PARRIED_FX = 'heavy_hit_parried';
		default HEAVY_HIT_BACK_PARRIED_FX = 'heavy_hit_back_parried';
		
	public const var LOW_HP_SHOW_LEVEL : float;							
		default LOW_HP_SHOW_LEVEL = 0.25;

	
	public const var TAG_ARMOR : name;								
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_YES : name;			
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_NO : name;			
	public const var TAG_ITEM_UPGRADEABLE : name;					
	public const var TAG_DONT_SHOW : name;							
	public const var TAG_DONT_SHOW_ONLY_IN_PLAYERS : name;			
	public const var TAG_ITEM_SINGLETON : name;						
	public const var TAG_INFINITE_AMMO : name;						
	public const var TAG_UNDERWATER_AMMO : name;					
	public const var TAG_GROUND_AMMO : name;	
	public const var TAG_ILLUSION_MEDALLION : name;
	public const var TAG_PLAYER_STEELSWORD : name;					
	public const var TAG_PLAYER_SILVERSWORD : name;					
	public const var TAG_INFINITE_USE : name;						
	private var ARMOR_COMMON_ABILITIES		: array<name>;			//modSigns: random resistances for all armors
	private var ARMOR_MASTERWORK_ABILITIES 	: array<name>;			//abilities randomly added to masterwork or better armors
	private var ARMOR_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better armors
	private var GLOVES_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better gloves
	private var GLOVES_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better gloves
	private var PANTS_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better pants
	private var PANTS_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better pants
	private var BOOTS_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better boots
	private var BOOTS_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better boots
	private var WEAPON_COMMON_ABILITIES		: array<name>;			//modSigns: random common abilities for weapons
	private var WEAPON_MASTERWORK_ABILITIES	: array<name>;			//abilities randomly added to masterwork or better weapons
	private var WEAPON_MAGICAL_ABILITIES 	: array<name>;			//abilities randomly added to magical or better armors
	public const var ITEM_SET_TAG_BEAR, ITEM_SET_TAG_GRYPHON, ITEM_SET_TAG_LYNX, ITEM_SET_TAG_WOLF, ITEM_SET_TAG_RED_WOLF, ITEM_SET_TAG_VAMPIRE, ITEM_SET_TAG_VIPER : name;		
	public const var ITEM_SET_TAG_KAER_MORHEN, ITEM_SET_TAG_BEAR_MINOR, ITEM_SET_TAG_GRYPHON_MINOR, ITEM_SET_TAG_LYNX_MINOR, ITEM_SET_TAG_WOLF_MINOR : name; //modSigns
	public const var BOUNCE_ARROWS_ABILITY : name;					
	public const var TAG_ALCHEMY_REFILL_ALCO : name;				
	public const var REPAIR_OBJECT_BONUS_ARMOR_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS_WEAPON_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS : name;					
	public const var CIRI_SWORD_NAME : name;
	public const var TAG_OFIR_SET : name;							
		
		default TAG_ARMOR = 'Armor';
		default TAG_ENCUMBRANCE_ITEM_FORCE_YES = 'EncumbranceOn';
		default TAG_ENCUMBRANCE_ITEM_FORCE_NO = 'EncumbranceOff';
		default TAG_ITEM_UPGRADEABLE = 'Upgradeable';
		default TAG_DONT_SHOW = 'NoShow';
		default TAG_DONT_SHOW_ONLY_IN_PLAYERS = 'NoShowInPlayersInventory';
		default TAG_ITEM_SINGLETON = 'SingletonItem';
		default TAG_INFINITE_AMMO = 'InfiniteAmmo';
		default TAG_UNDERWATER_AMMO = 'UnderwaterAmmo';
		default TAG_GROUND_AMMO = 'GroundAmmo';
		default TAG_ILLUSION_MEDALLION = 'IllusionMedallion';
		default TAG_PLAYER_STEELSWORD = 'PlayerSteelWeapon';
		default TAG_PLAYER_SILVERSWORD = 'PlayerSilverWeapon';
		default TAG_INFINITE_USE = 'InfiniteUse';
		default ITEM_SET_TAG_BEAR = 'BearSet';
		default ITEM_SET_TAG_GRYPHON = 'GryphonSet';
		default ITEM_SET_TAG_LYNX = 'LynxSet';
		default ITEM_SET_TAG_WOLF = 'WolfSet';
		default ITEM_SET_TAG_RED_WOLF = 'RedWolfSet';
		default ITEM_SET_TAG_VIPER = 'ViperSet';
		default ITEM_SET_TAG_VAMPIRE = 'VampireSet';
		default BOUNCE_ARROWS_ABILITY = 'bounce_arrows';
		default TAG_ALCHEMY_REFILL_ALCO = 'StrongAlcohol';
		default REPAIR_OBJECT_BONUS_ARMOR_ABILITY = 'repair_object_armor_bonus';
		default REPAIR_OBJECT_BONUS_WEAPON_ABILITY = 'repair_object_weapon_bonus';
		default REPAIR_OBJECT_BONUS = 'repair_object_stat_bonus';
		default CIRI_SWORD_NAME = 'Zireael Sword';
		default TAG_OFIR_SET = 'Ofir';
		//modSigns
		default ITEM_SET_TAG_KAER_MORHEN = 'KaerMorhenSet';
		default ITEM_SET_TAG_BEAR_MINOR = 'BearSetMinor';
		default ITEM_SET_TAG_GRYPHON_MINOR = 'GryphonSetMinor';
		default ITEM_SET_TAG_LYNX_MINOR = 'LynxSetMinor';
		default ITEM_SET_TAG_WOLF_MINOR = 'WolfSetMinor';
		
	
	private var newGamePlusLevel : int;						
	private const var NEW_GAME_PLUS_LEVEL_ADD : int;		
	public const var NEW_GAME_PLUS_MIN_LEVEL : int;				
	public const var NEW_GAME_PLUS_EP1_MIN_LEVEL : int;			
		default NEW_GAME_PLUS_LEVEL_ADD = 0;
		default NEW_GAME_PLUS_MIN_LEVEL = 30;
		default NEW_GAME_PLUS_EP1_MIN_LEVEL = 30;
	
	
	public const var TAG_STEEL_OIL, TAG_SILVER_OIL : name;
		default TAG_STEEL_OIL = 'SteelOil';
		default TAG_SILVER_OIL = 'SilverOil';
	
	
	public const var SUPERHEAVY_STRIKE_COST_MULTIPLIER : float; //modSigns
	public const var HEAVY_STRIKE_COST_MULTIPLIER : float;								
	public const var PARRY_HALF_ANGLE : int;											
	//public const var PARRY_STAGGER_REDUCE_DAMAGE_LARGE : float;							
	//public const var PARRY_STAGGER_REDUCE_DAMAGE_SMALL : float;							
	public const var PARRY_STAGGER_REDUCE_DAMAGE : float; //modSigns
		default PARRY_HALF_ANGLE = 180;
		default SUPERHEAVY_STRIKE_COST_MULTIPLIER = 1.5; //modSigns +50%
		default HEAVY_STRIKE_COST_MULTIPLIER = 1.25; //modSigns: +25%
		//default PARRY_STAGGER_REDUCE_DAMAGE_LARGE = 0.6f;
		//default PARRY_STAGGER_REDUCE_DAMAGE_SMALL = 0.3f;
		default PARRY_STAGGER_REDUCE_DAMAGE = 0.5f; //modSigns
		
	
	public const var POTION_QUICKSLOTS_COUNT : int;										
		default POTION_QUICKSLOTS_COUNT = 4;
	
	
	public const var ITEMS_REQUIRED_FOR_MINOR_SET_BONUS : int;
	public const var ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS : int;
	public const var ITEM_SET_TAG_BONUS					: name;
		default ITEMS_REQUIRED_FOR_MINOR_SET_BONUS = 3;
		default ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS = 6;
		default ITEM_SET_TAG_BONUS = 'SetBonusPiece';
	
	
	public const var TAG_STEEL_SOCKETABLE, TAG_SILVER_SOCKETABLE, TAG_ARMOR_SOCKETABLE, TAG_ABILITY_SOCKET : name;
		default TAG_STEEL_SOCKETABLE = 'SteelSocketable';							
		default TAG_SILVER_SOCKETABLE = 'SilverSocketable';							
		default TAG_ARMOR_SOCKETABLE = 'ArmorSocketable';							
		default TAG_ABILITY_SOCKET = 'Socket';										
		
	
	public const var STAMINA_COST_PARRY_ATTRIBUTE, STAMINA_COST_COUNTERATTACK_ATTRIBUTE, STAMINA_COST_EVADE_ATTRIBUTE, STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE, 
					 STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_LIGHT_ACTION_ATTRIBUTE, STAMINA_COST_DODGE_ATTRIBUTE,
					 STAMINA_COST_SPRINT_ATTRIBUTE, STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE, STAMINA_COST_JUMP_ATTRIBUTE, STAMINA_COST_USABLE_ITEM_ATTRIBUTE,
					 STAMINA_COST_DEFAULT, STAMINA_COST_PER_SEC_DEFAULT, STAMINA_COST_ROLL_ATTRIBUTE, STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE : name;
					 
	public const var STAMINA_DELAY_PARRY_ATTRIBUTE, STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE, STAMINA_DELAY_EVADE_ATTRIBUTE, STAMINA_DELAY_SWIMMING_ATTRIBUTE, 
					 STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE, STAMINA_DELAY_DODGE_ATTRIBUTE,
					 STAMINA_DELAY_SPRINT_ATTRIBUTE, STAMINA_DELAY_JUMP_ATTRIBUTE, STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE, STAMINA_DELAY_DEFAULT, STAMINA_DELAY_ROLL_ATTRIBUTE,
					 STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE: name;
					 
	public const var STAMINA_SEGMENT_SIZE : int;									
		
		default STAMINA_SEGMENT_SIZE = 10;
		
		default STAMINA_COST_DEFAULT = 'stamina_cost';
		default STAMINA_COST_PER_SEC_DEFAULT = 'stamina_cost_per_sec';
		default STAMINA_COST_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_cost';
		default STAMINA_COST_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_cost';
		default STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_cost';
		default STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_cost';
		default STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_cost';
		default STAMINA_COST_PARRY_ATTRIBUTE = 'parry_stamina_cost';
		default STAMINA_COST_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_cost';
		default STAMINA_COST_DODGE_ATTRIBUTE = 'dodge_stamina_cost';
		default STAMINA_COST_EVADE_ATTRIBUTE = 'evade_stamina_cost';
		default STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE = 'swimming_stamina_cost_per_sec';
		default STAMINA_COST_SPRINT_ATTRIBUTE = 'sprint_stamina_cost';
		default STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE = 'sprint_stamina_cost_per_sec';
		default STAMINA_COST_JUMP_ATTRIBUTE = 'jump_stamina_cost';
		default STAMINA_COST_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_cost';
		default STAMINA_COST_ROLL_ATTRIBUTE = 'roll_stamina_cost';
	
		default STAMINA_DELAY_DEFAULT = 'stamina_delay';
		default STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_delay';
		default STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_delay';			 
		default STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_delay';
		default STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_delay';
		default STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_delay';	
		default STAMINA_DELAY_PARRY_ATTRIBUTE = 'parry_stamina_delay';
		default STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_delay';
		default STAMINA_DELAY_DODGE_ATTRIBUTE = 'dodge_stamina_delay';
		default STAMINA_DELAY_EVADE_ATTRIBUTE = 'evade_stamina_delay';
		default STAMINA_DELAY_SWIMMING_ATTRIBUTE = 'swimming_stamina_delay';
		default STAMINA_DELAY_SPRINT_ATTRIBUTE = 'sprint_stamina_delay';
		default STAMINA_DELAY_JUMP_ATTRIBUTE = 'jump_stamina_delay';
		default STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_delay';
		default STAMINA_DELAY_ROLL_ATTRIBUTE = 'roll_stamina_delay';
		
	//modSigns
	public const var STAMINA_DELAY_DEFAULT_NPC, STAMINA_DELAY_LIGHT_NPC, STAMINA_DELAY_HEAVY_NPC, STAMINA_DELAY_SUPER_HEAVY_NPC : float;
		
		default STAMINA_DELAY_DEFAULT_NPC = 1.f;
		default STAMINA_DELAY_LIGHT_NPC = 1.f;
		default STAMINA_DELAY_HEAVY_NPC = 1.f;
		default STAMINA_DELAY_SUPER_HEAVY_NPC = 1.f;

	
	public const var TOXICITY_DAMAGE_THRESHOLD : float;									
		default TOXICITY_DAMAGE_THRESHOLD = 0.75;
		
	
	public const var OIL_DECAY_FACTOR : float; //modSigns
		default OIL_DECAY_FACTOR = 0.5;
		
	public const var DEBUG_CHEATS_ENABLED : bool;										
	public const var SKILL_GLOBAL_PASSIVE_TAG : name;									
	public const var TAG_OPEN_FIRE : name;												
	public const var TAG_MONSTER_SKILL : name;											
	public const var TAG_EXPLODING_GAS : name;											
	public const var ON_HIT_HP_REGEN_DELAY : float;										
	public const var TAG_NPC_IN_PARTY : name;											
	public const var TAG_PLAYERS_MOUNTED_VEHICLE : name;								
	public const var TAG_SOFT_LOCK : name;												
	public const var MAX_SPELLPOWER_ASSUMED : float;									
	public const var NPC_RESIST_PER_LEVEL : float;										
	public const var XP_PER_LEVEL : int;												
	public const var XP_MINIBOSS_BONUS : float;											
	public const var XP_BOSS_BONUS : float;												
	public const var ADRENALINE_DRAIN_AFTER_COMBAT_DELAY : float;						
	public const var KEYBOARD_KEY_FONT_COLOR : string;									
	public const var MONSTER_HUNT_ACTOR_TAG : name;										
	public const var GWINT_CARD_ACHIEVEMENT_TAG : name;									
	public const var TAG_AXIIABLE, TAG_AXIIABLE_LOWER_CASE : name;						
	public const var LEVEL_DIFF_DEADLY, LEVEL_DIFF_HIGH : int;							
	public const var LEVEL_DIFF_XP_MOD : float;											
	public const var MAX_XP_MOD : float;												
	public const var DEVIL_HORSE_AURA_MIN_DELAY, DEVIL_HORSE_AURA_MAX_DELAY : int;		
	public const var TOTAL_AMOUNT_OF_BOOKS	: int;										
	public const var MAX_PLAYER_LEVEL	: int;											
	
		default DEBUG_CHEATS_ENABLED = true;
		default SKILL_GLOBAL_PASSIVE_TAG = 'GlobalPassiveBonus';
		default TAG_MONSTER_SKILL = 'MonsterSkill';
		default TAG_OPEN_FIRE = 'CarriesOpenFire';
		default TAG_EXPLODING_GAS = 'explodingGas';
		default ON_HIT_HP_REGEN_DELAY = 2;
		default TAG_NPC_IN_PARTY = 'InPlayerParty';
		default TAG_PLAYERS_MOUNTED_VEHICLE = 'PLAYER_mounted_vehicle';
		default TAG_SOFT_LOCK = 'softLock';
		default MAX_SPELLPOWER_ASSUMED = 2;
		default NPC_RESIST_PER_LEVEL = 0.016;
		default XP_PER_LEVEL = 1;
		default XP_MINIBOSS_BONUS = 1.77;
		default XP_BOSS_BONUS = 2.5;
		default ADRENALINE_DRAIN_AFTER_COMBAT_DELAY = 3;
		default KEYBOARD_KEY_FONT_COLOR = "#CD7D03";
		default MONSTER_HUNT_ACTOR_TAG = 'MonsterHuntTarget';
		default GWINT_CARD_ACHIEVEMENT_TAG = 'GwintCollectorAchievement';
		default TAG_AXIIABLE = 'Axiiable';
		default TAG_AXIIABLE_LOWER_CASE = 'axiiable';
		default LEVEL_DIFF_HIGH = 6;
		default LEVEL_DIFF_DEADLY = 15;
		default LEVEL_DIFF_XP_MOD = 0.16f;
		default MAX_XP_MOD = 1.5f;
		default DEVIL_HORSE_AURA_MIN_DELAY = 2;
		default DEVIL_HORSE_AURA_MAX_DELAY = 6;
		default TOTAL_AMOUNT_OF_BOOKS = 130;
		default MAX_PLAYER_LEVEL = 100;
		
	
	public function Init()
	{
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('global_params');
				
		
		InitForbiddenAttributesList();
		
		SetWeaponDurabilityModifiers();
		
		SetArmorDurabilityModifiers();
			
		
		InitArmorAbilities();
		InitGlovesAbilities();
		InitPantsAbilities();
		InitBootsAbilities();
		InitWeaponAbilities();
		
		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS.Resize(5);
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[0] = 70;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[1] = 50;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[2] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[3] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[4] = 0;		
		
		newGamePlusLevel = FactsQuerySum("FinalNewGamePlusLevel");
	}
	
	private final function SetWeaponDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsWeapon.PushBack(dur);
	}
	
	private final function SetArmorDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsArmor.PushBack(dur);
	}
	
	public final function GetWeaponDurabilityLoseValue() : float
	{
		if(theGame.GetDifficultyMode() == EDM_Hardcore)
			return DURABILITY_WEAPON_LOSE_VALUE_HARDCORE;
		else
			return DURABILITY_WEAPON_LOSE_VALUE;		
	}
	
	private function InitArmorAbilities()
	{
		//modSigns
		ARMOR_COMMON_ABILITIES.PushBack('MA_SlashingResistance');
		ARMOR_COMMON_ABILITIES.PushBack('MA_PiercingResistance');
		ARMOR_COMMON_ABILITIES.PushBack('MA_BludgeoningResistance');
		ARMOR_COMMON_ABILITIES.PushBack('MA_RendingResistance');
		ARMOR_COMMON_ABILITIES.PushBack('MA_ElementalResistance');
		
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
		ARMOR_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
		
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		ARMOR_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitGlovesAbilities()
	{
		//modSigns
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
		GLOVES_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
		
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		GLOVES_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitPantsAbilities()
	{
		//modSigns
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
		PANTS_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
		
		PANTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		PANTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitBootsAbilities()
	{
		//modSigns
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
		BOOTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
		
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		BOOTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	private function InitWeaponAbilities()
	{
		//modSigns
		WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetration');
		WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetrationPerc');
		WEAPON_COMMON_ABILITIES.PushBack('MA_AttackPowerMult');
		WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalChance');
		WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalDamage');
		WEAPON_COMMON_ABILITIES.PushBack('MA_AdrenalineGain');
		
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BleedingChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_FreezingChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_PoisonChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_ConfusionChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BurningChance');
		WEAPON_MASTERWORK_ABILITIES.PushBack('MA_StaggerChance');
		
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
		WEAPON_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
	}
	
	
	private function InitForbiddenAttributesList()
	{
		var i,size : int;
	
		size = EnumGetMax('EBaseCharacterStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(StatEnumToName(i));
			
		size = EnumGetMax('ECharacterDefenseStats')+1;
		for(i=0; i<size; i+=1)
		{
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, true));
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, false));
		}
			
		size = EnumGetMax('ECharacterPowerStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(PowerStatEnumToName(i));
	}
	
	public function IsForbiddenAttribute(nam : name) : bool
	{
		if(!IsNameValid(nam))
			return true;
		
		return forbiddenAttributes.Contains(nam);
	}
	
	
	public function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
	{
		/*if(isWeapon)
			return GetDurMult(durabilityRatio, durabilityThresholdsWeapon);
		else
			return GetDurMult(durabilityRatio, durabilityThresholdsArmor);*/
		//modSigns: make durability matter more
		var currDiff : EDifficultyMode;
		currDiff = theGame.GetDifficultyMode();
		switch( currDiff )
		{
			case EDM_Easy:
				return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.8f, 1.0f);
			case EDM_Medium:
				return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.7f, 1.0f);
			case EDM_Hard:
				return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.6f, 1.0f);
			case EDM_Hardcore:
				return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.5f, 1.0f);
			default:
				return 1.0f;
		}
	}
	
	private function GetDurMult(durabilityRatio : float, durs : array<SDurabilityThreshold>) : float
	{
		var i : int;
		var currDiff : EDifficultyMode;
	
		currDiff = theGame.GetDifficultyMode();
		
		for(i=durs.Size()-1; i>=0; i-=1)
		{
			if(durs[i].difficulty == currDiff)			
				if(durabilityRatio <= durs[i].thresholdMax)
					return durs[i].multiplier;
		}
		
		return durs[0].multiplier;
	}
	
	//modSigns
	public function GetRandomCommonArmorAbility() : name
	{
		return ARMOR_COMMON_ABILITIES[RandRange(ARMOR_COMMON_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkArmorAbility() : name
	{
		return ARMOR_MASTERWORK_ABILITIES[RandRange(ARMOR_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalArmorAbility() : name
	{
		return ARMOR_MAGICAL_ABILITIES[RandRange(ARMOR_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_ABILITIES[RandRange(GLOVES_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalGlovesAbility() : name
	{
		return GLOVES_MAGICAL_ABILITIES[RandRange(GLOVES_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkPantsAbility() : name
	{
		return PANTS_MASTERWORK_ABILITIES[RandRange(PANTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalPantsAbility() : name
	{
		return PANTS_MAGICAL_ABILITIES[RandRange(PANTS_MAGICAL_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkBootsAbility() : name
	{
		return BOOTS_MASTERWORK_ABILITIES[RandRange(BOOTS_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalBootsAbility() : name
	{
		return BOOTS_MAGICAL_ABILITIES[RandRange(BOOTS_MAGICAL_ABILITIES.Size())];
	}
	
	//modSigns
	public function GetRandomCommonWeaponAbility() : name
	{
		return WEAPON_COMMON_ABILITIES[RandRange(WEAPON_COMMON_ABILITIES.Size())];
	}
	
	public function GetRandomMasterworkWeaponAbility() : name
	{
		return WEAPON_MASTERWORK_ABILITIES[RandRange(WEAPON_MASTERWORK_ABILITIES.Size())];
	}
	
	public function GetRandomMagicalWeaponAbility() : name
	{
		return WEAPON_MAGICAL_ABILITIES[RandRange(WEAPON_MAGICAL_ABILITIES.Size())];
	}
	
	
	public function GetStaminaActionAttributes(action : EStaminaActionType, getCostPerSec : bool, out costAttributeName : name, out delayAttributeName : name)
	{		
		switch(action)
		{
			case ESAT_LightAttack :
				costAttributeName = STAMINA_COST_LIGHT_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_SuperHeavyAttack :
				costAttributeName = STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_LightSpecial :
				costAttributeName = STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_Parry :
				costAttributeName = STAMINA_COST_PARRY_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_PARRY_ATTRIBUTE;
				return;
			case ESAT_Counterattack :
				costAttributeName = STAMINA_COST_COUNTERATTACK_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE;
				return;
			case ESAT_Dodge :
				costAttributeName = STAMINA_COST_DODGE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_DODGE_ATTRIBUTE;
				return;
			case ESAT_Roll :
				costAttributeName = STAMINA_COST_ROLL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_ROLL_ATTRIBUTE;
				return;
			case ESAT_Evade :
				costAttributeName = STAMINA_COST_EVADE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_EVADE_ATTRIBUTE;
				return;
			case ESAT_Swimming :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SWIMMING_ATTRIBUTE;
				return;
			case ESAT_Sprint :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE;
				}
				else
				{
					costAttributeName = STAMINA_COST_SPRINT_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SPRINT_ATTRIBUTE;
				return;
			case ESAT_Jump :
				costAttributeName = STAMINA_COST_JUMP_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_JUMP_ATTRIBUTE;
				return;
			case ESAT_UsableItem :
				costAttributeName = STAMINA_COST_USABLE_ITEM_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE;
				return;
			case ESAT_Ability :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_PER_SEC_DEFAULT;
				}
				else
				{
					costAttributeName = STAMINA_COST_DEFAULT;
				}
				delayAttributeName = STAMINA_DELAY_DEFAULT;
				return;
			default :
				LogAssert(false, "W3GameParams.GetStaminaActionAttributes : unknown stamina action type <<" + action + ">> !!");
				return;
		}		
	}	
	    
  	public function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name/*, optional out baseItemLevel : int*/) : int //modSigns
	{
		var stat : SAbilityAttributeValue;
		var stat_f : float;
		var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
		var stat_min, stat_add : float;
		var level : int;
	
		//modSigns: notes
		//weapon level is determined by BASE damage value and armor level is determined by BASE armor reduction value
		//bonuses with type="add" don't affect weapon level
		if ( itemCategory == 'armor' )
		{
			stat_min = 25;
			stat_add = 5;
			stat = itemAttributes[0];
			level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); //modSigns
		} else
		if ( itemCategory == 'boots' )
		{
			stat_min = 5;
			stat_add = 2;
			stat = itemAttributes[0];
			level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); //modSigns
		} else
		if ( itemCategory == 'gloves' )
		{
			stat_min = 1;
			stat_add = 2;
			stat = itemAttributes[0];
			level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); //modSigns
		} else
		if ( itemCategory == 'pants' )
		{
			stat_min = 5;
			stat_add = 2;
			stat = itemAttributes[0];
			level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); //modSigns
		} else
		if ( itemCategory == 'silversword' )
		{
			stat_min = 90;
			stat_add = 10;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1);
			level = CeilF( ( stat_f - stat_min ) / stat_add );  //modSigns
		} else
		if ( itemCategory == 'steelsword' )
		{
			stat_min = 25;
			stat_add = 8;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat7 = itemAttributes[6];
			stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1) + MaxF(0, stat7.valueBase - 1);
			level = CeilF( ( stat_f - stat_min ) / stat_add );  //modSigns
		} else
		if ( itemCategory == 'bolt' )
		{
			if ( itemName == 'Tracking Bolt' ) { level = 2; } else
			if ( itemName == 'Bait Bolt' ) { level = 2; }  else
			if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
			if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
			if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
			if ( itemName == 'Split Bolt' ) { level = 15; }  else
			if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
			//if ( itemName == 'Blunt Bolt Legendary' ) { level = 5; }  else //modSigns: bug? removed
			if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
			if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
			if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
			if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 
		} else
		if ( itemCategory == 'crossbow' )
		{
			stat = itemAttributes[0];
			level = 1;
			if ( stat.valueMultiplicative > 1.01 ) level = 2;
			if ( stat.valueMultiplicative > 1.1 ) level = 4;
			if ( stat.valueMultiplicative > 1.2 ) level = 8;
			if ( stat.valueMultiplicative > 1.3 ) level = 11;
			if ( stat.valueMultiplicative > 1.4 ) level = 15;
			if ( stat.valueMultiplicative > 1.5 ) level = 19;
			if ( stat.valueMultiplicative > 1.6 ) level = 22;
			if ( stat.valueMultiplicative > 1.7 ) level = 25;
			if ( stat.valueMultiplicative > 1.8 ) level = 27;
			if ( stat.valueMultiplicative > 1.9 ) level = 32;
			//modSigns
			if ( stat.valueMultiplicative > 2.0 ) level = 34;
			if ( stat.valueMultiplicative > 2.1 ) level = 38;
		} 
		//modSigns: no dancing around levels
		level = Clamp(level, 1, GetWitcherPlayer().GetMaxLevel());
		/*level = level - 1;
		if ( level < 1 ) level = 1;	
		baseItemLevel = level;
		if ( level > GetWitcherPlayer().GetMaxLevel() ) level = GetWitcherPlayer().GetMaxLevel();*/
		
		return level;
	}
	
	public final function SetNewGamePlusLevel(playerLevel : int)
	{
		if ( playerLevel > NEW_GAME_PLUS_MIN_LEVEL )
		{
			newGamePlusLevel = playerLevel;
		}
		else
		{
			newGamePlusLevel = NEW_GAME_PLUS_MIN_LEVEL;
		}
			
		FactsAdd("FinalNewGamePlusLevel", newGamePlusLevel);
	}
	
	public final function GetNewGamePlusLevel() : int
	{
		return newGamePlusLevel;
	}
	public final function NewGamePlusLevelDifference() : int
	{
		return ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL );
	}
	public final function GetPlayerMaxLevel() : int
	{
		return MAX_PLAYER_LEVEL;
	}
	
	//modSigns: menu config variables
	public function GetEnemyHealthMult() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMHealthMultiplier'));
	}
	
	public function GetEnemyDamageMult() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMDamageMultiplier'));
	}
	
	public function GetBossHealthMult() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMBossHealthMultiplier'));
	}
	
	public function GetBossDamageMult() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMBossDamageMultiplier'));
	}
	
	public function GetEnemyScalingOption() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'Virtual_GMScaling'));
	}

	public function GetNoAnimalUpscaling() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMNoAnimalUpscaling'));
	}
	
	public function GetNoAdditionalLevelsForGuards() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMNoAddLevelsGuards'));
	}
	
	public function GetRandomScalingMinLevel() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMRandomScalingMinLevel'));
	}
	
	public function GetRandomScalingMaxLevel() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMRandomScalingMaxLevel'));
	}
	
	public function GetNonlinearLevelup() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMNonlinearLevelup'));
	}
	
	public function GetNonlinearLevelDelta() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMNonlinearLevelDelta'));
	}
	
	public function GetNonlinearAbilitiesDelta() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GMScalingOptions', 'GMNonlinearAbilitiesDelta'));
	}
	
	public function GetFixedExp() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMExpOptions', 'GMUseXMLExp'));
	}
	
	public function GetQuestExpModifier() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMExpOptions', 'GMQuestExpModifier'));
	}
	
	public function GetMonsterExpModifier() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMExpOptions', 'GMMonsterExpModifier'));
	}
	
	public function GetNoQuestLevels() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMExpOptions', 'GMNoQuestLevels'));
	}
	
	public function GetGMVersion() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMVersion'));
	}
	
	public function GetBoatSinkOption() : bool
	{
		return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMSinkBoat'));
	}
	
	public function GetBoatSinkOverEncumbranceOption() : float
	{
		return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMSinkBoatOverEnc'));
	}
	
	public function GetEncumbranceMult() : float
	{
		return ClampF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMEncumbranceMultiplier'))/100, 0, 1);
	}
	
	private var isArmorRegenPenaltyEnabled : int; default isArmorRegenPenaltyEnabled = 0;
	
	public function IsArmorRegenPenaltyEnabled() : bool
	{
		if(isArmorRegenPenaltyEnabled == 0)
		{
			//apparently, this superb engine can't convert false/true to 0/1
			if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMArmorRegenPenalty')))
				isArmorRegenPenaltyEnabled = 2;
			else
				isArmorRegenPenaltyEnabled = 1;
		}
		return (isArmorRegenPenaltyEnabled > 1);
	}
	
	private var combatStaminaRegen : float; default combatStaminaRegen = -1000;
	
	public function GetCombatStaminaRegen() : float
	{
		if(combatStaminaRegen <= -1000)
		{
			combatStaminaRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMCombatStaminaRegen'));
		}
		return combatStaminaRegen;
	}
	
	private var outOfCombatStaminaRegen : float; default outOfCombatStaminaRegen = -1000;
	
	public function GetOutOfCombatStaminaRegen() : float
	{
		if(outOfCombatStaminaRegen <= -1000)
		{
			outOfCombatStaminaRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMOutOfCombatStaminaRegen'));
		}
		return outOfCombatStaminaRegen;
	}
	
	private var combatVitalityRegen : float; default combatVitalityRegen = -1000;
	
	public function GetCombatVitalityRegen() : float
	{
		if(combatVitalityRegen <= -1000)
		{
			combatVitalityRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMCombatVitalityRegen'));
		}
		return combatVitalityRegen;
	}
	
	private var outOfCombatVitalityRegen : float; default outOfCombatVitalityRegen = -1000;
	
	public function GetOutOfCombatVitalityRegen() : float
	{
		if(outOfCombatVitalityRegen <= -1000)
		{
			outOfCombatVitalityRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMOutOfCombatVitalityRegen'));
		}
		return outOfCombatVitalityRegen;
	}
	
	private var agilityStaminaCostMult : float; default agilityStaminaCostMult = -1000;
	
	public function GetAgilityStaminaCostMult() : float
	{
		if(agilityStaminaCostMult <= -1000)
		{
			agilityStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMAgilityStaminaCostMultiplier'));
		}
		return agilityStaminaCostMult;
	}
	
	private var meleeStaminaCostMult : float; default meleeStaminaCostMult = -1000;
	
	public function GetMeleeStaminaCostMult() : float
	{
		if(meleeStaminaCostMult <= -1000)
		{
			meleeStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMMeleeStaminaCostMultiplier'));
		}
		return meleeStaminaCostMult;
	}
	
	private var signStaminaCostMult : float; default signStaminaCostMult = -1000;
	
	public function GetSignStaminaCostMult() : float
	{
		if(signStaminaCostMult <= -1000)
		{
			signStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMSignStaminaCostMultiplier'));
		}
		return signStaminaCostMult;
	}
	
	private var staminaDelay : float; default staminaDelay = -1000;
	
	public function GetStaminaDelay() : float
	{
		if(staminaDelay <= -1000)
		{
			staminaDelay = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMStaminaDelay'));
		}
		return staminaDelay;
	}
	
	private var signCooldown : float; default signCooldown = -1000;
	
	public function GetSignCooldownDuration() : float
	{
		if(signCooldown <= -1000)
		{
			signCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMSignCooldown'));
		}
		return signCooldown;
	}
	
	private var altSignCooldown : float; default altSignCooldown = -1000;
	
	public function GetAltSignCooldownDuration() : float
	{
		if(altSignCooldown <= -1000)
		{
			altSignCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMAltSignCooldown'));
		}
		return altSignCooldown;
	}
	
	private var meleeSpecialCooldown : float; default meleeSpecialCooldown = -1000;
	
	public function GetMeleeSpecialCooldownDuration() : float
	{
		if(meleeSpecialCooldown <= -1000)
		{
			meleeSpecialCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMMeleeSpecialCooldown'));
		}
		return meleeSpecialCooldown;
	}
	
	public function gmResetCachedValuesGameplay()
	{
		isArmorRegenPenaltyEnabled = 0;
		combatStaminaRegen = -1000;
		outOfCombatStaminaRegen = -1000;
		combatVitalityRegen = -1000;
		outOfCombatVitalityRegen = -1000;
		agilityStaminaCostMult = -1000;
		meleeStaminaCostMult = -1000;
		signStaminaCostMult = -1000;
		staminaDelay = -1000;
		signCooldown = -1000;
		altSignCooldown = -1000;
		meleeSpecialCooldown = -1000;
		gmSetGMVersion();
	}
	
	private var instantCastingToggle : int; default instantCastingToggle = 0;
	
	public function GetInstantCasting() : bool
	{
		if(instantCastingToggle == 0)
		{
			//apparently, this superb engine can't convert false/true to 0/1
			if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMSignInstantCast')))
				instantCastingToggle = 2;
			else
				instantCastingToggle = 1;
		}
		return (instantCastingToggle > 1);
	}
	
	private var lowStaminaSFXThreshold : float; default lowStaminaSFXThreshold = -1000;
	
	public function GetLowStaminaSFXThreshold() : float
	{
		if(lowStaminaSFXThreshold <= -1000)
		{
			lowStaminaSFXThreshold = 0.01 * StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMLowStaminaSFX'));
		}
		return lowStaminaSFXThreshold;
	}
	
	private var lowStaminaSFXVolume : float; default lowStaminaSFXVolume = -1000;
	
	public function GetLowStaminaSFXVolume() : float
	{
		if(lowStaminaSFXVolume <= -1000)
		{
			lowStaminaSFXVolume = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMLowStaminaSFXVolume'));
		}
		return lowStaminaSFXVolume;
	}
	
	private var lowStaminaSFXRate : float; default lowStaminaSFXRate = -1000;
	
	public function GetLowStaminaSFXRate() : float
	{
		if(lowStaminaSFXRate <= -1000)
		{
			lowStaminaSFXRate = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMLowStaminaSFXRate'));
		}
		return lowStaminaSFXRate;
	}
	
	private var lowStaminaSFXDynVol : int; default lowStaminaSFXDynVol = 0;
	
	public function GetLowStaminaSFXDynVol() : bool
	{
		if(lowStaminaSFXDynVol == 0)
		{
			//apparently, this superb engine can't convert false/true to 0/1
			if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMLowStaminaSFXDynamicVolume')))
				lowStaminaSFXDynVol = 2;
			else
				lowStaminaSFXDynVol = 1;
		}
		return (lowStaminaSFXDynVol > 1);
	}
	
	private var lowStaminaSFXDynRate : int; default lowStaminaSFXDynRate = 0;
	
	public function GetLowStaminaSFXDynRate() : bool
	{
		if(lowStaminaSFXDynRate == 0)
		{
			//apparently, this superb engine can't convert false/true to 0/1
			if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('GMQOLOptions', 'GMLowStaminaSFXDynamicRate')))
				lowStaminaSFXDynRate = 2;
			else
				lowStaminaSFXDynRate = 1;
		}
		return (lowStaminaSFXDynRate > 1);
	}
	
	public function gmResetCachedValuesQoL()
	{
		instantCastingToggle = 0;
		lowStaminaSFXThreshold = -1000;
		lowStaminaSFXVolume = -1000;
		lowStaminaSFXRate = -1000;
		lowStaminaSFXDynVol = 0;
		lowStaminaSFXDynRate = 0;
	}
}
