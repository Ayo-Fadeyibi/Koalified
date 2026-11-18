package com.koalified.Screens;

import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.koalified.Fragments.CoursesFragment;
import com.koalified.Fragments.ProfileFragment;
import com.koalified.Fragments.TimetableFragment;
import com.koalified.Fragments.TodayFragment;
import com.koalified.R;

public class HomeScreen extends AppCompatActivity {

    private static final String SELECTED_TAB = "selected_tab";

    private int selectedTab = R.id.nav_today;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState != null) {
            selectedTab = savedInstanceState.getInt(SELECTED_TAB, R.id.nav_today);
        }

        bindNavigation();

        if (savedInstanceState == null) {
            showFragment(new TodayFragment());
        }

        selectNavigation(selectedTab);
    }

    private void bindNavigation() {
        findViewById(R.id.nav_today).setOnClickListener(v ->
                openTab(R.id.nav_today, new TodayFragment()));

        findViewById(R.id.nav_timetable).setOnClickListener(v ->
                openTab(R.id.nav_timetable, new TimetableFragment()));

        findViewById(R.id.nav_courses).setOnClickListener(v ->
                openTab(R.id.nav_courses, new CoursesFragment()));

        findViewById(R.id.nav_profile).setOnClickListener(v ->
                openTab(R.id.nav_profile, new ProfileFragment()));
    }

    private void openTab(int tabId, Fragment fragment) {
        if (tabId == selectedTab) {
            return;
        }

        selectedTab = tabId;
        selectNavigation(tabId);
        showFragment(fragment);
    }

    private void showFragment(Fragment fragment) {
        getSupportFragmentManager()
                .beginTransaction()
                .setReorderingAllowed(true)
                .replace(R.id.home_container, fragment)
                .commit();
    }

    private void selectNavigation(int selectedId) {
        selectNavigationItem(R.id.nav_today, selectedId == R.id.nav_today);
        selectNavigationItem(R.id.nav_timetable, selectedId == R.id.nav_timetable);
        selectNavigationItem(R.id.nav_courses, selectedId == R.id.nav_courses);
        selectNavigationItem(R.id.nav_profile, selectedId == R.id.nav_profile);
    }

    private void selectNavigationItem(int viewId, boolean selected) {
        View item = findViewById(viewId);

        item.setBackgroundResource(
                selected
                        ? R.drawable.k_mint_pill
                        : android.R.color.transparent
        );
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(SELECTED_TAB, selectedTab);
    }
}