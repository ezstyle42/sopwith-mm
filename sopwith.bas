MODE 7
SW=320: SH=240
GROUND_Y=206
HUD_Y=224
WORLD_W=3840
RWC=190
MAXSPD=6
STALL=2.1
GRAV=0.12
LIFT=0.045
MAXB=8
SKY=RGB(90,170,255)
GRN=RGB(0,150,0)
WHT=RGB(255,255,255)
BLK=RGB(0,0,0)
CYN=RGB(0,255,255)
RED=RGB(255,60,60)
MAG=RGB(255,0,255)
YEL=RGB(255,220,0)
GRY=RGB(130,130,130)
ORG=RGB(255,140,0)

DIM tx(20), tty(20), thp(20), tal(20)
DIM fx(8), fal(8), fcd(8)
DIM ex(5), ey(5), eal(5), ecd(5), evy(5)
DIM bux(14), buy(14), bud(14), bua(14)
DIM ebx(10), eby(10), ebvx(10), ebvy(10), eba(10)
DIM bbx(6), bby(6), bbvx(6), bbvy(6), bba(6)
DIM exx(10), eyy(10), ettl(10)
DIM clx(9), cly(9)

px=RWC: py=GROUND_Y-7: spd=0: vy=0: inv=0: thr=0
fuel=100: bombs=MAXB: bullets=400: lives=5: score=0: lvl=1
camX=0: state=0: snd=1: auto=0: msg=0: msg$=""
frame=0: bcd=0: esp=100: remaining=1: nfl=0: clrt=0
zx=WORLD_W*0.7: zy=34: zhp=5: zal=1
FOR i=0 TO 9
  clx(i)=RND*WORLD_W: cly(i)=8+RND*70
NEXT i

SUB Snd(f, d)
  IF snd=0 THEN EXIT SUB
  PLAY TONE f, d
END SUB

SUB AddExpl(x, y)
  LOCAL i
  FOR i=0 TO 10
    IF ettl(i)=0 THEN ettl(i)=12: exx(i)=x: eyy(i)=y: EXIT SUB
  NEXT i
END SUB

SUB KillTarget(i)
  IF tal(i)=0 THEN EXIT SUB
  tal(i)=0
  IF tty(i)=3 THEN score=score+200 ELSE score=score+100
  AddExpl(tx(i), GROUND_Y-8)
  Snd(70, 250)
END SUB

SUB ExplodeAt(x, y)
  LOCAL j, dx, dy, d
  AddExpl(x, y)
  Snd(55, 300)
  FOR j=0 TO 20
    IF tal(j)=1 THEN
      dx=x-tx(j): dy=y-(GROUND_Y-9)
      d=SQR(dx*dx+dy*dy)
      IF d<26 THEN KillTarget(j)
    ENDIF
  NEXT j
  IF zal=1 THEN
    dx=x-zx: dy=y-zy
    d=SQR(dx*dx+dy*dy)
    IF d<36 THEN
      zhp=zhp-2
      IF zhp<=0 THEN zal=0: score=score+300: AddExpl(zx, zy): Snd(60, 350)
    ENDIF
  ENDIF
  FOR j=0 TO 4
    IF eal(j)=1 THEN
      dx=x-ex(j): dy=y-ey(j)
      d=SQR(dx*dx+dy*dy)
      IF d<22 THEN eal(j)=0: score=score+50: AddExpl(ex(j), ey(j))
    ENDIF
  NEXT j
END SUB

SUB Fire
  LOCAL i, m
  IF bullets<=0 OR bcd>0 THEN EXIT SUB
  m=1-2*inv
  FOR i=0 TO 14
    IF bua(i)=0 THEN
      bua(i)=1: bux(i)=px+m*9: buy(i)=py: bud(i)=m
      bullets=bullets-1: bcd=4
      Snd(900, 25)
      EXIT SUB
    ENDIF
  NEXT i
END SUB

SUB DropBomb
  LOCAL i, m
  IF bombs<=0 THEN EXIT SUB
  m=1-2*inv
  FOR i=0 TO 6
    IF bba(i)=0 THEN
      bba(i)=1: bbx(i)=px: bby(i)=py+5: bbvx(i)=m*spd: bbvy(i)=vy
      bombs=bombs-1
      Snd(300, 60)
      EXIT SUB
    ENDIF
  NEXT i
END SUB

