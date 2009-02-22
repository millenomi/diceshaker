package net.infinite_labs.diceshaker.ad;

import net.infinite_labs.diceshaker.AppController;
import net.infinite_labs.diceshaker.Dice;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;

public class DicePickerDialog extends Dialog {

	private final AppController controller;
	private int numberOfFacesPerDie;
	private int numberOfDice;
	private Activity parent;
	
	private static final int[] Faces = {
		2, 3, 5, 6, 8, 10, 12, 20, 100
	};
	
	public DicePickerDialog(Activity parent, AppController controller) {
		super(parent);
		this.controller = controller;
		this.parent = parent;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		setContentView(R.layout.dice_picker);
		
		((Button) findViewById(R.id.dismissDicePickerButton))
			.setOnClickListener(new View.OnClickListener() {

			public void onClick(View arg0) {
				dismiss();
			}
			
		});
		
		((Button) findViewById(R.id.dismissDicePickerAndRollButton))
			.setOnClickListener(new View.OnClickListener() {
	
			public void onClick(View arg0) {
				dismiss();
				controller.didAskToRollCurrent();
			}
		
		});
		
		((Button) findViewById(R.id.addDieButton))
			.setOnClickListener(new View.OnClickListener() {

				public void onClick(View arg0) {
					setNumberOfDice(numberOfDice() + 1);
				}
				
		});
		
		((Button) findViewById(R.id.removeDieButton))
			.setOnClickListener(new View.OnClickListener() {
	
				public void onClick(View arg0) {
					setNumberOfDice(numberOfDice() - 1);
				}
				
		});
		
		final EditText field = ((EditText) findViewById(R.id.diceNumberField));
		field
			.addTextChangedListener(new TextWatcher() {

				public void afterTextChanged(Editable text) {
					if (text.length() == 0) return;
					
					int i;
					try {
						i = Integer.parseInt(text.toString());
					} catch (NumberFormatException ex) {
						field.setText(Integer.toString(numberOfDice));
						return;
					}
					
					setNumberOfDice(i, false);
				}

				public void beforeTextChanged(CharSequence arg0, int arg1,
						int arg2, int arg3) {}

				public void onTextChanged(CharSequence arg0, int arg1,
						int arg2, int arg3) {}
				
		});
		
		String[] faceNames = new String[Faces.length];
		for (int i = 0; i < Faces.length; i++)
			faceNames[i] = "d" + Faces[i];
		
		ArrayAdapter<String> adapter =
			new ArrayAdapter<String>(parent, 
					android.R.layout.simple_spinner_item, faceNames);
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		
		Spinner spinner = (Spinner) findViewById(R.id.diceFacesSpinner);
		spinner.setAdapter(adapter);
		spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {

			public void onItemSelected(AdapterView<?> spinner, View item,
					int position, long ident) {
				setNumberOfFacesPerDieByPosition(position);
			}

			public void onNothingSelected(AdapterView<?> arg0) {}
			
		});
	}
	
	public void prepareWithDice(Dice d) {
		numberOfDice = d.numberOfDice();
		numberOfFacesPerDie = d.numberOfFacesPerDie();
		selectNumberOfFacesInSpinner();
	}
	
	public int numberOfDice() {
		return numberOfDice;
	}
	
	public void setNumberOfDice(int d) {
		setNumberOfDice(d, true);
	}
	
	public void setNumberOfDice(int d, boolean updateUI) {
		if (d <= 0) d = 1;
		
		numberOfDice = d;

		if (updateUI)
			((EditText) findViewById(R.id.diceNumberField))
				.setText(Integer.toString(d));
		
		controller.didChangeDiceSettings(d, numberOfFacesPerDie());
	}

	public int numberOfFacesPerDie() {
		return numberOfFacesPerDie;
	}
	
	public void setNumberOfFacesPerDie(int f) {
		numberOfFacesPerDie = f;
		controller.didChangeDiceSettings(numberOfDice(), f);
		
		selectNumberOfFacesInSpinner();
	}
	
	private void selectNumberOfFacesInSpinner() {
		int i = indexInFacesOf(numberOfFacesPerDie);
		if (i != -1) {
			((Spinner) findViewById(R.id.diceFacesSpinner))
				.setSelection(i);
		}
	}

	private void setNumberOfFacesPerDieByPosition(int pos) {
		numberOfFacesPerDie = Faces[pos];
		controller.didChangeDiceSettings(numberOfDice(), numberOfFacesPerDie);
	}
	
	private static int indexInFacesOf(int faces) {
		for (int i = 0; i < Faces.length; i++)
			if (Faces[i] == faces) return i;
		
		return -1;
	}
}
