package net.infinite_labs.diceshaker.ad;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import net.infinite_labs.diceshaker.AppController;
import net.infinite_labs.diceshaker.Dice;
import net.infinite_labs.diceshaker.ShakeDetector;
import net.infinite_labs.diceshaker.ad.debugging.SimulatedAccelerometer;
import android.app.Activity;
import android.app.Dialog;
import android.content.SharedPreferences;
import android.hardware.SensorListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

public class Diceshaker extends Activity {
	private static final String LastRolledDiePreferenceKey = "L0LastRolledDie"; 
	private static final String HistoryPreferenceKey = "L0History";
	
	private AppController.Model model = new AppController.Model() {
		private Dice currentDice = null;
		
		public Dice currentDice() {
			if (currentDice == null) {
				SharedPreferences p = getPreferences(MODE_PRIVATE);
				String desc = p.getString(LastRolledDiePreferenceKey, null);
				if (desc != null)
					currentDice = Dice.fromDescription(desc);
				
				if (currentDice == null)
					currentDice = new Dice(3, 6);
			}
			
			return currentDice;
		}

		private List<Dice> history = null;
		
		public List<Dice> history() {
			if (history == null) {
				SharedPreferences p = getPreferences(MODE_PRIVATE);
				String descGroup = p.getString(HistoryPreferenceKey, null);
				if (descGroup == null)
					history = new LinkedList<Dice>();
				else
					history = new LinkedList<Dice>(Dice.fromDescriptionGroup(descGroup));
			}
			
			return history;
		}

		public boolean pushCurrentDiceToHistoryIfNeeded() {
			if (!history.contains(currentDice())) {
				history.add(currentDice());
				
				SharedPreferences.Editor e = getPreferences(MODE_PRIVATE).edit();
				e.putString(HistoryPreferenceKey, Dice.toDescriptionGroup(history));
				e.commit();

				return true;
			} else
				return false;
		}

		public void setCurrentDice(Dice dice) {
			currentDice = dice;
			SharedPreferences.Editor e = getPreferences(MODE_PRIVATE).edit();
			e.putString(LastRolledDiePreferenceKey, dice.toString());
			e.commit();
		}

		public void setCurrentDiceIfNone(Dice dice) {
			if (currentDice == null)
				setCurrentDice(dice);
		}
		
	};
	
	private ListView lv;
	private Button rollButton;
	private TextView rollTotalLabel;
	private TextView rollResultsLabel;
	private Button dicePickerButton;

	private ArrayAdapter<Dice> listAdapter
		= null;
	
	private ArrayAdapter<Dice> listAdapter() {
		if (listAdapter == null) {
			listAdapter = new ArrayAdapter<Dice>(Diceshaker.this,
					android.R.layout.simple_list_item_1,
					new ArrayList<Dice>());
			listAdapter.setNotifyOnChange(false);
		}
		
		return listAdapter;
	}
	
	private AppController.View view = new AppController.View() {
		public void displayCurrentDice(Dice currentDice) {
			dicePickerButton.setText(currentDice.toString());
		}
		
		public void displayHistory(List<Dice> history) {
			listAdapter().clear();
			for (Dice d : history)
				listAdapter().add(d);
			listAdapter().notifyDataSetChanged();
		}

		public void displayHistoryAfterPushing(Dice currentDice,
				List<Dice> history) {
			listAdapter().add(currentDice);
			listAdapter().notifyDataSetChanged();
		}

		public void displayRoll(long total, long[] roll) {
			rollTotalLabel.setText(Long.toString(total));
			
			StringBuffer dice = new StringBuffer();
			boolean first = true;
			for (long l : roll) {
				if (!first) dice.append(" + ");
				dice.append(l);
				first = false;
			}
			rollResultsLabel.setText(dice.toString());
		}
		
	};
	
	private AppController controller;
	private ShakeDetector detector = new ShakeDetector();
	private Accelerometer accelerometer;
	
	private final int DicePickerDialogID = 1;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        detector.setDelegate(new ShakeDetector.Delegate() {

			public void didStartShaking(ShakeDetector self) {
				controller.didAskToRollCurrent();
			}

			public void didStopShaking(ShakeDetector self) {}
        	
        });
        
        detector
        	.setActivationThreshold(1.2f)
        	.setDeactivationThreshold(0.2f);
        
        accelerometer = Accelerometer.forContext(this);
        accelerometer.setListener(new SensorListener() {
			public void onAccuracyChanged(int sensor, int accuracy) {}
	
			public void onSensorChanged(int sensor, float[] accelerationInfo) {
				float[] acceleration = {
					accelerationInfo[SensorManager.DATA_X],
					accelerationInfo[SensorManager.DATA_Y],
					accelerationInfo[SensorManager.DATA_Z]
				};
				detector.feed(acceleration);
			}
		});
        
        accelerometer.listen();
        controller = new AppController(model, view);

        lv = (ListView) findViewById(R.id.historyList);
		lv.setAdapter(listAdapter());
		lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

			public void onItemClick(AdapterView<?> parent, View view, int position,
					long ident) {
				Dice d = listAdapter().getItem(position);
				controller.didAskToRoll(d);
			}
			
		});

        rollButton = (Button) findViewById(R.id.rollButton);
        rollButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View arg0) {
				controller.didAskToRollCurrent();
			}
        });
        
        rollTotalLabel = (TextView) findViewById(R.id.rollTotalLabel);
        rollResultsLabel = (TextView) findViewById(R.id.rollResultsLabel);
        dicePickerButton = (Button) findViewById(R.id.dicePickerButton);
        dicePickerButton.setOnClickListener(new View.OnClickListener() {

			public void onClick(View arg0) {
				showDialog(DicePickerDialogID);
			}
        	
        });
        
        ((TextView) findViewById(R.id.promptLabel))
        	.setText(accelerometer.isAvailable()?
        			R.string.shake_or_touch_roll_to_roll : R.string.touch_roll_to_roll);
        
        controller.didStart();
    }

	@Override
	protected Dialog onCreateDialog(int id) {
		switch (id) {
			case DicePickerDialogID:
				return new DicePickerDialog(this, controller);
			default:
				return null;
		}
	}

	@Override
	protected void onPrepareDialog(int id, Dialog dialog) {
		switch (id) {
			case DicePickerDialogID:
				((DicePickerDialog) dialog)
					.prepareWithDice(model.currentDice());
		}
	}
    
	
    
}
