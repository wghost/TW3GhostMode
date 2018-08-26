/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SQuenEffects
{
	editable var lastingEffectUpgNone	: name;
	editable var lastingEffectUpg1		: name;
	editable var lastingEffectUpg2		: name;
	editable var lastingEffectUpg3		: name;
	editable var castEffect				: name;
	editable var cameraShakeStranth		: float;
}



statemachine class W3QuenEntity extends W3SignEntity
{
	editable var effects : array< SQuenEffects >;
	editable var hitEntityTemplate : CEntityTemplate;
		
	
	protected var shieldDuration	: float;
	protected var shieldHealth		: float;
	protected var initialShieldHealth : float;
	protected var dischargePercent	: float;
	protected var ownerBoneIndex	: int;
	protected var blockedAllDamage  : bool;
	protected var shieldStartTime	: EngineTime;
	protected var impulseLevel		: int; //modSigns
	protected var quenPower			: SAbilityAttributeValue; //modSigns
	protected var healingFactor		: float; //modSigns
	private var hitEntityTimestamps : array<EngineTime>;
	private const var MIN_HIT_ENTITY_SPAWN_DELAY : float;
	private var hitDoTEntities : array<W3VisualFx>;
	public var showForceFinishedFX : bool;
	public var freeCast	: bool; //modSigns
	
	default skillEnum = S_Magic_4;
	default MIN_HIT_ENTITY_SPAWN_DELAY = 0.25f;
	
	public function GetSignType() : ESignType
	{
		return ST_Quen;
	}
	
	public function SetBlockedAllDamage(b : bool)
	{
		blockedAllDamage = b;
	}
	
	public function GetBlockedAllDamage() : bool
	{
		return blockedAllDamage;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		var oldQuen : W3QuenEntity;
		
		ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'pelvis' );
		if(ownerBoneIndex == -1)
			ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'k_pelvis_g' );
			
		oldQuen = (W3QuenEntity)prevInstance;
		if(oldQuen)
			oldQuen.OnSignAborted(true);
		
		hitEntityTimestamps.Clear();
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation );
	}
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		if(owner.GetActor() == thePlayer && !damageData.IsDoTDamage() && !damageData.WasDodged())
			theGame.VibrateControllerHard();	
	}
		
	protected function GetSignStats()
	{
		var skillBonus : float;
		var spellPower : SAbilityAttributeValue;
		var min, max : SAbilityAttributeValue;
		
		super.GetSignStats();
		
		//modSigns: cache impulse and discharge skills
		quenPower = owner.GetActor().GetTotalSignSpellPower(S_Magic_4);
		if( owner.CanUseSkill(S_Magic_s13) )
			impulseLevel = owner.GetSkillLevel(S_Magic_s13);
		else
			impulseLevel = 0;
		
		//modSigns: use base quen ability to get shield stats, because they're defined there
		shieldDuration = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
		//level 3 petri philtre gives +30% to shield duration
		if(owner.GetPlayer() && owner.GetPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
		{
			shieldDuration *= 1.34;
			//theGame.witcherLog.AddMessage("Quen shield; Duration: " + shieldDuration); //modSigns: debug
		}
		shieldHealth = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_health', false, true));
		
		if( owner.CanUseSkill(S_Magic_s14) )
		{			
			dischargePercent = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s14, 'discharge_percent', false, true)) * owner.GetSkillLevel(S_Magic_s14);
			if( owner.GetPlayer().IsSetBonusActive( EISB_Bear_2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_2 ), 'quen_dmg_boost', min, max );
				dischargePercent *= 1 + min.valueMultiplicative;
			}
		}
		else
		{
			dischargePercent = 0;
		}
		
		if( owner.CanUseSkill(S_Magic_s15) )
			skillBonus = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s15, 'shield_health_bonus', false, true)) * owner.GetSkillLevel(S_Magic_s15);
		else
			skillBonus = 0;
		
		shieldHealth += skillBonus;
		shieldHealth *= quenPower.valueMultiplicative;

		initialShieldHealth = shieldHealth;
		
		if( owner.CanUseSkill(S_Magic_s04) )
			healingFactor = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s04, 'shield_healing_factor', false, true)) * owner.GetSkillLevel(S_Magic_s04);
		else
			healingFactor = 0;
	}
	
	public final function AddBuffImmunities()
	{
		var actor : CActor;
		var i : int;
		var crits : array<CBaseGameplayEffect>;
		var effectType : EEffectType;
		
		actor = owner.GetActor();
		
		
		crits = actor.GetBuffs();	
		for(i=0; i<crits.Size(); i+=1)
		{
			effectType = crits[i].GetEffectType();
			
			
			if( effectType == EET_SnowstormQ403 || effectType == EET_Snowstorm )
			{
				actor.FinishQuen( false );
				return;
			}
			
			
			//modSigns: casting quen doesn't remove active DoT effects, but having quen on denies adding DoT (see effectManager)
			/*
			if( !IsDoTEffect( crits[i] ) )
			{
				continue;
			}
			
			
			if( actor == GetWitcherPlayer() && ( effectType == EET_Poison || effectType == EET_PoisonCritical ) && actor.HasBuff( EET_GoldenOriole ) && GetWitcherPlayer().GetPotionBuffLevel( EET_GoldenOriole ) >= 3 )
			{
				continue;
			}
			
			actor.RemoveEffect( crits[i], true );			
			*/
		}		
	}
	
	public final function RemoveBuffImmunities()
	{
		var actor : CActor;
		var i, size : int;
		var dots : array<EEffectType>;
		
		actor = owner.GetActor();
		
		dots.PushBack(EET_Bleeding);
		dots.PushBack(EET_Burning);
		dots.PushBack(EET_Poison);
		dots.PushBack(EET_PoisonCritical);
		dots.PushBack(EET_Swarm);
		
		
		size = (int)EET_EffectTypesSize;
		for(i=0; i<size; i+=1)
		{
			if(IsCriticalEffectType(i) && !dots.Contains(i))
				actor.RemoveBuffImmunity(i, 'Quen');
		}
	}
	
	event OnStarted() 
	{
		var isAlternate		: bool;
		var witcherOwner	: W3PlayerWitcher;
		
		owner.ChangeAspect( this, S_Magic_s04 );
		isAlternate = IsAlternateCast();
		witcherOwner = owner.GetPlayer();
		
		if(isAlternate)
		{
			
			CreateAttachment( owner.GetActor(), 'quen_sphere' );
			
			if((CPlayer)owner.GetActor())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
		else
		{
			super.OnStarted();
		}
		
		
		if(owner.GetActor() == thePlayer && ShouldProcessTutorial('TutorialSelectQuen'))
		{
			FactsAdd("tutorial_quen_cast");
		}
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
				
		if( isAlternate || !owner.IsPlayer() )
		{
			if( owner.IsPlayer() && GetWitcherPlayer().HasBuff( EET_Mutation11Immortal ) )
			{
				PlayEffect( 'quen_second_life' );
			}
			else
			{
				PlayEffect( effects[1].castEffect );
			}
			
			if( witcherOwner && dischargePercent > 0 /*modSigns*/ && witcherOwner.IsSetBonusActive( EISB_Bear_2 ) )
			{
				PlayEffect( 'default_fx_bear_abl2' );
				witcherOwner.PlayEffect( 'quen_lasting_shield_bear_abl2' );
			}
			
			CacheActionBuffsFromSkill();
			GotoState( 'QuenChanneled' );
		}
		else
		{
			PlayEffect( effects[0].castEffect );
			GotoState( 'QuenShield' );
		}
	}
	
	public final function IsAnyQuenActive() : bool
	{
		
		if(GetCurrentStateName() == 'QuenChanneled' || (GetCurrentStateName() == 'ShieldActive' && shieldHealth > 0) )
		{
			return true;
		}
				
		return false;
	}
	
	event OnSignAborted( optional force : bool ){}
	
	
	
	
	public final function PlayHitEffect(fxName : name, rot : EulerAngles, optional isDoT : bool)
	{
		var hitEntity : W3VisualFx;
		var currentTime : EngineTime;
		var dt : float;
		
		currentTime = theGame.GetEngineTime();
		if(hitEntityTimestamps.Size() > 0)
		{
			dt = EngineTimeToFloat(currentTime - hitEntityTimestamps[0]);
			if(dt < MIN_HIT_ENTITY_SPAWN_DELAY)
				return;
		}
		hitEntityTimestamps.Erase(0);
		hitEntityTimestamps.PushBack(currentTime);
		
		hitEntity = (W3VisualFx)theGame.CreateEntity(hitEntityTemplate, GetWorldPosition(), rot);
		if(hitEntity)
		{
			
			hitEntity.CreateAttachment(owner.GetActor(), 'quen_sphere', , rot);
			hitEntity.PlayEffect(fxName);
			hitEntity.DestroyOnFxEnd(fxName);
			
			if(isDoT)
				hitDoTEntities.PushBack(hitEntity);
		}
	}
	
	public function EraseFirstTimeStamp()
	{
		hitEntityTimestamps.Erase(0);
	}
	
	timer function RemoveDoTFX(dt : float, id : int)
	{
		RemoveHitDoTEntities();
	}
	
	public final function RemoveHitDoTEntities()
	{
		var i : int;
		
		for(i=hitDoTEntities.Size()-1; i>=0; i-=1)
		{
			if(hitDoTEntities[i])
				hitDoTEntities[i].Destroy();
		}
	}
	
	public final function GetShieldHealth() : float 		{return shieldHealth;}
	public final function GetInitialShieldHealth() : float 		{return initialShieldHealth;}
	
	public final function GetShieldRemainingDuration() : float
	{
		return shieldDuration - EngineTimeToFloat( theGame.GetEngineTime() - shieldStartTime );
	}
	
	public final function SetDataFromRestore(health : float, duration : float)
	{
		shieldHealth = health;
		shieldDuration = duration;
		if( shieldHealth > initialShieldHealth ) //modSigns
			initialShieldHealth = shieldHealth;
		shieldStartTime = theGame.GetEngineTime();
		AddTimer('Expire', shieldDuration, false, , , true, true);
	}
	
	timer function Expire( deltaTime : float , id : int)
	{		
		GotoState( 'Expired' );
	}
		
	public final function ForceFinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var min, max : SAbilityAttributeValue;
		var player : W3PlayerWitcher;
		
		player = owner.GetPlayer();
		
		//modSigns: full set redesign, Quen bonus removed
		//if( !forceNoBearSetBonus && player && player.IsSetBonusActive( EISB_Bear_1 ) )
		//{
		//	theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_1), 'quen_reapply_chance', min, max );
		//	
		//	min.valueMultiplicative *= player.GetSetPartsEquipped( EIST_Bear );
		//	
		//	
		//	min.valueMultiplicative /= PowF(2, player.m_quenReappliedCount - 1); //modSigns
		//	/*if( player.m_quenReappliedCount > 4 )
		//	{
		//		min.valueMultiplicative = 0;
		//	}*/ //modSigns	
		//	
		//	//modSigns debug
		//	if( FactsQuerySum( "modSigns_debug_bear" ) > 0 )
		//		theGame.witcherLog.AddMessage("Bear set Quen reapply prob = " + min.valueMultiplicative);
		//	
		//	if( min.valueMultiplicative >= RandF() )
		//	{
		//		player.PlayEffect( 'quen_lasting_shield_back' );
		//		player.AddTimer( 'BearSetBonusQuenReapply', 0.9, true );
		//		//modSigns debug
		//		if( FactsQuerySum( "modSigns_debug_bear" ) > 0 )
		//			theGame.witcherLog.AddMessage("Reapplied successfully!");
		//	}
		//	
		//	else
		//	{
		//		player.m_quenReappliedCount = 1;
		//	}
		//}
		////modSigns
		//else
		//{
		//	player.m_quenReappliedCount = 1;
		//}
			
		if(IsAlternateCast())
		{
			OnEnded();
			
			if(!skipVisuals)
				owner.GetActor().PlayEffect('hit_electric_quen');
		}
		else
		{
			showForceFinishedFX = !skipVisuals;
			GotoState('Expired');
		}
	}
}


