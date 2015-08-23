{$R-}{$Q-}{$S-}{$N+}{$G+}{$I-}{$E-}{$A+}
program filler;
uses crt,graph,keyb1,gr;

const maxStars=750;
      MaxSetCol=3;
      MaxSize=66;
      MaxPlayers=8;
      MaxScore=10;

type top=record
 n:string[9];
 s:word;
end;


type playerData=object
  col:byte;
  level:byte;
  oldcol:byte;
  x,y:byte;
  cond:byte;

  StartPosition:byte;
  SetColCount:byte;

  around:array[0..12] of word;
  procedure ComputerGo;
  procedure AdvancedTactics;
end;

type star=object
  x,y:integer;
  dx,dy:shortInt;
  col:byte;
procedure new;
procedure fly;
end;

type fillArray=array[1..MaxSize,1..MaxSize] of byte;
type top10type=array[1..maxScore] of top;

var cc:array[1..MaxPlayers] of PlayerData;
    a:fillArray;

    i,j,k,l:integer;flg:boolean;

    x1,y1,x2:byte;

    t:^fillArray;

    now,redraw:byte;
    turn:boolean;

    VictoryMinimum:word;
    continiuebattle:boolean;
    survivors:byte;
    round1:byte;

    koef:single;
    score:longInt;
    top10:top10type;
    old:top;
    lastScore:byte;
    playerName:string[9];

    stars:array[1..maxStars] of star;
    step:byte;
    max:byte;
    players:byte;
    maxCol:byte;

    quickGame:boolean;
    tries:byte;

    str1,str2,str3:string;

    ch:array[1..9] of char;
    pos:byte;

    file1:file of top10type;

{------------------------------------------------------------------------}
procedure LoadScores;
begin
{$I+}
 Reset(file1);
  read(file1,top10);
 close(file1);
{$I-}
end;
{------------------------------------------------------------------------}
procedure SaveScores;
begin
{$I+}
 Rewrite(file1);
  write(file1,top10);
 close(file1);
{$I-}
end;
{------------------------------------------------------------------------}
function Lc(t:byte):string;
begin
case t of
  0:lc:='Random';
  1:lc:='DownLeft';
  2:lc:='UpRight';
  3:lc:='UpLeft';
  4:lc:='DownRight';
  5:lc:='Center';
  6:lc:='Left';
  7:lc:='Up';
  8:lc:='Right';
  9:lc:='Down';
end;
end;
{------------------------------------------------------------------------}
procedure outData;
begin
str(max:2,str1);
setColor(2);
outTextXY(20,110,'F1:');
setColor(1);
setFillStyle(1,0);
bar(122,110,162,116);
outTextXY(50,110,'MAP SIZE:'+str1+'x'+str1);

str((players-1):1,str1);
setColor(2);
outTextXY(20,120,'F2:');
setColor(1);
setFillStyle(1,0);
bar(114,120,122,126);
outTextXY(50,120,'ENEMIES:'+str1);

for i:=2 to MaxPlayers do begin
  setFillStyle(1,0);
  bar(20,110+i*10,320,117+i*10);

    str(i+1,str1);
    str(i-1,str3);
    if i<=players then setColor(4) else setColor(255);
    outTextXY(20,110+i*10,'F'+str1+':');
    if i<=players then setColor(3) else setColor(255);
    case cc[i].level of
      0:str2:='  0% Easy';
      1:str2:=' 80% Med';
      2:str2:='100% Norm';
      3:str2:='150% Hard';
    end;
    outTextXY(50,110+i*10,'Enemy'+str3+':'+str2);

    str(cc[i].SetColCount,str2);
    str3:=Lc(cc[i].StartPosition)+'('+str2+')';
    if i<=players then setColor(4) else setColor(255);
    outTextXY(185,110+i*10,'F'+str1+':');
    if i<=players then setColor(3) else setColor(255);
    outTextXY(215,110+i*10,str3);

end;
setColor(7);
outTextXY(170,100,'SHIFT+');
setColor(7);
outTextXY(170,120,'SHIFT+      CTRL+');

