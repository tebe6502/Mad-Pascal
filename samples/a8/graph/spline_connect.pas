
 { At last! A couple of spline routines that CONNECT the data points.}
 {they are set up in a simple, but probably useless, manner for you to
  configure to suit. The reconfigurations are simple, it's the core
  routines that seem to be hard to get.}

uses crt, graph;

const maxnodes=4;
      total=100;

      green = 1;
      cyan = 1;
      white = 1;
      lightred = 1;
      yellow = 1;
      
type
     TFloat = single;
     data=array[0..maxnodes] of TFloat;

var sum,xx,yy: TFloat;
    i,n,eger:smallint;
    xc,yc,xp,yp,temp,path: data;
    ch:char;
    alternate:boolean;
    
    method: byte;

    sigma: TFloat = 1.0;  {tension factor}

Procedure Spline1(color:smallint);
{ Fits a smooth curve through a given set of points. Small, simple, fast.
  No tension factor.
  From Algorithms, Robert Sedgewick, sort of...
  simple, but limited
  Beat beyond recognition by Ron Nossaman June 1996 }
Var i,j,oldy,oldx,x,y:smallint;
    part,t,xx,yy: TFloat;
    d,wy,wx:data;

  Function f(g: TFloat): TFloat;
  begin
     f:=g*g*g-g;
  end;

Begin
   setcolor(color);
   oldx:=999;
   x:=round(xc[1]);
   y:=round(yc[1]);

        {calculate matrix for x & y}
   for i:=1 to maxnodes-1 do d[i]:=4; {fake ascending sequence}
   for i:=1 to maxnodes-1 do
   begin
      wy[i]:=6*((yc[i+1]-yc[i])-(yc[i]-yc[i-1]));
      wx[i]:=6*((xc[i+1]-xc[i])-(xc[i]-xc[i-1]));
   end;
   yp[0]:=0.0; xp[0]:=0.0;
   yp[maxnodes]:=0.0; xp[maxnodes]:=0.0;
   for i:=1 to maxnodes-2 do
   begin
      wy[i+1]:=wy[i+1]-wy[i]*0.25;
      wx[i+1]:=wx[i+1]-wx[i]*0.25;
      d[i+1]:=d[i+1]-0.25;
   end;
   for i:=maxnodes-1 downto 1 do
   begin
      yp[i]:=(wy[i]-yp[i+1])/d[i];
      xp[i]:=(wx[i]-xp[i+1])/d[i];
   end;

        { Draw spline  }
   for i:=0 to maxnodes-1 do
   begin
      for j:=0 to 30 do {arbitrary number of steps between points}
      begin
         t:=j/30;
         part:=t*yc[i+1]+(1-t)*yc[i]+(f(t)*yp[i+1]+f(1-t)*yp[i])/6.0;
         y:=round(part);
         part:=t*xc[i+1]+(1-t)*xc[i]+(f(t)*xp[i+1]+f(1-t)*xp[i])/6.0;
         x:=round(part);
         if oldx<>999 then line(oldx,oldy,x,y);
         oldx:=x;
         oldy:=y;
       end;
    end;
 end;


Procedure Spline2(color:smallint);
{ Fits a smooth curve through a given set of points. Small, simple, fast.
  No tension factor. Nicer curve than above Spline1 routine.
  From Algorithms, Robert Sedgewick, sort of...
  Beat beyond recognition by Ron Nossaman June 1996 }
Var i,oldy,oldx,x,y,j:smallint;
    part,t,xx,yy: TFloat;
    zc,dx,dy,u,wx,wy,px,py:data;

  Function f(g: TFloat): TFloat;
  begin
     f:=g*g*g-g;
  end;

Begin
   setcolor(color);
   oldx:=999;
   x:=round(xc[0]);
   y:=round(yc[0]);
   zc[0]:=0.0;
   for i:=1 to maxnodes do
   begin
      xx:=xc[i-1]-xc[i]; yy:=yc[i-1]-yc[i];
      t:=sqrt(xx*xx+yy*yy);
      zc[i]:=zc[i-1]+t;     {establish a proportional linear progression}
   end;

