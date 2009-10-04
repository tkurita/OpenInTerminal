property InsertionLocator : missing value
property TerminalCommander : missing value
property XFile : missing value
property FrontAccess : missing value
property GUIScriptingChecker : missing value

on load_modules(loader)
	tell loader
		set my InsertionLocator to load("InsertionLocator")
		set my TerminalCommander to load("TerminalCommander")
		set my XFile to load("XFile")
		set my FrontAccess to load("FrontAccess")
		set my GUIScriptingChecker to load("GUIScriptingChecker")
	end tell
end load_modules

on initialize()
	load_modules(proxy_with({autocollect:true}) of application (get "OpenInTerminalLib"))
	tell InsertionLocator
		set_allow_package_contents(true)
		set_use_gui_scripting(false)
	end tell
end initialize

property _ : initialize()

on current_app_name()
	set a_result to ""
	try
		set a_result to name of current application
	on error
		try
			set a_result to short name of (info for (path to current application))
		end try
	end try
	if a_result ends with ".app" then
		set a_result to text 1 thru -5 of a_result
	end if
	return a_result
end current_app_name

on submain()
	set a_front to make FrontAccess
	set front_app_name to a_front's application_name()
	set c_app to current_app_name()
	if (front_app_name is in {"Finder", c_app}) then
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
	--log "start process in process_for_context"
	try
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