str((maxcol+1):1,str1);
setColor(2);
outTextXY(170,110,'F1:');
setColor(1);
setFillStyle(1,0);
bar(256,110,272,116);
outTextXY(200,110,'COLORS:'+str1);

setFillStyle(1,0);
bar(209,0,320,7);
str(cc[1].SetColCount,str2);
str3:=Lc(cc[1].StartPosition)+'('+str2+')';
setColor(5);
outTextXY(10,0,'Shift+F2:');
setColor(9);
outTextXY(85,0,'Player location:'+str3);

setFillStyle(1,0);
bar(221,10,243,16);
if QuickGame=true then str1:='NO' else str1:='YES';
setColor(5);
outTextXY(26,10,'Alt+F1:');
setColor(1);
outTextXY(85,10,'Show enemy moves:'+str1);
end;
{------------------------------------------------------------------------}
procedure mainMenu;
begin
clearViewPort;
for i:=1 to maxStars do stars[i].new;
{for i:=1 to maxStars do begin
  stars[i].new;
  stars[i].dx:=round(5*(random+1)*Fsin(2*pi*i/200));
  stars[i].dy:=round(5*(random+1)*Fcos(2*pi*i/200))
end;}
setTextStyle(0,0,6);
setColor(16);
outTextXY(20,20,'FILLER');
setTextStyle(0,0,2);
outTextXY(18,80,'Hit ENTER to start');
setTextStyle(0,0,0);
outData;
repeat
  key:='|';
  if keyPressed then rkey;
  delay(50);
  for i:=1 to maxStars do stars[i].fly;

  if key=#0 then
  case key1 of
    #59:begin
          if step=10 then step:=7;
          if step>3 then dec(step) else step:=10;
          max:=200 div step
        end;
    #60:if Players<MaxPlayers then begin
           inc(Players);
           if maxCol<=players then inc(maxCol);
        end
        else players:=2;
    #61..#67:begin
               case key1 of
                 #61:j:=2;
                 #62:j:=3;
                 #63:j:=4;
                 #64:j:=5;
                 #65:j:=6;
                 #66:j:=7;
                 #67:j:=8;
               end;
               if cc[j].level<3 then inc(cc[j].level) else cc[j].level:=0;
             end;
    #84:if maxcol<12 then inc(maxcol) else maxcol:=players+1;
    #85..#92:begin
               case key1 of
                 #85:j:=1;
                 #86:j:=2;
                 #87:j:=3;
                 #88:j:=4;
                 #89:j:=5;
                 #90:j:=6;
                 #91:j:=7;
                 #92:j:=8;
               end;
               k:=cc[j].StartPosition;
               repeat
                 flg:=true;
                 if k<9 then inc(k) else k:=0;
                 for l:=1 to MaxPlayers do if cc[l].startPosition=k then flg:=false;
                 if k=0 then flg:=true;
               until flg=true;
               cc[j].StartPosition:=k;
             end;
    #104:QuickGame:=not quickGame;
    #95..#102:begin
               case key1 of
                 #95:j:=1;
                 #96:j:=2;
                 #97:j:=3;
                 #98:j:=4;
                 #99:j:=5;
                #100:j:=6;
                #101:j:=7;
                #102:j:=8;
               end;
               if cc[j].SetColCount<sqr(maxSetCol+1) then inc(cc[j].SetColCount) else cc[j].SetColCount:=0;
               if cc[j].SetColCount=1 then cc[j].SetColCount:=2;
             end;
  end;

  if key<>'|' then outData;
until (key=enter) or (key1=f10);
clearViewPort;
end;
{------------------------------------------------------------------------}
procedure star.new;
begin
 repeat
  x:=160-5+round(random*10);
  y:=70-5+round(random*10);
  col:=trunc(random*15)+17;
  dx:=round(random*30)-15;
  dy:=round(random*20)-10;
 until (dx<>0) or (dy<>0);
