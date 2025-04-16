#! /bin/bash -x

# define previous/current release variables
PREVIOUS_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[1].tagName')
PREVIOUS_RELEASE_WITHOUT_V=$(echo $PREVIOUS_RELEASE | sed -e "s/v//g")
NEW_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[0].tagName')

# download the new release and previous release tarballs so we can calculate the sha256sum
echo "::debug::Downloading latest release $NEW_RELEASE..."
wget -nv  https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz
echo "::debug::Downloading previous release $PREVIOUS_RELEASE..."
wget -nv  https://github.com/edgee-cloud/edgee/archive/refs/tags/$PREVIOUS_RELEASE.tar.gz

# calculate the sha256sum of the new release tarballs
NEW_SHA256_SUM=$(sha256sum $NEW_RELEASE.tar.gz | cut -c1-64)
PREVIOUS_SHA256_SUM=$(sha256sum $PREVIOUS_RELEASE.tar.gz | cut -c1-64)

# create a new formula file for the previous release
echo "::debug::Creating new formula file for $PREVIOUS_RELEASE..."
cp edgee.rb edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb

# update previous release formula with the correct sha256sum
# we use the re-computed SHA256 to make this script idempotent
echo "::debug::Updating $PREVIOUS_RELEASE formula with the correct sha256sum..."
sed -i -e "s|sha256 \".*\"|sha256 \"$PREVIOUS_SHA256_SUM\"|g" ./edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb
sed -i -e "s|url \".*\"|url \"https://github.com/edgee-cloud/edgee/archive/refs/tags/$PREVIOUS_RELEASE.tar.gz\"|g" ./edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb

# update edgee.rb with the latest
echo "::debug::Updating edgee.rb with the $NEW_RELEASE sha256sum..."
sed -i -e "s|sha256 \".*\"|sha256 \"$NEW_SHA256_SUM\"|g" ./edgee.rb
sed -i -e "s|url \".*\"|url \"https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz\"|g" ./edgee.rb

# clean up temporary gz files
echo "::debug::Cleaning up temporary files..."
rm $NEW_RELEASE.tar.gz
rm $PREVIOUS_RELEASE.tar.gz

# commit and push the changes to a new branch
echo "::debug::Committing and pushing..."
git config --global user.email "tech@edgee.cloud"
git config --global user.name "Edgee team"
NEW_BRANCH=gha-release-$NEW_RELEASE
git checkout -b $NEW_BRANCH
git add edgee@$PREVIOUS_RELEASE_WITHOUT_V.rb
touch test.txt
git add test.txt
git commit -a -m "Release $NEW_RELEASE"
git push origin $NEW_BRANCH

# create a pull request
echo "::debug::Creating pull request..."
gh pr create --base main --head release-$NEW_RELEASE --title "Release $NEW_RELEASE" --body "Release $NEW_RELEASE"