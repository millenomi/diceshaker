package net.infinite_labs.diceshaker.ad.debugging;

import org.openintents.hardware.SensorManagerSimulator;
import org.openintents.provider.Hardware;

import android.content.Context;
import android.content.Intent;
import net.infinite_labs.diceshaker.ad.Accelerometer;

public class SimulatedAccelerometer extends Accelerometer {

	public SimulatedAccelerometer(Context c) {
		super(c);
		Hardware.mContentResolver = c.getContentResolver();
		if (manager() != null)
			setManager(new SensorManagerSimulator(super.manager()));
	}
	
	private boolean isConfigured = false;

	@Override
	public void listen() {
		if (!isConfigured) {
			Intent intent = new Intent(Intent.ACTION_VIEW, 
					Hardware.Preferences.CONTENT_URI); 
			// context().startActivity(intent);
			isConfigured = true;
			SensorManagerSimulator.connectSimulator();
		}
		
		super.listen();
	}
	
	
}
