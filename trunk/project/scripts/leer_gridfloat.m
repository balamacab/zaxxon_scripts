function leer_gridfloat(ficherohdr,ficheroflt)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  if (nargin<2) || (ficherohdr=='h')
    fprintf(1,'Ejemplo: leer_gridfloat(''ned_03263284.hdr'',''ned_03263284.flt'');\n');
    return;
  end
%Datos sacados de http://seamless.usgs.gov/products/1arc.php

%Fichero 
% ncols         316
% nrows         416
% xllcorner     -105.09499999873
% yllcorner     38.820277777173
% cellsize      0.00027777777779647
% NODATA_value  -9999
% byteorder     LSBFIRST
  [cadenas datos]=textread(ficherohdr,'%s %s');
ncols=str2num(datos{1});
nrows=str2num(datos{2});
xllcorner=str2num(datos{3});
yllcorner=str2num(datos{4});
paso=str2num(datos{5});
NODATA=str2num(datos{6});

M = readmtx(ficheroflt,nrows,ncols,'float32',[1 nrows],[1 ncols],'ieee-le');

M = flipud(M);

[fila,columna]=find(M==NODATA);
if length(fila)>1
    display('ATENCIÓN!!! Faltan datos en algunos puntos. Pulse ENTER para repararlos')
    pause
    Mnueva=M;
    for g=1:length(fila)
        xc=fila(g);
        yc=columna(g);
        if (xc>2)
            anchox=2;
        else
            if xc>1
                anchox=1;
            else
                anchox=0
            end
        end
        if (yc>2)
            anchoy=2;
        else
            if yc>1
                anchoy=1;
            else
                anchoy=0
            end
        end
        submatriz=M(xc-anchox:xc+anchox,yc-anchoy:yc+anchoy);
        buenos=find(submatriz~=NODATA);
        if length(buenos)==0
           anchox=3; 
           anchoy=3;
           if xc<4
               anchox=xc-1;
           end
           if yc<4
               anchoy=yc-1;
           end
           submatriz=M(xc-anchox:xc+anchox,yc-anchoy:yc+anchoy);
           buenos=find(submatriz~=NODATA);
        end
        media=mean(submatriz(buenos));
        Mnueva(xc,yc)=media;
    end
    M=Mnueva;
end

pasos1=0:paso:(ncols-1)*paso;
pasos2=0:paso:(nrows-1)*paso;
pos1=xllcorner+pasos1;
pos2=yllcorner+pasos2;
%surf(pos1,pos2,M);


[mapeo]=textread('..\mapeo.txt','%f');

contador=1;
x=zeros(nrows*ncols,1);
y=zeros(nrows*ncols,1);
z=zeros(nrows*ncols,1);

rangox=zeros(ncols,1);
rangoz=zeros(nrows,1);
for h=1:ncols
    h
    for g=1:nrows
     [x(contador) y(contador) z(contador)]=coor_a_BTB(pos1(h),pos2(g),M(g,h),mapeo);
     if h==1
         rangoz(g)=z(contador);
     end
     if g==1
         rangox(h)=x(contador);
     end
     contador=contador+1;
    end
end

surf(rangox,rangoz,M);

datax=x;
datay=y;
dataz=z;
malla_regular=M;

display('Grabando salida\lamalla.mat');
%save -mat-binary 'salida\lamalla.mat' datax datay dataz rangox rangoz malla_regular
save -mat-binary 'salida\lamalla.mat' rangox rangoz malla_regular;

%load 'lamalla.mat'
fid=my_fopen('datos_altura.geo','w');

for h=1:length(datax)
    fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',100000+h,datax(h),dataz(h),datay(h));%%Les pongo altura cero para que me ayuden a hacer el mallado
end

my_fclose(fid);

message(2);
