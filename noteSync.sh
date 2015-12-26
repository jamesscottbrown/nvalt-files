#!/usr/bin/env sh
cd ~/Notes
export SSH_AUTH_SOCK=$( ls /private/tmp/com.apple.launchd.*/Listeners )
git pull origin master > /dev/null

export LANG=en_GB.UTF-8
/Users/jsb/code/nvalt-files/nvalt-index.rb --tabulate --dir=/Users/jsb/Notes > /Users/jsb/Notes/Index.md
/Users/jsb/code/nvalt-files/nvalt-index.rb --links --dir=/Users/jsb/Notes | /usr/local/bin/circo -Tpng -o /Users/jsb/Notes/img/links.png

git add -A > /dev/null
git commit -a -m "Auto commit" > /dev/null
git push origin master > /dev/null
