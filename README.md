# LoveAudioTester

Small Lua program to test LOVE2D audio capabilities and SLAB GUI. Could be usefull or fun anyway. Now it's in early alpha phase.

<h1>FAQ</h1>
Q: How to install it?

A: For now only by download or clone the repository. See below, why.

Q: Why I got error message "File with path \< path \> is inaccessable"?

A: Due to love.filesystem limitation only file inside source directory or save directory could be loaded. Save directory could be also inaccessable because Slab FileDialog ignores files and dirs starting with ".". That's why no .love package is provided for now. Workaround planned.

Q: How I can add a source?

A: Be sure desired file is active (showed above items tree) and go to Filepaths -> Sources -> New

Q: Why I had to create source separately from loading a file?

A: Because it's planned to deal with many sources per file with different settings. For now it could looks useless.

Q: How to use sources?

A: Click on it and go to Filepaths -> Sources -> Info, or vice versa. Yes, there will be easier way.

Q: What's planned next?

A: Possibly everything related to love.audio subsystem + some tweaks around love.filesystem and Slab for better usability. Detailed tasks order is unknown, though.
