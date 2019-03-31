/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


//modSigns: reworked
class W3Mutagen02_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen02;
	
	var focusValPrc : float;
	
	public function AddFocus(dmgVal : float)
	{
		var focusVal : float;
		
		if(dmgVal <= 0)
			return;
		
		//yup, being lazy again
		if(focusValPrc <= 0)
		{
			focusValPrc = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen02Effect', 'mutagen02_focus'));
		}
		
		focusVal = focusValPrc * dmgVal / thePlayer.GetMaxHealth() * 100;
		
		//theGame.witcherLog.AddMessage("Mutagen02: focusValPrc = " + focusValPrc);
		//theGame.witcherLog.AddMessage("Mutagen02: focusVal = " + focusVal);
		
		thePlayer.GainStat(BCS_Focus, focusVal);
	}
}