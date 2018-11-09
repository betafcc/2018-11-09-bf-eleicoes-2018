SRC := src


.PHONY: install database lab


install:
	poetry install


database:
	docker-compose up -d
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
