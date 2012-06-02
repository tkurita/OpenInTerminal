global TerminalCommanderBase

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on activate_terminal()
			call method "activateAppOfIdentifier:" of class "SmartActivate" with parameter "com.apple.Terminal"
			return true
		end activate_terminal
	end script
	
	return TerminalCommanderExtend
end buildup