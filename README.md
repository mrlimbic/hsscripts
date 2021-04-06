# Hammerspoon VCL scripts

script that interprets vordio change lists (.vcl) files & applies the changes
in the list to various DAWs by sending keystrokes to the DAW.

Currently supported DAWs are Protools, Studio One, Digital Performer & Logic Pro X

# Instructions

Requires Hammerspoon app http://www.hammerspoon.org/

Requires a VCL file produced by Vordio app http://vordio.net/reconform

Load the init.lua file as a configuration file for hammerspooon.

# DAW configuration

Navigation:

	NOTE: All positioning is done via timecodes, so project positioning must be set to use frames at correct frame rate
	Some DAWs require some extra custom key mappings

Key bindings:

	Protools - default keys only
	StudioOne - default keys only
	Digital Performer - default keys only
	
	Logic Pro X - Map the following keys to actions
		cmd-shift-c -> "Copy section between locators (Global)"
		cmd-shift-[ -> "Set Left Locator Numerically"
		shift-/ 	-> "Go to Position"
