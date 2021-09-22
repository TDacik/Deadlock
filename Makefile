make:
	$(MAKE) -C src

setup install uninstall clean test unit-tests:
	$(MAKE) -C src $@

doc:
	$(MAKE) -C src odoc


.PHONY: docker
docker:
	docker build -t deadlock docker/deadlock
	docker run -it deadlock
