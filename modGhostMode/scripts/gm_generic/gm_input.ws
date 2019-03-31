function TestCastSignHold() : bool
{
	if( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		return true;
	if( gmInstantCastingAllowed() )
	{
		if( theInput.IsActionPressed( 'SelectAard' ) ||
			theInput.IsActionPressed( 'SelectIgni' ) ||
			theInput.IsActionPressed( 'SelectYrden' ) ||
			theInput.IsActionPressed( 'SelectQuen' ) ||
			theInput.IsActionPressed( 'SelectAxii' ) )
		{
			return ( theGame.GetEngineTimeAsSeconds() - thePlayer.castSignHoldTimestamp ) > 0.2;
		}
	}
	return false;
}

function ForceDeactivateCastSignHold()
{
	theInput.ForceDeactivateAction( 'CastSignHold' );
	theInput.ForceDeactivateAction( 'SelectAard' );
	theInput.ForceDeactivateAction( 'SelectIgni' );
	theInput.ForceDeactivateAction( 'SelectYrden' );
	theInput.ForceDeactivateAction( 'SelectQuen' );
	theInput.ForceDeactivateAction( 'SelectAxii' );
}
