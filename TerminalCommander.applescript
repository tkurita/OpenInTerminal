global TerminalCommanderBase
global NSRunningApplication

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on activate_terminal()
            NSRunningApplication's activateAppOfIdentifier_("com.apple.Terminal") as boolean
		end activate_terminal
	end script
	
	return TerminalCommanderExtend
end buildup