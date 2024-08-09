#!/bin/bash

# Check if all necessary arguments were provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <repo_url> <new_app_name>"
    echo "This script clones a Rails project from the provided repository URL,"
    echo "renames it to the specified new app name, initializes a new Git repository,"
    echo "and updates all occurrences of the original project name."
    exit 1
fi

# Assign arguments to variables
REPO_URL="$1"
NEW_NAME="$2"
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

# Convert names to different formats
OLD_NAME_CAMEL="$(tr '[:upper:]' '[:lower:]' <<< ${OLD_NAME:0:1})${OLD_NAME:1}"
NEW_NAME_CAMEL="$(tr '[:upper:]' '[:lower:]' <<< ${NEW_NAME:0:1})${NEW_NAME:1}"
OLD_NAME_SNAKE="$(echo $OLD_NAME | sed -r 's/([A-Z])/_\L\1/g' | cut -c 2-)"
NEW_NAME_SNAKE="$(echo $NEW_NAME | sed -r 's/([A-Z])/_\L\1/g' | cut -c 2-)"
OLD_NAME_UPPER="$(echo $OLD_NAME | tr '[:lower:]' '[:upper:]')"
NEW_NAME_UPPER="$(echo $NEW_NAME | tr '[:lower:]' '[:upper:]')"
OLD_NAME_HUMAN="$(echo $OLD_NAME | sed -r 's/([A-Z])/\L \1/g' | cut -c 2- | sed 's/^./\U&/')"
NEW_NAME_HUMAN="$(echo $NEW_NAME | sed -r 's/([A-Z])/\L \1/g' | cut -c 2- | sed 's/^./\U&/')"

# Replace all occurrences of the old name with the new name across all project files
find . -type f \( -name "*.rb" -o -name "*.erb" -o -name "*.yml" -o -name "*.js" -o -name "*.css" \) -exec sed -i "" \
-e "s/$OLD_NAME/$NEW_NAME/g" \
-e "s/$OLD_NAME_CAMEL/$NEW_NAME_CAMEL/g" \
-e "s/$OLD_NAME_SNAKE/$NEW_NAME_SNAKE/g" \
-e "s/$OLD_NAME_UPPER/$NEW_NAME_UPPER/g" \
-e "s/$OLD_NAME_HUMAN/$NEW_NAME_HUMAN/g" {} +

# Add all files to the new repository and commit them
git add .
git commit -m "Initial commit with new project name $NEW_NAME"

echo "All references to '$OLD_NAME' have been updated to '$NEW_NAME' in all cases. New Git repository initialized."
