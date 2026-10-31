"""Fetch the pinned official Fusion Pixel font and bundled license notices."""
from pathlib import Path
import io
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
URL = 'https://github.com/TakWolf/fusion-pixel-font/releases/download/2026.09.01/fusion-pixel-font-12px-monospaced-otf-v2026.09.01.zip'
archive = zipfile.ZipFile(io.BytesIO(urllib.request.urlopen(URL, timeout=60).read()))
folder = ROOT / 'assets/fonts'
folder.mkdir(parents=True, exist_ok=True)
(folder / 'FusionPixel.otf').write_bytes(archive.read('fusion-pixel-12px-monospaced-zh_hans.otf'))
(folder / 'FusionPixel-OFL.txt').write_bytes(archive.read('OFL.txt'))
for source in archive.namelist():
    if source.startswith('LICENSES/') and source.endswith('.txt'):
        target = folder / 'fusion-pixel-licenses' / Path(source).relative_to('LICENSES')
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(archive.read(source))
print('Pinned Fusion Pixel 2026.09.01 font and license notices saved.')
