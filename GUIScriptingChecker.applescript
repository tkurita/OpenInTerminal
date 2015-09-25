global GUIScriptingCheckerBase
global _appController

on buildup()
	script GUIScriptingCheckerExtend
        property parent : GUIScriptingCheckerBase
        
        on GUIScripting_enabled()
            return _appController's GUIScriptingAllowed() as boolean
        end GUIScripting_enabled
    
    end script

    return GUIScriptingCheckerExtend
end buildup