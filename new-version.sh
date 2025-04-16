#! /bin/bash -x

# define previous/current release variables
PREVIOUS_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[1].tagName')
PREVIOUS_RELEASE_WITHOUT_V=$(echo $PREVIOUS_RELEASE | sed -e "s/v//g")
NEW_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[0].tagName')

# download the new release and previous release tarballs so we can calculate the sha256sum
echo "Downloading latest release $NEW_RELEASE..."
wget -nv  https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz
echo "Downloading previous release $PREVIOUS_RELEASE..."
wget -nv  https://github.com/edgee-cloud/edgee/archive/refs/tags/$PREVIOUS_RELEASE.tar.gz

# calculate the sha256sum of the new release tarballs
NEW_SHA256_SUM=$(sha256sum $NEW_RELEASE.tar.gz | cut -c1-64)
PREVIOUS_SHA256_SUM=$(sha256sum $PREVIOUS_RELEASE.tar.gz | cut -c1-64)

# create a new formula file for the previous release
echo "Creating new formula file for $PREVIOUS_RELEASE..."
cp edgee.rb edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb

# sed works with -i on Ubuntu and with -i '' on MacOS
SEDOPTION="-i"
if [[ "$OSTYPE" == "darwin"* ]]; then
    SEDOPTION="-i ''"
fi

# update previous release formula with the correct sha256sum
# we use the re-computed SHA256 to make this script idempotent
echo "Updating $PREVIOUS_RELEASE formula with the correct sha256sum..."
sed $SEDOPTION -e "s|sha256 \".*\"|sha256 \"$PREVIOUS_SHA256_SUM\"|g" ./edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb
sed $SEDOPTION -e "s|url \".*\"|url \"https://github.com/edgee-cloud/edgee/archive/refs/tags/$PREVIOUS_RELEASE.tar.gz\"|g" ./edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb

# update edgee.rb with the latest
echo "Updating edgee.rb with the $NEW_RELEASE sha256sum..."
sed $SEDOPTION -e "s|sha256 \".*\"|sha256 \"$NEW_SHA256_SUM\"|g" ./edgee.rb
sed $SEDOPTION -e "s|url \".*\"|url \"https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz\"|g" ./edgee.rb

# clean up temporary gz files
echo "Cleaning up temporary files..."
rm $NEW_RELEASE.tar.gz
rm $PREVIOUS_RELEASE.tar.gz

# commit and push the changes to a new branch
echo "Committing and pushing..."
git checkout -b release-$NEW_RELEASE
git commit -a -m "Release $NEW_RELEASE"
git push origin release-$NEW_RELEASE

# create a pull request
echo "Creating pull request..."
gh pr create --base main --head release-$NEW_RELEASE --title "Release $NEW_RELEASE" --body "Release $NEW_RELEASE"