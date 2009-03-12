
(function(){

	if (!window.ILabs)
	    window.ILabs = {};

	if (!ILabs.Diceshaker) {
		ILabs.Diceshaker = {};
		ILabs.Diceshaker.makeEventsWithModelAndView = function(model, view) {
			return {
				didStart: function() {
					model.setCurrentDiceIfNone(new ILabs.Dice(3, 6));
					view.displayCurrentDice(model.currentDice());
					view.displayHistory(model.history());
				},
				didAskToRollCurrent: function() {
					this.didAskToRoll(model.currentDice());
				},
				didAskToRoll: function(dice) {
					model.setCurrentDice(dice);
					var result = dice.rollEachDie();
					view.displayRoll(ILabs.Dice.totalOf(result), result);

					if (model.pushCurrentDiceToHistoryIfNeeded())
						view.displayHistoryAfterPushing(model.currentDice(), model.history());
					
					view.displayCurrentDice(model.currentDice());
				},
				didChangeDiceSettings: function(numberOfDice, numberOfFacesPerDie) {
					model.setCurrentDice(new ILabs.Dice(parseInt(numberOfDice), parseInt(numberOfFacesPerDie)));
					view.displayCurrentDice(model.currentDice());
				}
			};
		};
		ILabs.Diceshaker.makeDefaultModel = function(x) {
			var model = {
				_history: null,
				_currentDice: null,
				currentDice: function() {
					if (!this._currentDice)
						this._currentDice = this.loadStoredDice();
					
					return this._currentDice;
				},
				setCurrentDice: function(x) {
					this._currentDice = x;
				},
				setCurrentDiceIfNone: function(y) {
					if (!this.currentDice())
						this.setCurrentDice(y);
				},
				history: function() {
					if (!this._history)
						this._history = this.loadStoredHistory();
						
					return this._history;
				},
				pushCurrentDiceToHistoryIfNeeded: function() {
					if (!this.currentDice()) return false;
					
                    if (!this._history)
                        this._history = this.loadStoredHistory();
                    
					for (var i = 0; i < this._history.length; i++) {
						if (this._history[i].equals(this.currentDice()))
							return;
					}
					
					this._history.push(this.currentDice());
					this.storeHistory(this._history);
					return true;
				},
				loadStoredDice: function() { return new ILabs.Dice(3, 6); },
				storeHistory: function(h) {},
				loadStoredHistory: function() { return [] }
			};
			
			if (x) {
				if (typeof x == 'function')
					model = x(model);
				else {
					for (var i in x)
						model[i] = x[i];
				}
			}
			
			return model;
		};
	}
	
	/*
		{
			view: {
				displayCurrentDice: function(dice) {},
				displayHistory: function(arrayOfDice) {},
				displayRoll: function(total, arrayOfDieResults) {},
				displayHistoryAfterPushing: function(newDice) {},
			},
		
			model: {
				history: function() {},
				currentDice: function() {},
				setCurrentDice: function(newDice) {},
				setCurrentDiceIfNone: function(newDiceIfNone) {},
				pushCurrentDiceToHistoryIfNeeded: function() {},
			},
			
			defaultModel: {
				loadStoredDice: function() {},
				storeHistory: function(h) {},
				loadStoredHistory: function() {}
			}
		}
	*/

})();
