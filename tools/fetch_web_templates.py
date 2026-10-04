import io,urllib.request,json,zipfile
from pathlib import Path
r=json.load(urllib.request.urlopen('https://api.github.com/repos/godotengine/godot/releases/tags/4.7.2-stable'))
a=next(a for a in r['assets'] if a['name']=='Godot_v4.7.2-stable_export_templates.tpz')
class RemoteZip(io.RawIOBase):
 def __init__(self): self.pos=0
 def seekable(self): return True
 def seek(self, offset, whence=0):
  self.pos=offset if whence==0 else (self.pos+offset if whence==1 else a['size']+offset)
  return self.pos
 def tell(self): return self.pos
 def read(self,n=-1):
  if n<0: n=a['size']-self.pos
  n=min(n,a['size']-self.pos)
  if n==0:return b''
  start=self.pos; end=start+n-1
  req=urllib.request.Request(a['browser_download_url']+f'?range={start}-{end}', headers={'Range':f'bytes={start}-{end}'})
  with urllib.request.urlopen(req,timeout=60) as res:
   if res.status!=206 or not res.headers.get('Content-Range','').startswith(f'bytes {start}-'): raise RuntimeError('Range unsupported')
   data=res.read()
  self.pos+=len(data)
  return data
with zipfile.ZipFile(RemoteZip()) as z:
 print('Available Web templates:',[i.filename for i in z.infolist() if 'web' in i.filename],flush=True)
 targets=[i for i in z.infolist() if Path(i.filename).name in ['web_nothreads_release.zip','web_nothreads_debug.zip','version.txt']]
 print([(i.filename,i.file_size,i.compress_size) for i in targets],flush=True)
 out=Path('tmp/web-templates'); out.mkdir(parents=True,exist_ok=True)
 for entry in targets:
  (out/Path(entry.filename).name).write_bytes(z.read(entry))
  print('Extracted',entry.filename,flush=True)
