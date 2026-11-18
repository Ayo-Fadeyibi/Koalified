package com.koalified.Fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.koalified.R;

public class TodayFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater,
            @Nullable ViewGroup container,
            @Nullable Bundle savedInstanceState
    ) {
        return inflater.inflate(R.layout.fragment_today, container, false);
    }

    @Override
    public void onViewCreated(
            @NonNull View view,
            @Nullable Bundle savedInstanceState
    ) {
        super.onViewCreated(view, savedInstanceState);

        View importTimetable = view.findViewById(R.id.action_today_import_timetable);
        View addClass = view.findViewById(R.id.action_today_add_class);

        importTimetable.setOnClickListener(v -> openFragment(new TimetableFragment()));

        addClass.setOnClickListener(v -> openFragment(new TimetableFragment()));
    }

    private void openFragment(Fragment fragment) {
        if (getParentFragmentManager() != null) {
            getParentFragmentManager()
                    .beginTransaction()
                    .replace(R.id.home_container, fragment)
                    .addToBackStack(null)
                    .commit();
        }
    }
}