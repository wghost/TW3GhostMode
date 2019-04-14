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
	return (optionName == 'GMSinkBoat' || optionName == 'GMSinkBoatOverEnc' || optionName == 'GMEncumbranceMultiplier'
			|| optionName == 'GMSignStaminaCostMultiplier' || optionName == 'GMMeleeStaminaCostMultiplier'
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

function gmLoadDefaultSettings()
{
	if(!theGame.GetInGameConfigWrapper().GetVarValue('GMGameplayOptions', 'GMVersion'))
	{
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMSinkBoat', true);
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMSinkBoatOverEnc', FloatToString(20.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMEncumbranceMultiplier', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMArmorRegenPenalty', false);
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMCombatStaminaRegen', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMOutOfCombatStaminaRegen', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMCombatVitalityRegen', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMOutOfCombatVitalityRegen', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMMeleeStaminaCostMultiplier', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMSignStaminaCostMultiplier', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMStaminaDelay', FloatToString(0.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMMeleeSpecialCooldown', FloatToString(10.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMSignCooldown', FloatToString(5.0f));
		theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMAltSignCooldown', FloatToString(10.0f));
	}
	gmSetGMVersion();
}

function gmSetGMVersion()
{
	theGame.GetInGameConfigWrapper().SetVarValue('GMGameplayOptions', 'GMVersion', "4.0");
}
