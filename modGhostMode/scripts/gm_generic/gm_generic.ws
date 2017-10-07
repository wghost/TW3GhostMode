enum EEnemyType
{
	EENT_GENERIC,
	EENT_ANIMAL,
	EENT_BOSS,
	//BASE:
	EENT_HUMAN,
	EENT_DOG,
	EENT_WOLF,
	EENT_BEAR,
	EENT_BEAR_BERSERKER,
	EENT_WILD_HUNT_WARRIOR,
	EENT_WILD_HUNT_MINION,
	EENT_NEKKER,
	EENT_DROWNER,
	EENT_ROTFIEND,
	EENT_GHOUL,
	EENT_ALGHOUL,
	EENT_GRYPHON,
	EENT_BASILISK,
	EENT_COCKATRICE,
	EENT_WYVERN,
	EENT_FORKTAIL,
	EENT_WATERHAG,
	EENT_GRAVEHAG,
	EENT_FOGLING,
	EENT_WRAITH,
	EENT_NIGHTWRAITH,
	EENT_NOONWRAITH,
	EENT_ENDRIAGA_WORKER,
	EENT_ENDRIAGA_SOLDIER,
	EENT_ENDRIAGA_TRUTEN,
	EENT_FUGAS,
	EENT_GARGOYLE,
	EENT_ARACHAS,
	EENT_ARACHAS_ARMORED,
	EENT_ARACHAS_POISON,
	EENT_WEREWOLF,
	EENT_KATAKAN,
	EENT_EKIMMA,
	EENT_TROLL,
	EENT_TROLL_ICE,
	EENT_GOLEM,
	EENT_ELEMENTAL,
	EENT_ELEMENTAL_FIRE,
	EENT_ELEMENTAL_ICE,
	EENT_BIES,
	EENT_CZART,
	EENT_CYCLOPS,
	EENT_SIREN,
	EENT_HARPY,
	EENT_ERYNIA,
	EENT_LESSOG,
	//EP1:
	EENT_BOAR,
	EENT_BLACK_SPIDER,
	//EP2:
	EENT_PANTHER,
	EENT_SHARLEY,
	EENT_DRACOLIZARD,
	EENT_KIKIMORA_WORKER,
	EENT_KIKIMORA_WARRIOR,
	EENT_SCOLOPENDROMORPH,
	EENT_ARCHESPOR,
	EENT_SPRIGAN,
	EENT_WIGHT,
	EENT_BARGHEST,
	EENT_NIGHTWRAITH_BANSHEE,
	EENT_BRUXA,
	EENT_ALP,
	EENT_GRAVIER,
	EENT_FLEDER,
	EENT_PROTOFLEDER,
	EENT_GARKAIN,
	EENT_MAX_TYPES
};


