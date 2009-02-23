package net.infinite_labs.diceshaker.ad.debugging;

import android.os.Bundle;
import net.infinite_labs.diceshaker.ad.Accelerometer;
import net.infinite_labs.diceshaker.ad.Diceshaker;

public class Diceshaker_SimulatedAccelerometer extends Diceshaker {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		Accelerometer.setPreferredClass(SimulatedAccelerometer.class);
		super.onCreate(savedInstanceState);
	}
	
}
