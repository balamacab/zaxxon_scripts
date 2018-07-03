function poncarretera(escalado,ddepth)
if nargin==0
    escalado=1;
    ddepth=0.3;%30 cm below the road level
end
if nargin==1   
    ddepth=0.3;%30 cm below the road level
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

totoriginal=genera_objetos('../s11_m3d/salida/paraobjetos.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen('salida/nodos_conaltura.txt','r');
tot=fscanf(fid,'%d %f %f %f\n',inf);
x=tot(2:4:end);
y=tot(3:4:end);
z=tot(4:4:end);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aplicamos a los nodos indicados en carretera.txt la curvatura establecida en curvaturas.mat

curvaturas=[];
if exist('../s11_m3d/curvaturas.mat','file')==2
    S=load('../s11_m3d/curvaturas.mat');
    offset=S.offset;
end

%fid=fopen('../s11_m3d/carretera.txt');
%tot=fscanf(fid,'%f %d %d %d %d %d %d %d %d %d');
%
%m=length(tot);
%totoriginal=reshape(tot,10,m/10);

tot=totoriginal([1 4:end-2],:);%Altura comun e indices de carretera. (2 y 3) y (end-1 y end) son adyacentes a carretera
[k p]=size(tot);
ditch_depth=crearditch(ddepth,p);

for g=1:p %Direccion de avance en la carretera
  alturacomun=tot(1,g);
  if isempty(offset)==0
      alturacomun=alturacomun+escalado*offset(g,:);
  end
  y(tot(2:6,g))=alturacomun;
  ancho_carretera=sqrt((x(tot(2,g))-x(tot(end,g)))^2+(z(tot(2,g))-z(tot(end,g)))^2);
	y(totoriginal(3,g))=y(tot(2,g))-ditch_depth(g); 
	y(totoriginal(end-1,g))=y(tot(end,g))-ditch_depth(g);
	y(totoriginal(2,g))=0.5*(y(tot(2,g))+y(totoriginal(2,g))); %El otro punto, a mitad de altura entre montanya y carretera
	y(totoriginal(end,g))=0.5*(y(tot(end,g))+y(totoriginal(end,g)));
end
%fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
createtrk([x(tot(4,1:3:end)) z(tot(4,1:3:end)) y(tot(4,1:3:end))]);
system('copy creado.trk direct.trk');
createtrk(flipud([x(tot(4,1:3:end)) z(tot(4,1:3:end)) y(tot(4,1:3:end))]));
system('copy creado.trk inverse.trk');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen('salida/nodosconcarretera.txt','w');
fprintf(fid,'%d %f %f %f\n',[(1:length(x))' x z y]');%En los nodos elevados, la altura es la columna intermedia
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msh_to_obj('salida/nodos_conaltura.txt','elements.txt','test.mtl');
system('copy salida\test.obj+salida\texturas0.txt salida\test_sincarretera.obj');
msh_to_obj('salida/nodosconcarretera.txt','elements.txt','test.mtl');
system('copy salida\test.obj+salida\texturas0.txt salida\test_concarretera.obj');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alt=y;
load('../s11_m3d/salida/paraobjetos.mat');
ii=find(zone==111);
implicados=tri(ii,:);
usados=zeros(size(x));
usados(implicados)=1;
orden=cumsum(usados);
implicados=orden(implicados);
indices=find(usados==1);
misx=x(indices);
misy=y(indices);
misalt=alt(indices);
misu=u(indices);
misv=v(indices);
creax(misx',misy',misalt',misu,misv,implicados-1,'salida/inside.x','Placa3.dds');

ii=find(zone==222);
implicados=tri(ii,:);
usados=zeros(size(x));
usados(implicados)=1;
orden=cumsum(usados);
implicados=orden(implicados);
indices=find(usados==1);
misx=x(indices);
misy=y(indices);
misalt=alt(indices);
misu=u(indices);
misv=v(indices);
creax(misx',misy',misalt',misu,misv,implicados-1,'salida/outside.x','Placa3.dds');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function carret=genera_objetos(sincarretera)
load(sincarretera);

fid=fopen('..\s3_road\track0.mat');
if (fid~=-1)
    S=load('..\s3_road\track0.mat');
	alturas_reales=S.alturas_suavizadas;
%     fid=fopen('alturas_track1.mat');
%     contenido=fread(fid,inf);
%     contenido=char(contenido)';
%     %posini=strfind(contenido,'alturas_suavizadas');
%     posini=strfind(contenido,'alturas_track1');
%     poscol=strfind(contenido,'columns:');
%     validos=find(poscol>posini);
%     frewind(fid);
%     fseek(fid,poscol(validos(1))+length('columns:')-1,'bof');
%     ncols=fscanf(fid,'%d',1);%Numero de anchors
%     alturas_reales=fscanf(fid,'%f',length(lasx));  
%     fclose(fid);
    %figure,plot(alturas_reales);
    %fid=fopen('../s11_m3d/carretera.txt','w');
    %for h=1:numpanelesvertical+1
    %    fprintf(fid,'%f ',alturas_reales(h));
    %   for g=borde_izdo-2:borde_dcho+2      %Carretera y dos puntos mas por cada lado
    %        fprintf(fid,'%d ',indice(g,h));
    %    end
    %    fprintf(fid,'\n');
    %end
    fclose(fid);
	carret=[alturas_reales indice(borde_izdo-2:borde_dcho+2,:)']';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Muro protector metido una posición dentro del terreno creado
indmuro=indice(pos_muro_izq,:);
murox=x(indmuro(1:4:end));
muroy=y(indmuro(1:4:end));
muroz=z(indmuro(1:4:end));

try
    alturas=procesar_nodostxt([0 0],[(1:length(murox))' murox muroy muroz],'salida/nodosizdoelevados.txt');
catch
    alturas=muroz;
    fprintf(2,'Wall not raised\n');
end %_try_catch
ponmuro(murox,muroy,alturas,'izdo');
msh_to_obj('salida/nodosmuroizdo.txt','salida/elementsmuroizdo.txt','transparente.mtl');
system('copy salida\test.obj+salida\texturasmuroizdo.txt salida\muroizdo.obj');
system('cat salida/test.obj salida/texturasmuroizdo.txt > salida/muroizdo.obj');
system('move salida\muro.x salida\muroizdo.x');

%Muro dcho
indmuro=indice(pos_muro_dcho,:);
murox=x(indmuro(1:4:end));
muroy=y(indmuro(1:4:end));
muroz=z(indmuro(1:4:end));
murox=fliplr(murox);muroy=fliplr(muroy);muroz=fliplr(muroz);%Forma sencilla de invertir las normales

try
    alturas=procesar_nodostxt([0 0],[(1:length(murox))' murox muroy muroz],'salida/nodosdchoelevados.txt');
catch
    alturas=muroz;
    fprintf(2,'Wall not raised\n');
end %_try_catch
ponmuro(murox,muroy,alturas,'dcho');
msh_to_obj('salida/nodosmurodcho.txt','salida/elementsmurodcho.txt','transparente.mtl');
system('copy salida\test.obj+salida\texturasmurodcho.txt salida\murodcho.obj');
%system('cat salida/test.obj salida/texturasmurodcho.txt > salida/murodcho.obj');
system('move salida\muro.x salida\murodcho.x');
%system('mv ../s11_m3d/salida/muro.x salida/murodcho.x');

fid_mtl=fopen(strcat('salida/transparente','.mtl'),'w');
fprintf(fid_mtl,'\nnewmtl material_%02d\nKa  0.6 0.6 0.6\nKd  0.6 0.6 0.6\nKs  0.9 0.9 0.9\nd  1.0\nNs  0.0\nillum 2\nmap_Kd %s\n',0,'transpa.dds');
fclose(fid_mtl);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%figure,plot(lasx,lasy);
%msh_to_obj('fichero_nodos.txt','fichero_elements.txt')
%msh_to_obj('nodos_conaltura.txt','fichero_elements.txt')
%system('copy test.obj+texturas.txt test_texturas.obj');
%system('cat salida/test.obj texturas.txt > test_texturas.obj');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   

    
    
    function salida=crearditch(profundidad,longitud)
        hhh=1;
        profundidad=[0 profundidad];
        salida=profundidad(2)*ones(1,longitud);
        hhh=hhh+2;
        while (hhh+1)<=length(profundidad); 
            salida(round(profundidad(hhh)*longitud):end)=profundidad(hhh+1);
            hhh=hhh+2;
        end
        xx=filter([0.05 0.25 0.4 0.25 0.05],1,salida);
        xx=flipud(fliplr(filter([0.05 0.25 0.4 0.25 0.05],1,flipud(fliplr(xx)))));
        salida(5:end-4)=xx(5:end-4);        
        end

end