function GetEnemyTypeByAbility( actor : CActor ) : EEnemyType
{
	//BOSSES:
	
	if(actor.HasAbility('mon_knight_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_cloud_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_fairytale_witch')) return EENT_BOSS;
	if(actor.HasAbility('mon_broom_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_vampire_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_monster_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_construct_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_toad_base')) return EENT_BOSS;
	if(actor.HasAbility('q604_caretaker')) return EENT_BOSS;
	if(actor.HasAbility('olgierd_default_stats')) return EENT_BOSS;
	if(actor.HasAbility('ethereal_default_stats')) return EENT_BOSS;
	if(actor.HasAbility('mon_ice_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_greater_miscreant')) return EENT_BOSS;
	if(actor.HasAbility('mon_him')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch1')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch2')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch3')) return EENT_BOSS;
	if(actor.HasAbility('mon_djinn')) return EENT_BOSS;
	if(actor.HasAbility('mon_heart_miniboss')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Eredin')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Imlerith')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Caranthir')) return EENT_BOSS;

	//EP2:
	
	if(actor.HasAbility('mon_sharley_young')) return EENT_SHARLEY;
	if(actor.HasAbility('mon_sharley')) return EENT_SHARLEY;
	if(actor.HasAbility('mon_sharley_base')) return EENT_SHARLEY;

	if(actor.HasAbility('mon_bruxa')) return EENT_BRUXA;
	if(actor.HasAbility('mon_alp')) return EENT_BRUXA;
	if(actor.HasAbility('mon_vampiress_base')) return EENT_BRUXA;

	if(actor.HasAbility('mon_draco_base')) return EENT_DRACOLIZARD;

	if(actor.HasAbility('mon_barghest')) return EENT_BARGHEST;
	if(actor.HasAbility('mon_barghest_wight_minion')) return EENT_BARGHEST;
	if(actor.HasAbility('mon_barghest_base')) return EENT_BARGHEST;

	if(actor.HasAbility('mon_black_spider_ep2_large')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_ep2')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_ep2_base')) return EENT_BLACK_SPIDER;

	if(actor.HasAbility('mon_kikimora_warrior')) return EENT_KIKIMORA_WARRIOR;
	if(actor.HasAbility('mon_kikimora_worker')) return EENT_KIKIMORA_WORKER;
	if(actor.HasAbility('mon_kikimore_base')) return EENT_KIKIMORA_WORKER;

	if(actor.HasAbility('mon_scolopendromorph_base')) return EENT_SCOLOPENDROMORPH;

	if(actor.HasAbility('mon_archespor_hard')) return EENT_ARCHESPOR;
	if(actor.HasAbility('mon_archespor')) return EENT_ARCHESPOR;
	//if(actor.HasAbility('mon_archespor_turret')) return EENT_ARCHESPOR;
	//if(actor.HasAbility('mon_archespor_petals')) return EENT_ARCHESPOR;
	if(actor.HasAbility('mon_archespor_base')) return EENT_ARCHESPOR;

	if(actor.HasAbility('mon_sprigan')) return EENT_SPRIGAN;
	if(actor.HasAbility('mon_sprigan_base')) return EENT_SPRIGAN;

	if(actor.HasAbility('mon_spooncollector')) return EENT_WIGHT;
	if(actor.HasAbility('mon_wight')) return EENT_WIGHT;

	if(actor.HasAbility('mon_gravier')) return EENT_GRAVIER;

	if(actor.HasAbility('mon_nightwraith_banshee')) return EENT_NIGHTWRAITH_BANSHEE;
	//if(actor.HasAbility('banshee_summons')) return EENT_NIGHTWRAITH;

	if(actor.HasAbility('mon_fleder')) return EENT_FLEDER;
	if(actor.HasAbility('q704_mon_protofleder')) return EENT_PROTOFLEDER;
	if(actor.HasAbility('mon_garkain')) return EENT_GARKAIN;

	if(actor.HasAbility('mon_panther')) return EENT_PANTHER;
	if(actor.HasAbility('mon_panther_ghost')) return EENT_PANTHER;
	if(actor.HasAbility('mon_panther_base')) return EENT_PANTHER;

	if(actor.HasAbility('mon_boar_ep2_base')) return EENT_BOAR;

	//EP1:

	if(actor.HasAbility('mon_nightwraith_iris')) return EENT_NIGHTWRAITH;
	
	if(actor.HasAbility('HaklandMage')) return EENT_HUMAN;
	if(actor.HasAbility('HaklandMagePhase1')) return EENT_HUMAN;

	if(actor.HasAbility('mon_boar_base')) return EENT_BOAR;

	if(actor.HasAbility('mon_black_spider_large')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_base')) return EENT_BLACK_SPIDER;

	//Base game:
	
	if(actor.HasAbility('mon_endriaga_soldier_tailed')) return EENT_ENDRIAGA_SOLDIER;
	if(actor.HasAbility('mon_endriaga_soldier_spikey')) return EENT_ENDRIAGA_TRUTEN;
	if(actor.HasAbility('mon_endriaga_worker')) return EENT_ENDRIAGA_WORKER;
	if(actor.HasAbility('mon_endriaga_base')) return EENT_ENDRIAGA_WORKER;

	if(actor.HasAbility('mon_fugas')) return EENT_FUGAS;
	if(actor.HasAbility('mon_fugas_lesser')) return EENT_FUGAS;
	if(actor.HasAbility('mon_gargoyle')) return EENT_GARGOYLE;
	if(actor.HasAbility('mon_fugas_base')) return EENT_FUGAS;

	if(actor.HasAbility('mon_poison_arachas')) return EENT_ARACHAS_POISON;
	if(actor.HasAbility('mon_arachas_armored')) return EENT_ARACHAS_ARMORED;
	if(actor.HasAbility('mon_arachas')) return EENT_ARACHAS;
	if(actor.HasAbility('mon_arachas_base')) return EENT_ARACHAS;

	if(actor.HasAbility('mon_bear_berserker')) return EENT_BEAR_BERSERKER;
	if(actor.HasAbility('mon_bear_black')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_grizzly')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_white')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_fistfight')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_base')) return EENT_BEAR;

	if(actor.HasAbility('mon_werewolf_lesser')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_werewolf')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_lycanthrope')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_katakan')) return EENT_KATAKAN;
	if(actor.HasAbility('mon_katakan_large')) return EENT_KATAKAN;
	if(actor.HasAbility('mon_ekimma')) return EENT_EKIMMA;
	if(actor.HasAbility('mon_werewolf_base')) return EENT_WEREWOLF;

	if(actor.HasAbility('mon_ice_troll')) return EENT_TROLL_ICE;
	if(actor.HasAbility('mon_black_troll')) return EENT_TROLL;
	if(actor.HasAbility('mon_cave_troll_young')) return EENT_TROLL;
	if(actor.HasAbility('mon_cave_troll')) return EENT_TROLL;
	if(actor.HasAbility('mon_troll_fistfight')) return EENT_TROLL;
	if(actor.HasAbility('mon_troll_base')) return EENT_TROLL;

	if(actor.HasAbility('mon_golem_lvl1')) return EENT_GOLEM;
	if(actor.HasAbility('mon_golem')) return EENT_GOLEM;
	if(actor.HasAbility('mon_elemental_dao_lesser')) return EENT_ELEMENTAL;
	if(actor.HasAbility('mon_elemental_dao')) return EENT_ELEMENTAL;
	if(actor.HasAbility('mon_ice_golem')) return EENT_ELEMENTAL_ICE;
	if(actor.HasAbility('mon_elemental_fire')) return EENT_ELEMENTAL_FIRE;
	if(actor.HasAbility('mon_elemental_fire_q211')) return EENT_ELEMENTAL_FIRE;
	if(actor.HasAbility('mon_golem_base')) return EENT_GOLEM;

	if(actor.HasAbility('mon_bies')) return EENT_BIES;
	if(actor.HasAbility('mon_bies_lesser')) return EENT_BIES;
	if(actor.HasAbility('mon_czart')) return EENT_CZART;
	if(actor.HasAbility('mon_bies_base')) return EENT_BIES;

	if(actor.HasAbility('mon_cyclops')) return EENT_CYCLOPS;
	
	if(actor.HasAbility('mon_lamia')) return EENT_SIREN;
	if(actor.HasAbility('mon_lamia_stronger')) return EENT_SIREN;
	if(actor.HasAbility('mon_siren')) return EENT_SIREN;
	if(actor.HasAbility('mon_siren_base')) return EENT_SIREN;

	if(actor.HasAbility('mon_erynia')) return EENT_ERYNIA;
	if(actor.HasAbility('mon_harpy')) return EENT_HARPY;
	if(actor.HasAbility('mon_harpy_base')) return EENT_HARPY;

	if(actor.HasAbility('mon_wraith')) return EENT_WRAITH;
	if(actor.HasAbility('mon_wraith_mh')) return EENT_WRAITH;
	if(actor.HasAbility('mon_wraith_base')) return EENT_WRAITH;

	if(actor.HasAbility('mon_nightwraith')) return EENT_NIGHTWRAITH;
	if(actor.HasAbility('mon_nightwraith_mh')) return EENT_NIGHTWRAITH;
	if(actor.HasAbility('mon_pesta')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith_mh')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith')) return EENT_NOONWRAITH;
	//if(actor.HasAbility('mon_noonwraith_doppelganger')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith_base')) return EENT_NOONWRAITH;

	if(actor.HasAbility('mon_nekker_warrior')) return EENT_NEKKER;
	if(actor.HasAbility('mon_nekker')) return EENT_NEKKER;
	if(actor.HasAbility('mon_nekker_base')) return EENT_NEKKER;

	if(actor.HasAbility('mon_rotfiend_large')) return EENT_ROTFIEND;
	if(actor.HasAbility('mon_rotfiend')) return EENT_ROTFIEND;
	if(actor.HasAbility('mon_drowneddead')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner_underwater')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner_base')) return EENT_DROWNER;

	if(actor.HasAbility('mon_wild_hunt_minionMH')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion_lesser')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion_weak')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_alghoul')) return EENT_ALGHOUL;
	if(actor.HasAbility('mon_ghoul_stronger')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul_lesser')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul_base')) return EENT_GHOUL;

	if(actor.HasAbility('mon_gryphon_volcanic')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon_stronger')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon_lesser')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_basilisk')) return EENT_BASILISK;
	if(actor.HasAbility('mon_cockatrice')) return EENT_COCKATRICE;
	if(actor.HasAbility('mon_gryphon_base')) return EENT_GRYPHON;

	if(actor.HasAbility('mon_lessog_ancient')) return EENT_LESSOG;
	if(actor.HasAbility('mon_lessog')) return EENT_LESSOG;
	if(actor.HasAbility('mon_lessog_base')) return EENT_LESSOG;

	if(actor.HasAbility('mon_forktail_mh')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_forktail')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_forktail_young')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_wyvern')) return EENT_WYVERN;
	if(actor.HasAbility('mon_wyvern_base')) return EENT_WYVERN;

	//if(actor.HasAbility('mon_baronswife')) return EENT_GRAVEHAG;
	if(actor.HasAbility('mon_gravehag')) return EENT_GRAVEHAG;
	if(actor.HasAbility('mon_fogling_mh')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling_stronger')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling_lesser')) return EENT_FOGLING;
	//if(actor.HasAbility('mon_fogling_doppelganger')) return EENT_FOGLING;
	if(actor.HasAbility('mon_waterhag_greater')) return EENT_WATERHAG;
	if(actor.HasAbility('mon_waterhag')) return EENT_WATERHAG;
	if(actor.HasAbility('mon_gravehag_base')) return EENT_GRAVEHAG;

	if(actor.HasAbility('mon_wild_hunt_default')) return EENT_WILD_HUNT_WARRIOR;

	if(actor.HasAbility('ConDefault')) return EENT_HUMAN;
	if(actor.HasAbility('ConAverage')) return EENT_HUMAN;
	if(actor.HasAbility('ConAthletic')) return EENT_HUMAN;
	if(actor.HasAbility('ConFrail')) return EENT_HUMAN;
	if(actor.HasAbility('ConFat')) return EENT_HUMAN;
	if(actor.HasAbility('ConPudzian')) return EENT_HUMAN;
	if(actor.HasAbility('ConWitcher')) return EENT_HUMAN;
	if(actor.HasAbility('ConImmortal')) return EENT_HUMAN;

	if(actor.HasAbility('mon_evil_dog_lvl12')) return EENT_DOG;
	if(actor.HasAbility('wild_dog_lvl9')) return EENT_DOG;
	if(actor.HasAbility('mon_evil_dog')) return EENT_DOG;
	if(actor.HasAbility('mon_wolf')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_summon')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_summon_were')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_alpha')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_alpha_weak')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_white')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_base')) return EENT_WOLF;

	if(actor.HasAbility('animal_rat_base')) return EENT_ANIMAL;
	if(actor.HasAbility('animal_default_animal')) return EENT_ANIMAL;

	return EENT_GENERIC;
}

