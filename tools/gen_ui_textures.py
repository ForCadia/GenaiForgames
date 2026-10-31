"""Generate original, nearest-filtered industrial UI artwork (Pillow tooling only)."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tmp/ui-tools'))
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[1] / 'ui/textures'
OUT.mkdir(parents=True, exist_ok=True)
def panel(name, fill, edge):
    im = Image.new('RGBA', (24, 24))
    d = ImageDraw.Draw(im)
    d.polygon([(6,0),(17,0),(23,6),(23,17),(17,23),(6,23),(0,17),(0,6)], fill=edge)
    d.polygon([(7,2),(16,2),(21,7),(21,16),(16,21),(7,21),(2,16),(2,7)], fill=fill)
    im.save(OUT / (name + '.png'))
panel('panel_chamfer', '#0B111AEE', '#3A4756')
for name, fill, edge in [('normal','#121A26','#3A4756'),('hover','#1B2636','#FFB32E'),('pressed','#3C301C','#FFB32E'),('focus','#1B2636','#FFB32E'),('disabled','#0B111A','#222B38')]:
    panel('button_'+name, fill, edge)
im = Image.new('RGBA',(8,8),'#0B111A')
for x in range(8):
    for y in range(8):
        if (x+y)%8 < 4: im.putpixel((x,y),(255,179,46,255))
im.save(OUT/'hazard_stripe.png')
for name in ['shield','rifle','piercer','grenade','speaker','muted']:
    im = Image.new('RGBA',(24,24)); d = ImageDraw.Draw(im); c='#E8EEF5'
    if name=='shield': d.polygon([(4,3),(19,3),(18,15),(12,22),(5,15)],outline=c,width=2)
    elif name in ('rifle','piercer'):
        d.rectangle((3,8,17,12),fill=c); d.rectangle((17,9,23,10),fill=c)
        d.rectangle((8,13,11,18),fill=c); d.rectangle((1,9,4,15),fill=c)
        if name=='piercer': d.rectangle((10,4,17,6),fill=c)
    elif name=='grenade':
        d.ellipse((6,8,18,22),outline=c,width=2); d.rectangle((10,3,15,8),fill=c); d.line((15,4,19,12),fill=c,width=2)
    else:
        d.polygon([(3,9),(8,9),(14,4),(14,20),(8,15),(3,15)],fill=c)
        if name=='speaker': d.arc((12,5,22,19),-75,75,fill=c,width=2)
        else: d.line((3,22,22,2),fill='#FFB32E',width=2)
    im.save(OUT/(name+'.png'))
