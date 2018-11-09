from pathlib import Path
from subprocess import run


def mkdirp(path):
    Path(path).mkdir(parents=True, exist_ok=True)


def download_if_not_exist(*, url, file):
    file_path = Path(file)

    if file_path.exists():
        print('Requested download file already exists:', str(file))
        return

    mkdirp(file_path.parent)
    download(url=url, file=file)


def download(*, url, file):
    run(['wget', '-O', str(file), url])


def unzip(file):
    run(['unzip', '-o', '-d', str(Path(file).parent), str(file)])
