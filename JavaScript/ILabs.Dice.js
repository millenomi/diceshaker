(function(global) {

	if (!global.ILabs)
		this.ILabs = {};
	
	if (!global.ILabs.Dice)
		global.ILabs.Dice = {};
		
	function ILabs_Dice_make(numberOfDice, numberOfFacesPerDie) {
		function ILabs_Dice_numberOfDice() { return numberOfDice; }
		function ILabs_Dice_numberOfFacesPerDie() { return numberOfFacesPerDie; }
		
		function ILabs_Dice_toString() {
			return this.numberOfDice() + "d" + this.numberOfFacesPerDie();
		}
		
		function ILabs_Dice_equals(x) {
			if (!x) return false;
			var fun = (typeof (function() {}));
			return (
				(typeof x.numberOfDice == fun) &&
				(typeof x.numberOfFacesPerDie == fun) &&
				(x.numberOfDice() == this.numberOfDice()) &&
				(x.numberOfFacesPerDie() == this.numberOfFacesPerDie()) );
		}
		
		function ILabs_Dice_rollEachDie() {
			var result = [];
			for (var i = 0; i < numberOfDice; i++)
				result.push(Math.ceil(Math.random() * numberOfFacesPerDie));
			return result;
		}

		function ILabs_Dice_roll() {
			var dice = this.rollEachDie();
			var total = 0;
			for (var i = 0; i < dice.length; i++)
				total += dice[i];
			return total;
		}
		
		return {
			// Accessors ------------
			numberOfDice: ILabs_Dice_numberOfDice,
			numberOfFacesPerDie: ILabs_Dice_numberOfFacesPerDie,
			// ----------------------
			
			// Equality and stringification --
			toString: ILabs_Dice_toString,
			equals: ILabs_Dice_equals,
			// -----------------------
			
			// Rolling ---------------
			rollEachDie: ILabs_Dice_rollEachDie,
			roll: ILabs_Dice_roll,
			// -----------------------
		}
	}
	global.ILabs.Dice.make = ILabs_Dice_make;
	
	function ILabs_Dice_fromString(string) {
		var parts = string.split(/d/);
		if (parts.length != 2) return null;
	
		var no = parseInt(parts[0]), faces = parseInt(parts[1]);
		return this.make(no, faces);
	}
	global.ILabs.Dice.fromString = ILabs_Dice_fromString;
	
	function ILabs_Dice_arrayFromString(string) {
		var diceStrings = string.split(/,/);
		var dice = [], d;
		for (var i = 0; i < diceStrings.length; i++) {
			if (d = ILabs.Dice.fromString(diceStrings[i]))
				dice.push(d);
		}
		
		return dice;
	}
	global.ILabs.Dice.arrayFromString = ILabs_Dice_arrayFromString;
	
	function ILabs_Dice_stringFromArray(array) {
		var result = '';
		var first = true;
		for (var i = 0; i < array.length; i++) {
			if (!first) result += ',';
			result += array[i].toString();
			first = false;
		}
		
		return result;
	}
	global.ILabs.Dice.stringFromArray = ILabs_Dice_stringFromArray;
	
	function ILabs_Dice_totalOf(array) {
		var t = 0;
		for (var i = 0; i < array.length; i++)
			t += array[i];
		return t;
	}
	global.ILabs.Dice.totalOf = ILabs_Dice_totalOf;
	
	Array.prototype.totalOfRoll = function() {
		return global.ILabs.Dice.totalOf(this);
	};
	
})(this);
