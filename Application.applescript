script AppControlScript
	property parent : class "NSObject"
	
	property InsertionLocator : module
	property TerminalCommanderBase : module "TerminalCommander"
	property XFile : module
	property XText : module
	property GUIScriptingCheckerBase : module "GUIScriptingChecker"
	property loader : boot (module loader of application (get "OpenInTerminalLib")) for me

	property TerminalCommander : missing value
	property GUIScriptingChecker : missing value
    
	property NSURL : class "NSURL"
    property NSRunningApplication : class "NSRunningApplication"
    property TXFrontAccess : class "TXFrontAccess"
	
    property _appController : missing value
    property _sysver : missing value
    
	on return_true()
		return true
	end return_true
	
	on import_script(a_name)
		--log "start import_script : "&a_name
		set a_script to load script (path to resource a_name & ".scpt")
		return a_script
	end import_script
	
	on is_need_TerminalControl(sysver)
		considering numeric strings
			set a_result to (sysver is greater than or equal to "10.6")
			if not a_result then
				set a_result to sysver is less than or equal to "10.5.6"
			end if
		end considering
		
		return a_result
	end is_need_TerminalControl

	on is_lion_or_later(sysver)
		considering numeric strings
			return sysver is greater than or equal to "10.7"
		end considering
	end is_lion_or_later

	on check_osax()
		try
			set term_control_ver to TerminalControl version
		on error
			activate
			display alert (localized string "Install TerminalControl.osax")
			return false
		end try
		
		set required_ver to "1.3"
		considering numeric strings
			if term_control_ver is less than required_ver then
				set ver_info to localized string "The installed version : $1, the required version : $2"
				set msg to XText's formatted_text(ver_info, {term_control_ver, required_ver})
				activate
				display alert (localized string "Upgrade of TerminalControl.osax is required") message msg
				return false
			end if
		end considering
		return true
	end check_osax

	on setup()
		if not check_osax() then
			quit
			return false
		end if
		
		tell InsertionLocator
			set_allow_package_contents(true)
			set_use_gui_scripting(false)
		end tell

		set TerminalCommander to import_script("TerminalCommander")'s buildup()
		set GUIScriptingChecker to import_script("GUIScriptingChecker")'s buildup()
		set my _sysver to system version of (get system info)
		TerminalCommander's set_use_osax_for_customtitle(is_need_TerminalControl(my _sysver))
		set my setup to my return_true
		return true
	end setup

	on location_for_safari()
        --log "start location_for_safari"
		set a_url to missing value
		tell application "Safari"
			tell front document
				if exists then
					set a_url to URL
				end if
			end tell
		end tell
		
        if a_url is missing value then
			set msg to localized string "No document in Safari."
			error msg number 1110
		end if
		
		if a_url starts with "file://" then
			set a_path to NSURL's URLWithString_(a_url)'s |path|()
		else
			set msg to XText's formatted_text(localized string "The scheme of $1 is not 'file'.", {quoted form of a_url})
			error msg number 1110
			return missing value
		end if
		
        if not (a_path's fileExists() as boolean) then
			set msg to XText's formatted_text(localized string "$1 is not found.", {quoted form of a_path as text})
			error msg number 1110
			return missing value
		end if
        
		if not (a_path's isFolder() as boolean) then
			set a_path to a_path's stringByDeletingLastPathComponent()
		end if
		
		return a_path as text
	end location_for_safari
    
    on checkGUIScripting()
		log "start checkGUIScripting"
		tell GUIScriptingChecker
            considering numeric strings
                set is_mavericks to (_sysver is greater than or equal to "10.9")
            end considering
			if is_mavericks then
				script MessageProvider109
                    on ok_button()
                        return localized string "Open System Preferences"
                    end ok_button
            
                    on cancel_button()
                        return localized string "Deny"
                    end cancel_button
        
                    on title_message()
                        set a_format to localized string "need accessibility"
                        return XText's formatted_text(a_format, {name of current application})
                    end title_message
            
                    on detail_message()
                        return localized string "Grant access"
                    end detail_message
                end script
                set_delegate(MessageProvider109)
            else
                localize_messages()
            end if
        end tell
        --log "will end checkGUIScripting"
        return GUIScriptingChecker's do()
    end checkGUIScripting

	on submain()
        set a_front to TXFrontAccess's frontAccessForFrontmostApp()
		set front_app_id to a_front's bundleIdentifier() as text
		if (("com.apple.finder" is front_app_id) or (a_front's isCurrentApplication() as boolean)) then
            if my _sysver starts with "10.8" then -- 10.8's Finder can't obtain new window's insertion location
                activate
                activate application "Finder"
            end if
			set a_location to do() of InsertionLocator
			if a_location is missing value then
				activate
				display alert "Can't get selected location in Finder."
				return false
			end if
			set a_location to POSIX path of a_location
		else if "com.apple.Safari" is front_app_id then
			set a_location to location_for_safari()
			if a_location is missing value then
				return false
			end if
		else
			if not checkGUIScripting() then
				return
			end if
			set a_location to XFile's make_with(a_front's documentURL()'s |path|() as text)
			if not a_location's is_folder() or a_location's is_package() then
				set a_location to a_location's parent_folder()
			end if
			set a_location to a_location's posix_path()
		end if
        
		return open_location(a_location)
	end submain
    
	on processForContext()
		--log "start processForContext"
		try
			if not setup() then return
			submain()
		on error msg number errno
			activate
			display alert msg message "Error Number : " & errno
		end try
	end processForContext

	on open_location(a_location)
        --log "start open_location"
		tell make TerminalCommander
			set_working_directory(a_location)
			set a_location to quoted form of a_location
			do_command for "cd " & a_location with activation
		end tell
		return true
	end open_location
    
	on process_pathes(a_list)
		--log "start process_pathes"
		set a_path to item 1 of a_list
		set a_list to rest of a_list
		if a_path is not in a_list then
			open_location(a_path)
		end if
		if length of a_list > 0 then
			process_pathes(a_list)
		end if
	end process_pathes

	on serviceForPathes_(a_list)
		-- log "start serviceForPathes_"
		set pathlist to {}
		try
			if not setup() then return
			repeat with a_path in a_list
				set a_xfile to XFile's make_with((a_path as text) as POSIX file)
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
	
	on awakeFromNib()
		-- log "start awakeFromNib"
		setup()
	end awakeFromNib
end script