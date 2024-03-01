package com.example.demo.message;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import java.util.Map;
import java.util.List;
import com.example.demo.Preference.*;

@RestController
@RequestMapping(path = "/")
public class MessageController {

    // Existing @GetMapping for "/hello"
    @GetMapping(path = "/hello")
    public Message helloWorld() {
        return new Message("hello world");
    }

    // New @GetMapping for "/music_type"
    @GetMapping(path = "/music_type")
    public Map<String, List<String>> getMusicType() {
    	Map<String, List<String>> musicType = Preference.getDefaultPreferences();
    	musicType.remove("workouts");

        return musicType;
    }

    // New @GetMapping for "/workout_type"
    @GetMapping(path = "/workout_type")
    public List<String> getWorkoutType() {
        return Preference.getDefaultPreferences().get("workouts");
    }
}

