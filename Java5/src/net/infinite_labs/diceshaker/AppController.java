package net.infinite_labs.diceshaker;

import java.util.List;

public class AppController {
	public interface Model {
		void setCurrentDiceIfNone(Dice dice);
		Dice currentDice();
		void setCurrentDice(Dice dice);
		boolean pushCurrentDiceToHistoryIfNeeded();
		List<Dice> history();
	}

	public interface View {
		void displayRoll(long total, long[] roll);
		void displayHistoryAfterPushing(Dice currentDice, List<Dice> history);
		void displayCurrentDice(Dice currentDice);
		void displayHistory(List<Dice> history);
	}

	private Model model;
	private View view;

	public AppController(Model model, View view) {
		this.model = model;
		this.view = view;
	}

	public void didStart() {
		model.setCurrentDiceIfNone(new Dice(3, 6));
		view.displayCurrentDice(model.currentDice());
		view.displayHistory(model.history());
	}

	public void didAskToRollCurrent() {
		didAskToRoll(model.currentDice());
	}

	public void didAskToRoll(Dice dice) {
		model.setCurrentDice(dice);
		long[] roll = model.currentDice().roll();

		view.displayRoll(Dice.totalOf(roll), roll);

		if (model.pushCurrentDiceToHistoryIfNeeded())
			view.displayHistoryAfterPushing(model.currentDice(), model
					.history());

		view.displayCurrentDice(model.currentDice());
	}

	public void didChangeDiceSettings(int numberOfDice, int numberOfFacesPerDie) {
		model.setCurrentDice(new Dice(numberOfDice, numberOfFacesPerDie));
		view.displayCurrentDice(model.currentDice());
	}
}
