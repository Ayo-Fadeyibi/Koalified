package com.koalified.Screens;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

/**
 * Android entry point corresponding to the iOS KoalifiedApp.
 * Shows a short first-run splash, then hands off to the app's home screen.
 */
public class KoalifiedHome extends Activity {
    private static final String PREFERENCES_NAME = "koalified_preferences";
    private static final String KEY_HAS_ONBOARDED = "hasOnboarded";
    private static final long SPLASH_DURATION_MS = 700L;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean openingHome = false;

    private final Runnable openHome = () -> {
        if (isFinishing() || isDestroyed()) {
            return;
        }
        openingHome = true;
        startActivity(new Intent(this, HomeScreen.class));
        finish();
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        SharedPreferences preferences = getSharedPreferences(
                PREFERENCES_NAME, MODE_PRIVATE);
        boolean hasOnboarded = preferences.getBoolean(KEY_HAS_ONBOARDED, false);

        if (hasOnboarded) {
            openHome.run();
        } else {
            showSplash();
            handler.postDelayed(openHome, SPLASH_DURATION_MS);
        }
    }

    private void showSplash() {
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.rgb(191, 242, 221));

        TextView title = new TextView(this);
        title.setText("Koalified");
        title.setTextColor(Color.rgb(32, 34, 43));
        title.setTextSize(36);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        title.setGravity(Gravity.CENTER);

        TextView subtitle = new TextView(this);
        subtitle.setText("Your semester, sorted.");
        subtitle.setTextColor(Color.rgb(65, 75, 76));
        subtitle.setTextSize(16);
        subtitle.setGravity(Gravity.CENTER);

        FrameLayout.LayoutParams titleParams = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER);
        titleParams.bottomMargin = 36;
        root.addView(title, titleParams);

        FrameLayout.LayoutParams subtitleParams = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER);
        subtitleParams.topMargin = 54;
        root.addView(subtitle, subtitleParams);

        root.setAlpha(0f);
        setContentView(root);
        root.animate().alpha(1f).setDuration(SPLASH_DURATION_MS).start();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // iOS re-syncs reminders and widget data when the app becomes active.
        // Hook the Android notification/widget refresh here once those services are implemented.
        if (!openingHome) {
            refreshAndroidAppData();
        }
    }

    private void refreshAndroidAppData() {
        // TODO: refresh local reminders and widget data when those Android features are added.
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacks(openHome);
        super.onDestroy();
    }
}
