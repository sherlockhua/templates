destdir = example
current_dir=$(shell pwd)
$(echo $(current_dir))
last_part=$(shell basename "$current_dir")
gen:
	openapi-generator generate --template-dir ./  -g go-server  -i ./pet.yaml -o $(destdir)
	rm -rf $(destdir)/go/*_service.go
	cp -r configs $(destdir)/
	sed -i 's#github.com/GIT_USER_ID/GIT_REPO_ID/go#$(last_part)#g' ./$(destdir)/main.go
	sed -i 's#github.com/GIT_USER_ID'
gen2:
	openapi-generator generate   -g go-gin-server  -i ./pet.yaml -o output
