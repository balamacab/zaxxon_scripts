function poncarretera(escalado)
if nargin==0
    escalado=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ../s11_m3d
genera_objetos('salida/paraobjetos.mat');
cd ../s4_terrain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen('salida/nodos_conaltura.txt','r');
tot=fscanf(fid,'%d %f %f %f\n',inf);
x=tot(2:4:end);
y=tot(3:4:end);
z=tot(4:4:end);%Esta es la altura
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aplicamos a los nodos indicados en carretera.txt la curvatura establecida en curvaturas.mat

curvaturas=[];
if exist('../s11_m3d/curvaturas.mat','file')==2
    S=load('../s11_m3d/curvaturas.mat');
    offset=S.offset;
end

fid=fopen('../s11_m3d/carretera.txt');
tot=fscanf(fid,'%f %d %d %d %d %d %d %d %d %d');

m=length(tot);
totoriginal=reshape(tot,10,m/10);

tot=totoriginal([1 4:end-2],:);
[k p]=size(tot);

for g=1:p %Direccion de avance en la carretera
    alturacomun=tot(1,g);
    if isempty(offset)==0
        alturacomun=alturacomun+escalado*offset(g,:);
    end
    y(tot(2:6,g))=alturacomun;
	y(totoriginal(3,g))=y(tot(2,g))-0.2;
	y(totoriginal(end-1,g))=y(tot(end,g))-0.2;
	y(totoriginal(2,g))=0.5*(y(tot(2,g))+y(totoriginal(2,g)));
	y(totoriginal(end,g))=0.5*(y(tot(end,g))+y(totoriginal(end,g)));
end
fclose(fid);

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
system('copy salida\test.obj+..\s11_m3d\salida\texturas0.txt salida\test_sincarretera.obj');
msh_to_obj('salida/nodosconcarretera.txt','elements.txt','test.mtl');
system('copy salida\test.obj+..\s11_m3d\salida\texturas0.txt salida\test_concarretera.obj');
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

function genera_objetos(sincarretera)
load(sincarretera);


ii=find(zone==111);
graba(x,y,alturas,tri(ii,:),'salida/nodos0.txt','salida/elements0.txt','salida/texturas0.txt',zone(ii),u,v);
ii=find(zone==222);
graba(x,y,alturas,tri(ii,:),'salida/nodos1.txt','salida/elements1.txt','salida/texturas1.txt',zone(ii),u,v);

msh_to_obj('salida/nodos0.txt','salida/elements0.txt','test.mtl');
system('copy salida\test.obj+salida\texturas0.txt salida\contexturas0.obj');
system('cat salida/test.obj salida/texturas0.txt > salida/contexturas0.obj');

msh_to_obj('salida/nodos1.txt','salida/elements1.txt','test.mtl');
system('copy salida\test.obj+salida\texturas1.txt salida\contexturas1.obj');
system('cat salida/test.obj salida/texturas1.txt > salida/contexturas1.obj');

system('copy salida\nodos0.txt ..\s1_mesh\salida\nodos.txt');
system('copy salida\elements0.txt ..\s1_mesh\salida\elements.txt');

fid_mtl=fopen(strcat('salida/test','.mtl'),'w');
fprintf(fid_mtl,'\nnewmtl material_%02d\nKa  0.6 0.6 0.6\nKd  0.6 0.6 0.6\nKs  0.9 0.9 0.9\nd  1.0\nNs  0.0\nillum 2\nmap_Kd %s\n',0,'Placa3.dds');
fclose(fid_mtl);

fid=fopen('track0.mat');
if (fid~=-1)
    S=load('track0.mat');
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
    fid=fopen('carretera.txt','w');
    for h=1:numpanelesvertical+1
        fprintf(fid,'%f ',alturas_reales(h));
        for g=borde_izdo-2:borde_dcho+2      %Carretera y dos puntos mas por cada lado
            fprintf(fid,'%d ',indice(g,h));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
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
system('move ..\s11_m3d\salida\muro.x salida\muroizdo.x');

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
system('move ..\s11_m3d\salida\muro.x salida\murodcho.x');
%system('mv ../s11_m3d/salida/muro.x salida/murodcho.x');

fid_mtl=fopen(strcat('salida/transparente','.mtl'),'w');
fprintf(fid_mtl,'\nnewmtl material_%02d\nKa  0.6 0.6 0.6\nKd  0.6 0.6 0.6\nKs  0.9 0.9 0.9\nd  1.0\nNs  0.0\nillum 2\nmap_Kd %s\n',0,'transpa.dds');
fclose(fid_mtl);

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

 
    function salida=longitud(a,tam_elemento)
        if isempty(a)==0
            [mm,nn]=size(a);
            salida=mm*nn/tam_elemento;
        else
            salida=1;8
        end
    end

    function graba(x,y,z,tri,fi_nodos,fi_elem,fi_text,zone,uu,vv)%'salida/fichero_nodos.txt' 'salida/fichero_elements.txt' 'salida/texturas.txt'
        rango=(1:length(x));
        [s1,s2]=size(rango);if (s2<s1) rango=rango.';end
        [s1,s2]=size(x);if (s2<s1) x=x.';end
        [s1,s2]=size(y);if (s2<s1) y=y.';end
        [s1,s2]=size(z);if (s2<s1) z=z.';end

        fid=fopen(fi_nodos,'w');
        fprintf(fid,'%d %f %f %f\n',[rango' x' y' z']');%En este fichero la última columna es la altura
        fclose(fid);

        fid=fopen(fi_elem,'w');
        fprintf(fid,'%d 2 2 %d 0 %d %d %d  \n',[(1:longitud(tri,3))' zone' tri ]');
        fclose(fid);

        fid=fopen(fi_text,'w');
        fprintf(fid,'vt %f %f\n',[uu;vv]);
        fclose(fid);
    end
    
    end

end