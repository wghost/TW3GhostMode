exec function addrecipesedibles()
{
	thePlayer.inv.AddAnItem('Recipe for Baked apple',1);
	thePlayer.inv.AddAnItem('Recipe for Baked potato',1);
	thePlayer.inv.AddAnItem('Recipe for Butter Bandalura',1);
	thePlayer.inv.AddAnItem('Recipe for Chicken leg',1);
	thePlayer.inv.AddAnItem('Recipe for Gutted fish',1);
	thePlayer.inv.AddAnItem('Recipe for Roasted chicken',1);
	thePlayer.inv.AddAnItem('Recipe for Roasted chicken leg',1);
	thePlayer.inv.AddAnItem('Recipe for Chicken sandwich',1);
	thePlayer.inv.AddAnItem('Recipe for Grilled chicken sandwich',1);
	thePlayer.inv.AddAnItem('Recipe for Fried fish',1);
	thePlayer.inv.AddAnItem('Recipe for Fried meat',1);
	thePlayer.inv.AddAnItem('Recipe for Fondue',1);
	thePlayer.inv.AddAnItem('Recipe for Grilled pork',1);
	thePlayer.inv.AddAnItem('Recipe for Ham sandwich',1);
	thePlayer.inv.AddAnItem('Recipe for Mutton curry',1);
	thePlayer.inv.AddAnItem('Recipe for Sausages',1);
	thePlayer.inv.AddAnItem('Recipe for Scrambled egg',1);
	thePlayer.inv.AddAnItem('Recipe for Apple juice',1);
	thePlayer.inv.AddAnItem('Recipe for Raspberry juice',1);
	thePlayer.inv.AddAnItem('Recipe for Chocolate souffle',1);
	thePlayer.inv.AddAnItem('Recipe for Crossaint honey',1);
	thePlayer.inv.AddAnItem('Recipe for Flamiche',1);
	thePlayer.inv.AddAnItem('Recipe for Onion soup',1);
	thePlayer.inv.AddAnItem('Recipe for Ratatouille',1);
	thePlayer.inv.AddAnItem('Recipe for Tarte tatin',1);
	thePlayer.inv.AddAnItem('Recipe for Baguette camembert',1);
	thePlayer.inv.AddAnItem('Recipe for Boeuf bourguignon',1);
	thePlayer.inv.AddAnItem('Recipe for Fish tarte',1);
}

exec function toggledebuglabels()
{
	if( FactsQuerySum( "modSigns_debug_labels" ) < 1 )
	{
		FactsAdd( "modSigns_debug_labels" );
	}
	else
	{
		FactsRemove( "modSigns_debug_labels" );
	}
}

exec function dumpallquests()
{
	var manager : CWitcherJournalManager;
	var allQuests : array<CJournalBase>;
	var aQuest : CJournalQuest;
	var i : int;

	theGame.GetJournalManager().GetActivatedOfType( 'CJournalQuest', allQuests );
	for( i = 0; i < allQuests.Size(); i += 1 )
	{
		LogChannel('modSigns', "Quest: " + ((CJournalQuest)allQuests[i]).GetUniqueScriptTag());
	}
}

exec function toggledebugkills()
{
	if( FactsQuerySum( "modSigns_debug_kills" ) < 1 )
	{
		FactsAdd( "modSigns_debug_kills" );
	}
	else
	{
		FactsRemove( "modSigns_debug_kills" );
	}
}

exec function toggledebugdmg()
{
	if( FactsQuerySum( "modSigns_debug_dmg" ) < 1 )
	{
		FactsAdd( "modSigns_debug_dmg" );
	}
	else
	{
		FactsRemove( "modSigns_debug_dmg" );
	}
}

exec function toggledebugabl()
{
	if( FactsQuerySum( "modSigns_debug_abl" ) < 1 )
	{
		FactsAdd( "modSigns_debug_abl" );
	}
	else
	{
		FactsRemove( "modSigns_debug_abl" );
	}
}

exec function toggledebugdot()
{
	if( FactsQuerySum( "modSigns_debug_dot" ) < 1 )
	{
		FactsAdd( "modSigns_debug_dot" );
	}
	else
	{
		FactsRemove( "modSigns_debug_dot" );
	}
}

exec function toggledebugreducedamage()
{
	if( FactsQuerySum( "modSigns_debug_reduce_damage" ) < 1 )
	{
		FactsAdd( "modSigns_debug_reduce_damage" );
	}
	else
	{
		FactsRemove( "modSigns_debug_reduce_damage" );
	}
}

