product:="${DSTROOT}/Applications/Open in Terminal.app"

define remove-product
  #printenv
  if [ -n '"${PS1}"' ] && [ -e ${product} ]; then rm -rf ${product}; fi
endef

build:

clean:
	$(remove-product)
    
install:
    