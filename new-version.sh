PREVIOUS_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[1].tagName')
NEW_RELEASE=$(gh release list --repo edgee-cloud/edgee --limit 2 --json tagName --jq '.[0].tagName')
wget https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz
cp edgee.rb edgee@$PREVIOUS_RELEASE.rb
NEW_SHA256_SUM=$(sha256sum $NEW_RELEASE.tar.gz | cut -c1-64)
sed -i '' -e "s|sha256 \".*\"|sha256 \"$NEW_SHA256_SUM\"|g" ./edgee.rb
sed -i '' -e "s|url \".*\"|url \"https://github.com/edgee-cloud/edgee/archive/refs/tags/$NEW_RELEASE.tar.gz\"|g" ./edgee.rb