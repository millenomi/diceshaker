package net.infinite_labs.diceshaker;

public class ShakeDetector {
	private Delegate delegate;
	private float[] lastAcceleration;
	private boolean shaking = false;
	
	public void feed(float[] newAcceleration) {
		if (lastAcceleration != null && newAcceleration.length != lastAcceleration.length)
			throw new IllegalArgumentException();
		
		
		if (lastAcceleration != null) {
			boolean oldShaking = shaking;
			updateShaking(newAcceleration);
		
			if (oldShaking != shaking && delegate != null) {
				if (shaking)
					delegate.didStartShaking(this);
				else
					delegate.didStopShaking(this);
			}
		}

		lastAcceleration = newAcceleration;
	}
	
	private float activationThreshold;
	private float deactivationThreshold;
	
	private void updateShaking(float[] newAcceleration) {
		float threshold = shaking? deactivationThreshold : activationThreshold;
		
		int shakers = 0;
		for (int i = 0; i < newAcceleration.length; i++) {
			if (Math.abs(lastAcceleration[i] - newAcceleration[i]) > threshold) {
				shakers++;
				if (shakers >= 2) {
					shaking = !shaking;
					return;
				}
			}
		}
	}

	public float activationThreshold() {
		return activationThreshold;
	}

	public ShakeDetector setActivationThreshold(float activationThreshold) {
		this.activationThreshold = activationThreshold;
		return this;
	}

	public float deactivationThreshold() {
		return deactivationThreshold;
	}

	public ShakeDetector setDeactivationThreshold(float deactivationThreshold) {
		this.deactivationThreshold = deactivationThreshold;
		return this;
	}

	public boolean isShaking() {
		return shaking;
	}
	
	public interface Delegate {
		void didStartShaking(ShakeDetector self);
		void didStopShaking(ShakeDetector self);
	}

	public Delegate delegate() {
		return delegate;
	}

	public void setDelegate(Delegate delegate) {
		this.delegate = delegate;
	}
}