state Expired in W3QuenEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.shieldHealth = 0;
		
		if(parent.showForceFinishedFX)
			parent.owner.GetActor().PlayEffect('quen_lasting_shield_hit');
			
		parent.DestroyAfter( 1.f );		
		
		if(parent.owner.GetActor() == thePlayer)
			theGame.VibrateControllerVeryHard();	
	}
}


state ShieldActive in W3QuenEntity extends Active
{
	//modSigns: function was rewritten to make fx depend on sign power
	private final function GetLastingFxName() : name
	{
		//var spellPower : SAbilityAttributeValue;
		var sp/*, level*/ : float;
		
		//spellPower = caster.GetActor().GetTotalSignSpellPower(virtual_parent.GetSkill());
		sp = parent.quenPower.valueMultiplicative - 1;
		if(sp < 0.5)
			return parent.effects[0].lastingEffectUpg1;
		else if(sp < 1.5)
			return parent.effects[0].lastingEffectUpg2;
		else
			return parent.effects[0].lastingEffectUpg3;

		return parent.effects[0].lastingEffectUpgNone;
	}
	
	event OnEnterState( prevStateName : name )
	{
		var witcher			: W3PlayerWitcher;
		var params 			: SCustomEffectParams;
		
		super.OnEnterState( prevStateName );
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		
		if(witcher)
		{
			witcher.SetUsedQuenInCombat();
			//witcher.m_quenReappliedCount = 1; //modSigns
			
			params.effectType = EET_BasicQuen;
			params.creator = witcher;
			params.sourceName = "sign cast";
			params.duration = parent.shieldDuration;
			
			witcher.AddEffectCustom( params );
		}
		
		caster.GetActor().PlayEffect(GetLastingFxName());
		
		if( witcher && witcher.IsSetBonusActive( EISB_Bear_2 ) && parent.dischargePercent > 0 /*modSigns*/ )
		{
			witcher.PlayEffect( 'quen_force_discharge_bear_abl2_armour' );
		}
		
		parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
		
		parent.AddBuffImmunities();
		
		/*if( witcher )
		{
			if( !parent.freeCast ) //modSigns
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
			}
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		
		parent.freeCast = false; //modSigns: reset free casting
		*/ //modSigns -> moved to another place
		
		
		if( /*!witcher.IsSetBonusActive( EISB_Bear_1 ) ||*/ ( !witcher.HasBuff( EET_HeavyKnockdown ) && !witcher.HasBuff( EET_Knockdown ) ) )
		{
			witcher.CriticalEffectAnimationInterrupted("basic quen cast");
		}
		
		
		witcher.AddTimer('HACK_QuenSaveStatus', 0, true);
		parent.shieldStartTime = theGame.GetEngineTime();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var witcher : W3PlayerWitcher;
		
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		//theGame.witcherLog.AddMessage("Quen shield; OnLeaveState"); //modSigns: debug
		if(witcher && parent == witcher.GetSignEntity(ST_Quen))
		{
			witcher.StopEffect(parent.effects[0].lastingEffectUpg1);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg2);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg3);
			witcher.StopEffect(parent.effects[0].lastingEffectUpgNone);
			witcher.StopEffect( 'quen_force_discharge_bear_abl2_armour' );
			witcher.RemoveBuff( EET_BasicQuen );
		}
	
		parent.RemoveBuffImmunities();
		
		parent.RemoveHitDoTEntities();
		
		if(parent.owner.GetActor() == thePlayer)
		{
			GetWitcherPlayer().OnBasicQuenFinishing();			
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	}
		
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var pos : Vector;
		var reducedDamage, drainedHealth, skillBonus, incomingDamage, directDamage : float;
		var spellPower : SAbilityAttributeValue;
		var physX : CEntity;
		var inAttackAction : W3Action_Attack;
		var action : W3DamageAction;
		var casterActor : CActor;
		var effectTypes : array < EEffectType >;
		var damageTypes : array<SRawDamage>;
		var i : int;
		var isBleeding : bool;
		
		//modSigns: DoT damage is not reduced
		if(damageData.IsDoTDamage())
			return true;

		//skip if dodged or reflected
		if( damageData.WasDodged() || damageData.GetHitReactionType() == EHRT_Reflect )
		{
			return true;
		}
		
		//skip if parried or countered
		inAttackAction = (W3Action_Attack)damageData;
		if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()) )
			return true;
		
		parent.OnTargetHit(damageData);
		
		//#Quen hack
		/*
		if(damageData.IsDoTDamage())
		{
			damageData.SetAllProcessedDamageAs(0);
			return true;
		}
		*/
			
		//all damage from DOTs is blocked
		/*
		if(damageData.IsDoTDamage())
		{	
			if(theGame.CanLog())
			{
				LogDMHits("QuenShieldActive.OnTargetHit: all DOT's damage is reduced to 0", damageData);
			}
			damageData.processedDmg.vitalityDamage = 0;
			parent.SetBlockedAllDamage(true);
			return true;
		}*/
			
		casterActor = caster.GetActor();
		reducedDamage = 0;		
				
		//calulcate reduced damage
		damageData.GetDTs(damageTypes);
		for(i=0; i<damageTypes.Size(); i+=1)
		{
			if(damageTypes[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDamage = damageTypes[i].dmgVal;
				break;
			}
		}
		
		//special handling for bleeding
		if( (W3Effect_Bleeding)damageData.causer )
		{
			incomingDamage = directDamage;
			isBleeding = true;
		}
		else
		{	
			isBleeding = false;
			incomingDamage = MaxF(0, damageData.processedDmg.vitalityDamage - directDamage);
		}
		
		if(incomingDamage < parent.shieldHealth) //modSigns: now this value holds scaled shield HP
			reducedDamage = incomingDamage;
		else
			reducedDamage = parent.shieldHealth; //modSigns: only shieldHealth amount of damage can be reduced
		
		//quen hit fx
		if(!damageData.IsDoTDamage())
		{
			casterActor.PlayEffect( 'quen_lasting_shield_hit' );	
			
			GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
		}
		
		//modify incoming damage action
		if ( theGame.CanLog() )
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), action );
		}
		
		damageData.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageData.SetCanPlayHitParticle( false );

		//combat log
		/*theGame.witcherLog.AddCombatMessage("Quen shield:", casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Health: " + FloatToString(parent.shieldHealth), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Dmg: " + FloatToString(incomingDamage), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Reduced Dmg: " + FloatToString(reducedDamage), casterActor, NULL);*/

		if(reducedDamage > 0)
		{
			//reduce shield health
			//modSigns: moved to shield HP caclulation code
			/*spellPower = casterActor.GetTotalSignSpellPower(virtual_parent.GetSkill());
			
			if ( caster.CanUseSkill( S_Magic_s15 ) )
				skillBonus = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s15, 'bonus', false, true ) );
			else
				skillBonus = 0;
				
			drainedHealth = reducedDamage / (skillBonus + spellPower.valueMultiplicative);
			parent.shieldHealth -= drainedHealth;*/
			
			parent.shieldHealth -= reducedDamage; //modSigns: reduce shield HP
				
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			
			//?
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
				
			//discharge effect's damage
			//modSigns: discharge should return % of reduced damage
			if (reducedDamage > 0 && !damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && parent.dischargePercent > 0 /*modSigns*/ && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) //~3.5^2
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				//modSigns: make it % of reduced damage and make it direct, spell power already affects the damage via reducedDamage amount
				//action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * incomingDamage );
				action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, parent.dischargePercent * reducedDamage );
				//combat log
				//theGame.witcherLog.AddCombatMessage("Quen discharge dmg: " + FloatToString(parent.dischargePercent * reducedDamage), thePlayer, NULL);
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				theGame.damageMgr.ProcessAction( action );		
				delete action;
				
				//fx
				casterActor.PlayEffect('quen_force_discharge');
			}			
		}
		
		//if quen blocked all damage (at this point damageData's damage is modified by quen, so DealsAnyDamage() checks if there is some damage AFTER quen processing
		//modSigns: reducedDamage >= incomingDamage
		if(reducedDamage >= incomingDamage && (!damageData.DealsAnyDamage() || (isBleeding && reducedDamage >= directDamage)) )
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		//break shield if all shield's health is used up
		if( parent.shieldHealth <= 0 )
		{
			if( parent.impulseLevel > 0 ) //modSigns
			{				
				casterActor.PlayEffect( 'lasting_shield_impulse' );
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse", parent.impulseLevel, parent.quenPower /*modSigns*/ );
			}
			//combat log
			//theGame.witcherLog.AddCombatMessage("SetEndsQuen", thePlayer, NULL);
			damageData.SetEndsQuen(true);
		}
	}
}


