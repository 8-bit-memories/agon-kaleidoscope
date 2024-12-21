   10 REM Agon Kaleidoscope
   20 REM Based on TRS-80 code from the 1980s
   30 REM Michael Keller, 1980-2024
   40 MODE 18
   50 GCOL 4,1
   60 VDU 23,0,192,0
   70 PRINT "Waiting four seconds for monitor to sync with new mode"
   80 A$=TIME$
   90 FOR I=1 TO 4
  100   REPEAT B$=TIME$
  110   UNTIL A$<>TIME$
  120   A$=B$
  130 NEXT I
  140 CLS
  150 X=0
  160 LX=1022
  170 MX=1022
  180 Y=0
  190 LY=767
  200 MY=767
  210 J=1
  220 K=1
  230 REM PRINT TAB(0,0);"X=";X;" Y=";Y;" LX=";LX;" LY=";LY;"   "
  240 MOVE X,Y
  250 PLOT 5,LX,Y
  260 PLOT 5,LX,LY
  270 PLOT 5,X,LY
  280 PLOT 5,X,Y
  290 X=X+J
  300 Y=Y+K
  310 LX=LX-J
  320 LY=LY-K
  330 IF X>MX THEN X=MX LX=0 J=-1
  340 IF Y>MY THEN Y=MY LY=0 K=-1
  350 IF X<0 THEN X=0 J=1
  360 IF Y<0 THEN Y=0 K=1
  370 GOTO 230
