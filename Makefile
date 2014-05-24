COFFEE := coffee
COFFEE_FLAGS := --compile
SASS   := node-sass

# Web assets
WEB  := web/modules.coffee $(shell find web -name "*.coffee")
SASS := $(shell find stylesheets -name "*.scss")

ASSETS := public/js/app.js public/css/app.css

.PHONY: all clean rebuild start deploy

# Starts dev server
start:
	nodemon -i web -i stylesheets app/app.coffee

# Compiles resources
deploy: bower all

# Installs bower deps
bower: bower.json
	bower install

# Phony all target
all: $(ASSETS)
	@-echo "Finished building classy-cate"

# Phony clean target
clean:
	@-echo "Cleaning all assets"
	@-rm -f $(ASSETS)

# Phony rebuild target
rebuild: clean all

# Compile js assets
public/js/app.js: $(WEB)
	@-echo "Compiling web js asset $@"
	@$(COFFEE) -cj $@ $^

# Compile css assets
public/css/app.css: $(SASS)
	@-echo "Compiling stylesheet asset $@"
	@$(COFFEE) ./app/midware/styles.coffee stylesheets $@

# Rule for all other coffee files
$(OUT_DIR)/%.js: $(SRC_DIR)/%.coffee
	@-echo "  Compiling $@"
	@$(COFFEE) $(COFFEE_FLAGS) -o $(shell dirname $@) $^

