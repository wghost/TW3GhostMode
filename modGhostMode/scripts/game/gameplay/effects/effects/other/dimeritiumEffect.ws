/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_DimeritiumEffect extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_DimeritiumEffect;
	
	private var enemyType : EEnemyType;
	private var monsterCategory : EMonsterCategory;
	
	public function GetDamageReduction() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(monsterCategory == MC_Human)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'dbomb_dmg_reduction', min, max);
			return min.valueAdditive;
		}
		return 0;
	}
	
	public function GetArmorPiercing() : float
	{
		var min, max : SAbilityAttributeValue;
		
		if(monsterCategory == MC_Magicals)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'dbomb_armor_piercing', min, max);
			return min.valueAdditive;
		}
		return 0;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var tmpName : name;
		var tmpBool : bool;
		
		super.OnEffectAdded(customParams);
		
		theGame.GetMonsterParamsForActor(target, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
		enemyType = GetEnemyTypeByAbility(target);
		if(enemyType == EENT_WILD_HUNT_MINION)
			target.PauseEffects(EET_AutoEssenceRegen, 'dimeritium_effect');
		BlockAbilities(true);
	}
	
	event OnEffectRemoved()
	{	
		if(enemyType == EENT_WILD_HUNT_MINION)
			target.ResumeEffects(EET_AutoEssenceRegen, 'dimeritium_effect');
		BlockAbilities(false);
		
		super.OnEffectRemoved();
	}
	
	private final function BlockAbilities(block : bool)
	{
		var ret : bool;
		
		//player signs
		if(target == thePlayer)
		{
			ret = thePlayer.BlockSkill(S_Magic_1, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_2, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_3, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_4, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_5, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_s01, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_s02, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_s03, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_s04, block) || ret;
			ret = thePlayer.BlockSkill(S_Magic_s05, block) || ret;
		}
		//NPC magic abilities
		else
		{
			//elemental dao + ifrit
			ret = target.BlockAbility('Wave', block) || ret;
			ret = target.BlockAbility('GroundSlam', block) || ret;
			ret = target.BlockAbility('SpawnArena', block) || ret;
			ret = target.BlockAbility('ThrowFire', block) || ret;
			//wh minions
			ret = target.BlockAbility('Frost', block) || ret;
			//witchers
			ret = target.BlockAbility('ablSignAttacks', block) || ret;
		}
		
		if(enemyType == EENT_WILD_HUNT_MINION)
			ret = true;
		
		if(monsterCategory == MC_Magicals)
			ret = true;
		
		//nothing was actually blocked
		if(block && !ret)
		{
			target.RemoveBuff(EET_DimeritiumEffect);
		}
		//some abilities were blocked
		else if(block && ret)
		{
			target.PlayEffect('transformation_block'); //need another effect
		}
		//unblock abilities
		else if(!block)
		{
			target.StopEffect('transformation_block'); //need another effect
		}
	}
}