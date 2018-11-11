SRC := src


.PHONY: install database lab


install:
	poetry install


# ===== This section prepares the data tables ====
tables_names := consulta_cand bem_candidato consulta_coligacao \
	consulta_vagas motivo_cassacao votacao_candidato_munzona \
	votacao_partido_munzona
table_url = http://agencia.tse.jus.br/estatistica/sead/odsele/$(1)/$(1)_2018.zip
table_zip_file = tables/$(1)/$(1)_2018.zip


.PHONY: tables


tables: $(foreach table,$(tables_names),$(call table_zip_file,$(table)))


# $(1): table zip file
# $(2): table url
define PREPARE_TABLE_RULE
$(1):
	mkdir -p $(shell dirname $(1))
	wget -O $(1) $(2)
	unzip -o -d $(shell dirname $(1)) $(1)
endef
$(foreach table,$(tables_names),\
	$(eval $(call PREPARE_TABLE_RULE,\
					$(call table_zip_file,$(table)),\
					$(call table_url,$(table))\
	))\
)
# ========


# ===== This section prepares the maps ====
.PHONY: maps

maps: maps/br_municipios.topo.json

maps/br_municipios.topo.json: maps/BRMUE250GC_SIR.shp
	@echo converting to topojson
	mapshaper snap $^ \
		-rename-layers municipios \
		-simplify 1% -filter-islands remove-empty min-area=1e8 \
		-o format=topojson $@

.SECONDARY: maps/BRMUE250GC_SIR.shp

maps/BRMUE250GC_SIR.shp: maps/br_municipios.zip
	unzip -o $^ -d $(shell dirname $@)
	touch $@

.INTERMEDIATE: maps/br_municipios.zip

maps/br_municipios.zip:
	mkdir -p $(shell dirname $@)
	wget -O $@ \
		'ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2017/Brasil/BR/br_municipios.zip'
# ========


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