SUB Crash
  AddExpl(px, py)
  Snd(50, 400)
  lives=lives-1
  IF lives<=0 THEN state=2: EXIT SUB
  px=RWC: py=GROUND_Y-7: spd=0: vy=0: inv=0: thr=0: auto=0
  msg=60: msg$="CRASHED! "+STR$(lives)+" PLANES LEFT"
END SUB

SUB CountTargets
  LOCAL i
  remaining=0
  FOR i=0 TO 20
    IF tal(i)=1 THEN remaining=remaining+1
  NEXT i
END SUB

SUB BuildLevel
  LOCAL i, n, x, r
  FOR i=0 TO 20: tal(i)=0: NEXT i
  n=7+lvl: IF n>15 THEN n=15
  x=780
  FOR i=0 TO n-1
    tx(i)=x: tal(i)=1
    r=RND
    IF r<0.18 THEN tty(i)=3: thp(i)=2
    ELSEIF r<0.42 THEN tty(i)=2: thp(i)=1
    ELSEIF r<0.74 THEN tty(i)=1: thp(i)=1
    ELSE tty(i)=0: thp(i)=1
    x=x+170+RND*170
    IF x>WORLD_W-430 THEN x=WORLD_W-430+RND*90
  NEXT i
  tx(n)=WORLD_W-150: tty(n)=4: thp(n)=3: tal(n)=1
  nfl=2+lvl: IF nfl>8 THEN nfl=8
  FOR i=0 TO 8: fal(i)=0: NEXT i
  FOR i=0 TO nfl-1
    fx(i)=850+i*((WORLD_W-1700)/nfl)+RND*120
    fal(i)=1: fcd(i)=RND*140
  NEXT i
END SUB

SUB StartLevel
  LOCAL i
  px=RWC: py=GROUND_Y-7: spd=0: vy=0: inv=0: thr=0: auto=0
  fuel=100: bombs=MAXB: bullets=400
  FOR i=0 TO 14: bua(i)=0: NEXT i
  FOR i=0 TO 10: eba(i)=0: ettl(i)=0: NEXT i
  FOR i=0 TO 6: bba(i)=0: NEXT i
  FOR i=0 TO 4: eal(i)=0: NEXT i
  zx=WORLD_W*0.6+RND*800: zy=30+RND*20: zhp=5: zal=1
  BuildLevel
  esp=120
  camX=0
  state=1
  msg=110: msg$="LEVEL "+STR$(lvl)+" - DESTROY ALL RED TARGETS"
END SUB

SUB ResetGame
  score=0: lives=5: lvl=1
  StartLevel
END SUB

SUB HandleKey(s$)
  LOCAL a$
  a$=UCASE$(s$)
  IF state=0 THEN
    IF s$<>CHR$(27) THEN ResetGame
    EXIT SUB
  ENDIF
  IF s$=CHR$(27) THEN state=0: EXIT SUB
  IF state=2 THEN
    IF a$="R" THEN ResetGame
    EXIT SUB
  ENDIF
  IF state<>1 THEN EXIT SUB
  IF a$="X" OR s$=CHR$(131) THEN thr=thr+7: IF thr>100 THEN thr=100
  IF a$="Z" OR s$=CHR$(130) THEN thr=thr-7: IF thr<0 THEN thr=0
  IF s$="," OR s$=CHR$(128) THEN vy=vy-0.40*(1-2*inv)
  IF s$="/" OR s$=CHR$(129) THEN vy=vy+0.40*(1-2*inv)
  IF a$="." THEN inv=1-inv: Snd(500, 30)
  IF s$=" " THEN Fire
  IF a$="B" THEN DropBomb
  IF a$="H" THEN auto=1-auto: IF auto=1 THEN inv=0: msg=50: msg$="AUTOPILOT HOME"
  IF a$="S" THEN snd=1-snd
END SUB

