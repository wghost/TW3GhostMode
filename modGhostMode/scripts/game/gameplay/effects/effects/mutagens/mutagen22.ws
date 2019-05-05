/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen22_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen22;
	default dontAddAbilityOnTarget = true;
	
	//modSigns
	public function AddMutagen22Ability()
	{
		var abilityCount, maxStack : int;
		var min, max : SAbilityAttributeValue;
		
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
			if(abilityCount < maxStack)
				thePlayer.AddAbility(abilityName, true);
		}
	}
	
	public function RemoveMutagen22Abilities()
	{
		target.RemoveAbilityAll(abilityName);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}