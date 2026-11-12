package com.koalified.Models;

import androidx.room.Entity;
import androidx.room.ForeignKey;
import androidx.room.Index;
import androidx.room.PrimaryKey;

@Entity(
    tableName = "assessments",
    foreignKeys = @ForeignKey(
        entity = Course.class,
        parentColumns = "id",
        childColumns = "courseId",
        onDelete = ForeignKey.CASCADE
    ),
    indices = {@Index("courseId")}
)
public class AssessmentItem {
    @PrimaryKey(autoGenerate = true)
    public long id;

    public long courseId;
    public String title;
    public double weight;
    // Milliseconds since epoch; this avoids needing a Room Date converter.
    public long dueDateMillis;
    // null means the assessment has not been marked.
    public Double mark;

    public AssessmentItem(
        long courseId,
        String title,
        double weight,
        long dueDateMillis,
        Double mark
    ) {
        this.courseId = courseId;
        this.title = title;
        this.weight = weight;
        this.dueDateMillis = dueDateMillis;
        this.mark = mark;
    }
}