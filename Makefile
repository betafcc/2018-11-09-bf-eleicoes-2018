SRC := src


.PHONY: install database lab


install:
	poetry install


database:
	docker-compose up -d

	# FIXME: use better way to wait for mysql in docker
	for i in $$(seq 10); \
	do \
		nc -z -v localhost 3307; \
		if [ $$? -eq 0 ]; then \
			break; \
		else \
			sleep 3; \
		fi \
	done
	sleep 20

	# while ! docker exec eleicoes_db mysqladmin --user=root --host "127.0.0.1" ping --silent &> /dev/null ; do \
	#     echo "Waiting for database connection..."; \
	#     sleep 2; \
	# done

	poetry run python -m scripts
	docker-compose down


init:
	sed -i "s/{{NAME}}/$${NAME:-$$(basename $$(pwd))}/" pyproject.toml
	sed -i "s/{{AUTHOR}}/$${AUTHOR:-$$(git config user.name) <$$(git config user.email)>}/" pyproject.toml


lab:
	poetry run jupyter lab .


.PHONY: validate lint typecheck test clean


validate:
	$(MAKE) lint && \
	$(MAKE) typecheck && \
	$(MAKE) test


lint:
	@echo "\n\n" ======== $@ ========= "\n\n"
	poetry run flake8


typecheck:
	@echo "\n\n" ======== $@ ========= "\n\n"
	poetry run mypy $(SRC)


test:
	@echo "\n\n" ======== $@ ========= "\n\n"
	poetry run pytest


clean:
	find . -type d | grep -P '(\.mypy_cache$$|__pycache__$$|\.pytest_cache$$)' | xargs rm -rf