end;
{------------------------------------------------------------------------}
procedure star.fly;
begin
  j:=getPixel(x,y);
 if j<100 then begin
  if j>16 then putPixel(x,y,0)
  else begin
    if j<>16 then putPixel(x,y,j) else putPixel(x,y,col+200);
  end;
 end;
  inc(x,dx);
  inc(y,dy);
  if (x>0) and (y>0) and (x<320) and (y<200) then begin
    j:=getPixel(x,y);
    if ((j>16) and (j<100)) or (j=0) then putPixel(x,y,col);
  end else new;

end;
{------------------------------------------------------------------------}
procedure createMap(menuSet:boolean);
var Rng:byte;
begin
if menuSet=true then mainmenu;
if continiueBattle=false then begin
  survivors:=players;
  round1:=1;
end;
VictoryMinimum:=round(sqr(max)/Survivors)+1;

for i:=1 to MaxSize do
  for j:=1 to MaxSize do a[j,i]:=trunc(random*(MaxCol+1));

cc[1].cond:=1;
for i:=1 to Players do if continiuebattle=false then cc[i].cond:=1;

for i:=1 to Players do with cc[i] do if cc[i].cond>0 then begin
  case startPosition of
   0:begin
       repeat
         flg:=true;
         x:=round((max-1)*random)+1;
         y:=round((max-1)*random)+1;
         for j:=1 to MaxPlayers do if (j<>i) and (cc[j].x+MaxSetCol>x) and
                                                 (cc[j].x-MaxSetCol<x) and
                                                 (cc[j].y+MaxSetCol>y) and
                                                 (cc[j].y-MaxSetCol<y) then flg:=false;
       until flg=true;
     end;

   1:begin
       x:=1;
       y:=max;
     end;
   2:begin
       x:=max;
       y:=1;
     end;
   3:begin
       x:=1;
       y:=1;
     end;
   4:begin
       x:=max;
       y:=max;
     end;
   5:begin
       x:=max div 2;
       y:=max div 2;
     end;
   6:begin
       x:=1;
       y:=max div 2;
     end;
   7:begin
       x:=max div 2;
       y:=1;
     end;
   8:begin
       x:=max;
       y:=max div 2;
     end;
   9:begin
       x:=max div 2;
       y:=max;
     end;
  end;


  col:=i-1;
  oldCol:=col;
  for j:=0 to maxCol do around[j]:=0;
  l:=0;
  if cond=1 then begin
  a[x,y]:=col;
  rng:=0;
  repeat
    inc(rng);
    for j:=-rng to rng do
      for k:=-rng to rng do if (x+j>0) and (x+j<=Max) and
                                     (y+k>0) and (y+k<=Max) then begin
                                         if a[x+j,y+k]<>col then inc(l);
                                         if l<=SetColCount then a[x+j,y+k]:=col;
                                      end;
  until rng>=MaxsetCol;
 end;
end;

continiuebattle:=false;
redraw:=1;
now:=0;
turn:=true;

setColor(2);
case maxCol of
 1..8:str(maxCol,str1);
  9:str1:='9,0';
 10:str1:='9,0,-';
 11:str1:='9,0,-,=';
 12:str1:='9,0,-,=,\';
end;
outTextXY(210,130,'1..'+str1+':');
outTextXY(220,138,'Choose Color');
setColor(3);
outTextXY(210,150,'F9:Restart');
setColor(6);
outTextXY(204,162,'Shift-F9:Reset');
setColor(7);
outTextXY(210,190,'F10:QUIT');
end;
{------------------------------------------------------------------------}
procedure DrawMap;
begin
for i:=1 to max do
  for j:=1 to max do{ if redraw>0 then }begin
    setFillStyle(1,a[j,i]+1);
    bar((j-1)*step,(i-1)*step,(j)*step-1,(i)*step-1);
  end;
{ turn:=false;}
 for i:=1 to Players do if cc[i].cond=1 then begin
    SetColor(15);
    circle(round((cc[i].x-1/2)*step)-1,round((cc[i].y-1/2)*step)-1,step div 2-1);
 end;
 redraw:=0;