SUB Update
  LOCAL i, j, m, eng, tgt, gy, ddx, ddy, d, n, hit, th
  IF state=3 THEN
    clrt=clrt-1
    px=px+2.5
    IF px>WORLD_W-16 THEN px=WORLD_W-16
    camX=px-110
    IF camX>WORLD_W-SW THEN camX=WORLD_W-SW
    IF msg>0 THEN msg=msg-1
    IF clrt<=0 THEN lvl=lvl+1: StartLevel
    EXIT SUB
  ENDIF
  IF bcd>0 THEN bcd=bcd-1
  m=1-2*inv
  eng=0: IF fuel>0 THEN eng=1
  IF fuel>0 THEN fuel=fuel-(0.012+thr*0.0009)
  IF fuel<0 THEN fuel=0
  tgt=thr/100*MAXSPD*eng
  spd=spd+(tgt-spd)*0.06
  IF auto=1 THEN
    IF ABS(RWC-px)>90 THEN thr=60 ELSE thr=18
    IF ABS(RWC-px)<40 AND py>GROUND_Y-28 THEN vy=vy+0.10 ELSE vy=vy*0.90-0.04
  ENDIF
  vy=vy*0.88+GRAV-spd*LIFT
  gy=GROUND_Y-7
  IF py<gy-1 AND spd<STALL THEN vy=vy+0.22
  px=px+m*spd
  IF px<16 THEN px=16
  IF px>WORLD_W-16 THEN px=WORLD_W-16
  py=py+vy
  IF py<8 THEN py=8: IF vy<0 THEN vy=0
  IF py>=gy THEN
    py=gy
    IF ABS(px-RWC)<75 THEN
      IF spd<=2.8 AND inv=0 THEN
        spd=0: vy=0: auto=0
        IF fuel<99 OR bombs<MAXB OR bullets<400 THEN msg=50: msg$="REFUELLED AT BASE": Snd(600, 90)
        fuel=100: bombs=MAXB: bullets=400
      ELSE
        spd=spd*0.96: vy=0
      ENDIF
    ELSE
      Crash
    ENDIF
  ENDIF
  IF py>GROUND_Y-30 THEN
    FOR i=0 TO 20
      IF tal(i)=1 THEN
        th=18: IF tty(i)=4 THEN th=26
        IF ABS(px-tx(i))<15 AND py>GROUND_Y-th-4 THEN Crash: EXIT FOR
      ENDIF
    NEXT i
  ENDIF
  IF zal=1 THEN
    zx=zx-(0.35+lvl*0.08)
    IF zx<-70 THEN zx=WORLD_W+50+RND*300
  ENDIF
  esp=esp-1
  n=0
  FOR i=0 TO 4
    IF eal(i)=1 THEN n=n+1
  NEXT i
  IF esp<=0 AND n<MIN(5, 2+lvl) THEN
    FOR i=0 TO 4
      IF eal(i)=0 THEN
        eal(i)=1: ex(i)=WORLD_W-30: ey(i)=26+RND*120: evy(i)=0: ecd(i)=50+RND*90
        esp=MAX(55, 180-lvl*16)
        EXIT FOR
      ENDIF
    NEXT i
  ENDIF
  FOR i=0 TO 4
    IF eal(i)=1 THEN
      ex(i)=ex(i)-(1.5+lvl*0.22)
      ddy=py-ey(i)
      IF ddy>0.8 THEN evy(i)=evy(i)+0.05
      IF ddy<-0.8 THEN evy(i)=evy(i)-0.05
      IF evy(i)>0.9 THEN evy(i)=0.9
      IF evy(i)<-0.9 THEN evy(i)=-0.9
      ey(i)=ey(i)+evy(i)
      IF ey(i)<12 THEN ey(i)=12
      IF ey(i)>GROUND_Y-16 THEN ey(i)=GROUND_Y-16
      ecd(i)=ecd(i)-1
      IF ecd(i)<=0 AND ABS(ex(i)-px)<240 THEN
        FOR j=0 TO 10
          IF eba(j)=0 THEN
            eba(j)=1: ebx(j)=ex(i): eby(j)=ey(i)
            ddx=px-ex(i): ddy=py-ey(i)
            d=SQR(ddx*ddx+ddy*ddy): IF d<1 THEN d=1
            ebvx(j)=ddx/d*5: ebvy(j)=ddy/d*5
            ecd(i)=MAX(45, 120-lvl*8)
            EXIT FOR
          ENDIF
        NEXT j
      ENDIF
      IF ex(i)<-30 THEN eal(i)=0
      IF ABS(ex(i)-px)<11 AND ABS(ey(i)-py)<8 THEN
        eal(i)=0: score=score+50: AddExpl(ex(i), ey(i)): Crash
      ENDIF
    ENDIF
  NEXT i
  FOR i=0 TO 14
    IF bua(i)=1 THEN
      bux(i)=bux(i)+bud(i)*7
      IF bux(i)<0 OR bux(i)>WORLD_W OR buy(i)<0 OR buy(i)>GROUND_Y THEN bua(i)=0
      IF bua(i)=1 THEN
        FOR j=0 TO 4
          IF eal(j)=1 AND ABS(bux(i)-ex(j))<9 AND ABS(buy(i)-ey(j))<7 THEN
            bua(i)=0: eal(j)=0: score=score+50: AddExpl(ex(j), ey(j)): Snd(80, 150)
          ENDIF
        NEXT j
      ENDIF
      IF bua(i)=1 AND zal=1 AND ABS(bux(i)-zx)<26 AND ABS(buy(i)-zy)<10 THEN
        bua(i)=0: zhp=zhp-1: AddExpl(bux(i), buy(i))
        IF zhp<=0 THEN zal=0: score=score+300: AddExpl(zx, zy): Snd(60, 350)
      ENDIF
      IF bua(i)=1 THEN
        FOR j=0 TO 20
          IF tal(j)=1 AND ABS(bux(i)-tx(j))<12 AND buy(i)>GROUND_Y-24 THEN
            bua(i)=0: thp(j)=thp(j)-1: IF thp(j)<=0 THEN KillTarget(j)
          ENDIF
        NEXT j
      ENDIF
    ENDIF
  NEXT i
  FOR i=0 TO 10
    IF eba(i)=1 THEN
      ebx(i)=ebx(i)+ebvx(i): eby(i)=eby(i)+ebvy(i)
      IF eby(i)>=GROUND_Y OR eby(i)<0 OR ebx(i)<0 OR ebx(i)>WORLD_W THEN eba(i)=0
      IF eba(i)=1 AND ABS(ebx(i)-px)<7 AND ABS(eby(i)-py)<6 THEN eba(i)=0: Crash
    ENDIF
  NEXT i
  FOR i=0 TO 6
    IF bba(i)=1 THEN
      bbvy(i)=bbvy(i)+0.14
      bbx(i)=bbx(i)+bbvx(i): bby(i)=bby(i)+bbvy(i)
      hit=0
      IF bby(i)>=GROUND_Y THEN hit=1
      IF hit=0 THEN
        FOR j=0 TO 20
          IF tal(j)=1 AND ABS(bbx(i)-tx(j))<14 AND bby(i)>GROUND_Y-26 THEN hit=1
        NEXT j
      ENDIF
      IF hit=1 THEN bba(i)=0: ExplodeAt(bbx(i), bby(i))
    ENDIF
  NEXT i
  FOR i=0 TO 8
    IF fal(i)=1 THEN
      fcd(i)=fcd(i)-1
      IF fcd(i)<=0 AND ABS(fx(i)-px)<150 AND py<GROUND_Y-8 THEN
        FOR j=0 TO 10
          IF eba(j)=0 THEN
            eba(j)=1: ebx(j)=fx(i): eby(j)=GROUND_Y-12: ebvx(j)=0: ebvy(j)=-4.2
            fcd(i)=MAX(70, 140-lvl*9)
            EXIT FOR
          ENDIF
        NEXT j
      ENDIF
    ENDIF
  NEXT i
  FOR i=0 TO 10
    IF ettl(i)>0 THEN ettl(i)=ettl(i)-1
  NEXT i
  camX=px-110
  IF camX<0 THEN camX=0
  IF camX>WORLD_W-SW THEN camX=WORLD_W-SW
  IF msg>0 THEN msg=msg-1
  CountTargets
  IF remaining=0 THEN
    state=3: clrt=150: msg=150: msg$="MISSION COMPLETE!"
  ENDIF
