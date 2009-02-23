package net.infinite_labs.diceshaker.ad;

import java.lang.reflect.InvocationTargetException;

import android.content.Context;
import android.hardware.SensorListener;
import android.hardware.SensorManager;

public class Accelerometer {
	private Context context;
	private SensorManager manager;
	
	public Accelerometer(Context c) {
		setContext(c);
		setManager((SensorManager) context().getSystemService(Context.SENSOR_SERVICE));
	}
	
	private SensorListener listener;
	
	public SensorListener listener() {
		return listener;
	}

	public void setListener(SensorListener listener) {
		this.listener = listener;
	}

	public void listen() {
		if (!isAvailable()) return;
		
		manager().registerListener(listener(), SensorManager.SENSOR_ACCELEROMETER);
	}
	
	public void stopListening() {
		if (!isAvailable()) return;
		
		manager().unregisterListener(listener);
	}
	
	public boolean isAvailable() {
		return manager() != null && ((manager().getSensors() & SensorManager.SENSOR_ACCELEROMETER) != 0);
	}
	
	public SensorManager manager() { return manager; }
	public Context context() { return context; }
	
	private static Class<? extends Accelerometer> preferredClass = Accelerometer.class;
	
	public static Class<? extends Accelerometer> preferredClass() {
		return preferredClass;
	}

	public static void setPreferredClass(
			Class<? extends Accelerometer> preferredClass) {
		Accelerometer.preferredClass = preferredClass;
	}

	public static Accelerometer forContext(Context c) {
		try {
			return preferredClass.getConstructor(Context.class).newInstance(c);
		} catch (InstantiationException e) {
			throw new IllegalStateException(e);
		} catch (IllegalAccessException e) {
			throw new IllegalStateException(e);
		} catch (InvocationTargetException e) {
			throw new IllegalStateException(e);
		} catch (NoSuchMethodException e) {
			throw new IllegalStateException(e);
		}
	}

	protected void setContext(Context context) {
		this.context = context;
	}

	protected void setManager(SensorManager manager) {
		this.manager = manager;
	}
}