end;
{------------------------------------------------------------------------}
procedure RestoreBoard;
begin
for i:=1 to max do
  for j:=1 to max do t^[j,i]:=a[j,i];
end;
{------------------------------------------------------------------------}
procedure playerData.advancedTactics;
var count:word;
    rng:byte;
    found:byte;
    count1:array[0..12] of word;
begin
new(t);
restoreBoard;
for i:=0 to maxCol do count1[i]:=0;
count1[col]:=1;
t^[x,y]:=255;
rng:=1;
repeat
     count:=0;
     for i:=-rng to rng do
      for j:=-rng to rng do if (y+i<=max) and (y+i>0) and
                               (x+j<=max) and (x+j>0) then begin
       k:=t^[x+j,y+i];

        if k<=MaxCol then begin
          found:=0;
          if x+j+1<=max then if (t^[x+j+1,y+i  ]=255) or (t^[x+j+1,y+i  ]=254-k) then inc(found);
          if x+j-1> 0   then if (t^[x+j-1,y+i  ]=255) or (t^[x+j-1,y+i  ]=254-k) then inc(found);
          if y+i+1<=max then if (t^[x+j  ,y+i+1]=255) or (t^[x+j  ,y+i+1]=254-k) then inc(found);
          if y+i-1> 0   then if (t^[x+j  ,y+i-1]=255) or (t^[x+j  ,y+i-1]=254-k) then inc(found);

          if found>0 then begin
            inc(count);
            inc(count1[k]);
            if k=col then t^[x+j,y+i]:=255 else begin
              t^[x+j,y+i]:=254-k;
            end;
          end;
        end;
    end;
    inc(rng);
until count=0;
for i:=0 to maxCol do around[i]:=count1[i];
dispose(t);
{if level>3 then Strategy;}
end;
{------------------------------------------------------------------------}
Procedure CheckColor;
var count:word;
    rng:byte;
    found:byte;
begin
  for i:=0 to maxCol do cc[now].around[i]:=0;
  cc[now].around[cc[now].col]:=1;
  a[cc[now].x,cc[now].y]:=255;
  rng:=0;
  repeat
    count:=0;
    inc(rng);
     for i:=-rng to rng do
      for j:=-rng to rng do if (cc[now].y+i<=max) and (cc[now].y+i>0) and
                               (cc[now].x+j<=max) and (cc[now].x+j>0) then begin
         found:=0;
         if cc[now].x+j+1<=max then if a[cc[now].x+j+1,cc[now].y+i  ]=255 then inc(found);
         if cc[now].x+j-1> 0   then if a[cc[now].x+j-1,cc[now].y+i  ]=255 then inc(found);
         if cc[now].y+i+1<=max then if a[cc[now].x+j  ,cc[now].y+i+1]=255 then inc(found);
         if cc[now].y+i-1> 0   then if a[cc[now].x+j  ,cc[now].y+i-1]=255 then inc(found);
         if found>0 then begin
           if a[cc[now].x+j,cc[now].y+i]<=maxCol then
             inc(cc[now].around[(a[cc[now].x+j,cc[now].y+i])]);

           if a[cc[now].x+j,cc[now].y+i]=cc[now].col then begin
             a[cc[now].x+j,cc[now].y+i]:=255;
             inc(count);
         end;
       end;
    end;

  until count=0;
end;
{------------------------------------------------------------------------}
procedure setNewColor(c:byte);
begin
flg:=true;
for i:=1 to players do if (c=cc[i].col) and (cc[i].cond=1) then flg:=false;
if flg=true then begin
  checkColor;
  begin
    for i:=1 to max do
      for j:=1 to max do if a[j,i]=255 then a[j,i]:=c;
    turn:=true;
    cc[now].col:=c;
    redraw:=1;
  end
end;
end;
{------------------------------------------------------------------------}
procedure playerData.ComputerGo;
var st:array[0..12] of byte;
    flg1:boolean;
begin
if level>1 then advancedTactics;

