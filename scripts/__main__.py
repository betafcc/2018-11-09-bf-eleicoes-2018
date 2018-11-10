from pathlib import Path

import pandas as pd

from .util import download_if_not_exist, unzip


def main():
    base_path = Path("./tables")

    for table in [
        # candidatos
        "consulta_cand",
        "bem_candidato",
        "consulta_coligacao",
        "consulta_vagas",
        "motivo_cassacao",

        # resultados
        "votacao_candidato_munzona",
        "votacao_partido_munzona",
    ]:
        url = f"http://agencia.tse.jus.br/estatistica/sead/odsele/{table}/{table}_2018.zip"
        generic(table=table, base_path=base_path, url=url)


def generic(*, table, base_path, url):
    base_path = Path(base_path)
    table_path = base_path / table
    zip_file = table_path / f"{table}_2018.zip"


    if table_path.exists():
        print(f"Already prepared `{table}`")
        return

    print(f"Preparing table `{table}`")
    print()
    print()
    download_if_not_exist(url=url, file=zip_file)

    print()
    print()
    unzip(zip_file)

    print()
    print()
    print("Cleaning zip file")
    zip_file.unlink()

    print()
    print()
    print(f"Done `{table}`")


main()
