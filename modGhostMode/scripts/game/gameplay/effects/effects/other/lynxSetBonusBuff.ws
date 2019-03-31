/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_LynxSetBonus extends CBaseGameplayEffect
{
	default effectType = EET_LynxSetBonus;
	default isPositive = true;
	
	//modSigns: reworked
	
	var bonus, curBonus, maxBonus : float;
	var cachedIsHeavy : bool;
	
	public function GetLynxBonus(isHeavy : bool) : float
	{
		if(cachedIsHeavy != isHeavy && curBonus > 0)
			return curBonus;
		return 0.0f;
	}
	
	public function ManageLynxBonus(isHeavy : bool, dealtDamage : bool)
	{
		if(cachedIsHeavy != isHeavy && curBonus > 0)
			Discharge();
		else
			Accumulate(isHeavy, dealtDamage);
	}
	
	private function Discharge()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.PlayEffectSingle( 'fast_attack_buff_hit' );
			swEnt.StopEffectIfActive( 'fast_attack_buff' );
		}
		
		cachedIsHeavy = false;
		curBonus = 0;
		
		//theGame.witcherLog.AddMessage("Lynx set tier 1: Discharge"); //debug
	}
	
	private function Accumulate(isHeavy : bool, dealtDamage : bool)
	{
		var inv			: CInventoryComponent;
		var swEnt		: CItemEntity;
		
		if( dealtDamage )
		{
			inv = target.GetInventory();
			
			if( inv.GetCurrentlyHeldSwordEntity( swEnt ) && !swEnt.IsEffectActive( 'fast_attack_buff' ) )
			{
				swEnt.PlayEffect( 'fast_attack_buff' );
			}
			
			if( curBonus < maxBonus )
			{
				curBonus += bonus * ((W3PlayerWitcher)target).GetSetPartsEquipped( EIST_Lynx );
				curBonus = MinF(curBonus, maxBonus);
			}
			
			//theGame.witcherLog.AddMessage("Lynx set tier 1: Accumulate, curBonus = " + curBonus); //debug
		}
		else
		{
			//theGame.witcherLog.AddMessage("Lynx set tier 1: Skip"); //debug
		}
		cachedIsHeavy = isHeavy;
	}
	
	public final function GetStacks() : int
	{
		return RoundMath( curBonus * 100 );
	}
	
	public final function GetMaxStacks() : int
	{
		return RoundMath( maxBonus * 100 );
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		//var inv			: CInventoryComponent;
		//var swEnt		: CItemEntity;
		//
		//inv = target.GetInventory();
		//
		//if( inv.GetCurrentlyHeldSwordEntity( swEnt ) ) 
		//{
		//	swEnt.PlayEffect( 'fast_attack_buff' );
		//}
		var dm			: CDefinitionsManagerAccessor;
		var min, max 	: SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_ap_boost', min, max );
		bonus = min.valueAdditive;
		dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_boost_max', min, max );
		maxBonus = min.valueAdditive;
		
		//theGame.witcherLog.AddMessage("Lynx set tier 1: bonus = " + bonus); //debug
		//theGame.witcherLog.AddMessage("Lynx set tier 1: maxBonus = " + maxBonus); //debug
		
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectRemoved()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			//swEnt.PlayEffectSingle( 'fast_attack_buff_hit' );			
			swEnt.StopEffectIfActive( 'fast_attack_buff' );
		}
		
		super.OnEffectRemoved();
	}
	
	protected function OnPaused()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.StopEffectIfActive( 'fast_attack_buff' );
		}
		
		super.OnPaused();
	}
	
	protected function OnResumed()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) && curBonus > 0 )
		{
			swEnt.PlayEffect( 'fast_attack_buff' );
		}
	
		super.OnResumed();
	}
	
};