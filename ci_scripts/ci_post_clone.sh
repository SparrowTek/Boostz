#!/bin/sh

#  ci_post_clone.sh
#  Boostz
#
#  Created by Thomas Rademaker on 1/9/24.
#  

development_team_value=$DEVELOPMENT_TEAM
bundle_id_prefix_value=$BUNDLE_ID_PREFIX
alby_client_id_value=$ALBY_CLIENT_ID
alby_client_secret_vaule=$ALBY_CLIENT_SECRET

# Check for the presence of 'user.xcconfig'
if [ -f "user.xcconfig" ]; then
echo "user.xcconfig exists."
else
echo "Creating user.xcconfig and populating it with environment variables"
echo "DEVELOPMENT_TEAM = $development_team_value" > user.xcconfig
echo "BUNDLE_ID_PREFIX = $bundle_id_prefix_value" >> user.xcconfig
echo "ALBY_CLIENT_ID = $alby_client_id_value" >> user.xcconfig
echo "ALBY_CLIENT_SECRET = $alby_client_secret_vaule" >> user.xcconfig
fi
