/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_TawnyOwl extends W3RegenEffect
{
	default effectType = EET_TawnyOwl;
	
	//modSigns begin
	function AddStamina()
	{
		var stamina : float;
		var staminaAtt, min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'staminaRestore', min, max);
		staminaAtt = GetAttributeRandomizedValue(min, max);
		stamina = target.GetStatMax(BCS_Stamina) * staminaAtt.valueMultiplicative + staminaAtt.valueAdditive;
		target.GainStat(BCS_Stamina, stamina);
		
		//theGame.witcherLog.AddMessage("stamina += " + stamina); //debug
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		AddStamina();
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		AddStamina();
	}
	//modSigns end
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var currentHour, level : int;
		var toxicityThreshold : float;
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				
				level = GetBuffLevel();				
				currentHour = GameTimeHours(theGame.GetGameTime());
				if(level < 3 || (currentHour > GetHourForDayPart(EDP_Dawn) && currentHour < GetHourForDayPart(EDP_Dusk)) )
					timeLeft -= deltaTime;
					
				if( timeLeft <= 0 )
				{
					if ( thePlayer.CanUseSkill(S_Alchemy_s03) )
					{
						toxicityThreshold = thePlayer.ToxicityThresholdPrcToPts((1 - CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Alchemy_s03, 'toxicity_threshold', false, true) ) * thePlayer.GetSkillLevel(S_Alchemy_s03))); //modSigns
					}
					if(isPotionEffect && target == thePlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && thePlayer.GetStat(BCS_Toxicity) > toxicityThreshold) //modSigns
					{
						
					}
					else
					{
						isActive = false;		
					}
				}
			}
			OnUpdate(deltaTime);	
		}
	}
}