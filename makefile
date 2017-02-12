POST_SRC := $(subst ./,,$(shell find ./src/post/ -regextype posix-extended -regex '.*[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\.md'))
POST_DEST := content/post/

default: all

define POSTS_PARSE
_target := $(POST_DEST)$(shell echo $1 | grep -Po '\w+\.md')
POSTS := $$(POSTS) $$(_target)
$$(_target): $1
	date=$$$$(echo '$$<' | grep -Po '\d{4}-\d{2}-\d{2}') && \
		sed "1 adate: $$$$date" $$< > $$@;
endef

$(foreach x,$(POST_SRC),$(eval $(call POSTS_PARSE,$x)))

posts: $(POSTS)

init:
	mkdir -p content/post/

hugo:
	hugo server -w

stylus:
	node ./node_modules/stylus/bin/stylus -w -c src/stylus/ -o layouts/css/

static:
	cp -rf ./static/** ./public

cleanPosts:
	rm -rf content/post/*

cleanAll: cleanPosts
	rm -rf public/*

deploy:
	./deploy.sh

# stylus - can't figure out how to install nodejs in Bash On Ubuntu On Windows
all: cleanAll init posts static


.PHONY: all posts init cleanPosts hugo deploy cleanAll static
