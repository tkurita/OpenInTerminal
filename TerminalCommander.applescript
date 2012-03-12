global TerminalCommanderBase

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on activate_terminal()
			call method "activateAppOfIdentifier:" of class "SmartActivate" with parameter "com.apple.Terminal"
			return true
		end activate_terminal
		
		on support_working_directory(flag)
			if not flag then
				set my set_working_directory to my set_custom_title_for_path
			end if
		end support_working_directory
	end script
	
	return TerminalCommanderExtend
end buildup