exec function toggledebugpreattack()
{
	if( FactsQuerySum( "modSigns_debug_preattack" ) < 1 )
	{
		FactsAdd( "modSigns_debug_preattack" );
	}
	else
	{
		FactsRemove( "modSigns_debug_preattack" );
	}
}

exec function toggledebugoils()
{
	if( FactsQuerySum( "modSigns_debug_oils" ) < 1 )
	{
		FactsAdd( "modSigns_debug_oils" );
	}
	else
	{
		FactsRemove( "modSigns_debug_oils" );
	}
}

/*exec function toggledebugbear()
{
	if( FactsQuerySum( "modSigns_debug_bear" ) < 1 )
	{
		FactsAdd( "modSigns_debug_bear" );
	}
	else
	{
		FactsRemove( "modSigns_debug_bear" );
	}
}*/

exec function enabledeletedscene()
{
	if( FactsQuerySum( "q401_cooking_enabled" ) < 1 )
	{
		FactsAdd( "q401_cooking_enabled" );
	}
}

exec function whoareyou()
{
	var ents : array< CGameplayEntity >;
	var arrNames, arrUniqueNames : array< name >;
	var i : int;
	var actor : CActor;
	var template : CEntityTemplate;
	var interactionTarget : CInteractionComponent;
	var monsterCategory : EMonsterCategory;
	var tmpName : name;
	var tmpBool : bool;
	
	interactionTarget = theGame.GetInteractionsManager().GetActiveInteraction();
	
	if( interactionTarget )
	{
		theGame.witcherLog.AddMessage("Object template: " + interactionTarget.GetEntity().GetReadableName());
	}
	
	if( !interactionTarget )
	{
		actor = thePlayer.GetTarget();
	}
	
	if( !actor )
	{
		FindGameplayEntitiesCloseToPoint( ents,  thePlayer.GetWorldPosition(), 3, 1, , , , 'CNewNPC');
		if( ents.Size() > 0 )
		{
			actor = (CActor)ents[0];
		}
	}
	
	if( actor )
	{
		theGame.witcherLog.AddMessage("NPC template: " + actor.GetReadableName());
		theGame.GetMonsterParamsForActor(actor, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
		theGame.witcherLog.AddMessage("Monster category: " + monsterCategory);
		actor.GetCharacterStats().GetAbilities( arrNames, true );
		ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
		if(arrUniqueNames.Size() > 0)
		{
			for( i = 0; i < arrUniqueNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Ability:" + arrUniqueNames[i]);
		}
		arrNames.Clear();
		arrNames = actor.GetTags();
		if(arrNames.Size() > 0)
		{
			for( i = 0; i < arrNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Tag:" + arrNames[i]);
		}
		template = (CEntityTemplate)LoadResource( actor.GetReadableName(), true );
		if(template.includes.Size() > 0)
		{
			for( i = 0; i < template.includes.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Includes:" + template.includes[i].GetPath());
		}
	}
}

exec function whoami()
{
	var arrNames, arrUniqueNames : array< name >;
	var i : int;
	theGame.witcherLog.AddMessage("Player template: " + thePlayer.GetReadableName());
	thePlayer.GetCharacterStats().GetAbilities( arrNames, false );
	ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
	if(arrUniqueNames.Size() > 0)
	{
		for( i = 0; i < arrUniqueNames.Size(); i += 1 )
			theGame.witcherLog.AddMessage("Ability:" + arrUniqueNames[i]);
	}
}

exec function takeall( optional range : float )
{
	var containers: array<CGameplayEntity>;
	var i, containersSize : int;
	var container : W3Container;
	
	if( range <= 0.0f )
	{
		range = 20.0f;
	}
	
	FindGameplayEntitiesInSphere(containers, thePlayer.GetWorldPosition(), range, 1000000, , , , 'W3Container');
	
	containersSize = containers.Size();
	
	for( i = 0; i < containersSize; i += 1 )
	{
		container = (W3Container)containers[i];
		
		if( container )
		{
			GetWitcherPlayer().StartInvUpdateTransaction();
			container.TakeAllItems();
			GetWitcherPlayer().FinishInvUpdateTransaction();
			container.OnContainerClosed();
		}
	}
}

exec function destroybodies( optional range : float )
{	
	var enemies: array<CActor>;
	var i, enemiesSize : int;
	var npc : CNewNPC;
	
	if( range <= 0.0f )
	{
		range = 20.0f;
	}
	
	enemies = GetActorsInRange(thePlayer, range);
	
	enemiesSize = enemies.Size();
	
	for( i = 0; i < enemiesSize; i += 1 )
	{
		npc = (CNewNPC)enemies[i];
		
		if( npc )
		{
			if( !npc.IsAlive() )
			{
				npc.Destroy();
			}
		}
	}
}

exec function togglezeroenc()
{
	if( FactsQuerySum( "modSigns_debug_zero_enc" ) < 1 )
	{
		FactsAdd( "modSigns_debug_zero_enc" );
	}
	else
	{
		FactsRemove( "modSigns_debug_zero_enc" );
	}
	
	GetWitcherPlayer().UpdateEncumbrance();
}

exec function ValidateItem( itemName : name )
{
	var playerInv, horseInv : CInventoryComponent;
	var playerItemId, horseItemId : SItemUniqueId;
	
	playerInv = GetWitcherPlayer().GetInventory();
	horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	playerItemId = playerInv.GetItemId( itemName );
	horseItemId = horseInv.GetItemId( itemName );
	
	theGame.witcherLog.AddMessage("Validating item: " + itemName);
	
	if( playerItemId != GetInvalidUniqueId() )
		theGame.witcherLog.AddMessage("Player has item: " + itemName);
	if( horseItemId != GetInvalidUniqueId() )
		theGame.witcherLog.AddMessage("Stash has item: " + itemName);
	if( playerItemId == horseItemId && playerItemId != GetInvalidUniqueId() && horseItemId != GetInvalidUniqueId() )
		theGame.witcherLog.AddMessage("Id's are identical");
	if( horseInv.IsIdValid( playerItemId ) )
		theGame.witcherLog.AddMessage("Stash has item with the same id: " + horseInv.GetItemName( playerItemId ));
	if( playerInv.IsIdValid( horseItemId ) )
		theGame.witcherLog.AddMessage("Player has item with the same id: " + playerInv.GetItemName( horseItemId ));
}

exec function addalchemy1()
{
	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	arr = inv.AddAnItem('Black Blood 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Killer Whale 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = inv.AddAnItem('Beast Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = thePlayer.inv.AddAnItem('Samum 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Grapeshot 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
}

exec function addalchemy2()
{
	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	arr = inv.AddAnItem('Black Blood 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = inv.AddAnItem('Beast Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = thePlayer.inv.AddAnItem('Samum 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Grapeshot 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
}

exec function addalchemy3()
{
	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	arr = inv.AddAnItem('Black Blood 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = inv.AddAnItem('Beast Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = thePlayer.inv.AddAnItem('Samum 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Grapeshot 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
}

exec function adddecoctions()
{
	thePlayer.inv.AddAnItem('Mutagen 1',1);
	thePlayer.inv.AddAnItem('Mutagen 2',1);
	thePlayer.inv.AddAnItem('Mutagen 3',1);
	thePlayer.inv.AddAnItem('Mutagen 4',1);
	thePlayer.inv.AddAnItem('Mutagen 5',1);
	thePlayer.inv.AddAnItem('Mutagen 6',1);
	thePlayer.inv.AddAnItem('Mutagen 7',1);
	thePlayer.inv.AddAnItem('Mutagen 8',1);
	thePlayer.inv.AddAnItem('Mutagen 9',1);
	thePlayer.inv.AddAnItem('Mutagen 10',1);
	thePlayer.inv.AddAnItem('Mutagen 11',1);
	thePlayer.inv.AddAnItem('Mutagen 12',1);
	thePlayer.inv.AddAnItem('Mutagen 13',1);
	thePlayer.inv.AddAnItem('Mutagen 14',1);
	thePlayer.inv.AddAnItem('Mutagen 15',1);
	thePlayer.inv.AddAnItem('Mutagen 16',1);
	thePlayer.inv.AddAnItem('Mutagen 17',1);
	thePlayer.inv.AddAnItem('Mutagen 18',1);
	thePlayer.inv.AddAnItem('Mutagen 19',1);
	thePlayer.inv.AddAnItem('Mutagen 20',1);
	thePlayer.inv.AddAnItem('Mutagen 21',1);
	thePlayer.inv.AddAnItem('Mutagen 22',1);
	thePlayer.inv.AddAnItem('Mutagen 23',1);
	thePlayer.inv.AddAnItem('Mutagen 24',1);
	thePlayer.inv.AddAnItem('Mutagen 25',1);
	thePlayer.inv.AddAnItem('Mutagen 26',1);
	thePlayer.inv.AddAnItem('Mutagen 27',1);
	thePlayer.inv.AddAnItem('Mutagen 28',1);
}

exec function addlightarmor()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Light armor 01',1);
	thePlayer.inv.AddAnItem('Light armor 02',1);
	thePlayer.inv.AddAnItem('Light armor 03',1);
	thePlayer.inv.AddAnItem('Light armor 04',1);
	thePlayer.inv.AddAnItem('Light armor 06',1);
	thePlayer.inv.AddAnItem('Light armor 07',1);
	thePlayer.inv.AddAnItem('Light armor 08',1);
	thePlayer.inv.AddAnItem('Light armor 09',1);
	thePlayer.inv.AddAnItem('Shiadhal armor',1);
	thePlayer.inv.AddAnItem('Light armor 01r',1);
	thePlayer.inv.AddAnItem('Light armor 02r',1);
	thePlayer.inv.AddAnItem('Light armor 03r',1);
	thePlayer.inv.AddAnItem('Light armor 04r',1);
	thePlayer.inv.AddAnItem('Light armor 06r',1);
	thePlayer.inv.AddAnItem('Light armor 07r',1);
	thePlayer.inv.AddAnItem('Light armor 08r',1);
	thePlayer.inv.AddAnItem('Light armor 09r',1);
}

exec function addmediumarmor()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Medium armor 01',1);
	thePlayer.inv.AddAnItem('Medium armor 02',1);
	thePlayer.inv.AddAnItem('Medium armor 03',1);
	thePlayer.inv.AddAnItem('Medium armor 04',1);
	thePlayer.inv.AddAnItem('Medium armor 05',1);
	thePlayer.inv.AddAnItem('Medium armor 07',1);
	thePlayer.inv.AddAnItem('Medium armor 10',1);
	thePlayer.inv.AddAnItem('Medium armor 11',1);
	thePlayer.inv.AddAnItem('Thyssen armor',1);
	thePlayer.inv.AddAnItem('Oathbreaker armor',1);
	thePlayer.inv.AddAnItem('Medium armor 01r',1);
	thePlayer.inv.AddAnItem('Medium armor 02r',1);
	thePlayer.inv.AddAnItem('Medium armor 03r',1);
	thePlayer.inv.AddAnItem('Medium armor 04r',1);
	thePlayer.inv.AddAnItem('Medium armor 05r',1);
	thePlayer.inv.AddAnItem('Medium armor 07r',1);
	thePlayer.inv.AddAnItem('Medium armor 10r',1);
	thePlayer.inv.AddAnItem('Medium armor 11r',1);
}

exec function addheavyarmor()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Heavy armor 01',1);
	thePlayer.inv.AddAnItem('Heavy armor 02',1);
	thePlayer.inv.AddAnItem('Heavy armor 03',1);
	thePlayer.inv.AddAnItem('Heavy armor 04',1);
	thePlayer.inv.AddAnItem('Heavy armor 05',1);
	thePlayer.inv.AddAnItem('Relic Heavy 3 armor',1);
	thePlayer.inv.AddAnItem('Zireael armor',1);
	thePlayer.inv.AddAnItem('Shadaal armor',1);
	thePlayer.inv.AddAnItem('Heavy armor 01r',1);
	thePlayer.inv.AddAnItem('Heavy armor 02r',1);
	thePlayer.inv.AddAnItem('Heavy armor 03r',1);
	thePlayer.inv.AddAnItem('Heavy armor 04r',1);
	thePlayer.inv.AddAnItem('Heavy armor 05r',1);
}

exec function addallgloves()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Gloves 01',1);
	thePlayer.inv.AddAnItem('Gloves 01 q2',1);
	thePlayer.inv.AddAnItem('Gloves 03',1);
	thePlayer.inv.AddAnItem('Gloves 04',1);
	thePlayer.inv.AddAnItem('Gloves 02',1);
	thePlayer.inv.AddAnItem('Heavy gloves 02',1);
	thePlayer.inv.AddAnItem('Heavy gloves 01',1);
	thePlayer.inv.AddAnItem('Heavy gloves 03',1);
	thePlayer.inv.AddAnItem('Heavy gloves 04',1);
}

exec function addallboots()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Boots 01',1);
	thePlayer.inv.AddAnItem('Boots 01 q2',1);
	thePlayer.inv.AddAnItem('Boots 02',1);
	thePlayer.inv.AddAnItem('Boots 05',1);
	thePlayer.inv.AddAnItem('Boots 04',1);
	thePlayer.inv.AddAnItem('Boots 012',1);
	thePlayer.inv.AddAnItem('Boots 022',1);
	thePlayer.inv.AddAnItem('Boots 07',1);
	thePlayer.inv.AddAnItem('Boots 03',1);
	thePlayer.inv.AddAnItem('Boots 06',1);
	thePlayer.inv.AddAnItem('Heavy boots 03',1);
	thePlayer.inv.AddAnItem('Boots 032',1);
	thePlayer.inv.AddAnItem('Heavy boots 07',1);
	thePlayer.inv.AddAnItem('Heavy boots 01',1);
	thePlayer.inv.AddAnItem('Heavy boots 02',1);
	thePlayer.inv.AddAnItem('Heavy boots 04',1);
	thePlayer.inv.AddAnItem('Heavy boots 05',1);
	thePlayer.inv.AddAnItem('Heavy boots 06',1);
	thePlayer.inv.AddAnItem('Heavy boots 08',1);
}

exec function addallpants()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Pants 01',1);
	thePlayer.inv.AddAnItem('Pants 01 q2',1);
	thePlayer.inv.AddAnItem('Pants 02',1);
	thePlayer.inv.AddAnItem('Pants 04',1);
	thePlayer.inv.AddAnItem('Pants 03',1);
	thePlayer.inv.AddAnItem('Heavy pants 02',1);
	thePlayer.inv.AddAnItem('Heavy pants 01',1);
	thePlayer.inv.AddAnItem('Heavy pants 03',1);
	thePlayer.inv.AddAnItem('Heavy pants 04',1);
}

exec function addcraftedarmor()
{
	var guiMgr : CR4GuiManager = theGame.GetGuiManager();
	guiMgr.SetShowItemNames( true );
	thePlayer.inv.AddAnItem('Light armor 01_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 02_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 03_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 04_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 05_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 06_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 07_crafted',1);
	thePlayer.inv.AddAnItem('Light armor 08_crafted',1);
	thePlayer.inv.AddAnItem('Medium armor 01_crafted',1);
	thePlayer.inv.AddAnItem('Medium armor 02_crafted',1);
	thePlayer.inv.AddAnItem('Medium armor 03_crafted',1);
	thePlayer.inv.AddAnItem('Medium armor 04_crafted',1);
	thePlayer.inv.AddAnItem('Thyssen armor crafted',1);
	thePlayer.inv.AddAnItem('Heavy armor 01_crafted',1);
	thePlayer.inv.AddAnItem('Heavy armor 02_crafted',1);
	thePlayer.inv.AddAnItem('Heavy armor 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy armor 04_crafted',1);
	thePlayer.inv.AddAnItem('Relic Heavy 3 crafted',1);
	thePlayer.inv.AddAnItem('Gloves 01_crafted',1);
	thePlayer.inv.AddAnItem('Gloves 03_crafted',1);
	thePlayer.inv.AddAnItem('Gloves 04_crafted',1);
	thePlayer.inv.AddAnItem('Gloves 02_crafted',1);
	thePlayer.inv.AddAnItem('Heavy gloves 02_crafted',1);
	thePlayer.inv.AddAnItem('Heavy gloves 01_crafted',1);
	thePlayer.inv.AddAnItem('Heavy gloves 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy gloves 04_crafted',1);
	thePlayer.inv.AddAnItem('Boots 01_crafted',1);
	thePlayer.inv.AddAnItem('Boots 02_crafted',1);
	thePlayer.inv.AddAnItem('Boots 04_crafted',1);
	thePlayer.inv.AddAnItem('Boots 07_crafted',1);
	thePlayer.inv.AddAnItem('Boots 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 07_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 01_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 02_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 04_crafted',1);
	thePlayer.inv.AddAnItem('Heavy boots 08_crafted',1);
	thePlayer.inv.AddAnItem('Pants 01_crafted',1);
	thePlayer.inv.AddAnItem('Pants 02_crafted',1);
	thePlayer.inv.AddAnItem('Pants 04_crafted',1);
	thePlayer.inv.AddAnItem('Pants 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy pants 02_crafted',1);
	thePlayer.inv.AddAnItem('Heavy pants 01_crafted',1);
	thePlayer.inv.AddAnItem('Heavy pants 03_crafted',1);
	thePlayer.inv.AddAnItem('Heavy pants 04_crafted',1);
}

exec function addviperset()
{
	thePlayer.inv.AddAnItem('EP1 Witcher Armor',1);
	thePlayer.inv.AddAnItem('EP1 Witcher Boots',1);
	thePlayer.inv.AddAnItem('EP1 Witcher Gloves',1);
	thePlayer.inv.AddAnItem('EP1 Witcher Pants',1);
}

exec function resetme(optional level : int)
{
	resetLevels_internal(level);
	addAutogenEquipment_internal();
}