END SUB

SUB DrawPlane(sx, sy, col, iv, ph, dr)
  LOCAL s, nx, tl
  s=1-2*iv
  nx=sx+7*dr: tl=sx-7*dr
  LINE sx-7, sy, sx+7, sy, 1, col
  LINE sx-8, sy-3*s, sx+8, sy-3*s, 1, col
  LINE sx-8, sy+3*s, sx+8, sy+3*s, 1, col
  LINE tl, sy, tl-4*dr, sy-2*s, 1, col
  LINE sx-1, sy-2*s, sx+2, sy-2*s, 1, col
  IF ph MOD 4<2 THEN LINE nx, sy-5, nx, sy+5, 1, col ELSE LINE nx, sy-3, nx, sy+3, 1, col
END SUB

SUB DrawTarget(i, sx)
  IF tty(i)=0 THEN
    BOX sx-12, GROUND_Y-13, 24, 13, 1, RED, RED
    LINE sx-14, GROUND_Y-13, sx, GROUND_Y-21, 1, RED
    LINE sx, GROUND_Y-21, sx+14, GROUND_Y-13, 1, RED
  ELSEIF tty(i)=1 THEN
    BOX sx-12, GROUND_Y-15, 24, 15, 1, RED, RED
    BOX sx+3, GROUND_Y-24, 5, 10, 1, RED, RED
    LINE sx-12, GROUND_Y-15, sx+12, GROUND_Y-15, 2, BLK
  ELSEIF tty(i)=2 THEN
    BOX sx-7, GROUND_Y-6, 14, 6, 1, RED, RED
    LINE sx-2, GROUND_Y-6, sx-2, GROUND_Y-10, 1, RED
    LINE sx-2, GROUND_Y-10, sx+5, GROUND_Y-12, 1, RED
  ELSEIF tty(i)=3 THEN
    BOX sx-11, GROUND_Y-10, 9, 10, 1, RED, RED
    BOX sx+2, GROUND_Y-10, 9, 10, 1, RED, RED
    LINE sx-11, GROUND_Y-10, sx-2, GROUND_Y-10, 1, BLK
    LINE sx+2, GROUND_Y-10, sx+11, GROUND_Y-10, 1, BLK
  ELSE
    BOX sx-16, GROUND_Y-22, 32, 22, 1, RED, RED
    LINE sx-18, GROUND_Y-22, sx, GROUND_Y-32, 1, RED
    LINE sx, GROUND_Y-32, sx+18, GROUND_Y-22, 1, RED
    BOX sx-4, GROUND_Y-12, 8, 12, 1, BLK, BLK
  ENDIF
