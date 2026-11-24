from PIL import Image, ImageDraw, ImageFilter
import logo
from logo import S, K, W, ORANGE, sc
DEEP=(14,52,112,255); MID=(31,95,173,255); LIGHT=(58,140,230,255); GLASS=(120,185,245,255)

def background():
    g=Image.new("RGBA",(S*K,S*K))
    top=Image.new("RGBA",(1,2)); top.putpixel((0,0),LIGHT); top.putpixel((0,1),DEEP)
    g=top.resize((S*K,S*K),Image.BICUBIC)
    # soft diagonal light band
    band=Image.new("L",(S*K,S*K),0); ImageDraw.Draw(band).polygon(sc(0,180, 1024,-200, 1024,120, 0,520),fill=40)
    band=band.filter(ImageFilter.GaussianBlur(60*K))
    g=Image.composite(Image.new("RGBA",g.size,(255,255,255,255)),g,band)
    mask=Image.new("L",(S*K,S*K),0); ImageDraw.Draw(mask).rounded_rectangle([0,0,S*K,S*K],220*K,fill=255)
    out=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); out.paste(g,(0,0),mask); return out

def shadow(layer, off=(10,14), blur=14, alpha=90):
    a=layer.split()[3].point(lambda v: v*alpha//255)
    sh=Image.new("RGBA",layer.size,(5,20,50,255)); sh.putalpha(a)
    sh=sh.filter(ImageFilter.GaussianBlur(blur*K))
    out=Image.new("RGBA",layer.size,(0,0,0,0)); out.alpha_composite(sh,(off[0]*K,off[1]*K)); return out

def truck_layer(y=676):
    L=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); d=ImageDraw.Draw(L); CL=(0,0,0,0)
    P=lambda pts:[(x*K,yy*K) for x,yy in pts]; s=lambda *v:[t*K for t in v]
    # trailer with panel lines and stripe
    d.rounded_rectangle(s(236,y,606,y+140),16*K,fill=W)
    for x in (330,425,520): d.rectangle(s(x,y+12,x+3,y+88),fill=(220,230,242,255))
    d.polygon(P([(262,y+100),(580,y+100),(566,y+112),(262,y+112)]),fill=ORANGE)
    d.polygon(P([(394,y+144),(560,y+144),(550,y+164),(402,y+164)]),fill=W)          # side skirt
    # tractor with roof fairing
    d.polygon(P([(614,y-2),(668,y-2),(714,y+42),(748,y+70),(764,y+86),(768,y+150),(614,y+150)]),fill=W)
    d.polygon(P([(676,y+46),(708,y+46),(742,y+78),(676,y+78)]),fill=GLASS)          # tinted glass
    d.polygon(P([(676,y+46),(690,y+46),(684,y+78),(676,y+78)]),fill=(170,215,250,255))  # glass reflection
    d.rectangle(s(668,y+88,671,y+140),fill=(200,212,228,255))                          # door seam
    d.rounded_rectangle(s(646,y+92,662,y+98),3*K,fill=(200,212,228,255))              # door handle
    d.polygon(P([(748,y+104),(768,y+104),(768,y+114),(748,y+116)]),fill=ORANGE)       # LED light
    d.rectangle(s(606,y+64,614,y+124),fill=CL)                                         # coupling gap
    # wheels with rims
    for x in (284,356,640,724):
        d.ellipse(s(x-42,y+112,x+42,y+196),fill=CL)
        d.ellipse(s(x-36,y+118,x+36,y+190),fill=(24,32,48,255))
        d.ellipse(s(x-22,y+132,x+22,y+176),fill=W)
        d.ellipse(s(x-8,y+146,x+8,y+162),fill=(160,175,195,255))
    return L

def road_layer():
    """Dark road under the truck with orange edge and white lane dashes."""
    L=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); d=ImageDraw.Draw(L)
    d.rounded_rectangle(sc(150,872,874,906),17*K,fill=(10,35,80,170))
    d.rounded_rectangle(sc(150,872,874,878),3*K,fill=ORANGE)
    for x in range(190,840,90): d.rounded_rectangle(sc(x,888,x+50,894),3*K,fill=(255,255,255,200))
    return L

def make():
    im=background()
    mono=logo.shear(logo.mono_layer())
    mono_shift=Image.new("RGBA",mono.size,(0,0,0,0)); mono_shift.alpha_composite(mono,(40*K,-20*K))
    speed=Image.new("RGBA",mono.size,(0,0,0,0)); logo.speedlines(ImageDraw.Draw(speed),x0=0,y=310)
    tr=truck_layer()
    for layer in (mono_shift,speed,tr):
        im.alpha_composite(shadow(layer))
    im.alpha_composite(road_layer())
    for layer in (mono_shift,speed,tr): im.alpha_composite(layer)
    return im.resize((S,S),Image.LANCZOS)

def foreground():
    """Transparent version for Android adaptive icons."""
    tr=truck_layer(); mono=logo.shear(logo.mono_layer())
    L=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); L.alpha_composite(mono,(40*K,-20*K))
    logo.speedlines(ImageDraw.Draw(L),x0=0,y=310); L.alpha_composite(road_layer()); L.alpha_composite(tr)
    return L.resize((S,S),Image.LANCZOS)

if __name__=="__main__":
    m=make(); m.save("v2.png"); m.resize((512,512),Image.LANCZOS).save("v2_small.png")
