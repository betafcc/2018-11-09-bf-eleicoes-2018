import dask.dataframe as dd


bem_candidato = dd.read_csv(
    "./tables/bem_candidato/bem_candidato_2018_BRASIL.csv", encoding="latin1", sep=";"
)

consulta_cand = dd.read_csv(
    "./tables/consulta_cand/consulta_cand_2018_BRASIL.csv", encoding="latin1", sep=";"
)

consulta_coligacao = dd.read_csv(
    "./tables/consulta_coligacao/consulta_coligacao_2018_BRASIL.csv",
    encoding="latin1",
    sep=";",
)

consulta_vagas = dd.read_csv(
    "./tables/consulta_vagas/consulta_vagas_2018_BRASIL.csv",
    encoding="latin1",
    sep=";",
)

motivo_cassacao = dd.read_csv(
    "./tables/motivo_cassacao/*.csv", encoding="latin1", sep=";"
)

votacao_candidato_munzona = dd.read_csv(
    "./tables/votacao_candidato_munzona/*.csv", encoding="latin1", sep=";"
)

votacao_partido_munzona = dd.read_csv(
    "./tables/votacao_partido_munzona/*.csv", encoding="latin1", sep=";"
)