{j:=0;
for i:=0 to maxCol do begin
  flg1:=true;
  for k:=1 to players do if (cc[k].cond=1) and (cc[k].col=i) then begin
     flg1:=false;
     if (around[i]>cc[k].around[i]+cc[k].around[OldCol]) then inc(j,around[i]-(cc[k].around[i]+cc[k].around[OldCol]));
    end;
  if flg1=true then inc(j,around[i]);
end;
if j=0 then begin
   cond:=0;
end;}


for i:=0 to maxCol do st[i]:=i;

for k:=1 to 10 do begin
  for i:=1 to maxCol do begin
    if around[st[i]]<around[st[i-1]] then begin
      tries:=st[i];
      st[i]:=st[i-1];
      st[i-1]:=tries;
    end;
  end;
end;
oldCol:=col;

{  for i:=0 to MaxCol do begin
    setColor(i+1);
    setFillStyle(1,0);
    str((around[i]):5,str1);
    str(i:2,str2);
    str(st[i]:2,str3);
    bar(220,102+i*8,320,110+i*8);
    outTextXY(220,102+i*8,str2+')'+str1);

    outTextXY(300,102+i*8,str3);
  end;}

tries:=0;
repeat
 flg1:=false;
   if (tries<=maxCol) and (level>1) or ((level=1) and (random>0.2)) then begin
     setNewColor(st[maxcol-tries]);
     flg1:=true;
   end;
 if flg1=false then
   setNewColor(round(random*maxCol));
 inc(tries);
until turn=true;
end;
{------------------------------------------------------------------------}
procedure CountCond;
var ttt:integer;
begin
  j:=0;
  for i:=1 to players do if cc[i].cond=1 then  j:=j+cc[i].around[cc[i].OldCol];

  if j=sqr(max) then begin
     clearViewPort;
     loadScores;
     ttt:=cc[1].around[cc[1].col];
     koef:=0;
      for i:=2 to players do
         case cc[i].level of
           0:koef:=koef/2.6+1/4;
           1:koef:=koef/2.5+1/3;
           2:koef:=koef/2.4+5/6;
           3:koef:=(koef/2.3+9/8)*0;
         end;
     score:=round((30000*(koef*(ttt/sqr(max)))));
     if score>65535 then score:=65535;

