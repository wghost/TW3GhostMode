/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen25_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen25;
	//default dontAddAbilityOnTarget = true;
	
	//modSigns
	
	private saved var m25Bonus : float;
	
	public function GetM25Bonus() : float
	{
		return m25Bonus;
	}
	
	public function RecalcM25Bonus()
	{
		var mutagenSlots : array<SMutagenSlot>;
		var i : int;
		var item : SItemUniqueId;
		var mutagensCount : array<int>;
		var inv : CInventoryComponent;
		var abilities : array<name>;
		var abl : SAbilityAttributeValue;
		
		mutagenSlots = GetWitcherPlayer().GetPlayerSkillMutagens();
		inv = GetWitcherPlayer().GetInventory();
		
		mutagensCount.Resize(3);
		m25Bonus = 0;
		
		for(i = 0; i < mutagenSlots.Size(); i += 1)
		{
			item = mutagenSlots[i].item;
			if(item != GetInvalidUniqueId())
			{
				abilities.Clear();
				inv.GetItemAbilities(item, abilities);
				//theGame.witcherLog.AddMessage("Mutagen25: item = " + inv.GetItemName(item));
				if(abilities.Contains('greater_mutagen_color_red'))
					mutagensCount[2] += 1;
				else if(abilities.Contains('mutagen_color_red'))
					mutagensCount[1] += 1;
				else if(abilities.Contains('lesser_mutagen_color_red'))
					mutagensCount[0] += 1;
			}
		}
		
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_lesser');
		//theGame.witcherLog.AddMessage("Mutagen25: bonus_lesser = " + abl.valueAdditive);
		m25Bonus += abl.valueAdditive * mutagensCount[0];
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_medium');
		//theGame.witcherLog.AddMessage("Mutagen25: bonus_medium = " + abl.valueAdditive);
		m25Bonus += abl.valueAdditive * mutagensCount[1];
		abl = thePlayer.GetAbilityAttributeValue(abilityName, 'mutagen25_bonus_greater');
		//theGame.witcherLog.AddMessage("Mutagen25: bonus_greater = " + abl.valueAdditive);
		m25Bonus += abl.valueAdditive * mutagensCount[2];
		
		m25Bonus = ClampF(m25Bonus, 0, 1);
		//theGame.witcherLog.AddMessage("Mutagen25: m25Bonus = " + m25Bonus);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		RecalcM25Bonus();
	}
	
	/*private var attackPowerBonus : SAbilityAttributeValue;
	
	public function GetAttackPowerBonus() : SAbilityAttributeValue
	{
		return attackPowerBonus;
	}
	
	public function CacheSettings()
	{
		var min, max : SAbilityAttributeValue;
		
		super.CacheSettings();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, PowerStatEnumToName(CPS_AttackPower), min, max);
		attackPowerBonus = GetAttributeRandomizedValue(min, max);
	}*/
}