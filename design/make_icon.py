from PIL import Image, ImageDraw, ImageFont
S=1024; K=4; BLUE=(31,95,173,255); W=(255,255,255,255); ORANGE=(255,159,28,255)
def canvas(bg=True):
    im=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); d=ImageDraw.Draw(im)
    if bg: d.rounded_rectangle([0,0,S*K,S*K],220*K,fill=BLUE)
    return im,d
def sc(*v): return [x*K for x in v]
def mono_layer(accent=ORANGE):
    """T clearly separate: wide thick crossbar, D drawn next to the stem with a thin gap."""
    L=Image.new("RGBA",(S*K,S*K),(0,0,0,0)); d=ImageDraw.Draw(L)
    CLR=(0,0,0,0)
    d.rounded_rectangle(sc(330,300,840,600),150*K,fill=W)
    d.rectangle(sc(330,300,600,600),fill=W)
    d.rounded_rectangle(sc(450,380,750,520),70*K,fill=CLR)
    d.rectangle(sc(450,380,560,520),fill=CLR)
    d.rectangle(sc(150,270,560,300),fill=CLR)
    d.rectangle(sc(410,270,440,600),fill=CLR)
    d.rectangle(sc(130,190,640,270),fill=W)
    d.rectangle(sc(320,190,410,600),fill=W)
    d.polygon(sc(470,505, 700,505, 690,520, 470,520),fill=accent)
    return L
def shear(L, k=-0.18):
    return L.transform(L.size, Image.AFFINE, (1,k,-k*S*K*0.42,0,1,0), resample=Image.BICUBIC)
def speedlines(d, x0=60, y=300, accent=ORANGE):
    for i,(ln,col) in enumerate([(150,W),(110,accent),(70,W)]):
        yy=y+i*70; d.rounded_rectangle(sc(x0+(150-ln),yy,x0+150,yy+34),17*K,fill=col)
def truck(d, hole, dx=-16, y=700):
    from PIL import ImageDraw as D
    def P(pts): return [((x+dx)*K,yy*K) for x,yy in pts]
    s=lambda x0,y0,x1,y1:[(x0+dx)*K,y0*K,(x1+dx)*K,y1*K]
    d.rounded_rectangle(s(300,y,598,y+130),6*K,fill=W)
    d.polygon(P([(612,y+4),(690,y+4),(732,y+60),(740,y+64),(740,y+130),(612,y+130)]),fill=W)
    d.polygon(P([(628,y+18),(683,y+18),(716,y+60),(628,y+60)]),fill=hole)
    d.rectangle(s(626,y+70,629,y+120),fill=hole); d.rectangle(s(722,y+90,740,y+104),fill=hole)
    d.rectangle(s(736,y+112,752,y+130),fill=W)
    for x in (358,446,536,686):
        d.ellipse(s(x-42,y+100,x+42,y+184),fill=hole); d.ellipse(s(x-36,y+106,x+36,y+178),fill=W); d.ellipse(s(x-11,y+131,x+11,y+153),fill=hole)

def option_a(bg=True):
    im,d=canvas(bg); hole=BLUE if bg else (0,0,0,0)
    m=shear(mono_layer()); im.alpha_composite(m, (int(40*K),0))
    speedlines(d, x0=0, y=330)
    truck(d,hole)
    return im.resize((S,S),Image.LANCZOS)
def option_b(bg=True):
    im,d=canvas(bg); hole=BLUE if bg else (0,0,0,0)
    d.ellipse(sc(150,90,874,650),outline=W,width=26*K)             # ring badge
    m=mono_layer().resize((int(S*K*0.72),int(S*K*0.72)),Image.LANCZOS)
    im.alpha_composite(m,(int(S*K*0.16),int(S*K*0.07)))
    d.rectangle(sc(260,620,764,650),fill=BLUE if bg else (0,0,0,0))  # gap in ring for truck road
    d.rounded_rectangle(sc(240,630,784,646),8*K,fill=ORANGE)       # road line
    truck(d,hole)
    return im.resize((S,S),Image.LANCZOS)
def option_c(bg=True):
    im,d=canvas(bg); hole=BLUE if bg else (0,0,0,0)
    m=mono_layer(accent=W)
    im.alpha_composite(m,(0,0))

    # orange underline swoosh
    d.pieslice(sc(150,520,880,700),200,340,fill=ORANGE)
    d.pieslice(sc(150,545,880,725),200,340,fill=BLUE if bg else (0,0,0,0))
    truck(d,hole)
    return im.resize((S,S),Image.LANCZOS)
if __name__=="__main__":
    a,b,c=option_a(),option_b(),option_c()
    a.save("a.png"); b.save("b.png"); c.save("c.png")
    sheet=Image.new("RGBA",(3*520+40,600),(240,242,246,255)); dd=ImageDraw.Draw(sheet)
    f=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",40)
    for i,(im,lab) in enumerate([(a,"1"),(b,"2"),(c,"3")]):
        sheet.alpha_composite(im.resize((500,500),Image.LANCZOS),(20+i*520,20)); dd.text((270+i*520,560),lab,font=f,fill=(30,30,30),anchor="mm")
    sheet.save("options.png")
