package main

import (
	"testing"
)

func TestIsValidProjectName(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected bool
	}{
		{"valid lowercase", "project1", true},
		{"valid with underscore", "my_project", true},
		{"valid with numbers", "project123", true},
		{"invalid uppercase", "Project", false},
		{"invalid special char", "project-1", false},
		{"invalid too short", "p", false},
		{"invalid too long", "this_project_name_is_way_too_long_and_should_fail_validation", false},
		{"valid boundary", "pr", true},
		{"valid boundary long", "abcdefghijklmnopqrstuvwxyz1234", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := isValidProjectName(tt.input)
			if result != tt.expected {
				t.Errorf("isValidProjectName(%q) = %v, want %v", tt.input, result, tt.expected)
			}
		})
	}
}

func TestGetEnv(t *testing.T) {
	// Test default value
	result := getEnv("NON_EXISTENT_ENV_VAR", "default_value")
	if result != "default_value" {
		t.Errorf("getEnv returned %q, want %q", result, "default_value")
	}
}