for i:=1 to maxStars do stars[i].new;
     if score>top10[maxScore].s then begin

      key1:='|';
      k:=1;
      flg:=true;
     setTextStyle(0,0,6);
     setColor(16);
     outTextXY(20,20,'êÖäéêÑ!');
     setTextStyle(0,0,0);
     setFillStyle(1,8);
{     pos:=1;}
      repeat
        bar(100,100,220,130);
        for i:=1 to pos do if i<pos then begin
          setColor(15);
          outTextXY(110+i*9,111,ch[i])
        end
        else begin
          setColor(14);
          outTextXY(110+i*9,111,'˛')
        end;
        if keyPressed then begin
          rkey;
          case key of
            'a'..'z','A'..'Z','1'..'9','0','.',',','-','(',')','`',' ':
              if pos<10 then begin
                ch[pos]:=key;
                if pos<10 then inc(pos);
              end;
            enter,esc:flg:=false;
               #0:if key1=f10 then flg:=false else
                  if key1=left then begin
                    if pos>1 then dec(pos);
                  end;
          end;
        end;
        delay(50);
        for i:=1 to maxStars do stars[i].fly;
      until (flg=false);
      playerName:='';
      for i:=1 to pos-1 do playerName:=playerName+ch[i];
      if playerName='' then playerName:='Incognito';
    end;

     clearViewPort;
{       for i:=1 to maxStars do stars[i].new;}

     setTextStyle(0,0,2);
     if ttt>VictoryMinimum then setColor(2) else setColor(4);
     if ttt=VictoryMinimum then setColor(6);
       str(ttt,str1);
       str(VictoryMinimum,str2);
       outTextXY(10,3,'Score:'+str1+'/'+str2);

     setColor(16);
     if (ttt>=VictoryMinimum) then begin
       setTextStyle(0,0,5);
       outTextXY(25,20,'VICTORY')
     end
     else begin
       setTextStyle(0,0,6);
       outTextXY(25,20,'DEFEAT');
     end;

     setTextStyle(0,0,2);

     x1:=157;
     y1:=155;
     continiuebattle:=false;
     setTextStyle(0,0,0);
     survivors:=1;
     for i:=1 to Players do begin
       k:=cc[i].around[cc[i].oldCol];
       if i<>1 then begin
         if (k>=VictoryMinimum) then begin
           inc(survivors);
           continiueBattle:=true
         end else cc[i].cond:=0;
       end;
       if k>victoryMinimum then begin
         setcolor(2);
         str1:='Victory';
       end else begin
         if k=victoryMinimum then begin
           setColor(6);
           str1:='Parity';
         end else begin
           setColor(4);
           str1:='Defeat';
         end;
{         if k=0 then begin
           setColor(255);
           str1:='Absent';
         end;}
         if (cc[i].cond=0) and (k=0) then begin
           setColor(8);
           str1:='Dead';
         end;
       end;
       str(i,str2);
       str(k:4,str3);
       if x1=10 then x1:=157 else begin
         x1:=10;
         inc(y1,8);
       end;
       outTextXY(x1,y1,str2+')['+str3+']:'+str1);
     end;
   if ttt<VictoryMinimum then continiuebattle:=false;
   if continiuebattle=false then begin
     setColor(2);
     setTextStyle(0,0,0);
     outTextXY(10,90,'Press F9 to Restart');

     outTextXY(20,110,'Press SHIFT+F9 to');
     outTextXY(50,127,'Main Menu');

     outTextXY(20,145,'Press F10 to Quit');
{     setTextStyle(0,0,0);}
     setColor(3);

     str(round(30000*koef),str1);
     str(score:5,str3);
     outTextXY(10,80,'OUTCOME:'+str3+'/'+str1);

     recTangle(180,75,319,160);

     if score>top10[maxScore].s then begin
       top10[maxScore].s:=score;
       top10[maxScore].n:=PlayerName;
       lastScore:=1;
       for i:=maxScore-1 downto 1 do if top10[i].s<top10[i+1].s then begin
         old:=top10[i];
         top10[i]:=top10[i+1];
         top10[i+1]:=old;
       end else if lastScore=1 then lastScore:=i+1;
       saveScores;
     end;

     for i:=1 to maxScore do with top10[i] do begin
       setColor(11);
       if lastScore=i+100 then setColor(6);
       if lastScore=i then begin
         inc(lastScore,100);
         setColor(14);
       end;

       str(s:5,str1);
       str(i,str2);
       if i=10 then str2:=chr(1);
       outTextXY(182,70+i*8,str2+')'+n);
       outTextXY(278,70+i*8,str1);
     end;


   end else begin
     inc(round1);
     setColor(4);
     setTextStyle(0,0,1);
     outTextXY(40, 90,'You`ve survived but all the');
     outTextXY(40,100,'Enemies are not defeated yet...');
     case round1 of
       2:str1:='2nd';
       3:str1:='3rd';
       else begin
         str(round1,str1);
         str1:=str1+'th';
       end;
     end;
     outTextXY(40,110,'Let The '+str1+' Round Begin!');
     outTextXY(40,120,'Press Any Key to go Ahead!');
     str(survivors,str1);
     outTextXY(40,130,'You are still '+str1+' here!');
     setTextStyle(0,0,0);
   end;