function GetExpByEnemyType( et : EEnemyType ) : int
{
	var NO_EXP : int = 0;
	var MIN_EXP : int = 1;		//2 types
	var SMALL_EXP : int = 5;	//20 types
	var MEDIUM_EXP : int = 10;	//18 types
	var BIG_EXP : int = 15;		//9 types
	var BOSS_EXP : int = 20;

	switch(et)
	{
		case EENT_BOSS:
			return BOSS_EXP;
		//BASE:
		case EENT_HUMAN:
			return SMALL_EXP;
		case EENT_DOG:
			return MIN_EXP;
		case EENT_WOLF:
			return MIN_EXP;
		case EENT_BEAR:
			return SMALL_EXP;
		case EENT_BEAR_BERSERKER:
			return MEDIUM_EXP;
		case EENT_ENDRIAGA_WORKER:
			return SMALL_EXP;
		case EENT_ENDRIAGA_SOLDIER:
			return MEDIUM_EXP;
		case EENT_ENDRIAGA_TRUTEN:
			return MEDIUM_EXP;
		case EENT_FUGAS:
			return MEDIUM_EXP;
		case EENT_GARGOYLE:
			return MEDIUM_EXP;
		case EENT_ARACHAS:
			return BIG_EXP;
		case EENT_ARACHAS_ARMORED:
			return BIG_EXP;
		case EENT_ARACHAS_POISON:
			return BIG_EXP;
		case EENT_WEREWOLF:
			return MEDIUM_EXP;
		case EENT_KATAKAN:
			return MEDIUM_EXP;
		case EENT_EKIMMA:
			return MEDIUM_EXP;
		case EENT_TROLL_ICE:
			return MEDIUM_EXP;
		case EENT_TROLL:
			return MEDIUM_EXP;
		case EENT_GOLEM:
			return BIG_EXP;
		case EENT_ELEMENTAL:
			return BIG_EXP;
		case EENT_ELEMENTAL_FIRE:
			return BIG_EXP;
		case EENT_ELEMENTAL_ICE:
			return BIG_EXP;
		case EENT_BIES:
			return BIG_EXP;
		case EENT_CZART:
			return BIG_EXP;
		case EENT_CYCLOPS:
			return MEDIUM_EXP;
		case EENT_SIREN:
			return SMALL_EXP;
		case EENT_HARPY:
			return SMALL_EXP;
		case EENT_ERYNIA:
			return SMALL_EXP;
		case EENT_WRAITH:
			return SMALL_EXP;
		case EENT_NIGHTWRAITH:
			return MEDIUM_EXP;
		case EENT_NOONWRAITH:
			return MEDIUM_EXP;
		case EENT_NEKKER:
			return SMALL_EXP;
		case EENT_DROWNER:
			return SMALL_EXP;
		case EENT_ROTFIEND:
			return SMALL_EXP;
		case EENT_ALGHOUL:
			return SMALL_EXP;
		case EENT_GHOUL:
			return SMALL_EXP;
		case EENT_WILD_HUNT_MINION:
			return SMALL_EXP;
		case EENT_GRYPHON:
			return MEDIUM_EXP;
		case EENT_BASILISK:
			return MEDIUM_EXP;
		case EENT_COCKATRICE:
			return MEDIUM_EXP;
		case EENT_LESSOG:
			return BIG_EXP;
		case EENT_WYVERN:
			return SMALL_EXP;
		case EENT_FORKTAIL:
			return MEDIUM_EXP;
		case EENT_GRAVEHAG:
			return MEDIUM_EXP;
		case EENT_FOGLING:
			return SMALL_EXP;
		case EENT_WATERHAG:
			return SMALL_EXP;
		case EENT_WILD_HUNT_WARRIOR:
			return SMALL_EXP;
		//EP1:
		case EENT_BOAR:
			return SMALL_EXP;
		case EENT_BLACK_SPIDER:
			return SMALL_EXP;
		//EP2:
		case EENT_SHARLEY:
			return BIG_EXP;
		case EENT_BRUXA:
			return MEDIUM_EXP;
		case EENT_ALP:
			return MEDIUM_EXP;
		case EENT_DRACOLIZARD:
			return MEDIUM_EXP;
		case EENT_BARGHEST:
			return SMALL_EXP;
		case EENT_KIKIMORA_WORKER:
			return SMALL_EXP;
		case EENT_KIKIMORA_WARRIOR:
			return MEDIUM_EXP;
		case EENT_SCOLOPENDROMORPH:
			return MEDIUM_EXP;
		case EENT_ARCHESPOR:
			return SMALL_EXP;
		case EENT_SPRIGAN:
			return BIG_EXP;
		case EENT_WIGHT:
			return BIG_EXP;
		case EENT_GRAVIER:
			return MEDIUM_EXP;
		case EENT_NIGHTWRAITH_BANSHEE:
			return MEDIUM_EXP;
		case EENT_FLEDER:
			return MEDIUM_EXP;
		case EENT_PROTOFLEDER:
			return MEDIUM_EXP;
		case EENT_GARKAIN:
			return MEDIUM_EXP;
		case EENT_PANTHER:
			return SMALL_EXP;
		//no exp for unidentified creatures and animals
		case EENT_GENERIC:
		case EENT_ANIMAL:
		default:
			return NO_EXP;
	}
}

