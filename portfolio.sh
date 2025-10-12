#!/bin/bash

# Simple Portfolio

# --- Personal Information ---
NAME="Your Name"
EMAIL="your.email@example.com"
WEBSITE="https://your-portfolio.com"
GITHUB="https://github.com/your-username"

# --- Projects ---
# Add your projects here
PROJECTS=(
  "Project 1: A brief description of your first project."
  "Project 2: A brief description of your second project."
  "Project 3: A brief description of your third project."
)

# --- Skills ---
# Add your skills here
SKILLS=(
  "Skill 1"
  "Skill 2"
  "Skill 3"
  "Skill 4"
)

# --- Display Portfolio ---
echo "========================================"
echo "           PORTFOLIO"
echo "========================================"
echo
echo "Name: $NAME"
echo "Email: $EMAIL"
echo "Website: $WEBSITE"
echo "GitHub: $GITHUB"
echo
echo "--- Projects ---"
for project in "${PROJECTS[@]}"; do
  echo "- $project"
done
echo
echo "--- Skills ---"
for skill in "${SKILLS[@]}"; do
  echo "- $skill"
done
echo
echo "========================================"
