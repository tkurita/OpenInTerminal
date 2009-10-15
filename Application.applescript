property loader : proxy() of application (get "OpenInTerminalLib")

on load(a_name)
	return loader's load(a_name)
end load

property InsertionLocator : load("InsertionLocator")
property TerminalCommanderBase : load("TerminalCommander")
property XFile : load("XFile")
property FrontAccessBase : load("FrontAccess")
property GUIScriptingChecker : load("GUIScriptingChecker")
property FrontAccess : missing value
property TerminalCommander : missing value
property MessageDelegate : missing value

on initialize()
	tell InsertionLocator
		set_allow_package_contents(true)
		set_use_gui_scripting(false)
	end tell
end initialize

property _ : initialize()

on import_script(script_name)
	tell main bundle
		set script_path to path for script script_name extension "scpt"
	end tell
	return load script POSIX file script_path
end import_script

on is_need_TerminalControl()
	set sysver to system version of (get system info)
	considering numeric strings
		set a_result to (sysver is greater than or equal to "10.6")
		if not a_result then
			set a_result to sysver is less than or equal to "10.5.6"
		end if
	end considering
	
	return a_result
end is_need_TerminalControl

on setup()
	if MessageDelegate is missing value then
		set MessageDelegate to import_script("MessageDelegate")
		GUIScriptingChecker's set_delegate(MessageDelegate)
		set FrontAccess to buildup() of (import_script("FrontAccess"))
		set TerminalCommander to buildup() of (import_script("TerminalCommander"))
		
		set info_dict to call method "infoDictionary" of main bundle
		TerminalCommander's set_use_osax_for_customtitle(is_need_TerminalControl())
	end if
end setup

on submain()
	set a_front to make FrontAccess
	if (("com.apple.finder" is a_front's bundle_identifier()) or (a_front's is_current_application())) then
		set a_location to do() of InsertionLocator
		if a_location is missing value then
			activate
			display alert "Can't get selected location in Finder."
			return false
		end if
	else
		if not do() of GUIScriptingChecker then
			return
		end if
		set a_location to XFile's make_with(a_front's document_alias())
		if not a_location's is_folder() or a_location's is_package() then
			set a_location to a_location's parent_folder()
		end if
		set a_location to a_location's as_alias()
	end if
	
	return open_location(POSIX path of a_location)
end submain

on process_for_context()
	try
		setup()
		submain()
	on error msg number errno
		activate
		display alert msg message "Error Number : " & errno
	end try
end process_for_context

on open_location(a_location)
	set a_commander to make TerminalCommander
	tell a_commander
		set_custom_title_for_path(a_location)
		set a_location to quoted form of a_location
		do_command for "cd " & a_location with activation
	end tell
	
	return true
end open_location

on process_pathes(a_list)
	set a_path to item 1 of a_list
	set a_list to rest of a_list
	if a_path is not in a_list then
		open_location(a_path)
	end if
	if length of a_list > 0 then
		process_pathes(a_list)
	end if
end process_pathes

on service_for_pathes(a_list)
	set pathlist to {}
	try
		setup()
		repeat with a_path in a_list
			set a_xfile to XFile's make_with(POSIX file a_path)
			tell a_xfile
				if not is_folder() or is_package() then
					set a_xfile to parent_folder()
				end if
			end tell
			set end of pathlist to a_xfile's posix_path()
		end repeat
		return process_pathes(pathlist)
	on error errMsg
		activate
		display alert errMsg
	end try
end service_for_pathes