END SUB

SUB Render
  LOCAL i, sx, fw, fc
  BOX 0, 0, SW, HUD_Y, 1, SKY, SKY
  CIRCLE 282, 26, 10, , , , YEL, YEL
  FOR i=0 TO 7
    LINE 282+13*COS(i*0.785), 26+13*SIN(i*0.785), 282+18*COS(i*0.785), 26+18*SIN(i*0.785), 1, YEL
  NEXT i
  FOR i=0 TO 9
    sx=clx(i)-camX*0.5
    IF sx>-20 AND sx<SW+20 THEN
      BOX sx-14, cly(i), 28, 6, 1, WHT, WHT
      BOX sx-8, cly(i)-4, 16, 5, 1, WHT, WHT
    ENDIF
  NEXT i
  BOX 0, GROUND_Y, SW, HUD_Y-GROUND_Y, 1, GRN, GRN
  sx=120-camX
  IF sx>-150 AND sx<SW THEN
    BOX sx, GROUND_Y, 140, 4, 1, GRY, GRY
    FOR i=0 TO 6
      LINE sx+6+i*20, GROUND_Y+2, sx+14+i*20, GROUND_Y+2, 1, BLK
    NEXT i
  ENDIF
  sx=40-camX
  IF sx>-30 AND sx<SW+10 THEN
    BOX sx-12, GROUND_Y-13, 24, 13, 1, CYN, CYN
    LINE sx-14, GROUND_Y-13, sx, GROUND_Y-21, 1, CYN
    LINE sx, GROUND_Y-21, sx+14, GROUND_Y-13, 1, CYN
  ENDIF
  FOR i=0 TO 20
    IF tal(i)=1 THEN
      sx=tx(i)-camX
      IF sx>-40 AND sx<SW+30 THEN DrawTarget(i, sx)
    ENDIF
  NEXT i
  FOR i=0 TO 8
    IF fal(i)=1 THEN
      sx=fx(i)-camX
      IF sx>-10 AND sx<SW+10 THEN
        LINE sx, GROUND_Y, sx, GROUND_Y-11, 2, BLK
        BOX sx-4, GROUND_Y-3, 8, 3, 1, BLK, BLK
      ENDIF
    ENDIF
  NEXT i
  IF zal=1 THEN
    sx=zx-camX
    IF sx>-60 AND sx<SW+60 THEN
      BOX sx-24, zy-8, 48, 16, 1, MAG, MAG
      BOX sx-28, zy-3, 6, 6, 1, MAG, MAG
      FOR i=0 TO 4
        LINE sx-16+i*8, zy-8, sx-16+i*8, zy+8, 1, BLK
      NEXT i
    ENDIF
  ENDIF
  FOR i=0 TO 4
    IF eal(i)=1 THEN
      sx=ex(i)-camX
      IF sx>-20 AND sx<SW+20 THEN DrawPlane(sx, ey(i), RED, 0, frame, -1)
    ENDIF
  NEXT i
  DrawPlane(px-camX, py, CYN, inv, frame, 1-2*inv)
  FOR i=0 TO 14
    IF bua(i)=1 THEN
      sx=bux(i)-camX
      LINE sx, buy(i), sx+bud(i)*5, buy(i), 1, YEL
    ENDIF
  NEXT i
  FOR i=0 TO 10
    IF eba(i)=1 THEN
      sx=ebx(i)-camX
      BOX sx-1, eby(i)-1, 3, 3, 1, RED, RED
    ENDIF
  NEXT i
  FOR i=0 TO 6
    IF bba(i)=1 THEN
      sx=bbx(i)-camX
      BOX sx-2, bby(i)-2, 4, 4, 1, BLK, BLK
    ENDIF
  NEXT i
  FOR i=0 TO 10
    IF ettl(i)>0 THEN
      sx=exx(i)-camX
      CIRCLE sx, eyy(i), 15-ettl(i)+3, , , , ORG, ORG
      CIRCLE sx, eyy(i), 10-ettl(i)/2+2, , , , YEL, YEL
    ENDIF
  NEXT i
  BOX 0, HUD_Y, SW, SH-HUD_Y, 1, BLK, BLK
  FOR i=0 TO lives-1
    LINE 6+i*5, HUD_Y+9, 10+i*5, HUD_Y+4, 1, CYN
    LINE 10+i*5, HUD_Y+4, 14+i*5, HUD_Y+9, 1, CYN
  NEXT i
  TEXT 34, HUD_Y+4, "SC "+STR$(score), 0, 1, WHT
  TEXT 100, HUD_Y+4, "LV "+STR$(lvl), 0, 1, WHT
  TEXT 138, HUD_Y+4, "FUEL", 0, 1, WHT
  BOX 168, HUD_Y+4, 52, 8, 1, WHT, BLK
  fw=fuel*0.50
  IF fw>0 THEN
    fc=GRN: IF fuel<30 THEN fc=RED
    BOX 169, HUD_Y+5, fw, 6, 1, fc, fc
  ENDIF
  TEXT 226, HUD_Y+4, "T"+STR$(remaining), 0, 1, WHT
  TEXT 252, HUD_Y+4, "B"+STR$(bombs), 0, 1, WHT
  TEXT 276, HUD_Y+4, "G"+STR$(bullets), 0, 1, WHT
  IF msg>0 THEN TEXT 160-LEN(msg$)*4, HUD_Y-14, msg$, 0, 1, YEL
  IF state=0 THEN
    BOX 20, 46, SW-40, 148, 1, BLK, RGB(0,0,90)
    TEXT 160-LEN("S O P W I T H")*8, 56, "S O P W I T H", 0, 2, YEL
    TEXT 160-LEN("MMBasic remake of BMB 1984 original")*4, 84, "MMBasic remake of BMB 1984 original", 0, 1, WHT
    TEXT 40, 102, "X Z or ARROWS : throttle", 0, 1, WHT
    TEXT 40, 114, ", / or ARROWS : pitch  . : roll", 0, 1, WHT
    TEXT 40, 126, "SPACE fire  B bomb  H home  S snd", 0, 1, WHT
    TEXT 40, 138, "Land on runway to refuel", 0, 1, WHT
    TEXT 40, 150, "Destroy all red enemy targets!", 0, 1, WHT
    TEXT 160-LEN("PRESS ANY KEY")*4, 172, "PRESS ANY KEY", 0, 1, CYN
  ENDIF
  IF state=2 THEN
    BOX 60, 80, SW-120, 80, 1, BLK, RGB(90,0,0)
    TEXT 160-LEN("GAME OVER")*8, 90, "GAME OVER", 0, 2, RED
    TEXT 160-LEN("SCORE "+STR$(score))*4, 120, "SCORE "+STR$(score), 0, 1, WHT
    TEXT 160-LEN("PRESS R TO FLY AGAIN")*4, 138, "PRESS R TO FLY AGAIN", 0, 1, CYN
  ENDIF
  IF state=3 THEN
    BOX 40, 90, SW-80, 50, 1, BLK, RGB(0,70,0)
    TEXT 160-LEN("MISSION COMPLETE!")*8, 100, "MISSION COMPLETE!", 0, 2, YEL
    TEXT 160-LEN("NEXT LEVEL "+STR$(lvl+1))*4, 124, "NEXT LEVEL "+STR$(lvl+1), 0, 1, WHT
  ENDIF
END SUB

DO
  frame=frame+1
  t0=TIMER
  DO
    k$=INKEY$
    IF k$<>"" THEN HandleKey(k$)
  LOOP WHILE k$<>""
  IF state=1 OR state=3 THEN Update
  Render
  DO WHILE TIMER-t0<33: LOOP
LOOP
