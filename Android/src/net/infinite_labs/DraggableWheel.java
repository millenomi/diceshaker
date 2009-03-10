package net.infinite_labs;

import net.infinite_labs.diceshaker.ad.R;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

public class DraggableWheel extends View {
	
	private BitmapDrawable backdrop;

	int offset = 0;
	
	@Override
	protected void onDraw(Canvas canvas) {
		Bitmap b = backdrop.getBitmap();
		Paint p = new Paint();
		
		int firstWholeAt = (offset % b.getHeight());
		if (firstWholeAt > 0)
			firstWholeAt = - (b.getHeight() - firstWholeAt);
		
		for (int i = firstWholeAt; i < getHeight(); i += b.getHeight())
			canvas.drawBitmap(b, 0, i, p);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		this.setMeasuredDimension(20, 200);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// TODO Auto-generated method stub
		return super.onTouchEvent(event);
	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();
		
		this.setFocusable(false);
		backdrop = (BitmapDrawable) getContext().getResources().getDrawable(R.drawable.draggable_wheel_backdrop);
	}

	public DraggableWheel(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public DraggableWheel(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public DraggableWheel(Context context) {
		super(context);
	}

	

}
