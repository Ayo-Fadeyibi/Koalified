package com.koalified.Models;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "courses")
public class Course {
    @PrimaryKey(autoGenerate = true)
    public long id;

    public String courseCode;
    public String title;
    // Store values such as "S1", "S2", or "S3".
    public String term;
    public int year;
    public String color;
    public Long censusDateMillis;
    public Long lastDropDateMillis;

    public Course(
        String courseCode,
        String title,
        String term,
        int year,
        String color
    ) {
        this.courseCode = courseCode;
        this.title = title;
        this.term = term;
        this.year = year;
        this.color = color;
    }

    public String getSemesterLabel() {
        String termLabel;
        switch (term) {
            case "S1":
                termLabel = "Semester 1";
                break;
            case "S2":
                termLabel = "Semester 2";
                break;
            case "S3":
                termLabel = "Summer";
                break;
            default:
                termLabel = term;
        }
        return termLabel + ", " + year;
    }
}