//modSigns
function gmModRegenValue(attributeName : name, out effectValue : SAbilityAttributeValue)
{
	if(attributeName == 'staminaOutOfCombatRegen')
		effectValue.valueAdditive += theGame.params.GetOutOfCombatStaminaRegen();
	else if(attributeName == 'staminaRegenGuarded' || attributeName == 'staminaRegen')
		effectValue.valueAdditive += theGame.params.GetCombatStaminaRegen();
	else if(attributeName == 'vitalityRegen')
		effectValue.valueAdditive += theGame.params.GetOutOfCombatVitalityRegen();
	else if(attributeName == 'vitalityCombatRegen')
		effectValue.valueAdditive += theGame.params.GetCombatVitalityRegen();
}

function gmModMeleeStaminaCost(out cost : float)
{
	cost *= 1 + theGame.params.GetMeleeStaminaCostMult();
	cost = ClampF(cost, 0, 100);
}

function gmModSignStaminaCost(out cost : float)
{
	cost *= 1 + theGame.params.GetSignStaminaCostMult();
	cost = ClampF(cost, 0, 100);
}

function gmModStaminaDelay(out delay : float)
{
	delay += theGame.params.GetStaminaDelay();
	delay = MaxF(delay, 0);
}

function gmUpdateRegenEffects()
{
	var buffs : array<CBaseGameplayEffect>;
	var i : int;
	
	buffs = thePlayer.GetBuffs(EET_AutoVitalityRegen);
	
	for(i = 0; i < buffs.Size(); i += 1)
	{
		((W3Effect_AutoVitalityRegen)buffs[i]).UpdateEffectValue();
	}
	
	buffs = thePlayer.GetBuffs(EET_AutoStaminaRegen);
	
	for(i = 0; i < buffs.Size(); i += 1)
	{
		((W3Effect_AutoStaminaRegen)buffs[i]).UpdateEffectValue();
	}
}

function gmIsQoLOption(optionName : name) : bool
{
	return (optionName == 'GMSignInstantCast' || optionName == 'GMLowStaminaSFX'
			|| optionName == 'GMLowStaminaSFXVolume' || optionName == 'GMLowStaminaSFXRate'
			|| optionName == 'GMLowStaminaSFXDynamicVolume' || optionName == 'GMLowStaminaSFXDynamicRate');
}

function gmIsGameplayOption(optionName : name) : bool
{
	return (optionName == 'GMSignStaminaCostMultiplier' || optionName == 'GMMeleeStaminaCostMultiplier'
			|| optionName == 'GMOutOfCombatVitalityRegen' || optionName == 'GMCombatVitalityRegen'
			|| optionName == 'GMOutOfCombatStaminaRegen' || optionName == 'GMCombatStaminaRegen'
			|| optionName == 'GMStaminaDelay' || optionName == 'GMMeleeSpecialCooldown'
			|| optionName == 'GMSignCooldown' || optionName == 'GMAltSignCooldown'
			|| optionName == 'GMArmorRegenPenalty');
}

function gmIsScalingOption(optionName : name) : bool
{
	return (optionName == 'Virtual_GMScaling' || optionName == 'GMRandomScalingMinLevel'
			|| optionName == 'GMRandomScalingMaxLevel' || optionName == 'GMNoAnimalUpscaling'
			|| optionName == 'GMNoAddLevelsGuards' || optionName == 'GMHealthMultiplier'
			|| optionName == 'GMDamageMultiplier');
}

function gmInstantCastingAllowed() : bool
{
	return theGame.params.GetInstantCasting();
}