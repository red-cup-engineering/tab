FENNEL ?= $(TAB_ROOT)/fennel

FENNEL_TAB = TAB_ROOT="$(TAB_ROOT)" "$(FENNEL)" --add-fennel-path "$(TAB_ROOT)/?.fnl"

.DEFAULT_GOAL := verify

check:
	@command -v "$(FENNEL)" >/dev/null || { echo "TAB requires Fennel; set FENNEL=/path/to/fennel" >&2; exit 1; }
	@test -f "$(TAB_ROOT)/tab.fnl" || { echo "TAB_ROOT does not name a TAB engine: $(TAB_ROOT)" >&2; exit 1; }

verify: check
	@$(FENNEL_TAB) "$(TAB_ROOT)/tools/verify-world.fnl"

play: check
	@$(FENNEL_TAB) "$(TAB_ROOT)/tools/play-world.fnl"

serve: check
	@$(FENNEL_TAB) "$(TAB_ROOT)/tools/serve-world.fnl"

verify-network: check
	@python3 "$(TAB_ROOT)/tools/verify-network.py" "$(TAB_ROOT)" "$(FENNEL)" $(NETWORK_SCENARIO)

load: check
	@$(FENNEL_TAB) run.fnl

topology: check
	@$(FENNEL_TAB) tools/topology.fnl

.PHONY: check verify load topology play serve verify-network
