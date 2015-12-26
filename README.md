# My nvAlt setup

## Introduction

My workflow for taking notes is based around [nvALT](http://brettterpstra.com/projects/nvalt/), a fork of [Notational Velocity](http://notational.net/) with several additional features - most usefully, a preview window which renders [Markdown formatting](https://en.wikipedia.org/wiki/Markdown).

I make several changes from the default configuration:

* To allow immediate access to my notes, I leave the application constantly running, and set a 'Bring-To-Font hotkey'  (`nvAlt -> Preferences -> Notes -> General`)
* To allow additional formatting in the preview window,  I use dg2's fork of the [nvalt-prime](https://github.com/dg2/nvalt-prime) theme  
* To facilitate the use of Git for version control, I store notes as 'Plain Text Files', rather than in a 'Single Database', and use with the extension `.md`  (options to enable both of these can be set in the Preferences: `nvAlt -> Preferences -> Notes -> Storage`. Click the plus sign to add a new extension, then the tick/check to make it the default).
* To allow quick capturing of image files or screenshots, I have automator actions that quickly move screenshots or image files into an archive folder (with subfolders for year and month), and copies the markdown needed to display them to the clipboard
* To allow indexing of my notes, I have a script which automatically scans through my notes, extracts metadata in a a particular format and converts it to an index 
* To allow access to my notes from anywhere, I `git push` to a repository on a [VPS](https://en.wikipedia.org/wiki/Virtual_private_server) running [Gollum](https://github.com/gollum) 

## Scripts

The files in this archive provide several functions. The first (`nvALT archive.workflow`) was [originally written by mjpost](https://github.com/mjpost/nvalt-files), and only slightly modified by me.

- `nvALT archive.workflow` is an Automator workflow implementing a Finder service that moves image files to a canonical location and copies a [Markdown](http://daringfireball.net/projects/markdown/)-formatted image URL to that image, enabling each incorporation of images.

- `nvALT archive screenshot.workflow` is An Automator workflow implementing a service that takes a screenshot, moves it to a canonical location and copies a [Markdown](http://daringfireball.net/projects/markdown/)-formatted image URL to that image. Before taking the screenshot, a dialog box appears to ask for the desired file name. 
Initially crosshairs will appear, allowing selection of the area to be screenshotted; pressing the space bar toggles between selecting an area or whole window. Prssing the escape button cancels without saving a screenshot.

- `nvalt-index.rb` is a ruby script which scans through a directory of notes, and emits Markdown formatting for an index page. The metadata it reads is in the format 'Key: Value\n' somewhere above a hashtag - for, example:

>Title: An interesting talk

>Speaker: Someone Famous

>Location: A large lecture theatre

>#talk

would be parsed, and appear as a row in a table under the subtitle 'Talk'. The order of the keys does not matter, and a key will appear as a column in a table even if it does not appear in every note containing the corresponding hashtag. Note that a table will not be listed if it contains only a single row. I have three hashtags: talk (title, speaker, venue), book (title, author, date read, genre), recipe (name, meal, source).

- `noteSync.sh` is the script that I run with cron: it automatically re-constructs the index page, commits changes to Git, and runs a Git push/pull with a remote repository (providing both backup and scryonization between my desktop and laptop). *It contains hard-coded paths that you will need to change for it to work*.


## Installation

0. Download and install [nvALT](http://brettterpstra.com/projects/nvalt/).

1. Install the Automator workflows by double-clicking on the filse
`nvALT archive.workflow` and `nvALT archive screenshots.workflow`. 

2. Decide the path in which you want images to be stored. Save this path in a file in your home directory called `.imgdir` (eg. by running something like `echo "/Users/post/Library/Application Support/nvALT/Media/" > ~/.imgdir` at the Terminal)

2. Install a keyboard shortcut for the workflows. Place them under System Preferences →
Keyboard → Shortcuts → App Shortcuts → All Applications. The name
should be "nvALT archive" and "nvALT archive screenshot" (exactly). I use ^⌘a as my shortcut for the "nvALT archive" workflow.

   Now, on any image file in Finder, you can click this shortcut (or
   select it from the Finder Services menu. The image will be copied
   to a directory within `/{YEAR}/{MONTH}` under the directory specified in `.imgdir`, and a Markdown-formatted relative path to this
   file will be placed on the clipboard, to be pasted into your nvALT document.

### Preview template

You may also wish to enhance the default template by installing a theme such as dg2's fork of the [nvalt-prime](https://github.com/dg2/nvalt-prime) theme.

Whether you do this or not, you will need to [set an all-purpose base path](http://brettterpstra.com/2012/09/27/quick-tip-images-in-nvalt/) to the template in order to have images displayed in the preview. This path should be to the directory you set in your `.imgdir` file.

### Git

To initialise a Git repository, open a terminal, `cd` into the directroy containing your notes, and run `git init && git commit -m "Initial commit"`.

You could use a private github repository could be used as a remote, or run a [Git server](https://git-scm.com/book/en/v1/Git-on-the-Server) yourself. 

### Cron

[Cron](https://en.wikipedia.org/wiki/Cron) is a tool that runs jobs at scheduled times. To run `nvalt-index.rb`  every 20 minutes, open a terminal, run `crontab -e`, and add the following line

    */20    *       *       *       *       ~/code/backupScripts/noteSync.sh >> /dev/null

(changing the path as necessary)
