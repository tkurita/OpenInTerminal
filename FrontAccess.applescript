global FrontAccessBase

on buildup()
	script FrontAccessExtend
		property parent : FrontAccessBase
		
		on path_from_url(a_url)
			tell current application's class "NSURL"
				set a_url to URLWithString_(a_url)
			end tell
			return a_url's |path|() as text
		end path_from_url
		
	end script
	return FrontAccessExtend
end buildup