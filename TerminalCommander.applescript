global TerminalCommanderBase

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on activate_terminal()
			tell current application's class "NSRunningApplication"
				return activateAppOfIdentifier_("com.apple.Terminal") as boolean
			end tell
		end activate_terminal
	end script
	
	return TerminalCommanderExtend
end buildup