REBAR=$(shell which rebar || echo ./rebar)

.PHONY: rel all deps clean test

all: deps compile

compile:
	$(REBAR) compile

deps:
	./rebar get-deps

clean:
	$(REBAR) clean

test: compile
	$(REBAR) eunit

doc:
	$(REBAR) doc

