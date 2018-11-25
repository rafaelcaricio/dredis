export PYTHONPATH=.

DEBUG ?= --debug
FLUSHALL_ON_STARTUP ?= --flushall
PORT ?= --port 6377
TEST_OPTIONS = $(DEBUG) $(FLUSHALL_ON_STARTUP) $(PORT)
PID = dredis-test-server.pid
REDIS_PID = redis-test-server.pid

PROFILE_DIR ?= --dir /tmp/dredis-data
PROFILE_PORT = --port 6376
PROFILE_OPTIONS = $(PROFILE_DIR) $(FLUSHALL_ON_STARTUP) $(PROFILE_PORT)
STATS_FILE = stats.prof
STATS_METRIC ?= cumtime
PERFORMANCE_PID = dredis-performance-test-server.pid


fulltests:
	bash -c "trap 'make stop-testserver' EXIT; make start-testserver DEBUG=''; make test"

fulltests-real-redis:
	bash -c "trap 'make stop-redistestserver' EXIT; make start-redistestserver; make test"

test: unit integration lint

unit: setup
	@pipenv run py.test -v tests/unit

integration: setup
	@pipenv run py.test -v tests/integration

lint:
	@pipenv run flake8 .

server:
	pipenv run python -m dredis.server $(TEST_OPTIONS)

start-testserver:
	-pipenv run python -m dredis.server $(TEST_OPTIONS) 2>&1 & echo $$! > $(PID)

stop-testserver:
	@-touch $(PID)
	@-kill `cat $(PID)` 2> /dev/null
	@-rm $(PID)

setup:
	@pipenv sync --dev

start-redistestserver:
	-@redis-server $(PORT) 2>&1 & echo $$! > $(REDIS_PID)

stop-redistestserver:
	@-touch $(REDIS_PID)
	@-kill `cat $(REDIS_PID)` 2> /dev/null
	@-rm $(REDIS_PID)

redis_server:
	@mkdir -p dredis-data
	PYTHONPATH=. python -m dredis.server --dir /tmp/dredis-data --port 6379

release:
	rm -rf dist build
	python setup.py sdist bdist_wheel
	twine upload dist/*

test-performance:
	@pipenv run py.test -vvvvv -s tests-performance

performance-server:
	pipenv run python -m cProfile -o $(STATS_FILE) dredis/server.py $(PROFILE_OPTIONS)

performance-stats:
	pipenv run python -c 'import pstats ; pstats.Stats("$(STATS_FILE)").sort_stats("$(STATS_METRIC)").print_stats()' | less

clean:
	rm -rf build/ dist/
	find . -name '*.pyc' -delete