{     while keyPressed do ReadKey;}
     key1:='|';
     key:='|';
     repeat
      if keyPressed then rkey;
      delay(50);
      for i:=1 to maxStars do stars[i].fly;
{      if key=enter then begin
        key:=#0;
        key1:=f9;
      end;}
      if ((key1<>'|') or (key<>'|')) and (continiuebattle=true) then begin
        key:=#0;
        key1:=f9;
      end;
     until (key1=f9) or (key1=f10) or (key1=#92);
     clearViewPort;
  end;
end;
{------------------------------------------------------------------------}
procedure PlayerGo;
begin
  key:='|';
  countCond;

  if key='|' then
  repeat
    if keyPressed then rKey;
  until key<>'|';


  case key of
    '-':if maxCol>=10 then setNewColor(10);
    '=':if maxCol>=11 then setNewColor(11);
    '\':if maxCol>=12 then setNewColor(12);
    '0'..'9':begin
               val(key,j,i);
               if j=0 then j:=10;
               if j<=maxCol+1 then
                 setNewColor(j-1);
             end;
    #0:begin
        if (key1=#67) then createMap(false);
        if (key1=#92) then createMap(true);
       end;

  end;
end;
{------------------------------------------------------------------------}
BEGIN
randomize;
assign(file1,'Scores.Fil');
max:=50;
step:=4;
players:=2;
maxCol:=9;
continiuebattle:=false;
QuickGame:=True;

pos:=1;

{$I-}
reset(file1);
if ioresult<>0 then begin
  for i:=1 to maxScore do begin
    top10[i].n:='Default';
    top10[i].s:=100*(maxScore-i+1);
  end;
  saveScores;
end else close(file1);
{$I+}


{max:=5;
step:=40;
{players:=8;
maxCol:=12;}

for i:=1 to MaxPlayers do begin
  cc[i].SetColCount:=3;
  cc[i].StartPosition:=i;
  if i=5 then cc[i].StartPosition:=maxPlayers+1;
end;
for i:=2 to MaxPlayers do cc[i].level:=3;
cc[1].level:=0;
SetGraficMode(0);
setRGBPalette(255,1,2,3);
createMap(true);

repeat
  if turn=true then begin
    turn:=false;
    if now<players then inc(now) else now:=1;

 with cc[now] do begin

    if (level<=2) or (now=1) then begin
      checkColor;
      for i:=1 to max do
        for j:=1 to max do if a[j,i]=255 then a[j,i]:=cc[now].col;
      oldCol:=col;
    end;

 end;
    for i:=1 to players do if cc[i].cond=1 then begin
      setFillStyle(1,0);

      str((cc[i].around[cc[i].Oldcol]):4,str1);
      str(i:1,str2);
      str(100*((cc[i].around[cc[i].Oldcol])/sqr(max)):4:1,str3);
      bar(212,1+i*9,320,10+i*9-1);
      if i=now then setColor(15) else setColor(8);
      if round(1000*((cc[i].around[cc[i].Oldcol])/sqr(max)))>=1000 then str3:=' 100';

      outTextXY(213,2+i*9,str2+')'+str1+'['+str3+'%]');

      setFillStyle(1,cc[i].col+1);
      bar(202,1+i*9,211,10+i*9-1);
    end;
{    cc[i].oldCol:=cc[i].col;}
{    readKey;}
    if now=1 then begin
      if maxCol<10 then k:=11 else k:=11-(3*maxCol) div 12;
      for i:=0 to maxCol do begin
        flg:=true;
        for j:=1 to Players do if (i=cc[j].col) and (cc[j].cond=1) then flg:=false;
        if flg=true then begin
          setFillStyle(1,1+i);
          setColor(15);
          bar(210+i*k,100,209+(i+1)*k,111);
        end else begin
          setFillStyle(1,0);
          setColor(17);
          bar(210+i*k,100,209+(i+1)*k,111);
        end;
        str(i+1,str1);
        case i of
          9:str1:='0';
         10:str1:='-';
         11:str1:='=';
         12:str1:='\';
        end;

        outTextXY(211+i*k,102,str1);
      end;
   end;
  end;

  if (now=1) or (quickGame=false) then
    if (redraw>0) then drawMap;

  if now=1 then playerGo else begin
   if cc[now].cond=1 then cc[now].computerGo else turn:=true;
  end;

until (key=#0) and (key1=#68);

restoreCrtMode;
closeGraph;
END.