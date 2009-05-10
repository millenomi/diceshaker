(function(global) {

	if (!global.ILabs)
		this.ILabs = {};
	
	if (!global.ILabs.Diceshaker)
		global.ILabs.Diceshaker = {};
	
	function ILabs_Diceshaker_makeSimpleAdapter() {
		var history = null, currentDice = null, lastRoll = [];
		
		function loadHistoryIfNeeded() {
			if (!history) {
				history = this.loadHistory() || [];
				this.historyChanged();
			}
		}
		
		function loadCurrentDiceIfNeeded() {
			if (!currentDice) {
				currentDice = this.loadCurrentDice() || ILabs.Dice.make(3,6);
				this.currentDiceChanged();
			}
		}
		
		function SimpleAdapter_prepare() {
			loadHistoryIfNeeded.apply(this);
			loadCurrentDiceIfNeeded.apply(this);
		}
		
		function SimpleAdapter_history() {
			loadHistoryIfNeeded.apply(this);
			return history;
		}
		
		function SimpleAdapter_pushIntoHistory(dice) {
			loadHistoryIfNeeded.apply(this);
			history.push(dice);
			this.historyChanged();
		}
		
		function SimpleAdapter_currentDice() {
			loadCurrentDiceIfNeeded.apply(this);
			return currentDice;
		}
		
		function SimpleAdapter_setCurrentDice(d) {
			currentDice = d;
			this.currentDiceChanged();
		}
		
		function SimpleAdapter_setLastRoll(roll) {
			lastRoll = roll;
			this.lastRollChanged();
		}
		
		function SimpleAdapter_lastRoll() {
			return lastRoll;
		}
		
		return {
			prepare: SimpleAdapter_prepare,
			
			history: SimpleAdapter_history,
			pushIntoHistory: SimpleAdapter_pushIntoHistory,
			historyChanged: function() {},
			loadHistory: function() {},
			
			currentDice: SimpleAdapter_currentDice,
			setCurrentDice: SimpleAdapter_setCurrentDice,
			currentDiceChanged: function() {},
			loadCurrentDice: function() {},
			
			lastRoll: SimpleAdapter_lastRoll,
			setLastRoll: SimpleAdapter_setLastRoll,
			lastRollChanged: function() {},
		};
	}
	global.ILabs.Diceshaker.makeSimpleAdapter = ILabs_Diceshaker_makeSimpleAdapter;

})(this);