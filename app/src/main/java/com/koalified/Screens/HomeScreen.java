package com.koalified.Screens;

import android.content.Intent;
import android.widget.Toast;
import android.os.Bundle;
import android.app.Activity;
import android.view.View;
import com.koalified.R;

public class HomeScreen extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        findViewById(R.id.action_courses).setOnClickListener(view ->
            startActivity(new Intent(HomeScreen.this, CoursesScreen.class))
        );
        findViewById(R.id.action_today).setOnClickListener(view ->
            startActivity(new Intent(HomeScreen.this, HomeScreen.class))
        );
        findViewById(R.id.action_calculator).setOnClickListener(view ->
            startActivity(new Intent(HomeScreen.this, CalculatorScreen.class))
        );
    }


    private void setPlaceholderAction(int viewId, String message) {
        View action = findViewById(viewId);
        action.setOnClickListener(view ->
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show());
    }
}