function GetLocStringByEnemyType( et : EEnemyType ) : string
{
	switch(et)
	{
		case EENT_HUMAN:
			return GetLocStringByKey("gm_kills_humans");
		case EENT_WILD_HUNT_WARRIOR:
			return GetLocStringByKey("gm_kills_wh_warriors");
		case EENT_WILD_HUNT_MINION:
			return GetLocStringById(1077934);		//Hounds of the Wild Hunt
		case EENT_DOG:
			return GetLocStringById(1077512);		//Dogs
		case EENT_WOLF:
			return GetLocStringById(1077510);		//Wolves
		case EENT_BEAR:
			return GetLocStringById(1077511);		//Bears
		case EENT_BEAR_BERSERKER:
			return GetLocStringById(1077471);		//Berserkers
		case EENT_ENDRIAGA_WORKER:
			return GetLocStringById(1077475);		//Endrega workers
		case EENT_ENDRIAGA_SOLDIER:
			return GetLocStringById(339456);		//Endrega warriors
		case EENT_ENDRIAGA_TRUTEN:
			return GetLocStringById(1077474);		//Endrega drones
		case EENT_FUGAS:
			return GetLocStringById(1077882);		//Sylvans
		case EENT_GARGOYLE:
			return GetLocStringById(1082623);		//Gargoyles
		case EENT_ARACHAS:
			return GetLocStringById(1077760);		//Arachasae
		case EENT_ARACHAS_ARMORED:
			return GetLocStringById(1077472);		//Armored Arachasae
		case EENT_ARACHAS_POISON:
			return GetLocStringById(1077473);		//Venomous arachasae
		case EENT_WEREWOLF:
			return GetLocStringById(593528);		//Werewolves
		case EENT_KATAKAN:
			return GetLocStringById(354496);		//Katakans
		case EENT_EKIMMA:
			return GetLocStringById(1077304);		//Ekimmaras
		case EENT_TROLL_ICE:
			return GetLocStringById(1077498);		//Ice trolls
		case EENT_TROLL:
			return GetLocStringById(1077612);		//Rock trolls
		case EENT_GOLEM:
			return GetLocStringById(339451);		//Golems
		case EENT_ELEMENTAL:
			return GetLocStringById(354371);		//Earth Elementals
		case EENT_ELEMENTAL_FIRE:
			return GetLocStringById(1077469);		//Fire Elementals
		case EENT_ELEMENTAL_ICE:
			return GetLocStringById(1077468);		//Ice Elementals
		case EENT_BIES:
			return GetLocStringById(1077880);		//Fiends
		case EENT_CZART:
			return GetLocStringById(1077881);		//Chorts
		case EENT_CYCLOPS:
			return GetLocStringById(1077494);		//Cyclopses
		case EENT_SIREN:
			return GetLocStringById(1077508);		//Sirens
		case EENT_HARPY:
			return GetLocStringById(1077506);		//Harpies
		case EENT_ERYNIA:
			return GetLocStringById(1077504);		//Erynias
		case EENT_WRAITH:
			return GetLocStringById(1077489);		//Wraiths
		case EENT_NIGHTWRAITH:
			return GetLocStringById(397223);		//Nightwraiths
		case EENT_NOONWRAITH:
			return GetLocStringById(354483);		//Noonwraiths
		case EENT_NEKKER:
			return GetLocStringById(1077497);		//Nekkers
		case EENT_DROWNER:
			return GetLocStringById(1077480);		//Drowners
		case EENT_ROTFIEND:
			return GetLocStringById(1077608);		//Rotfiends
		case EENT_ALGHOUL:
			return GetLocStringById(339457);		//Alghouls
		case EENT_GHOUL:
			return GetLocStringById(548214);		//Ghouls
		case EENT_GRYPHON:
			return GetLocStringById(1077505);		//Griffins
		case EENT_BASILISK:
			return GetLocStringById(339458);		//Basilisks
		case EENT_COCKATRICE:
			return GetLocStringById(354425);		//Cockatrices
		case EENT_LESSOG:
			return GetLocStringById(1077879);		//Leshens
		case EENT_WYVERN:
			return GetLocStringById(1077487);		//Wyverns
		case EENT_FORKTAIL:
			return GetLocStringById(1077488);		//Forktails
		case EENT_GRAVEHAG:
			return GetLocStringById(1077483);		//Grave hags
		case EENT_FOGLING:
			return GetLocStringById(1077481);		//Foglets
		case EENT_WATERHAG:
			return GetLocStringById(1077484);		//Water hags
		//EP1:
		case EENT_BOAR:
			return GetLocStringById(1139394);		//Wild Boars
			return GetLocStringById(1214837);		//Wild Boars
		case EENT_BLACK_SPIDER:
			return GetLocStringById(1139683);		//Arachnomorph
			return GetLocStringById(1214635);		//Arachnomorph
		//EP2:
		case EENT_SHARLEY:
			return GetLocStringById(1203524);		//Shaelmaars
		case EENT_BRUXA:
			return GetLocStringById(1188873);		//Bruxae
		case EENT_ALP:
			return GetLocStringById(1208707);		//Alps
		case EENT_DRACOLIZARD:
			return GetLocStringById(1201766);		//Slyzards
		case EENT_BARGHEST:
			return GetLocStringById(1208635);		//Barghests
		case EENT_KIKIMORA_WORKER:
			return GetLocStringById(1208686);		//Kikimore Workers
		case EENT_KIKIMORA_WARRIOR:
			return GetLocStringById(1208683);		//Kikimore Warrior
		case EENT_SCOLOPENDROMORPH:
			return GetLocStringById(1203529);		//Giant Centipedes
		case EENT_ARCHESPOR:
			return GetLocStringById(1208713);		//Archespores
		case EENT_SPRIGAN:
			return GetLocStringById(1170003);		//Spriggans
		case EENT_WIGHT:
			return GetLocStringById(1207197);		//Wights
		case EENT_GRAVIER:
			return GetLocStringById(1190589);		//Scurvers
		case EENT_NIGHTWRAITH_BANSHEE:
			return GetLocStringById(1213774);		//Beann'shies
		case EENT_FLEDER:
			return GetLocStringById(1208893);		//Fleders
		case EENT_PROTOFLEDER:
			return GetLocStringById(1206787);		//Protofleders
		case EENT_GARKAIN:
			return GetLocStringById(1176357);		//Garkains
		case EENT_PANTHER:
			return GetLocStringById(1208643);		//Panthers
		case EENT_BOSS:
		case EENT_GENERIC:
		case EENT_ANIMAL:
		default:
			return "";
	}
	/*
			return 1077509;		//Succubi
			return 1078140;		//Godlings
			return 1082146;		//Doppler
	*/
}
