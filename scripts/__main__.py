from pathlib import Path
from shutil import rmtree

import pandas as pd
from tqdm import tqdm
from sqlalchemy import create_engine

from .util import download_if_not_exist, unzip


def main():
    base_path = Path("./downloaded_data")

    with create_engine(
        "mysql+pymysql://root:@localhost:3307/eleicoes"
    ).connect() as con:
        for table in [
            # candidatos
            "consulta_cand",
            "bem_candidato",
            "consulta_coligacao",
            "consulta_vagas",
            "motivo_cassacao",

            # # eleitorado
            # "perfil_eleitorado",

            # resultados
            "votacao_candidato_munzona",
            "votacao_partido_munzona",
        ]:
            url = f"http://agencia.tse.jus.br/estatistica/sead/odsele/{table}/{table}_2018.zip"
            generic(con=con, table=table, base_path=base_path, url=url)

        # # weird url special case
        # table = "perfil_eleitor_deficiente"
        # url = "http://agencia.tse.jus.br/estatistica/sead/odsele/perfil_eleitor_deficiente/perfil_eleitor_deficiencia_2018.zip"
        # generic(con=con, table=table, base_path=base_path, url=url)


def generic(*, con, table, base_path, url):
    base_path = Path(base_path)
    table_path = base_path / table
    temp_path = table_path / "temp"
    zip_file = temp_path / f"{table}_2018.zip"

    print()
    print()
    print(f"Preparing table `{table}`")
    if len(pd.read_sql(f"SHOW TABLES LIKE '{table}'", con=con)) == 1:
        print(f"Table `{table}` already exists")
        return

    print()
    print()
    download_if_not_exist(url=url, file=zip_file)

    print()
    print()
    unzip(zip_file)
    for file in temp_path.iterdir():
        if file.suffix == ".pdf":
            file.rename(table_path / file.name)

    print()
    print()
    print("Loading files")
    df = pd.concat(
        pd.read_csv(file, encoding="latin1", sep=";")
        for file in Path(zip_file).parent.iterdir()
        if file.suffix == ".csv"
    )

    print()
    print()
    print("Removing duplicates")
    df = df.drop_duplicates()

    print()
    print()
    print("Adding to database")
    _ldf = len(df)
    _range = list(range(0, _ldf, 5000))
    _slices = list(map(slice, _range, _range[1:] + [_ldf + 1]))

    for s in tqdm(_slices):
        df.iloc[s].to_sql(table, con=con, index=None, if_exists="append")

    print()
    print()
    print("Cleaning temp")
    rmtree(temp_path)

    print()
    print()
    print(f"Done `{table}`")


main()
