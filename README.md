### nvALT configuration files

I use nvALT extensively for research notes.  The files in this archive
provide these functions:

- An Automator workflow implementing a Finder service that archives
  image files to a canonical location and copies a
  [Markdown](http://daringfireball.net/projects/markdown/)-formatted
  image URL to that image, enabling each incorporation of images.

### Installation

0. Download and install [nvALT](http://brettterpstra.com/projects/nvalt/).

1. Install the Automator workflow by double-clicking on the file
`nvALT archive.workflow`. 

2. Install a keyboard shortcut for the workflow. Place it under System Preferences →
Keyboard → Shortcuts → App Shortcuts → All Applications. The name
should be "nvALT archive" (exactly). I use ^⌘a as my shortcut.

   Now, on any image file in Finder, you can click this shortcut (or
   select it from the Finder Services menu. The image will be copied
   to a directory within `$HOME/Library/Application
   Support/nvALT/Media/{YEAR}/{MONTH}`, and a Markdown-formatted relative path to this
   file will be placed on the clipboard, to be pasted into your nvALT document.
