#!/bin/zsh

#  ci_post_clone.sh
#  Boostz
#
#  Created by Thomas Rademaker on 1/9/24.
#  

development_team_value=$DEVELOPMENT_TEAM
bundle_id_prefix_value=$BUNDLE_ID_PREFIX
alby_client_id_value=$ALBY_CLIENT_ID
alby_client_secret_vaule=$ALBY_CLIENT_SECRET

config_file_path="../User.xcconfig"

# Check for the presence of 'user.xcconfig'
if [ -f "$config_file_path" ]; then
echo "User.xcconfig exists."
else
echo "Creating User.xcconfig and populating it with environment variables"
echo "DEVELOPMENT_TEAM = $development_team_value" > "$config_file_path"
echo "BUNDLE_ID_PREFIX = $bundle_id_prefix_value" >> "$config_file_path"
echo "ALBY_CLIENT_ID = $alby_client_id_value" >> "$config_file_path"
echo "ALBY_CLIENT_SECRET = $alby_client_secret_vaule" >> "$config_file_path"
fi
