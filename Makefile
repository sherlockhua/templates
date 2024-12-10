gen:
	openapi-generator generate --template-dir ./  -g go-server  -i ./pet.yaml
	rm -rf go/*_service.go
gen2:
	openapi-generator generate   -g go-gin-server  -i ./pet.yaml -o output
