package net.infinite_labs.diceshaker;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Dice {
	private int numberOfDice;
	private int numberOfFacesPerDie;
	
	public Dice(int dice, int faces) {
		numberOfDice = dice;
		numberOfFacesPerDie = faces;
	}
	
	public long[] roll() {
		long[] r = new long[numberOfDice];
		Random random = new Random();
		
		for (int i = 0; i < r.length; i++)
			r[i] = random.nextInt(numberOfFacesPerDie) + 1;
		
		return r;
	}
	
	public static long totalOf(long[] roll) {
		long t = 0;
		for (int i = 0; i < roll.length; i++)
			t += roll[i];
		
		return t;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + numberOfDice();
		result = prime * result + numberOfFacesPerDie();
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Dice other = (Dice) obj;
		if (numberOfDice() != other.numberOfDice())
			return false;
		if (numberOfFacesPerDie() != other.numberOfFacesPerDie())
			return false;
		return true;
	}
	
	public int numberOfDice() { return numberOfDice; }
	public int numberOfFacesPerDie() { return numberOfFacesPerDie; }
	
	public String description() {
		return numberOfDice() + "d" + numberOfFacesPerDie();
	}
	
	@Override
	public String toString() {
		return description();
	}
	
	public static Dice fromDescription(String s) {
		String[] parts = s.split("d");
		if (parts.length != 2)
			return null;
		
		try { 
			return new Dice(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]));
		} catch (NumberFormatException ex) { return null; }
	}
	
	public static List<Dice> fromDescriptionGroup(String s) {
		ArrayList<Dice> diceList = new ArrayList<Dice>();
		
		String[] allDiceStrings = s.split(",");
		for (String diceString : allDiceStrings) {
			Dice d = fromDescription(diceString);
			if (d != null) diceList.add(d);
		}
		
		return diceList;
	}
	
	public static String toDescriptionGroup(Iterable<Dice> s) {
		StringBuilder descriptionGroup = new StringBuilder();
		boolean first = true;
		for (Dice d : s) {
			if (!first) descriptionGroup.append(",");
			descriptionGroup.append(d.description());
			first = false;
		}
		
		return descriptionGroup.toString();
	}
}
