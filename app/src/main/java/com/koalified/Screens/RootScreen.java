package com.koalified.Screens;


import android.widget.Toast;
import android.os.Bundle;
import android.app.Activity;
import android.view.View;
import com.koalified.R;

public class RootScreen extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        setPlaceholderAction(R.id.action_today, "Today view is ready for timetable data.");
        setPlaceholderAction(R.id.action_courses, "Course tracking is coming next.");
        setPlaceholderAction(R.id.action_calculator, "Grade calculator is coming next.");
    }

    private void setPlaceholderAction(int viewId, String message) {
        View action = findViewById(viewId);
        action.setOnClickListener(view ->
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show());
    }
}