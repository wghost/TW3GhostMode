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
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		
		//theGame.witcherLog.AddMessage("Mutagen22 ability = " + abilityName);
		
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			
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
				thePlayer.AddAbility(abilityName, true);
				//theGame.witcherLog.AddMessage("Mutagen22 ability added");
			}
		}
	}
}