{calculate x & y matrix stuff}
   for i:=1 to maxnodes-1 do
   begin
      dx[i]:=2*(zc[i+1]-zc[i-1]);
      dy[i]:=2*(zc[i+1]-zc[i-1]);
   end;
   for i:=0 to maxnodes-1 do
   begin
      u[i]:=zc[i+1]-zc[i];
   end;
   for i:=1 to maxnodes-1 do
   begin
      wy[i]:=6*((yc[i+1]-yc[i])/u[i]-(yc[i]-yc[i-1])/u[i-1]);
      wx[i]:=6*((xc[i+1]-xc[i])/u[i]-(xc[i]-xc[i-1])/u[i-1]);
   end;
   py[0]:=0.0; px[0]:=0.0;    px[1]:=0; py[1]:=0;
   py[maxnodes]:=0.0; px[maxnodes]:=0.0;
   for i:=1 to maxnodes-2 do
   begin
      wy[i+1]:=wy[i+1]-wy[i]*u[i]/dy[i];
      dy[i+1]:=dy[i+1]-u[i]*u[i]/dy[i];
      wx[i+1]:=wx[i+1]-wx[i]*u[i]/dx[i];
      dx[i+1]:=dx[i+1]-u[i]*u[i]/dx[i];
   end;
   for i:=maxnodes-1 downto 1 do
   begin
      py[i]:=(wy[i]-u[i]*py[i+1])/dy[i];
      px[i]:=(wx[i]-u[i]*px[i+1])/dx[i];
   end;

{ Draw spline  }
   for i:=0 to maxnodes-1 do
   begin
      for j:=0 to 30 do
      begin
         part:=zc[i]-(((zc[i]-zc[i+1])/30)*j);
         t:=(part-zc[i])/u[i];
         part:=t*yc[i+1]+(1-t)*yc[i]+u[i]*u[i]*(f(t)*py[i+1]+f(1-t)*py[i])/6.0;
         y:=round(part);
         part:=zc[i]-(((zc[i]-zc[i+1])/30)*j);
         t:=(part-zc[i])/u[i];
         part:=t*xc[i+1]+(1-t)*xc[i]+u[i]*u[i]*(f(t)*px[i+1]+f(1-t)*px[i])/6.0;
         x:=round(part);
         if oldx<>999 then line(oldx,oldy,x,y);
         oldx:=x;
         oldy:=y;
       end;
    end;
 end;




 (* -----------------------------------------------------------------*)
                { Spline under tension}
{  Original Author -- Copyright(c)1985 James R .Van Zandt
   Converted to Turbo Pascal, simplified, altered
    - Ron Nossaman June 1996 nossaman@southwind.net
   Based on algorithms by A. K. Cline      }

procedure curv1(var x:data; var y:data; var p:data; n:smallint);
var i:smallint;
    c1,c2,c3,deln,delnm1,delnn,dels,delx1,delx2,delx12,
    diag1,diag2,diagin,dx1,dx2,exps,
    sigmap,sinhs,sinhin,slpp1,slppn,spdiag: TFloat;
begin
   delx1:=x[1]-x[0];
   dx1:=(y[1]-y[0])/delx1;
   if sigma>=0.then
   begin
      slpp1:=0;
      slppn:=0;
   end else
       begin
          if n<>1 then
          begin
             delx2:=x[2]-x[1];
             delx12:=x[2]-x[0];
             c1:=-(delx12+delx1)/delx12/delx1;
             c2:=delx12/delx1/delx2;
             c3:=-delx1/delx12/delx2;
             slpp1:=c1* y[0]+c2* y[1]+c3* y[2];
             deln:=x[n-1]-x[n-2];
             delnm1:=x[n-2]-x[n-3];
             delnn:=x[n-1]-x[n-3];
             c1:=(delnn+deln)/delnn/deln;
             c2:=-delnn/deln/delnm1;
             c3:=deln/delnn/delnm1;
             slppn:=c3* y[n-3]+c2* y[n-2]+c1* y[n-1];
          end else
             begin
                p[0]:=0.;
                p[1]:=0.;
             end;
       end;
   (* denormalize tension factor *)
   sigmap:=abs(sigma)*(n-1)/(x[n-1]-x[0]);
   (* set up right hand side and tridiagonal system for
         yp and perform forward elimination *)
   dels:=sigmap* delx1;
   exps:=exp(dels);
   sinhs:=0.5*(exps-1./exps);
   sinhin:=1./(delx1* sinhs);
   diag1:=sinhin*(dels* 0.5*(exps+1./exps)-sinhs);
   diagin:=1./diag1;
   p[0]:=diagin*(dx1-slpp1);
   spdiag:=sinhin*(sinhs-dels);
   temp[0]:=diagin* spdiag;
   if(n <> 1) then
   begin
      for i:=1 to n-2 do
      begin
         delx2:=x[i+1]-x[i];
         dx2:=(y[i+1]-y[i])/delx2;
         dels:=sigmap*delx2;
         exps:=exp(dels);
         sinhs:=0.5*(exps-1./exps);
         sinhin:=1./(delx2*sinhs);
         diag2:=sinhin*(dels*(0.5*(exps+1./exps))-sinhs);
         diagin:=1./(diag1+diag2-spdiag*temp[i-1]);
         p[i]:=diagin*(dx2-dx1-spdiag*p[i-1]);
         spdiag:=sinhin*(sinhs-dels);
         temp[i]:=diagin*spdiag;
         dx1:=dx2;
         diag1:=diag2;
      end;
   end;
   diagin:=1./(diag1-spdiag*temp[n-2]);
   p[n-1]:=diagin*(slppn-dx2-spdiag*p[n-2]);
              (* perform back substitution *)
   for i:=n-2 downto 0 do p[i]:=p[i]-(temp[i]*p[i+1]);
