function addgrid(xmin,xmax,zmin,zmax,nummetros)


if (nargin==2)|(nargin==3)
    numx=xmin;
	numz=xmax;
	salvaguarda=0.01;
	try 
		S=load('..\s2_elevation_b\salida\lamalla.mat');
	catch
	        display('Warning: s2_elevation_b\lamalla.mat not found. Getting it from s2_elevation');
                try 
		    S=load('..\s2_elevation\salida\lamalla.mat'); %Asumimos que solo hay una malla
                catch
                    display('Warning: lamalla.mat file not found');
                    display('Grid not added');
                    return;
                end
	end
	minx=S.rangox(1);
	maxx=S.rangox(end);
	pasox=(maxx-minx-salvaguarda)/(numx);

	minz=S.rangoz(1);
	maxz=S.rangoz(end);
	pasoz=(maxz-minz-salvaguarda)/(numz);
elseif (nargin==5) | (nargin==6)
    minx=xmin;
	maxx=xmax;
	minz=zmin;
	maxz=zmax;
	pasox=nummetros(1);
	pasoz=nummetros(length(nummetros));
	numx=round((maxx-minx)/(pasox));
	numz=round((maxz-minz)/(pasoz));
	salvaguarda=0;
else 
    nargin=0
end

[mapeo]=textread('..\mapeo.txt','%f');
[longitudmin altura latitudmin]=BTB_a_coor(minx,0,minz,mapeo);
[longitudmax altura latitudmax]=BTB_a_coor(maxx,0,maxz,mapeo);

%‘Operations’>’Select’>’Load from file’
fid=fopen('addgrid.hlg','w');
fprintf(fid,'[HIGHLIGHTING]\r\n');
fprintf(fid,'zoom=17\r\n');
fprintf(fid,'PointLat_1=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_2=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_5=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_3=%f\r\n',latitudmin);%38.5691381150080
fprintf(fid,'PointLat_4=%f\r\n',latitudmin);%38.5691381150080
fprintf(fid,'PointLon_1=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_4=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_5=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_2=%f\r\n',longitudmin);%-0.397154512982273
fprintf(fid,'PointLon_3=%f\r\n',longitudmin);%-0.397154512982273
fclose(fid)


if nargin==0
    display('Use:');
	display('addgrid(numx,numz) creates a numx X numz grid relative to available elevation data');
	display('addgrid(xmin,xmax,zmin,zmax,step) creates a grid with those limits and splitted every "step" meters');
end

global progress_bar;
if isempty(progress_bar)==0
	option=4;
else
	display('1) Create grid.geo')
	display('2) Add grid to salida\joined.geo')
	display('3) Add grid to salida\anchors_carretera.geo')
	option=input('Select one option:')
end
if option==2
	fid=fopen('salida\joined.geo','a');
elseif option==3
    fid=fopen('salida\anchors_carretera.geo','a');
elseif option==4
    fid=fopen('salida\limits.geo','w');
else
    fid=fopen('grid.geo','w');
end
fprintf(fid,'\r\nclg=150;\r\n');
fprintf(fid,'\r\nnumg=newreg;\r\n');

fprintf(fid,'\r\n');
fprintf(fid,'numx=%d;\r\n',numx+1);
fprintf(fid,'numy=%d;\r\n',numz+1);
fprintf(fid,'xmin=%f;\r\n',minx+salvaguarda/2);
fprintf(fid,'pasox=%f;\r\n',pasox);
fprintf(fid,'ymin=%f;\r\n',minz+salvaguarda/2);
fprintf(fid,'pasoy=%f;\r\n',pasoz);
numy=numz+1;
numx=numx+1;
xmin=minx+salvaguarda/2;
ymin=minz+salvaguarda/2;

if (nargin==6) | (nargin==3)
  for indx=1:numx
     x=xmin+(indx-1)*pasox;
     for indy=1:numy
         y=ymin+(indy-1)*pasoz;
         fprintf(fid,'    Point(numg+%d)={%f,%f,0,clg};\r\n',indx*numy+indy,x,y);
     end
  end
  
  for indx=1:numx
     for indy=1:numy
        if (indx>1)
           fprintf(fid,'        Line(numg+%d)={ numg+%d, numg+%d};\r\n',indx*numy+indy,indx*numy+indy,(indx-1)*numy+indy);
        end
        if (indy>1)
           fprintf(fid,'        Line(numg+%d)={ numg+%d, numg+%d};\r\n',indx*numy+indy+numx*numy,indx*numy+indy,indx*numy+(indy-1));
        end
     end
  end
else
  fprintf(fid,'For indx In {1:numx}\r\n');
  fprintf(fid,'  x=xmin+(indx-1)*pasox;\r\n');
  fprintf(fid,'  For indy In {1:numy}\r\n');
  fprintf(fid,'    y=ymin+(indy-1)*pasoy;\r\n');
  fprintf(fid,'\r\n');    
  fprintf(fid,'    puntos[indx*numy+indy] = newp; Point(puntos[indx*numy+indy])={x,y,0,clg};\r\n');
  fprintf(fid,'\r\n');
  fprintf(fid,'    If (indx>1)\r\n');
  fprintf(fid,'        ll=newl; Line(ll)={puntos[indx*numy+indy] , puntos[(indx-1)*numy+indy]};\r\n');
  fprintf(fid,'    EndIf\r\n');
  fprintf(fid,'    If (indy>1)\r\n');
  fprintf(fid,'        ll=newl; Line(ll)={puntos[indx*numy+indy] , puntos[indx*numy+(indy-1)]};\r\n');
  fprintf(fid,'    EndIf\r\n');
  fprintf(fid,'  EndFor\r\n');
  fprintf(fid,'EndFor\r\n');

end

fclose(fid)
