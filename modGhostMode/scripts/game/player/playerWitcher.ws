/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




statemachine class W3PlayerWitcher extends CR4Player
{	
	
	private saved var craftingSchematics				: array<name>; 					
	private saved var expandedCraftingCategories		: array<name>;
	private saved var craftingFilters : SCraftingFilters;
	
	
	private saved var alchemyRecipes 					: array<name>; 					
	private saved var expandedAlchemyCategories			: array<name>;
	private saved var alchemyFilters : SCraftingFilters;
	
	
	private saved var expandedBestiaryCategories		: array<name>;
	
	
	private saved var booksRead 						: array<name>; 					
	
	private saved var enemiesKilledByType				: array<int>; //modSigns
	
	
	private 			var fastAttackCounter, heavyAttackCounter	: int;		
	private				var isInFrenzy : bool;
	//private				var hasRecentlyCountered : bool; //modSigns
	//private saved 		var cannotUseUndyingSkill : bool; //modSigns
	
	
	protected saved			var amountOfSetPiecesEquipped			: array<int>;
	
	
	public				var canSwitchFocusModeTarget	: bool;
	protected			var switchFocusModeTargetAllowed : bool;
		default canSwitchFocusModeTarget = true;
		default switchFocusModeTargetAllowed = true;
	
	
	private editable	var signs						: array< SWitcherSign >;
	private	saved		var equippedSign				: ESignType;
	private				var currentlyCastSign			: ESignType; default currentlyCastSign = ST_None;
	private				var signOwner					: W3SignOwnerPlayer;
	private				var usedQuenInCombat			: bool;
	public				var yrdenEntities				: array<W3YrdenEntity>;
	public saved		var m_quenReappliedCount		: int;
	
	default				equippedSign	= ST_Aard;
	default				m_quenReappliedCount = 1;
	
	
	
	private 			var bDispalyHeavyAttackIndicator 		: bool; 
	private 			var bDisplayHeavyAttackFirstLevelTimer 	: bool; 
	public	 			var specialAttackHeavyAllowed 			: bool;	

	default bIsCombatActionAllowed = true;	
	default bDispalyHeavyAttackIndicator = false; 
	default bDisplayHeavyAttackFirstLevelTimer = true; 
	
	
	
		default explorationInputContext = 'Exploration';
		default combatInputContext = 'Combat';
		default combatFistsInputContext = 'Combat';
		
	
	private saved var companionNPCTag		: name;
	private saved var companionNPCTag2		: name;
	
	private saved var companionNPCIconPath	: string;
	private saved var companionNPCIconPath2	: string;	
		
	
	private 	  saved	var itemSlots					: array<SItemUniqueId>;
	private 			var remainingBombThrowDelaySlot1	: float;
	private 			var remainingBombThrowDelaySlot2	: float;
	private 			var previouslyUsedBolt : SItemUniqueId;				
	private		  saved var questMarkedSelectedQuickslotItems : array< SSelectedQuickslotItem >;
	
	default isThrowingItem = false;
	default remainingBombThrowDelaySlot1 = 0.f;
	default remainingBombThrowDelaySlot2 = 0.f;
	
	
	
	
	
	private saved var tempLearnedSignSkills : array<SSimpleSkill>;		
	public	saved var autoLevel				: bool;						
	
	
	
	
	protected saved var skillBonusPotionEffect			: CBaseGameplayEffect;			
	
	
	public saved 		var levelManager 				: W3LevelManager;

	
	saved var reputationManager	: W3Reputation;
	
	
	private editable	var medallionEntity			: CEntityTemplate;
	private				var medallionController		: W3MedallionController;
	
	
	
	
	public 				var bShowRadialMenu	: bool;	

	private 			var _HoldBeforeOpenRadialMenuTime : float;
	
	default _HoldBeforeOpenRadialMenuTime = 0.5f;
	
	public var MappinToHighlight : array<SHighlightMappin>;
	
	
	protected saved	var horseManagerHandle			: EntityHandle;		
	

	private var isInitialized : bool;
	private var timeForPerk21 : float;
	
		default isInitialized = false;
		
	
	private var invUpdateTransaction : bool;
		default invUpdateTransaction = false;
	
	
	
	
	
	
	
	
	
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var i 				: int;
		var items 			: array<SItemUniqueId>;
		var items2 			: array<SItemUniqueId>;
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;
		
		AddAnimEventCallback( 'ActionBlend', 			'OnAnimEvent_ActionBlend' );
		AddAnimEventCallback('cast_begin',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_throw',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_end',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_begin',		'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_throw',		'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_ready',				'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_alternate_ready',	'OnAnimEvent_Sign');
		AddAnimEventCallback('yrden_draw_ready',		'OnAnimEvent_Sign');
		
		AddAnimEventCallback( 'ProjectileThrow',	'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'OnWeaponReload',		'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'ProjectileAttach',	'OnAnimEvent_Throwable' );
		AddAnimEventCallback( 'Mutation11AnimEnd',	'OnAnimEvent_Mutation11AnimEnd' );
		AddAnimEventCallback( 'Mutation11ShockWave', 'OnAnimEvent_Mutation11ShockWave' );
		

		
		amountOfSetPiecesEquipped.Resize( EnumGetMax( 'EItemSetType' ) + 1 );
		
		runewordInfusionType = ST_None;
				
		
		inv = GetInventory();			

		
		signOwner = new W3SignOwnerPlayer in this;
		signOwner.Init( this );
		
		itemSlots.Resize( EnumGetMax('EEquipmentSlots')+1 );

		//modSigns
		if( FactsQuerySum("ModSignsRecipesAdded") < 1 )
		{
			AddAlchemyRecipe('Recipe for Tawny Owl 1', true, true); // fix missing Tawny Owl recipe
			AddCraftingSchematic('Meteorite plate schematic', true, true); //add missing meteorite plate schematic
			FactsAdd("ModSignsRecipesAdded");
		}
		
		FactsRemove("player_had_quen"); //remove, no need for this and never was
		
		//modSigns
		if( FactsQuerySum("ModSignsKMSetSchematicsAdded") < 1 )
		{
			AddCraftingSchematic('Kaer Morhen Armor 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Armor 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Armor 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 3 schematic',true, true);
			FactsAdd("ModSignsKMSetSchematicsAdded");
		}
		
		if(!spawnData.restored)
		{
			levelManager = new W3LevelManager in this;			
			levelManager.Initialize();
			
			
			inv.GetAllItems(items);
			for(i=0; i<items.Size(); i+=1)
			{
				if(inv.IsItemMounted(items[i]) && ( !inv.IsItemBody(items[i]) || inv.GetItemCategory(items[i]) == 'hair' ) )
					EquipItem(items[i]);
			}
			
			
			
			
			
			AddAlchemyRecipe('Recipe for Swallow 1',true,true);
			AddAlchemyRecipe('Recipe for Cat 1',true,true);
			AddAlchemyRecipe('Recipe for White Honey 1',true,true);
			
			AddAlchemyRecipe('Recipe for Samum 1',true,true);
			AddAlchemyRecipe('Recipe for Grapeshot 1',true,true);
			
			AddAlchemyRecipe('Recipe for Specter Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Necrophage Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Alcohest 1',true,true);
		}
		else
		{
			AddTimer('DelayedOnItemMount', 0.1, true);
			
			
			CheckHairItem();
		}
		
		
		AddStartingSchematics();

		super.OnSpawned( spawnData );
		
		
		AddAlchemyRecipe('Recipe for Mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Mutagen blue',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen blue',true,true);
		
		AddCraftingSchematic('Starting Armor Upgrade schematic 1',true,true);
		
		
		if( inputHandler )
		{
			inputHandler.BlockAllActions( 'being_ciri', false );
		}
		SetBehaviorVariable( 'test_ciri_replacer', 0.0f);
		
		if(!spawnData.restored)
		{
			
			abilityManager.GainStat(BCS_Toxicity, 0);		
		}		
		
		levelManager.PostInit(this, spawnData.restored, true);
		
		SetBIsCombatActionAllowed( true );		
		SetBIsInputAllowed( true, 'OnSpawned' );				
		
		
		if ( !reputationManager )
		{
			reputationManager = new W3Reputation in this;
			reputationManager.Initialize();
		}
		
		theSound.SoundParameter( "focus_aim", 1.0f, 1.0f );
		theSound.SoundParameter( "focus_distance", 0.0f, 1.0f );
		
		
		
		
			
		
		currentlyCastSign = ST_None;
		
		
		if(!spawnData.restored)
		{
			horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
			horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
			horseManager.CreateAttachment(this);
			horseManager.OnCreated();
			EntityHandleSet( horseManagerHandle, horseManager );
		}
		else
		{
			AddTimer('DelayedHorseUpdate', 0.01, true);
		}
		
		
		RemoveAbility('Ciri_CombatRegen');
		RemoveAbility('Ciri_Rage');
		RemoveAbility('CiriBlink');
		RemoveAbility('CiriCharge');
		RemoveAbility('Ciri_Q205');
		RemoveAbility('Ciri_Q305');
		RemoveAbility('Ciri_Q403');
		RemoveAbility('Ciri_Q111');
		RemoveAbility('Ciri_Q501');
		RemoveAbility('SkillCiri');
		
		//modSigns: remove passive bonuses
		RemoveAbilityAll('sword_adrenalinegain');
		RemoveAbilityAll('magic_staminaregen');
		RemoveAbilityAll('alchemy_potionduration');
		
		/*if(spawnData.restored)
		{
			RestoreQuen(savedQuenHealth, savedQuenDuration);			
		}
		else
		{
			savedQuenHealth = 0.f;
			savedQuenDuration = 0.f;
		}*/ //modSigns: removed, params aren't saved properly anyway
		savedQuenHealth = 0.f;
		savedQuenDuration = 0.f;
		
		if(spawnData.restored)
		{
			ApplyPatchFixes();
		}
		else
		{
			
			FactsAdd( "new_game_started_in_1_20" );
			
			FactsAdd( "new_game_started_with_GM_40" ); //modSigns
		}
		
		if ( spawnData.restored )
		{
			FixEquippedMutagens();
		}
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			NewGamePlusAdjustDLC1TemerianSet(inv);
			NewGamePlusAdjustDLC5NilfgardianSet(inv);
			NewGamePlusAdjustDLC10WolfSet(inv);
			NewGamePlusAdjustDLC14SkelligeSet(inv);
			if(horseManager)
			{
				NewGamePlusAdjustDLC1TemerianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC5NilfgardianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC10WolfSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC14SkelligeSet(horseManager.GetInventoryComponent());
			}
		}
		
		//modSigns: load sound banks for mutations
		((W3PlayerAbilityManager)abilityManager).LoadCurrentMutationSoundBank();
		//modSigns: load sound banks for sets
		LoadCurrentSetBonusSoundbank();
		//modSigns: add mutation trigger recipe
		if(IsMutationResearched(EPMT_Mutation11) /*|| IsMutationResearched(EPMT_Mutation12)*/)
		{
			if(!alchemyRecipes.Contains('Recipe for Mutation Trigger'))
				AddAlchemyRecipe('Recipe for Mutation Trigger', true, true);
		}
		
		
		ResumeStaminaRegen('WhirlSkill');
		ResumeStaminaRegen('RendSkill'); //modSigns
		ResumeStaminaRegen('IsPerformingFinisher'); //modSigns
		
		ResumeHPRegenEffects('FistFightMinigame'); //modSigns
		
		if(HasRunewordActive('Runeword 4 _Stats')) //modSigns
			StartVitalityRegen();
		
		if(HasAbility('sword_s19'))
		{
			RemoveTemporarySkills();
		}
		
		//HACK_UnequipWolfLiver(); //modSigns
		
		if( enemiesKilledByType.Size() == 0 )
		{
			enemiesKilledByType.Resize(EENT_MAX_TYPES);
		}
		
		
		if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
		}
		
		if( HasBuff( EET_GryphonSetBonus ) ) //modSigns: remove on spawn
		{
			RemoveBuff( EET_GryphonSetBonus );
		}
		
		if( HasBuff(EET_KaerMorhenSetBonus) ) //modSigns: remove on spawn
		{
			RemoveBuff(EET_KaerMorhenSetBonus);
		}
		
		if( HasBuff( EET_Aerondight ) ) //modSigns: remove Aerondight effect
			RemoveBuff( EET_Aerondight );
		
		if( HasBuff( EET_PhantomWeapon ) ) //modSigns: remove Iris effect
			RemoveBuff( EET_PhantomWeapon );
		
		RemoveBuff(EET_Runeword4); //modSigns
		RemoveBuff(EET_Runeword11); //modSigns
		RemoveAbilityAll('Glyphword 14 _Stats'); //modSigns
		RemoveAbilityAll('Glyphword 10 _Stats'); //modSigns
		
		//modSigns
		if( FactsQuerySum("standalone_ep1") > 0 && FactsQuerySum("standalone_ep1_inv") < 1 )
		{
			AddTimer('GiveStandAloneEP1Items', 0.00001, true, , , true);
		}
		//modSigns
		if( FactsQuerySum("standalone_ep2") > 0 && FactsQuerySum("standalone_ep2_inv") < 1 )
		{
			AddTimer('GiveStandAloneEP2Items', 0.00001, true, , , true);
		}
		
		if( spawnData.restored )
		{
			
			UpdateEncumbrance();
			
			
			RemoveBuff( EET_Mutation11Immortal );
			RemoveBuff( EET_Mutation11Buff );
			
			//modSigns:
			RemoveBuff( EET_UndyingSkillImmortal );
		}
		
		
		theGame.GameplayFactsAdd( "PlayerIsGeralt" );
		
		isInitialized = true;
	}

	
	
	
	
	private function HACK_UnequipWolfLiver()
	{
		var itemName1, itemName2, itemName3, itemName4 : name;
		var item1, item2, item3, item4 : SItemUniqueId;
		
		GetItemEquippedOnSlot( EES_Potion1, item1 );
		GetItemEquippedOnSlot( EES_Potion2, item2 );
		GetItemEquippedOnSlot( EES_Potion3, item3 );
		GetItemEquippedOnSlot( EES_Potion4, item4 );

		if ( inv.IsIdValid( item1 ) )
			itemName1 = inv.GetItemName( item1 );
		if ( inv.IsIdValid( item2 ) )
			itemName2 = inv.GetItemName( item2 );
		if ( inv.IsIdValid( item3 ) )
			itemName3 = inv.GetItemName( item3 );
		if ( inv.IsIdValid( item4 ) )
			itemName4 = inv.GetItemName( item4 );

		if ( itemName1 == 'Wolf liver' || itemName3 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item1 ) )
				UnequipItem( item1 );
			if ( inv.IsIdValid( item3 ) )
				UnequipItem( item3 );
		}
		else if ( itemName2 == 'Wolf liver' || itemName4 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item2 ) )
				UnequipItem( item2 );
			if ( inv.IsIdValid( item4 ) )
				UnequipItem( item4 );
		}
	}
	
	public function IncKills( et : EEnemyType ) //modSigns
	{
		enemiesKilledByType[et] += 1;
		//theGame.witcherLog.AddMessage(et + ": " + enemiesKilledByType[et]);
	}
	
	public function GetKills( et : EEnemyType ) : int //modSigns
	{
		return enemiesKilledByType[et];
	}
	
	public function GetExpModifierByEnemyType( et : EEnemyType ) : float //modSigns
	{
		switch(et)
		{
			case EENT_BOSS:
				return 1;
			case EENT_GENERIC:
			case EENT_ANIMAL:
				return 0;
			default:
				return 1 - MinF(100.0f, (float)GetKills(et))/100.0f;
		}
	}
	
	
	
	

	timer function DelayedHorseUpdate( dt : float, id : int )
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
		{
			if ( man.ApplyHorseUpdateOnSpawn() )
			{
				
				UpdateEncumbrance();
				
				RemoveTimer( 'DelayedHorseUpdate' );
			}
		}
	}	
	
	event OnAbilityAdded( abilityName : name)
	{
		super.OnAbilityAdded(abilityName);
		
		if( HasRunewordActive('Runeword 4 _Stats') ) //modSigns
		{
			StartVitalityRegen();
		}
			
		if ( abilityName == 'Runeword 8 _Stats' && GetStat(BCS_Focus, true) >= GetStatMax(BCS_Focus) && !HasBuff(EET_Runeword8) ) //modSigns
		{
			AddEffectDefault(EET_Runeword8, this, "equipped item");
		}

	}
	
	private final function AddStartingSchematics()
	{
		AddCraftingSchematic('Starting Armor Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Thread schematic',					true, true);
		AddCraftingSchematic('String schematic',					true, true);
		AddCraftingSchematic('Linen schematic',						true, true);
		AddCraftingSchematic('Silk schematic',						true, true);
		AddCraftingSchematic('Resin schematic',						true, true);
		AddCraftingSchematic('Blasting powder schematic',			true, true);
		AddCraftingSchematic('Haft schematic',						true, true);
		AddCraftingSchematic('Hardened timber schematic',			true, true);
		AddCraftingSchematic('Leather squares schematic',			true, true);
		AddCraftingSchematic('Leather schematic',					true, true);
		AddCraftingSchematic('Hardened leather schematic',			true, true);
		AddCraftingSchematic('Draconide leather schematic',			true, true);
		AddCraftingSchematic('Iron ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic 1',				true, true);
		AddCraftingSchematic('Steel plate schematic',				true, true);
		AddCraftingSchematic('Dark iron ingot schematic',			true, true);
		AddCraftingSchematic('Dark iron plate schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic 1',		true, true);
		AddCraftingSchematic('Dark steel plate schematic',			true, true);
		AddCraftingSchematic('Silver ore schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic 1',			true, true);
		AddCraftingSchematic('Silver plate schematic',				true, true);
		AddCraftingSchematic('Meteorite ingot schematic',			true, true);
		AddCraftingSchematic('Meteorite silver ingot schematic',	true, true);
		AddCraftingSchematic('Meteorite silver plate schematic',	true, true);
		AddCraftingSchematic('Glowing ingot schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ore schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic',			true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic 1',			true, true);
		AddCraftingSchematic('Dwimeryte plate schematic',			true, true);
		AddCraftingSchematic('Infused dust schematic',				true, true);
		AddCraftingSchematic('Infused shard schematic',				true, true);
		AddCraftingSchematic('Infused crystal schematic',			true, true);

		if ( theGame.GetDLCManager().IsEP2Available() )
		{
			AddCraftingSchematic('Draconide infused leather schematic',	true, true);
			AddCraftingSchematic('Nickel ore schematic',				true, true);
			AddCraftingSchematic('Cupronickel ore schematic',			true, true);
			AddCraftingSchematic('Copper ore schematic',				true, true);
			AddCraftingSchematic('Copper ingot schematic',				true, true);
			AddCraftingSchematic('Copper plate schematic',				true, true);
			AddCraftingSchematic('Green gold ore schematic',			true, true);
			AddCraftingSchematic('Green gold ore schematic 1',			true, true);
			AddCraftingSchematic('Green gold ingot schematic',			true, true);
			AddCraftingSchematic('Green gold plate schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic 1',			true, true);
			AddCraftingSchematic('Orichalcum ingot schematic',			true, true);
			AddCraftingSchematic('Orichalcum plate schematic',			true, true);
			AddCraftingSchematic('Dwimeryte enriched ore schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched ingot schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched plate schematic',	true, true);
		}
	}
	
	private final function ApplyPatchFixes()
	{
		var cnt, transmutationCount, mutagenCount, i, slot : int;
		var transmutationAbility, itemName : name;
		var pam : W3PlayerAbilityManager;
		var slotId : int;
		var offset : float;
		var buffs : array<CBaseGameplayEffect>;
		var mutagen : W3Mutagen_Effect;
		var skill : SSimpleSkill;
		var spentSkillPoints, swordSkillPointsSpent, alchemySkillPointsSpent, perkSkillPointsSpent, pointsToAdd : int;
		var mutagens : array< W3Mutagen_Effect >;
		
		/*if(FactsQuerySum("ClearingPotionPassiveBonusFix") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;

			cnt = GetAbilityCount('sword_adrenalinegain') - pam.GetPathPointsSpent(ESP_Sword);
			if(cnt > 0)
				RemoveAbilityMultiple('sword_adrenalinegain', cnt);
				
			cnt = GetAbilityCount('magic_staminaregen') - pam.GetPathPointsSpent(ESP_Signs);
			if(cnt > 0)
				RemoveAbilityMultiple('magic_staminaregen', cnt);
				
			cnt = GetAbilityCount('alchemy_potionduration') - pam.GetPathPointsSpent(ESP_Alchemy);
			if(cnt > 0)
				RemoveAbilityMultiple('alchemy_potionduration', cnt);
		
			FactsAdd("ClearingPotionPassiveBonusFix");
		}*/ //modSigns
				
		
		/*if(FactsQuerySum("DimeritiumSynergyFix") < 1)
		{
			slotId = GetSkillSlotID(S_Alchemy_s19);
			if(slotId != -1)
				UnequipSkill(S_Alchemy_s19);
				
			RemoveAbilityAll('greater_mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_green_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_blue_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_red_synergy_bonus');
			
			if(slotId != -1)
				EquipSkill(S_Alchemy_s19, slotId);
		
			FactsAdd("DimeritiumSynergyFix");
		}*/ //modSigns
		
		
		if(FactsQuerySum("DontShowRecipePinTut") < 1)
		{
			FactsAdd( "DontShowRecipePinTut" );
			TutorialScript('alchemyRecipePin', '');
			TutorialScript('craftingRecipePin', '');
		}
		
		
		if(FactsQuerySum("LevelReqPotGiven") < 1)
		{
			FactsAdd("LevelReqPotGiven");
			inv.AddAnItem('Wolf Hour', 1, false, false, true);
		}
		
		
		if(!HasBuff(EET_AutoStaminaRegen))
		{
			AddEffectDefault(EET_AutoStaminaRegen, this, 'autobuff', false);
		}
		
		
		
		buffs = GetBuffs();
		offset = 0;
		mutagenCount = 0;
		for(i=0; i<buffs.Size(); i+=1)
		{
			mutagen = (W3Mutagen_Effect)buffs[i];
			if(mutagen)
			{
				offset += mutagen.GetToxicityOffset();
				mutagenCount += 1;
			}
		}
		
		
		if(offset != (GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true)))
			SetToxicityOffset(offset);
			
		
		/*mutagenCount *= GetSkillLevel(S_Alchemy_s13);
		transmutationAbility = GetSkillAbilityName(S_Alchemy_s13);
		transmutationCount = GetAbilityCount(transmutationAbility);
		if(mutagenCount < transmutationCount)
		{
			RemoveAbilityMultiple(transmutationAbility, transmutationCount - mutagenCount);
		}
		else if(mutagenCount > transmutationCount)
		{
			AddAbilityMultiple(transmutationAbility, mutagenCount - transmutationCount);
		}*/ //modSigns: skill changed
		RecalcTransmutationAbilities();
		
		
		if(theGame.GetDLCManager().IsEP1Available())
		{
			theGame.GetJournalManager().ActivateEntryByScriptTag('TutorialJournalEnchanting', JS_Active);
		}

		
		if(HasAbility('sword_s19') && FactsQuerySum("Patch_Sword_s19") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;

			
			skill.level = 0;
			for(i = S_Magic_s01; i <= S_Magic_s20; i+=1)
			{
				skill.skillType = i;				
				pam.RemoveTemporarySkill(skill);
			}
			
			
			spentSkillPoints = levelManager.GetPointsUsed(ESkillPoint);
			swordSkillPointsSpent = pam.GetPathPointsSpent(ESP_Sword);
			alchemySkillPointsSpent = pam.GetPathPointsSpent(ESP_Alchemy);
			perkSkillPointsSpent = pam.GetPathPointsSpent(ESP_Perks);
			
			pointsToAdd = spentSkillPoints - swordSkillPointsSpent - alchemySkillPointsSpent - perkSkillPointsSpent;
			if(pointsToAdd > 0)
				levelManager.UnspendPoints(ESkillPoint, pointsToAdd);
			
			
			RemoveAbilityAll('sword_s19');
			
			
			FactsAdd("Patch_Sword_s19");
		}
		
		
		if( HasAbility( 'sword_s19' ) )
		{
			RemoveAbilityAll( 'sword_s19' );
		}
		
		
		//if(FactsQuerySum("Patch_Armor_Type_Glyphwords") < 1)
		//{
		//	pam = (W3PlayerAbilityManager)abilityManager;
		//	
		//	pam.SetPerkArmorBonus( S_Perk_05, this );
		//	pam.SetPerkArmorBonus( S_Perk_06, this );
		//	pam.SetPerkArmorBonus( S_Perk_07, this );
		//	
		//	FactsAdd("Patch_Armor_Type_Glyphwords");
		//}
		//else if( FactsQuerySum("154999") < 1 )
		//{
		//	
		//	pam = (W3PlayerAbilityManager)abilityManager;
		//	
		//	pam.SetPerkArmorBonus( S_Perk_05, this );
		//	pam.SetPerkArmorBonus( S_Perk_06, this );
		//	pam.SetPerkArmorBonus( S_Perk_07, this );
		//	
		//	FactsAdd("154999");
		//}
		
		if( FactsQuerySum( "Patch_Decoction_Buff_Icons" ) < 1 )
		{
			mutagens = GetMutagenBuffs();
			for( i=0; i<mutagens.Size(); i+=1 )
			{
				itemName = DecoctionEffectTypeToItemName( mutagens[i].GetEffectType() );				
				mutagens[i].OverrideIcon( itemName );
			}
			
			FactsAdd( "Patch_Decoction_Buff_Icons" );
		}
		
		
		//if( FactsQuerySum( "154997" ) < 1 )
		//{
		//	if( IsSkillEquipped( S_Alchemy_s18 ) )
		//	{
		//		slot = GetSkillSlotID( S_Alchemy_s18 );
		//		UnequipSkill( slot );
		//		EquipSkill( S_Alchemy_s18, slot );
		//	}
		//	FactsAdd( "154997" );
		//}
		if( FactsQuerySum( "Patch_Mutagen_Ing_Stacking" ) < 1 )
		{
			Patch_MutagenStacking();		
			FactsAdd( "Patch_Mutagen_Ing_Stacking" );
		}
		
		//modSigns
		if(FactsQuerySum("new_game_started_with_GM_40") < 1 )
		{
			if( FactsQuerySum( "modSigns_ArmorTypeSetsIntroduced" ) < 1 )
			{
				pam = (W3PlayerAbilityManager)abilityManager;
				pam.ManageSetArmorTypeBonus();
				RecalcSetItemsEquipped();
				FactsAdd( "modSigns_ArmorTypeSetsIntroduced" );
			}
			if( FactsQuerySum( "modSigns_KMArmorTypeSetIntroduced" ) < 1 )
			{
				pam = (W3PlayerAbilityManager)abilityManager;
				pam.ManageSetArmorTypeBonus();
				RecalcSetItemsEquipped();
				FactsAdd( "modSigns_KMArmorTypeSetIntroduced" );
			}
		}
	}
	
	private final function Patch_MutagenStacking()
	{
		var i, j, quantity : int;
		var muts : array< SItemUniqueId >;
		var item : SItemUniqueId;
		var mutName : name;
		var wasInArray : bool;
		var mutsToAdd : array< SItemParts >;
		var mutToAdd : SItemParts;
		
		muts = inv.GetItemsByTag( 'MutagenIngredient' );
		if( GetItemEquippedOnSlot( EES_SkillMutagen1, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen2, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen3, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen4, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		
		for( i=0; i<muts.Size(); i+=1 )
		{
			mutName = inv.GetItemName( muts[i] );
			quantity = inv.GetItemQuantity( muts[i] );
			
			wasInArray = false;
			for( j=0; j<mutsToAdd.Size(); j+=1 )
			{
				if( mutsToAdd[j].itemName == mutName )
				{
					mutsToAdd[j].quantity += quantity;
					wasInArray = true;
					break;
				}
			}
			
			if( !wasInArray )
			{
				mutToAdd.itemName = mutName;
				mutToAdd.quantity = quantity;
				mutsToAdd.PushBack( mutToAdd );
			}
			
			inv.RemoveItem( muts[i], quantity );
		}
		
		for( i=0; i<mutsToAdd.Size(); i+=1 )
		{
			inv.AddAnItem( mutsToAdd[i].itemName, mutsToAdd[i].quantity, true, true );
		}
	}
	
	private function FixEquippedMutagens()
	{
		var item : SItemUniqueId;
		if( GetItemEquippedOnSlot( EES_SkillMutagen1, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen2, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen3, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen4, item ) )
		{
			inv.SetItemStackable( item, false );
		}
	}

	public final function RestoreQuen( quenHealth : float, quenDuration : float, optional alternate : bool ) : bool
	{
		var restoredQuen 	: W3QuenEntity;
		
		if(quenHealth > 0.f && quenDuration >= 3.f)
		{
			restoredQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			restoredQuen.Init( signOwner, signs[ST_Quen].entity, true );
			
			if( alternate )
			{
				restoredQuen.SetAlternateCast( S_Magic_s04 );
			}
			
			restoredQuen.freeCast = true; //modSigns
			restoredQuen.OnStarted();
			restoredQuen.OnThrowing();
			
			if( !alternate )
			{
				restoredQuen.OnEnded();
			}
			
			restoredQuen.SetDataFromRestore(quenHealth, quenDuration);
			
			return true;
		}
		
		return false;
	}
	
	public function IsInitialized() : bool
	{
		return isInitialized;
	}
	
	private function NewGamePlusInitialize()
	{
		var questItems : array<name>;
		var horseManager : W3HorseManager;
		var horseInventory : CInventoryComponent;
		var i, missingLevels, expDiff : int;
		
		super.NewGamePlusInitialize();
		
		
		horseManager = (W3HorseManager)EntityHandleGet(horseManagerHandle);
		if(horseManager)
			horseInventory = horseManager.GetInventoryComponent();
		
		
		theGame.params.SetNewGamePlusLevel(GetLevel());
		
		
		if (theGame.GetDLCManager().IsDLCAvailable('ep1'))
			missingLevels = theGame.params.NEW_GAME_PLUS_EP1_MIN_LEVEL - GetLevel();
		else
			missingLevels = theGame.params.NEW_GAME_PLUS_MIN_LEVEL - GetLevel();
			
		for(i=0; i<missingLevels; i+=1)
		{
			
			expDiff = levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint);
			expDiff = CeilF( ((float)expDiff) / 2 );
			AddPoints(EExperiencePoint, expDiff, false);
		}
		
		
		
		
		
		inv.RemoveItemByTag('Quest', -1);
		horseInventory.RemoveItemByTag('Quest', -1);

		
		
		questItems = theGame.GetDefinitionsManager().GetItemsWithTag('Quest');
		for(i=0; i<questItems.Size(); i+=1)
		{
			inv.RemoveItemByName(questItems[i], -1);
			horseInventory.RemoveItemByName(questItems[i], -1);
		}
		
		
		inv.RemoveItemByName('mq1002_artifact_3', -1);
		horseInventory.RemoveItemByName('mq1002_artifact_3', -1);
		
		
		inv.RemoveItemByTag('NotTransferableToNGP', -1);
		horseInventory.RemoveItemByTag('NotTransferableToNGP', -1);
		
		
		inv.RemoveItemByTag('NoticeBoardNote', -1);
		horseInventory.RemoveItemByTag('NoticeBoardNote', -1);
		
		
		RemoveAllNonAutoBuffs();
		
		
		RemoveAlchemyRecipe('Recipe for Trial Potion Kit');
		RemoveAlchemyRecipe('Recipe for Pops Antidote');
		RemoveAlchemyRecipe('Recipe for Czart Lure');
		RemoveAlchemyRecipe('q603_diarrhea_potion_recipe');
		
		
		inv.RemoveItemByTag('Trophy', -1);
		horseInventory.RemoveItemByTag('Trophy', -1);
		
		
		inv.RemoveItemByCategory('usable', -1);
		horseInventory.RemoveItemByCategory('usable', -1);
		
		
		RemoveAbility('StaminaTutorialProlog');
    	RemoveAbility('TutorialStaminaRegenHack');
    	RemoveAbility('area_novigrad');
    	RemoveAbility('NoRegenEffect');
    	RemoveAbility('HeavySwimmingStaminaDrain');
    	RemoveAbility('AirBoost');
    	RemoveAbility('area_nml');
    	RemoveAbility('area_skellige');
    	
    	
    	inv.RemoveItemByTag('GwintCard', -1);
    	horseInventory.RemoveItemByTag('GwintCard', -1);
    	    	
    	
    	
    	inv.RemoveItemByTag('ReadableItem', -1);
    	horseInventory.RemoveItemByTag('ReadableItem', -1);
    	
    	
    	abilityManager.RestoreStats();
    	
    	
    	((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(10000);
    	
    	
    	GetInventory().SingletonItemsRefillAmmo();
    	
    	
    	craftingSchematics.Clear();
    	AddStartingSchematics();
    	
    	
    	for( i=0; i<amountOfSetPiecesEquipped.Size(); i+=1 )
    	{
			amountOfSetPiecesEquipped[i] = 0;
		}

    	
    	inv.AddAnItem('Clearing Potion', 1, true, false, false);
    	
    	
    	inv.RemoveItemByName('q203_broken_eyeofloki', -1);
    	horseInventory.RemoveItemByName('q203_broken_eyeofloki', -1);
    	
    	
		//modSigns
		if( FactsQuerySum("ModSignsKMSetSchematicsAdded") < 1 )
		{
			AddCraftingSchematic('Kaer Morhen Armor 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Armor 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Armor 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Pants 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Boots 3 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 1 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 2 schematic',true, true);
			AddCraftingSchematic('Kaer Morhen Gloves 3 schematic',true, true);
			FactsAdd("ModSignsKMSetSchematicsAdded");
		}
		
    	NewGamePlusReplaceViperSet(inv);
    	NewGamePlusReplaceViperSet(horseInventory);
		NewGamePlusReplaceKaerMorhenSet(inv); //modSigns
		NewGamePlusReplaceKaerMorhenSet(horseInventory); //modSigns
    	NewGamePlusReplaceLynxSet(inv);
    	NewGamePlusReplaceLynxSet(horseInventory);
    	NewGamePlusReplaceGryphonSet(inv);
    	NewGamePlusReplaceGryphonSet(horseInventory);
    	NewGamePlusReplaceBearSet(inv);
    	NewGamePlusReplaceBearSet(horseInventory);
    	NewGamePlusReplaceEP1(inv);
    	NewGamePlusReplaceEP1(horseInventory);
    	NewGamePlusReplaceEP2WitcherSets(inv);
    	NewGamePlusReplaceEP2WitcherSets(horseInventory);
    	NewGamePlusReplaceEP2Items(inv);
    	NewGamePlusReplaceEP2Items(horseInventory);
    	NewGamePlusMarkItemsToNotAdjust(inv);
    	NewGamePlusMarkItemsToNotAdjust(horseInventory);
    	
    	
    	inputHandler.ClearLocksForNGP();
    	
    	
    	buffImmunities.Clear();
    	buffRemovedImmunities.Clear();
    	
    	newGamePlusInitialized = true;
    	
    	
    	m_quenReappliedCount = 1;
	}
		
	private final function NewGamePlusMarkItemsToNotAdjust(out inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		var n		: name;
		
		inv.GetAllItems(ids);
		for( i=0; i<ids.Size(); i+=1 ) 
		{
			inv.SetItemModifierInt(ids[i], 'NGPItemAdjusted', 1);
		}
	}
	
	private final function NewGamePlusReplaceItem( item : name, new_item : name, out inv : CInventoryComponent)
	{
		var i, j 					: int;
		var ids, new_ids, enh_ids 	: array<SItemUniqueId>;
		var dye_ids					: array<SItemUniqueId>;
		var enh					 	: array<name>;
		var wasEquipped 			: bool;
		var wasEnchanted 			: bool;
		var wasDyed					: bool;
		var enchantName, colorName	: name;
		
		if ( inv.HasItem( item ) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				inv.GetItemEnhancementItems( ids[i], enh );
				wasEnchanted = inv.IsItemEnchanted( ids[i] );
				if ( wasEnchanted ) 
					enchantName = inv.GetEnchantment( ids[i] );
				wasEquipped = IsItemEquipped( ids[i] );
				wasDyed = inv.IsItemColored( ids[i] );
				if ( wasDyed )
				{
					colorName = inv.GetItemColor( ids[i] );
				}
				
				inv.RemoveItem( ids[i], 1 );
				new_ids = inv.AddAnItem( new_item, 1, true, true, false );
				if ( wasEquipped )
				{
					EquipItem( new_ids[0] );
				}
				if ( wasEnchanted )
				{
					inv.EnchantItem( new_ids[0], enchantName, getEnchamtmentStatName(enchantName) );
				}
				for (j = 0; j < enh.Size(); j += 1)
				{
					enh_ids = inv.AddAnItem( enh[j], 1, true, true, false );
					inv.EnhanceItemScript( new_ids[0], enh_ids[0] );
				}
				if ( wasDyed )
				{
					dye_ids = inv.AddAnItem( colorName, 1, true, true, false );
					inv.ColorItem( new_ids[0], dye_ids[0] );
					inv.RemoveItem( dye_ids[0], 1 );
				}
				
				inv.SetItemModifierInt( new_ids[0], 'NGPItemAdjusted', 1 );
			}
		}
	}
	
	private final function NewGamePlusAdjustDLCItem(item : name, mod : name, inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		
		if( inv.HasItem(item) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				if ( inv.GetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC') <= 0 )
				{
					inv.AddItemBaseAbility(ids[i], mod);
					inv.SetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC', 1);	
				}
			}
		}
		
	}
	
	private final function NewGamePlusAdjustDLC1TemerianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC5NilfgardianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC10WolfSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP Wolf Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 1', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 2', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 3', 'NGP DLC Compatibility Chest Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword',   'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 1', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 2', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 3', 'NGP Wolf Steel Sword Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword',   'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 1', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 2', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 3', 'NGP Wolf Silver Sword Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC14SkelligeSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	//modSigns
	private final function NewGamePlusReplaceKaerMorhenSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Kaer Morhen Armor','NGP Kaer Morhen Armor', inv);
		NewGamePlusReplaceItem('Kaer Morhen Armor 1','NGP Kaer Morhen Armor 1', inv);
		NewGamePlusReplaceItem('Kaer Morhen Armor 2','NGP Kaer Morhen Armor 2', inv);
		NewGamePlusReplaceItem('Kaer Morhen Armor 3','NGP Kaer Morhen Armor 3', inv);
		NewGamePlusReplaceItem('Kaer Morhen Pants','NGP Kaer Morhen Pants', inv);
		NewGamePlusReplaceItem('Kaer Morhen Pants 1','NGP Kaer Morhen Pants 1', inv);
		NewGamePlusReplaceItem('Kaer Morhen Pants 2','NGP Kaer Morhen Pants 2', inv);
		NewGamePlusReplaceItem('Kaer Morhen Pants 3','NGP Kaer Morhen Pants 3', inv);
		NewGamePlusReplaceItem('Kaer Morhen Boots','NGP Kaer Morhen Boots', inv);
		NewGamePlusReplaceItem('Kaer Morhen Boots 1','NGP Kaer Morhen Boots 1', inv);
		NewGamePlusReplaceItem('Kaer Morhen Boots 2','NGP Kaer Morhen Boots 2', inv);
		NewGamePlusReplaceItem('Kaer Morhen Boots 3','NGP Kaer Morhen Boots 3', inv);
		NewGamePlusReplaceItem('Kaer Morhen Gloves','NGP Kaer Morhen Gloves', inv);
		NewGamePlusReplaceItem('Kaer Morhen Gloves 1','NGP Kaer Morhen Gloves 1', inv);
		NewGamePlusReplaceItem('Kaer Morhen Gloves 2','NGP Kaer Morhen Gloves 2', inv);
		NewGamePlusReplaceItem('Kaer Morhen Gloves 3','NGP Kaer Morhen Gloves 3', inv);
	}
	
	private final function NewGamePlusReplaceViperSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Viper School steel sword', 'NGP Viper School steel sword', inv);
		
		NewGamePlusReplaceItem('Viper School silver sword', 'NGP Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceLynxSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor', 'NGP Lynx Armor', inv);
		NewGamePlusReplaceItem('Lynx Armor 1', 'NGP Lynx Armor 1', inv);
		NewGamePlusReplaceItem('Lynx Armor 2', 'NGP Lynx Armor 2', inv);
		NewGamePlusReplaceItem('Lynx Armor 3', 'NGP Lynx Armor 3', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 1', 'NGP Lynx Gloves 1', inv);
		NewGamePlusReplaceItem('Lynx Gloves 2', 'NGP Lynx Gloves 2', inv);
		NewGamePlusReplaceItem('Lynx Gloves 3', 'NGP Lynx Gloves 3', inv);
		NewGamePlusReplaceItem('Lynx Gloves 4', 'NGP Lynx Gloves 4', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 1', 'NGP Lynx Pants 1', inv);
		NewGamePlusReplaceItem('Lynx Pants 2', 'NGP Lynx Pants 2', inv);
		NewGamePlusReplaceItem('Lynx Pants 3', 'NGP Lynx Pants 3', inv);
		NewGamePlusReplaceItem('Lynx Pants 4', 'NGP Lynx Pants 4', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 1', 'NGP Lynx Boots 1', inv);
		NewGamePlusReplaceItem('Lynx Boots 2', 'NGP Lynx Boots 2', inv);
		NewGamePlusReplaceItem('Lynx Boots 3', 'NGP Lynx Boots 3', inv);
		NewGamePlusReplaceItem('Lynx Boots 4', 'NGP Lynx Boots 4', inv);
		
		NewGamePlusReplaceItem('Lynx School steel sword', 'NGP Lynx School steel sword', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 1', 'NGP Lynx School steel sword 1', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 2', 'NGP Lynx School steel sword 2', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 3', 'NGP Lynx School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword', 'NGP Lynx School silver sword', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 1', 'NGP Lynx School silver sword 1', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 2', 'NGP Lynx School silver sword 2', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 3', 'NGP Lynx School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceGryphonSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Gryphon Armor', 'NGP Gryphon Armor', inv);
		NewGamePlusReplaceItem('Gryphon Armor 1', 'NGP Gryphon Armor 1', inv);
		NewGamePlusReplaceItem('Gryphon Armor 2', 'NGP Gryphon Armor 2', inv);
		NewGamePlusReplaceItem('Gryphon Armor 3', 'NGP Gryphon Armor 3', inv);
		
		NewGamePlusReplaceItem('Gryphon Gloves 1', 'NGP Gryphon Gloves 1', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 2', 'NGP Gryphon Gloves 2', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 3', 'NGP Gryphon Gloves 3', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 4', 'NGP Gryphon Gloves 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Pants 1', 'NGP Gryphon Pants 1', inv);
		NewGamePlusReplaceItem('Gryphon Pants 2', 'NGP Gryphon Pants 2', inv);
		NewGamePlusReplaceItem('Gryphon Pants 3', 'NGP Gryphon Pants 3', inv);
		NewGamePlusReplaceItem('Gryphon Pants 4', 'NGP Gryphon Pants 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Boots 1', 'NGP Gryphon Boots 1', inv);
		NewGamePlusReplaceItem('Gryphon Boots 2', 'NGP Gryphon Boots 2', inv);
		NewGamePlusReplaceItem('Gryphon Boots 3', 'NGP Gryphon Boots 3', inv);
		NewGamePlusReplaceItem('Gryphon Boots 4', 'NGP Gryphon Boots 4', inv);
		
		NewGamePlusReplaceItem('Gryphon School steel sword', 'NGP Gryphon School steel sword', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 1', 'NGP Gryphon School steel sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 2', 'NGP Gryphon School steel sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 3', 'NGP Gryphon School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Gryphon School silver sword', 'NGP Gryphon School silver sword', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 1', 'NGP Gryphon School silver sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 2', 'NGP Gryphon School silver sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 3', 'NGP Gryphon School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceBearSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Bear Armor', 'NGP Bear Armor', inv);
		NewGamePlusReplaceItem('Bear Armor 1', 'NGP Bear Armor 1', inv);
		NewGamePlusReplaceItem('Bear Armor 2', 'NGP Bear Armor 2', inv);
		NewGamePlusReplaceItem('Bear Armor 3', 'NGP Bear Armor 3', inv);
		
		NewGamePlusReplaceItem('Bear Gloves 1', 'NGP Bear Gloves 1', inv);
		NewGamePlusReplaceItem('Bear Gloves 2', 'NGP Bear Gloves 2', inv);
		NewGamePlusReplaceItem('Bear Gloves 3', 'NGP Bear Gloves 3', inv);
		NewGamePlusReplaceItem('Bear Gloves 4', 'NGP Bear Gloves 4', inv);
		
		NewGamePlusReplaceItem('Bear Pants 1', 'NGP Bear Pants 1', inv);
		NewGamePlusReplaceItem('Bear Pants 2', 'NGP Bear Pants 2', inv);
		NewGamePlusReplaceItem('Bear Pants 3', 'NGP Bear Pants 3', inv);
		NewGamePlusReplaceItem('Bear Pants 4', 'NGP Bear Pants 4', inv);
		
		NewGamePlusReplaceItem('Bear Boots 1', 'NGP Bear Boots 1', inv);
		NewGamePlusReplaceItem('Bear Boots 2', 'NGP Bear Boots 2', inv);
		NewGamePlusReplaceItem('Bear Boots 3', 'NGP Bear Boots 3', inv);
		NewGamePlusReplaceItem('Bear Boots 4', 'NGP Bear Boots 4', inv);
		
		NewGamePlusReplaceItem('Bear School steel sword', 'NGP Bear School steel sword', inv);
		NewGamePlusReplaceItem('Bear School steel sword 1', 'NGP Bear School steel sword 1', inv);
		NewGamePlusReplaceItem('Bear School steel sword 2', 'NGP Bear School steel sword 2', inv);
		NewGamePlusReplaceItem('Bear School steel sword 3', 'NGP Bear School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Bear School silver sword', 'NGP Bear School silver sword', inv);
		NewGamePlusReplaceItem('Bear School silver sword 1', 'NGP Bear School silver sword 1', inv);
		NewGamePlusReplaceItem('Bear School silver sword 2', 'NGP Bear School silver sword 2', inv);
		NewGamePlusReplaceItem('Bear School silver sword 3', 'NGP Bear School silver sword 3', inv);
	}
		
	private final function NewGamePlusReplaceEP1(out inv : CInventoryComponent)
	{	
		NewGamePlusReplaceItem('Ofir Armor', 'NGP Ofir Armor', inv);
		NewGamePlusReplaceItem('Ofir Sabre 2', 'NGP Ofir Sabre 2', inv);
		
		NewGamePlusReplaceItem('Crafted Burning Rose Armor', 'NGP Crafted Burning Rose Armor', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Gloves', 'NGP Crafted Burning Rose Gloves', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Sword', 'NGP Crafted Burning Rose Sword', inv);
		
		NewGamePlusReplaceItem('Crafted Ofir Armor', 'NGP Crafted Ofir Armor', inv);
		NewGamePlusReplaceItem('Crafted Ofir Boots', 'NGP Crafted Ofir Boots', inv);
		NewGamePlusReplaceItem('Crafted Ofir Gloves', 'NGP Crafted Ofir Gloves', inv);
		NewGamePlusReplaceItem('Crafted Ofir Pants', 'NGP Crafted Ofir Pants', inv);
		NewGamePlusReplaceItem('Crafted Ofir Steel Sword', 'NGP Crafted Ofir Steel Sword', inv);
		
		NewGamePlusReplaceItem('EP1 Crafted Witcher Silver Sword', 'NGP EP1 Crafted Witcher Silver Sword', inv);
		//NewGamePlusReplaceItem('Olgierd Sabre', 'NGP Olgierd Sabre', inv);
		
		NewGamePlusReplaceItem('EP1 Witcher Armor', 'NGP EP1 Witcher Armor', inv);
		NewGamePlusReplaceItem('EP1 Witcher Boots', 'NGP EP1 Witcher Boots', inv);
		NewGamePlusReplaceItem('EP1 Witcher Gloves', 'NGP EP1 Witcher Gloves', inv);
		NewGamePlusReplaceItem('EP1 Witcher Pants', 'NGP EP1 Witcher Pants', inv);
		NewGamePlusReplaceItem('EP1 Viper School steel sword', 'NGP EP1 Viper School steel sword', inv);
		NewGamePlusReplaceItem('EP1 Viper School silver sword', 'NGP EP1 Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceEP2WitcherSets(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor 4', 'NGP Lynx Armor 4', inv);
		NewGamePlusReplaceItem('Gryphon Armor 4', 'NGP Gryphon Armor 4', inv);
		NewGamePlusReplaceItem('Bear Armor 4', 'NGP Bear Armor 4', inv);
		NewGamePlusReplaceItem('Wolf Armor 4', 'NGP Wolf Armor 4', inv);
		NewGamePlusReplaceItem('Red Wolf Armor 1', 'NGP Red Wolf Armor 1', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 5', 'NGP Lynx Gloves 5', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 5', 'NGP Gryphon Gloves 5', inv);
		NewGamePlusReplaceItem('Bear Gloves 5', 'NGP Bear Gloves 5', inv);
		NewGamePlusReplaceItem('Wolf Gloves 5', 'NGP Wolf Gloves 5', inv);
		NewGamePlusReplaceItem('Red Wolf Gloves 1', 'NGP Red Wolf Gloves 1', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 5', 'NGP Lynx Pants 5', inv);
		NewGamePlusReplaceItem('Gryphon Pants 5', 'NGP Gryphon Pants 5', inv);
		NewGamePlusReplaceItem('Bear Pants 5', 'NGP Bear Pants 5', inv);
		NewGamePlusReplaceItem('Wolf Pants 5', 'NGP Wolf Pants 5', inv);
		NewGamePlusReplaceItem('Red Wolf Pants 1', 'NGP Red Wolf Pants 1', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 5', 'NGP Lynx Boots 5', inv);
		NewGamePlusReplaceItem('Gryphon Boots 5', 'NGP Gryphon Boots 5', inv);
		NewGamePlusReplaceItem('Bear Boots 5', 'NGP Bear Boots 5', inv);
		NewGamePlusReplaceItem('Wolf Boots 5', 'NGP Wolf Boots 5', inv);
		NewGamePlusReplaceItem('Red Wolf Boots 1', 'NGP Red Wolf Boots 1', inv);
		
		
		NewGamePlusReplaceItem('Lynx School steel sword 4', 'NGP Lynx School steel sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 4', 'NGP Gryphon School steel sword 4', inv);
		NewGamePlusReplaceItem('Bear School steel sword 4', 'NGP Bear School steel sword 4', inv);
		NewGamePlusReplaceItem('Wolf School steel sword 4', 'NGP Wolf School steel sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School steel sword 1', 'NGP Red Wolf School steel sword 1', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword 4', 'NGP Lynx School silver sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 4', 'NGP Gryphon School silver sword 4', inv);
		NewGamePlusReplaceItem('Bear School silver sword 4', 'NGP Bear School silver sword 4', inv);
		NewGamePlusReplaceItem('Wolf School silver sword 4', 'NGP Wolf School silver sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School silver sword 1', 'NGP Red Wolf School silver sword 1', inv);
	}
	
	private final function NewGamePlusReplaceEP2Items(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Guard Lvl1 Armor 3', 'NGP Guard Lvl1 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Armor 3', 'NGP Guard Lvl1 A Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Armor 3', 'NGP Guard Lvl2 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Armor 3', 'NGP Guard Lvl2 A Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Armor 3', 'NGP Knight Geralt Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Armor 3', 'NGP Knight Geralt A Armor 3', inv);
		//NewGamePlusReplaceItem('q702_vampire_armor', 'NGP q702_vampire_armor', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Gloves 3', 'NGP Guard Lvl1 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Gloves 3', 'NGP Guard Lvl1 A Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Gloves 3', 'NGP Guard Lvl2 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Gloves 3', 'NGP Guard Lvl2 A Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Gloves 3', 'NGP Knight Geralt Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Gloves 3', 'NGP Knight Geralt A Gloves 3', inv);
		//NewGamePlusReplaceItem('q702_vampire_gloves', 'NGP q702_vampire_gloves', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Pants 3', 'NGP Guard Lvl1 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Pants 3', 'NGP Guard Lvl1 A Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Pants 3', 'NGP Guard Lvl2 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Pants 3', 'NGP Guard Lvl2 A Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Pants 3', 'NGP Knight Geralt Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Pants 3', 'NGP Knight Geralt A Pants 3', inv);
		//NewGamePlusReplaceItem('q702_vampire_pants', 'NGP q702_vampire_pants', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Boots 3', 'NGP Guard Lvl1 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Boots 3', 'NGP Guard Lvl1 A Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Boots 3', 'NGP Guard Lvl2 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Boots 3', 'NGP Guard Lvl2 A Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Boots 3', 'NGP Knight Geralt Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Boots 3', 'NGP Knight Geralt A Boots 3', inv);
		//NewGamePlusReplaceItem('q702_vampire_boots', 'NGP q702_vampire_boots', inv);
		
		NewGamePlusReplaceItem('Serpent Steel Sword 1', 'NGP Serpent Steel Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 2', 'NGP Serpent Steel Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 3', 'NGP Serpent Steel Sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl1 steel sword 3', 'NGP Guard lvl1 steel sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl2 steel sword 3', 'NGP Guard lvl2 steel sword 3', inv);
		NewGamePlusReplaceItem('Knights steel sword 3', 'NGP Knights steel sword 3', inv);
		NewGamePlusReplaceItem('Hanza steel sword 3', 'NGP Hanza steel sword 3', inv);
		NewGamePlusReplaceItem('Toussaint steel sword 3', 'NGP Toussaint steel sword 3', inv);
		//NewGamePlusReplaceItem('q702 vampire steel sword', 'NGP q702 vampire steel sword', inv);
		
		NewGamePlusReplaceItem('Serpent Silver Sword 1', 'NGP Serpent Silver Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 2', 'NGP Serpent Silver Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 3', 'NGP Serpent Silver Sword 3', inv);
	}
	
	public function GetEquippedSword(steel : bool) : SItemUniqueId
	{
		var item : SItemUniqueId;
		
		if(steel)
			GetItemEquippedOnSlot(EES_SteelSword, item);
		else
			GetItemEquippedOnSlot(EES_SilverSword, item);
			
		return item;
	}
	
	timer function BroadcastRain( deltaTime : float, id : int )
	{
		var rainStrength : float = 0;
		rainStrength = GetRainStrength();
		if( rainStrength > 0.5 )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'RainAction', 2.0f , 50.0f, -1.f, -1, true); 
			LogReactionSystem( "'RainAction' was sent by Player - single broadcast - distance: 50.0" ); 
		}
	}
	
	function InitializeParryType()
	{
		var i, j : int;
		
		parryTypeTable.Resize( EnumGetMax('EAttackSwingType')+1 );
		for( i = 0; i < EnumGetMax('EAttackSwingType')+1; i += 1 )
		{
			parryTypeTable[i].Resize( EnumGetMax('EAttackSwingDirection')+1 );
		}
		parryTypeTable[AST_Horizontal][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_LeftRight] = PT_Left;
		parryTypeTable[AST_Horizontal][ASD_RightLeft] = PT_Right;
		parryTypeTable[AST_Vertical][ASD_UpDown] = PT_Up;
		parryTypeTable[AST_Vertical][ASD_DownUp] = PT_Down;
		parryTypeTable[AST_Vertical][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Vertical][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_LeftRight] = PT_UpLeft;
		parryTypeTable[AST_DiagonalUp][ASD_RightLeft] = PT_RightUp;
		parryTypeTable[AST_DiagonalDown][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_LeftRight] = PT_LeftDown;
		parryTypeTable[AST_DiagonalDown][ASD_RightLeft] = PT_DownRight;
		parryTypeTable[AST_Jab][ASD_UpDown] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_DownUp] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_LeftRight] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_RightLeft] = PT_Jab;	
	}
	
	
	
	
	
	
	event OnDeath( damageAction : W3DamageAction )
	{
		var items 		: array< SItemUniqueId >;
		var i, size 	: int;	
		var slot		: EEquipmentSlots;
		var holdSlot	: name;
	
		super.OnDeath( damageAction );
	
		items = GetHeldItems();
				
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait')
		{
			OnRangedForceHolster( true, true, true );		
			rangedWeapon.ClearDeployedEntity(true);
		}
		
		size = items.Size();
		
		if ( size > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				if ( this.inv.IsIdValid( items[i] ) && !( this.inv.IsItemCrossbow( items[i] ) ) )
				{
					holdSlot = this.inv.GetItemHoldSlot( items[i] );				
				
					if (  holdSlot == 'l_weapon' && this.IsHoldingItemInLHand() )
					{
						this.OnUseSelectedItem( true );
					}			
			
					DropItemFromSlot( holdSlot, false );
					
					if ( holdSlot == 'r_weapon' )
					{
						slot = this.GetItemSlot( items[i] );
						if ( UnequipItemFromSlot( slot ) )
							Log( "Unequip" );
					}
				}
			}
		}
	}
	
	
	
	
	
	
	
	function HandleMovement( deltaTime : float )
	{
		super.HandleMovement( deltaTime );
		
		rawCameraHeading = theCamera.GetCameraHeading();
	}
		
	
	
	
	
	
	
	function ToggleSpecialAttackHeavyAllowed( toggle : bool)
	{
		specialAttackHeavyAllowed = toggle;
	}
	
	function GetReputationManager() : W3Reputation
	{
		return reputationManager;
	}
			
	function OnRadialMenuItemChoose( selectedItem : string ) 
	{
		var iSlotId : int;
		var item : SItemUniqueId;
		
		if ( selectedItem != "Crossbow" )
		{
			if ( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
				OnRangedForceHolster( true, false );
		}
		
		
		switch(selectedItem)
		{
			
			case "Meditation":
				theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu' );
				break;			
			case "Slot1":
				GetItemEquippedOnSlot( EES_Petard1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				break;
				
			case "Slot2":
				GetItemEquippedOnSlot( EES_Petard2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				break;
				
			case "Crossbow":
				SelectQuickslotItem(EES_RangedWeapon);
				break;
				
			case "Slot3":
				GetItemEquippedOnSlot( EES_Quickslot1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				break;
				
			case "Slot4": 
				GetItemEquippedOnSlot( EES_Quickslot2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				break;
				
			default:
				SetEquippedSign(SignStringToEnum( selectedItem ));
				FactsRemove("SignToggled");
				break;
		}
	}
	
	function ToggleNextItem()
	{
		var quickSlotItems : array< EEquipmentSlots >;
		var currentSelectedItem : SItemUniqueId;
		var item : SItemUniqueId;
		var i : int;
		
		for( i = EES_Quickslot2; i > EES_Petard1 - 1; i -= 1 )
		{
			GetItemEquippedOnSlot( i, item );
			if( inv.IsIdValid( item ) )
			{
				quickSlotItems.PushBack( i );
			}
		}
		if( !quickSlotItems.Size() )
		{
			return;
		}
		
		currentSelectedItem = GetSelectedItemId();
		
		if( inv.IsIdValid( currentSelectedItem ) )
		{
			for( i = 0; i < quickSlotItems.Size(); i += 1 )
			{
				GetItemEquippedOnSlot( quickSlotItems[i], item );
				if( currentSelectedItem == item )
				{
					if( i == quickSlotItems.Size() - 1 )
					{
						SelectQuickslotItem( quickSlotItems[ 0 ] );
					}
					else
					{
						SelectQuickslotItem( quickSlotItems[ i + 1 ] );
					}
					return;
				}
			}
		}
		else 
		{
			SelectQuickslotItem( quickSlotItems[ 0 ] );
		}
	}
		
	
	function SetEquippedSign( signType : ESignType )
	{
		if(!IsSignBlocked(signType))
		{
			equippedSign = signType;
			FactsSet("CurrentlySelectedSign", equippedSign);
		}
	}
	
	function GetEquippedSign() : ESignType
	{
		return equippedSign;
	}
	
	function GetCurrentlyCastSign() : ESignType
	{
		return currentlyCastSign;
	}
	
	function SetCurrentlyCastSign( type : ESignType, entity : W3SignEntity )
	{
		currentlyCastSign = type;
		
		if( type != ST_None )
		{
			signs[currentlyCastSign].entity = entity;
		}
	}
	
	function GetCurrentSignEntity() : W3SignEntity
	{
		if(currentlyCastSign == ST_None)
			return NULL;
			
		return signs[currentlyCastSign].entity;
	}
	
	public function GetSignEntity(type : ESignType) : W3SignEntity
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].entity;
	}
	
	public function GetSignTemplate(type : ESignType) : CEntityTemplate
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].template;
	}
	
	public function IsCurrentSignChanneled() : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
			return signs[currentlyCastSign].entity.OnCheckChanneling();
		
		return false;
	}
	
	function IsCastingSign() : bool
	{
		return currentlyCastSign != ST_None;
	}
	
	
	protected function IsInCombatActionCameraRotationEnabled() : bool
	{
		if( IsInCombatAction() && ( GetCombatAction() == EBAT_EMPTY || GetCombatAction() == EBAT_Parry ) )
		{
			return true;
		}
		
		return !bIsInCombatAction;
	}
	
	function SetHoldBeforeOpenRadialMenuTime ( time : float )
	{
		_HoldBeforeOpenRadialMenuTime = time;
	}
	
	
	
	
	
	
	
	public function RepairItem (  rapairKitId : SItemUniqueId, usedOnItem : SItemUniqueId )
	{
		var itemMaxDurablity 		: float;
		var itemCurrDurablity 		: float;
		var baseRepairValue		  	: float;
		var reapirValue				: float;
		var itemAttribute			: SAbilityAttributeValue;
		//var dmgBoost				: float; //modSigns
		
		itemMaxDurablity = inv.GetItemMaxDurability(usedOnItem);
		itemCurrDurablity = inv.GetItemDurability(usedOnItem);
		itemAttribute = inv.GetItemAttributeValue ( rapairKitId, 'repairValue' );
		
		/*if( itemCurrDurablity >= itemMaxDurablity )
		{
			return;
		}*/ //modSigns
		
		if ( inv.IsItemAnyArmor ( usedOnItem )|| inv.IsItemWeapon( usedOnItem ) )
		{			
			//modSigns: master repair kits increase item level
			if( inv.ItemHasTag( rapairKitId, 'ArmorReapairKit_Master' ) || inv.ItemHasTag( rapairKitId, 'WeaponReapairKit_Master' ) )
			{
				inv.AddItemLevelAbility( usedOnItem );
				//if( inv.ItemHasTag( usedOnItem, 'Aerondight' ) )
				//{
				//	dmgBoost = inv.GetItemModifierFloat( usedOnItem, 'PermDamageBoost' );
				//	if( dmgBoost > 10 )
				//		inv.SetItemModifierFloat( usedOnItem, 'PermDamageBoost', dmgBoost - 10 );
				//}
			}
			
			baseRepairValue = itemMaxDurablity * itemAttribute.valueMultiplicative;					
			reapirValue = MinF( itemCurrDurablity + baseRepairValue, itemMaxDurablity );
			
			inv.SetItemDurabilityScript ( usedOnItem, MinF ( reapirValue, itemMaxDurablity ));
		}
		
		inv.RemoveItem ( rapairKitId, 1 );
		
	}
	public function HasRepairAbleGearEquiped ( ) : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_Armor, curEquipedItem) || GetItemEquippedOnSlot(EES_Boots, curEquipedItem) || GetItemEquippedOnSlot(EES_Pants, curEquipedItem) || GetItemEquippedOnSlot(EES_Gloves, curEquipedItem)) == true;
	}
	public function HasRepairAbleWaponEquiped () : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem) || GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem) ) == true;
	}
	public function IsItemRepairAble ( item : SItemUniqueId ) : bool
	{
		return inv.HasItemDurability(item); //inv.GetItemDurabilityRatio(item) <= 0.99999f; //modSigns
	}
	
	
	
	
	
	
		
	
	public function ApplyOil( oilId : SItemUniqueId, usedOnItem : SItemUniqueId ) : bool
	{
		var tutStateOil : W3TutorialManagerUIHandlerStateOils;		
		
		if( !super.ApplyOil( oilId, usedOnItem ))
			return false;
				
		
		if(ShouldProcessTutorial('TutorialOilCanEquip3'))
		{
			tutStateOil = (W3TutorialManagerUIHandlerStateOils)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateOil)
			{
				tutStateOil.OnOilApplied();
			}
		}
		
		return true;
	}
	
	private final function RemoveExtraOilsFromItem( item : SItemUniqueId )
	{
		var oils : array< CBaseGameplayEffect >;
		var i, cnt : int;
		var buff : W3Effect_Oil;
	
		oils = GetBuffs( EET_Oil );
		for( i=0; i<oils.Size(); i+=1 )
		{			
			buff = (W3Effect_Oil) oils[ i ];
			if( buff && buff.GetSwordItemId() == item )
			{
				cnt += 1;
			}
		}
		while( cnt > 1 )
		{
			inv.RemoveOldestOilFromItem( item );
			cnt -= 1;
		}
	}
	
	
	
	
	
	
	
	
	//modSigns: separate function for dodge
	function DodgeDamage(out damageData : W3DamageAction)
	{
		var actorAttacker : CActor;
		var attackRange : CAIAttackRange;
		var safeAngleDist, angleDist, distToAttacker, damageReduction : float;
		var attackName : name;
		var isDodging, isIceGiantSpecial : bool;
		
		super.DodgeDamage(damageData);
		
		actorAttacker = (CActor)damageData.attacker;
		//modSigns: fix dodge detection bug - shouldn't be needed anymore, but leaving it here just in case
		isDodging = IsCurrentlyDodging() || IsInCombatAction() && ((int)GetBehaviorVariable( 'combatActionType' ) == CAT_Dodge || (int)GetBehaviorVariable( 'combatActionType' ) == CAT_Roll);
		
		//modSigns: debug
		if( FactsQuerySum( "modSigns_debug_reduce_damage" ) > 0 )
		{
			theGame.witcherLog.AddMessage("Is in combat action: " + (int)IsInCombatAction());
			theGame.witcherLog.AddMessage("Player action: " + GetBehaviorVariable( 'combatActionType' ));
			theGame.witcherLog.AddMessage("Player is dodging: " + isDodging);
		}
		
		if(actorAttacker && isDodging && !(damageData.IsActionEnvironment() || damageData.IsDoTDamage()))
		{
			attackName = actorAttacker.GetLastAttackRangeName();
			angleDist = AbsF(AngleDistance(evadeHeading, actorAttacker.GetHeading()));
			attackRange = theGame.GetAttackRangeForEntity(actorAttacker, attackName);
			distToAttacker = VecDistance(this.GetWorldPosition(), damageData.attacker.GetWorldPosition());
			isIceGiantSpecial = ( attackName == 'stomp' || attackName == 'anchor_special_far' || attackName == 'anchor_far' );
			//Fleet Footed graze damage reduction
			if( CanUseSkill(S_Sword_s09) )
				damageReduction = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s09, 's9_damage_reduction', false, true)) * GetSkillLevel(S_Sword_s09);
			else
				damageReduction = 0;
			//attack can be dodged
			if( damageData.CanBeDodged() )
			{
				//set up safe angle distance
				safeAngleDist = 120;
				if( HasAbility('ArmorTypeLightSetBonusAbility') )
					safeAngleDist += CalculateAttributeValue(GetAbilityAttributeValue('ArmorTypeLightSetBonusAbility', 'dodge_safe_ange_dist_deg'));
				safeAngleDist = ClampF( safeAngleDist, 0, 180 );
				//check dodge success
				if( angleDist <= safeAngleDist && !isIceGiantSpecial || isIceGiantSpecial && distToAttacker > attackRange.rangeMax * 0.75 )
				{
					if( theGame.CanLog() )
					{
						LogDMHits("W3PlayerWitcher.DodgeDamage: Attack dodged by player - no damage done", damageData);
					}
					damageData.SetWasDodged();
				}
			}
			//graze damage reduction
			if( !damageData.WasDodged() && damageReduction > 0 )
			{
				if( theGame.CanLog() )
				{
					LogDMHits("W3PlayerWitcher.DodgeDamage: reduced damage while dodging an attack", damageData );
				}
				damageData.SetGrazeDamageReduction(damageReduction);
			}
			//modSigns: debug
			if( FactsQuerySum( "modSigns_debug_reduce_damage" ) > 0 )
			{
				theGame.witcherLog.AddMessage("Fleet Footed damage reduction: " + damageReduction);
				theGame.witcherLog.AddMessage("Attack name: " + attackName);
				theGame.witcherLog.AddMessage("Attack can be dodged: " + damageData.CanBeDodged());
				theGame.witcherLog.AddMessage("Safe angle distance: " + safeAngleDist);
				theGame.witcherLog.AddMessage("Attacker and evade angle distance: " + angleDist);
				theGame.witcherLog.AddMessage("Attack range: " + attackRange.rangeMax);
				theGame.witcherLog.AddMessage("Distance to attacker: " + distToAttacker);
				theGame.witcherLog.AddMessage("Damage was dodged completely: " + damageData.WasDodged());
			}
		}
	}
	
	//modSigns: rewritten
	function ReduceDamage(out damageData : W3DamageAction)
	{
		var quen : W3QuenEntity;
		var min, max : SAbilityAttributeValue;
		var /*currAdrenaline, adrenReducedDmg, focus,*/ chance : float;
		var whirlDmgReduction : SAbilityAttributeValue;
		
		super.ReduceDamage(damageData);
		
		//new mutagen27 effect: prevent chain damage
		if(HasBuff(EET_Mutagen27) && !(damageData.IsActionEnvironment() || damageData.IsDoTDamage()))
		{
			((W3Mutagen27_Effect)GetBuff(EET_Mutagen27)).ReduceDamage(damageData);
		}
			
		//damage prevented
		if(!damageData.DealsAnyDamage())
			return;
		
		//modSigns: dodge detection moved to separate function!
		//reduce damage from dodging, if was partially dodged
		if(damageData.IsGrazeDamage())
		{
			damageData.processedDmg.vitalityDamage *= ClampF( 1 - damageData.GetGrazeDamageReduction(), 0.05, 1 );
			//modSigns: debug
			if( FactsQuerySum( "modSigns_debug_reduce_damage" ) > 0 )
			{
				theGame.witcherLog.AddMessage("Is graze damage: " + damageData.IsGrazeDamage());
				theGame.witcherLog.AddMessage("Graze damage reduction: " + damageData.GetGrazeDamageReduction());
			}
		}
		
		quen = (W3QuenEntity)signs[ST_Quen].entity;
		
		//Protective Coating damage reduction
		if( !damageData.IsDoTDamage() && CanUseSkill(S_Alchemy_s05) )
		{
			damageData.processedDmg.vitalityDamage *= ClampF(1 - GetOilProtectionAgainstMonster(damageData), 0.f, 1.f);
			//modSigns: debug
			if( FactsQuerySum( "modSigns_debug_reduce_damage" ) > 0 )
			{
				theGame.witcherLog.AddMessage("Oil protection against monster: " + GetOilProtectionAgainstMonster(damageData));
			}
		}
		
		//Mutated Skin passive ability -> changed
		//if( IsMutationActive( EPMT_Mutation5 ) && !IsAnyQuenActive() && !damageData.IsDoTDamage() )
		//{
		//	focus = GetStat( BCS_Focus );
		//	currAdrenaline = FloorF( focus );
		//	if( currAdrenaline >= 1 )
		//	{
		//		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
		//		adrenReducedDmg = ( currAdrenaline * min.valueAdditive );
		//		damageData.processedDmg.vitalityDamage *= ClampF(1 - adrenReducedDmg, 0, 1);
		//		
		//		
		//		theGame.MutationHUDFeedback( MFT_PlayOnce );
		//		
		//		if( focus >= 3.f )
		//		{
		//			PlayEffect( 'mutation_5_stage_03' );
		//		}
		//		else if( focus >= 2.f )
		//		{
		//			PlayEffect( 'mutation_5_stage_02' );
		//		}
		//		else
		//		{
		//			PlayEffect( 'mutation_5_stage_01' );
		//		}
		//	}
		//}
		
		//modSigns: whirl incoming damage reduction
		if( !damageData.IsDoTDamage() && GetStat(BCS_Focus) > 0 && IsDoingSpecialAttack(false) )
		{
			whirlDmgReduction = GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction', false, true)
				+ GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction_bonus_after_1', false, true) * (GetSkillLevel(S_Sword_s01) - 1);
			damageData.processedDmg.vitalityDamage *= ClampF(1 - whirlDmgReduction.valueMultiplicative, 0.f, 1.f);
			//DrainFocus(1);
			//PauseFocusGain( true );
			//AddTimer( 'ResumeFocusGain', 1.f );
			//theGame.witcherLog.AddMessage("Whirl damage reduction."); //modSigns: debug
		}
		
		//modSigns: cast quen on projectile ability, moved here
		if((!quen || !quen.IsAnyQuenActive()) && damageData.IsActionRanged() && !damageData.IsActionWitcherSign() && !damageData.IsDoTDamage() && !damageData.WasDodged())
		{
			chance = CalculateAttributeValue(GetAttributeValue('quen_chance_on_projectile'));
			if(chance > 0)
			{
				chance = ClampF(chance, 0, 1);
				
				if(RandF() < chance)
				{
					if(!quen)
					{
						quen = (W3QuenEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
					}
					quen.Init(signOwner, signs[ST_Quen].entity, true );
					quen.freeCast = true;
					quen.OnStarted();
					quen.OnThrowing();
					quen.OnEnded();
					if ( theGame.CanLog() )
					{		
						LogDMHits("W3PlayerWitcher.ReduceDamage: Processing Quen On Projectile armor ability...", damageData);
					}
					//quen.OnTargetHit( damageData );
					quen.ShowHitFX(); //modSigns: play FX
					damageData.SetAllProcessedDamageAs(0);
					damageData.SetEndsQuen(true);
				}
			}
		}
		//damage reduction from signs
		//else if((quen && quen.IsAnyQuenActive()) && damageData.GetBuffSourceName() != "FallingDamage")
		//{
		//	if ( theGame.CanLog() )
		//	{		
		//		LogDMHits("W3PlayerWitcher.ReduceDamage: Processing Quen sign damage reduction...", damageData);
		//	}
		//	quen.OnTargetHit( damageData );
		//} //modSigns: moved to damage manager to decrease raw damage
		
		//modSigns: gryphon set tier 2 damage reduction - removed, adds resistances instead
		/*if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			min = GetAttributeValue( 'gryphon_set_bns_dmg_reduction' );
			damageData.processedDmg.vitalityDamage *= ClampF(1 - min.valueAdditive, 0, 1);
		}*/
		
		
		//if you need to copy-paste a part of a parent function
		//and do some shitty dancing around a part of the code,
		//this probably means that the code doesn't belong here
		//and should be placed somewhere else instead... yeah?
		//if(!damageData.GetIgnoreImmortalityMode())
		//{
		//	if(!((W3PlayerWitcher)this))
		//		Log("");
		//	
		//	
		//	if( IsInvulnerable() )
		//	{
		//		if ( theGame.CanLog() )
		//		{
		//			LogDMHits("CActor.ReduceDamage: victim Invulnerable - no damage will be dealt", damageData );
		//		}
		//		damageData.SetAllProcessedDamageAs(0);
		//		return;
		//	}
		//	
		//	if(actorAttacker && damageData.DealsAnyDamage() )
		//		actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
		//	
		//	
		//	if( IsImmortal() )
		//	{
		//		if ( theGame.CanLog() )
		//		{
		//			LogDMHits("CActor.ReduceDamage: victim is Immortal, clamping damage", damageData );
		//		}
		//		damageData.processedDmg.vitalityDamage = ClampF(damageData.processedDmg.vitalityDamage, 0, GetStat(BCS_Vitality)-1 );
		//		damageData.processedDmg.essenceDamage  = ClampF(damageData.processedDmg.essenceDamage, 0, GetStat(BCS_Essence)-1 );
		//		return;
		//	}
		//}
		//else
		//{
		//	
		//	if(actorAttacker && damageData.DealsAnyDamage() )
		//		actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
		//}
	}
	
	//modSigns
	private function GetOilProtectionAgainstMonster(damageData : W3DamageAction) : float
	{
		var i : int;
		var heldWeapons : array< SItemUniqueId >;
		var weapon : SItemUniqueId;
		var resist : float;
		var attackerMonsterCategory : EMonsterCategory;
		var tmpName : name;
		var tmpBool	: bool;
		
		if( !((CActor)damageData.attacker) )
			return 0;
		
		resist = 0;
		heldWeapons = inv.GetHeldWeapons();
		
		for( i = 0; i < heldWeapons.Size(); i += 1 )
		{
			if( !inv.IsItemFists( heldWeapons[ i ] ) )
			{
				weapon = heldWeapons[ i ];
				break;
			}
		}
		
		if( !inv.IsIdValid( weapon ) )
			return 0;
		
		theGame.GetMonsterParamsForActor((CActor)damageData.attacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	
		resist = inv.GetOilProtectionAgainstMonster(weapon, attackerMonsterCategory);
		
		return resist;
	}
	
	/*timer function UndyingSkillCooldown(dt : float, id : int)
	{
		cannotUseUndyingSkill = false;
	}*/
	
	//modSigns
	public function CastFreeQuen()
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)signs[ST_Quen].entity;

		if(!quen)
			quen = (W3QuenEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation());
		
		PlayEffect( 'quen_lasting_shield_back' ); //make use of vanilla bear set effect
		
		quen.Init(signOwner, signs[ST_Quen].entity, true);
		quen.freeCast = true;
		quen.OnStarted();
		quen.OnThrowing();
		quen.OnEnded();
	}
	
	event OnTakeDamage( action : W3DamageAction)
	{
		var currVitality, rgnVitality, hpTriggerTreshold : float;
		//var healingFactor : float;
		var abilityName : name;
		var abilityCount, maxStack, itemDurability : float;
		var addAbility : bool;
		var min, max : SAbilityAttributeValue;
		//var mutagenQuen : W3SignEntity; //modSigns
		var equipped : array<SItemUniqueId>;
		var i : int;
		var killSourceName : string;
		var aerondight	: W3Effect_Aerondight;
		var phantomWeapon	: W3Effect_PhantomWeapon; //modSigns
		//var quen : W3QuenEntity; //modSigns
		var mutation5CustomEffect : SCustomEffectParams; //modSigns
		
		currVitality = GetStat(BCS_Vitality);
		killSourceName = action.GetBuffSourceName();
		
		
		if(action.processedDmg.vitalityDamage >= currVitality)
		{
			//killSourceName = action.GetBuffSourceName();
			
			
			if( killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage" )
			{			
				//modSigns: Second Life mutation will now have priority over Undying skill -> mutation changed
				/*if( IsMutationActive( EPMT_Mutation11 ) && !HasBuff( EET_Mutation11Debuff ) && !IsInAir() )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );

					action.SetAllProcessedDamageAs( 0 );
					
					OnMutation11Triggered();					
				}
				else*/ if(/*!cannotUseUndyingSkill*/ !HasBuff( EET_UndyingSkillImmortal ) && !HasBuff( EET_UndyingSkillCooldown ) && GetStat(BCS_Focus) >= 1 && CanUseSkill(S_Sword_s18) /*&& HasBuff(EET_BattleTrance)*/ )
				{
					//healingFactor = CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_factor', false, true) );
					//healingFactor *= GetStatMax(BCS_Vitality);
					//healingFactor *= GetStat(BCS_Focus);
					//healingFactor *= 1 + CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_bonus', false, true) ) * (GetSkillLevel(S_Sword_s18) - 1);
					action.SetAllProcessedDamageAs( 0 ); //modSigns
					ForceSetStat(BCS_Vitality, 1); //modSigns: heal 1 point of damage
					//DrainFocus(GetStat(BCS_Focus));
					//RemoveBuff(EET_BattleTrance);
					//cannotUseUndyingSkill = true;
					AddEffectDefault( EET_UndyingSkillImmortal, NULL, "UndyingSkill" ); //modSigns: brief immortality
					//AddTimer('UndyingSkillCooldown', CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'trigger_delay', false, true) ), false, , , true);
				}
				else
				{
					
					equipped = GetEquippedItems();
					
					for(i=0; i<equipped.Size(); i+=1)
					{
						if ( !inv.IsIdValid( equipped[i] ) )
						{
							continue;
						}
						itemDurability = inv.GetItemDurability(equipped[i]);
						if(inv.ItemHasAbility(equipped[i], 'MA_Reinforced') && itemDurability > 0)
						{
							
							inv.SetItemDurabilityScript(equipped[i], MaxF(0, itemDurability - action.processedDmg.vitalityDamage) );
							
							
							action.processedDmg.vitalityDamage = 0;
							ForceSetStat(BCS_Vitality, 1);
							
							break;
						}
					}
				}
			}
		}
		
		//modSigns: new Mutated Skin ability
		if(IsMutationActive(EPMT_Mutation5) && !action.IsDoTDamage() && action.processedDmg.vitalityDamage > 0.0 && GetStat(BCS_Focus) >= 1.0)
		{
			if(action.processedDmg.vitalityDamage < currVitality || killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage")
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation5', 'mut5_duration_per_point', min, max);
				//custom effect params
				mutation5CustomEffect.effectType = EET_Mutation5;
				mutation5CustomEffect.creator = this;
				mutation5CustomEffect.sourceName = "mutation5";
				mutation5CustomEffect.duration = min.valueAdditive * GetStat(BCS_Focus);
				mutation5CustomEffect.effectValue.valueAdditive = action.processedDmg.vitalityDamage / mutation5CustomEffect.duration;
				AddEffectCustom(mutation5CustomEffect);
				//the damage is considered to be dealt by the rest of the code (for the swords,
				//mutagens, etc to work as usual), but DrainVitality is actually omitted
				action.SetMutation5Triggered();
			}
		}
	
		
		//if(action.DealsAnyDamage() && !((W3Effect_Toxicity)action.causer) )
		//{
		//	//if(HasBuff(EET_Mutagen10))
		//	//	RemoveAbilityAll( GetBuff(EET_Mutagen10).GetAbilityName() ); //modSigns: changed
		//	
		//	//if(HasBuff(EET_Mutagen15))
		//	//	RemoveAbilityAll( GetBuff(EET_Mutagen15).GetAbilityName() ); //modSigns: changed
		//}
				
		
		/*quen = (W3QuenEntity)signs[ST_Quen].entity; //modSigns
		if(HasBuff(EET_Mutagen19) && (!quen || !quen.IsAnyQuenActive())) //modSigns
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetBuff(EET_Mutagen19).GetAbilityName(), 'max_hp_perc_trigger', min, max);
			hpTriggerTreshold = GetStatMax(BCS_Vitality) * CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			//theGame.witcherLog.AddMessage( "hpTriggerTreshold = " + hpTriggerTreshold );
			//theGame.witcherLog.AddMessage( "damage = " + action.GetDamageDealt() );
			
			if(action.GetDamageDealt() >= hpTriggerTreshold)
			{
				if(!quen) //modSigns
				{
					quen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
				}
				quen.Init( signOwner, signs[ST_Quen].entity, true );
				quen.freeCast = true; //modSigns
				quen.OnStarted();
				quen.OnThrowing();
				quen.OnEnded();
			}
		}*/ //modSigns: reworked
		
		
		/*if(action.DealsAnyDamage() && !action.IsDoTDamage() && HasBuff(EET_Mutagen27))
		{
			abilityName = GetBuff(EET_Mutagen27).GetAbilityName();
			abilityCount = GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen27_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				AddAbility(abilityName, true);
			}
		}*/ //modSigns: reworked
		
		if(HasBuff(EET_Trap) && !action.IsDoTDamage() && action.attacker.HasAbility( 'mon_dettlaff_monster_base' ))
		{
			action.AddEffectInfo(EET_Knockdown);
			RemoveBuff(EET_Trap, true);
		}		
		
		super.OnTakeDamage(action);
		
		
		//modSigns: Aerondight and Iris
		if( !action.WasDodged() && action.DealtDamage() && !action.IsDoTDamage() && !( (W3Effect_Toxicity) action.causer ) )
		{
			if( inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'Aerondight' ) )
			{
				aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
				if( aerondight /*&& aerondight.GetCurrentCount() != 0*/ )
				{
					//aerondight.ReduceAerondightStacks();
					//modSigns: now resets on damage taken
					aerondight.ResetCharges();
				}
			}
			if( inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'PhantomWeapon' ) )
			{
				phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
				if( phantomWeapon )
					phantomWeapon.ResetCharges();
			}
		}
		
		//if( !action.WasDodged() && action.DealtDamage() && !( (W3Effect_Toxicity) action.causer ) )
		//{
		//	RemoveBuff( EET_Mutation3 );
		//} //modSigns: reworked
		
		
		//modSigns: new mutation3 (Bloodbath effect)
		if(HasBuff(EET_Mutation3))
			((W3Effect_Mutation3)GetBuff(EET_Mutation3)).ManageMutation3Bonus(action);
		//modSigns: new Mutagen02 effect
		if(HasBuff(EET_Mutagen02) && !action.WasDodged() && action.DealtDamage() && action.IsActionMelee())
			((W3Mutagen02_Effect)GetBuff(EET_Mutagen02)).AddDebuffToEnemy((CActor)action.attacker);
		//modSigns: new mutagen05 effect
		if(HasBuff(EET_Mutagen05))
			((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).ManageMutagen05Bonus(action);
		//modSigns: new mutagen15 effect
		if(HasBuff(EET_Mutagen15))
			((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).ManageMutagen15Bonus(action);
		//modSigns: new mutagen22 effect
		if(HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)GetBuff(EET_Mutagen22)).RemoveMutagen22Abilities(action);
		//modSigns: new Mutagen27 effect
		if(HasBuff(EET_Mutagen27) && !action.WasDodged() && action.DealtDamage() && !(action.IsActionEnvironment() || action.IsDoTDamage()))
			((W3Mutagen27_Effect)GetBuff(EET_Mutagen27)).AccumulateHits();
	}
	
	
	
	
	
	
	
	event OnStartFistfightMinigame()
	{
		var i : int;
		var buffs : array< CBaseGameplayEffect >;
		
		
		effectManager.RemoveAllPotionEffects();
		
		abilityManager.DrainToxicity(GetStatMax( BCS_Toxicity ));
		
		buffs = GetBuffs( EET_WellFed );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		
		
		buffs.Clear();
		buffs = GetBuffs( EET_WellHydrated );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		
		super.OnStartFistfightMinigame();
	}
	
	event OnEndFistfightMinigame()
	{
		super.OnEndFistfightMinigame();
	}
	
	
	public function GetCriticalHitChance( isLightAttack : bool, isHeavyAttack : bool, target : CActor, victimMonsterCategory : EMonsterCategory, isBolt : bool ) : float
	{
		var ret : float;
		var thunder : W3Potion_Thunderbolt;
		var min, max : SAbilityAttributeValue;
		
		ret = super.GetCriticalHitChance( isLightAttack, isHeavyAttack, target, victimMonsterCategory, isBolt );
		
		
		
		
		
		
		
		thunder = ( W3Potion_Thunderbolt )GetBuff( EET_Thunderbolt );
		if( thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm )
		{
			ret += 1.0f;
		}
		
		
		if( isBolt && IsMutationActive( EPMT_Mutation9 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'critical_hit_chance', min, max);
			ret += min.valueMultiplicative;
		}
		
		
		if( isBolt && CanUseSkill( S_Sword_s07 ) )
		{
			ret += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s07);
		}
			
		return ret;
	}
	
	
	public function GetCriticalHitDamageBonus(weaponId : SItemUniqueId, victimMonsterCategory : EMonsterCategory, isStrikeAtBack : bool) : SAbilityAttributeValue
	{
		var min, max, bonus, null, oilBonus : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var monsterBonusType : name;
		
		bonus = super.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, isStrikeAtBack);
		
		if( inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) && GetStat( BCS_Focus ) >= 1 && CanUseSkill( S_Alchemy_s07 ) ) //modSigns
		{
			monsterBonusType = MonsterCategoryToAttackPowerBonus( victimMonsterCategory );
			oilBonus = inv.GetItemAttributeValue( weaponId, monsterBonusType );
			if(oilBonus != null)	
			{
				//bonus += GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true);
				//modSigns: fix crit bonus
				bonus += GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false) * GetSkillLevel(S_Alchemy_s07) * FloorF(GetStat(BCS_Focus));
			}
			//debug log
			//theGame.witcherLog.AddMessage("Crit dmg bonus: " + bonus.valueAdditive);
		}
		
		// Mutagen 11 - back strike bonus
		if (isStrikeAtBack && HasBuff(EET_Mutagen11))
		{
			mutagen = GetBuff(EET_Mutagen11);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
			bonus += GetAttributeRandomizedValue(min, max);
		}
			
		return bonus;		
	}
	
	public function ProcessLockTarget( optional newLockTarget : CActor, optional checkLeftStickHeading : bool ) : bool
	{
		var newLockTargetFound	: bool;
	
		newLockTargetFound = super.ProcessLockTarget(newLockTarget, checkLeftStickHeading);
		
		if(GetCurrentlyCastSign() == ST_Axii)
		{
			((W3AxiiEntity)GetCurrentSignEntity()).OnDisplayTargetChange(newLockTarget);
		}
		
		return newLockTargetFound;
	}
	
	
	
	
	
	
	
	 event OnProcessActionPost(action : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		var rendLoad, focusVal, stamCost, rendTimeRatio : float; //modSigns
		var value : SAbilityAttributeValue;
		var actorVictim : CActor;
		var weaponId : SItemUniqueId;
		var usesSteel, usesSilver, usesVitality, usesEssence : bool;
		var abs : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var lynxSetBuff : W3Effect_LynxSetBonus;
		var min, max, nullBonus, oilBonus : SAbilityAttributeValue; //modSigns
		var victimMonsterCategory : EMonsterCategory; //modSigns
		var monsterBonusType : name; //modSigns
		var tmpName : name; //modSigns
		var tmpBool	: bool; //modSigns
		var splitCount : int; //modSigns
		
		super.OnProcessActionPost(action);
		
		attackAction = (W3Action_Attack)action;
		actorVictim = (CActor)action.victim;
		
		if(attackAction)
		{
			if(attackAction.IsActionMelee())
			{
				
				if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
				{
					//rendLoad = GetSpecialAttackTimeRatio();
					
					
					//rendLoad = MinF(rendLoad * GetStatMax(BCS_Focus), GetStat(BCS_Focus));
					
					
					//rendLoad = FloorF(rendLoad);					
					
					//modSigns
					RendAoE(attackAction);
					
					rendTimeRatio = GetSpecialAttackTimeRatio(); //save for bear tier 2
					
					rendLoad = GetStat(BCS_Focus);

					DrainFocus(rendLoad);
					
					OnSpecialAttackHeavyActionProcess();
				}
				else if(actorVictim && IsRequiredAttitudeBetween(this, actorVictim, true)
					    && attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered()) //modSigns: only gain adrenaline for actual damage dealt
				{
					
					
					value = GetAttributeValue('focus_gain');
					
					if( FactsQuerySum("debug_fact_focus_boy") > 0 )
					{
						Debug_FocusBoyFocusGain();
					}
					
					
					if ( CanUseSkill(S_Sword_s20) )
					{
						value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
					}
					
					//modSigns
					if( CanUseSkill(S_Sword_s21) && attackAction && attackAction.IsActionMelee() && 
						IsLightAttack(attackAction.GetAttackName()) && !inv.IsItemFists(attackAction.GetWeaponId()) )
					{
						value += GetSkillAttributeValue(S_Sword_s21, 'light_focus_gain', false, true) * GetSkillLevel(S_Sword_s21);
					}
					if( CanUseSkill(S_Sword_s04) && attackAction && attackAction.IsActionMelee() && 
						IsHeavyAttack(attackAction.GetAttackName()) && !inv.IsItemFists(attackAction.GetWeaponId()) )
					{
						value += GetSkillAttributeValue(S_Sword_s04, 'heavy_focus_gain', false, true) * GetSkillLevel(S_Sword_s04);
					}
					
					//if( IsMutationActive( EPMT_Mutation3 ) && IsRequiredAttitudeBetween( this, action.victim, true ) && !action.victim.HasTag( 'Mutation3InvalidTarget' ) && !attackAction.IsParried() && !attackAction.WasDodged() && !attackAction.IsCountered() && !inv.IsItemFists( attackAction.GetWeaponId() ) && !attackAction.WasDamageReturnedToAttacker() && attackAction.DealtDamage() )
					//{
					//	AddEffectDefault( EET_Mutation3, this, "", false );
					//} //modSigns: reworked
					
					focusVal = 0.1f * (1 + CalculateAttributeValue(value));
					
					if(!inv.IsItemFists(attackAction.GetWeaponId()))
					{
						//modSigns: lynx set tier 2 bonus - doubled adrenaline gain for critical hits
						if( attackAction.IsCriticalHit() && IsSetBonusActive( EISB_Lynx_2 ) )
						{
							focusVal *= 2;
						}
						
						//modSigns: additional adrenaline for bear school perk
						focusVal += CalculateAttributeValue(GetAttributeValue('bonus_focus_gain'));
					}
					
					//modSigns: new mutation7 (Adrenaline Rush)
					//theGame.witcherLog.AddMessage("focus before adjustments: " + focusVal);
					if(HasBuff(EET_Mutation7Buff))
						focusVal *= 2;
					else if(HasBuff(EET_Mutation7Debuff))
						focusVal /= 2;
					
					//theGame.witcherLog.AddMessage("melee focus gain: " + focusVal);
					
					GainStat(BCS_Focus, focusVal);
				}
				
				//modSigns: bear tier 2 stamina restore
				if(IsSetBonusActive(EISB_Bear_2) && attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered())
				{
					if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
						stamCost = rendTimeRatio * GetStatMax(BCS_Stamina);
					else if(IsHeavyAttack(attackAction.GetAttackName()))
						stamCost = GetStaminaActionCost(ESAT_HeavyAttack);
					if(stamCost > 0)
					{
						theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_2), 'stamina_attack', min, max);
						GainStat(BCS_Stamina, stamCost * min.valueAdditive);
						//theGame.witcherLog.AddMessage("stamina gain: " + (stamCost * min.valueAdditive));
					}
				}
				
				weaponId = attackAction.GetWeaponId();
				if(actorVictim && (ShouldProcessTutorial('TutorialWrongSwordSteel') || ShouldProcessTutorial('TutorialWrongSwordSilver')) && GetAttitudeBetween(actorVictim, this) == AIA_Hostile)
				{
					usesSteel = inv.IsItemSteelSwordUsableByPlayer(weaponId);
					usesSilver = inv.IsItemSilverSwordUsableByPlayer(weaponId);
					usesVitality = actorVictim.UsesVitality();
					usesEssence = actorVictim.UsesEssence();
					
					if(usesSilver && usesVitality)
					{
						FactsAdd('tut_wrong_sword_silver',1);
					}
					else if(usesSteel && usesEssence)
					{
						FactsAdd('tut_wrong_sword_steel',1);
					}
					else if(FactsQuerySum('tut_wrong_sword_steel') && usesSilver && usesEssence)
					{
						FactsAdd('tut_proper_sword_silver',1);
						FactsRemove('tut_wrong_sword_steel');
					}
					else if(FactsQuerySum('tut_wrong_sword_silver') && usesSteel && usesVitality)
					{
						FactsAdd('tut_proper_sword_steel',1);
						FactsRemove('tut_wrong_sword_silver');
					}
				}
				
				
				if(!action.WasDodged() && HasRunewordActive('Runeword 1 _Stats')) //modSigns
				{
					if(runewordInfusionType == ST_Axii)
					{
						actorVictim.SoundEvent('sign_axii_release');
					}
					else if(runewordInfusionType == ST_Igni)
					{
						actorVictim.SoundEvent('sign_igni_charge_begin');
					}
					else if(runewordInfusionType == ST_Quen)
					{
						value = GetAttributeValue('runeword1_quen_heal');
						Heal( action.GetDamageDealt() * value.valueMultiplicative );
						PlayEffectSingle('drain_energy_caretaker_shovel');
					}
					else if(runewordInfusionType == ST_Yrden)
					{
						actorVictim.SoundEvent('sign_yrden_shock_activate');
					}
					runewordInfusionType = ST_None;
					
					
					items = inv.GetHeldWeapons();
					weaponEnt = inv.GetItemEntityUnsafe(items[0]);
					weaponEnt.StopEffect('runeword_aard');
					weaponEnt.StopEffect('runeword_axii');
					weaponEnt.StopEffect('runeword_igni');
					weaponEnt.StopEffect('runeword_quen');
					weaponEnt.StopEffect('runeword_yrden');
				}
				
				//modSigns: Invigoration
				if(HasBuff(EET_Runeword4) && (action.IsActionMelee() || action.IsActionWitcherSign() && IsMutationActive(EPMT_Mutation1)) && action.DealsAnyDamage() && !action.IsDoTDamage())
				{
					RemoveBuff(EET_Runeword4);
					actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );
				}
				
				if(ShouldProcessTutorial('TutorialLightAttacks') || ShouldProcessTutorial('TutorialHeavyAttacks'))
				{
					if(IsLightAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsLightAttacksCount(action.victim.GetTags());
					}
					else if(IsHeavyAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsHeavyAttacksCount(action.victim.GetTags());
					}
				}
			}
			else if(attackAction.IsActionRanged())
			{
				
				if(CanUseSkill(S_Perk_02) && !attackAction.IsDoTDamage() && attackAction.DealsAnyDamage() && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered()) //modSigns: only gain adrenaline for actual damage dealt
				{				
					//value = GetSkillAttributeValue(S_Perk_02, 'focus_gain', false, true);
					//focusVal = CalculateAttributeValue(value);
					
					//modSigns: bolts give the same amount of focus as swords
					
					value = GetAttributeValue('focus_gain');
					
					if( FactsQuerySum("debug_fact_focus_boy") > 0 )
					{
						Debug_FocusBoyFocusGain();
					}
					
					if ( CanUseSkill(S_Sword_s20) )
					{
						value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
					}
					
					focusVal = 0.1f * (1 + CalculateAttributeValue(value));
					
					//modSigns: new mutation7 (Adrenaline Rush)
					if(HasBuff(EET_Mutation7Buff))
						focusVal *= 2;
					else if(HasBuff(EET_Mutation7Debuff))
						focusVal /= 2;
					
					//modSigns: split bolt
					splitCount = (int)CalculateAttributeValue(inv.GetItemAttributeValue(attackAction.GetWeaponId(), 'split_count'));
					if(splitCount > 0)
						focusVal /= splitCount;
					
					//theGame.witcherLog.AddMessage("xbow focus gain: " + focusVal);
					
					GainStat(BCS_Focus, focusVal);
				}
				
				
				if(CanUseSkill(S_Sword_s12) && attackAction.IsCriticalHit() && actorVictim)
				{
					
					actorVictim.GetCharacterStats().GetAbilities(abs, false);
					dm = theGame.GetDefinitionsManager();
					for(i=abs.Size()-1; i>=0; i-=1)
					{
						if(!dm.AbilityHasTag(abs[i], theGame.params.TAG_MONSTER_SKILL) || actorVictim.IsAbilityBlocked(abs[i]))
						{
							abs.EraseFast(i);
						}
					}
					
					
					if(abs.Size() > 0)
					{
						value = GetSkillAttributeValue(S_Sword_s12, 'duration', true, true) * GetSkillLevel(S_Sword_s12);
						actorVictim.BlockAbility(abs[ RandRange(abs.Size()) ], true, CalculateAttributeValue(value));
					}
				}
			}
		}
		
		
		//modSigns: moved sign fx to signEntity to ensure it's triggered only once per cast (and alt cast)
		if( IsMutationActive( EPMT_Mutation10 ) && ( action.IsActionMelee() /*|| action.IsActionWitcherSign()*/ ) )
		{
			PlayEffect( 'mutation_10_energy' );
		}
		
		
		if(CanUseSkill(S_Perk_18) && ((W3Petard)action.causer) && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			value = GetSkillAttributeValue(S_Perk_18, 'focus_gain', false, true);
					
			//modSigns: new mutation7 (Adrenaline Rush)
			focusVal = CalculateAttributeValue(value);
			if(HasBuff(EET_Mutation7Buff))
				focusVal *= 2;
			else if(HasBuff(EET_Mutation7Debuff))
				focusVal /= 2;
			
			//modSigns: cluster bombs
			if(CanUseSkill(S_Alchemy_s11))
			{
				splitCount = GetSkillLevel(S_Alchemy_s11) + 1;
				if(splitCount > 0)
					focusVal /= splitCount;
			}
			
			//theGame.witcherLog.AddMessage("petard focus gain: " + focusVal);
			
			GainStat(BCS_Focus, focusVal);
		}
		
		//modSigns: new mutagen01 effect
		if(HasBuff(EET_Mutagen01) && attackAction)
		{
			((W3Mutagen01_Effect)GetBuff(EET_Mutagen01)).ManageMutagen01Bonus(attackAction);
		}
		
		//modSigns: new mutagen05 effect
		if(HasBuff(EET_Mutagen05))
		{
			((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).ManageMutagen05Bonus(action);
		}
		
		//modSigns: new mutagen10 effect
		if(HasBuff(EET_Mutagen10) && attackAction)
		{
			((W3Mutagen10_Effect)GetBuff(EET_Mutagen10)).ManageMutagen10Bonus(attackAction);
		}
		
		//modSigns: new mutagen15 effect
		if(HasBuff(EET_Mutagen15))
		{
			((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).ManageMutagen15Bonus(action);
		}
		
		//modSigns: new mutagen17 effect
		if(HasBuff(EET_Mutagen17) && attackAction)
		{
			((W3Mutagen17_Effect)GetBuff(EET_Mutagen17)).ManageMutagen17Bonus(attackAction);
		}
		
		//modSigns: new lynx set tier1 bonus
		if( IsSetBonusActive( EISB_Lynx_1 ) && attackAction && attackAction.IsActionMelee() && !attackAction.WasDodged() )
		{
			//theGame.witcherLog.AddMessage("Lynx set tier 1 post action"); //debug
			if( !HasBuff( EET_LynxSetBonus ) )
			{
				AddEffectDefault( EET_LynxSetBonus, NULL, "LynxSetBuff" );
				SoundEvent( "ep2_setskill_lynx_activate" );
			}
			lynxSetBuff = (W3Effect_LynxSetBonus)GetBuff( EET_LynxSetBonus );
			lynxSetBuff.ManageLynxBonus( IsHeavyAttack( attackAction.GetAttackName() ) );
		}
	}
	
	//modSigns: rend AoE
	private function RendAoE(attackAction : W3Action_Attack)
	{
		var dmgTypes			: array< name >;
		var dmgValues			: array< float >;
		var ents				: array<CGameplayEntity>;
		var rendAoEAction		: W3DamageAction;
		var i, j				: int;
		
		if(GetStat(BCS_Focus) < 3)
			return;
		
		inv.GetWeaponDTNames(attackAction.GetWeaponId(), dmgTypes);
		for(i = 0; i < dmgTypes.Size(); i += 1)
			dmgValues.PushBack(GetTotalWeaponDamage(attackAction.GetWeaponId(), dmgTypes[i], GetInvalidUniqueId()));
		
		FindGameplayEntitiesInCylinder(ents, attackAction.victim.GetWorldPosition(), 3, 10, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
		
		for(i = 0; i < ents.Size(); i += 1)
		{
			if(ents[i] == attackAction.victim)
				continue;
			rendAoEAction = new W3DamageAction in theGame;
			rendAoEAction.Initialize(attackAction.attacker, ents[i], attackAction.causer, "RendAoE", EHRT_Heavy, CPS_AttackPower, false, false, false, false);
			rendAoEAction.SetCannotReturnDamage(true);
			rendAoEAction.SetProcessBuffsIfNoDamage(true);
			for(j = 0; j < dmgTypes.Size(); j += 1)
				rendAoEAction.AddDamage(dmgTypes[j], dmgValues[j]);
			rendAoEAction.AddEffectInfo(EET_KnockdownTypeApplicator);
			theGame.damageMgr.ProcessAction(rendAoEAction);
			ents[i].PlayEffect('yrden_shock');
			delete rendAoEAction;
		}
	}
	
	
	timer function Mutagen14Timer(dt : float, id : int)
	{
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		
		abilityName = GetBuff(EET_Mutagen14).GetAbilityName();
		abilityCount = GetAbilityCount(abilityName);
		
		if(abilityCount == 0)
		{
			addAbility = true;
		}
		else
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen14_max_stack', min, max);
			maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			if(maxStack >= 0)
			{
				addAbility = (abilityCount < maxStack);
			}
			else
			{
				addAbility = true;
			}
		}
		
		if(addAbility)
		{
			AddAbility(abilityName, true);
		}
		else
		{
			
			RemoveTimer('Mutagen14Timer');
		}
	}
	
	public final function FailFundamentalsFirstAchievementCondition()
	{
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
		
	public final function SetUsedQuenInCombat()
	{
		usedQuenInCombat = true;
	}
	
	public final function UsedQuenInCombat() : bool
	{
		return usedQuenInCombat;
	}
	
	event OnCombatStart()
	{
		var quenEntity/*, glyphQuen*/ : W3QuenEntity; //modSigns
		var focus, stamina, focusMax : float; //modSigns
		var glowTargets, moTargets, actors : array< CActor >;
		var delays : array< float >;
		var rand, i : int;
		var isHostile, isAlive, isUnconscious : bool;
		
		super.OnCombatStart();
		
		if ( IsInCombatActionFriendly() )
		{
			SetBIsCombatActionAllowed(true);
			SetBIsInputAllowed(true, 'OnCombatActionStart' );
		}
		
		
		if(HasBuff(EET_Mutagen14))
		{
			AddTimer('Mutagen14Timer', 2, true);
		}
		
		
		//if(HasBuff(EET_Mutagen15)) //modSigns: changed
		//{
		//	AddAbility(GetBuff(EET_Mutagen15).GetAbilityName(), false);
		//}
		
		//modSigns: new mutagen24 effect
		if(HasBuff(EET_Mutagen24))
			((W3Mutagen24_Effect)GetBuff(EET_Mutagen24)).ManageMutagen24Bonus();
		
		//modSigns
		if( IsSetBonusActive(EISB_KaerMorhen) && !HasBuff(EET_KaerMorhenSetBonus) )
		{
			AddEffectDefault(EET_KaerMorhenSetBonus, this, "KaerMorhenSetBonus");
		}
		
		ManageAerondightBuff( true ); //modSigns
		ManageIrisBuff( true ); //modSigns
		
		
		mutation12IsOnCooldown = false;
		
		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;		
		
		
		if(quenEntity)
		{
			usedQuenInCombat = quenEntity.IsAnyQuenActive();
		}
		else
		{
			usedQuenInCombat = false;
		}
		
		if(usedQuenInCombat || HasPotionBuff() || IsEquippedSwordUpgradedWithOil(true) || IsEquippedSwordUpgradedWithOil(false))
		{
			SetFailedFundamentalsFirstAchievementCondition(true);
		}
		else
		{
			if(IsAnyItemEquippedOnSlot(EES_PotionMutagen1) || IsAnyItemEquippedOnSlot(EES_PotionMutagen2) || IsAnyItemEquippedOnSlot(EES_PotionMutagen3) || IsAnyItemEquippedOnSlot(EES_PotionMutagen4))
				SetFailedFundamentalsFirstAchievementCondition(true);
			else
				SetFailedFundamentalsFirstAchievementCondition(false);
		}
		
		if(CanUseSkill(S_Sword_s20) && IsThreatened())
		{
			focus = GetStat(BCS_Focus);
			//modSigns
			focusMax = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s20, 'focus_add', false, true)) * GetSkillLevel(S_Sword_s20);
			if(focus < focusMax)
			{
				GainStat(BCS_Focus, focusMax - focus);
			}
		}

		if ( HasGlyphwordActive('Glyphword 17 _Stats') && (!quenEntity || !quenEntity.IsAnyQuenActive()) ) //modSigns
		{
			//stamina = GetStat(BCS_Stamina); //modSigns
			if(!quenEntity)
			{
				quenEntity = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			}
			quenEntity.glyphword17Cast = true; //modSigns
			quenEntity.Init( signOwner, signs[ST_Quen].entity, true );
			quenEntity.freeCast = true; //modSigns
			quenEntity.OnStarted();
			quenEntity.OnThrowing();
			quenEntity.OnEnded();
			//ForceSetStat(BCS_Stamina, stamina); //modSigns
		}
		
		
		MeditationForceAbort(true);
		
		
		

		
		if( IsMutationActive( EPMT_Mutation3 ) ) //modSigns: now added at combat start
		{
			AddEffectDefault( EET_Mutation3, this, "", false );
		}
		else if( IsMutationActive( EPMT_Mutation4 ) )
		{
			AddEffectDefault( EET_Mutation4, this, "combat start", false );
		}
		//else if( IsMutationActive( EPMT_Mutation5 ) && GetStat( BCS_Focus ) >= 1.f )
		//{
		//	AddEffectDefault( EET_Mutation5, this, "", false );
		//} //modSigns: mutation changed
		
		else if( IsMutationActive( EPMT_Mutation7 ) )
		{
			//
			//	
			//	RemoveTimer( 'Mutation7CombatStartHackFixGo' );
			//	
			//	
			//	AddTimer( 'Mutation7CombatStartHackFix', 1.f, true, , , , true );
			//
			//modSigns
			AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7 buff phase" );
			theGame.MutationHUDFeedback( MFT_PlayRepeat );
		}
		else if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayRepeat );
		}
		
		else if( IsMutationActive( EPMT_Mutation10 ) )
		{
			/*if( !HasBuff( EET_Mutation10 ) && GetStat( BCS_Toxicity ) > 0.f )
			{
				AddEffectDefault( EET_Mutation10, this, "Mutation 10" );
			}*/
			
			
			//PlayEffect( 'mutation_10' );
			//
			//
			//PlayEffect( 'critical_toxicity' );
			//AddTimer( 'Mutation10StopEffect', 5.f );
			////modSigns
			//if( !HasBuff( EET_Mutation10 ) )
			//{
			//	AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
			//}
			
			//modSigns: Euphoria rework
			if( GetStatPercents(BCS_Toxicity) >= GetToxicityDamageThreshold() )
				AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
		}
	}
	
	//timer function Mutation7CombatStartHackFix( dt : float, id : int )
	//{
	//	var actors : array< CActor >;
	//	
	//	actors = GetEnemies();
	//	
	//	if( actors.Size() > 0 )
	//	{
	//		
	//		AddTimer( 'Mutation7CombatStartHackFixGo', 0.5f );
	//		RemoveTimer( 'Mutation7CombatStartHackFix' );
	//	}
	//}
	//
	//timer function Mutation7CombatStartHackFixGo( dt : float, id : int )
	//{
	//	var actors : array< CActor >;
	//	
	//	if( IsMutationActive( EPMT_Mutation7 ) )
	//	{
	//		actors = GetEnemies();
	//		
	//		if( actors.Size() > 1 )
	//		{		
	//			AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7, combat start" );			
	//		}
	//	}
	//} //modSigns: redone
	
	public final function IsInFistFight() : bool
	{
		var enemies : array< CActor >;
		var i, j : int;
		var invent : CInventoryComponent;
		var weapons : array< SItemUniqueId >;
		
		if( IsInFistFightMiniGame() )
		{
			return true;
		}
		
		enemies = GetEnemies();
		for( i=0; i<enemies.Size(); i+=1 )
		{
			weapons.Clear();
			invent = enemies[i].GetInventory();
			weapons = invent.GetHeldWeapons();
			
			for( j=0; j<weapons.Size(); j+=1 )
			{
				if( invent.IsItemFists( weapons[j] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	timer function Mutation10StopEffect( dt : float, id : int )
	{
		StopEffect( 'critical_toxicity' );
	}
	
	
	event OnCombatFinished()
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var disableAutoSheathe : bool;
		
		super.OnCombatFinished();
		
		//modSigns: cleanup mutagens
		if(HasBuff(EET_Mutagen01))
			((W3Mutagen01_Effect)GetBuff(EET_Mutagen01)).RemoveMutagen01Abilities();
		if(HasBuff(EET_Mutagen05))
			((W3Mutagen05_Effect)GetBuff(EET_Mutagen05)).RemoveMutagen05AbilitiesAll();
		if(HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)GetBuff(EET_Mutagen10)).RemoveMutagen10Abilities();
		if(HasBuff(EET_Mutagen12))
			((W3Mutagen12_Effect)GetBuff(EET_Mutagen12)).ManageAdditionalBonus();
		if(HasBuff(EET_Mutagen13))
			((W3Mutagen13_Effect)GetBuff(EET_Mutagen13)).ManageMutagen13Bonus();
		if(HasBuff(EET_Mutagen15))
			((W3Mutagen15_Effect)GetBuff(EET_Mutagen15)).RemoveMutagen15AbilitiesAll();
		if(HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(HasBuff(EET_Mutagen18))
			((W3Mutagen18_Effect)GetBuff(EET_Mutagen18)).ManageMutagen18Bonus();
		if(HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)GetBuff(EET_Mutagen22)).RemoveMutagen22AbilitiesAll();
		if(HasBuff(EET_Mutagen24))
			((W3Mutagen24_Effect)GetBuff(EET_Mutagen24)).ResetMutagen24Bonus();
		
		//cleanup mutations
		RemoveBuff( EET_Mutation3 );
		RemoveBuff( EET_Mutation4 );
		//RemoveBuff( EET_Mutation5 ); //modSigns: mutation changed
		RemoveBuff( EET_Mutation7Buff );
		RemoveBuff( EET_Mutation7Debuff );
		if( IsMutationActive( EPMT_Mutation7 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
		else if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
		RemoveBuff( EET_Mutation10 );
		
		//cleanup set bonuses
		RemoveBuff( EET_LynxSetBonus );
		RemoveBuff( EET_KaerMorhenSetBonus ); //modSigns
		
		if( HasBuff( EET_Aerondight ) ) //modSigns
			RemoveBuff( EET_Aerondight );
		
		if( HasBuff( EET_PhantomWeapon ) ) //modSigns
			RemoveBuff( EET_PhantomWeapon );
		
		//cleanup runewords
		RemoveAbilityAll('Runeword 10 Buff');
		//thePlayer.abilityManager.ResetOverhealBonus();
		RemoveBuff(EET_Runeword4); //modSigns
		runewordInfusionType = ST_None;
		RemoveBuff(EET_Runeword11); //modSigns
		
		RemoveAbilityAll('Glyphword 14 _Stats'); //modSigns
		RemoveAbilityAll('Glyphword 10 _Stats'); //modSigns
		
		//begin out of combat adrenaline drain
		if(GetStat(BCS_Focus) > 0)
		{
			AddTimer('DelayedAdrenalineDrain', theGame.params.ADRENALINE_DRAIN_AFTER_COMBAT_DELAY, , , , true);
		}
		
		//profile tracker
		usedQuenInCombat = false;		
		theGame.GetGamerProfile().ResetStat(ES_FinesseKills);
		
		//sword sheathing
		LogChannel( 'OnCombatFinished', "OnCombatFinished: DelayedSheathSword timer added" ); 
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Gameplay', 'DisableAutomaticSwordSheathe' );			
		if( !disableAutoSheathe )
		{
			if ( ShouldAutoSheathSwordInstantly() )
				AddTimer( 'DelayedSheathSword', 0.5f );
			else
				AddTimer( 'DelayedSheathSword', 2.f );
		}
		
		OnBlockAllCombatTickets( false ); 
	}
	
	public function PlayHitEffect( damageAction : W3DamageAction )
	{
		var hitReactionType		: EHitReactionType;
		var isAtBack			: bool;
		
		
		if( damageAction.GetMutation4Triggered() )
		{
			hitReactionType = damageAction.GetHitReactionType();
			isAtBack = IsAttackerAtBack( damageAction.attacker );
			
			if( hitReactionType != EHRT_Heavy )
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'light_hit_back_toxic', true );					
				}
				else
				{
					damageAction.SetHitEffect( 'light_hit_toxic' );
				}
			}
			else
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'heavy_hit_back_toxic' ,true );
				}
				else
				{
					damageAction.SetHitEffect( 'heavy_hit_toxic' );
				}
			}
		}
		
		super.PlayHitEffect( damageAction );
	}
	
	timer function DelayedAdrenalineDrain(dt : float, id : int)
	{
		if ( !HasBuff(EET_Runeword8) )
			AddEffectDefault(EET_AdrenalineDrain, this, "after_combat_adrenaline_drain");
	}
	
	
	protected function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
	{
		//var mutagen17 : W3Mutagen17_Effect;
		
		//modSigns: check for mutagen17 activation
		//if(HasBuff(EET_Mutagen17))
		//{
		//	mutagen17 = (W3Mutagen17_Effect)GetBuff(EET_Mutagen17);
		//	if(mutagen17.IsBoostAvailable())
		//	{
		//		mutagen17.ActivateBoost();
		//		//theGame.witcherLog.AddMessage("mutagen17 boost activated: attack"); //modSigns: debug
		//	}
		//}
		
		super.Attack(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
		
		/*if( (CActor)hitTarget && HasBuff(EET_Mutagen17) )
		{
			mutagen17 = (W3Mutagen17_Effect)GetBuff(EET_Mutagen17);
			if(mutagen17.HasBoost())
			{
				mutagen17.ClearBoost();
			}
		}*/ //modSigns: move to other place
	}
	
	//modSigns: redone completely
	public final timer function SpecialAttackLightSustainCost(dt : float, id : int)
	{
		if(abilityManager && abilityManager.IsInitialized() && IsAlive() && HasResourcesForWhirl(dt))
		{
			PauseStaminaRegen('WhirlSkill');
			PauseFocusGain(true);
			AddTimer('ResumeFocusGain', 1.f);
			WhirlDrainResources(dt);
		}
		else
		{
			OnPerformSpecialAttack(true, false);
		}
		/*var focusPerSec, cost, delay : float;
		var reduction : SAbilityAttributeValue;
		var skillLevel : int;
		
		if(abilityManager && abilityManager.IsInitialized() && IsAlive())
		{
			PauseStaminaRegen('WhirlSkill');
			
			if(GetStat(BCS_Stamina) > 0)
			{
				cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				skillLevel = GetSkillLevel(S_Sword_s01);
				
				if(skillLevel > 1)
				{
					reduction = GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, true) * (skillLevel - 1);
					cost = MaxF(0, cost * (1 - reduction.valueMultiplicative) - reduction.valueAdditive);
				}
				
				DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s01));
			}
			else				
			{				
				GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec', false, true);
				focusPerSec = GetWhirlFocusCostPerSec();
				DrainFocus(focusPerSec * dt);
			}
		}
		
		if(GetStat(BCS_Stamina) <= 0 && GetStat(BCS_Focus) <= 0)
		{
			OnPerformSpecialAttack(true, false);
		}*/
	}
	
	/*public final function GetWhirlFocusCostPerSec() : float
	{
		var ability : SAbilityAttributeValue;
		var val : float;
		var skillLevel : int;
		
		ability = GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec_initial', false, false);
		skillLevel = GetSkillLevel(S_Sword_s01);
		
		if(skillLevel > 1)
			ability -= GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, false) * (skillLevel-1);
			
		val = CalculateAttributeValue(ability);
		
		return val;
	}*/ //modSigns: redone
	
	//modSigns
	public final function HasResourcesForWhirl(dt : float) : bool
	{
		return GetStat(BCS_Stamina) >= GetWhirlStaminaCost(dt);
	}
	
	public final function GetWhirlStaminaCost(dt : float) : float
	{
		var cost : float;
		cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
		cost *= 1 - CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_reduction_after_1', false, false)) * (GetSkillLevel(S_Sword_s01) - 1);
		if(HasBuff(EET_Mutagen04))
			cost *= 1 + ((W3Mutagen04_Effect)GetBuff(EET_Mutagen04)).GetAttackCostIncrease();
		return cost;
	}
	
	//modSigns
	private final function WhirlDrainResources(dt : float)
	{
		var delay : float;
		var cost : float;
		delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
		cost = GetWhirlStaminaCost(dt);
		DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s01));
		//calculating adrenaline drain manually, so it's not affected by stamina bonuses/penalties
		cost = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_per_sec', false, false))
			 * (1 - CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_reduction_after_1', false, false)) * (GetSkillLevel(S_Sword_s01) - 1));
		cost *= dt;
		DrainFocus(cost/GetStatMax(BCS_Stamina));
	}
	
	//modSigns
	public final function GetNumHostilesInRange() : int
	{
		var ents : array<CGameplayEntity>;
		
		FindGameplayEntitiesInRange(ents, this, 30, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
		
		return ents.Size();
	}
	
	//modSigns
	public final function GetWhirlDamageBonus() : float
	{
		var bonusCount : int;
		var ability : SAbilityAttributeValue;
		var damageBonus : float;
		
		bonusCount = Clamp(GetNumHostilesInRange() - 1, 0, 5);
		ability = GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_bonus', false, true) * GetSkillLevel(S_Sword_s01);
		damageBonus = ability.valueMultiplicative * bonusCount;
		
		return damageBonus;
	}
	
	//modSigns
	public final function GetRendPowerBonus() : float
	{
		var	rendLoad, rendBonus, rendRatio : float;
		var attackBonus, rendBonusPerPoint, staminaRendBonus : SAbilityAttributeValue;
		
		rendBonus = 0;
		//unconditional bonus
		attackBonus = GetSkillAttributeValue(S_Sword_s02, 'attack_damage_bonus', false, true) * GetSkillLevel(S_Sword_s02);
		rendBonus += attackBonus.valueMultiplicative;
		//check how much of the 'gauge' player channeled
		rendRatio = GetSpecialAttackTimeRatio();
		if(rendRatio > 0)
		{
			//bonus for stamina usage (per skill level, per stamina point)
			staminaRendBonus = GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true) * GetSkillLevel(S_Sword_s02);
			rendBonus += rendRatio * GetStatMax(BCS_Stamina) * staminaRendBonus.valueMultiplicative;
		}
		//adrenaline points
		rendLoad = GetStat(BCS_Focus);
		//do not round adrenaline points, use as many as possible
		if(rendLoad > 0)
		{
			//bonus for adrenaline usage (per skill level)
			rendBonusPerPoint = GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true) * GetSkillLevel(S_Sword_s02);
			rendBonus += rendLoad * rendBonusPerPoint.valueMultiplicative;
		}
		//theGame.witcherLog.AddMessage("Rend ratio: " + rendRatio);
		//theGame.witcherLog.AddMessage("Rend load: " + rendLoad);
		//theGame.witcherLog.AddMessage("Rend bonus: " + rendBonus);
		return rendBonus;
	}
	
	//modSigns
	public final function GetRendStaminaCost(dt : float) : float
	{
		return GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s02), dt);
	}
	
	public final timer function SpecialAttackHeavySustainCost(dt : float, id : int)
	{
		var focusHighlight, ratio : float;
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		

		PauseStaminaRegen('RendSkill'); //modSigns
		
		DrainStamina(ESAT_Ability, 0, 0, GetSkillAbilityName(S_Sword_s02), dt);

		
		if(GetStat(BCS_Stamina) <= 0)
			OnPerformSpecialAttack(false, false);
			
		
		ratio = EngineTimeToFloat(theGame.GetEngineTime() - specialHeavyStartEngineTime) / specialHeavyChargeDuration;
		
		if(ratio > 0.99) //modSigns
			ratio = 1;
			
		SetSpecialAttackTimeRatio(ratio);
		
		
		//focusHighlight = ratio * GetStatMax(BCS_Focus);
		//focusHighlight = MinF(focusHighlight, GetStat(BCS_Focus));
		//focusHighlight = FloorF(focusHighlight);
		//modSigns
		/*focusHighlight = FloorF(ratio * GetStat(BCS_Focus));
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.LockFocusPoints((int)focusHighlight);
			}		
		}*/
	}
	
	public function OnSpecialAttackHeavyActionProcess()
	{
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;
		
		super.OnSpecialAttackHeavyActionProcess();

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.ResetFocusPoints();
			}		
		}
	}
	
	timer function IsSpecialLightAttackInputHeld ( time : float, id : int )
	{
		var hasResource : bool;
		
		if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
		{
			if ( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
			{
				/*if(GetStat(BCS_Stamina) > 0)
				{
					hasResource = true;
				}
				else
				{
					hasResource = (GetStat(BCS_Focus) >= GetWhirlFocusCostPerSec() * time);					
				}*/ //modSigns: redone
				hasResource = HasResourcesForWhirl(0.5f);
				
				if(hasResource)
				{
					SetupCombatAction( EBAT_SpecialAttack_Light, BS_Pressed );
					RemoveTimer('IsSpecialLightAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					//IndicateTooLowAdrenaline(); //modSigns
					SetShowToLowStaminaIndication(GetWhirlStaminaCost(0.5f));
					SoundEvent("gui_no_stamina");
					playedSpecialAttackMissingResourceSound = true;
				}
			}			
		}
		else
		{
			RemoveTimer('IsSpecialLightAttackInputHeld');
		}
	}	
	
	timer function IsSpecialHeavyAttackInputHeld ( time : float, id : int )
	{		
		var cost : float;
		
		if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
		{
			//cost = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s02, 'stamina_cost_per_sec', false, false));
			cost = GetRendStaminaCost(0.5f); //modSigns
			
			if( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
			{
				if(GetStat(BCS_Stamina) >= cost)
				{
					SetupCombatAction( EBAT_SpecialAttack_Heavy, BS_Pressed );
					RemoveTimer('IsSpecialHeavyAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					//IndicateTooLowAdrenaline(); //modSigns
					SetShowToLowStaminaIndication(cost);
					SoundEvent("gui_no_stamina");
					playedSpecialAttackMissingResourceSound = true;
				}
			}
		}
		else
		{
			RemoveTimer('IsSpecialHeavyAttackInputHeld');
		}
	}
	
	public function EvadePressed( bufferAction : EBufferActionType )
	{
		var cat : float;
		
		if( (bufferAction == EBAT_Dodge && IsActionAllowed(EIAB_Dodge)) || (bufferAction == EBAT_Roll && IsActionAllowed(EIAB_Roll)) )
		{
			//modSigns: check for stamina
			if( bufferAction == EBAT_Dodge && !HasStaminaToUseAction(ESAT_Dodge, '', 0, 0 ) ||
				bufferAction == EBAT_Roll && !HasStaminaToUseAction(ESAT_Roll, '', 0, 0 ) )
			{
				SoundEvent("gui_no_stamina");
				return;
			}
			
			if(bufferAction != EBAT_Roll && ShouldProcessTutorial('TutorialDodge'))
			{
				FactsAdd("tut_in_dodge", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}				
			else if(bufferAction == EBAT_Roll && ShouldProcessTutorial('TutorialRoll'))
			{
				FactsAdd("tut_in_roll", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}
				
			if ( GetBIsInputAllowed() )
			{			
				if ( GetBIsCombatActionAllowed() )
				{
					CriticalEffectAnimationInterrupted("Dodge 2");
					PushCombatActionOnBuffer( bufferAction, BS_Released );
					ProcessCombatActionBuffer();
				}					
				else if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( CanPlayHitAnim() && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 1");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				
				else if ( !( IsCurrentSignChanneled() ) )
				{
					
					PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
			}
			else
			{
				if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( CanPlayHitAnim() && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 3");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				LogChannel( 'InputNotAllowed', "InputNotAllowed" );
			}
		}
		else
		{
			DisplayActionDisallowedHudMessage(EIAB_Dodge);
		}
	}
		
	//modSigns
	public saved var isLowStaminaSFXPlaying : bool;
	
	public function CheckForLowStamina()
	{
		var sfxThreshold : float = theGame.params.GetLowStaminaSFXThreshold();
		var staminaPrc : float = GetStatPercents(BCS_Stamina);
		var rate : float;
	
		if(staminaPrc < sfxThreshold && !isLowStaminaSFXPlaying)
		{
			isLowStaminaSFXPlaying = true;
			//PlayEffectSingle('focus_sound_red_fx');
			if(!theSound.SoundIsBankLoaded("heartbeat02a.bnk"))
				theSound.SoundLoadBank("heartbeat02a.bnk", false);
			theSound.SoundEvent("play_heartbeat_02a_loop");
			theSound.SoundParameter("heartbeat_rate", theGame.params.GetLowStaminaSFXRate());
			theSound.SoundParameter("heartbeat_volume", theGame.params.GetLowStaminaSFXVolume());
		}
		else if(staminaPrc >= sfxThreshold && isLowStaminaSFXPlaying)
		{
			isLowStaminaSFXPlaying = false;
			//StopEffectIfActive('focus_sound_red_fx');
			theSound.SoundEvent("stop_heartbeat_02a_loop");
		}
		if(isLowStaminaSFXPlaying)
		{
			rate = (1.0f - staminaPrc / sfxThreshold) * 100.0f;
			if(theGame.params.GetLowStaminaSFXDynRate())
				theSound.SoundParameter("heartbeat_rate", rate);
			if(theGame.params.GetLowStaminaSFXDynVol())
				theSound.SoundParameter("heartbeat_volume", rate);
		}
	}
	
	public function StopLowStaminaSFX() //modSigns
	{
		isLowStaminaSFXPlaying = false;
		//StopEffectIfActive('focus_sound_red_fx');
		theSound.SoundEvent("stop_heartbeat_02a_loop");
	}
	
	public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult 		: bool = true;
		
		
		if( isInFinisher )
		{
			return false;
		}
		
		if ( action != EBAT_SpecialAttack_Heavy )
			specialAttackCamera = false;			
		
		
		if(super.ProcessCombatActionBuffer())
			return true;		
			
		switch ( action )
		{			
			case EBAT_CastSign :
			{
				switch ( stage )
				{
					case BS_Pressed : 
					{




	
	
								actionResult = this.CastSign();
								LogChannel('SignDebug', "CastSign()");
	

					} break;
					
					default : 
					{
						actionResult = false;
					} break;
				}
			} break;
			
			case EBAT_SpecialAttack_Light :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						
						actionResult = this.OnPerformSpecialAttack( true, true );
					} break;
					
					case BS_Released :
					{						
						actionResult = this.OnPerformSpecialAttack( true, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;

			case EBAT_SpecialAttack_Heavy :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						
						actionResult = this.OnPerformSpecialAttack( false, true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			default:
				return false;	
		}
		
		
		this.CleanCombatActionBuffer();
		
		if (actionResult)
		{
			SetCombatAction( action ) ;
		}
		
		return true;
	}
		
		
	event OnPerformSpecialAttack( isLightAttack : bool, enableAttack : bool ){}	
	
	public final function GetEnemies() : array< CActor >
	{
		var actors, actors2 : array<CActor>;
		var i : int;
		
		
		actors = GetWitcherPlayer().GetHostileEnemies();
		ArrayOfActorsAppendUnique( actors, GetWitcherPlayer().GetMoveTargets() );
		
		
		thePlayer.GetVisibleEnemies( actors2 );
		ArrayOfActorsAppendUnique( actors, actors2 );
		
		for( i=actors.Size()-1; i>=0; i-=1 )
		{
			if( !IsRequiredAttitudeBetween( actors[i], this, true ) )
			{
				actors.EraseFast( i );
			}
		}
		
		return actors;
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{
		super.OnPlayerTickTimer( deltaTime );
		
		if ( !IsInCombat() )
		{
			fastAttackCounter = 0;
			heavyAttackCounter = 0;			
		}		
	}
	
	
	
	
	
	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var ret : bool;
		var skill : ESkill;
	
		ret = super.PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, attackAction);
		
		if(!ret)
			return false;
		
		
		if(attackAction.IsActionMelee())
		{			
			skill = SkillNameToEnum( attackAction.GetAttackTypeName() );
			if( skill != S_SUndefined && CanUseSkill(skill))
			{
				if(IsLightAttack(animData.attackName))
					fastAttackCounter += 1;
				else
					fastAttackCounter = 0;
				
				if(IsHeavyAttack(animData.attackName))
					heavyAttackCounter += 1;
				else
					heavyAttackCounter = 0;				
			}		
		}
		
		AddTimer('FastAttackCounterDecay',5.0);
		AddTimer('HeavyAttackCounterDecay',5.0);
		
		return true;
	}
	
	protected function TestParryAndCounter(data : CPreAttackEventData, weaponId : SItemUniqueId, out parried : bool, out countered : bool) : array<CActor>
	{
		
		if(SkillNameToEnum(attackActionName) == S_Sword_s02)
			data.Can_Parry_Attack = false;
			
		return super.TestParryAndCounter(data, weaponId, parried, countered);
	}
		
	private timer function FastAttackCounterDecay(delta : float, id : int)
	{
		fastAttackCounter = 0;
	}
	
	private timer function HeavyAttackCounterDecay(delta : float, id : int)
	{
		heavyAttackCounter = 0;
	}
		
	
	public function GetCraftingSchematicsNames() : array<name>		{return craftingSchematics;}
	
	public function RemoveAllCraftingSchematics()
	{
		craftingSchematics.Clear();
	}
	
	
	function AddCraftingSchematic( nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool ) : bool
	{
		var i : int;
		
		if(!skipTutorialUpdate && ShouldProcessTutorial('TutorialCraftingGotRecipe'))
		{
			FactsAdd("tut_received_schematic");
		}
		
		for(i=0; i<craftingSchematics.Size(); i+=1)
		{
			if(craftingSchematics[i] == nam)
				return false;
			
			
			if(StrCmp(craftingSchematics[i],nam) > 0)
			{
				craftingSchematics.Insert(i,nam);
				AddCraftingHudNotification( nam, isSilent );
				theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
				return true;
			}			
		}	

		
		craftingSchematics.PushBack(nam);
		AddCraftingHudNotification( nam, isSilent );
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
		return true;	
	}
	
	function AddCraftingHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnCraftingSchematicUpdate( nam );
			}
		}
	}	
	
	function AddAlchemyHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnAlchemySchematicUpdate( nam );
			}
		}
	}
	
	public function GetExpandedCraftingCategories() : array< name >
	{
		return expandedCraftingCategories;
	}
	
	public function AddExpandedCraftingCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedCraftingCategories, category );
		}
	}

	public function RemoveExpandedCraftingCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedCraftingCategories.Remove( category );
		}
	}
	
	public function SetCraftingFilters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		craftingFilters.showCraftable = showHasIngre;
		craftingFilters.showMissingIngre = showMissingIngre;
		craftingFilters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetCraftingFilters() : SCraftingFilters
	{
		
		if ( craftingFilters.showCraftable == false && craftingFilters.showMissingIngre == false && craftingFilters.showAlreadyCrafted == false )
		{
			craftingFilters.showCraftable = true;
			craftingFilters.showMissingIngre = true;
			craftingFilters.showAlreadyCrafted = false;
		}
		
		return craftingFilters;
	}

	
	
	
	
	event OnMutation11Triggered()
	{
		var min, max : SAbilityAttributeValue;
		var healValue : float;
		var quenEntity : W3QuenEntity;
		
		
		if( IsSwimming() || IsDiving() || IsSailing() || IsUsingHorse() || IsUsingBoat() || IsUsingVehicle() || IsUsingExploration() )
		{
			
			//ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) );
			//
			//
			//theGame.MutationHUDFeedback( MFT_PlayOnce );
			//
			//
			//GCameraShake( 1.0f, , , , true, 'camera_shake_loop_lvl1_1' );
			//AddTimer( 'StopMutation11CamShake', 2.f );
			//
			//
			//theGame.VibrateControllerVeryHard( 2.f );
			//
			//
			//Mutation11ShockWave( true );
			
			
			AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		}
		else
		{
			AddEffectDefault( EET_Mutation11Buff, this, "Mutation 11", false );
		}
	}
	
	timer function StopMutation11CamShake( dt : float, id : int )
	{
		theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
	}
	
	public function Mutation12GetBonus() : float //modSigns
	{
		var min, max : SAbilityAttributeValue;
		var buffs : array< CBaseGameplayEffect >;
		
		buffs = GetDrunkMutagens("Mutation12");
		if(buffs.Size() > 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'mut12bonus', min, max);
			return buffs.Size() * min.valueAdditive;
		}
		else
			return 0;
	}
	
	private var mutation12IsOnCooldown : bool;
	
	public final function AddMutation12Decoction() //modSigns: removed, mechanic changed
	{
		//var params : SCustomEffectParams;
		//var buffs : array< EEffectType >;
		//var existingDecoctionBuffs : array<CBaseGameplayEffect>;
		//var i : int;
		//var effectType : EEffectType;
		//var decoctions : array< SItemUniqueId >;
		//var tmpName : name;
		//var min, max : SAbilityAttributeValue;
		//
		//if( mutation12IsOnCooldown )
		//{
		//	return;
		//}
		//
		//
		//existingDecoctionBuffs = GetDrunkMutagens( "Mutation12" );
		//theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
		//if( existingDecoctionBuffs.Size() >= min.valueAdditive )
		//{
		//	return;
		//}
		//
		//
		//mutation12IsOnCooldown = true;		
		//theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'cooldown', min, max );
		//AddTimer( 'Mutation12Cooldown', CalculateAttributeValue( min ) );
		//
		//
		//decoctions = inv.GetItemsByTag( 'Mutagen' );
		//
		//
		//for( i=decoctions.Size()-1; i>=0; i-=1 )
		//{
		//	inv.GetPotionItemBuffData( decoctions[i], effectType, tmpName );
		//	if( HasBuff( effectType ) )
		//	{
		//		decoctions.EraseFast( i );
		//		continue;
		//	}
		//	buffs.PushBack( effectType );
		//}
		//
		//
		//if( buffs.Size() == 0 )
		//{
		//	for( i=EET_Mutagen01; i<=EET_Mutagen28; i+=1 )
		//	{
		//		if( !HasBuff( i ) )
		//		{
		//			buffs.PushBack( i );
		//		}
		//	}
		//}
		//
		//
		////buffs.Remove( EET_Mutagen16 ); //modSigns
		////buffs.Remove( EET_Mutagen24 ); //modSigns
		//
		//
		//if( buffs.Size() == 0 )
		//{
		//	return;
		//}
		//
		//
		//theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'duration', min, max );
		//params.effectType = buffs[ RandRange( buffs.Size() ) ];
		//params.creator = this;
		//params.sourceName = "Mutation12";
		//params.duration = min.valueAdditive;
		//AddEffectCustom( params );
		//( ( W3Mutagen_Effect ) GetBuff( params.effectType, params.sourceName ) ).OverrideIcon( DecoctionEffectTypeToItemName( params.effectType ) );
		//
		//
		//if ( !IsEffectActive( 'invisible' ) )
		//{
		//	PlayEffect( 'use_potion' );
		//}
		//
		//theGame.MutationHUDFeedback( MFT_PlayOnce );
	}
	
	timer function Mutation12Cooldown( dt : float, id : int )
	{
		mutation12IsOnCooldown = false;
	}
	
	
	public final function HasResourcesToStartAnyMutationResearch() : bool
	{
		var greenPoints, redPoints, bluePoints, count : int;
		var itemIDs : array< SItemUniqueId >;
		
		if( levelManager.GetPointsFree( ESkillPoint ) > 0 )
		{
			return true;
		}
		
		
		count = inv.GetItemQuantityByName( 'Greater mutagen green' );
		if( count > 0 )
		{
			itemIDs = inv.GetItemsByName( 'Greater mutagen green' );
			greenPoints = inv.GetMutationResearchPoints( SC_Green, itemIDs[0] );
			if( greenPoints > 0 )
			{
				return true;
			}
		}	
		count = inv.GetItemQuantityByName( 'Greater mutagen red' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen red' );
			redPoints = inv.GetMutationResearchPoints( SC_Red, itemIDs[0] );
			if( redPoints > 0 )
			{
				return true;
			}
		}		
		count = inv.GetItemQuantityByName( 'Greater mutagen blue' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen blue' );
			bluePoints = inv.GetMutationResearchPoints( SC_Blue, itemIDs[0] );
			if( bluePoints > 0 )
			{
				return true;
			}
		}		
		
		return false;
	}
	
	
	public final function Mutation11StartAnimation()
	{
		
		thePlayer.ActionPlaySlotAnimationAsync( 'PLAYER_SLOT', 'geralt_mutation_11', 0.2, 0.2 );
		
		
		BlockAllActions( 'Mutation11', true );
		
		
		loopingCameraShakeAnimName = 'camera_shake_loop_lvl1_1';
		GCameraShake( 1.0f, , , , true, loopingCameraShakeAnimName );
		
		
		theGame.VibrateControllerVeryHard( 15.f );
		
		
		storedInteractionPriority = GetInteractionPriority();
		SetInteractionPriority( IP_Max_Unpushable );
	}
	
	event OnAnimEvent_Mutation11ShockWave( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		Mutation11ShockWave( false );
	}
	
	private final function Mutation11ShockWave( skipQuenSign : bool )
	{
		var action : W3DamageAction;
		var ents : array< CGameplayEntity >;
		var i, j : int;
		var damages : array< SRawDamage >;
		var quen : W3QuenEntity; //modSigns
	
		
		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 5.f, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral, this);
		
		if( ents.Size() > 0 )
		{
			damages = theGame.GetDefinitionsManager().GetDamagesFromAbility( 'Mutation11' );
		}
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			action = new W3DamageAction in theGame;
			action.Initialize( this, ents[i], NULL, "Mutation11", EHRT_Heavy, CPS_SpellPower, false, false, true, false );
			
			for( j=0; j<damages.Size(); j+=1 )
			{
				action.AddDamage( damages[j].dmgType, damages[j].dmgVal );
			}
			
			action.SetCannotReturnDamage( true );
			action.SetProcessBuffsIfNoDamage( true );
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
			action.SetHitAnimationPlayType( EAHA_ForceYes );
			action.SetCanPlayHitParticle( false );
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		
		
		
		
		mutation11QuenEntity = ( W3QuenEntity )GetSignEntity( ST_Quen );
		if( !mutation11QuenEntity )
		{
			mutation11QuenEntity = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
			mutation11QuenEntity.CreateAttachment( this, 'quen_sphere' );
			AddTimer( 'DestroyMutation11QuenEntity', 2.f );
		}
		mutation11QuenEntity.PlayHitEffect( 'quen_impulse_explode', mutation11QuenEntity.GetWorldRotation() );
		
		if( !skipQuenSign )
		{
			
			PlayEffect( 'mutation_11_second_life' );
			
			
			//RestoreQuen( 1000000.f, 10.f, true );
			
			//modSigns
			quen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			quen.Init( signOwner, signs[ST_Quen].entity, true, true );
			quen.SetAlternateCast( S_Magic_s04 );
			quen.freeCast = true;
			quen.OnStarted();
			quen.OnThrowing();
			quen.SetDataFromRestore(1000000.f, 10.f);
		}
	}
	
	private var mutation11QuenEntity : W3QuenEntity;
	private var storedInteractionPriority : EInteractionPriority;
	
	timer function DestroyMutation11QuenEntity( dt : float, id : int )
	{
		if( mutation11QuenEntity )
		{
			mutation11QuenEntity.Destroy();
		}
	}
	
	event OnAnimEvent_Mutation11AnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd )
		{
			
			BlockAllActions( 'Mutation11', false );			
			
			
			theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
			
			
			theGame.StopVibrateController();
			
			
			SetInteractionPriority( storedInteractionPriority );
			
			
			RemoveBuff( EET_Mutation11Buff, true );
		}
		else if ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle )
		{
			
			SetBehaviorVariable( 'AIControlled', 0.f );
		}
	}
	
	//modSigns
	public final function Mutation11GetBaseStrength() : float
	{
		var drainStrength : float;
		var swordDmg, avAP, avSI : float;
		var abl : SAbilityAttributeValue;
		var curStats : SPlayerOffenseStats;
		var sword : SItemUniqueId;
		
		//avSI
		abl  = GetTotalSignSpellPower(S_Magic_1);
		abl += GetTotalSignSpellPower(S_Magic_2);
		abl += GetTotalSignSpellPower(S_Magic_3);
		abl += GetTotalSignSpellPower(S_Magic_4);
		abl += GetTotalSignSpellPower(S_Magic_5);
		avSI = MaxF(0.0, abl.valueMultiplicative / 5.0 - 1.0) * 100;
		//theGame.witcherLog.AddMessage("Mutation11 avSI = " + avSI);
		//avAP
		curStats = GetOffenseStatsList();
		avAP = MaxF(0.0,
					(	curStats.steelFastAP * (1 - curStats.steelFastCritChance/100.0) + curStats.steelFastCritAP * curStats.steelFastCritChance/100.0
					+	curStats.silverFastAP * (1 - curStats.silverFastCritChance/100.0) + curStats.silverFastCritAP * curStats.silverFastCritChance/100.0
					+	curStats.steelStrongAP * (1 - curStats.steelStrongCritChance/100.0) + curStats.steelStrongCritAP * curStats.steelStrongCritChance/100.0
					+	curStats.silverStrongAP * (1 - curStats.silverStrongCritChance/100.0) + curStats.silverStrongCritAP * curStats.silverStrongCritChance/100.0
					)/4.0
			) * 100;
		//theGame.witcherLog.AddMessage("Mutation11 avAP = " + avAP);
		//swordDmg
		sword = inv.GetCurrentlyHeldSword();
		if( sword == GetInvalidUniqueId() )
		{
			GetItemEquippedOnSlot(EES_SteelSword, sword);
			if( sword == GetInvalidUniqueId() )
				GetItemEquippedOnSlot(EES_SilverSword, sword);
		}
		if( sword != GetInvalidUniqueId() )
		{
			if( inv.GetItemCategory(sword) == 'steelsword' )
				swordDmg = GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
			else if( inv.GetItemCategory(sword) == 'silversword' )
				swordDmg = GetTotalWeaponDamage(sword, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
		}
		//theGame.witcherLog.AddMessage("Mutation11 swordDmg = " + swordDmg);
		drainStrength = swordDmg + avAP + avSI;
		//theGame.witcherLog.AddMessage("Mutation11 drainStrength = " + drainStrength);
		return drainStrength;
	}
		
	public final function MutationSystemEnable( enable : bool )
	{
		( ( W3PlayerAbilityManager ) abilityManager ).MutationSystemEnable( enable );
	}
	
	public final function IsMutationSystemEnabled() : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationSystemEnabled();
	}
	
	public final function GetMutation( mutationType : EPlayerMutationType ) : SMutation
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutation( mutationType );
	}
	
	public final function IsMutationActive( mutationType : EPlayerMutationType) : bool
	{
		var swordQuality : int;
		var sword : SItemUniqueId;
		
		if( GetEquippedMutationType() != mutationType )
		{
			return false;
		}
		
		switch( mutationType )
		{
			case EPMT_Mutation4 :
			case EPMT_Mutation5 :
			case EPMT_Mutation7 :
			case EPMT_Mutation8 :
			case EPMT_Mutation10 :
			case EPMT_Mutation11 :
			case EPMT_Mutation12 :
				if( IsInFistFight() )
				{
					return false;
				}
		}
		
		if( mutationType == EPMT_Mutation1 )
		{
			sword = inv.GetCurrentlyHeldSword();			
			swordQuality = inv.GetItemQuality( sword );
			
			
			if( swordQuality < 3 )
			{
				return false;
			}
		}
		
		return true;
	}
		
	public final function SetEquippedMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).SetEquippedMutation( mutationType );
	}
	
	public final function GetEquippedMutationType() : EPlayerMutationType
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetEquippedMutationType();
	}
	
	public final function CanEquipMutation(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanEquipMutation( mutationType );
	}
	
	public final function CanResearchMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanResearchMutation( mutationType );
	}
	
	public final function IsMutationResearched(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationResearched( mutationType );
	}
	
	public final function GetMutationResearchProgress(mutationType : EPlayerMutationType) : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutationResearchProgress( mutationType );
	}
	
	public final function GetMasterMutationStage() : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMasterMutationStage();
	}
	
	public final function MutationResearchWithSkillPoints(mutation : EPlayerMutationType, skillPoints : int) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithSkillPoints( mutation, skillPoints );
	}
	
	public final function MutationResearchWithItem(mutation : EPlayerMutationType, item : SItemUniqueId, optional count: int) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithItem( mutation, item, count );
	}
	
	public final function GetMutationLocalizedName( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationNameLocalizationKey( mutationType );
		
		return GetLocStringByKeyExt( locKey );
	}
	
	public final function GetMutationLocalizedDescription( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
		var arrStr : array< string >;
		var dm : CDefinitionsManagerAccessor;
		var min, max, sp : SAbilityAttributeValue;
		var tmp, tmp2, tox, critBonusDamage, val : float;
		var stats, stats2 : SPlayerOffenseStats;
		var buffPerc, exampleEnemyCount, debuffPerc : int;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationDescriptionLocalizationKey( mutationType );
		dm = theGame.GetDefinitionsManager();
		
		switch( mutationType )
		{
			case EPMT_Mutation1 :
				dm.GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);							
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * min.valueAdditive ) ) );
				break;
				
			case EPMT_Mutation2 :
				sp = GetPowerStatValue( CPS_SpellPower );
				
				
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_chance_factor', min, max );
				//arrStr.PushBack( NoTrailZeros( RoundMath( 100 * ( min.valueAdditive + sp.valueMultiplicative * min.valueMultiplicative ) ) ) );
				//modSigns: changing the formula
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * ( ClampF(min.valueAdditive + SignPowerStatToPowerBonus(sp.valueMultiplicative) * min.valueMultiplicative, 0.f, 1.f) ) ) ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_damage_factor', min, max );
				//critBonusDamage = sp.valueMultiplicative * min.valueMultiplicative;
				//modSigns: changing the formula
				critBonusDamage = min.valueAdditive + SignPowerStatToPowerBonus(sp.valueMultiplicative) * min.valueMultiplicative;
				
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * critBonusDamage ) ) );
				break;
				
			case EPMT_Mutation3 : //modSigns: mutation reworked
			
				dm.GetAbilityAttributeValue('Mutation3', 'attack_power', min, max);
				tmp = min.valueMultiplicative;
				
				dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_sword', min, max);
				tmp2 = tmp * min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
				dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_other', min, max);
				tmp2 = tmp * min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
				dm.GetAbilityAttributeValue('Mutation3', 'mutation3_debuff_rate', min, max);
				tmp2 = tmp * min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
				dm.GetAbilityAttributeValue('Mutation3', 'mutation3_buff_rate_kill', min, max);
				tmp2 = tmp * min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
				dm.GetAbilityAttributeValue('Mutation3', 'mutation3_maxcap', min, max);
				tmp2 = tmp * min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp2 ) );
				
				//dm.GetAbilityAttributeValue( 'Mutation3', 'attack_power', min, max );
				//tmp = min.valueMultiplicative;
				//arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp ) ) );
				//dm.GetAbilityAttributeValue( 'Mutation3', 'maxcap', min, max );
				//arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp * min.valueAdditive ) ) );
				break;
				
			case EPMT_Mutation4 : //modSigns: mutation reworked
				
				dm.GetAbilityAttributeValue( 'Mutation4', 'toxicityRegenFactor', min, max );
				tmp = min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( tmp * 100 ) );

				dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
				tmp = min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( tmp ) );

				arrStr.PushBack( NoTrailZeros( RoundMath( tmp * GetStat( BCS_Toxicity ) ) ) );
				arrStr.PushBack( NoTrailZeros( RoundMath( tmp * GetStatMax( BCS_Toxicity ) ) ) );
				
				dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
				tmp = min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( tmp ) );

				dm.GetAbilityAttributeValue( 'Mutation4BloodDebuff', 'staminaRegen', min, max );
				tmp = AbsF( min.valueMultiplicative ) * 100;
				arrStr.PushBack( NoTrailZeros( tmp ) );
				break;
				
			case EPMT_Mutation5 :
				
				//dm.GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
				//tmp = min.valueAdditive;
				//arrStr.PushBack( NoTrailZeros( 100 * tmp ) );
				//
				//
				//arrStr.PushBack( NoTrailZeros( 100 * tmp * 3 ) );
				
				//modSigns: mutation changed
				dm.GetAbilityAttributeValue( 'Mutation5', 'mut5_duration_per_point', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive * GetStatMax(BCS_Focus) ) );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				break;
			
			case EPMT_Mutation6 :	
				//modSigns: raw and total damage
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
				arrStr.PushBack( RoundMath( 100 * min.valueMultiplicative ) );
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
				val = CalculateAttributeValue( min );
				arrStr.PushBack( RoundMath( val ) );
				sp = GetTotalSignSpellPower( S_Magic_1 );
				arrStr.PushBack( RoundMath( val * sp.valueMultiplicative ) );
			
				break;
				
			case EPMT_Mutation7 : //modSigns: changed
				
				dm.GetAbilityAttributeValue( 'Mutation7BuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				dm.GetAbilityAttributeValue( 'Mutation7Buff', 'attack_power', min, max );
				buffPerc = RoundMath( 100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( buffPerc ) );
				
				dm.GetAbilityAttributeValue( 'Mutation7DebuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
					
				dm.GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
				buffPerc = RoundMath( -100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( buffPerc ) );
				
				break;
			
			case EPMT_Mutation8 : //modSigns: changed
				
				dm.GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
				arrStr.PushBack( FloatToStringPrec( 100 * min.valueMultiplicative, 0 ) );
				
				arrStr.PushBack( FloatToStringPrec( 100 * min.valueMultiplicative * GetStatMax(BCS_Focus), 0 ) );
				
				break;
				
			case EPMT_Mutation9 : //modSigns: changed
				
				
				
				
				//stats = GetOffenseStatsList( 1 );
				//arrStr.PushBack( NoTrailZeros( RoundMath( stats.crossbowSteelDmg ) ) );
				
				
				//stats2 = GetOffenseStatsList( 2 );
				//arrStr.PushBack( NoTrailZeros( RoundMath( stats2.crossbowSteelDmg ) ) );
				
				
				//dm.GetAbilityAttributeValue( 'Mutation9', 'critical_hit_chance', min, max );
				//arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				//dm.GetAbilityAttributeValue( 'Mutation9', 'critical_damage', min, max );
				//arrStr.PushBack( NoTrailZeros( 100 * min.valueAdditive ) );
				
				dm.GetAbilityAttributeValue( 'Mutation9', 'mut9_damage', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				dm.GetAbilityAttributeValue( 'Mutation9', 'health_reduction', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				dm.GetAbilityAttributeValue( 'Mutation9', 'mut9_slowdown', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueAdditive ) );
				
				break;
				
			case EPMT_Mutation10 : //modSigns: redone
				
				//dm.GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_stat_boost', min, max );
				dm.GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_factor', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueMultiplicative ) );
				arrStr.PushBack( NoTrailZeros( RoundMath(GetToxicityDamage())) );

				theGame.GetDefinitionsManager().GetAbilityAttributeValue('ToxicityEffect', 'DirectDamage', min, max);
				tmp = min.valueMultiplicative * GetStatMax(BCS_Vitality);
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation10Effect', 'mutation10_factor', min, max);
				tmp *= 1 + min.valueMultiplicative * GetStatMax(BCS_Toxicity)/100.0;
				arrStr.PushBack( NoTrailZeros( RoundMath(tmp)) );
				
				
				//arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative * GetStatMax( BCS_Toxicity ) ) );
				
				break;
				
			case EPMT_Mutation11 : //modSigns: redone
				
				dm.GetAbilityAttributeValue( 'Mutation11BuffEffect', 'duration', min, max);
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				dm.GetAbilityAttributeValue( 'Mutation11DebuffEffect', 'duration', min, max);
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				arrStr.PushBack( NoTrailZeros( MaxF(1, Mutation11GetBaseStrength()) * GetStatMax(BCS_Focus) ) );
				
				break;
				
			case EPMT_Mutation12 : //modSigns: changed
				
				//dm.GetAbilityAttributeValue( 'Mutation12', 'duration', min, max );
				//arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );				
				
				
				dm.GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );	
				
				dm.GetAbilityAttributeValue( 'Mutation12', 'mut12bonus', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive * 100 ) );
				
				dm.GetAbilityAttributeValue( 'Mutation12', 'mut12bonus', min, max );
				arrStr.PushBack( NoTrailZeros( 1 + min.valueAdditive * 3 ) );
				break;
				
			case EPMT_MutationMaster :
				
				arrStr.PushBack( "4" );
				
				break;
		}
		
		return GetLocStringByKeyExtWithParams( locKey, , , arrStr );
	}
		
	//public final function ApplyMutation10StatBoost( out statValue : SAbilityAttributeValue )
	//{
	//	var attValue 			: SAbilityAttributeValue;
	//	var currToxicity		: float;
	//	
	//	if( IsMutationActive( EPMT_Mutation10 ) )
	//	{
	//		currToxicity = GetStat( BCS_Toxicity );
	//		if( currToxicity > 0.f )
	//		{
	//			attValue = GetAttributeValue( 'mutation10_stat_boost' );
	//			currToxicity *= attValue.valueMultiplicative;
	//			statValue.valueMultiplicative += currToxicity;
	//		}
	//	}
	//} //modSigns: redone

	
	
	
	
	

	public final function IsBookRead( bookName : name ):bool
	{
		return booksRead.Contains( bookName );
	}	
	
	public final function AddReadBook( bookName : name ):void
	{
		if( !booksRead.Contains( bookName ) )
		{
			booksRead.PushBack( bookName );
		}
	}
	
	public final function RemoveReadBook( bookName : name ):void
	{
		var idx : int = booksRead.FindFirst( bookName );
		
		if( idx > -1 )
		{
			booksRead.Erase( idx );
		}
	}
	
	
	
	
	
	
	
	public final function GetMutagenBuffs() : array< W3Mutagen_Effect >
	{
		var null : array< W3Mutagen_Effect >;
		
		if(effectManager)
		{
			return effectManager.GetMutagenBuffs();
		}
	
		return null;
	}
	
	public function GetAlchemyRecipes() : array<name>
	{
		return alchemyRecipes;
	}
		
	public function CanLearnAlchemyRecipe(recipeName : name) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var recipeNode : SCustomNode;
		var i, tmpInt : int;
		var tmpName : name;
	
		dm = theGame.GetDefinitionsManager();
		if ( dm.GetSubNodeByAttributeValueAsCName( recipeNode, 'alchemy_recipes', 'name_name', recipeName ) )
		{
			return true;
			
		}
		
		return false;
	}
	
	private final function RemoveAlchemyRecipe(recipeName : name)
	{
		alchemyRecipes.Remove(recipeName);
	}
	
	private final function RemoveAllAlchemyRecipes()
	{
		alchemyRecipes.Clear();
	}

	//modSigns: skill changed
	public function CountAlchemy18Abilities(skillLevel : int) : int
	{
		var absToAdd : int;
		var maxAbsAllowed : int;
		var names : array<name>;
		var m_alchemyManager : W3AlchemyManager;
		var recipe : SAlchemyRecipe;
		var i : int;
		
		absToAdd = 0;
		maxAbsAllowed = skillLevel * RoundMath(CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s18, 'max_abs_per_lvl_s18', false, false)));
		m_alchemyManager = new W3AlchemyManager in this;
		m_alchemyManager.Init();
		names = GetAlchemyRecipes();
		for(i = 0; i < names.Size(); i += 1)
		{
			m_alchemyManager.GetRecipe(names[i], recipe);
			//if(IsAlchemy18Recipe(recipe.cookedItemType) && GetAlchemy18RecipeLevel(recipe) <= skillLevel)
			if(absToAdd < maxAbsAllowed && IsAlchemy18Recipe(recipe.cookedItemType))
				absToAdd += 1;
		}
		
		return absToAdd;
	}
	
	//modSigns
	public function RecalcAlchemy18Abilities()
	{
		var absToAdd, curAbs : int;
		var skillName : name = SkillEnumToName(S_Alchemy_s18);
		
		if(CanUseSkill(S_Alchemy_s18))
			absToAdd = CountAlchemy18Abilities(GetSkillLevel(S_Alchemy_s18));
		else
			absToAdd = 0;
		curAbs = GetAbilityCount(skillName);
	
		if(absToAdd == 0)
			RemoveAbilityAll(skillName);
		else if(absToAdd > curAbs)
			AddAbilityMultiple(skillName, absToAdd - curAbs);
		else if(absToAdd < curAbs)
			RemoveAbilityMultiple(skillName, curAbs - absToAdd);
	}
	
	function AddAlchemyRecipe(nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool) : bool
	{
		var i, potions, bombs : int;
		var found : bool;
		var m_alchemyManager : W3AlchemyManager;
		var recipe : SAlchemyRecipe;
		var knownBombTypes : array<string>;
		var strRecipeName, recipeNameWithoutLevel : string;
		
		if(!IsAlchemyRecipe(nam))
			return false;
		
		found = false;
		for(i=0; i<alchemyRecipes.Size(); i+=1)
		{
			if(alchemyRecipes[i] == nam)
				return false;
			
			
			if(StrCmp(alchemyRecipes[i],nam) > 0)
			{
				alchemyRecipes.Insert(i,nam);
				found = true;
				AddAlchemyHudNotification(nam,isSilent);
				break;
			}			
		}	

		if(!found)
		{
			alchemyRecipes.PushBack(nam);
			AddAlchemyHudNotification(nam,isSilent);
		}
		
		m_alchemyManager = new W3AlchemyManager in this;
		m_alchemyManager.Init(alchemyRecipes);
		m_alchemyManager.GetRecipe(nam, recipe);
			
		
		//if(CanUseSkill(S_Alchemy_s18))
		//{
		//	//modSigns
		//	//if ((recipe.cookedItemType != EACIT_Bolt) && (recipe.cookedItemType != EACIT_Undefined) && (recipe.cookedItemType != EACIT_Dye) && (recipe.level <= GetSkillLevel(S_Alchemy_s18)))
		//	if(IsAlchemy18Recipe(recipe.cookedItemType) && recipe.level <= GetSkillLevel(S_Alchemy_s18))
		//		AddAbility(SkillEnumToName(S_Alchemy_s18), true);
		//	
		//}
		//modSigns: moved to another place
		RecalcAlchemy18Abilities();
		
		
		if(recipe.cookedItemType == EACIT_Bomb)
		{
			bombs = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				
				if(recipe.cookedItemType == EACIT_Bomb)
				{
					strRecipeName = NameToString(alchemyRecipes[i]);
					recipeNameWithoutLevel = StrLeft(strRecipeName, StrLen(strRecipeName)-2);
					if(!knownBombTypes.Contains(recipeNameWithoutLevel))
					{
						bombs += 1;
						knownBombTypes.PushBack(recipeNameWithoutLevel);
					}
				}
			}
			
			theGame.GetGamerProfile().SetStat(ES_KnownBombRecipes, bombs);
		}		
		
		else if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
		{
			potions = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				
				if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
				{
					potions += 1;
				}				
			}		
			theGame.GetGamerProfile().SetStat(ES_KnownPotionRecipes, potions);
		}
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_AlchemyRecipe );
				
		return true;
	}
	
	public function GetExpandedAlchemyCategories() : array< name >
	{
		return expandedAlchemyCategories;
	}
	
	public function AddExpandedAlchemyCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedAlchemyCategories, category );
		}
	}

	public function RemoveExpandedAlchemyCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedAlchemyCategories.Remove( category );
		}
	}
	
	public function SetAlchemyFilters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		alchemyFilters.showCraftable = showHasIngre;
		alchemyFilters.showMissingIngre = showMissingIngre;
		alchemyFilters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetAlchemyFilters() : SCraftingFilters
	{
		
		if ( alchemyFilters.showCraftable == false && alchemyFilters.showMissingIngre == false && alchemyFilters.showAlreadyCrafted == false )
		{
			alchemyFilters.showCraftable = true;
			alchemyFilters.showMissingIngre = true;
			alchemyFilters.showAlreadyCrafted = false;
		}

		return alchemyFilters;
	}
	
	
	
	
	
	

	public function GetExpandedBestiaryCategories() : array< name >
	{
		return expandedBestiaryCategories;
	}
	
	public function AddExpandedBestiaryCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedBestiaryCategories, category );
		}
	}

	public function RemoveExpandedBestiaryCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedBestiaryCategories.Remove( category );
		}
	}
	
	
	
	
	
	
	
	public function GetDisplayHeavyAttackIndicator() : bool
	{
		return bDispalyHeavyAttackIndicator;
	}

	public function SetDisplayHeavyAttackIndicator( val : bool ) 
	{
		bDispalyHeavyAttackIndicator = val;
	}

	public function GetDisplayHeavyAttackFirstLevelTimer() : bool
	{
		return bDisplayHeavyAttackFirstLevelTimer;
	}

	public function SetDisplayHeavyAttackFirstLevelTimer( val : bool ) 
	{
		bDisplayHeavyAttackFirstLevelTimer = val;
	}
	
	
	
	
	
	

	public function SelectQuickslotItem( slot : EEquipmentSlots )
	{
		var item : SItemUniqueId;
	
		GetItemEquippedOnSlot(slot, item);
		selectedItemId = item;			
	}	
	
	
	
	
	
	
	
	public function GetMedallion() : W3MedallionController
	{
		if ( !medallionController )
		{
			medallionController = new W3MedallionController in this;
		}
		return medallionController;
	}
	
	
	public final function HighlightObjects(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, 'HighlightedByMedalionFX', FLAG_ExcludePlayer);

		if(highlightTime == 0)
			highlightTime = 30;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(!ents[i].IsHighlighted())
			{
				ents[i].SetHighlighted( true );
				ents[i].PlayEffectSingle( 'medalion_detection_fx' );
				ents[i].AddTimer( 'MedallionEffectOff', highlightTime );
			}
		}
	}
	
	
	public final function HighlightEnemies(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;
		var catComponent : CGameplayEffectsComponent;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, , FLAG_ExcludePlayer + FLAG_OnlyAliveActors);

		if(highlightTime == 0)
			highlightTime = 5;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(IsRequiredAttitudeBetween(this, ents[i], true))
			{
				catComponent = GetGameplayEffectsComponent(ents[i]);
				if(catComponent)
				{
					catComponent.SetGameplayEffectFlag(EGEF_CatViewHiglight, true);
					ents[i].AddTimer( 'EnemyHighlightOff', highlightTime, , , , , true );
				}
			}
		}
	}	
	
	function SpawnMedallionEntity()
	{
		var rot					: EulerAngles;
		var spawnedMedallion	: CEntity;
				
		spawnedMedallion = theGame.GetEntityByTag( 'new_Witcher_medallion_FX' ); 
		
		if ( !spawnedMedallion )
			theGame.CreateEntity( medallionEntity, GetWorldPosition(), rot, true, false );
	}
	
	
	
	
	
	
	
	
	
	public final function InterruptCombatFocusMode()
	{
		if( this.GetCurrentStateName() == 'CombatFocusMode_SelectSpot' )
		{	
			SetCanPlayHitAnim( true );
			PopState();
		}
	}
	
	public final function IsInDarkPlace() : bool
	{
		var envs : array< string >;
		
		if( FactsQuerySum( "tut_in_dark_place" ) )
		{
			return true;
		}
		
		GetActiveAreaEnvironmentDefinitions( envs );
		
		if( envs.Contains( 'env_novigrad_cave' ) || envs.Contains( 'cave_catacombs' ) )
		{
			return true;
		}
		
		return false;
	}
	
	
	
	
	
	private saved var selectedPotionSlotUpper, selectedPotionSlotLower : EEquipmentSlots;
	private var potionDoubleTapTimerRunning, potionDoubleTapSlotIsUpper : bool;
		default selectedPotionSlotUpper = EES_Potion1;
		default selectedPotionSlotLower = EES_Potion2;
		default potionDoubleTapTimerRunning = false;
	
	public final function SetPotionDoubleTapRunning(b : bool, optional isUpperSlot : bool)
	{
		if(b)
		{
			AddTimer('PotionDoubleTap', 0.3);
		}
		else
		{
			RemoveTimer('PotionDoubleTap');
		}
		
		potionDoubleTapTimerRunning = b;
		potionDoubleTapSlotIsUpper = isUpperSlot;
	}
	
	public final function IsPotionDoubleTapRunning() : bool
	{
		return potionDoubleTapTimerRunning;
	}
	
	timer function PotionDoubleTap(dt : float, id : int)
	{
		potionDoubleTapTimerRunning = false;
		OnPotionDrinkInput(potionDoubleTapSlotIsUpper);
	}
	
	public final function OnPotionDrinkInput(fromUpperSlot : bool)
	{
		var slot : EEquipmentSlots;
		
		if(fromUpperSlot)
			slot = GetSelectedPotionSlotUpper();
		else
			slot = GetSelectedPotionSlotLower();
			
		DrinkPotionFromSlot(slot);
	}
	
	public final function OnPotionDrinkKeyboardsInput(slot : EEquipmentSlots)
	{
		DrinkPotionFromSlot(slot);
	}
	
	private function DrinkPotionFromSlot(slot : EEquipmentSlots):void
	{
		var item : SItemUniqueId;		
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleItemInfo;
		
		GetItemEquippedOnSlot(slot, item);
		//modSigns: disable drinking mid action
		if(IsInCombatAction() && (((int)GetBehaviorVariable('combatActionType')) == CAT_SpecialAttack || ((int)GetBehaviorVariable('combatActionType')) == CAT_CastSign && IsCurrentSignChanneled()))
		{
			DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
		}
		//modSigns: handle toxic food and drinks
		else if(!CanUseSkill(S_Perk_15) && (inv.ItemHasTag(item, 'Alcohol') || inv.ItemHasTag(item, 'Uncooked')) && !ToxicityLowEnoughToDrinkPotion(slot))
		{
			SendToxicityTooHighMessage();
		}
		else if(inv.ItemHasTag(item, 'Edibles'))
		{
			ConsumeItem( item );
		}
		else
		{			
			if (ToxicityLowEnoughToDrinkPotion(slot))
			{
				DrinkPreparedPotion(slot);
			}
			else
			{
				SendToxicityTooHighMessage();
			}
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud(); 
		if ( hud ) 
		{ 
			module = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
			if( module )
			{
				module.ForceShowElement();
			}
		}
	}
	
	private function SendToxicityTooHighMessage()
	{
		var messageText : string;
		var language : string;
		var audioLanguage : string;
		
		if (GetHudMessagesSize() < 2)
		{
			messageText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + " " + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
			
			theGame.GetGameLanguageName(audioLanguage,language);
			if (language == "AR")
			{
				messageText += (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity)) + " :";
			}
			else
			{
				messageText += ": " + (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity));
			}
			
			DisplayHudMessage(messageText);
		}
		theSound.SoundEvent("gui_global_denied");
	}
	
	public final function GetSelectedPotionSlotUpper() : EEquipmentSlots
	{
		return selectedPotionSlotUpper;
	}
	
	public final function GetSelectedPotionSlotLower() : EEquipmentSlots
	{
		return selectedPotionSlotLower;
	}
	
	
	public final function FlipSelectedPotion(isUpperSlot : bool) : bool
	{
		if(isUpperSlot)
		{
			if(selectedPotionSlotUpper == EES_Potion1 && IsAnyItemEquippedOnSlot(EES_Potion3))
			{
				selectedPotionSlotUpper = EES_Potion3;
				return true;
			}
			else if(selectedPotionSlotUpper == EES_Potion3 && IsAnyItemEquippedOnSlot(EES_Potion1))
			{
				selectedPotionSlotUpper = EES_Potion1;
				return true;
			}
		}
		else
		{
			if(selectedPotionSlotLower == EES_Potion2 && IsAnyItemEquippedOnSlot(EES_Potion4))
			{
				selectedPotionSlotLower = EES_Potion4;
				return true;
			}
			else if(selectedPotionSlotLower == EES_Potion4 && IsAnyItemEquippedOnSlot(EES_Potion2))
			{
				selectedPotionSlotLower = EES_Potion2;
				return true;
			}
		}
		
		return false;
	}
	
	public final function AddBombThrowDelay( bombId : SItemUniqueId )
	{
		var slot : EEquipmentSlots;
		
		slot = GetItemSlot( bombId );
		
		if( slot == EES_Unused )
		{
			return;
		}
			
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			remainingBombThrowDelaySlot1 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			remainingBombThrowDelaySlot2 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else
		{
			return;
		}
	}
	
	public final function GetBombDelay( slot : EEquipmentSlots ) : float
	{
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			return remainingBombThrowDelaySlot1;
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			return remainingBombThrowDelaySlot2;
		}
		
		return 0;
	}
	
	timer function BombDelay( dt : float, id : int )
	{
		remainingBombThrowDelaySlot1 = MaxF( 0.f , remainingBombThrowDelaySlot1 - dt );
		remainingBombThrowDelaySlot2 = MaxF( 0.f , remainingBombThrowDelaySlot2 - dt );
		
		if( remainingBombThrowDelaySlot1 <= 0.0f && remainingBombThrowDelaySlot2  <= 0.0f )
		{
			RemoveTimer('BombDelay');
		}
	}
	
	public function ResetCharacterDev()
	{
		ForceSetStat(BCS_Toxicity, 0); //modSigns: reset toxicity
		
		UnequipItemFromSlot(EES_SkillMutagen1);
		UnequipItemFromSlot(EES_SkillMutagen2);
		UnequipItemFromSlot(EES_SkillMutagen3);
		UnequipItemFromSlot(EES_SkillMutagen4);
		
		levelManager.ResetCharacterDev();
		((W3PlayerAbilityManager)abilityManager).ResetCharacterDev();		
	}
	
	public final function ResetMutationsDev()
	{
		levelManager.ResetMutationsDev();
		((W3PlayerAbilityManager)abilityManager).ResetMutationsDev();
	}
	
	public final function GetHeldSword() : SItemUniqueId
	{
		var i : int;
		var weapons : array< SItemUniqueId >;
		
		weapons = inv.GetHeldWeapons();
		for( i=0; i<weapons.Size(); i+=1 )
		{
			if( inv.IsItemSilverSwordUsableByPlayer( weapons[i] ) || inv.IsItemSteelSwordUsableByPlayer( weapons[i] ) )
			{
				return weapons[i];
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public function ConsumeItem( itemId : SItemUniqueId ) : bool
	{
		var itemName : name;
		var removedItem, willRemoveItem : bool;
		var edibles : array<SItemUniqueId>;
		var toSlot : EEquipmentSlots;
		var i : int;
		var equippedNewEdible : bool;
		
		itemName = inv.GetItemName( itemId );
		
		if (itemName == 'q111_imlerith_acorn' ) 
		{
			AddPoints(ESkillPoint, 2, true);
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +2");
			theSound.SoundEvent("gui_character_buy_skill"); 
		} 
		else if ( itemName == 'Clearing Potion' ) 
		{
			ResetCharacterDev();
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );
			theSound.SoundEvent("gui_character_synergy_effect"); 
		}
		else if ( itemName == 'Restoring Potion' ) 
		{
			ResetMutationsDev();
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );
			theSound.SoundEvent("gui_character_synergy_effect"); 
		}
		else if(itemName == 'Wolf Hour')
		{
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect"); 
			AddEffectDefault(EET_WolfHour, thePlayer, 'wolf hour');
		}
		else if ( itemName == 'q704_ft_golden_egg' )
		{
			AddPoints(ESkillPoint, 1, true);
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +1");
			theSound.SoundEvent("gui_character_buy_skill"); 
		} 
		else if ( itemName == 'mq7023_cake' )
		{
			this.AddAbility('mq7023_cake_vitality_bonus');
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect");
		}
		else
		{
			willRemoveItem = inv.GetItemQuantity(itemId) == 1 && !inv.ItemHasTag(itemId, 'InfiniteUse');
			
			if(willRemoveItem)
				toSlot = GetItemSlot(itemId);
				
			removedItem = super.ConsumeItem(itemId);
			
			if(willRemoveItem && removedItem)
			{
				edibles = inv.GetItemsByTag('Edibles');
				equippedNewEdible = false;
				
				
				for(i=0; i<edibles.Size(); i+=1)
				{
					if(!IsItemEquipped(edibles[i]) && !inv.ItemHasTag(edibles[i], 'Alcohol') && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
					{
						EquipItemInGivenSlot(edibles[i], toSlot, true, false);
						equippedNewEdible = true;
						break;
					}
				}
				
				
				if(!equippedNewEdible)
				{
					for(i=0; i<edibles.Size(); i+=1)
					{
						if(!IsItemEquipped(edibles[i]) && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
						{
							EquipItemInGivenSlot(edibles[i], toSlot, true, false);
							break;
						}
					}
				}
			}
		}
		
		return removedItem;
	}
	
	
	public final function GetAlcoholForAlchemicalItemsRefill() : SItemUniqueId
	{
		var alcos : array<SItemUniqueId>;
		var id : SItemUniqueId;
		var i, price, minPrice : int;
		
		alcos = inv.GetItemsByTag(theGame.params.TAG_ALCHEMY_REFILL_ALCO);
		
		if(alcos.Size() > 0)
		{
			if(inv.ItemHasTag(alcos[0], theGame.params.TAG_INFINITE_USE))
				return alcos[0];
				
			minPrice = inv.GetItemPrice(alcos[0]);
			price = minPrice;
			id = alcos[0];
			
			for(i=1; i<alcos.Size(); i+=1)
			{
				if(inv.ItemHasTag(alcos[i], theGame.params.TAG_INFINITE_USE))
					return alcos[i];
				
				price = inv.GetItemPrice(alcos[i]);
				
				if(price < minPrice)
				{
					minPrice = price;
					id = alcos[i];
				}
			}
			
			return id;
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function ClearPreviouslyUsedBolt()
	{
		previouslyUsedBolt = GetInvalidUniqueId();
	}
	
	public function ShouldUseInfiniteWaterBolts() : bool
	{
		return GetCurrentStateName() == 'Swimming' || IsSwimming() || IsDiving();
	}
	
	public function GetCurrentInfiniteBoltName( optional forceBodkin : bool, optional forceHarpoon : bool ) : name
	{
		if(!forceBodkin && (forceHarpoon || ShouldUseInfiniteWaterBolts()) )
		{
			return 'Harpoon Bolt';
		}
		return 'Bodkin Bolt';
	}
	
	
	public final function AddAndEquipInfiniteBolt(optional forceBodkin : bool, optional forceHarpoon : bool)
	{
		var bolt, bodkins, harpoons : array<SItemUniqueId>;
		var boltItemName : name;
		var i : int;
		
		
		bodkins = inv.GetItemsByName('Bodkin Bolt');
		harpoons = inv.GetItemsByName('Harpoon Bolt');
		
		for(i=bodkins.Size()-1; i>=0; i-=1)
			inv.RemoveItem(bodkins[i], inv.GetItemQuantity(bodkins[i]) );
			
		for(i=harpoons.Size()-1; i>=0; i-=1)
			inv.RemoveItem(harpoons[i], inv.GetItemQuantity(harpoons[i]) );
			
		
		
		boltItemName = GetCurrentInfiniteBoltName( forceBodkin, forceHarpoon );
		
		
		if(boltItemName == 'Bodkin Bolt' && inv.IsIdValid(previouslyUsedBolt))
		{
			bolt.PushBack(previouslyUsedBolt);
		}
		else
		{
			
			bolt = inv.AddAnItem(boltItemName, 1, true, true);
			
			
			if(boltItemName == 'Harpoon Bolt')
			{
				GetItemEquippedOnSlot(EES_Bolt, previouslyUsedBolt);
			}
		}
		
		EquipItem(bolt[0], EES_Bolt);
	}
	
	
	event OnItemGiven(data : SItemChangedData)
	{
		var m_guiManager 	: CR4GuiManager;
		
		super.OnItemGiven(data);
		
		
		if(!inv)
			inv = GetInventory();
		
		
		if(inv.IsItemEncumbranceItem(data.ids[0]))
			UpdateEncumbrance();
		
		m_guiManager = theGame.GetGuiManager();
		if(m_guiManager)
			m_guiManager.RegisterNewItem(data.ids[0]);
	}
		
	
	public final function CheckForFullyArmedAchievement()
	{
		if( HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_BEAR) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_GRYPHON) || 
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_LYNX) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_WOLF) ||
			/* modSigns */
			/*HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_VIPER)*/
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_BEAR_MINOR) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_GRYPHON_MINOR) ||
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_LYNX_MINOR) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_WOLF_MINOR)
		)
		{
			theGame.GetGamerProfile().AddAchievement(EA_FullyArmed);
		}
	}
	
	
	public final function HasAllItemsFromSet(setItemTag : name) : bool
	{
		var item : SItemUniqueId;
		
		if(!GetItemEquippedOnSlot(EES_SteelSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
		
		if(!GetItemEquippedOnSlot(EES_SilverSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Boots, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Pants, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Gloves, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Armor, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		
		/*if(setItemTag == theGame.params.ITEM_SET_TAG_BEAR || setItemTag == theGame.params.ITEM_SET_TAG_LYNX)
		{
			if(!GetItemEquippedOnSlot(EES_RangedWeapon, item) || !inv.ItemHasTag(item, setItemTag))
				return false;
		}*/ //modSigns: removed due to set changes

		return true;
	}
	
	
	
	
	public function GetTotalArmor() : SAbilityAttributeValue
	{
		var armor : SAbilityAttributeValue;
		var armorItem : SItemUniqueId;
		
		armor = super.GetTotalArmor();
		
		if(GetItemEquippedOnSlot(EES_Armor, armorItem))
		{
			
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			
			armor += inv.GetItemArmorTotal(armorItem);			
		}
		
		if(GetItemEquippedOnSlot(EES_Pants, armorItem))
		{
			
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		if(GetItemEquippedOnSlot(EES_Boots, armorItem))
		{
			
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		if(GetItemEquippedOnSlot(EES_Gloves, armorItem))
		{
			
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		return armor;
	}
	
	
	
	public function ReduceArmorDurability() : EEquipmentSlots
	{
		var r, sum : int;
		var slot : EEquipmentSlots;
		var id : SItemUniqueId;
		var prevDurMult, currDurMult, ratio : float;
	
		
		sum = theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_MISS_WEIGHT;
		
		r = RandRange(sum);
		
		if(r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT)
			slot = EES_Armor;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT)
			slot = EES_Pants;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT)
			slot = EES_Gloves;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT + theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT)
			slot = EES_Boots;
		else
			return EES_InvalidSlot;					
		
		GetItemEquippedOnSlot(slot, id);				
		ratio = inv.GetItemDurabilityRatio(id);		
		if(inv.ReduceItemDurability(id))			
		{
			prevDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			ratio = inv.GetItemDurabilityRatio(id);
			currDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			if(currDurMult != prevDurMult)
			{
				
				
				
				
			}
				
			return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	
	public function DismantleItem(dismantledItem : SItemUniqueId, toolItem : SItemUniqueId) : bool
	{
		var parts : array<SItemParts>;
		var i : int;
		
		if(!inv.IsItemDismantleKit(toolItem))
			return false;
		
		parts = inv.GetItemRecyclingParts(dismantledItem);
		
		if(parts.Size() <= 0)
			return false;
			
		for(i=0; i<parts.Size(); i+=1)
			inv.AddAnItem(parts[i].itemName, parts[i].quantity, true, false);
			
		inv.RemoveItem(toolItem);
		inv.RemoveItem(dismantledItem);
		return true;
	}
	
	
	public function GetItemEquippedOnSlot(slot : EEquipmentSlots, out item : SItemUniqueId) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
		
		item = itemSlots[slot];
		
		return inv.IsIdValid(item);
	}
	
	
	public function GetItemSlotByItemName(itemName : name) : EEquipmentSlots
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsByName(itemName);
		for(i=0; i<ids.Size(); i+=1)
		{
			slot = GetItemSlot(ids[i]);
			if(slot != EES_InvalidSlot)
				return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	
	public function GetItemSlot(item : SItemUniqueId) : EEquipmentSlots
	{
		var i : int;
		
		if(!inv.IsIdValid(item))
			return EES_InvalidSlot;
			
		for(i=0; i<itemSlots.Size(); i+=1)
			if(itemSlots[i] == item)
				return i;
		
		return EES_InvalidSlot;
	}
	
	public function GetEquippedItems() : array<SItemUniqueId>
	{
		return itemSlots;
	}
	
	public function IsItemEquipped(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return itemSlots.Contains(item);
	}

	public function IsItemHeld(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return inv.IsItemHeld(item);
	}

	
	public function IsAnyItemEquippedOnSlot(slot : EEquipmentSlots) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
			
		return inv.IsIdValid(itemSlots[slot]);
	}
	
	
	public function GetFreeQuickslot() : EEquipmentSlots
	{
		if(!inv.IsIdValid(itemSlots[EES_Quickslot1]))		return EES_Quickslot1;
		if(!inv.IsIdValid(itemSlots[EES_Quickslot2]))		return EES_Quickslot2;
		
		
		return EES_InvalidSlot;
	}
	
	
	event OnEquipItemRequested(item : SItemUniqueId, ignoreMount : bool)
	{
		var slot : EEquipmentSlots;
		
		if(inv.IsIdValid(item))
		{
			slot = inv.GetSlotForItemId(item);
				
			if (slot != EES_InvalidSlot)
			{
				
				
				EquipItemInGivenSlot(item, slot, ignoreMount);
			}
		}
	} 
	
	event OnUnequipItemRequested(item : SItemUniqueId)
	{
		UnequipItem(item);
	}
	
	
	public function EquipItem(item : SItemUniqueId, optional slot : EEquipmentSlots, optional toHand : bool) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		if(slot == EES_InvalidSlot)
		{
			slot = inv.GetSlotForItemId(item);
			
			if(slot == EES_InvalidSlot)
				return false;
		}
		
		ForceSoundAppearanceUpdate();
		
		return EquipItemInGivenSlot(item, slot, false, toHand);
	}
	
	protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		
		
		return !IsSlotPotionMutagen(slot) && category != 'usable' && category != 'potion' && category != 'petard' && !inv.ItemHasTag(item, 'PlayerUnwearable');
	}
		
	protected function ShouldMountItemWithName( itemName: name ): bool
	{
		var slot : EEquipmentSlots;
		var items : array<SItemUniqueId>;
		var category : name;
		var i : int;
		
		items = inv.GetItemsByName( itemName );
		
		category = inv.GetItemCategory( items[0] );
		
		slot = GetItemSlot( items[0] );
		
		return ShouldMount( slot, items[0], category );
	}	
	
	public function GetMountableItems( out items : array< SItemUniqueId > )
	{
		var i : int;
		var mountable : bool;
		var mountableItems : array< SItemUniqueId >;
		var slot : EEquipmentSlots;
		var category : name;
		var item: SItemUniqueId;
		
		for ( i = 0; i < items.Size(); i += 1 )
		{
			item = items[i];
		
			category = inv.GetItemCategory( item );
		
			slot = GetItemSlot( item );
		
			mountable = ShouldMount( slot, item, category );
		
			if ( mountable )
			{
				mountableItems.PushBack( items[ i ] );
			}
		}
		items = mountableItems;
	}
	
	public final function AddAndEquipItem( item : name ) : bool
	{
		var ids : array< SItemUniqueId >;
		
		ids = inv.AddAnItem( item );
		if( inv.IsIdValid( ids[ 0 ] ) )
		{
			return EquipItem( ids[ 0 ] );
		}
		
		return false;
	}
	
	public final function AddQuestMarkedSelectedQuickslotItem( sel : SSelectedQuickslotItem )
	{
		questMarkedSelectedQuickslotItems.PushBack( sel );
	}
	
	public final function GetQuestMarkedSelectedQuickslotItem( sourceName : name ) : SItemUniqueId
	{
		var i : int;
		
		for( i=0; i<questMarkedSelectedQuickslotItems.Size(); i+=1 )
		{
			if( questMarkedSelectedQuickslotItems[i].sourceName == sourceName )
			{
				return questMarkedSelectedQuickslotItems[i].itemID;
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function SwapEquippedItems(slot1 : EEquipmentSlots, slot2 : EEquipmentSlots)
	{
		var temp : SItemUniqueId;
		var pam : W3PlayerAbilityManager;
		
		temp = itemSlots[slot1];
		itemSlots[slot1] = itemSlots[slot2];
		itemSlots[slot2] = temp;
		
		if(IsSlotSkillMutagen(slot1))
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(pam)
				pam.OnSwappedMutagensPost(itemSlots[slot1], itemSlots[slot2]);
		}
	}
	
	public final function GetSlotForEquippedItem( itemID : SItemUniqueId ) : EEquipmentSlots
	{
		var i : int;
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			if( itemSlots[i] == itemID )
			{
				return i;
			}
		}
		
		return EES_InvalidSlot;
	}
	
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{			
		var i, groupID, quantity : int;
		var fistsID : array<SItemUniqueId>;
		var pam : W3PlayerAbilityManager;
		var isSkillMutagen : bool;		
		var armorEntity : CItemEntity;
		var armorMeshComponent : CComponent;
		var armorSoundIdentification : name;
		var category : name;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var otherMask, previousItemInSlot : SItemUniqueId;
		var tutStatePot : W3TutorialManagerUIHandlerStatePotions;
		var tutStateFood : W3TutorialManagerUIHandlerStateFood;
		var tutStateSecondPotionEquip : W3TutorialManagerUIHandlerStateSecondPotionEquip;
		var boltItem : SItemUniqueId;
		var aerondight : W3Effect_Aerondight;
		var phantomWeapon : W3Effect_PhantomWeapon; //modSigns
		
		if(!inv.IsIdValid(item))
		{
			LogAssert(false, "W3PlayerWitcher.EquipItemInGivenSlot: invalid item");
			return false;
		}
		if(slot == EES_InvalidSlot || slot == EES_HorseBlinders || slot == EES_HorseSaddle || slot == EES_HorseBag || slot == EES_HorseTrophy)
		{
			LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> - provided slot <<" + slot + ">> is invalid");
			return false;
		}
		if(itemSlots[slot] == item)
		{
			return true;
		}	
		
		if(!HasRequiredLevelToEquipItem(item))
		{
			
			return false;
		}
		
		//if(inv.ItemHasTag(item, 'PhantomWeapon') && !GetPhantomWeaponMgr())
		//{
		//	InitPhantomWeaponMgr();
		//} //modSigns
		
		
		if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
		{
			//modSigns: only in combat
			if(IsInCombat())
			{
				AddEffectDefault( EET_Aerondight, this, "Aerondight" );
				aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
				aerondight.Pause( 'ManageAerondightBuff' );
			}
		}		
		
		if( slot == EES_SteelSword && inv.ItemHasTag( item, 'PhantomWeapon' ) ) //modSigns
		{
			if(IsInCombat())
			{
				AddEffectDefault( EET_PhantomWeapon, this, "PhantomWeapon" );
				phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
				phantomWeapon.Pause( 'ManageIrisBuff' );
			}
		}		
		
		
		previousItemInSlot = itemSlots[slot];
		if( IsItemEquipped(item)) 
		{
			SwapEquippedItems(slot, GetItemSlot(item));
			return true;
		}
		
		
		isSkillMutagen = IsSlotSkillMutagen(slot);
		if(isSkillMutagen)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(!pam.IsSkillMutagenSlotUnlocked(slot))
			{
				return false;
			}
		}
		
		
		if(inv.IsIdValid(previousItemInSlot))
		{			
			if(!UnequipItemFromSlot(slot, true))
			{
				LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> !!");
				return false;
			}
		}		
		
		
		if(inv.IsItemMask(item))
		{
			if(slot == EES_Quickslot1)
				GetItemEquippedOnSlot(EES_Quickslot2, otherMask);
			else
				GetItemEquippedOnSlot(EES_Quickslot1, otherMask);
				
			if(inv.IsItemMask(otherMask))
				UnequipItem(otherMask);
		}
		
		if(isSkillMutagen)
		{
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		itemSlots[slot] = item;
		
		category = inv.GetItemCategory( item );
	
		
		if( !ignoreMounting && ShouldMount(slot, item, category) )
		{
			
			inv.MountItem( item, toHand, IsSlotSkillMutagen( slot ) );
		}		
		
		theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_EQUIPPED, inv.GetItemName(item), slot );
				
		if(slot == EES_RangedWeapon)
		{			
			rangedWeapon = ( Crossbow )( inv.GetItemEntityUnsafe(item) );
			if(!rangedWeapon)
				AddTimer('DelayedOnItemMount', 0.1, true);
			
			if ( IsSwimming() || IsDiving() )
			{
				GetItemEquippedOnSlot(EES_Bolt, boltItem);
				
				if(inv.IsIdValid(boltItem))
				{
					if ( !inv.ItemHasTag(boltItem, 'UnderwaterAmmo' ))
					{
						AddAndEquipInfiniteBolt(false, true);
					}
				}
				else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				{
					AddAndEquipInfiniteBolt(false, true);
				}
			}
			
			else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				AddAndEquipInfiniteBolt();
		}
		else if(slot == EES_Bolt)
		{
			if(rangedWeapon)
			{	if ( !IsSwimming() || !IsDiving() )
				{
					rangedWeapon.OnReplaceAmmo();
					rangedWeapon.OnWeaponReload();
				}
				else
				{
					DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
				}
			}
		}		
		
		else if(isSkillMutagen)
		{
			theGame.GetGuiManager().IgnoreNewItemNotifications( true );
			
			
			quantity = inv.GetItemQuantity( item );
			if( quantity > 1 )
			{
				inv.SplitItem( item, quantity - 1 );
			}
			
			pam.OnSkillMutagenEquipped(item, slot, prevSkillColor);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> equipped to slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
			
			theGame.GetGuiManager().IgnoreNewItemNotifications( false );
		}
		else if(slot == EES_Gloves && HasWeaponDrawn(false))
		{
			//PlayRuneword4FX(PW_Steel);
			//PlayRuneword4FX(PW_Silver);
			//modSigns
			if(HasBuff(EET_Runeword4))
				((W3Effect_Runeword4)GetBuff(EET_Runeword4)).PlayRuneword4FX();
		}
		
		else if( ( slot == EES_Petard1 || slot == EES_Petard2 ) && inv.IsItemBomb( GetSelectedItemId() ) )
		{
			SelectQuickslotItem( slot );
		}

		
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{					
					inv.AddItemCraftedAbility(fistsID[0], containedAbilities[i], true);
				}
			}
		}		
		
		
		if(inv.IsItemAnyArmor(item))
		{
			armorType = inv.GetArmorType(item);
			pam = (W3PlayerAbilityManager)abilityManager;
			
			pam.ManageSetArmorTypeBonus(); //modSigns
			
			if(armorType == EAT_Light)
			{
				if(CanUseSkill(S_Perk_05))
					pam.SetPerkArmorBonus(S_Perk_05);
			}
			else if(armorType == EAT_Medium)
			{
				if(CanUseSkill(S_Perk_06))
					pam.SetPerkArmorBonus(S_Perk_06);
			}
			else if(armorType == EAT_Heavy)
			{
				if(CanUseSkill(S_Perk_07))
					pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		
		UpdateItemSetBonuses( item, true );
				
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
	
		
		if(ShouldProcessTutorial('TutorialPotionCanEquip3'))
		{
			if(IsSlotPotionSlot(slot))
			{
				tutStatePot = (W3TutorialManagerUIHandlerStatePotions)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStatePot)
				{
					tutStatePot.OnPotionEquipped(inv.GetItemName(item));
				}
				
				tutStateSecondPotionEquip = (W3TutorialManagerUIHandlerStateSecondPotionEquip)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStateSecondPotionEquip)
				{
					tutStateSecondPotionEquip.OnPotionEquipped(inv.GetItemName(item));
				}
				
			}
		}
		
		if(ShouldProcessTutorial('TutorialFoodSelectTab'))
		{
			if( IsSlotPotionSlot(slot) && inv.IsItemFood(item))
			{
				tutStateFood = (W3TutorialManagerUIHandlerStateFood)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStateFood)
				{
					tutStateFood.OnFoodEquipped();
				}
			}
		}
		
		
		if(inv.IsItemSetItem(item))
		{
			CheckForFullyArmedAchievement();	
		}
		
		return true;
	}

	private function CheckHairItem()
	{
		var ids : array<SItemUniqueId>;
		var i   : int;
		var itemName : name;
		var hairApplied : bool;
		
		ids = inv.GetItemsByCategory('hair');
		
		for(i=0; i<ids.Size(); i+= 1)
		{
			itemName = inv.GetItemName( ids[i] );
			
			if( itemName != 'Preview Hair' )
			{
				if( hairApplied == false )
				{
					inv.MountItem( ids[i], false );
					hairApplied = true;
				}
				else
				{
					inv.RemoveItem( ids[i], 1 );
				}
				
			}
		}
		
		if( hairApplied == false )
		{
			ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
			inv.MountItem( ids[0], false );
		}
		
	}

	
	timer function DelayedOnItemMount( dt : float, id : int )
	{
		var crossbowID : SItemUniqueId;
		var invent : CInventoryComponent;
		
		invent = GetInventory();
		if(!invent)
			return;	
		
		
		GetItemEquippedOnSlot(EES_RangedWeapon, crossbowID);
				
		if(invent.IsIdValid(crossbowID))
		{
			
			rangedWeapon = ( Crossbow )(invent.GetItemEntityUnsafe(crossbowID) );
			
			if(rangedWeapon)
			{
				
				RemoveTimer('DelayedOnItemMount');
			}
		}
		else
		{
			
			RemoveTimer('DelayedOnItemMount');
		}
	}

	public function GetHeldItems() : array<SItemUniqueId>
	{
		var items : array<SItemUniqueId>;
		var item : SItemUniqueId;
	
		if( inv.GetItemEquippedOnSlot(EES_SilverSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);
			
		if( inv.GetItemEquippedOnSlot(EES_SteelSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_RangedWeapon, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		return items;			
	}
	
	public function MoveMutagenToSlot( item : SItemUniqueId, slotFrom : EEquipmentSlots, slotTo : EEquipmentSlots )
	{
		var pam : W3PlayerAbilityManager;
		var prevSkillColor : ESkillColor;
		var groupID : int;
		
		if( IsSlotSkillMutagen( slotTo ) )
		{	
			itemSlots[slotFrom] = GetInvalidUniqueId();
			
			
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slotFrom);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
			pam = (W3PlayerAbilityManager)abilityManager;
			pam.OnSkillMutagenUnequipped(item, slotFrom, prevSkillColor, true);
			
			
			
			EquipItemInGivenSlot( item, slotTo, false );
		}
	}
	
	
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item, bolts, id : SItemUniqueId;
		var items : array<SItemUniqueId>;
		var retBool : bool;
		var fistsID, bolt : array<SItemUniqueId>;
		var i, groupID : int;
		var pam : W3PlayerAbilityManager;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var isSwimming : bool;
		var hud 				: CR4ScriptedHud;
		var damagedItemModule 	: CR4HudModuleDamagedItems;
		
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots') || !inv.IsIdValid(itemSlots[slot]))
			return false;
			
		
		if(IsSlotSkillMutagen(slot))
		{
			
			pam = (W3PlayerAbilityManager)abilityManager;
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			PauseOilBuffs( slot == EES_SteelSword );
		}
			
		item = itemSlots[slot];
		itemSlots[slot] = GetInvalidUniqueId();
		
		
		//if(inv.ItemHasTag( item, 'PhantomWeapon' ) && GetPhantomWeaponMgr())
		//{
		//	DestroyPhantomWeaponMgr();
		//} //modSigns
		
		
		
		
		if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
		{
			RemoveBuff( EET_Aerondight );
		}
		
		if( slot == EES_SteelSword && inv.ItemHasTag( item, 'PhantomWeapon' ) ) //modSigns
		{
			RemoveBuff( EET_PhantomWeapon );
		}
		
		
		if(slot == EES_RangedWeapon)
		{
			
			this.OnRangedForceHolster( true, true );
			rangedWeapon.ClearDeployedEntity(true);
			rangedWeapon = NULL;
		
			
			if(GetItemEquippedOnSlot(EES_Bolt, bolts))
			{
				if(inv.ItemHasTag(bolts, theGame.params.TAG_INFINITE_AMMO))
				{
					inv.RemoveItem(bolts, inv.GetItemQuantity(bolts) );
				}
			}
		}
		else if(IsSlotSkillMutagen(slot))
		{			
			pam.OnSkillMutagenUnequipped(item, slot, prevSkillColor);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> unequipped from slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
		}
		
		
		if(currentlyEquipedItem == item)
		{
			currentlyEquipedItem = GetInvalidUniqueId();
			RaiseEvent('ForcedUsableItemUnequip');
		}
		if(currentlyEquipedItemL == item)
		{
			if ( currentlyUsedItemL )
			{
				currentlyUsedItemL.OnHidden( this );
			}
			HideUsableItem ( true );
		}
				
		
		if( !IsSlotPotionMutagen(slot) )
		{
			GetInventory().UnmountItem(item, true);
		}
		
		retBool = true;
				
		
		if(IsAnyItemEquippedOnSlot(EES_RangedWeapon) && slot == EES_Bolt)
		{			
			if(inv.ItemHasTag(item, theGame.params.TAG_INFINITE_AMMO))
			{
				
				inv.RemoveItem(item, inv.GetItemQuantityByName( inv.GetItemName(item) ) );
			}
			else if (!reequipped)
			{
				
				AddAndEquipInfiniteBolt();
			}
		}
		
		
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			OnEquipMeleeWeapon(PW_None, true);			
		}
		
		if(  GetSelectedItemId() == item )
		{
			ClearSelectedItemId();
		}
		
		if(inv.IsItemBody(item))
		{
			retBool = true;
		}		
		
		/*if(retBool && !reequipped)
		{
			theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_UNEQUIPPED, inv.GetItemName(item), slot );
			
			
			if(slot == EES_SteelSword && !IsAnyItemEquippedOnSlot(EES_SilverSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(slot == EES_SilverSword && !IsAnyItemEquippedOnSlot(EES_SteelSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(inv.IsItemAnyArmor(item))
			{
				if( !IsAnyItemEquippedOnSlot(EES_Armor) && !IsAnyItemEquippedOnSlot(EES_Gloves) && !IsAnyItemEquippedOnSlot(EES_Boots) && !IsAnyItemEquippedOnSlot(EES_Pants))
					RemoveBuff(EET_EnhancedArmor);
			}
		}*/ //modSigns: removed
		
		
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{
					inv.RemoveItemCraftedAbility(fistsID[0], containedAbilities[i]);
				}
			}
		}
		
		
		if(inv.IsItemAnyArmor(item))
		{
			armorType = inv.GetArmorType(item);
			pam = (W3PlayerAbilityManager)abilityManager;
			
			pam.ManageSetArmorTypeBonus(); //modSigns
			
			if(CanUseSkill(S_Perk_05) && (armorType == EAT_Light /*|| GetCharacterStats().HasAbility('Glyphword 2 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 2 _Stats')*/))
			{
				pam.SetPerkArmorBonus(S_Perk_05);
			}
			if(CanUseSkill(S_Perk_06) && (armorType == EAT_Medium /*|| GetCharacterStats().HasAbility('Glyphword 3 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 3 _Stats')*/))
			{
				pam.SetPerkArmorBonus(S_Perk_06);
			}
			if(CanUseSkill(S_Perk_07) && (armorType == EAT_Heavy /*|| GetCharacterStats().HasAbility('Glyphword 4 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 4 _Stats')*/))
			{
				pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		
		UpdateItemSetBonuses( item, false );
		
		
		if( inv.ItemHasTag( item, theGame.params.ITEM_SET_TAG_BONUS ) && !IsSetBonusActive( EISB_RedWolf_2 ) )
		{
			SkillReduceBombAmmoBonus();
		}

		if( slot == EES_Gloves )
		{
			thePlayer.DestroyEffect('runeword_4');
		}
		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			damagedItemModule = hud.GetDamagedItemModule();
			if ( damagedItemModule )
			{
				damagedItemModule.OnItemUnequippedFromSlot( slot );
			}
		}
		
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		return retBool;
	}
		
	public function UnequipItem(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
		
		return UnequipItemFromSlot( itemSlots.FindFirst(item) );
	}
	
	public function DropItem( item : SItemUniqueId, quantity : int ) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
		if(IsItemEquipped(item))
			return UnequipItem(item);
		
		return true;
	}	
	
	
	public function IsItemEquippedByName(itemName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemName(itemSlots[i]) == itemName)
				return true;

		return false;
	}

	
	public function IsItemEquippedByCategoryName(categoryName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemCategory(itemSlots[i]) == categoryName)
				return true;
				
		return false;
	}
	
	public function GetMaxRunEncumbrance(out usesHorseBonus : bool) : float
	{
		var value : float;
		
		value = CalculateAttributeValue(GetHorseManager().GetHorseAttributeValue('encumbrance', false));
		usesHorseBonus = (value > 0);
		value += CalculateAttributeValue( GetAttributeValue('encumbrance') );
		
		return value;
	}
		
	public function GetEncumbrance() : float
	{
		var i: int;
		var encumbrance : float;
		var items : array<SItemUniqueId>;
		var inve : CInventoryComponent;
	
		inve = GetInventory();			
		inve.GetAllItems(items);

		for(i=0; i<items.Size(); i+=1)
		{
			encumbrance += inve.GetItemEncumbrance( items[i] );
			
			
			
		}		
		return encumbrance;
	}
	
	
	
	public function StartInvUpdateTransaction():void
	{
		invUpdateTransaction = true;
	}
	
	public function FinishInvUpdateTransaction():void
	{
		invUpdateTransaction = false;
		
		
		
		UpdateEncumbrance();
	}
	
	
	public function UpdateEncumbrance()
	{
		var temp : bool;
		
		if (invUpdateTransaction)
		{
			
			return;
		}
		
		
		
		if ( GetEncumbrance() >= (GetMaxRunEncumbrance(temp) + 1) )
		{
			if( !HasBuff(EET_OverEncumbered) && FactsQuerySum( "DEBUG_EncumbranceBoy" ) == 0 )
			{
				AddEffectDefault(EET_OverEncumbered, NULL, "OverEncumbered");
			}
		}
		else if(HasBuff(EET_OverEncumbered))
		{
			RemoveAllBuffsOfType(EET_OverEncumbered);
		}
	}
	
	public final function GetSkillGroupIDFromIndex(idx : int) : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupIDFromIndex(idx);
			
		return -1;
	}
	
	public final function GetSkillGroupColor(groupID : int) : ESkillColor
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupColor(groupID);
			
		return SC_None;
	}
	
	public final function GetSkillGroupsCount() : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupsCount();
			
		return 0;
	}
	
	
	
	
	
	
	
	
	function CycleSelectSign( bIsCyclingLeft : bool ) : ESignType
	{
		var signOrder : array<ESignType>;
		var i : int;
		
		signOrder.PushBack( ST_Yrden );
		signOrder.PushBack( ST_Quen );
		signOrder.PushBack( ST_Igni );
		signOrder.PushBack( ST_Axii );
		signOrder.PushBack( ST_Aard );
			
		for( i = 0; i < signOrder.Size(); i += 1 )
			if( signOrder[i] == equippedSign )
				break;
		
		if(bIsCyclingLeft)
			return signOrder[ (4 + i) % 5 ];	
		else
			return signOrder[ (6 + i) % 5 ];
	}
	
	function ToggleNextSign()
	{
		SetEquippedSign(CycleSelectSign( false ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function TogglePreviousSign()
	{
		SetEquippedSign(CycleSelectSign( true ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function ProcessSignEvent( eventName : name ) : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			return signs[currentlyCastSign].entity.OnProcessSignEvent( eventName );
		}
		
		return false;
	}
	
	var findActorTargetTimeStamp : float;
	var pcModeChanneledSignTimeStamp	: float;
	event OnProcessCastingOrientation( isContinueCasting : bool )
	{
		var customOrientationTarget : EOrientationTarget;
		var checkHeading 			: float;
		var rotHeading 				: float;
		var playerToHeadingDist 	: float;
		var slideTargetActor		: CActor;
		var newLockTarget			: CActor;
		
		var enableNoTargetOrientation	: bool;
		
		var currTime : float;
		
		enableNoTargetOrientation = true;
		if ( GetDisplayTarget() && this.IsDisplayTargetTargetable() )
		{
			enableNoTargetOrientation = false;
			if ( /*theInput.GetActionValue( 'CastSignHold' ) > 0*/ TestCastSignHold() /* modSigns */ || this.IsCurrentSignChanneled() )
			{
				if ( IsPCModeEnabled() )
				{
					if ( EngineTimeToFloat( theGame.GetEngineTime() ) >  pcModeChanneledSignTimeStamp + 1.f )
						enableNoTargetOrientation = true;
				}
				else
				{
					if ( GetCurrentlyCastSign() == ST_Igni || GetCurrentlyCastSign() == ST_Axii )
					{
						slideTargetActor = (CActor)GetDisplayTarget();
						if ( slideTargetActor 
							&& ( !slideTargetActor.GetGameplayVisibility() || !CanBeTargetedIfSwimming( slideTargetActor ) || !slideTargetActor.IsAlive() ) )
						{
							SetSlideTarget( NULL );
							if ( ProcessLockTarget() )
								slideTargetActor = (CActor)slideTarget;
						}				
						
						if ( !slideTargetActor )
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
						else if ( IsThreat( slideTargetActor ) || GetCurrentlyCastSign() == ST_Axii )
							LockToTarget( true );
						else
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
					}
				}
			}

			if ( !enableNoTargetOrientation )
			{			
				customOrientationTarget = OT_Actor;
			}
		}
		
		if ( enableNoTargetOrientation )
		{
			if ( GetPlayerCombatStance() == PCS_AlertNear && /*theInput.GetActionValue( 'CastSignHold' ) > 0*/ TestCastSignHold() /* modSigns */ )
			{
				if ( GetDisplayTarget() && !slideTargetActor )
				{
					currTime = EngineTimeToFloat( theGame.GetEngineTime() );
					if ( currTime > findActorTargetTimeStamp + 1.5f )
					{
						findActorTargetTimeStamp = currTime;
						
						newLockTarget = GetScreenSpaceLockTarget( GetDisplayTarget(), 180.f, 1.f, 0.f, true );
						
						if ( newLockTarget && IsThreat( newLockTarget ) && IsCombatMusicEnabled() )
						{
							SetTarget( newLockTarget, true );
							SetMoveTargetChangeAllowed( true );
							SetMoveTarget( newLockTarget );
							SetMoveTargetChangeAllowed( false );
							SetSlideTarget( newLockTarget );							
						}	
					}
				}
				else
					ProcessLockTarget();
			}
			
			if ( wasBRAxisPushed )
				customOrientationTarget = OT_CameraOffset;
			else
			{
				if ( !lastAxisInputIsMovement || theInput.LastUsedPCInput() )
					customOrientationTarget = OT_CameraOffset;
				else if ( /*theInput.GetActionValue( 'CastSignHold' ) > 0*/ TestCastSignHold() /* modSigns */ )
				{
					if ( GetOrientationTarget() == OT_CameraOffset )
						customOrientationTarget = OT_CameraOffset;
					else if ( GetPlayerCombatStance() == PCS_AlertNear || GetPlayerCombatStance() == PCS_Guarded ) 
						customOrientationTarget = OT_CameraOffset;
					else
						customOrientationTarget = OT_Player;	
				}
				else
					customOrientationTarget = OT_CustomHeading;
			}			
		}		
		
		if ( GetCurrentlyCastSign() == ST_Quen )
		{
			if ( theInput.LastUsedPCInput() )
			{
				customOrientationTarget = OT_Camera;
			}
			else if ( IsCurrentSignChanneled() )
			{
				if ( bLAxisReleased )
					customOrientationTarget = OT_Player;
				else
					customOrientationTarget = OT_Camera;
			}
			else 
				customOrientationTarget = OT_Player;
		}	
		
		if ( GetCurrentlyCastSign() == ST_Axii && IsCurrentSignChanneled() )
		{	
			if ( slideTarget && (CActor)slideTarget )
			{
				checkHeading = VecHeading( slideTarget.GetWorldPosition() - this.GetWorldPosition() );
				rotHeading = checkHeading;
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );					
			}
			else
			{
				checkHeading = VecHeading( theCamera.GetCameraDirection() );
				rotHeading = GetHeading();
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading - 22.5, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading + 22.5, 0.0, 0.5, false );				
			}
		}		
			
		if ( IsActorLockedToTarget() )
			customOrientationTarget = OT_Actor;
		
		AddCustomOrientationTarget( customOrientationTarget, 'Signs' );
		
		if ( customOrientationTarget == OT_CustomHeading )
			SetOrientationTargetCustomHeading( GetCombatActionHeading(), 'Signs' );			
	}
	
	event OnRaiseSignEvent()
	{
		var newTarget : CActor;
	
		if ( ( !IsCombatMusicEnabled() && !CanAttackWhenNotInCombat( EBAT_CastSign, false, newTarget ) ) || ( IsOnBoat() && !IsCombatMusicEnabled() ) )
		{		
			if ( CastSignFriendly() )
				return true;
		}
		else
		{
			RaiseEvent('CombatActionFriendlyEnd');
			SetBehaviorVariable( 'SignNum', (int)equippedSign );
			SetBehaviorVariable( 'combatActionType', (int)CAT_CastSign );

			if ( IsPCModeEnabled() )
				pcModeChanneledSignTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
		
			if( RaiseForceEvent('CombatAction') )
			{
				OnCombatActionStart();
				findActorTargetTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
				theTelemetry.LogWithValueStr(TE_FIGHT_PLAYER_USE_SIGN, SignEnumToString( equippedSign ));
				return true;
			}
		}
		
		return false;
	}
	
	function CastSignFriendly() : bool
	{
		var actor : CActor;
	
		SetBehaviorVariable( 'combatActionTypeForOverlay', (int)CAT_CastSign );			
		if ( RaiseCombatActionFriendlyEvent() )
		{
						
			return true;
		}	
		
		return false;
	}
	
	function CastSign() : bool
	{
		var equippedSignStr : string;
		var newSignEnt : W3SignEntity;
		var spawnPos : Vector;
		var slotMatrix : Matrix;
		var target : CActor;
		//var mutagen17 : W3Mutagen17_Effect; //modSigns
		
		if ( IsInAir() )
		{
			return false;
		}
		
		//AddTemporarySkills(); // moved to sign entity init
		
		//modSigns: check for mutagen17 activation
		//if(HasBuff(EET_Mutagen17))
		//{
		//	mutagen17 = (W3Mutagen17_Effect)GetBuff(EET_Mutagen17);
		//	if(mutagen17.IsBoostAvailable())
		//	{
		//		mutagen17.ActivateBoost();
		//		//theGame.witcherLog.AddMessage("mutagen17 boost activated: sign"); //modSigns: debug
		//	}
		//}
		
		
		
		if(equippedSign == ST_Aard)
		{
			CalcEntitySlotMatrix('l_weapon', slotMatrix);
			spawnPos = MatrixGetTranslation(slotMatrix);
		}
		else
		{
			spawnPos = GetWorldPosition();
		}
		
		if( equippedSign == ST_Aard || equippedSign == ST_Igni )
		{
			target = GetTarget();
			if(target)
				target.SignalGameplayEvent( 'DodgeSign' );
		}
		
		newSignEnt = (W3SignEntity)theGame.CreateEntity( signs[equippedSign].template, spawnPos, GetWorldRotation() );
		return newSignEnt.Init( signOwner, signs[equippedSign].entity );
	}
	
	
	private function HAX_SignToThrowItemRestore()
	{
		var action : SInputAction;
		
		action.value = theInput.GetActionValue('ThrowItemHold');
		action.lastFrameValue = 0;
		
		if(IsPressed(action) && CanSetupCombatAction_Throw())
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowStart();
			}
			else
			{
				UsableItemStart();
			}
			
			SetThrowHold( true );
		}
	}
	
	event OnCFMCameraZoomFail(){}
		
	

	public final function GetDrunkMutagens( optional sourceName : string ) : array<CBaseGameplayEffect>
	{
		return effectManager.GetDrunkMutagens( sourceName );
	}
	
	public final function GetPotionBuffs() : array<CBaseGameplayEffect>
	{
		return effectManager.GetPotionBuffs();
	}
	
	public final function RecalcPotionsDurations()
	{
		var i : int;
		var buffs : array<CBaseGameplayEffect>;
		
		buffs = GetPotionBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			buffs[i].RecalcPotionDuration();
		}
	}

	public function StartFrenzy()
	{
		//modSigns: reworked
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
		var skillAbilityName : name;
		var skillLevel : int;
		var ratio, duration : float;
		
		isInFrenzy = true;
		skillLevel = GetSkillLevel(S_Alchemy_s16);
		skillAbilityName = SkillEnumToName(S_Alchemy_s16);
		dm.GetAbilityAttributeValue(skillAbilityName, 'slowdown_ratio', min, max);
		ratio = 1.0f - skillLevel * CalculateAttributeValue(min);
		dm.GetAbilityAttributeValue(skillAbilityName, 'slowdown_duration', min, max);
		duration = CalculateAttributeValue(min);
		
		theGame.SetTimeScale(ratio, theGame.GetTimescaleSource(ETS_SkillFrenzy), theGame.GetTimescalePriority(ETS_SkillFrenzy) );
		AddTimer('SkillFrenzyFinish', duration * ratio, , , , true);
	}
	
	timer function SkillFrenzyFinish(dt : float, optional id : int)
	{		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_SkillFrenzy) );
		isInFrenzy = false;
	}
	
	public function GetToxicityDamageThreshold() : float
	{
		var ret : float;
		
		ret = theGame.params.TOXICITY_DAMAGE_THRESHOLD;
		
		//if(CanUseSkill(S_Alchemy_s01)) //modSigns -> skill changed
		//	ret += CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s01, 'threshold', false, true)) * GetSkillLevel(S_Alchemy_s01);
		
		return ret;
	}
	
	//modSigns
	private var cachedToxDmg : float;
	public function GetToxicityDamage() : float
	{
		var min, max : SAbilityAttributeValue;
		var dmg : float;
		
		if(cachedToxDmg == 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('ToxicityEffect', 'DirectDamage', min, max);
			cachedToxDmg = min.valueMultiplicative;
		}
		dmg = cachedToxDmg * GetStatMax(BCS_Vitality);
		if(HasBuff(EET_Mutation10))
			dmg *= ((W3Effect_Mutation10)GetBuff(EET_Mutation10)).GetDrainMult();
		
		return dmg;
	}
	
	
	
	public final function AddToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).AddToxicityOffset(val);		
	}
	
	public final function SetToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).SetToxicityOffset(val);
	}
	
	public final function RemoveToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(val);		
	}
	
	//modSigns
	public final function RecalcTransmutationAbilities()
	{
		var ablName : name = GetSkillAbilityName(S_Alchemy_s13);
		var offset : float = GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true);
		var numAbls : int = GetAbilityCount(ablName);
		var targetNumAbls : int;
		
		if(!CanUseSkill(S_Alchemy_s13))
		{
			RemoveAbilityAll(ablName);
			return;
		}
		
		targetNumAbls = RoundMath(offset) * GetSkillLevel(S_Alchemy_s13);
		if(numAbls < targetNumAbls)
			AddAbilityMultiple(ablName, targetNumAbls - numAbls);
		else if(numAbls > targetNumAbls)
			RemoveAbilityMultiple(ablName, numAbls - targetNumAbls);
	}
	
	
	public final function CalculatePotionDuration(item : SItemUniqueId, isMutagenPotion : bool, optional itemName : name) : float
	{
		var duration, skillPassiveMod, mutagenSkillMod : float;
		var val, min, max : SAbilityAttributeValue;
		
		
		if(inv.IsIdValid(item))
		{
			duration = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'duration'));			
		}
		else
		{
			theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
			
		skillPassiveMod = CalculateAttributeValue(GetAttributeValue('potion_duration'));
		
		//if(isMutagenPotion && CanUseSkill(S_Alchemy_s14))
		//{
		//	val = GetSkillAttributeValue(S_Alchemy_s14, 'duration', false, true);
		//	mutagenSkillMod = val.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
		//} //modSigns: skill changed
		
		//modSigns: don't add passive skill mod to mutagen potions
		//duration = duration * (1 + skillPassiveMod + mutagenSkillMod);
		if(isMutagenPotion)
			duration = duration * (1 + mutagenSkillMod);
		else
			duration = duration * (1 + skillPassiveMod);
		
		return duration;
	}
	
	public function GetAdaptationToxReduction() : float //modSigns
	{
		var attr : SAbilityAttributeValue;
		
		if(CanUseSkill(S_Alchemy_s14))
		{
			attr = GetSkillAttributeValue(S_Alchemy_s14, 'tox_off_bonus', false, false);
			return attr.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
		}
		else
			return 0;
	}
	
	public function Mutation12FreeDecoctionAvailable() : bool //modSigns
	{
		var min, max : SAbilityAttributeValue;
		var buffs : array< CBaseGameplayEffect >;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'maxcap', min, max);
		
		buffs = GetDrunkMutagens("Mutation12");
		if(buffs.Size() < min.valueAdditive)
			return true;
		else
			return false;
	}
	
	public function ToxicityLowEnoughToDrinkPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId ) : bool
	{
		var item 				: SItemUniqueId;
		var maxTox 				: float;
		var potionToxicity 		: float;
		var toxicityOffset 		: float;
		var effectType 			: EEffectType;
		var customAbilityName 	: name;
		var adrenaline 			: float; //modSigns
		var costReduction		: SAbilityAttributeValue; //modSigns
		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
		
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
		maxTox = abilityManager.GetStatMax(BCS_Toxicity);
		potionToxicity = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity'));
		//modSigns begin
		if(CanUseSkill(S_Alchemy_s03))
		{
			potionToxicity -= CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s03, 'toxicityReduction', false, false)) * GetSkillLevel(S_Alchemy_s03);
		}
		//modSigns end
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		
		//modSigns
		if(CanUseSkill(S_Perk_13))
		{
			costReduction = GetSkillAttributeValue(S_Perk_13, 'cost_reduction', false, true);
			adrenaline = FloorF(GetStat(BCS_Focus));
			costReduction = costReduction * adrenaline;
			potionToxicity = (potionToxicity - costReduction.valueBase) * (1 - costReduction.valueMultiplicative) - costReduction.valueAdditive;
			potionToxicity = MaxF(0.f, potionToxicity);
		}
		
		//modSigns
		if(IsMutationActive(EPMT_Mutation12) && Mutation12FreeDecoctionAvailable())
		{
			toxicityOffset = 0;
		}
		else if(CanUseSkill(S_Alchemy_s14))
		{
			toxicityOffset *= MaxF(0, 1 - GetAdaptationToxReduction());
		}
		
		
		if(effectType != EET_WhiteHoney)
		{
			if(abilityManager.GetStat(BCS_Toxicity, false) + potionToxicity + toxicityOffset > maxTox )
			{
				return false;
			}
		}
		
		return true;
	}
	
	public final function HasFreeToxicityToDrinkPotion( item : SItemUniqueId, effectType : EEffectType, out finalPotionToxicity : float ) : bool
	{
		var i : int;
		var maxTox, toxicityOffset, adrenaline : float;
		var costReduction : SAbilityAttributeValue;
		
		
		if( effectType == EET_WhiteHoney )
		{
			return true;
		}
		
		
		maxTox = abilityManager.GetStatMax(BCS_Toxicity);
		finalPotionToxicity = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity'));
		//modSigns begin
		if(CanUseSkill(S_Alchemy_s03))
		{
			finalPotionToxicity -= CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s03, 'toxicityReduction', false, false)) * GetSkillLevel(S_Alchemy_s03);
		}
		//modSigns end
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		
		
		if(CanUseSkill(S_Perk_13))
		{
			costReduction = GetSkillAttributeValue(S_Perk_13, 'cost_reduction', false, true);
			adrenaline = FloorF(GetStat(BCS_Focus));
			costReduction = costReduction * adrenaline;
			finalPotionToxicity = (finalPotionToxicity - costReduction.valueBase) * (1 - costReduction.valueMultiplicative) - costReduction.valueAdditive;
			finalPotionToxicity = MaxF(0.f, finalPotionToxicity);
		}
		
		
		//modSigns
		if(IsMutationActive(EPMT_Mutation12) && Mutation12FreeDecoctionAvailable())
		{
			toxicityOffset = 0;
		}
		else if(CanUseSkill(S_Alchemy_s14))
		{
			toxicityOffset *= MaxF(0, 1 - GetAdaptationToxReduction());
		}
		
		
		if(abilityManager.GetStat(BCS_Toxicity, false) + finalPotionToxicity + toxicityOffset > maxTox )
		{
			return false;
		}
		
		return true;
	}
	
	public function DrinkPreparedPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId )
	{	
		var potParams : W3PotionParams;
		var potionParams : SCustomEffectParams;
		var factPotionParams : W3Potion_Fact_Params;
		var adrenaline, hpGainValue, staminaGainValue, duration, finalPotionToxicity : float; //modSigns
		var ret : EEffectInteract;
		var effectType : EEffectType;
		var item : SItemUniqueId;
		var customAbilityName, factId : name;
		var atts : array<name>;
		var i : int;
		var mutagenParams : W3MutagenBuffCustomParams;
		
		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
		
		
		if(!inv.IsIdValid(item))
			return;
			
		
		if( inv.SingletonItemGetAmmo(item) == 0 )
			return;
			
		
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
			
		
		if( !HasFreeToxicityToDrinkPotion( item, effectType, finalPotionToxicity ) )
		{
			return;
		}
				
		
		if(effectType == EET_Fact)
		{
			inv.GetItemAttributes(item, atts);
			
			for(i=0; i<atts.Size(); i+=1)
			{
				if(StrBeginsWith(NameToString(atts[i]), "fact_"))
				{
					factId = atts[i];
					break;
				}
			}
			
			factPotionParams = new W3Potion_Fact_Params in theGame;
			factPotionParams.factName = factId;
			factPotionParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = factPotionParams;
		}
		
		else if(inv.ItemHasTag( item, 'Mutagen' ))
		{
			mutagenParams = new W3MutagenBuffCustomParams in theGame;
			//modSigns
			if(IsMutationActive(EPMT_Mutation12) && Mutation12FreeDecoctionAvailable())
			{
				mutagenParams.toxicityOffset = 0;
				potionParams.sourceName = "Mutation12";
				theGame.MutationHUDFeedback(MFT_PlayOnce);
			}
			else
			{
				mutagenParams.toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
				if(CanUseSkill(S_Alchemy_s14))
				{
					mutagenParams.toxicityOffset *= MaxF(0, 1 - GetAdaptationToxReduction());
				}
			}
			mutagenParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = mutagenParams;
			
			//if( IsMutationActive( EPMT_Mutation10 ) && !HasBuff( EET_Mutation10 ) && IsInCombat() ) //modSigns
			//{
			//	AddEffectDefault( EET_Mutation10, this, "Mutation 10" );
			//} //modSigns: reworked
		}
		
		else
		{
			potParams = new W3PotionParams in theGame;
			potParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = potParams;
		}
	
		
		duration = CalculatePotionDuration(item, inv.ItemHasTag( item, 'Mutagen' ));		

		
		potionParams.effectType = effectType;
		potionParams.creator = this;
		//modSigns
		if(potionParams.sourceName != "Mutation12")
			potionParams.sourceName = "drank_potion";
		potionParams.duration = duration;
		potionParams.customAbilityName = customAbilityName;
		ret = AddEffectCustom(potionParams);

		
		if(factPotionParams)
			delete factPotionParams;
			
		if(mutagenParams)
			delete mutagenParams;
			
		
		inv.SingletonItemRemoveAmmo(item);
		
		
		if(ret == EI_Pass || ret == EI_Override || ret == EI_Cumulate)
		{
			if( finalPotionToxicity > 0.f )
			{
				abilityManager.GainStat(BCS_Toxicity, finalPotionToxicity );
			}
			
			
			if(CanUseSkill(S_Perk_13) && !inv.ItemHasTag(item, 'Mutagen')) //modSigns
			{
				adrenaline = FloorF(GetStat(BCS_Focus)); //modSigns
				abilityManager.DrainFocus(adrenaline);
			}
			
			if (!IsEffectActive('invisible'))
			{
				PlayEffect('use_potion');
			}
			
			if ( inv.ItemHasTag( item, 'Mutagen' ) )
			{
				
				theGame.GetGamerProfile().CheckTrialOfGrasses();
				
				
				SetFailedFundamentalsFirstAchievementCondition(true);
			}
			
			
			if(CanUseSkill(S_Alchemy_s01)) //modSigns
			{
				staminaGainValue = ClampF(GetStatMax(BCS_Stamina) * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s01, 'stamina_gain_perc', false, true)) * GetSkillLevel(S_Alchemy_s01), 0, GetStatMax(BCS_Stamina));
				GainStat(BCS_Stamina, staminaGainValue);
			}			
			
			if(CanUseSkill(S_Alchemy_s02))
			{
				hpGainValue = ClampF(GetStatMax(BCS_Vitality) * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s02, 'vitality_gain_perc', false, true)) * GetSkillLevel(S_Alchemy_s02), 0, GetStatMax(BCS_Vitality));
				GainStat(BCS_Vitality, hpGainValue);
			}			
			
			
			/*if(CanUseSkill(S_Alchemy_s04) && !skillBonusPotionEffect && (RandF() < CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s04, 'apply_chance', false, true)) * GetSkillLevel(S_Alchemy_s04)))
			{
				AddRandomPotionEffectFromAlch4Skill( effectType );				
			}*/ //modSigns: removed
			
			theGame.GetGamerProfile().SetStat(ES_ActivePotions, effectManager.GetPotionBuffsCount());
		}
		
		theTelemetry.LogWithLabel(TE_ELIXIR_USED, inv.GetItemName(item));
		
		if(ShouldProcessTutorial('TutorialPotionAmmo'))
		{
			FactsAdd("tut_used_potion");
		}
		
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
	
	
	/*private final function AddRandomPotionEffectFromAlch4Skill( currentlyDrankPotion : EEffectType )
	{
		var randomPotions : array<EEffectType>;
		var currentPotion : CBaseGameplayEffect;
		var effectsOld, effectsNew : array<CBaseGameplayEffect>;
		var i, ind : int;
		var duration : float;
		var params : SCustomEffectParams;
		var ret : EEffectInteract;
		
		
		randomPotions.PushBack( EET_BlackBlood );
		randomPotions.PushBack( EET_Blizzard );
		randomPotions.PushBack( EET_FullMoon );
		randomPotions.PushBack( EET_GoldenOriole );
		//randomPotions.PushBack( EET_KillerWhale ); //modSigns
		randomPotions.PushBack( EET_MariborForest );
		randomPotions.PushBack( EET_PetriPhiltre );
		randomPotions.PushBack( EET_Swallow );
		randomPotions.PushBack( EET_TawnyOwl );
		randomPotions.PushBack( EET_Thunderbolt );
		
		
		randomPotions.Remove( currentlyDrankPotion );
		
		
		ind = RandRange( randomPotions.Size() );

		
		if( HasBuff( randomPotions[ ind ] ) )
		{
			currentPotion = GetBuff( randomPotions[ ind ] );
			currentPotion.SetTimeLeft( currentPotion.GetInitialDurationAfterResists() );
		}
		
		else
		{			
			duration = BonusPotionGetDurationFromXML( randomPotions[ ind ] );
			
			if(duration > 0)
			{
				effectsOld = GetCurrentEffects();
									
				params.effectType = randomPotions[ ind ];
				params.creator = this;
				params.sourceName = SkillEnumToName( S_Alchemy_s04 );
				params.duration = duration;
				ret = AddEffectCustom( params );
				
				
				if( ret != EI_Undefined && ret != EI_Deny )
				{
					effectsNew = GetCurrentEffects();
					
					ind = -1;
					for( i=effectsNew.Size()-1; i>=0; i-=1)
					{
						if( !effectsOld.Contains( effectsNew[i] ) )
						{
							ind = i;
							break;
						}
					}
					
					if(ind > -1)
					{
						skillBonusPotionEffect = effectsNew[ind];
					}
				}
			}		
		}
	}*/ //modSigns: removed
	
	
	private function BonusPotionGetDurationFromXML(type : EEffectType) : float
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName, typeName, itemName : name;
		var abs : array<name>;
		var min, max : SAbilityAttributeValue;
		var tmpInt : int;
		var temp 								: array<float>;
		var i, temp2, temp3 : int;
						
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');
		typeName = EffectTypeToName(type);
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
			{
				
				if(tmpName == typeName)
				{
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
					{
						
						if(tmpInt == 1)
						{
							if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', itemName))
							{
								
								if(IsNameValid(itemName))
								{
									break;
								}
							}
						}
					}
				}
			}
		}
		
		if(!IsNameValid(itemName))
			return 0;
		
		
		dm.GetItemAbilitiesWithWeights(itemName, true, abs, temp, temp2, temp3);
		dm.GetAbilitiesAttributeValue(abs, 'duration', min, max);						
		return CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	public function ClearSkillBonusPotionEffect()
	{
		skillBonusPotionEffect = NULL;
	}
	
	public function GetSkillBonusPotionEffect() : CBaseGameplayEffect
	{
		return skillBonusPotionEffect;
	}
	
	
	
	
	
	
	
	public final function HasRunewordActive(abilityName : name) : bool
	{
		var item : SItemUniqueId;
		var hasRuneword : bool;
		
		hasRuneword = false;
		
		if(GetItemEquippedOnSlot(EES_SteelSword, item) && (IsItemHeld(item) || abilityName == 'Runeword 5 _Stats' || abilityName == 'Runeword 6 _Stats')) //modSigns: only drawn sword (or equipped - for runeword 5 and 6)
		{
			hasRuneword = inv.ItemHasAbility(item, abilityName);				
		}
		
		if(!hasRuneword)
		{
			if(GetItemEquippedOnSlot(EES_SilverSword, item) && (IsItemHeld(item) || abilityName == 'Runeword 5 _Stats' || abilityName == 'Runeword 6 _Stats')) //modSigns: only drawn sword (or equipped - for runeword 5 and 6)
			{
				hasRuneword = inv.ItemHasAbility(item, abilityName);
			}
		}
		
		return hasRuneword;
	}
	
	public final function HasGlyphwordActive(abilityName : name) : bool //modSigns
	{
		var item : SItemUniqueId;
		var hasGlyphword : bool;
		
		hasGlyphword = false;
		
		if(GetItemEquippedOnSlot(EES_Armor, item))
		{
			hasGlyphword = inv.ItemHasAbility(item, abilityName);
		}
		
		return hasGlyphword;
	}
	
	public final function GetShrineBuffs() : array<CBaseGameplayEffect>
	{
		var null : array<CBaseGameplayEffect>;
		
		if(effectManager && effectManager.IsReady())
			return effectManager.GetShrineBuffs();
			
		return null;
	}
	
	public final function AddRepairObjectBuff(armor : bool, weapon : bool) : bool
	{
		var added : bool;
		
		added = false;
		
		if(weapon /*&& (IsAnyItemEquippedOnSlot(EES_SilverSword) || IsAnyItemEquippedOnSlot(EES_SteelSword))*/ ) //modSigns: restrictions removed
		{
			AddEffectDefault(EET_EnhancedWeapon, this, "repair_object", false);
			added = true;
		}
		
		if(armor /*&& (IsAnyItemEquippedOnSlot(EES_Armor) || IsAnyItemEquippedOnSlot(EES_Gloves) || IsAnyItemEquippedOnSlot(EES_Boots) || IsAnyItemEquippedOnSlot(EES_Pants))*/ ) //modSigns: restrictions removed
		{
			AddEffectDefault(EET_EnhancedArmor, this, "repair_object", false);
			added = true;
		}
		
		return added;
	}
	
	
	public function StartCSAnim(buff : CBaseGameplayEffect) : bool
	{
		
		if(IsAnyQuenActive() && (W3CriticalDOTEffect)buff)
			return false;
			
		return super.StartCSAnim(buff);
	}
	
	public function GetPotionBuffLevel(effectType : EEffectType) : int
	{
		if(effectManager && effectManager.IsReady())
			return effectManager.GetPotionBuffLevel(effectType);
			
		return 0;
	}	

	
	
	
	
	
	
	event OnLevelGained(currentLevel : int, show : bool)
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(abilityManager && abilityManager.IsInitialized())
		{
			((W3PlayerAbilityManager)abilityManager).OnLevelGained(currentLevel);
		}
		
		if ( theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		} 
	
		
		if(currentLevel >= 35)
		{
			theGame.GetGamerProfile().AddAchievement(EA_Immortal);
		}
	
		if ( hud && currentLevel < levelManager.GetMaxLevel() && FactsQuerySum( "DebugNoLevelUpUpdates" ) == 0 )
		{
			hud.OnLevelUpUpdate(currentLevel, show);
		}
		
		theGame.RequestAutoSave( "level gained", false );
	}
	
	public function GetSignStats(skill : ESkill, out damageType : name, out damageVal : float, out spellPower : SAbilityAttributeValue)
	{
		var i, size : int;
		var dm : CDefinitionsManagerAccessor;
		var attrs : array<name>;
	
		spellPower = GetPowerStatValue(CPS_SpellPower);
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(GetSkillAbilityName(skill), attrs);
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsDamageTypeNameValid(attrs[i]) )
			{
				damageVal = CalculateAttributeValue(GetSkillAttributeValue(skill, attrs[i], false, true));
				damageType = attrs[i];
				break;
			}
		}
	}
		
	
	public function SetIgnorePainMaxVitality(val : float)
	{
		if(abilityManager && abilityManager.IsInitialized())
			abilityManager.SetStatPointMax(BCS_Vitality, val);
	}
	
	event OnAnimEvent_ActionBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart && !disableActionBlend )
		{
			if ( this.IsCastingSign() )
				ProcessSignEvent( 'cast_end' );
			
			
			FindMoveTarget();
			SetCanPlayHitAnim( true );
			this.SetBIsCombatActionAllowed( true );
			
			if ( this.GetFinisherVictim() && this.GetFinisherVictim().HasAbility( 'ForceFinisher' ) && !isInFinisher )
			{
				this.GetFinisherVictim().SignalGameplayEvent( 'Finisher' );
			}
			else if (this.BufferCombatAction != EBAT_EMPTY )
			{
				
				
					
					if ( !IsCombatMusicEnabled() )
					{
						SetCombatActionHeading( ProcessCombatActionHeading( this.BufferCombatAction ) ); 
						FindTarget();
						UpdateDisplayTarget( true );
					}
			
					if ( AllowAttack( GetTarget(), this.BufferCombatAction ) )
						this.ProcessCombatActionBuffer();
			}
			else
			{
				
				ResumeStaminaRegen( 'InsideCombatAction' );
				
				
				
			}
		}
		else if ( disableActionBlend )
		{
			disableActionBlend = false;
		}
	}
	
	
	event OnAnimEvent_Sign( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_Tick )
		{
			ProcessSignEvent( animEventName );
		}
	}
	
	event OnAnimEvent_Throwable( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var thrownEntity		: CThrowable;	
		
		thrownEntity = (CThrowable)EntityHandleGet( thrownEntityHandle );
			
		if ( inv.IsItemCrossbow( inv.GetItemFromSlot('l_weapon') ) &&  rangedWeapon.OnProcessThrowEvent( animEventName ) )
		{		
			return true;
		}
		else if( thrownEntity && IsThrowingItem() && thrownEntity.OnProcessThrowEvent( animEventName ) )
		{
			return true;
		}
	}
	
	event OnTaskSyncAnim( npc : CNewNPC, animNameLeft : name )
	{
		var tmpBool : bool;
		var tmpName : name;
		var damage, points, resistance : float;
		var min, max : SAbilityAttributeValue;
		var mc : EMonsterCategory;
		
		super.OnTaskSyncAnim( npc, animNameLeft );
		
		if( animNameLeft == 'BruxaBite' && IsMutationActive( EPMT_Mutation4 ) )
		{
			theGame.GetMonsterParamsForActor( npc, mc, tmpName, tmpBool, tmpBool, tmpBool );
			
			if( mc == MC_Vampire )
			{
				GetResistValue( CDS_BleedingRes, points, resistance );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'DirectDamage', min, max );
				damage = MaxF( 0.f, max.valueMultiplicative * GetMaxHealth() - points );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'duration', min, max );
				damage *= min.valueAdditive * ( 1 - MinF( 1.f, resistance ) );
				
				if( damage > 0.f )
				{
					//npc.AddAbility( 'Mutation4BloodDebuff' ); //modSigns: moved to acid effect
					ProcessActionMutation4ReturnedDamage( damage, npc, EAHA_ForceNo );					
					//npc.AddTimer( 'RemoveMutation4BloodDebuff', 15.f, , , , , true ); //modSigns: moved to acid effect
				}
			}
		}
	}
	
	
	//modSigns: redone
	public function ProcessActionMutation4ReturnedDamage( damageDealt : float, attacker : CActor, hitAnimationType : EActionHitAnim, optional action : W3DamageAction ) : bool
	{
		var customParams				: SCustomEffectParams;
		var currToxicity				: float;
		var min, max, customDamageValue	: SAbilityAttributeValue;
		var dm							: CDefinitionsManagerAccessor;
		var animAction					: W3DamageAction;
		var customDuration				: float; //modSigns

		if( damageDealt <= 0 )
		{
			return false;
		}
		
		currToxicity = GetStat( BCS_Toxicity );

		if( currToxicity <= 0 )
		{
			return false;
		}
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
		customDamageValue.valueAdditive = currToxicity * min.valueAdditive;
		dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
		customDuration = min.valueAdditive;
		
		if( customDamageValue.valueAdditive <= 0 || customDuration <= 0 )
		{
			return false;
		}
		
		if( action )
		{
			action.SetMutation4Triggered();
		}
		
		//dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
		//customDamageValue.valueAdditive = damageDealt * min.valueAdditive;
		//
		//if( currToxicity > 0 )
		//{
		//	customDamageValue.valueAdditive *= currToxicity;
		//}
		//
		//dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
		//customDamageValue.valueAdditive /= min.valueAdditive; 
		
		customParams.effectType = EET_Acid;
		customParams.effectValue = customDamageValue;
		customParams.duration = customDuration;
		customParams.creator = this;
		customParams.sourceName = 'Mutation4';
		
		attacker.AddEffectCustom( customParams );
		
		
		animAction = new W3DamageAction in theGame;
		animAction.Initialize( this, attacker, NULL, 'Mutation4', EHRT_Reflect, CPS_Undefined, true, false, false, false );
		animAction.SetCannotReturnDamage( true );
		animAction.SetCanPlayHitParticle( false );
		animAction.SetHitAnimationPlayType( hitAnimationType );
		theGame.damageMgr.ProcessAction( animAction );
		delete animAction;
		
		theGame.MutationHUDFeedback( MFT_PlayOnce );
		
		return true;
	}
	
	event OnPlayerActionEnd()
	{
		var l_i				: int;
		var l_bed			: W3WitcherBed;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			BlockAllActions( 'WitcherBed', false );
			l_bed.ApplyAppearance( "collision" );
			l_bed.GotoState( 'WakeUp' );
			theGame.ReleaseNoSaveLock( l_bed.m_bedSaveLock );
			
			
			substateManager.m_MovementCorrectorO.disallowRotWhenGoingToSleep = false;
		}
		
		super.OnPlayerActionEnd();
	}
	
	event OnPlayerActionStartFinished()
	{
		var l_initData			: W3SingleMenuInitData;		
		var l_i					: int;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_initData = new W3SingleMenuInitData in this;
			l_initData.SetBlockOtherPanels( true );
			l_initData.ignoreSaveSystem = true;
			l_initData.ignoreMeditationCheck = true;
			l_initData.setDefaultState( '' );
			l_initData.isBonusMeditationAvailable = true;
			l_initData.fixedMenuName = 'MeditationClockMenu';
			
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu', l_initData );
		}
		
		super.OnPlayerActionStartFinished();
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		if ( IsInCombatAction() && ( GetCombatAction() == EBAT_SpecialAttack_Light || GetCombatAction() == EBAT_SpecialAttack_Heavy ) )
			return true;
		else
			return false;
	}
	
	public function IsInCombatAction_SpecialAttackHeavy() : bool
	{
		if ( IsInCombatAction() && GetCombatAction() == EBAT_SpecialAttack_Heavy )
			return true;
		else
			return false;
	}
	
	protected function WhenCombatActionIsFinished()
	{
		super.WhenCombatActionIsFinished();
		RemoveTimer( 'ProcessAttackTimer' );
		RemoveTimer( 'AttackTimerEnd' );
		CastSignAbort();
		specialAttackCamera = false;
		this.OnPerformSpecialAttack( true, false );
	}
	
	//modSigns: RemoveTemporarySkills should never happen on combat action end,
	//as if sign casting interrupts any other action, temp skills are removed
	//by the end of interrupted action and before the sign is actually cast!
	event OnCombatActionEnd()
	{
		this.CleanCombatActionBuffer();		
		super.OnCombatActionEnd();
		
		//RemoveTemporarySkills();
	}
	
	event OnCombatActionFriendlyEnd()
	{
		if ( IsCastingSign() )
		{
			SetBehaviorVariable( 'IsCastingSign', 0 );
			SetCurrentlyCastSign( ST_None, NULL );
			LogChannel( 'ST_None', "ST_None" );					
		}

		super.OnCombatActionFriendlyEnd();
	}
	
	public function GetPowerStatValue( stat : ECharacterPowerStats, optional ablName : name, optional ignoreDeath : bool ) : SAbilityAttributeValue
	{
		var result :  SAbilityAttributeValue;
		
		
		result = super.GetPowerStatValue( stat, ablName, ignoreDeath );
		//modSigns: W3DamageAction.GetPowerStatValue calls for actor.GetPowerStatValue twice:
		//second time with attackName as ablName to obtain attack specific boosts, so Euphoria boost ends up
		//being applied twice. Character stats for popup menu don't use ablName as there is no attack and no attackName,
		//so bonus is displayed properly there, but gets doubled when actual damage is calculated in combat.
		//To fix this we need to check for non-ability specific calls:
		//if( !IsNameValid(ablName) && stat != CPS_Undefined )
		//	ApplyMutation10StatBoost( result ); //modSigns: reworked
		
		return result;
	}
	
	
	
	timer function OpenRadialMenu( time: float, id : int )
	{
		
		if( GetBIsCombatActionAllowed() && !IsUITakeInput() )
		{
			bShowRadialMenu = true;
		}
		
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function OnAddRadialMenuOpenTimer(  )
	{
		
		
		
		    
		    
			this.AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		
	}

	public function SetShowRadialMenuOpenFlag( bSet : bool  )
	{
		
		bShowRadialMenu = bSet;
	}
	
	public function OnRemoveRadialMenuOpenTimer()
	{
		
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function ResetRadialMenuOpenTimer()
	{
		
		this.RemoveTimer('OpenRadialMenu');
		if( GetBIsCombatActionAllowed() )
		{
		    
		    
			AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		}
	}

	
	
	timer function ResendCompanionDisplayName(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayName();
			}
		}
	}

	timer function ResendCompanionDisplayNameSecond(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayNameSecond();
			}
		}
	}
	
	public function RemoveCompanionDisplayNameTimer()
	{
		this.RemoveTimer('ResendCompanionDisplayName');
	}
		
	public function RemoveCompanionDisplayNameTimerSecond()
	{
		this.RemoveTimer('ResendCompanionDisplayNameSecond');
	}
	
		
	public function GetCompanionNPCTag() : name
	{
		return companionNPCTag;
	}

	public function SetCompanionNPCTag( value : name )
	{
		companionNPCTag = value;
	}	

	public function GetCompanionNPCTag2() : name
	{
		return companionNPCTag2;
	}

	public function SetCompanionNPCTag2( value : name )
	{
		companionNPCTag2 = value;
	}

	public function GetCompanionNPCIconPath() : string
	{
		return companionNPCIconPath;
	}

	public function SetCompanionNPCIconPath( value : string )
	{
		companionNPCIconPath = value;
	}

	public function GetCompanionNPCIconPath2() : string
	{
		return companionNPCIconPath2;
	}

	public function SetCompanionNPCIconPath2( value : string )
	{
		companionNPCIconPath2 = value;
	}
	
	

	//modSigns: chance to ignore hit anim
	/*public function GetChanceToIgnoreHitAnim() : float
	{
		var armorPieces : array<int>;
		
		inv.CountArmorPieces(armorPieces);
		return armorPieces[0] * 0 + armorPieces[1] * 2.5 + armorPieces[2] * 10;
	}*/
	
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
	{
		//var chance : float;
		//var procQuen : W3SignEntity;
		
		if(IsThrowingItem() || IsThrowingItemWithAim()) //modSigns: no need to abort throwing if not in fact throwing
		{
			if(!damageAction.IsDoTDamage() && damageAction.DealsAnyDamage() && damageAction.GetHitAnimationPlayType() != EAHA_ForceNo) //modSigns
			{
				if(inv.IsItemBomb(selectedItemId))
				{
					BombThrowAbort();
				}
				else
				{
					ThrowingAbort();
				}			
			}
		}
		
		
		/*if(damageAction.IsActionRanged())
		{
			chance = CalculateAttributeValue(GetAttributeValue('quen_chance_on_projectile'));
			if(chance > 0)
			{
				chance = ClampF(chance, 0, 1);
				
				if(RandF() < chance)
				{
					procQuen = (W3SignEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
					procQuen.Init(signOwner, signs[ST_Quen].entity, true );
					procQuen.OnStarted();
					procQuen.OnThrowing();
					procQuen.OnEnded();
				}
			}
		}*/ //modSigns: moved to reduce damage
		
		
		if( !((W3Effect_Toxicity)damageAction.causer) )
			MeditationForceAbort(true);
		
		
		if(IsDoingSpecialAttack(false))
			damageAction.SetHitAnimationPlayType(EAHA_ForceNo);
		
		return super.ReactToBeingHit(damageAction, buffNotApplied);
	}
	
	protected function ShouldPauseHealthRegenOnHit() : bool
	{
		
		if( ( HasBuff( EET_Swallow ) && GetPotionBuffLevel( EET_Swallow ) >= 3 ) || HasBuff( EET_Runeword8 ) || HasBuff( EET_Mutation11Buff ) || HasBuff( EET_UndyingSkillImmortal ) ) //modSigns
		{
			return false;
		}
			
		return true;
	}
		
	public function SetMappinToHighlight( mappinName : name, mappinState : bool )
	{
		var mappinDef : SHighlightMappin;
		mappinDef.MappinName = mappinName;
		mappinDef.MappinState = mappinState;
		MappinToHighlight.PushBack(mappinDef);
	}	

	public function ClearMappinToHighlight()
	{
		MappinToHighlight.Clear();
	}
	
	public function CastSignAbort()
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			signs[currentlyCastSign].entity.OnSignAborted();
		}
		
		
	}
	
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		var med : W3PlayerWitcherStateMeditationWaiting;
				
		
		med = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
		if(med)
		{
			med.StopRequested(true);
		}
		
		
		super.OnBlockingSceneStarted( scene );
	}
	
	
	
	
	
	public function GetHorseManager() : W3HorseManager
	{
		return (W3HorseManager)EntityHandleGet( horseManagerHandle );
	}
	
	
	public function HorseEquipItem(horsesItemId : SItemUniqueId) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.EquipItem(horsesItemId) != GetInvalidUniqueId();
			
		return false;
	}
	
	
	public function HorseUnequipItem(slot : EEquipmentSlots) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.UnequipItem(slot) != GetInvalidUniqueId();
			
		return false;
	}
	
	
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByName(itemName, quantity);
	}
	
	
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByCategory(itemCategory, quantity);
	}
	
	
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByTag(itemTag, quantity);
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.GetInventoryComponent();
			
		return NULL;
	}
	
	
	
	
	
	public final function TutorialMutagensUnequipPlayerSkills() : array<STutorialSavedSkill>
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensUnequipPlayerSkills();
	}
	
	public final function TutorialMutagensEquipOneGoodSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		pam.TutorialMutagensEquipOneGoodSkill();
	}
	
	public final function TutorialMutagensEquipOneGoodOneBadSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipOneGoodOneBadSkill();
	}
	
	public final function TutorialMutagensEquipThreeGoodSkills()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipThreeGoodSkills();
	}
	
	public final function TutorialMutagensCleanupTempSkills(savedEquippedSkills : array<STutorialSavedSkill>)
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensCleanupTempSkills(savedEquippedSkills);
	}
	
	
	
	
	
	//modSigns: redone
	//modSigns: by default, there's no armor stamina penalty as armor class already
	//affects action cost, but you can enable it in options
	public final function CalculatedArmorStaminaRegenBonus() : float
	{
		var armorEq, glovesEq, pantsEq, bootsEq : bool;
		var armorId, glovesId, pantsId, bootsId : SItemUniqueId;
		var staminaRegenVal : float;
		var armorRegenVal : SAbilityAttributeValue;
		
		if(!theGame.params.IsArmorRegenPenaltyEnabled())
			return 0.0f;
		
		//base armor stamina regen bonus/penalty
		armorRegenVal = GetAttributeValue('staminaRegen_armor_mod');
		staminaRegenVal = armorRegenVal.valueMultiplicative;

		//equipped pieces
		armorEq = inv.GetItemEquippedOnSlot( EES_Armor, armorId );
		glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, glovesId );
		pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, pantsId );
		bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, bootsId );
		
		//glyphwords change stamina, not replace it
		//if( HasGlyphwordActive( 'Glyphword 2 _Stats' ) )
		//{
		//	if ( armorEq && !inv.ItemHasTag(armorId, 'LightArmor') )
		//		staminaRegenVal += 0.07;
		//	if ( glovesEq && !inv.ItemHasTag(glovesId, 'LightArmor') )
		//		staminaRegenVal += 0.01;
		//	if ( pantsEq && !inv.ItemHasTag(pantsId, 'LightArmor') )
		//		staminaRegenVal += 0.01;
		//	if ( bootsEq && !inv.ItemHasTag(bootsId, 'LightArmor') )
		//		staminaRegenVal += 0.01;
		//}
		//else if( HasGlyphwordActive( 'Glyphword 3 _Stats' ) )
		//{
		//}
		//else if( HasGlyphwordActive( 'Glyphword 4 _Stats' ) )
		//{
		//	if ( armorEq && !inv.ItemHasTag(armorId, 'HeavyArmor') )
		//		staminaRegenVal -= 0.20;
		//	if ( glovesEq && !inv.ItemHasTag(glovesId, 'HeavyArmor') )
		//		staminaRegenVal -= 0.025;
		//	if ( pantsEq && !inv.ItemHasTag(pantsId, 'HeavyArmor') )
		//		staminaRegenVal -= 0.025;
		//	if ( bootsEq && !inv.ItemHasTag(bootsId, 'HeavyArmor') )
		//		staminaRegenVal -= 0.05;
		//} //modSigns: reworked

		//stamina regen bonus for missing armor pieces
		if ( !armorEq )
			staminaRegenVal += 0.11;
		if ( !glovesEq )
			staminaRegenVal += 0.02;
		if ( !pantsEq )
			staminaRegenVal += 0.03;
		if ( !bootsEq )
			staminaRegenVal += 0.04;
		
		//debug
		//theGame.witcherLog.AddMessage( "staminaRegenVal = " + staminaRegenVal );

		return staminaRegenVal;
	}
	
	//modSigns: reworked
	public function GetOffenseStatsList( optional hackMode : int ) : SPlayerOffenseStats
	{
		var playerOffenseStats : SPlayerOffenseStats;
		var min, max, value : SAbilityAttributeValue;
		var attackPower : SAbilityAttributeValue;
		var fastAPBonus, strongAPBonus, steelAPBonus, silverAPBonus : SAbilityAttributeValue;
		var critChance, critPowerBonus, fastCritChanceBonus, strongCritChanceBonus, fastCritPowerBonus, strongCritPowerBonus : float;
		var steelCritChanceBonus, silverCritChanceBonus, steelCritPowerBonus, silverCritPowerBonus : float;
		var steelDmg, silverDmg, elementalSteel, elementalSilver : float;
		var attackPowerCrossbow : SAbilityAttributeValue;
		var silverSword, steelSword, crossbow, bolt : SItemUniqueId;
		var mutagen : CBaseGameplayEffect;
		var thunder : W3Potion_Thunderbolt;
		var strongDmgMult, bonusDmgMult, bonusDmgCrossbow, bonusDmgMultCrossbow, bonusDmgMultSteel, bonusDmgMultSilver : float;
		var steelFastAP, silverFastAP, steelStrongAP, silverStrongAP, steelFastCritAP, silverFastCritAP, steelStrongCritAP, silverStrongCritAP : SAbilityAttributeValue;
		var steelFastCritChance, silverFastCritChance, steelStrongCritChance, silverStrongCritChance : float;
		
		if(!abilityManager || !abilityManager.IsInitialized())
			return playerOffenseStats;
		
		//base damage increase for heavy attacks
		value = GetSkillAttributeValue(S_Sword_2, 'heavy_attack_dmg_boost', false, true);
		strongDmgMult = 1 + value.valueMultiplicative;
		
		//generic bonuses
		attackPower = GetPowerStatValue(CPS_AttackPower);
		//Bear tier 1 power bonus
		if(IsSetBonusActive(EISB_Bear_1))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_1), 'attack_power', min, max);
			attackPower.valueMultiplicative += min.valueMultiplicative * GetSetPartsEquipped(EIST_Bear) * FloorF(GetStat(BCS_Focus));
		}
		critChance = CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		critPowerBonus = CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		
		//attack type specific bonuses
		fastAPBonus = GetSkillAttributeValue(S_Sword_1, PowerStatEnumToName(CPS_AttackPower), false, true);
		strongAPBonus = GetSkillAttributeValue(S_Sword_2, PowerStatEnumToName(CPS_AttackPower), false, true);
		if (CanUseSkill(S_Sword_s21))
			fastAPBonus += GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s21); 
		if (CanUseSkill(S_Sword_s04))
			strongAPBonus += GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s04);
		if (HasBuff(EET_LynxSetBonus)) //lynx tier 1 attack type specific bonuses
		{
			fastAPBonus.valueMultiplicative += ((W3Effect_LynxSetBonus)GetBuff(EET_LynxSetBonus)).GetLynxBonus(false);
			strongAPBonus.valueMultiplicative += ((W3Effect_LynxSetBonus)GetBuff(EET_LynxSetBonus)).GetLynxBonus(true);
		}
		if (CanUseSkill(S_Sword_s17)) 
		{
			fastCritChanceBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s17);
			fastCritPowerBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s17);
		}
		if (CanUseSkill(S_Sword_s08)) 
		{
			strongCritChanceBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s08);
			strongCritPowerBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s08);
		}
		
		//steel sword specific bonuses
		if (GetItemEquippedOnSlot(EES_SteelSword, steelSword))
		{
			steelDmg = GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
			steelDmg += GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_PIERCING, GetInvalidUniqueId());
			steelDmg += GetTotalWeaponDamage(steelSword, theGame.params.DAMAGE_NAME_BLUDGEONING, GetInvalidUniqueId());
			elementalSteel = CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_FIRE));
			elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_FROST)); 
			elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.DAMAGE_NAME_POISON)); //modSigns
			//weapon bonuses are added OnHold, so we need to retrieve them specifically if we want to show them
			if (!GetInventory().IsItemHeld(steelSword))
			{
				steelCritChanceBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_CHANCE));
				steelCritPowerBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				steelAPBonus += GetInventory().GetItemAttributeValue(steelSword, 'attack_power');
			}
			//bonus damage
			bonusDmgMultSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, 'sword_dmg_bonus'));
			//tier 2 wolf oil bonuses
			steelCritChanceBonus += CalculateAttributeValue(inv.GetOilCriticalChanceBonus(steelSword, MC_NotSet));
			steelCritPowerBonus += CalculateAttributeValue(inv.GetOilCriticalDamageBonus(steelSword, MC_NotSet));
		}
		
		//silver sword specific bonuses
		if (GetItemEquippedOnSlot(EES_SilverSword, silverSword))
		{
			silverDmg = GetTotalWeaponDamage(silverSword, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
			elementalSilver = CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_FIRE));
			elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_FROST));
			elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.DAMAGE_NAME_POISON)); //modSigns
			//weapon bonuses are added OnHold, so we need to retrieve them specifically if we want to show them
			if (!GetInventory().IsItemHeld(silverSword))
			{
				silverCritChanceBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_CHANCE));
				silverCritPowerBonus += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				silverAPBonus += GetInventory().GetItemAttributeValue(silverSword, 'attack_power');
			}
			//bonus damage
			bonusDmgMultSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, 'sword_dmg_bonus'));
			//tier 2 wolf oil bonuses
			silverCritChanceBonus += CalculateAttributeValue(inv.GetOilCriticalChanceBonus(silverSword, MC_NotSet));
			silverCritPowerBonus += CalculateAttributeValue(inv.GetOilCriticalDamageBonus(silverSword, MC_NotSet));
		}
		
		//since drawn sword adds its stats to character stats, we now need to do this hackiest shit ever
		if (GetInventory().IsItemHeld(steelSword))
		{
			//remove steel bonuses from silver stats
			silverCritChanceBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_CHANCE));
			silverCritPowerBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(steelSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			silverAPBonus -= GetInventory().GetItemAttributeValue(steelSword, 'attack_power');
		}
		if (GetInventory().IsItemHeld(silverSword))
		{
			//remove silver bonuses from steel stats
			steelCritChanceBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_CHANCE));
			steelCritPowerBonus -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(silverSword, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			steelAPBonus -= GetInventory().GetItemAttributeValue(silverSword, 'attack_power');
		}

		//Thunderbolt lvl 3 crit chance
		thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
		if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
		{
			critPowerBonus += 1.0f;
		}
		
		//heft damage increase
		if(HasGlyphwordActive('Glyphword 4 _Stats'))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 4 _Stats', 'glyphword4_mod', min, max);
			bonusDmgMult += CalculateAttributeValue(min);
		}
		
		//Euphoria damage bonus
		if(HasBuff(EET_Mutation10))
		{
			steelDmg += GetToxicityDamage();
			silverDmg += GetToxicityDamage();
		}
		
		//final attributes
		steelFastAP = attackPower + fastAPBonus + steelAPBonus;
		silverFastAP = attackPower + fastAPBonus + silverAPBonus;
		steelStrongAP = attackPower + strongAPBonus + steelAPBonus;
		silverStrongAP = attackPower + strongAPBonus + silverAPBonus;
		steelFastCritAP = steelFastAP;
		steelFastCritAP.valueMultiplicative += critPowerBonus + fastCritPowerBonus + steelCritPowerBonus;
		silverFastCritAP = silverFastAP;
		silverFastCritAP.valueMultiplicative += critPowerBonus + fastCritPowerBonus + silverCritPowerBonus;
		steelStrongCritAP = steelStrongAP;
		steelStrongCritAP.valueMultiplicative += critPowerBonus + strongCritPowerBonus + steelCritPowerBonus;
		silverStrongCritAP = silverStrongAP;
		silverStrongCritAP.valueMultiplicative += critPowerBonus + strongCritPowerBonus + silverCritPowerBonus;
		steelFastCritChance = critChance + fastCritChanceBonus + steelCritChanceBonus;
		silverFastCritChance = critChance + fastCritChanceBonus + silverCritChanceBonus;
		steelStrongCritChance = critChance + strongCritChanceBonus + steelCritChanceBonus;
		silverStrongCritChance = critChance + strongCritChanceBonus + silverCritChanceBonus;
		
		//fill offense stats
		playerOffenseStats.steelFastAP = steelFastAP.valueMultiplicative;
		playerOffenseStats.silverFastAP = silverFastAP.valueMultiplicative;
		playerOffenseStats.steelStrongAP = steelStrongAP.valueMultiplicative;
		playerOffenseStats.silverStrongAP = silverStrongAP.valueMultiplicative;
		playerOffenseStats.steelFastCritAP = steelFastCritAP.valueMultiplicative;
		playerOffenseStats.silverFastCritAP = silverFastCritAP.valueMultiplicative;
		playerOffenseStats.steelStrongCritAP = steelStrongCritAP.valueMultiplicative;
		playerOffenseStats.silverStrongCritAP = silverStrongCritAP.valueMultiplicative;
		playerOffenseStats.steelFastCritChance = steelFastCritChance * 100;
		playerOffenseStats.silverFastCritChance = silverFastCritChance * 100;
		playerOffenseStats.steelStrongCritChance = steelStrongCritChance * 100;
		playerOffenseStats.silverStrongCritChance = silverStrongCritChance * 100;
		if ( steelDmg != 0 )
		{
			playerOffenseStats.steelFastDmg = ((steelDmg + elementalSteel) * (1 + bonusDmgMult + bonusDmgMultSteel) + steelFastAP.valueBase) * steelFastAP.valueMultiplicative + steelFastAP.valueAdditive;
			playerOffenseStats.steelFastCritDmg = ((steelDmg + elementalSteel) * (1 + bonusDmgMult + bonusDmgMultSteel) + steelFastCritAP.valueBase) * steelFastCritAP.valueMultiplicative + steelFastCritAP.valueAdditive;
			playerOffenseStats.steelFastDPS = playerOffenseStats.steelFastDmg * (1 - steelFastCritChance) + playerOffenseStats.steelFastCritDmg * steelFastCritChance;
			playerOffenseStats.steelStrongDmg = ((steelDmg + elementalSteel) * (strongDmgMult + bonusDmgMult + bonusDmgMultSteel) + steelStrongAP.valueBase) * steelStrongAP.valueMultiplicative + steelStrongAP.valueAdditive;
			playerOffenseStats.steelStrongCritDmg = ((steelDmg + elementalSteel) * (strongDmgMult + bonusDmgMult + bonusDmgMultSteel) + steelStrongCritAP.valueBase) * steelStrongCritAP.valueMultiplicative + steelStrongCritAP.valueAdditive;
			playerOffenseStats.steelStrongDPS = playerOffenseStats.steelStrongDmg * (1 - steelStrongCritChance) + playerOffenseStats.steelStrongCritDmg * steelStrongCritChance;
		}
		if ( silverDmg != 0 )
		{
			playerOffenseStats.silverFastDmg = ((silverDmg + elementalSilver) * (1 + bonusDmgMult + bonusDmgMultSilver) + silverFastAP.valueBase) * silverFastAP.valueMultiplicative + silverFastAP.valueAdditive;
			playerOffenseStats.silverFastCritDmg = ((silverDmg + elementalSilver) * (1 + bonusDmgMult + bonusDmgMultSilver) + silverFastCritAP.valueBase) * silverFastCritAP.valueMultiplicative + silverFastCritAP.valueAdditive;
			playerOffenseStats.silverFastDPS = playerOffenseStats.silverFastDmg * (1 - silverFastCritChance) + playerOffenseStats.silverFastCritDmg * silverFastCritChance;
			playerOffenseStats.silverStrongDmg = ((silverDmg + elementalSilver) * (strongDmgMult + bonusDmgMult + bonusDmgMultSilver) + silverStrongAP.valueBase) * silverStrongAP.valueMultiplicative + silverStrongAP.valueAdditive;
			playerOffenseStats.silverStrongCritDmg = ((silverDmg + elementalSilver) * (strongDmgMult + bonusDmgMult + bonusDmgMultSilver) + silverStrongCritAP.valueBase) * silverStrongCritAP.valueMultiplicative + silverStrongCritAP.valueAdditive;
			playerOffenseStats.silverStrongDPS = playerOffenseStats.silverStrongDmg * (1 - silverStrongCritChance) + playerOffenseStats.silverStrongCritDmg * silverStrongCritChance;
		}
		
		//modSigns: crossbow redone
		playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
		playerOffenseStats.crossbowElementaDmgType = '';
		if (GetItemEquippedOnSlot(EES_RangedWeapon, crossbow))
		{
			attackPowerCrossbow = attackPower + GetInventory().GetItemAttributeValue(crossbow, PowerStatEnumToName(CPS_AttackPower));
			playerOffenseStats.crossbowAttackPower = attackPowerCrossbow.valueMultiplicative;
			playerOffenseStats.crossbowCritChance = GetCriticalHitChance( false, false, NULL, MC_NotSet, true );

			value = GetCriticalHitDamageBonus( crossbow, MC_NotSet, false ) + inv.GetItemAttributeValue( crossbow, theGame.params.CRITICAL_HIT_DAMAGE_BONUS );
			//Cat Eyes mutation crit damage boost
			if( IsMutationActive( EPMT_Mutation9 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'critical_damage', min, max );
				value += min;
			}
			if( CanUseSkill(S_Sword_s07) )
			{
				value += GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * GetSkillLevel(S_Sword_s07);
			}
			playerOffenseStats.crossbowCritDmgBonus = CalculateAttributeValue(value);
			
			//bolt stats
			if (GetItemEquippedOnSlot(EES_Bolt, bolt))
			{
				playerOffenseStats.crossbowSteelDmgType = GetCrossbowSteelDmgName();
				inv.GetItemStatByName(inv.GetItemName(bolt), playerOffenseStats.crossbowSteelDmgType, playerOffenseStats.crossbowSteelDmg);
				inv.GetItemStatByName(inv.GetItemName(bolt), 'SilverDamage', playerOffenseStats.crossbowSilverDmg);
				playerOffenseStats.crossbowElementaDmgType = GetCrossbowElementaDmgName();
				if(IsNameValid(playerOffenseStats.crossbowElementaDmgType))
					inv.GetItemStatByName(inv.GetItemName(bolt), playerOffenseStats.crossbowElementaDmgType, playerOffenseStats.crossbowElementaDmg);
			}
			
			//crossbow damage increase skill
			if( CanUseSkill(S_Sword_s15) )
			{
				bonusDmgCrossbow += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s15, 'xbow_dmg_bonus', false, true)) * GetSkillLevel(S_Sword_s15);
			}
			
			playerOffenseStats.crossbowSteelDmg += bonusDmgCrossbow;
			playerOffenseStats.crossbowSilverDmg += bonusDmgCrossbow;
			playerOffenseStats.crossbowElementaDmg += bonusDmgCrossbow;
			
			//modSigns: mutation9 base damage boost
			if( IsMutationActive( EPMT_Mutation9 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'mut9_damage', min, max);
				playerOffenseStats.crossbowSteelDmg *= 1 + min.valueMultiplicative;
				playerOffenseStats.crossbowSilverDmg *= 1 + min.valueMultiplicative;
				playerOffenseStats.crossbowElementaDmg *= 1 + min.valueMultiplicative;
			}
			
			playerOffenseStats.crossbowSteelDmg = (playerOffenseStats.crossbowSteelDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
			playerOffenseStats.crossbowSilverDmg = (playerOffenseStats.crossbowSilverDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
			playerOffenseStats.crossbowElementaDmg = (playerOffenseStats.crossbowElementaDmg * (1 + bonusDmgMultCrossbow) + attackPowerCrossbow.valueBase) * attackPowerCrossbow.valueMultiplicative;
		}
		
		return playerOffenseStats;
	}
	
	public function GetTotalWeaponDamage(weaponId : SItemUniqueId, damageTypeName : name, crossbowId : SItemUniqueId) : float
	{
		var damage, durRatio, durMod, itemMod : float;
		var repairObjectBonus, min, max : SAbilityAttributeValue;
		var aerondight : W3Effect_Aerondight; //modSigns
		var phantomWeapon : W3Effect_PhantomWeapon; //modSigns
		
		//durMod = 0;
		durMod = 1; //modSigns: zero value effectively removes all non-physical damages from weapon
		damage = super.GetTotalWeaponDamage(weaponId, damageTypeName, crossbowId);
		
		
		//modSigns: changed -> moved
		//if( IsMutationActive( EPMT_Mutation9 ) && inv.IsItemBolt( weaponId ) /*&& IsDamageTypeAnyPhysicalType( damageTypeName )*/ )
		//{
		//	theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'mut9_damage', min, max);
		//	damage *= 1 + min.valueMultiplicative;
		//}
		
		
		if(IsPhysicalResistStat(GetResistForDamage(damageTypeName, false)))
		{
			repairObjectBonus = inv.GetItemAttributeValue(weaponId, theGame.params.REPAIR_OBJECT_BONUS);
			durRatio = -1;
			
			if(inv.IsIdValid(crossbowId) && inv.HasItemDurability(crossbowId))
			{
				durRatio = inv.GetItemDurabilityRatio(crossbowId);
			}
			else if(inv.IsIdValid(weaponId) && inv.HasItemDurability(weaponId))
			{
				durRatio = inv.GetItemDurabilityRatio(weaponId);
			}
			
			
			if(durRatio >= 0)
				durMod = theGame.params.GetDurabilityMultiplier(durRatio, true);
			else
				durMod = 1;
		}
		
		
		if( damageTypeName == 'SilverDamage' && inv.ItemHasTag( weaponId, 'Aerondight' ) )
		{
			//itemMod = inv.GetItemModifierFloat( weaponId, 'PermDamageBoost' );
			//if( itemMod > 0.f )
			//{
			//	damage += itemMod;
			//}
			//modSigns: damage boost per enemy
			aerondight = (W3Effect_Aerondight)GetBuff(EET_Aerondight);
			if(aerondight)
				damage += aerondight.GetDamageBoost();
		}
		
		//modSigns
		if( damageTypeName == 'SlashingDamage' && inv.ItemHasTag( weaponId, 'PhantomWeapon' ) )
		{
			phantomWeapon = (W3Effect_PhantomWeapon)GetBuff(EET_PhantomWeapon);
			if(phantomWeapon && phantomWeapon.IsFullyCharged())
			{
				damage += phantomWeapon.GetDamageBoost();
				//theGame.witcherLog.AddMessage("Phantom dmg boost = " + phantomWeapon.GetDamageBoost());
			}
		}
		
		//modSigns: Invigoration
		if( HasBuff(EET_Runeword4) && ( damageTypeName == 'SilverDamage' || damageTypeName == 'SlashingDamage' ) )
			damage *= 1 + ((W3Effect_Runeword4)GetBuff(EET_Runeword4)).GetDamageBonus();
		
		return damage * (durMod + repairObjectBonus.valueMultiplicative);
	}
	
	
	
	
	
	public final function GetSkillPathType(skill : ESkill) : ESkillPath
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillPathType(skill);
			
		return ESP_NotSet;
	}
	
	public function GetSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillLevel(s);
			
		return -1;
	}
	
	public function GetSkillMaxLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillMaxLevel(s);
			
		return -1;
	}
	
	public function GetBoughtSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetBoughtSkillLevel(s);
			
		return -1;
	}
	
	
	public function GetAxiiLevel() : int
	{
		var level : int;
		
		level = 1;
		
		if(CanUseSkill(S_Magic_s17)) level += GetSkillLevel(S_Magic_s17);
			
		return Clamp(level, 1, 4);
	}
	
	public function IsInFrenzy() : bool
	{
		return isInFrenzy;
	}
	
	//modSigns: redone to fix a bug
	//public function HasRecentlyCountered() : bool
	//{
	//	return hasRecentlyCountered;
	//}
	//
	//public function SetRecentlyCountered(counter : bool)
	//{
	//	hasRecentlyCountered = counter;
	//}
	//
	////modSigns
	//timer function ResetRecentlyCountered(dt : float, id : int)
	//{
	//	hasRecentlyCountered = false;
	//}
		
	timer function CheckBlockedSkills(dt : float, id : int)
	{
		var nextCallTime : float;
		
		nextCallTime = ((W3PlayerAbilityManager)abilityManager).CheckBlockedSkills(dt);
		if(nextCallTime != -1)
			AddTimer('CheckBlockedSkills', nextCallTime, , , , true);
	}
		
	//modSigns: reworked
	public function RemoveTemporarySkills()
	{
		var i : int;
		var pam : W3PlayerAbilityManager;
	
		if(tempLearnedSignSkills.Size() > 0)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			for(i=0; i<tempLearnedSignSkills.Size(); i+=1)
			{
				pam.RemoveTemporarySkill(tempLearnedSignSkills[i]);
			}
			
			tempLearnedSignSkills.Clear();						
			//theGame.witcherLog.AddMessage("Temp skills removed");
		}
		RemoveAbilityAll(SkillEnumToName(S_Sword_s19));
	}
	
	public function RemoveTemporarySkill(skill : SSimpleSkill) : bool
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.RemoveTemporarySkill(skill);
			
		return false;
	}
	
	
	//modSigns: reworked, focus is drained in sign entity
	public function AddTemporarySkills() : bool
	{
		tempLearnedSignSkills.Clear();
		if(CanUseSkill(S_Sword_s19) && GetStat(BCS_Focus) >= 3)
		{
			tempLearnedSignSkills = ((W3PlayerAbilityManager)abilityManager).AddTempNonAlchemySkills();
			AddAbilityMultiple(SkillEnumToName(S_Sword_s19), GetSkillLevel(S_Sword_s19));
		}
		return tempLearnedSignSkills.Size();
	}

	
	
	public function HasAlternateQuen() : bool
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)GetCurrentSignEntity();
		if(quenEntity)
		{
			return quenEntity.IsAlternateCast();
		}
		
		return false;
	}
	
	
	
	
	
	public function AddPoints(type : ESpendablePointType, amount : int, show : bool)
	{
		levelManager.AddPoints(type, amount, show);
	}
	
	public function GetLevel() : int											{return levelManager.GetLevel();}
	public function GetMaxLevel() : int											{return levelManager.GetMaxLevel();}
	public function GetTotalExpForNextLevel() : int								{return levelManager.GetTotalExpForNextLevel();}	
	public function GetPointsTotal(type : ESpendablePointType) : int 			{return levelManager.GetPointsTotal(type);}
	public function IsAutoLeveling() : bool										{return autoLevel;}
	public function SetAutoLeveling( b : bool )									{autoLevel = b;}
	
	public function GetMissingExpForNextLevel() : int
	{
		return Max(0, GetTotalExpForNextLevel() - GetPointsTotal(EExperiencePoint));
	}
	
	
	
	
	private saved var runewordInfusionType : ESignType;
	default runewordInfusionType = ST_None;
	
	public final function GetRunewordInfusionType() : ESignType
	{
		return runewordInfusionType;
	}
	
	
	//modSigns: reworked
	public function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional forceSkillLevel : int, optional forceSpellPower : SAbilityAttributeValue )
	{
		var level, i, j : int;
		var atts, damages : array<name>;
		var ents : array<CGameplayEntity>;
		var action : W3DamageAction;
		var dm : CDefinitionsManagerAccessor;
		var skillAbilityName : name;
		var dmg : float;
		var min, max : SAbilityAttributeValue;
		var pos : Vector;
		var spellPower : SAbilityAttributeValue;
		var staminaPrc : float;
		
		//forced level (for Flood of Anger)
		if(forceSkillLevel > 0)
			level = forceSkillLevel;
		else
			level = GetSkillLevel(S_Magic_s13);
		
		//forced spell power (for Flood of Anger)
		if(forceSpellPower.valueMultiplicative > 0)
			spellPower = forceSpellPower;
		else
			spellPower = GetTotalSignSpellPower(S_Magic_4);
		
		dm = theGame.GetDefinitionsManager();
		skillAbilityName = GetSkillAbilityName(S_Magic_s13);
		
		//add damage
		if(level >= 2)
		{
			dm.GetAbilityAttributes(skillAbilityName, atts);
			for(i = 0; i < atts.Size(); i += 1)
			{
				if(IsDamageTypeNameValid(atts[i]))
					damages.PushBack(atts[i]);
			}
		}
		
		//find enemies in range
		//pos = signEntity.GetWorldPosition();
		//FindGameplayEntitiesInSphere(ents, pos, 3, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral + FLAG_TestLineOfSight, this);
		//modSigns: the above variant doesn't work properly. Use box instead of a sphere.
		FindGameplayEntitiesInRange(ents, this, 3, 100, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile, this);
		
		for(i = 0; i < ents.Size(); i += 1)
		{
			//debug log
			//theGame.witcherLog.AddMessage("Quen impulse:");
			//theGame.witcherLog.AddMessage("Target # " + (i + 1) + ": " + ents[i].GetDisplayName());
			
			//init damage action, use spell power and light hit reaction
			action = new W3DamageAction in theGame;
			action.Initialize(this, ents[i], signEntity, source, EHRT_Light, CPS_SpellPower, false, false, true, false);
			action.SetSignSkill(S_Magic_s13);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			
			//add damages
			if(level >= 2)
			{
				for(j = 0; j < damages.Size(); j += 1)
				{
					dm.GetAbilityAttributeValue(skillAbilityName, damages[j], min, max);
					//damage scales with ability level
					dmg = CalculateAttributeValue(GetAttributeRandomizedValue(min, max)) * (level - 1);
					if( HasGlyphwordActive( 'Glyphword 5 _Stats' ) ) //modSigns
					{
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Glyphword 5 _Stats', 'glyphword5_dmg_boost', min, max );
						dmg *= 1 + min.valueMultiplicative;
					}
					
					//debug log
					//theGame.witcherLog.AddMessage("Quen impulse dmg: " + dmg + " (" + damages[j] + ")");
					
					if(dmg > 0)
					{
						action.SetHitEffectAllTypes('hit_electric_quen');
						action.AddDamage(damages[j], dmg);
					}
				}
			}
			
			//add knockdown applicator (spell power will affect knockdown chances)
			if(level == 3)
				action.AddEffectInfo(EET_KnockdownTypeApplicator);
			//add stagger
			else if(level >= 1)
				action.AddEffectInfo(EET_Stagger);
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		if(isAlternate)
		{
			signEntity.PlayHitEffect('quen_impulse_explode', signEntity.GetWorldRotation());
			signEntity.EraseFirstTimeStamp();
			
			if(level >= 2)
			{
				//if(IsSetBonusActive( EISB_Bear_2 ))
				//{
				//	signEntity.PlayHitEffect('quen_electric_explode_bear_abl2', signEntity.GetWorldRotation());
				//}
				//else //ability changed
				signEntity.PlayHitEffect('quen_electric_explode', signEntity.GetWorldRotation());
			}
		}
		else
		{
			signEntity.PlayEffect('lasting_shield_impulse');
		}
	}
	
	//modSigns
	public function PlayGlyphword5FX(ent : CGameplayEntity)
	{
		var template : CEntityTemplate;
		var component : CComponent;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		component = ent.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', ent);
	}

	//called after both Aard casts, after normal Igni cast, for alt Igni called at the beginning of channeling,
	//after normal Yrden cast, for alt Yrden - at the end of the channeling, if it wasn't aborted,
	//after normal Quen cast, for alt Quen - at the beginning of the channeling,
	//after normal Axii cast, for alt Axii - at the end of the channeling, if it wasn't aborted.
	//modSigns: alt Igni and alt Quen calls moved to the end of channeling.
	public function OnSignCastPerformed(signType : ESignType, isAlternate : bool)
	{
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var fxName : name;
		var pos : Vector;
		//modSigns: new vars
		//var abilityName : name;
		//var abilityCount, maxStack : float;
		//var min, max : SAbilityAttributeValue;
		//var addAbility : bool;
		
		super.OnSignCastPerformed(signType, isAlternate);
		
		if(HasRunewordActive('Runeword 1 _Stats') && GetStat(BCS_Focus) >= 1.0f) //modSigns
		{
			DrainFocus(1.0f);
			runewordInfusionType = signType;
			items = inv.GetHeldWeapons();
			weaponEnt = inv.GetItemEntityUnsafe(items[0]);
			
			
			weaponEnt.StopEffect('runeword_aard');
			weaponEnt.StopEffect('runeword_axii');
			weaponEnt.StopEffect('runeword_igni');
			weaponEnt.StopEffect('runeword_quen');
			weaponEnt.StopEffect('runeword_yrden');
					
			
			if(signType == ST_Aard)
				fxName = 'runeword_aard';
			else if(signType == ST_Axii)
				fxName = 'runeword_axii';
			else if(signType == ST_Igni)
				fxName = 'runeword_igni';
			else if(signType == ST_Quen)
				fxName = 'runeword_quen';
			else if(signType == ST_Yrden)
				fxName = 'runeword_yrden';
				
			weaponEnt.PlayEffect(fxName);
		}
		
		
		if( IsMutationActive( EPMT_Mutation6 ) && signType == ST_Aard && !isAlternate )
		{
			pos = GetWorldPosition() + GetWorldForward() * 2;
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup( pos, 0.f, 3.f, 2.f, 5.f, 0 );
		}
		
		//modSigns: ancient leshed decoction fix -> decoction changed
		/*if(HasBuff(EET_Mutagen22) && IsInCombat() && IsThreatened() && !isAlternate)
		{
			abilityName = GetBuff(EET_Mutagen22).GetAbilityName();
			abilityCount = GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				AddAbility(abilityName, true);
			}
		}*/
		
		//modSigns
		if(!HasBuff(EET_GryphonSetBonus) && IsSetBonusActive( EISB_Gryphon_1 ))
		{
			AddEffectDefault( EET_GryphonSetBonus, NULL, signType );
		}
		
		//theGame.witcherLog.AddMessage("OnSignCastPerformed: " + signType + "; isAlternate: " + isAlternate); //modSigns: debug
	}
	
	public saved var savedQuenHealth, savedQuenDuration : float;
	
	timer function HACK_QuenSaveStatus(dt : float, id : int)
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;
		savedQuenHealth = quenEntity.GetShieldHealth();
		savedQuenDuration = quenEntity.GetShieldRemainingDuration();
	}
	
	timer function DelayedRestoreQuen(dt : float, id : int)
	{
		RestoreQuen(savedQuenHealth, savedQuenDuration);
	}
	
	public final function OnBasicQuenFinishing()
	{
		RemoveTimer('HACK_QuenSaveStatus');
		savedQuenHealth = 0.f;
		savedQuenDuration = 0.f;
	}
	
	public final function IsAnyQuenActive() : bool
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			return quen.IsAnyQuenActive();
			
		return false;
	}
	
	public final function IsQuenActive(alternateMode : bool) : bool
	{
		if(IsAnyQuenActive() && GetSignEntity(ST_Quen).IsAlternateCast() == alternateMode)
			return true;
			
		return false;
	}
	
	public function FinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			quen.ForceFinishQuen( skipVisuals, forceNoBearSetBonus );
	}
	
	
	public function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
	{
		var sp : SAbilityAttributeValue;
		var penalty : SAbilityAttributeValue;
		var penaltyReduction : float;
		var penaltyReductionLevel : int; 
		var mutagen : CBaseGameplayEffect; //modSigns
		var min, max : SAbilityAttributeValue; //modSigns

		//character SP + spell specific skills
		sp = GetSkillAttributeValue(signSkill, PowerStatEnumToName(CPS_SpellPower), true, true);
		
		//skill custom
		if ( signSkill == S_Magic_s01 )
		{
			//wave leveling penalty reduction
			/*penaltyReductionLevel = GetSkillLevel(S_Magic_s01) + 1;
			if(penaltyReductionLevel > 0)
			{
				penaltyReduction = 1 - penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', true, true));
				penalty = GetSkillAttributeValue(S_Magic_s01, PowerStatEnumToName(CPS_SpellPower), false, false);
				sp += penalty * penaltyReduction;	//add amount equal to penalty reduction (since full penalty is already applied)
			}*/
			//modSigns: fix percentages as they are completely off from what skill description says
			penaltyReductionLevel = GetSkillLevel(S_Magic_s01) - 1;
			if(penaltyReductionLevel > 0)
			{
				penaltyReduction = penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', false, false));
				//penalty was already applied, so we revert it based on penalty reduction and skill level
				sp.valueMultiplicative += penaltyReduction;
			}
		}
		
		
		if(signSkill == S_Magic_1 || signSkill == S_Magic_s01)
		{
			sp += GetAttributeValue('spell_power_aard');
		}
		else if(signSkill == S_Magic_2 || signSkill == S_Magic_s02)
		{
			sp += GetAttributeValue('spell_power_igni');
		}
		else if(signSkill == S_Magic_3 || signSkill == S_Magic_s03)
		{
			sp += GetAttributeValue('spell_power_yrden');
		}
		else if(signSkill == S_Magic_4 || signSkill == S_Magic_s04)
		{
			sp += GetAttributeValue('spell_power_quen');
		}
		else if(signSkill == S_Magic_5 || signSkill == S_Magic_s05)
		{
			sp += GetAttributeValue('spell_power_axii');
		}
		
		
		//ApplyMutation10StatBoost( sp ); //modSigns: reworked
		
		//modSigns: prevent negatives
		sp.valueBase = MaxF(sp.valueBase, 0);
		sp.valueMultiplicative = MaxF(sp.valueMultiplicative, 0);
		sp.valueAdditive = MaxF(sp.valueAdditive, 0);
	
		return sp;
	}
	
	
	
	
	
	public final function GetGwentCardIndex( cardName : name ) : int
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) 
		{
			return theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			return theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			return theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			return theGame.GetGwintManager().GwentSctlNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			return theGame.GetGwintManager().GwentMstrNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSke' ))
		{
			return theGame.GetGwintManager().GwentSkeNameToInt( cardName );
		}	
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			return theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			return theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
		}
		
		return -1;
	}
	
	public final function AddGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		var tut : STutorialMessage;
		var gwintManager : CR4GwintManager;
		
		
		
		if(FactsQuerySum("q001_nightmare_ended") > 0 && ShouldProcessTutorial('TutorialGwentDeckBuilder2'))
		{
			tut.type = ETMT_Hint;
			tut.tutorialScriptTag = 'TutorialGwentDeckBuilder2';
			tut.journalEntryName = 'TutorialGwentDeckBuilder2';
			tut.hintPositionType = ETHPT_DefaultGlobal;
			tut.markAsSeenOnShow = true;
			tut.hintDurationType = ETHDT_Long;

			theGame.GetTutorialSystem().DisplayTutorial(tut);
		}
		
		dm = theGame.GetDefinitionsManager();
		
		cardIndex = GetGwentCardIndex(cardName);
		
		if (cardIndex != -1)
		{
			FactsAdd("Gwint_Card_Looted");
			
			for(i = 0; i < amount; i += 1)
			{
				theGame.GetGwintManager().AddCardToCollection( cardIndex );
			}
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
		
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		gwintManager = theGame.GetGwintManager();
		if( !gwintManager.IsDeckUnlocked( GwintFaction_Skellige ) &&
			gwintManager.HasCardsOfFactionInCollection( GwintFaction_Skellige, false ) )
		{
			gwintManager.UnlockDeck( GwintFaction_Skellige );
		}
		
		return true;
	}
	
	
	public final function RemoveGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) 
		{
			cardIndex = theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSctlNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			cardIndex = theGame.GetGwintManager().GwentMstrNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
			
			
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		return true;
	}
	
	function CheckGwentTournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 70;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "GwentTournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			FactsAdd( "HasGwentTournamentDeck", 1 );
		}
		else
		{
			if( FactsDoesExist( "HasGwentTournamentDeck" ) )
			{
				FactsRemove( "HasGwentTournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "GwentTournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective1" ) )
			{
				FactsRemove( "GwentTournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "GwentTournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective2" ) )
			{
				FactsRemove( "GwentTournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "GwentTournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective3" ) )
			{
				FactsRemove( "GwentTournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "GwentTournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective4" ) )
			{
				FactsRemove( "GwentTournamentObjective4" );
			}
		}
	}
	
	function CheckEP2TournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 24;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "EP2Tournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			if( FactsQuerySum( "HasEP2TournamentDeck") == 0 )
			{
				FactsAdd( "HasEP2TournamentDeck", 1 );
			}
			
		}
		else
		{
			if( FactsDoesExist( "HasEP2TournamentDeck" ) )
			{
				FactsRemove( "HasEP2TournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "EP2TournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective1" ) )
			{
				FactsRemove( "EP2TournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "EP2TournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective2" ) )
			{
				FactsRemove( "EP2TournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "EP2TournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective3" ) )
			{
				FactsRemove( "EP2TournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "EP2TournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective4" ) )
			{
				FactsRemove( "EP2TournamentObjective4" );
			}
		}
	}
	
	
	
	
	
	
	public function SimulateBuffTimePassing(simulatedTime : float)
	{
		super.SimulateBuffTimePassing(simulatedTime);
		
		FinishQuen(true);
	}
	
	
	public function CanMeditate() : bool
	{
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		
		if(currentStateName == 'Exploration' && !CanPerformPlayerAction())
			return false;
		
		
		if(GetCurrentStateName() != 'Exploration' && GetCurrentStateName() != 'Meditation' && GetCurrentStateName() != 'MeditationWaiting')
			return false;
			
		
		if(GetUsedVehicle())
			return false;
			
		
		return CanMeditateHere();
	}
	
	
	public final function CanMeditateWait(optional skipMeditationStateCheck : bool) : bool
	{
		var currState : name;
		
		currState = GetCurrentStateName();
		
		
		
		if(!skipMeditationStateCheck && currState != 'Meditation')
			return false;
			
		
		if(theGame.IsGameTimePaused())
			return false;
			
		if(!IsActionAllowed( EIAB_MeditationWaiting ))
			return false;
			
		return true;
	}

	
	public final function CanMeditateHere() : bool
	{
		var pos	: Vector;
		
		pos = GetWorldPosition();
		if(pos.Z <= theGame.GetWorld().GetWaterLevel(pos, true) && IsInShallowWater())
			return false;
		
		if(IsThreatened())
			return false;
		
		return true;
	}
	
	
	public function Meditate() : bool
	{
		var medState 			: W3PlayerWitcherStateMeditation;
		var stateName 			: name;
	
		stateName = GetCurrentStateName();
	
		
		if (!CanMeditate()  || stateName == 'MeditationWaiting' )
			return false;
	
		GotoState('Meditation');
		medState = (W3PlayerWitcherStateMeditation)GetState('Meditation');		
		medState.SetMeditationPointHeading(GetHeading());
		
		return true;
	}
	
	
	public final function MeditationRestoring(simulatedTime : float)
	{			
		
		if ( theGame.GetDifficultyMode() != EDM_Hard && theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		}
		
		
		abilityManager.DrainToxicity( abilityManager.GetStat( BCS_Toxicity ) );
		abilityManager.DrainFocus( abilityManager.GetStat( BCS_Focus ) );
		
		
		inv.SingletonItemsRefillAmmo();
		
		
		SimulateBuffTimePassing(simulatedTime);
		
		
		ApplyWitcherHouseBuffs();
	}
	
	var clockMenu : CR4MeditationClockMenu;
	
	public function MeditationClockStart(m : CR4MeditationClockMenu)
	{
		clockMenu = m;
		AddTimer('UpdateClockTime',0.1,true);
	}
	
	public function MeditationClockStop()
	{
		clockMenu = NULL;
		RemoveTimer('UpdateClockTime');
	}
	
	public timer function UpdateClockTime(dt : float, id : int)
	{
		if(clockMenu)
			clockMenu.UpdateCurrentHours();
		else
			RemoveTimer('UpdateClockTime');
	}
	
	private var waitTimeHour : int;
	public function SetWaitTargetHour(t : int)
	{
		waitTimeHour = t;
	}
	public function GetWaitTargetHour() : int
	{
		return waitTimeHour;
	}
	
	public function MeditationForceAbort(forceCloseUI : bool)
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		var medd : W3PlayerWitcherStateMeditation;
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		if(currentStateName == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested(forceCloseUI);
			}
		}
		else if(currentStateName == 'Meditation')
		{
			medd = (W3PlayerWitcherStateMeditation)GetCurrentState();
			if(medd)
			{
				medd.StopRequested(forceCloseUI);
			}
		}
		
		
		
		if(forceCloseUI && theGame.GetGuiManager().IsAnyMenu())
		{
			theGame.GetGuiManager().GetRootMenu().CloseMenu();
			DisplayActionDisallowedHudMessage(EIAB_MeditationWaiting, false, false, true, false);
		}
	}
	
	public function Runeword10Triggerred()
	{
		var min, max : SAbilityAttributeValue; 
		
		//modSigns
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 10 _Stats', 'health', min, max );
		GainStat(BCS_Vitality, min.valueMultiplicative * GetStatMax(BCS_Vitality));
		PlayEffect('runeword_10_stamina');
	}
	
	public function Runeword12Triggerred()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 12 _Stats', 'focus', min, max );
		//GainStat(BCS_Focus, RandRangeF(max.valueAdditive, min.valueAdditive));
		GainStat(BCS_Focus, min.valueAdditive); //modSigns
		PlayEffect('runeword_20_adrenaline');	
	}
	
	/*var runeword10TriggerredOnFinisher, runeword12TriggerredOnFinisher : bool;
	
	event OnFinisherStart()
	{
		super.OnFinisherStart();
		
		runeword10TriggerredOnFinisher = false;
		runeword12TriggerredOnFinisher = false;
	}*/ //modSigns
	
	public function ApplyWitcherHouseBuffs()
	{
		var l_bed			: W3WitcherBed;
		
		if( FactsQuerySum( "PlayerInsideInnerWitcherHouse" ) > 0 )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			
			if( l_bed.GetWasUsed() )
			{
				if( l_bed.GetBedLevel() != 0 )
				{
					AddEffectDefault( EET_WellRested, this, "Bed Buff" );
				}

				if( FactsQuerySum( "StablesExists" ) )
				{
					AddEffectDefault( EET_HorseStableBuff, this, "Stables" );
				}
				
				if( l_bed.GetWereItemsRefilled() )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_applied" ),, true );
					l_bed.SetWereItemsRefilled( false );
				}
				
				AddEffectDefault( EET_BookshelfBuff, this, "Bookshelf" );
				
				Heal( GetStatMax( BCS_Vitality ) );
			}
		}
	}
	
	
	
	
	
	public function CheatResurrect()
	{
		super.CheatResurrect();
		theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
		theInput.RestoreContext( 'Exploration', true );	
	}
	
	
	public function Debug_EquipTestingSkills(equip : bool, force : bool)
	{
		var skills : array<ESkill>;
		var i, slot : int;
		
		
		((W3PlayerAbilityManager)abilityManager).OnLevelGained(36);
		
		skills.PushBack(S_Magic_s01);
		skills.PushBack(S_Magic_s02);
		skills.PushBack(S_Magic_s03);
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s05);
		skills.PushBack(S_Sword_s01);
		skills.PushBack(S_Sword_s02);
		
		
		if(equip)
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				if(!force && IsSkillEquipped(skills[i]))
					continue;
					
				
				if(GetSkillLevel(skills[i]) == 0)
					AddSkill(skills[i]);
				
				
				if(force)
					slot = i+1;		
				else
					slot = GetFreeSkillSlot();
				
				
				EquipSkill(skills[i], slot);
			}
		}
		else
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				UnequipSkill(GetSkillSlotID(skills[i]));
			}
		}
	}
	
	//modSigns
	public function Debug_RestoreMutagensSpent()
	{
		var total : array<int>;
		
		total = ((W3PlayerAbilityManager)abilityManager).GetMutationsUsedMutagens();
		
		if(total[0] > 0) inv.AddAnItem('Greater mutagen red', total[0]);
		if(total[1] > 0) inv.AddAnItem('Greater mutagen blue', total[1]);
		if(total[2] > 0) inv.AddAnItem('Greater mutagen green', total[2]);
	}

	//modSigns
	public function Debug_ClearCharacterDevelopment( optional resetLevels : bool )
	{
		var template : CEntityTemplate;
		var entity : CEntity;
		var invTesting : CInventoryComponent;
		var i, totalExp, currentLevel, totalSkillPoints : int;
		var items : array<SItemUniqueId>;
		var abs : array<name>;
		var isMutationSystemEnabled : bool;
		
		ForceSetStat(BCS_Toxicity, 0);
		
		UnequipItemFromSlot(EES_SilverSword);
		UnequipItemFromSlot(EES_SteelSword);
		UnequipItemFromSlot(EES_Bolt);
		UnequipItemFromSlot(EES_RangedWeapon);
		UnequipItemFromSlot(EES_Armor);
		UnequipItemFromSlot(EES_Boots);
		UnequipItemFromSlot(EES_Pants);
		UnequipItemFromSlot(EES_Gloves);
		UnequipItemFromSlot(EES_Petard1);
		UnequipItemFromSlot(EES_Petard2);
		UnequipItemFromSlot(EES_Quickslot1);
		UnequipItemFromSlot(EES_Quickslot2);
		UnequipItemFromSlot(EES_Potion1);
		UnequipItemFromSlot(EES_Potion2);
		UnequipItemFromSlot(EES_Potion3);
		UnequipItemFromSlot(EES_Potion4);
		UnequipItemFromSlot(EES_Mask);
		UnequipItemFromSlot(EES_SkillMutagen1);
		UnequipItemFromSlot(EES_SkillMutagen2);
		UnequipItemFromSlot(EES_SkillMutagen3);
		UnequipItemFromSlot(EES_SkillMutagen4);
		HorseUnequipItem(EES_HorseBlinders);
		HorseUnequipItem(EES_HorseSaddle);
		HorseUnequipItem(EES_HorseBag);
		HorseUnequipItem(EES_HorseTrophy);
		
		currentLevel = levelManager.GetLevel();
		totalExp = levelManager.GetPointsTotal(EExperiencePoint);
		totalSkillPoints = levelManager.GetPointsTotal(ESkillPoint);
		isMutationSystemEnabled = ((W3PlayerAbilityManager)abilityManager).IsMutationSystemEnabled();
		
		Debug_RestoreMutagensSpent();
		
		GetCharacterStats().GetAbilities(abs, false);
		for(i = 0; i < abs.Size(); i+=1)
			RemoveAbility(abs[i]);
		
		abs.Clear();
		GetCharacterStatsParam(abs);		
		for(i = 0; i < abs.Size(); i +=1 )
			AddAbility(abs[i]);
		
		delete levelManager;
		levelManager = new W3LevelManager in this;
		levelManager.Initialize();
		levelManager.PostInit(this, false, true);
		
		if(!resetLevels)
		{
			levelManager.AddPoints(EExperiencePoint, totalExp, false, true);
			levelManager.AddPoints(ESkillPoint, Max(0, totalSkillPoints - levelManager.GetPointsTotal(ESkillPoint)), false);
		}
		
		delete abilityManager;
		SetAbilityManager();
		abilityManager.Init(this, GetCharacterStats(), false, theGame.GetDifficultyMode());
		
		delete effectManager;
		SetEffectManager();
		
		abilityManager.PostInit();
		((W3PlayerAbilityManager)abilityManager).MutationSystemEnable(isMutationSystemEnabled);
	}
	
	function Debug_BearSetBonusQuenSkills()
	{
		var skills	: array<ESkill>;
		var i, slot	: int;
		
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s14);
		
		for(i=0; i<skills.Size(); i+=1)
		{				
			
			if(GetSkillLevel(skills[i]) == 0)
			{
				AddSkill(skills[i]);
			}
			
			slot = GetFreeSkillSlot();
			
			
			EquipSkill(skills[i], slot);
		}
	}
	
	final function Debug_HAX_UnlockSkillSlot(slotIndex : int) : bool
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).Debug_HAX_UnlockSkillSlot(slotIndex);
			
		return false;
	}
	
	
	public function GetLevelupAbility( id : int) : name
	{
		switch(id)
		{
			case 1: return 'Lvl1';
			case 2: return 'Lvl2';
			case 3: return 'Lvl3';
			case 4: return 'Lvl4';
			case 5: return 'Lvl5';
			case 6: return 'Lvl6';
			case 7: return 'Lvl7';
			case 8: return 'Lvl8';
			case 9: return 'Lvl9';
			case 10: return 'Lvl10';
			case 11: return 'Lvl11';
			case 12: return 'Lvl12';
			case 13: return 'Lvl13';
			case 14: return 'Lvl14';
			case 15: return 'Lvl15';
			case 16: return 'Lvl16';
			case 17: return 'Lvl17';
			case 18: return 'Lvl18';
			case 19: return 'Lvl19';
			case 20: return 'Lvl20';
			case 21: return 'Lvl21';
			case 22: return 'Lvl22';
			case 23: return 'Lvl23';
			case 24: return 'Lvl24';
			case 25: return 'Lvl25';
			case 26: return 'Lvl26';
			case 27: return 'Lvl27';
			case 28: return 'Lvl28';
			case 29: return 'Lvl29';
			case 30: return 'Lvl30';
			case 31: return 'Lvl31';
			case 32: return 'Lvl32';
			case 33: return 'Lvl33';
			case 34: return 'Lvl34';
			case 35: return 'Lvl35';
			case 36: return 'Lvl36';
			case 37: return 'Lvl37';
			case 38: return 'Lvl38';
			case 39: return 'Lvl39';
			case 40: return 'Lvl40';
			case 41: return 'Lvl41';
			case 42: return 'Lvl42';
			case 43: return 'Lvl43';
			case 44: return 'Lvl44';
			case 45: return 'Lvl45';
			case 46: return 'Lvl46';
			case 47: return 'Lvl47';
			case 48: return 'Lvl48';
			case 49: return 'Lvl49';
			case 50: return 'Lvl50';
		
			default: return '';
		}
		
		return '';
	}	
	
	public function CanSprint( speed : float ) : bool
	{
		/*if( !super.CanSprint( speed ) )
		{
			return false;
		}		*/ //modSings
		if(theGame.GetEngineTimeAsSeconds() - blockSprintTimestamp < 2) //modSigns
		{
			return false;
		}
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			if ( this.GetPlayerCombatStance() ==  PCS_AlertNear )
			{
				if ( IsSprintActionPressed() )
					OnRangedForceHolster( true, false );
			}
			else
				return false;
		}
		if( GetCurrentStateName() != 'Swimming' && GetStat(BCS_Stamina) <= 0 )
		{
			SetSprintActionPressed(false,true);
			blockSprintTimestamp = theGame.GetEngineTimeAsSeconds(); //modSings
			return false;
		}
		
		return super.CanSprint( speed ); //modSigns: moved here
	}
	
	var blockSprintTimestamp : float; //modSings
	
	public function ManageSleeping()
	{
		thePlayer.RemoveBuffImmunity_AllCritical( 'Bed' );
		thePlayer.RemoveBuffImmunity_AllNegative( 'Bed' );

		thePlayer.PlayerStopAction( PEA_GoToSleep );
	}
	
	
	
	public function RestoreHorseManager() : bool
	{
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;	
		
		if ( GetHorseManager() )
		{
			return false;
		}
		
		horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
		horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
		horseManager.CreateAttachment(this);
		horseManager.OnCreated();
		EntityHandleSet( horseManagerHandle, horseManager );	
		
		return true;
	}
	
	
	
	
	
	
	final function PerformParryCheck( parryInfo : SParryInfo ) : bool
	{
		if( super.PerformParryCheck( parryInfo ) )
		{
			//GainAdrenalineFromPerk21( 'parry' ); //modSigns
			return true;
		}
		return false;
	}	
	
	protected final function PerformCounterCheck( parryInfo: SParryInfo ) : bool
	{
		var fistFightCheck, isInFistFight		: bool;
		
		if( super.PerformCounterCheck( parryInfo ) )
		{
			//GainAdrenalineFromPerk21( 'counter' ); //modSigns
			
			isInFistFight = FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightCheck );
			
			if( isInFistFight && fistFightCheck )
			{
				FactsAdd( "statistics_fist_fight_counter" );
				AddTimer( 'FistFightCounterTimer', 0.5f, , , , true );
			}
			
			return true;
		}
		return false;
	}
	
	/*public function GainAdrenalineFromPerk21( n : name )
	{
		var perkStats, perkTime : SAbilityAttributeValue;
		var targets	: array<CActor>;
		
		targets = GetHostileEnemies();
		
		if( !CanUseSkill( S_Perk_21 ) || targets.Size() == 0 )
		{
			return;
		}
		
		perkTime = GetSkillAttributeValue( S_Perk_21, 'perk21Time', false, false );
		
		if( theGame.GetEngineTimeAsSeconds() >= timeForPerk21 + perkTime.valueAdditive )
		{
			perkStats = GetSkillAttributeValue( S_Perk_21, n , false, false );
			GainStat( BCS_Focus, perkStats.valueAdditive );
			timeForPerk21 = theGame.GetEngineTimeAsSeconds();
			
			AddEffectDefault( EET_Perk21InternalCooldown, this, "Perk21", false );
		}	
	}*/ //modSigns
	
	public function Perk21GainStamina(action : name) //modSigns
	{
		var min, max : SAbilityAttributeValue;
		
		if(!HasBuff(EET_Perk21InternalCooldown) || action == 'kill')
		{
			switch(action)
			{
				case 'kill':
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_21', 'stamina_kill', min, max);
					GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
					break;
				case 'crit':
				case 'counter':
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_21', 'stamina_other', min, max);
					GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
					break;
				default:
					break;
			}
			AddEffectDefault(EET_Perk21InternalCooldown, this, "Perk21");
		}
	}
	
	timer function FistFightCounterTimer( dt : float, id : int )
	{
		FactsRemove( "statistics_fist_fight_counter" );
	}
	
	public final function IsSignBlocked(signType : ESignType) : bool
	{
		switch( signType )
		{
			case ST_Aard :
				return IsRadialSlotBlocked ( 'Aard');
				break;
			case ST_Axii :
				return IsRadialSlotBlocked ( 'Axii');
				break;
			case ST_Igni :
				return IsRadialSlotBlocked ( 'Igni');
				break;
			case ST_Quen :
				return IsRadialSlotBlocked ( 'Quen');
				break;
			case ST_Yrden :
				return IsRadialSlotBlocked ( 'Yrden');
				break;
			default:
				break;
		}
		return false;
		
	}
	
	public final function AddAnItemWithAutogenLevelAndQuality(itemName : name, desiredLevel : int, minQuality : int, optional equipItem : bool)
	{
		var itemLevel, quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;
		
		itemLevel = 0;
		quality = 0;
		attemptCounter = 0;
		while(itemLevel != desiredLevel || quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			
			if(attemptCounter >= 1000)
				break;
			
			if(itemLevel != desiredLevel || quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equipItem)
			EquipItem(ids[0]);
	}
	
	public final function AddAnItemWithAutogenLevel(itemName : name, desiredLevel : int)
	{
		var itemLevel : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		itemLevel = 0;
		while(itemLevel != desiredLevel)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			
			
			if(attemptCounter >= 1000)
				break;
				
			if(itemLevel != desiredLevel)
				inv.RemoveItem(ids[0]);
		}
	}
	
	public final function AddAnItemWithMinQuality(itemName : name, minQuality : int, optional equip : bool)
	{
		var quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		quality = 0;
		while(quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			
			if(attemptCounter >= 1000)
				break;
				
			if(quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equip)
			EquipItem(ids[0]);
	}
	
	
	
	
	
	
	//modSigns: fix equipped, only once
	private function RecalcSetItemsEquipped()
	{
		var slotsToCheck : array<EEquipmentSlots>;
		var setType : EItemSetType;
		var item : SItemUniqueId;
		var i : int;
		
		for(i = 0; i < amountOfSetPiecesEquipped.Size(); i += 1)
			amountOfSetPiecesEquipped[i] = 0;
		
		slotsToCheck.PushBack(EES_Armor);
		slotsToCheck.PushBack(EES_Boots);
		slotsToCheck.PushBack(EES_Pants);
		slotsToCheck.PushBack(EES_Gloves);
		slotsToCheck.PushBack(EES_SilverSword);
		slotsToCheck.PushBack(EES_SteelSword);
	
		for(i = 0; i < slotsToCheck.Size(); i += 1)
		{
			if(GetItemEquippedOnSlot(slotsToCheck[i], item) && inv.ItemHasTag(item, 'SetBonusPiece'))
			{
				setType = CheckSetType( item );
				amountOfSetPiecesEquipped[ setType ] += 1;
				ManageSetBonusesSoundbanks( setType );
			}
		}
	}
	
	//modSigns: minor sets added
	public function IsSetBonusActive( bonus : EItemSetBonus ) : bool
	{
		switch(bonus)
		{
			case EISB_Lynx_1:
				return amountOfSetPiecesEquipped[ EIST_Lynx ] + amountOfSetPiecesEquipped[ EIST_Lynx_Minor ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Lynx_2:
				return amountOfSetPiecesEquipped[ EIST_Lynx ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Gryphon_1:
				return amountOfSetPiecesEquipped[ EIST_Gryphon ] + amountOfSetPiecesEquipped[ EIST_Gryphon_Minor ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Gryphon_2:
				return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Bear_1:
				return amountOfSetPiecesEquipped[ EIST_Bear ] + amountOfSetPiecesEquipped[ EIST_Bear_Minor ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Bear_2:
				return amountOfSetPiecesEquipped[ EIST_Bear ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Wolf_1:
				return amountOfSetPiecesEquipped[ EIST_Wolf ] + amountOfSetPiecesEquipped[ EIST_Wolf_Minor ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Wolf_2:
				return amountOfSetPiecesEquipped[ EIST_Wolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_RedWolf_1:
				return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_RedWolf_2:
				return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Vampire:
				return amountOfSetPiecesEquipped[ EIST_Vampire ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			//modSigns
			case EISB_Viper:
				return amountOfSetPiecesEquipped[ EIST_Viper ] >= GetNumItemsRequiredForSetActivation(EIST_Viper);
			case EISB_KaerMorhen:
				return amountOfSetPiecesEquipped[ EIST_KaerMorhen ] >= GetNumItemsRequiredForSetActivation(EIST_KaerMorhen);
			default:					return false;
		}
	}
	
	//modSigns: minor sets
	public function GetSetPartsEquipped( setType : EItemSetType ) : int
	{
		switch( setType )
		{
			case EIST_Lynx:
			case EIST_Lynx_Minor:
				return amountOfSetPiecesEquipped[ EIST_Lynx ] + amountOfSetPiecesEquipped[ EIST_Lynx_Minor ];
			case EIST_Gryphon:
			case EIST_Gryphon_Minor:
				return amountOfSetPiecesEquipped[ EIST_Gryphon ] + amountOfSetPiecesEquipped[ EIST_Gryphon_Minor ];
			case EIST_Bear:
			case EIST_Bear_Minor:
				return amountOfSetPiecesEquipped[ EIST_Bear ] + amountOfSetPiecesEquipped[ EIST_Bear_Minor ];
			case EIST_Wolf:
			case EIST_Wolf_Minor:
				return amountOfSetPiecesEquipped[ EIST_Wolf ] + amountOfSetPiecesEquipped[ EIST_Wolf_Minor ];
			default:
				return amountOfSetPiecesEquipped[ setType ];
		}
	}
	
	//modSigns
	public function GetSetPartsEquippedRaw( setType : EItemSetType ) : int
	{
		return amountOfSetPiecesEquipped[ setType ];
	}
	
	//modSigns
	public function HasMixedSetsEquipped() : bool
	{
		return	amountOfSetPiecesEquipped[ EIST_Lynx ] > 0 && amountOfSetPiecesEquipped[ EIST_Lynx_Minor ] > 0 ||
				amountOfSetPiecesEquipped[ EIST_Gryphon ] > 0 && amountOfSetPiecesEquipped[ EIST_Gryphon_Minor ] > 0 ||
				amountOfSetPiecesEquipped[ EIST_Bear ] > 0 && amountOfSetPiecesEquipped[ EIST_Bear_Minor ] > 0 ||
				amountOfSetPiecesEquipped[ EIST_Wolf ] > 0 && amountOfSetPiecesEquipped[ EIST_Wolf_Minor ] > 0;
	}
	
	protected function UpdateItemSetBonuses( item : SItemUniqueId, increment : bool )
	{
		var setType : EItemSetType;
		var tutorialStateSets : W3TutorialManagerUIHandlerStateSetItemsUnlocked;
		var id : SItemUniqueId;
					
		if( !inv.IsIdValid( item ) || !inv.ItemHasTag(item, theGame.params.ITEM_SET_TAG_BONUS ) )  
		{
			
			if( !IsSetBonusActive( EISB_Wolf_2 ) ) //modSigns
			{
				if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
				{
					RemoveExtraOilsFromItem( id );
				}
				if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
				{
					RemoveExtraOilsFromItem( id );
				}
			}
		
			return;
		}
		
		setType = CheckSetType( item );
		
		if( increment )
		{
			amountOfSetPiecesEquipped[ setType ] += 1;
			
			//modSigns
			if( GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType) && ShouldProcessTutorial( 'TutorialSetBonusesUnlocked' ) && theGame.GetTutorialSystem().uiHandler && theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'SetItemsUnlocked' )
			{
				tutorialStateSets = ( W3TutorialManagerUIHandlerStateSetItemsUnlocked )theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				tutorialStateSets.OnSetBonusCompleted();
			}
		}
		else if( amountOfSetPiecesEquipped[ setType ] > 0 )
		{
			amountOfSetPiecesEquipped[ setType ] -= 1;
		}
		
		
		//modSigns
		//if( setType < EIST_Viper && amountOfSetPiecesEquipped[ setType ] == theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS )
		if( IsSetBonusActive(EISB_Lynx_2) || IsSetBonusActive(EISB_Gryphon_2) || IsSetBonusActive(EISB_Bear_2) || IsSetBonusActive(EISB_Wolf_2) || IsSetBonusActive(EISB_RedWolf_2) )
		{
			theGame.GetGamerProfile().AddAchievement( EA_ReadyToRoll );
		}
		
		
		if( !IsSetBonusActive( EISB_Wolf_2 ) ) //modSigns
		{
			if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
			{
				RemoveExtraOilsFromItem( id );
			}
			if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
			{
				RemoveExtraOilsFromItem( id );
			}
		}
		
		ManageActiveSetBonuses( setType );
		
		
		ManageSetBonusesSoundbanks( setType );
	}
	
	public function ManageActiveSetBonuses( setType : EItemSetType )
	{
		var l_i				: int;
		
		
		if( setType == EIST_Lynx || setType == EIST_Lynx_Minor ) //modSigns
		{
			
			if( HasBuff( EET_LynxSetBonus ) && !IsSetBonusActive( EISB_Lynx_1 ) )
			{
				RemoveBuff( EET_LynxSetBonus );
			}
		}
		
		else if( setType == EIST_Gryphon )
		{
			
			if( !IsSetBonusActive( EISB_Gryphon_1 ) )
			{
				RemoveBuff( EET_GryphonSetBonus );
			}
			
			if( IsSetBonusActive( EISB_Gryphon_2 ) && !HasBuff( EET_GryphonSetBonusYrden ) )
			{
				for( l_i = 0 ; l_i < yrdenEntities.Size() ; l_i += 1 )
				{
					if( yrdenEntities[ l_i ].GetIsPlayerInside() && !yrdenEntities[ l_i ].IsAlternateCast() )
					{
						AddEffectDefault( EET_GryphonSetBonusYrden, this, "GryphonSetBonusYrden" );
						break;
					}
				}
			}
			else
			{
				RemoveBuff( EET_GryphonSetBonusYrden );
			}
		}
		
		//modSigns
		else if( setType == EIST_KaerMorhen )
		{
			if( !IsSetBonusActive(EISB_KaerMorhen) && HasBuff(EET_KaerMorhenSetBonus) )
			{
				RemoveBuff(EET_KaerMorhenSetBonus);
			}
			else if( IsSetBonusActive(EISB_KaerMorhen) && !HasBuff(EET_KaerMorhenSetBonus) && IsInCombat() )
			{
				AddEffectDefault(EET_KaerMorhenSetBonus, this, "KaerMorhenSetBonus");
			}
		}
	}
	
	public function CheckSetTypeByName( itemName : name ) : EItemSetType
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX ) )
		{
			return EIST_Lynx;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON ) )
		{
			return EIST_Gryphon;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR ) )
		{
			return EIST_Bear;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF ) )
		{
			return EIST_Wolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_RED_WOLF ) )
		{
			return EIST_RedWolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) )
		{
			return EIST_Vampire;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VIPER ) )
		{
			return EIST_Viper;
		}
		else
		//modSigns
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_KAER_MORHEN ) )
		{
			return EIST_KaerMorhen;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX_MINOR ) )
		{
			return EIST_Lynx_Minor;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON_MINOR ) )
		{
			return EIST_Gryphon_Minor;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR_MINOR ) )
		{
			return EIST_Bear_Minor;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF_MINOR ) )
		{
			return EIST_Wolf_Minor;
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	public function CheckSetType( item : SItemUniqueId ) : EItemSetType
	{
		var stopLoop 	: bool;
		var tags 		: array<name>;
		var i 			: int;
		var setType 	: EItemSetType;
		
		stopLoop = false;
		
		inv.GetItemTags( item, tags );
		
		
		for( i=0; i<tags.Size(); i+=1 )
		{
			switch( tags[i] )
			{
				case theGame.params.ITEM_SET_TAG_LYNX:
				case theGame.params.ITEM_SET_TAG_GRYPHON:
				case theGame.params.ITEM_SET_TAG_BEAR:
				case theGame.params.ITEM_SET_TAG_WOLF:
				case theGame.params.ITEM_SET_TAG_RED_WOLF:
				case theGame.params.ITEM_SET_TAG_VAMPIRE:
				case theGame.params.ITEM_SET_TAG_VIPER:
				//modSigns
				case theGame.params.ITEM_SET_TAG_KAER_MORHEN:
				case theGame.params.ITEM_SET_TAG_LYNX_MINOR:
				case theGame.params.ITEM_SET_TAG_GRYPHON_MINOR:
				case theGame.params.ITEM_SET_TAG_BEAR_MINOR:
				case theGame.params.ITEM_SET_TAG_WOLF_MINOR:
					setType = SetItemNameToType( tags[i] );
					stopLoop = true;
					break;
			}		
			if ( stopLoop )
			{
				break;
			}
		}
		
		return setType;
	}
	
	public function GetSetBonusStatusByName( itemName : name, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetTypeByName( itemName );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;		
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	public function GetSetBonusStatus( item : SItemUniqueId, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetType( item );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	private function SetBonusStatusByType(setType : EItemSetType, out desc1, desc2 : string, out isActive1, isActive2 : bool):void
	{
		var setBonus : EItemSetBonus;
		
		//modSigns
		isActive1 = (GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType));
		isActive2 = (amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS);
		
		setBonus = ItemSetTypeToItemSetBonus( setType, 1 );
		desc1 = GetSetBonusTooltipDescription( setBonus );
		
		setBonus = ItemSetTypeToItemSetBonus( setType, 2 );
		desc2 = GetSetBonusTooltipDescription( setBonus );
	}
	
	public function ItemSetTypeToItemSetBonus( setType : EItemSetType, nr : int ) : EItemSetBonus
	{
		var setBonus : EItemSetBonus;
	
		if( nr == 1 )
		{
			switch( setType )
			{
				case EIST_Lynx: 			setBonus = EISB_Lynx_1;		break;
				case EIST_Gryphon: 			setBonus = EISB_Gryphon_1;	break;
				case EIST_Bear: 			setBonus = EISB_Bear_1;		break;
				case EIST_Wolf: 			setBonus = EISB_Wolf_1;		break;
				case EIST_RedWolf: 			setBonus = EISB_RedWolf_1;	break;
				case EIST_Vampire:			setBonus = EISB_Vampire;	break;
				//modSigns
				case EIST_Viper:			setBonus = EISB_Viper;		break;
				case EIST_KaerMorhen:		setBonus = EISB_KaerMorhen;	break;
				case EIST_Lynx_Minor:		setBonus = EISB_Lynx_1;		break;
				case EIST_Gryphon_Minor:	setBonus = EISB_Gryphon_1;	break;
				case EIST_Bear_Minor:		setBonus = EISB_Bear_1;		break;
				case EIST_Wolf_Minor:		setBonus = EISB_Wolf_1;		break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx: 			setBonus = EISB_Lynx_2;		break;
				case EIST_Gryphon: 			setBonus = EISB_Gryphon_2;	break;
				case EIST_Bear: 			setBonus = EISB_Bear_2;		break;
				case EIST_Wolf: 			setBonus = EISB_Wolf_2;		break;
				case EIST_RedWolf: 			setBonus = EISB_RedWolf_2;	break;
				case EIST_Vampire:			setBonus = EISB_Undefined;	break;
				//modSigns
				case EIST_Viper:			setBonus = EISB_Undefined;	break;
				case EIST_KaerMorhen:		setBonus = EISB_Undefined;	break;
				case EIST_Lynx_Minor:		setBonus = EISB_Undefined;	break;
				case EIST_Gryphon_Minor:	setBonus = EISB_Undefined;	break;
				case EIST_Bear_Minor:		setBonus = EISB_Undefined;	break;
				case EIST_Wolf_Minor:		setBonus = EISB_Undefined;	break;
			}
		} 
	
		return setBonus;
	}
	
	public function GetSetBonusTooltipDescription( bonus : EItemSetBonus ) : string
	{
		var finalString : string;
		var arrString	: array<string>;
		var dm			: CDefinitionsManagerAccessor;
		var min, max 	: SAbilityAttributeValue;
		var tempString	: string;
		var tmpVal		: float; //modSigns
		
		switch( bonus )
		{
			case EISB_Lynx_1:			tempString = "skill_desc_lynx_set_ability1"; break;
			case EISB_Lynx_2:			tempString = "skill_desc_lynx_set_ability2"; break;
			case EISB_Gryphon_1:		tempString = "skill_desc_gryphon_set_ability1"; break;
			case EISB_Gryphon_2:		tempString = "skill_desc_gryphon_set_ability2"; break;
			case EISB_Bear_1:			tempString = "skill_desc_bear_set_ability1"; break;
			case EISB_Bear_2:			tempString = "skill_desc_bear_set_ability2"; break;
			case EISB_Wolf_1:			tempString = "skill_desc_wolf_set_ability1"; break;
			case EISB_Wolf_2:			tempString = "skill_desc_wolf_set_ability2"; break;
			case EISB_RedWolf_1:		tempString = "skill_desc_red_wolf_set_ability1"; break;
			case EISB_RedWolf_2:		tempString = "skill_desc_red_wolf_set_ability2"; break;
			case EISB_Vampire:			tempString = "skill_desc_vampire_set_ability1"; break;
			//modSigns
			case EISB_Viper:			tempString = "skill_desc_viper_set_ability1"; break;
			case EISB_KaerMorhen:		tempString = "skill_desc_kaer_morhen_set_ability1"; break;
			default:					tempString = ""; break;
		}
		
		dm = theGame.GetDefinitionsManager();
		
		switch( bonus )
		{
		case EISB_Lynx_1:
			dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_ap_boost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
			arrString.PushBack( FloatToString( min.valueAdditive * 100 * GetSetPartsEquipped( EIST_Lynx ) ) );
			dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_boost_max', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Lynx_2:
			//modSigns: changed
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Gryphon_1:
			//modSigns: new mechanic
			dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'gryphon_tier1_bonus', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
			arrString.PushBack( FloatToString( min.valueAdditive * 100 * GetSetPartsEquipped( EIST_Gryphon ) ) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'duration', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;		
		case EISB_Gryphon_2:
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			arrString.PushBack( FloatToString( ( min.valueAdditive - 1 )* 100) );
			//dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'staminaRegen', min, max ); //modSigns: removed
			//arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'spell_power', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'slashing_resistance_perc', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_1: //modSigns: full set redesign
			dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'bonus_focus_gain', min, max );
			arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) ) );
			arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) * GetSetPartsEquipped( EIST_Bear ) ) );
			dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'attack_power', min, max );
			arrString.PushBack( NoTrailZeros( min.valueMultiplicative * 100 ) );
			arrString.PushBack( NoTrailZeros( min.valueMultiplicative * 100 * GetSetPartsEquipped( EIST_Bear ) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_2: //modSigns: full set redesign
			dm.GetAbilityAttributeValue( 'setBonusAbilityBear_2', 'stamina_attack', min, max );
			arrString.PushBack( NoTrailZeros( CalculateAttributeValue(min) * 100 ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		//modSigns
		case EISB_Wolf_1:
			dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_1', 'per_piece_oil_bonus', min, max );
			arrString.PushBack( RoundMath( CalculateAttributeValue(min) * 100 ) );
			arrString.PushBack( RoundMath( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_Wolf ) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Wolf_2:
			dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_2', 'per_oil_crit_chance_bonus', min, max );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
			dm.GetAbilityAttributeValue( 'SetBonusAbilityWolf_2', 'per_oil_crit_power_bonus', min, max );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_RedWolf_1:
			dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_1', 'per_redwolf_piece_crit_chance_bonus', min, max );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_RedWolf ) ) );
			dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_1', 'per_redwolf_piece_crit_power_bonus', min, max );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_RedWolf ) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_RedWolf_2:
			dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_2', 'amount', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Vampire:
			dm.GetAbilityAttributeValue( 'setBonusAbilityVampire', 'life_percent', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			arrString.PushBack( FloatToString( min.valueAdditive * GetSetPartsEquipped( EIST_Vampire ) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		//modSigns
		case EISB_Viper:
			dm.GetAbilityAttributeValue( 'setBonusAbilityViper_1', 'per_viper_piece_poison_healing_rate', min, max );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 ) );
			arrString.PushBack( FloatToString( CalculateAttributeValue(min) * 100 * GetSetPartsEquipped( EIST_Viper ) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_KaerMorhen:
			dm.GetAbilityAttributeValue( 'KaerMorhenSetBonusEffect', 'staminaRegen', min, max );
			tmpVal = CalculateAttributeValue(min);
			arrString.PushBack( FloatToString( tmpVal ) );
			dm.GetAbilityAttributeValue( 'KaerMorhenSetBonusEffect', 'maxStacks', min, max );
			arrString.PushBack( FloatToString( tmpVal * CalculateAttributeValue(min) ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		default:
			finalString = GetLocStringByKeyExtWithParams( tempString );
		}
		
		return finalString;
	}
	
	//modSigns
	public function LoadCurrentSetBonusSoundbank()
	{
		if(IsSetBonusActive(EISB_Lynx_1) || IsSetBonusActive(EISB_Lynx_2))
		{
			LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
		}
		if(IsSetBonusActive(EISB_Gryphon_1) || IsSetBonusActive(EISB_Gryphon_2))
		{
			LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
		}
		//if(IsSetBonusActive(EISB_Bear_1) || IsSetBonusActive(EISB_Bear_2))
		//{
			LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
		//} //should always be loaded as it's used by regular Quen now!
	}
	
	public function ManageSetBonusesSoundbanks( setType : EItemSetType )
	{
		//modSigns
		if( GetSetPartsEquipped(setType) >= GetNumItemsRequiredForSetActivation(setType) )
		{
			switch( setType )
			{
				case EIST_Lynx:
					LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
					LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
					LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx:
					UnloadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
					UnloadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
					UnloadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
	}
	
	public function VampiricSetAbilityRegeneration()
	{
		var healthMax		: float;
		var healthToReg		: float;
		var healthPrc		: float; //modSigns
		var min, max		: SAbilityAttributeValue; //modSigns
		
		healthMax = GetStatMax( BCS_Vitality );
		
		//modSigns: whoever decided that assuming no one will ever change xml values
		//should be thrown to harpies
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'setBonusAbilityVampire', 'life_percent', min, max );
		healthPrc = min.valueAdditive;

		healthToReg = ( healthPrc * GetSetPartsEquipped(EIST_Vampire) * healthMax ) / 100;
		
		//PlayEffect('drain_energy_caretaker_shovel');
		GainStat( BCS_Vitality, healthToReg );
	}
	
	private function LoadSetBonusSoundBank( bankName : string )
	{
		if( !theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundLoadBank( bankName, true );
		}
	}
	
	private function UnloadSetBonusSoundBank( bankName : string )
	{
		if( theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundUnloadBank( bankName );
		}
	}
	
	timer function BearSetBonusQuenReapply( dt : float, id : int )
	{
		var newQuen		: W3QuenEntity;
		
		newQuen = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
		newQuen.Init( signOwner, GetSignEntity( ST_Quen ), true );
		newQuen.freeCast = true; //modSigns
		newQuen.OnStarted();
		newQuen.OnThrowing();
		newQuen.OnEnded();
		
		m_quenReappliedCount += 1;
		
		RemoveTimer( 'BearSetBonusQuenReapply');
	}
	
	//modSigns: gryphon set tier 1 bonus
	public function GetGryphonSetTier1Bonus() : float
	{
		var abl			: SAbilityAttributeValue;
		
		abl = GetAttributeValue( 'gryphon_tier1_bonus' );
		return abl.valueAdditive * GetSetPartsEquipped( EIST_Gryphon );
	}
	
	//modSigns: griffin school perk bonus
	public function GetPerk6StaminaCostReduction() : float
	{
		var abl			: SAbilityAttributeValue;
		var bonus		: float;
		
		abl = GetAttributeValue('perk_6_stamina_cost_reduction');
		bonus = abl.valueMultiplicative;
		bonus = ClampF(bonus, 0, 1);
		
		//theGame.witcherLog.AddMessage("stamina reduction bonus: " + bonus);
		
		return bonus;
	}
	
	//modSigns
	timer function GiveStandAloneEP1Items(dt : float, timerId : int)
	{
		var items : array<SItemUniqueId>;
		
		if( inv )
		{			
			inv.GetAllItems(items);
			if( items.Size() <= 0 )
				return;
		}
		else
			return;
		
		StandaloneEp1_1();
		
		FactsAdd("standalone_ep1_inv", 1);
			
		RemoveTimer('GiveStandAloneEP1Items');
	}
	
	//modSigns
	timer function GiveStandAloneEP2Items(dt : float, timerId : int)
	{
		var items : array<SItemUniqueId>;
		
		if( inv )
		{			
			inv.GetAllItems(items);
			if( items.Size() <= 0 )
				return;
		}
		else
			return;
		
		StandaloneEp2_1();
		
		FactsAdd("standalone_ep2_inv", 1);
			
		RemoveTimer('GiveStandAloneEP2Items');
	}
	
	public final function StandaloneEp1_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd("StandAloneEP1", 1);
		
		
		inv.RemoveAllItems();
		
		
		inv.AddAnItem('Illusion Medallion', 1, true, true, false);
		inv.AddAnItem('q103_safe_conduct', 1, true, true, false);
		
		
		theGame.GetGamerProfile().ClearAllAchievementsForEP1();
		
		
		STARTING_LEVEL = 32;
		inc = STARTING_LEVEL - GetLevel();
		for(i=0; i<inc; i+=1)
		{
			levelManager.AddPoints(EExperiencePoint, levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint), false);
		}
		
		
		levelManager.ResetCharacterDev();
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints(levelManager.GetLevel() - 1 + 11);	
		
		
		//modSigns
		inv.AddAnItem('Greater mutagen red', 1);
		inv.AddAnItem('Greater mutagen green', 1);
		inv.AddAnItem('Greater mutagen blue', 1);
		inv.AddAnItem('Mutagen red', 2);
		inv.AddAnItem('Mutagen green', 2);
		inv.AddAnItem('Mutagen blue', 2);
		inv.AddAnItem('Lesser mutagen red', 2);
		inv.AddAnItem('Lesser mutagen green', 2);
		inv.AddAnItem('Lesser mutagen blue', 2);
		
		
		startingMoney = 4000;
		if(GetMoney() > startingMoney)
		{
			RemoveMoney(GetMoney() - startingMoney);
		}
		else
		{
			AddMoney( 4000 - GetMoney() );
		}
		
		
		
		
		
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Armor');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Boots');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Gloves');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Pants');
		EquipItem(ids[0]);
		
		
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Steel Sword');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Silver Sword');
		EquipItem(ids[0]);
		
		
		inv.AddAnItem('Torch', 1, true, true, false);
		
		
		//modSigns
		quantityLow = 1;
		randLow = 2;
		quantityMedium = 2;
		randMedium = 2;
		quantityHigh = 3;
		randHigh = 2;
		
		inv.AddAnItem('Alghoul bone marrow',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Amethyst dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas eyes',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk hide',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Berserker pelt',quantityLow+RandRange(randLow));
		inv.AddAnItem('Coal',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Cotton',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Dark iron ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dark iron ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Diamond dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Draconide leather',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowned dead tongue',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowner brain',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Dwimeryte ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dwimeryte ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Emerald dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Endriag chitin plates',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Endriag embryo',quantityLow+RandRange(randLow));
		inv.AddAnItem('Ghoul blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hag teeth',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened leather',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened timber',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Harpy feathers',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Iron ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Leather straps',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Leather',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Linen',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Meteorite ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Meteorite ore',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Necrophage skin',quantityLow+RandRange(randLow));
		inv.AddAnItem('Nekker blood',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Nekker heart',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Oil',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Phosphorescent crystal',quantityLow+RandRange(randLow));
		inv.AddAnItem('Pure silver',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rotfiend blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Sapphire dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Silk',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Silver ingot',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Silver ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Specter dust',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Steel ingot',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('String',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Thread',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Timber',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Twine',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Venom extract',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Water essence',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Wolf liver',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Alcohest', 3);
		inv.AddAnItem('Dwarven spirit', 4);
	
		
		ids.Clear();
		ids = inv.AddAnItem('Crossbow 5');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Blunt Bolt', 20);
		EquipItem(ids[0]);
		inv.AddAnItem('Broadhead Bolt', 20);
		inv.AddAnItem('Split Bolt', 20);
		
		
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		
		
		
		AddAlchemyRecipe('Recipe for Cat 1');
		
		
		
		AddAlchemyRecipe('Recipe for Maribor Forest 1');
		AddAlchemyRecipe('Recipe for Petris Philtre 1');
		AddAlchemyRecipe('Recipe for Swallow 1');
		AddAlchemyRecipe('Recipe for Tawny Owl 1');
		
		AddAlchemyRecipe('Recipe for White Gull 1');
		AddAlchemyRecipe('Recipe for White Honey 1');
		AddAlchemyRecipe('Recipe for White Raffards Decoction 1');
		
		
		
		AddAlchemyRecipe('Recipe for Beast Oil 1');
		AddAlchemyRecipe('Recipe for Cursed Oil 1');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
		AddAlchemyRecipe('Recipe for Hybrid Oil 1');
		AddAlchemyRecipe('Recipe for Insectoid Oil 1');
		AddAlchemyRecipe('Recipe for Magicals Oil 1');
		AddAlchemyRecipe('Recipe for Necrophage Oil 1');
		AddAlchemyRecipe('Recipe for Specter Oil 1');
		AddAlchemyRecipe('Recipe for Vampire Oil 1');
		AddAlchemyRecipe('Recipe for Draconide Oil 1');
		AddAlchemyRecipe('Recipe for Ogre Oil 1');
		AddAlchemyRecipe('Recipe for Relic Oil 1');
		AddAlchemyRecipe('Recipe for Beast Oil 2');
		AddAlchemyRecipe('Recipe for Cursed Oil 2');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
		AddAlchemyRecipe('Recipe for Hybrid Oil 2');
		AddAlchemyRecipe('Recipe for Insectoid Oil 2');
		AddAlchemyRecipe('Recipe for Magicals Oil 2');
		AddAlchemyRecipe('Recipe for Necrophage Oil 2');
		AddAlchemyRecipe('Recipe for Specter Oil 2');
		AddAlchemyRecipe('Recipe for Vampire Oil 2');
		AddAlchemyRecipe('Recipe for Draconide Oil 2');
		AddAlchemyRecipe('Recipe for Ogre Oil 2');
		AddAlchemyRecipe('Recipe for Relic Oil 2');
		
		
		AddAlchemyRecipe('Recipe for Dancing Star 1');
		
		AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
		
		AddAlchemyRecipe('Recipe for Grapeshot 1');
		AddAlchemyRecipe('Recipe for Samum 1');
		
		AddAlchemyRecipe('Recipe for White Frost 1');
		
		
		
		AddAlchemyRecipe('Recipe for Dwarven spirit 1');
		AddAlchemyRecipe('Recipe for Alcohest 1');
		AddAlchemyRecipe('Recipe for White Gull 1');
		
		
		AddStartingSchematics();
		
		
		ids.Clear();
		ids = inv.AddAnItem('Swallow 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Thunderbolt 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Tawny Owl 2');
		EquipItem(ids[0]);
		ids.Clear();
		
		ids = inv.AddAnItem('Grapeshot 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Samum 2');
		EquipItem(ids[0]);
		
		inv.AddAnItem('Dwimeritum Bomb 1');
		inv.AddAnItem('Dragons Dream 1');
		inv.AddAnItem('Silver Dust Bomb 1');
		inv.AddAnItem('White Frost 2');
		inv.AddAnItem('Devils Puffball 2');
		inv.AddAnItem('Dancing Star 2');
		inv.AddAnItem('Beast Oil 1');
		inv.AddAnItem('Cursed Oil 1');
		inv.AddAnItem('Hanged Man Venom 2');
		inv.AddAnItem('Hybrid Oil 1');
		inv.AddAnItem('Insectoid Oil 1');
		inv.AddAnItem('Magicals Oil 1');
		inv.AddAnItem('Necrophage Oil 2');
		inv.AddAnItem('Specter Oil 1');
		inv.AddAnItem('Vampire Oil 1');
		inv.AddAnItem('Draconide Oil 1');
		inv.AddAnItem('Relic Oil 1');
		inv.AddAnItem('Black Blood 1');
		inv.AddAnItem('Blizzard 1');
		inv.AddAnItem('Cat 2');
		inv.AddAnItem('Full Moon 1');
		inv.AddAnItem('Maribor Forest 1');
		inv.AddAnItem('Petris Philtre 1');
		inv.AddAnItem('White Gull 1', 2);
		inv.AddAnItem('White Honey 2');
		inv.AddAnItem('White Raffards Decoction 1');
		
		
		inv.AddAnItem('Mutagen 17');	
		inv.AddAnItem('Mutagen 19');	
		inv.AddAnItem('Mutagen 27');	
		inv.AddAnItem('Mutagen 26');	
		
		
		inv.AddAnItem('weapon_repair_kit_1', 3);
		inv.AddAnItem('weapon_repair_kit_2', 2);
		inv.AddAnItem('armor_repair_kit_1', 3);
		inv.AddAnItem('armor_repair_kit_2', 2);
		
		
		quantityMedium = 1;
		quantityLow = 1;
		inv.AddAnItem('Rune stribog lesser', quantityMedium);
		inv.AddAnItem('Rune stribog', quantityLow);
		inv.AddAnItem('Rune dazhbog lesser', quantityMedium);
		inv.AddAnItem('Rune dazhbog', quantityLow);
		inv.AddAnItem('Rune devana lesser', quantityMedium);
		inv.AddAnItem('Rune devana', quantityLow);
		inv.AddAnItem('Rune zoria lesser', quantityMedium);
		inv.AddAnItem('Rune zoria', quantityLow);
		inv.AddAnItem('Rune morana lesser', quantityMedium);
		inv.AddAnItem('Rune morana', quantityLow);
		inv.AddAnItem('Rune triglav lesser', quantityMedium);
		inv.AddAnItem('Rune triglav', quantityLow);
		inv.AddAnItem('Rune svarog lesser', quantityMedium);
		inv.AddAnItem('Rune svarog', quantityLow);
		inv.AddAnItem('Rune veles lesser', quantityMedium);
		inv.AddAnItem('Rune veles', quantityLow);
		inv.AddAnItem('Rune perun lesser', quantityMedium);
		inv.AddAnItem('Rune perun', quantityLow);
		inv.AddAnItem('Rune elemental lesser', quantityMedium);
		inv.AddAnItem('Rune elemental', quantityLow);
		
		inv.AddAnItem('Glyph aard lesser', quantityMedium);
		inv.AddAnItem('Glyph aard', quantityLow);
		inv.AddAnItem('Glyph axii lesser', quantityMedium);
		inv.AddAnItem('Glyph axii', quantityLow);
		inv.AddAnItem('Glyph igni lesser', quantityMedium);
		inv.AddAnItem('Glyph igni', quantityLow);
		inv.AddAnItem('Glyph quen lesser', quantityMedium);
		inv.AddAnItem('Glyph quen', quantityLow);
		inv.AddAnItem('Glyph yrden lesser', quantityMedium);
		inv.AddAnItem('Glyph yrden', quantityLow);
		
		
		StandaloneEp1_2();
	}
	
	public final function StandaloneEp1_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		
		inv.AddAnItem( 'Cows milk', 5 );
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 5 );
		EquipItem(ids[0]);
		
		
		inv.AddAnItem('Clearing Potion', 2, true, false, false);
		
		
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Bag 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Blinder 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Saddle 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		manager = theGame.GetJournalManager();

		
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			
			if( StrStartsWith(ents[i].baseName, "q60"))
				continue;
				
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		manager.ActivateEntryByScriptTag('TutorialAard', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAdrenaline', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxii', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxiiDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriBlink', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriCharge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCounter', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialDialogClose', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFallingRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocus', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseRoad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed1', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed2', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialIgni', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalAlternateSings', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatDamage', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatMount', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBuffs', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevLeveling', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevSkills', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrafting', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrossbow', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogGwint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogShop', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDive', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDurability', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFastTravel', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFocusRedObjects', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalGasClouds', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHeavyAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorse', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorseStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalJump', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMonsterThreatLevels', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenIngredient', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenPotion', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalOils', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPetards', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalQuestArea', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRadial', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRifts', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRun', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalShopDescription', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSpecialAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalStaminaExploration', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJumpHang', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadder', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialObjectiveSwitching', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialOxygen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialParry', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialPOIUncovered', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialQuen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSpeedPairing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSprint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStaminaSigns', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStealing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSwimmingSpeed', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialTimedChoiceDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialYrden', JS_Active);
		
		
		FactsAdd('kill_base_tutorials');
		
		
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		if( FactsQuerySum("standalone_ep1") < 1 ) //modSigns
			FactsAdd("standalone_ep1");
		FactsRemove("StandAloneEP1");
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
	
	final function Debug_FocusBoyFocusGain()
	{
		var focusGain : float;
		
		focusGain = FactsQuerySum( "debug_fact_focus_boy" ) ;
		GainStat( BCS_Focus, focusGain );
	}
	
	public final function StandaloneEp2_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd( "StandAloneEP2", 1 );
		
		
		inv.RemoveAllItems();
		
		
		inv.AddAnItem( 'Illusion Medallion', 1, true, true, false );
		inv.AddAnItem( 'q103_safe_conduct', 1, true, true, false );
		
		
		theGame.GetGamerProfile().ClearAllAchievementsForEP2();
		
		
		levelManager.Hack_EP2StandaloneLevelShrink( 35 );
		
		
		levelManager.ResetCharacterDev();
		pam = ( W3PlayerAbilityManager )abilityManager;
		if( pam )
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints( levelManager.GetLevel() - 1 + 11 );	
		
		
		//modSigns
		inv.AddAnItem('Greater mutagen red', 1);
		inv.AddAnItem('Greater mutagen green', 1);
		inv.AddAnItem('Greater mutagen blue', 1);
		inv.AddAnItem('Mutagen red', 2);
		inv.AddAnItem('Mutagen green', 2);
		inv.AddAnItem('Mutagen blue', 2);
		inv.AddAnItem('Lesser mutagen red', 2);
		inv.AddAnItem('Lesser mutagen green', 2);
		inv.AddAnItem('Lesser mutagen blue', 2);
		
		
		startingMoney = 5000;
		if( GetMoney() > startingMoney )
		{
			RemoveMoney( GetMoney() - startingMoney );
		}
		else
		{
			AddMoney( 5000 - GetMoney() );
		}
		
		
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Armor' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Boots' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Gloves' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Pants' );
		EquipItem( ids[0] );
		
		
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Steel Sword' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Silver Sword' );
		EquipItem( ids[0] );
		
		
		inv.AddAnItem( 'Torch', 1, true, true, false );
		
		
		//modSigns
		quantityLow = 1;
		randLow = 2;
		quantityMedium = 2;
		randMedium = 2;
		quantityHigh = 3;
		randHigh = 2;
		
		inv.AddAnItem( 'Alghoul bone marrow',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Amethyst dust',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Arachas eyes',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Arachas venom',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Basilisk hide',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Basilisk venom',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Berserker pelt',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Coal',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Cotton',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Diamond dust',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Drowned dead tongue',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Drowner brain',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Endriag chitin plates',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Endriag embryo',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Ghoul blood',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hag teeth',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hardened leather',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hardened timber',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Harpy feathers',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Necrophage skin',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Nekker blood',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Nekker heart',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Phosphorescent crystal',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Rotfiend blood',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Sapphire dust',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Specter dust',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Water essence',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Wolf liver',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Alcohest', 3 );
		inv.AddAnItem( 'Dwarven spirit', 4 );
	
		
		ids.Clear();
		ids = inv.AddAnItem( 'Crossbow 5' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Blunt Bolt', 20 );
		EquipItem( ids[0] );
		inv.AddAnItem( 'Broadhead Bolt', 20 );
		inv.AddAnItem( 'Split Bolt', 20 );
		
		
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		
		
		
		
		
		
		
		
		AddAlchemyRecipe( 'Recipe for Petris Philtre 2' );
		AddAlchemyRecipe( 'Recipe for Swallow 1' );
		AddAlchemyRecipe( 'Recipe for Tawny Owl 1' );
		
		AddAlchemyRecipe( 'Recipe for White Gull 1' );
		
		
		
		
		
		AddAlchemyRecipe( 'Recipe for Beast Oil 1' );
		AddAlchemyRecipe( 'Recipe for Cursed Oil 1' );
		AddAlchemyRecipe( 'Recipe for Hanged Man Venom 1' );
		AddAlchemyRecipe( 'Recipe for Hybrid Oil 1' );
		AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Magicals Oil 1' );
		AddAlchemyRecipe( 'Recipe for Necrophage Oil 1' );
		AddAlchemyRecipe( 'Recipe for Specter Oil 1' );
		AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
		AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
		AddAlchemyRecipe( 'Recipe for Ogre Oil 1' );
		AddAlchemyRecipe( 'Recipe for Relic Oil 1' );
		AddAlchemyRecipe( 'Recipe for Beast Oil 2' );
		AddAlchemyRecipe( 'Recipe for Cursed Oil 2' );
		AddAlchemyRecipe( 'Recipe for Hanged Man Venom 2' );
		AddAlchemyRecipe( 'Recipe for Hybrid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Magicals Oil 2' );
		AddAlchemyRecipe( 'Recipe for Necrophage Oil 2' );
		AddAlchemyRecipe( 'Recipe for Specter Oil 2' );
		AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
		AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
		AddAlchemyRecipe( 'Recipe for Ogre Oil 2' );
		AddAlchemyRecipe( 'Recipe for Relic Oil 2' );
		
		
		AddAlchemyRecipe( 'Recipe for Dancing Star 1' );
		
		AddAlchemyRecipe( 'Recipe for Dwimeritum Bomb 1' );
		
		AddAlchemyRecipe( 'Recipe for Grapeshot 1' );
		AddAlchemyRecipe( 'Recipe for Samum 1' );
		
		AddAlchemyRecipe( 'Recipe for White Frost 1' );
		
		
		
		AddAlchemyRecipe( 'Recipe for Dwarven spirit 1' );
		AddAlchemyRecipe( 'Recipe for Alcohest 1' );
		AddAlchemyRecipe( 'Recipe for White Gull 1' );
		
		
		AddStartingSchematics();
		
		
		ids.Clear();
		ids = inv.AddAnItem( 'Swallow 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Thunderbolt 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Tawny Owl 2' );
		EquipItem( ids[0] );
		ids.Clear();
		
		ids = inv.AddAnItem( 'Grapeshot 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Samum 2' );
		EquipItem( ids[0] );
		
		inv.AddAnItem( 'Dwimeritum Bomb 1' );
		inv.AddAnItem( 'Dragons Dream 1' );
		inv.AddAnItem( 'Silver Dust Bomb 1' );
		inv.AddAnItem( 'White Frost 2' );
		inv.AddAnItem( 'Devils Puffball 2' );
		inv.AddAnItem( 'Dancing Star 2' );
		inv.AddAnItem( 'Beast Oil 1' );
		inv.AddAnItem( 'Cursed Oil 1' );
		inv.AddAnItem( 'Hanged Man Venom 2' );
		inv.AddAnItem( 'Hybrid Oil 2' );
		inv.AddAnItem( 'Insectoid Oil 2' );
		inv.AddAnItem( 'Magicals Oil 1' );
		inv.AddAnItem( 'Necrophage Oil 2' );
		inv.AddAnItem( 'Ogre Oil 1' );
		inv.AddAnItem( 'Specter Oil 1' );
		inv.AddAnItem( 'Vampire Oil 2' );
		inv.AddAnItem( 'Draconide Oil 2' );
		inv.AddAnItem( 'Relic Oil 1' );
		inv.AddAnItem( 'Black Blood 1' );
		inv.AddAnItem( 'Blizzard 1' );
		inv.AddAnItem( 'Cat 2' );
		inv.AddAnItem( 'Full Moon 1' );
		inv.AddAnItem( 'Golden Oriole 1' );
		inv.AddAnItem( 'Killer Whale 1' );
		inv.AddAnItem( 'Maribor Forest 1' );
		inv.AddAnItem( 'Petris Philtre 2' );
		inv.AddAnItem( 'White Gull 1', 2 );
		inv.AddAnItem( 'White Honey 2' );
		inv.AddAnItem( 'White Raffards Decoction 1' );
		
		
		inv.AddAnItem( 'Mutagen 17' );	
		inv.AddAnItem( 'Mutagen 19' );	
		inv.AddAnItem( 'Mutagen 27' );	
		inv.AddAnItem( 'Mutagen 26' );	
		
		
		inv.AddAnItem( 'weapon_repair_kit_1', 3 );
		inv.AddAnItem( 'weapon_repair_kit_2', 2 );
		inv.AddAnItem( 'armor_repair_kit_1', 3 );
		inv.AddAnItem( 'armor_repair_kit_2', 2 );
		
		
		quantityMedium = 1;
		quantityLow = 1;
		inv.AddAnItem( 'Rune stribog lesser', quantityMedium );
		inv.AddAnItem( 'Rune stribog', quantityLow );
		inv.AddAnItem( 'Rune dazhbog lesser', quantityMedium );
		inv.AddAnItem( 'Rune dazhbog', quantityLow );
		inv.AddAnItem( 'Rune devana lesser', quantityMedium );
		inv.AddAnItem( 'Rune devana', quantityLow );
		inv.AddAnItem( 'Rune zoria lesser', quantityMedium );
		inv.AddAnItem( 'Rune zoria', quantityLow );
		inv.AddAnItem( 'Rune morana lesser', quantityMedium );
		inv.AddAnItem( 'Rune morana', quantityLow );
		inv.AddAnItem( 'Rune triglav lesser', quantityMedium );
		inv.AddAnItem( 'Rune triglav', quantityLow );
		inv.AddAnItem( 'Rune svarog lesser', quantityMedium );
		inv.AddAnItem( 'Rune svarog', quantityLow );
		inv.AddAnItem( 'Rune veles lesser', quantityMedium );
		inv.AddAnItem( 'Rune veles', quantityLow );
		inv.AddAnItem( 'Rune perun lesser', quantityMedium );
		inv.AddAnItem( 'Rune perun', quantityLow );
		inv.AddAnItem( 'Rune elemental lesser', quantityMedium );
		inv.AddAnItem( 'Rune elemental', quantityLow );
		
		inv.AddAnItem( 'Glyph aard lesser', quantityMedium );
		inv.AddAnItem( 'Glyph aard', quantityLow );
		inv.AddAnItem( 'Glyph axii lesser', quantityMedium );
		inv.AddAnItem( 'Glyph axii', quantityLow );
		inv.AddAnItem( 'Glyph igni lesser', quantityMedium );
		inv.AddAnItem( 'Glyph igni', quantityLow );
		inv.AddAnItem( 'Glyph quen lesser', quantityMedium );
		inv.AddAnItem( 'Glyph quen', quantityLow );
		inv.AddAnItem( 'Glyph yrden lesser', quantityMedium );
		inv.AddAnItem( 'Glyph yrden', quantityLow );
		
		
		StandaloneEp2_2();
	}
	
	public final function StandaloneEp2_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		
		inv.AddAnItem( 'Cows milk', 5 );
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 5 );
		EquipItem( ids[0] );
		
		
		inv.AddAnItem( 'Clearing Potion', 2, true, false, false );
		
		
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Bag 2' );
		horseId = GetHorseManager( ).MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Blinder 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Saddle 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		manager = theGame.GetJournalManager();

		
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			
			if( StrStartsWith( ents[i].baseName, "q60" ) )
				continue;
				
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		manager.ActivateEntryByScriptTag( 'TutorialAard', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAdrenaline', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxii', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxiiDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriBlink', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriCharge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCounter', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialDialogClose', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFallingRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocus', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseRoad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed1', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed2', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialIgni', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalAlternateSings', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatDamage', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatMount', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBuffs', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevLeveling', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevSkills', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrafting', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrossbow', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogGwint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogShop', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDive', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDurability', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFastTravel', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFocusRedObjects', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalGasClouds', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHeavyAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorse', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorseStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalJump', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMonsterThreatLevels', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenIngredient', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenPotion', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalOils', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPetards', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalQuestArea', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRadial', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRifts', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRun', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalShopDescription', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSpecialAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalStaminaExploration', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJumpHang', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadder', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialObjectiveSwitching', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialOxygen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialParry', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialPOIUncovered', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialQuen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSpeedPairing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSprint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStaminaSigns', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStealing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSwimmingSpeed', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialTimedChoiceDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialYrden', JS_Active );
		
		//modSigns
		inv.AddAnItem( 'Geralt Shirt', 1 );
		inv.AddAnItem( 'Thread', 3 );
		inv.AddAnItem( 'String', 3 );
		inv.AddAnItem( 'Linen', 2 );
		inv.AddAnItem( 'Silk', 1 );
		inv.AddAnItem( 'Nigredo', 1 );
		inv.AddAnItem( 'Albedo', 1 );
		inv.AddAnItem( 'Rubedo', 1 );
		inv.AddAnItem( 'Rebis', 1 );
		inv.AddAnItem( 'Dog tallow', 3 );
		inv.AddAnItem( 'Lunar shards', 1 );
		inv.AddAnItem( 'Quicksilver solution', 1 );
		inv.AddAnItem( 'Aether', 1 );
		inv.AddAnItem( 'Optima mater', 1 );
		inv.AddAnItem( 'Fifth essence', 1 );
		inv.AddAnItem( 'Hardened timber', 2 );
		inv.AddAnItem( 'Fur square', 1 );
		inv.AddAnItem( 'Leather straps', 4 ); 
		inv.AddAnItem( 'Leather squares', 1 ); 
		inv.AddAnItem( 'Leather', 2 ); 
		inv.AddAnItem( 'Hardened leather', 2 ); 
		inv.AddAnItem( 'Chitin scale', 2 ); 
		inv.AddAnItem( 'Draconide leather', 1 ); 
		inv.AddAnItem( 'Infused draconide leather', 0 );
		inv.AddAnItem( 'Steel ingot', 2 );
		inv.AddAnItem( 'Dark iron ore', 2 );
		inv.AddAnItem( 'Dark iron ingot', 1 );
		inv.AddAnItem( 'Dark steel ingot', 1 );
		inv.AddAnItem( 'Silver ore', 2 );
		inv.AddAnItem( 'Silver ingot', 2 );
		inv.AddAnItem( 'Meteorite ore', 2 );
		inv.AddAnItem( 'Meteorite ingot', 1 );
		inv.AddAnItem( 'Meteorite silver ingot', 1 );
		inv.AddAnItem( 'Dwimeryte ingot', 2 );
		inv.AddAnItem( 'Emerald dust', 2 );
		inv.AddAnItem( 'Ruby dust', 2 );
		inv.AddAnItem( 'Ruby', 1 );
		inv.AddAnItem( 'Sapphire dust', 2 );
		inv.AddAnItem( 'Sapphire', 1 );
		inv.AddAnItem( 'Monstrous brain', 4 );
		inv.AddAnItem( 'Monstrous blood', 3 );
		inv.AddAnItem( 'Monstrous bone', 4 );
		inv.AddAnItem( 'Monstrous claw', 3 );
		inv.AddAnItem( 'Monstrous dust', 3 );
		inv.AddAnItem( 'Monstrous ear', 4 );
		inv.AddAnItem( 'Monstrous egg', 2 );
		inv.AddAnItem( 'Monstrous eye', 2 );
		inv.AddAnItem( 'Monstrous essence', 3 );
		inv.AddAnItem( 'Monstrous feather', 4 );
		inv.AddAnItem( 'Monstrous hair', 3 );
		inv.AddAnItem( 'Monstrous heart', 2 );
		inv.AddAnItem( 'Monstrous hide', 3 );
		inv.AddAnItem( 'Monstrous liver', 2 );
		inv.AddAnItem( 'Monstrous plate', 1 );
		inv.AddAnItem( 'Monstrous saliva', 4 );
		inv.AddAnItem( 'Monstrous stomach', 2 );
		inv.AddAnItem( 'Monstrous tongue', 2 );
		inv.AddAnItem( 'Monstrous tooth', 3 );
		inv.AddAnItem( 'Venom extract', 1 );
		inv.AddAnItem( 'Siren vocal cords', 1 );
		
		
		SelectQuickslotItem( EES_RangedWeapon );
		
		
		FactsAdd( 'kill_base_tutorials' );
		
		
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		
		if( FactsQuerySum("standalone_ep2") < 1 ) //modSigns
			FactsAdd("standalone_ep2");
		FactsRemove( "StandAloneEP2" );
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
}

exec function fuqfep1()
{
	theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
}





function GetWitcherPlayer() : W3PlayerWitcher
{
	return (W3PlayerWitcher)thePlayer;
}
