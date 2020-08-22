# LoveAudioTester

Small Lua program to test LOVE2D audio capabilities and SLAB GUI. Could be usefull or fun anyway. Now it's in early alpha phase.

<h1>FAQ</h1>
Q: How to install it?

A: For now only by download or clone the repository. See below, why. If you are infamiliar with git, I suggest following console command: `git clone --recurse-submodules https://github.com/pirogronian/LoveAudioTester LoveAudioTester`. Then `cd LoveAudioTester` and `love .`.

Q: Why I got error message "File with path \< path \> is inaccessable"?

A: Due to love.filesystem limitation only file inside source directory or save directory could be loaded. Save directory could be also inaccessable because Slab FileDialog ignores files and dirs starting with ".". That's why no .love package is provided for now. Workaround planned.

Q: How I can add a source?

A: From file item context menu. Altenratively, be sure desired file is active (showed above items tree) and go to main menu -> Sources -> New

Q: Why I had to create source separately from loading a file?

A: Because every file can have many sources with different settings.

Q: How to show details and controls sources?

A: Make sure there is selected main menu -> Windows -> Sources and click on it.

Q: What is the recent release version?

A: 0.5, but it's updated quiet frequently.

Q: What's planned next?

A: Planned, but not quaranteed: for version 0.7: listener info/control. For version 0.8: basic audio data info/control. For 0.8 or maybe along with earlier one: basic graphical presentation of spatial sources parameters. Ultimately: possibly everything related to love.audio subsystem + some tweaks around love.filesystem and Slab for better usability. Detailed tasks order is unknown, though.
