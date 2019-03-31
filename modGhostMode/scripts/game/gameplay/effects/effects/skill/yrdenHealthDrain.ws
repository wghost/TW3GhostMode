/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0;
		
		//SetEffectValue();
		//debug log
		//theGame.witcherLog.AddMessage("Drain prc: " + effectValue.valueMultiplicative * 100);
	}
	
	
	//modSigns: effect value is calculated in yrden entity
	/*protected function SetEffectValue()
	{
		//effectValue = thePlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s11);
	}*/
	
	//modSigns
	public function ResetHealthDrainEffect(newVal : SAbilityAttributeValue)
	{
		effectValue = newVal;
		//SetEffectValue();
		timeLeft = initialDuration;
		//debug log
		//theGame.witcherLog.AddMessage("Drain prc: " + effectValue.valueMultiplicative * 100);
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	//0.9-1.1
			target.PlayEffect('yrden_shock');
		}
	}
}