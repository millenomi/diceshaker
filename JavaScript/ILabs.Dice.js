
(function() {
	if (!window.ILabs)
	    window.ILabs = {};

	if (!ILabs.Dice) {
	    ILabs.Dice = function(numberOfDice, numberOfFacesPerDie) {
	        this.rollEachDie = function() {
	            var result = [];
	            for (var i = 0; i < numberOfDice; i++)
	                result.push(Math.ceil(Math.random() * numberOfFacesPerDie));
	            return result;
	        };
        
	        this.roll = function() {
	            var dice = this.rollEachDie();
	            var total = 0;
	            for (var i = 0; i < dice.length; i++)
	                total += dice[i];
	            return total;
	        };
        
	        this.numberOfFacesPerDie = function() {
	            return numberOfFacesPerDie;
	        };
        
	        this.numberOfDice = function() {
	            return numberOfDice;
	        };
        
	        this.toString = function() {
	            return this.numberOfDice() + "d" + this.numberOfFacesPerDie();
	        }
	
			this.equals = function(x) {
				if (!x) return false;
				var fun = (typeof (function() {}));
				return (
					(typeof x.numberOfDice == fun) &&
					(typeof x.numberOfFacesPerDie == fun) &&
					(x.numberOfDice() == this.numberOfDice()) &&
					(x.numberOfFacesPerDie() == this.numberOfFacesPerDie()) );
			}
	    }
    
	    ILabs.Dice.fromString = function(string) {
	        var parts = string.split(/d/);
	        if (parts.length != 2) return null;
        
	        var no = parseInt(parts[0]), faces = parseInt(parts[1]);
	        return new this(no, faces);
	    };

		ILabs.Dice.arrayFromString = function(string) {
			var parts = string.split(/,/);
			var result = [];
			for (var i = 0; i < parts.length; i++)
				result.push(this.fromString(string));
			return result;
		};
	
		ILabs.Dice.stringFromArray = function(array) {
			var result = '';
			var first = true;
			for (var i = 0; i < array.length; i++) {
				if (!first) result += ',';
				result += array[i].toString();
				first = false;
			}
			return result;
		};
		
		ILabs.Dice.totalOf = function(array) {
			var t = 0;
			for (var i = 0; i < array.length; i++)
                t += array[i];
			return t;
		};
	}
})();
