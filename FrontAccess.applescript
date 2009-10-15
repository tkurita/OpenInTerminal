global FrontAccessBase

on buildup()
	script FrontAccessExtend
		property parent : FrontAccessBase
		
		on path_from_url(a_url)
			set url_obj to call method "URLWithString:" of class "NSURL" with parameter a_url
			return call method "path" of url_obj
		end path_from_url
		
	end script
	return FrontAccessExtend
end buildup