end;



function curv2(var x:data; var y:data; var p:data; t: TFloat; n:smallint): TFloat;
var i,j,i1:smallint;
    del1,del2,dels,exps,exps1,s,sigmap,sinhd1,sinhd2,sinhs: TFloat;
begin
   i1:=1;
   s:=x[n-1]-x[0];
   sigmap:=abs(sigma)*(n-1)/s;
   i:=i1;
   while(i<n) and(t>= x[i])do inc(i);
   while(i>1) and(x[i-1]>t)do dec(i);
   i1:=i;
   del1:=t-x[i-1];
   del2:=x[i]-t;
   dels:=x[i]-x[i-1];
   exps1:=exp(sigmap*del1); sinhd1:=0.5*(exps1-1./exps1);
   exps:=exp(sigmap*del2); sinhd2:=0.5*(exps-1./exps);
   exps:=exps1*exps; sinhs:=0.5*(exps-1./exps);
   curv2:=((p[i]*sinhd1+p[i-1]*sinhd2)/sinhs+
        ((y[i]-p[i])*del1+(y[i-1]-p[i-1])*del2)/dels);
end;


procedure curv0(n,requested:smallint);
var  i,j,each,stop,seg,regressing:smallint;
     s,ds,xx,yy,oldx,oldy: TFloat;
begin
   oldx:=999;
   curv1(path,xc,xp,n);
   curv1(path,yc,yp,n);
   s:=path[0];
   seg:=0;
   for j:=0 to n-2 do
   begin
      stop:=100;
      ds:=(path[j+1]-path[j])/stop;
      for i:=0 to stop-1 do
      begin
         xx:=round(curv2(path,xc,xp,s,n));
         yy:=round(curv2(path,yc,yp,s,n));
         if oldx<>999 then
           line(round(oldx),round(oldy),round(xx),round(yy));
         oldx:=xx; oldy:=yy;
         s:=s+ds;
      end;
   end;
   xx:=xc[n-1];
   yy:=yc[n-1];
   line(round(oldx),round(oldy),round(xx),round(yy));
end;


procedure tspline(color:smallint);
{  Fits a smooth curve through a given set of points, using the splines
   under tension introduced by J. Schweikert. They are similar to cubic
   splines,but are less likely to introduce spurious inflection points.

   Original Author -- Copyright(c)1985James R .Van Zandt
   Converted to Turbo Pascal, butchered, simplified, altered --
         Ron Nossaman June 1996 nossaman@southwind.net
   Based on algorithms by A. K. Cline      }
var nn,origin:smallint;
begin
   sum:=0;
   path[0]:=0;
   for i:=1 to maxnodes do
   begin
      xx:=xc[i]-xc[i-1];
      yy:=yc[i]-yc[i-1];
      sum:=sum+sqrt((xx*xx)+(yy*yy));
      path[i]:=sum;
      if alternate then path[i]:=i; {my addition, another alternative }
   end;
   setcolor(color);   {display color for spline curve}
   curv0(maxnodes+1,100);
end;


procedure loadarrays;
var i:smallint;
begin

   setcolor(red);
   for i:=0 to maxnodes do
   begin
      xc[i]:=random(120)+50;   {try to keep it on the screen for demo}
      yc[i]:=random(60)+50;
{show the path, if you want}
      if i>0 then line(round(xc[i-1]),round(yc[i-1]),round(xc[i]),round(yc[i]));
   end;
   setcolor(white);
   for i:=0 to maxnodes do circle(round(xc[i]),round(yc[i]),3);
end;


begin
 
 randomize;
 
 method:=0;
 
 while true do begin

   InitGraph(8);

   loadarrays;

    {try whatever combinations strike you}
    {there are a lot of different ways to get there!}
    
   writeln('Method: ', method) ;
    
   case method of
     0: begin alternate:=false; sigma:=-2; tspline(green); end;
     1: begin alternate:=false; sigma:=0.1; tspline(cyan); end;
     2: begin alternate:=true; sigma:=1; tspline(white); end;
     3: spline1(lightred);
     4: spline2(yellow);
   end;

   method:=(method+1) mod 5;

   writeln('Press any key');

   repeat until keypressed;
   ch:=readkey;
      
 end;     

end.