state QuenShield in W3QuenEntity extends NormalCast
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		caster.OnDelayOrientationChange();
		
		caster.GetActor().OnSignCastPerformed(ST_Quen, false);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			//modSigns: stamina management
			if( (W3PlayerWitcher)caster.GetActor() )
			{
				if( !parent.freeCast )
				{
					parent.ManagePlayerStamina();
					parent.ManageGryphonSetBonusBuff();
				}
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
			parent.freeCast = false;
			//cleanup after stamina management
			parent.CleanUp();	
			parent.GotoState( 'ShieldActive' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		parent.GotoState( 'Expired' );
	}
}

state QuenChanneled in W3QuenEntity extends Channeling
{
	private const var HEALING_FACTOR : float;		
	
		default HEALING_FACTOR = 1.0f;

	event OnEnterState( prevStateName : name )
	{
		var casterActor : CActor;
		var witcher : W3PlayerWitcher;
		
		super.OnEnterState( prevStateName );
	
		casterActor = caster.GetActor();
		witcher = (W3PlayerWitcher)casterActor;
		
		if(witcher)
			witcher.SetUsedQuenInCombat();
							
		caster.OnDelayOrientationChange();
		
		//parent.GetSignStats(); //modSigns: already happens on change aspect
		
		
		casterActor.GetMovingAgentComponent().SetVirtualRadius( 'QuenBubble' );
			
		parent.AddBuffImmunities();	
		
		
		witcher.CriticalEffectAnimationInterrupted("quen channeled");
		
		casterActor.OnSignCastPerformed(ST_Quen, true);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			ChannelQuen();
		}
	}
	
	private var HAXXOR_LeavingState : bool;
	event OnLeaveState( nextStateName : name )
	{
		HAXXOR_LeavingState = true;
		OnEnded(true);
		super.OnLeaveState(nextStateName);
	}
	
	
	
	event OnEnded(optional isEnd : bool)
	{
		var casterActor : CActor;
		
		if(!HAXXOR_LeavingState)
			super.OnEnded();
			
		casterActor = caster.GetActor();
		casterActor.GetMovingAgentComponent().ResetVirtualRadius();
		casterActor.StopEffect('quen_shield');		
		casterActor.StopEffect( 'quen_lasting_shield_bear_abl2' );
		
		parent.RemoveBuffImmunities();		
		
		parent.StopAllEffects();
		
		parent.RemoveHitDoTEntities();
		
		//modSigns: creates too many ways for exploiting alt cast
		//if(isEnd && caster.CanUseSkill(S_Magic_s13))
		//	caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
	}
	
	event OnSignAborted( optional force : bool )
	{
		OnEnded();
	}
	
	entry function ChannelQuen()
	{
		while( Update(theTimer.timeDelta) ) //modSigns
		{
			ProcessQuenCollisionForRiders();
			//SleepOneFrame();
			//modSigns
			Sleep(theTimer.timeDelta);
		}
	}
	
	private function ProcessQuenCollisionForRiders()
	{
		var mac	: CMovingPhysicalAgentComponent;
		var collisionData : SCollisionData;
		var collisionNum : int;
		var i : int;
		var npc	: CNewNPC;
		var riderActor : CActor;
		var collidedWithRider : bool;
		var horseComp : W3HorseComponent;
		var riderToPlayerHeading, riderHeading : float;
		var angleDist : float;
		
		mac	= (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
		if( !mac )
		{
			return;
		}
		
		collisionNum = mac.GetCollisionCharacterDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData = mac.GetCollisionCharacterData( i );
			npc	= (CNewNPC)collisionData.entity;
			if( npc )
			{
				if( npc.IsUsingHorse() )
				{
					collidedWithRider = true;
					horseComp = npc.GetUsedHorseComponent();
				}
				else
				{
					horseComp = npc.GetHorseComponent();
					if( horseComp.user )
						collidedWithRider = true;
				}
			}
			
			if( collidedWithRider )
			{
				riderActor = horseComp.user;
				
				if( IsRequiredAttitudeBetween( riderActor, thePlayer, true ) )
				{
					riderToPlayerHeading = VecHeading( thePlayer.GetWorldPosition() - riderActor.GetWorldPosition() );
					riderHeading = riderActor.GetHeading();
					angleDist = AngleDistance( riderToPlayerHeading, riderHeading );
					
					if( AbsF( angleDist ) < 45.0 )
					{
						horseComp.ReactToQuen();
					}
				}
			}
		}
	}
	
	public function ShowHitFX(damageData : W3DamageAction, rot : EulerAngles)
	{
		var movingAgent : CMovingPhysicalAgentComponent;
		var inWater, hasFireDamage, hasElectricDamage, hasPoisonDamage, isDoT, isBirds : bool;
		var witcher	: W3PlayerWitcher;
		
		isBirds = (CFlyingCrittersLairEntityScript)damageData.causer;
		witcher = parent.owner.GetPlayer();
		
		if (isBirds)
		{
			
			parent.PlayHitEffect('quen_rebound_sphere_constant', rot, true);
			parent.AddTimer('RemoveDoTFX', 0.3, false, , , , true);
		}
		else
		{			
			isDoT = damageData.IsDoTDamage();
		
			if(!isDoT)
			{
				hasFireDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_FIRE) > 0;
				hasPoisonDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_POISON) > 0;		
				hasElectricDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_SHOCK) > 0;
		
				if( witcher && parent.dischargePercent > 0 /*modSigns*/ && witcher.IsSetBonusActive( EISB_Bear_2 ) )
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_bear_abl2', rot );
				}
				else if (hasFireDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_fire', rot );
				}
				else if (hasPoisonDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_poison', rot );
				}
				else if (hasElectricDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_electricity', rot );
				}
				else
				{
					parent.PlayHitEffect( 'quen_rebound_sphere', rot );
				}
			}
		}
		
		
		movingAgent = (CMovingPhysicalAgentComponent)caster.GetActor().GetMovingAgentComponent();
		inWater = movingAgent.GetSubmergeDepth() < 0;
		if(!inWater)
		{
			parent.PlayHitEffect( 'quen_rebound_ground', rot );
		}
	}
		
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var reducedDamage, skillBonus, drainedStamina, reducibleDamage, directDamage, shieldFactor : float;		
		//var spellPower : SAbilityAttributeValue;
		var /*drainAllStamina,*/ isBleeding : bool;
		var casterActor : CActor;
		var attackerVictimEuler : EulerAngles;
		var action : W3DamageAction;		
		var shieldHP, staminaPrc, reducedDamagePrc, adrenalinePrc, drainedAdrenaline : float; //modSigns: new vars

		//modSigns: DoT damage is not reduced
		if(damageData.IsDoTDamage())
			return true;

		parent.OnTargetHit(damageData);
		
		casterActor = caster.GetActor();
		directDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_DIRECT);
		
		//show hit fx
		//get rotation towards where the hit came from
		if( !( (CBaseGameplayEffect) damageData.causer ) )
		{
			attackerVictimEuler = VecToRotation(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition());
			attackerVictimEuler.Pitch = 0;
			attackerVictimEuler.Roll = 0;
			
			ShowHitFX(damageData, attackerVictimEuler);
		}
	
		//reaction to strong hit
		if( damageData.processedDmg.vitalityDamage >= 20 )
			casterActor.RaiseForceEvent( 'StrongHitTest' );
		
		//spell power
		//spellPower = casterActor.GetTotalSignSpellPower(virtual_parent.GetSkill());
		
		/*if ( caster.CanUseSkill( S_Magic_s15 ) )
			skillBonus = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s15, 'bonus', false, true ) );
		else
			skillBonus = 0;*/ //modSigns: early design leftover code - Resilience ability - removing
		
		//direct damage cannot be reduced
		if( (W3Effect_Bleeding)damageData.causer )
		{
			isBleeding = true;
			reducibleDamage = directDamage;
		}
		else
		{
			isBleeding = false;
			reducibleDamage = MaxF(0, damageData.processedDmg.vitalityDamage - directDamage);
		}
		
		shieldFactor = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s04, 'shield_health_factor', false, true ) );
		//modSigns: casting with adrenaline
		if( (W3PlayerWitcher)casterActor && caster.CanUseSkill(S_Perk_09) && parent.usedFocus )
		{
			adrenalinePrc = casterActor.GetStat(BCS_Focus);
		}
		else
		{
			//modSigns: get stamina in prc and calculate shield HP
			staminaPrc = casterActor.GetStat(BCS_Stamina)/casterActor.GetStatMax(BCS_Stamina);
		}
		shieldHP = parent.shieldHealth * shieldFactor * (staminaPrc + adrenalinePrc);
		//reduced damage is capped by stamina
		if(reducibleDamage > 0)
		{
			if( casterActor.HasBuff( EET_Mutation11Buff ) )
			{
				shieldHP = 1000000;
				reducedDamage = reducibleDamage;
			}
			else
			{
				//shieldHP = casterActor.GetStat( BCS_Stamina ) * shieldFactor * (skillBonus + spellPower.valueMultiplicative);
				//reducedDamage = MinF( reducibleDamage, casterActor.GetStat( BCS_Stamina ) * shieldFactor * (skillBonus + spellPower.valueMultiplicative) );
				//modSigns: can't absorb more damage than shield HP
				reducedDamage = MinF(reducibleDamage, shieldHP);
			}
			
			/*if(reducedDamage < reducibleDamage)
			{
				drainAllStamina = true;
			}*/
		}
		else
		{
			reducedDamage = 0;
		}

		
		//combat log
		/*theGame.witcherLog.AddCombatMessage("Quen active shield:", casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Stamina %: " + FloatToString(staminaPrc * 100), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Base health: " + FloatToString(parent.shieldHealth), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Health: " + FloatToString(shieldHP), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Dmg: " + FloatToString(reducibleDamage), casterActor, NULL);
		theGame.witcherLog.AddCombatMessage("Reduced Dmg: " + FloatToString(reducedDamage), casterActor, NULL);*/

		//reduce damage
		if ( reducedDamage > 0 || (!damageData.DealsAnyDamage() || (isBleeding && reducedDamage >= reducibleDamage)) )
		{
			if ( theGame.CanLog() )
			{		
				LogDMHits("Quen QuenChanneled.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), damageData );
			}
			
			if(!damageData.IsDoTDamage())
				GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
			
			damageData.SetHitAnimationPlayType( EAHA_ForceNo );			
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			damageData.SetCanPlayHitParticle(false);
						
			
			if( casterActor == thePlayer && parent.dischargePercent > 0 && !damageData.IsActionRanged() && IsRequiredAttitudeBetween( thePlayer, damageData.attacker, true) && parent.dischargePercent > 0 /*modSigns*/ && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				//action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reducibleDamage );
				action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, parent.dischargePercent * reducedDamage ); //modSigns
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				theGame.damageMgr.ProcessAction( action );		
				delete action;
				
				
				parent.PlayHitEffect('discharge', attackerVictimEuler);				
			}
		}		
		parent.SetBlockedAllDamage( !damageData.DealsAnyDamage() );
		
		//heal
		caster.GetActor().Heal(reducedDamage * parent.healingFactor);
		//debug log
		//theGame.witcherLog.AddMessage("Healing factor: " + parent.healingFactor);
		//theGame.witcherLog.AddMessage("HP healed: " + reducedDamage * parent.healingFactor);
		
		if(!casterActor.HasBuff( EET_Mutation11Buff ))
		{
			reducedDamagePrc = reducedDamage / (parent.shieldHealth * shieldFactor);
			//modSigns: casting with adrenaline
			if( (W3PlayerWitcher)casterActor && caster.CanUseSkill(S_Perk_09) && parent.usedFocus )
			{
				drainedAdrenaline = MinF(reducedDamagePrc, casterActor.GetStat(BCS_Focus));
				if( drainedAdrenaline > 0 )
				{
					((W3PlayerWitcher)casterActor).DrainFocus( drainedAdrenaline );
					//reducedDamagePrc = MaxF(0, reducedDamagePrc - drainedAdrenaline);
				}
			}
			else if( reducedDamagePrc > 0 )
			{
				//modSigns: drain stamina
				drainedStamina = reducedDamagePrc * casterActor.GetStatMax(BCS_Stamina);
				casterActor.DrainStamina( ESAT_FixedValue, drainedStamina, 3 );
			}
		
			//combat log
			//theGame.witcherLog.AddMessage("Drained adrenaline %: " + (drainedAdrenaline * 100));
			//theGame.witcherLog.AddMessage("Drained stamina %: " + (reducedDamagePrc * 100));

			//modSigns: break on zero adrenaline OR zero stamina
			if( parent.usedFocus && casterActor.GetStat(BCS_Focus) <= 0 || !parent.usedFocus && casterActor.GetStat( BCS_Stamina ) <= 0 )
			{
				if( parent.impulseLevel > 0 ) //modSigns
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
					caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse", parent.impulseLevel, parent.quenPower /*modSigns*/ );
				}
				
				damageData.SetEndsQuen(true);			
			}
		}
	}
}
