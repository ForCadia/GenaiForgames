from pathlib import Path
import subprocess,array,math,json,concurrent.futures
ff=Path('tmp/video-tools/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe').resolve()
paths=list(Path('assets/sfx').glob('*.wav'))+list(Path('assets/sfx').glob('*.mp3'))+list(Path('assets/music').glob('*.mp3'))
def analyze(p):
 data=subprocess.check_output([str(ff),'-v','error','-i',str(p),'-ac','2','-ar','24000','-f','f32le','-'])
 a=array.array('f');a.frombytes(data); peak=max(abs(x) for x in a)
 chunks=[(sum(x*x for x in a[i:i+2400])/len(a[i:i+2400]),len(a[i:i+2400])) for i in range(0,len(a),2400)]
 max_energy=max(x for x,n in chunks);active=[(x,n) for x,n in chunks if x>=max_energy/1000]
 rms=math.sqrt(sum(x*n for x,n in active)/sum(n for x,n in active))
 return {'file':str(p).replace('\\','/'),'seconds':round(len(a)/48000,3),'peak_db':round(20*math.log10(peak),2),'active_rms_db':round(20*math.log10(rms),2)}
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool: results=list(pool.map(analyze,paths))
Path('tmp/audio_levels.json').write_text(json.dumps(results,indent=2))
for r in results:print(r)

