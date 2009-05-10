(function(global) {

	if (!global.ILabs)
		this.ILabs = {};
	
	if (!global.ILabs.Diceshaker)
		global.ILabs.Diceshaker = {};
		
	function ILabs_Diceshaker_make(adapter) {
		adapter.prepare();
		
		function ILabs_Diceshaker_rollDice(dice) {
			var c = adapter.currentDice();
			if (!c.equals(dice))
				adapter.setCurrentDice(dice);

			var roll = dice.rollEachDie();
			adapter.setLastRoll(roll);

			var history = adapter.history();
			var found = false;
			for (var i = 0; i < history.length; i++) {
				if (history[i].equals(dice)) {
					found = true; break;
				}
			}

			if (!found)
				adapter.pushIntoHistory(dice);
		}
		
		function ILabs_Diceshaker_rollCurrentDice() {
			this.rollDice(adapter.currentDice());
		}
		
		function ILabs_Diceshaker_setCurrentDiceNumber(amount) {
			var dice = new ILabs.Dice(amount, adapter.currentDice().numberOfFacesPerDie());
			adapter.setCurrentDice(dice);
		}
		
		function ILabs_Diceshaker_setCurrentDiceNumberOfSides(sides) {
			var dice = new ILabs.Dice(adapter.currentDice().numberOfDice(), sides);
			adapter.setCurrentDice(dice);			
		}
		
		return {
			rollDice: ILabs_Diceshaker_rollDice,
			rollCurrentDice: ILabs_Diceshaker_rollCurrentDice,
			setCurrentDiceNumber: ILabs_Diceshaker_setCurrentDiceNumber,
			setCurrentDiceNumberOfSides: ILabs_Diceshaker_setCurrentDiceNumberOfSides,
		};
	}
	
	global.ILabs.Diceshaker.make = ILabs_Diceshaker_make;
	
})(this);