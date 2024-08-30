#!/bin/bash

# Check if all necessary arguments were provided
# Function to prompt for input if not provided as an argument
prompt_for_input() {
    local prompt_message=$1
    local input_value
    read -p "$prompt_message" input_value
    echo "$input_value"
}

# Check if REPO_URL argument was provided, otherwise prompt for it
if [ -z "$1" ]; then
    REPO_URL=$(prompt_for_input "Enter the repository URL: ")
else
    REPO_URL="$1"
fi

# Check if NEW_NAME argument was provided, otherwise prompt for it
if [ -z "$2" ]; then
    NEW_NAME=$(prompt_for_input "Enter the new app name: ")
else
    NEW_NAME="$2"
fi

NEW_NAME_LOWER=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]')

# Clone the repository into a directory with the new name in lowercase
git clone $REPO_URL $NEW_NAME_LOWER

# Enter the new application directory
cd $NEW_NAME_LOWER

# Remove the existing .git directory
rm -rf .git

# Initialize a new Git repository
git init

# Extract the old name from the Rails module in the config/application.rb file
OLD_NAME=$(grep "module " config/application.rb | sed -e 's/module \(.*\)/\1/' -e 's/ *$//')

# Convert OLD_NAME to snake_case
OLD_NAME_SNAKE=$(echo "$OLD_NAME" | sed -r 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')

# Convert NEW_NAME to snake_case
NEW_NAME_SNAKE=$(echo "$NEW_NAME" | sed -r 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')

# Convert OLD_NAME to uppercase with underscores for environment variables
OLD_NAME_ENV=$(echo "$OLD_NAME_SNAKE" | tr '[:lower:]' '[:upper:]')

# Convert NEW_NAME to uppercase with underscores for environment variables
NEW_NAME_ENV=$(echo "$NEW_NAME_SNAKE" | tr '[:lower:]' '[:upper:]')

# Replace all occurrences of the old name with the new name across all project files
find . -type f \( -name "*.rb" -o -name "*.erb" -o -name "*.yml" -o -name "*.js" -o -name "*.css" \) -exec sed -i "" \
-e "s/${OLD_NAME}/${NEW_NAME}/g" \
-e "s/${OLD_NAME_SNAKE}/${NEW_NAME_SNAKE}/g" \
-e "s/${OLD_NAME_SNAKE}_/${NEW_NAME_SNAKE}_/g" \
-e "s/${OLD_NAME_ENV}/${NEW_NAME_ENV}/g" {} +

# Add all files to the new repository and commit them
git add .
git commit -m "Initial commit with new project name $NEW_NAME"

echo "All references to '$OLD_NAME' have been updated to '$NEW_NAME' in all cases. New Git repository initialized."
