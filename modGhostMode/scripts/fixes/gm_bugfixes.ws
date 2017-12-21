exec function fixquestitems()
{
	FixQuestItems();
}

function FixQuestItems()
{
	var journalManager : CWitcherJournalManager;
	var mapManager : CCommonMapManager;
	var journalEntry : CJournalBase;
	var entryStatus : EJournalStatus;
	var playerInv : CInventoryComponent;
	var questItems : array<SItemUniqueId>;
	var itemIdx : int;
	var itemName : name;
	
	playerInv = thePlayer.GetInventory();
	questItems = playerInv.GetItemsByTag( 'Quest' );
	if( questItems.Size() < 1 )
		return;
	journalManager = theGame.GetJournalManager();
	mapManager = theGame.GetCommonMapManager();

	for( itemIdx = 0; itemIdx < questItems.Size(); itemIdx += 1 )
	{
		itemName = playerInv.GetItemName( questItems[itemIdx] );
		LogChannel('modSigns', "Quest item: " + itemName);
		journalEntry = NULL;
		switch( itemName )
		{
		//keys: reset tag by map pin status
		case 'lw_gr29_cage_key':
			if( mapManager.IsEntityMapPinDisabled( 'nml_mp_gr29' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'lw_sk41_prison_key':
			if( mapManager.IsEntityMapPinDisabled( 'sk41_mp_skellige' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'lw_sk90_cage_key':
			if( mapManager.IsEntityMapPinDisabled( 'sk90_mp_skl' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'poi_bar_a_10_key':
			if( mapManager.IsEntityMapPinDisabled( 'poi_bar_a_10_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//non quest related notes: reset by map pin status
		case 'poi_gor_d_06_note04':
			if( mapManager.IsEntityMapPinDisabled( 'poi_gor_d_06_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'ep1_poi_12_note_b':
			if( mapManager.IsEntityMapPinDisabled( 'ep1_poi12_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//unconditional reset: not used as actual quest item
		case 'camm_trophy':
		case 'q702_vampire_mask':
		case 'q704_vampire_mask':
		case 'sq701_item_wearable_feather':
			playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//quest based reset
		case 'Only Geralt mandragora mask':
			journalEntry = journalManager.GetEntryByString( "Q703 Art 6C2340E8-4E58E618-BF93D5A9-E8E5CB29" );
			break;
		case 'Beauclair Casual Suit 01':
		case 'Beauclair Casual Suit with medal':
		case 'Beauclair Casual Pants 01':
		case 'Beauclair casual shoes 01':
		case 'q705_medal':
		case 'q704_orianas_vampire_key':
			journalEntry = journalManager.GetEntryByString( "Q705 Ceremony 75B389CC-4F5043B3-9CC508A2-88F82183" );
			break;
		case 'q702_wicht_key':
			journalEntry = journalManager.GetEntryByString( "Q702 Reverb Mixture 1" );
			break;
		case 'th700_vault_journal':
			journalEntry = journalManager.GetEntryByString( "th700 Preacher bones 3D231EB3-445C3C97-0F6411B8-6A511BA6" );
			break;
		case 'th700_prison_journal':
		case 'th700_chapel_journal':
		case 'th700_crypt_journal':
		case 'th700_lake_journal':
			journalEntry = journalManager.GetEntryByString( "th700_red_wolf D0589E62-4A43EF34-AF11C692-E0E0D72C" );
			break;
		case 'th701_coward_journal':
		case 'th701_portal_crystal':
			journalEntry = journalManager.GetEntryByString( "th701_wolf_gear 6DBE2D54-4A4E2066-CAC1ABB6-97CB905B" );
			break;
		case 'mh701_usable_lure':
			journalEntry = journalManager.GetEntryByString( "mh701_tectonic_terror 32486D3E-469FB6BB-9FB1D18B-88046F5A" );
			break;
		case 'mq7002_love_letter_01':
		case 'mq7002_love_letter_02':
			journalEntry = journalManager.GetEntryByString( "mq7002 Stubborn Knight C9725EB0-42EB7261-0E491ABB-D0BC09B4" );
			break;
		case 'mq7007_elven_mask':
		case 'mq7007_elven_shield':
			journalEntry = journalManager.GetEntryByString( "mq7007_gargoyles" );
			break;
		case 'Flowers':
		case 'Perfume':
			journalEntry = journalManager.GetEntryByString( "mq7011 Where's My Money" );
			break;
		case 'sq701_victory_laurels':
			journalEntry = journalManager.GetEntryByString( "sq701_tournament" );
			break;
		case 'sq703_accountance_book':
		case 'sq703_hunter_letter':
		case 'sq703_map_alternative':
		case 'sq703_wife_letter': //WBC
			journalEntry = journalManager.GetEntryByString( "sq703_wine_wars 39087354-4BBDC2C0-3D0942B3-0230FD61" );
			break;
		case 'poi_gor_a_10_note':
			journalEntry = journalManager.GetEntryByString( "gor_a_10 0BBCBACE-4099237B-24A55B88-77B4A861" );
			break;
		case 'poi_car_b_10_note_02':
			journalEntry = journalManager.GetEntryByString( "car_b_10 BA4BC5BD-4B52F387-D2C251B6-6873EAF9" );
			break;
		case 'poi_ww_ver_10_note':
			journalEntry = journalManager.GetEntryByString( "ww_vermentino" );
			break;
		case 'mq6004_lab_key':
			journalEntry = journalManager.GetEntryByString( "mq6004_broken_rose B89DD723-4BD41D61-01BB70B8-849A3C8C" );
			break;
		case 'q504_fish':
			journalEntry = journalManager.GetEntryByString( "Q504 Ciri Empress E8D3E37E-443DA208-F6407683-AA607416" );
			break;
		case 'Potestaquisitor':
			journalEntry = journalManager.GetEntryByString( "Q401 Megascope 0BF1484F-4FAE6703-2880A4B3-C08F7F5C" );
			break;
		case 'Trial Potion Kit':
		case 'q401_forktail_brain':
			journalEntry = journalManager.GetEntryByString( "Q401 The Curse F4D14B2F-43C39290-E76256A6-9BB706B9" );
			break;
		case 'q301_burdock':
			journalEntry = journalManager.GetEntryByString( "Q301 Find Dreamer D2C182B4-449540BC-CCB326B2-4FD786E7" );
			break;
		case 'q309_key_orders':
		case 'q309_key_letters':
			journalEntry = journalManager.GetEntryByString( "Q309 Novigrad Under Control" );
			break;
		case 'q310_wine':
			journalEntry = journalManager.GetEntryByString( "Q210 Preparations 3FFACA7E-489A30A5-824E4887-21A507DE" );
			break;
		case 'q206_herb_mixture':
		case 'q206_arnvalds_letter':
			journalEntry = journalManager.GetEntryByString( "Q206 Berserkers B5130AE1-468A2171-0B7BD3B0-3FBE5499" );
			break;
		case 'q111_fugas_top_key':
			journalEntry = journalManager.GetEntryByString( "Q111 Imlerith" );
			break;
		case 'q106_magic_oillamp':
			journalEntry = journalManager.GetEntryByString( "Q106 Tower 38E268CF-431777D8-0A106B87-22F7BA0D" );
			break;
		case 'mq1002_artifact_1':
		case 'mq1002_artifact_2':
		case 'mq1002_artifact_3':
			journalEntry = journalManager.GetEntryByString( "mq1002 Rezydencja B85F69B4-4563B896-339733A6-9223A984" );
			break;
		case 'sq305_trophies':
			journalEntry = journalManager.GetEntryByString( "SQ305 Scoiatael 6AFAFC3C-47D50499-6D21D3A7-0D30C14D" );
			break;
		case 'sq303_robbery_speech':
			journalEntry = journalManager.GetEntryByString( "SQ303 Brothel 1DBEC8F9-4023BB3B-23EB70A1-52D14101" );
			break;
		case 'sq201_ship_manifesto':
		case 'sq201_cursed_jewel':
		case 'sq201_werewolf_meat':
		case 'sq201_padlock_key':
			journalEntry = journalManager.GetEntryByString( "SQ201 Curse FE437B83-49995725-39F6089A-D2A87C27" );
			break;
		case 'sq205_brewing_instructions':
		case 'sq205_brewmasters_log':
			journalEntry = journalManager.GetEntryByString( "SQ205 Alchemist 52DCBB5B-433C44F6-FC2578A2-49BB8D86" );
			break;
		case 'sq104_notes':
			journalEntry = journalManager.GetEntryByString( "SQ104 Werewolf 15CBFA78-4DA5D1B1-FC623EAD-9F73CE73" );
			break;
		case 'q302_crafter_notes':
			journalEntry = journalManager.GetEntryByString( "Q302 Mafia 5E9E0041-463E3ECD-C72D1B98-5CF5D6C6" );
			break;
		case 'q303_bomb_fragment':
		case 'q303_bomb_cap':
		case 'q303_contact_note':
			journalEntry = journalManager.GetEntryByString( "Q303 Treasure 0292F065-4622C52C-4B7C3492-C7B3FA8E" );
			break;
		case 'q308_sermon_1':
		case 'q308_sermon_2':
		case 'q308_sermon_3':
		case 'q308_sermon_4':
		case 'q308_sermon_5':
		case 'q308_nathanel_sermon_1': //WBC
			journalEntry = journalManager.GetEntryByString( "Q308 Psycho 6EDC27E1-46D57C09-1828A6AE-2E6C46D8" );
			break;
		case 'q310_lever':
			journalEntry = journalManager.GetEntryByString( "Q310 Prison Break 5B858684-4A646E08-258AF3AD-635E235B" );
			break;
		case 'q309_mssg_from_triss':
		case 'q309_witch_hunters_orders': //WBC
			journalEntry = journalManager.GetEntryByString( "Q309 Casablanca 06950C40-442252DF-03C66981-3FD2B4F3" );
			break;
		case 'q202_hjalmar_cell_key':
			journalEntry = journalManager.GetEntryByString( "Q202 Ice Giant" );
			break;
		case 'Geralt mask 01':
		case 'Geralt mask 02':
		case 'Geralt mask 03':
			journalEntry = journalManager.GetEntryByString( "SQ301 Triss DF5C1032-43CFD052-056742B1-5E8C57B0" );
			break;
		case 'sq302_agates':
			journalEntry = journalManager.GetEntryByString( "SQ302 Philippa 9D3E34EB-4DB8F4BA-4B1C649B-7B7BBAA5" );
			break;
		case 'sq204_wolf_heart':
			journalEntry = journalManager.GetEntryByString( "SQ204 Forest Spirit ADF1F1F0-41C5D27D-3397258A-2893B653" );
			break;
		case 'th1009_journal_wolf_part4':
			journalEntry = journalManager.GetEntryByString( "Wolf Set ECDA507B-4902A54F-85D7CAA9-E26BF51C" );
			break;
		case 'mq1055_letters':
			journalEntry = journalManager.GetEntryByString( "mq1055_nilfgaard_mom BCBB27C8-4FA7E374-3CC1408F-8CD2AC77" );
			break;
		case 'mq4002_note':
			journalEntry = journalManager.GetEntryByString( "mq4002_anomaly" );
			break;
		case 'mq4005_note_1':
			journalEntry = journalManager.GetEntryByString( "mq4005_sword" );
			break;
		case 'mq4006_book':
			journalEntry = journalManager.GetEntryByString( "mq4006_armor" );
			break;
		case 'mq2001_journal_2b':
			journalEntry = journalManager.GetEntryByString( "mq2001 Kuilu BF18DA51-48A12FC9-7FC49692-3E4593EB" );
			break;
		case 'mq2020_slave_cells_key':
			journalEntry = journalManager.GetEntryByString( "mq2020 Flesh for cash buisness 75CE5700-4B1F1BBE-069237AE-6D20CA0F" );
			break;
		case 'mq2015_kurisus_note':
			journalEntry = journalManager.GetEntryByString( "mq2015 Long Time Apart 62611322-4F5B1005-3765EA81-5D229FB0" );
			break;
		case 'mq0004_thalers_monocle':
		case 'mq0004_thalers_monocle_wearable':
			journalEntry = journalManager.GetEntryByString( "MQ0004 Locked Shed F7C2C616-4FBFA7E7-3A37FBA1-0FB8CFC8" );
			break;
		case 'mh305_doppler_letter':
			journalEntry = journalManager.GetEntryByString( "Novigrad Hunt : Doppler D713995F-4D748EC3-F8C29892-A5309EB8" );
			break;
		case 'mh207_lighthouse_keeper_letter':
			journalEntry = journalManager.GetEntryByString( "mh207: Wraith F8815175-4F992A27-45F5F19C-7706FA95" );
			break;
		case 'cg100_barons_notes':
			journalEntry = journalManager.GetEntryByString( "CG : No Man's Land BECB3BA0-4C293A48-C3C229B6-31A1439A" );
			break;
		case 'cg700_letter_monniers_brother':
		case 'cg700_letter_merchants':
		case 'cg700_letter_purist':
			journalEntry = journalManager.GetEntryByString( "cg700_tournament DBBF356D-4FFC9CC0-29404AAF-D6208B48" );
			break;
		default:
			break;
		}
		if( journalEntry )
		{
			entryStatus = journalManager.GetEntryStatus(journalEntry);
			if( entryStatus == JS_Success || entryStatus == JS_Failed )
			{
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
				playerInv.RemoveItemTag( questItems[itemIdx], 'NoDrop' );
			}
		}
	}
}

function SQ102Finished() : bool
{
	var journalManager : CWitcherJournalManager;
	var journalEntry : CJournalBase;
	var entryStatus : EJournalStatus;

	journalManager = theGame.GetJournalManager();
	journalEntry = journalManager.GetEntryByString( "SQ102 Letho 4614B8BA-49B427F1-8D5B8F96-AB94FBF6" );
	entryStatus = journalManager.GetEntryStatus( journalEntry );
	if( entryStatus == JS_Success || entryStatus == JS_Failed )
	{
		return true;
	}
	return false;
}

function FamilyIssuesAutosave( questEntry : CJournalQuest )
{
	var i, j : int;
	var questPhase : CJournalQuestPhase;
	var objective : CJournalQuestObjective;
	var objectiveStatus : EJournalStatus;
	var journalManager : CWitcherJournalManager;
	var objectiveTag : string;
	
	if( NameToString(questEntry.GetUniqueScriptTag()) == "Q103 Family Issues DB024D36-4E9AE35E-FB098D89-C8E7AB0F" )
	{
		//theGame.witcherLog.AddMessage("Q103 Family Issues");
		journalManager = theGame.GetJournalManager();
		for( i = 0; i < questEntry.GetNumChildren(); i += 1 )
		{
			questPhase = (CJournalQuestPhase)questEntry.GetChild(i);
			if( questPhase )
			{				
				for( j = 0; j < questPhase.GetNumChildren(); j += 1 )
				{
					objective = (CJournalQuestObjective)questPhase.GetChild(j);
					objectiveStatus = journalManager.GetEntryStatus( objective );
					objectiveTag = NameToString(objective.GetUniqueScriptTag());
					if( objectiveStatus == JS_Active )
					{
						//theGame.witcherLog.AddMessage("Objective tag = " + objectiveTag);
						if( objectiveTag == "Protect Baron from wraiths" || objectiveTag == "Protect Baron from wraiths once more" )
						{
							//theGame.witcherLog.AddMessage("Checkpoint saved");
							theGame.SaveGame( SGT_CheckPoint, -1 );
						}
					}
				}
			}
		}
	}
}

function LazyArmorFix( npc : CNewNPC )
{
	var template : CEntityTemplate;
	var size, i : int;
	var armorAbility : name;
	
	if(!npc.IsHuman() || HasArmorAbility(npc))
		return;
	
	template = (CEntityTemplate)LoadResource( npc.GetReadableName(), true );
	size = template.includes.Size();
	if(size > 0)
	{
		for(i = 0; i < size; i += 1)
		{
			armorAbility = GetArmorAbilityFromPath(template.includes[i].GetPath());
			if(armorAbility != 'none' && !npc.HasAbility(armorAbility))
			{
				npc.AddAbility(armorAbility);
				break;
			}
		}
	}
	
}

function HasArmorAbility( npc : CNewNPC ) : bool
{
	return (npc.HasAbility('NPC Leather Armor') || npc.HasAbility('NPC Heavy Leather Armor') ||
			npc.HasAbility('NPC Chainmail Armor') || npc.HasAbility('NPC Partial Plate Armor') ||
			npc.HasAbility('NPC Full Plate Armor') || npc.HasAbility('NPC_Wild_Hunt_Armor'));
}

function GetArmorAbilityFromPath( path : string ) : name
{
	if(StrEndsWith(path, "npc_armor_lvl1.w2ent")) return 'NPC Leather Armor';
	if(StrEndsWith(path, "npc_armor_lvl2.w2ent")) return 'NPC Heavy Leather Armor';
	if(StrEndsWith(path, "npc_armor_lvl3.w2ent")) return 'NPC Chainmail Armor';
	if(StrEndsWith(path, "npc_armor_lvl4.w2ent")) return 'NPC Partial Plate Armor';
	if(StrEndsWith(path, "npc_armor_lvl5.w2ent")) return 'NPC Full Plate Armor';
	if(StrEndsWith(path, "npc_armor_lvl6_wild_hunt.w2ent")) return 'NPC_Wild_Hunt_Armor';
	return 'none';
}

function IsAtLWGR13( actor : CActor ) : bool
{
	var mapManager : CCommonMapManager;
	var entityMapPins : array< SEntityMapPinInfo >;
	var i : int;
	
	mapManager = theGame.GetCommonMapManager();
	
	if( mapManager.GetCurrentArea() != AN_NMLandNovigrad )
		return false;
	
	entityMapPins = mapManager.GetEntityMapPins( mapManager.GetWorldPathFromAreaType( AN_NMLandNovigrad ) );
	
	for( i = 0; i < entityMapPins.Size(); i += 1 )
	{
		if( entityMapPins[i].entityName == 'nml_mp_gr13' && VecDistanceSquared( entityMapPins[i].entityPosition, actor.GetWorldPosition() ) <= 2500 )
		{
			//theGame.witcherLog.AddMessage("At lw gr 13!");
			return true;
		}
	}
	
	return false;
}