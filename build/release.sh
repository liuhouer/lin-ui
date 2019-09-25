git checkout master
git merge develop

echo "Select a option to release (input a serial number)："
echo

select VERSION in patch minor major "Specific Version"
  do
    echo
    if [[ $REPLY =~ ^[1-4]$ ]]; then
      if [[ $REPLY == 4 ]]; then
        read -p "Enter a specific version: " -r VERSION
        echo
        if [[ -z $REPLY ]]; then
          VERSION=$REPLY
        fi
      fi

      read -p "Release $VERSION - are you sure? (y/n) " -n 1 -r
      echo

      if [[ $REPLY =~ ^[Yy]$ || -z $REPLY ]]; 
      then
        npm run build
        
        if [[ `git status --porcelain` ]]; 
        then
          git add -A
          git commit -am "build: compile $VERSION"
        fi
        # bump version
        npm version $VERSION
        NEW_VERSION=$(node -p "require('../package.json').version")
        echo Releasing ${NEW_VERSION} ...

        # npm release

        echo "✅ Released to npm."

        # github release
        git add -A
        git commit -m "release v${NEW_VERSION}"
        git push
        git push origin refs/tags/v${NEW_VERSION}

        # async develop
        git checkout dev
        git rebase master
        git push origin dev

        echo "✅ Released to Github."
      else
        echo Cancelled
      fi
      break
    else
      echo Invalid \"${REPLY}\"
      echo "To continue, please input a serial number(1-4) of an option."
      echo
    fi
  done