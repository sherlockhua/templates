gen:
	current_dir=$(pwd)
	last_part=$(basename "$current_dir")
	openapi-generator generate --template-dir ./  -g go-server  -i ./pet.yaml
	rm -rf go/*_service.go
	sed 's/github.com/GIT_USER_ID/GIT_REPO_ID/go/$last_part/g' ./main.go
gen2:
	openapi-generator generate   -g go-gin-server  -i ./pet.yaml -o output
