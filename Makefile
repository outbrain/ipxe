default:
	./build.sh all

push:
	./build.sh push

all:
	./build.sh all
	./build.sh push
