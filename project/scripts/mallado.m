function mallado(amp_ruido,lasx,lasy,lasz)
   
generico=0;
numpal=20; %Numero total de paneles
ancho_carretera=5;%Ancho de la carretera en metros

if (nargin==0)|(nargin==3)
    amp_ruido=0;
end
if nargin<3
    if (generico==1)
        %A partir de nodos cualesquiera -> los llevamos a 4 m de distancia
        fid=fopen('nodes.txt');
        [salida]=textscan(fid,'%d %f %f %f %f %f');
        fclose(fid);

        x=salida{2};
        y=salida{3};
        z=salida

        distancias=sqrt(sum(diff(x).^2+diff(y).^2,2));
        distancia_acumulada=cumsum([0; distancias]);

        final=distancia_acumulada(end);

        lasx=interp1(distancia_acumulada,x,0:4:final,'PCHIP');
        lasy=interp1(distancia_acumulada,y,0:4:final,'PCHIP');
        lasz=interp1(distancia_acumulada,z,0:4:final,'PCHIP');

        %Recolocamos de nuevo
        distancias=sqrt(sum(diff(lasx').^2+diff(lasy').^2,2));
        distancia_acumulada=cumsum([0; distancias]);

        lasx=interp1(distancia_acumulada,lasx,0:4:final,'PCHIP');
        lasy=interp1(distancia_acumulada,lasy,0:4:final,'PCHIP');
        lasz=interp1(distancia_acumulada,z,0:4:final,'PCHIP');
    else %Cogemos los anchors del metodo zaxxon (puntos de enganche carretera-terreno)
    %     fid=fopen('anchorsM.mat');%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %     contenido=fread(fid,inf);
    %     fclose(fid);
    %     contenido=char(contenido)';
    %     posdatos=strfind(contenido,'columns:');
    %     fid=fopen('anchorsM.mat');
    %     fseek(fid,posdatos(1)+length('columns:'),'bof');    
    %     ncols=fscanf(fid,'%d',1);%Numero de anchors
    %     x=fscanf(fid,'%f',ncols);   
    %     fseek(fid,posdatos(3)+length('columns:'),'bof');    
    %     ncols=fscanf(fid,'%d',1);%Numero de anchors
    %     y=fscanf(fid,'%f');
    %     fclose(fid);
        S=load('anchors.mat');
        x=S.x;
        y=S.z;
        z=S.y;
        [m,n]=size(x);
         if n>m
             x=x';y=y';z=z';
         end

        lasx=0.5*(x(1:end/2)+x(end/2+1:end));
        lasy=0.5*(y(1:end/2)+y(end/2+1:end));
        lasz=0.5*(z(1:end/2)+z(end/2+1:end));
    end
end
[s1,s2]=size(lasx);if (s2>s1) lasx=lasx.';lasy=lasy.';lasz=lasz.';end

distancias=sqrt(sum(diff(lasx).^2+diff(lasy).^2,2));
distancia_acumulada=cumsum([0; distancias]);

%Ancho (m) de los paneles
panelesTRESMETROS=numpal/2-4-1;%Total menos los que son de carretera y los dos de los extremos
paneles_carretera=(ancho_carretera/5)*[0.75 0.75 1.25 1.25 1.25 1.25 0.75 0.75];
dist=[5 3*ones(1,panelesTRESMETROS) paneles_carretera 3*ones(1,panelesTRESMETROS) 5];

%numpal=length(dist);
%%%%%%%%%%%%%%%%%%%%%%BORDES CARRETERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
borde_izdo=numpal/2-3;
borde_dcho=numpal/2+5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%BORDES MURO%%%%%%%%%%%%%%%%
pos_muro_izq=2;%4;  %--%--%--%
pos_muro_dcho=numpal;%numpal-2; %--%--%--% numpal+1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

peralte=calcula_curvatura(lasx,lasy,distancias,dist,borde_izdo,borde_dcho,amp_ruido);

%figure,plot(x(1),y(1),'*');
%hold on
%plot(x,y);
%pause
%Puntos con los que aproximamos la perpendicular
mispuntos=lasx+1j*lasy;
antesx=interp1(distancia_acumulada,lasx,distancia_acumulada-0.25,'PCHIP','extrap');
despuesx=interp1(distancia_acumulada,lasx,distancia_acumulada+0.25,'PCHIP','extrap');
antesy=interp1(distancia_acumulada,lasy,distancia_acumulada-0.25,'PCHIP','extrap');
despuesy=interp1(distancia_acumulada,lasy,distancia_acumulada+0.25,'PCHIP','extrap');

vector_perpendicular=-((antesy-despuesy)+1j*( despuesx-antesx));
cambio=abs(0.5*angle(diff(mispuntos(1:end-1)))+0.5*angle(diff(mispuntos(2:end))))/(2*pi);
cambio_angulo=[1; 1-cambio.^1.5;1];
dir_suavizada=filter([0.15 0.2 0.4 0.2 0.15],1,vector_perpendicular);
dir_suavizada=[vector_perpendicular(1); vector_perpendicular(2); dir_suavizada(5:end-4) ;dir_suavizada(end-4); vector_perpendicular(end-3); vector_perpendicular(end-2); vector_perpendicular(end-1) ; vector_perpendicular(end); vector_perpendicular(end);]
vector_perpendicular=abs(vector_perpendicular).*exp(1j*angle(dir_suavizada))./cambio_angulo;
numpanelesvertical=length(lasx)-1;

quads=zeros(3,numpanelesvertical);%xmin,ymin,ymax


%18x100 paneles
%El primer y ultimo panel seria la parte no conducible (lo pongo por coherencia con
%la forma de trabajar antigua)


mitad=sum(dist(1:length(dist)/2));


%Forzamos que los 9 valores centrales vayan entre u1=0.5-0.0525 y u2=0.5+0.0525
u1=0.5-0.063;
u2=0.5+0.063;

uinicial=linspace(0,u1,6);
ufinal=linspace(u2,1,6);

u_texturas=[-uinicial(2) uinicial(1:end-1) linspace(u1,u2,9) ufinal(2:end) ufinal(end)+uinicial(2)];

contador=1;
contadorp=1;



%Creamos el mallado de puntos
contadorp=1;

%Borde izdo
lperal=length(peralte(1,:));
for h=1:numpanelesvertical+1
    inclinacion=[zeros(1,numpal/2-(lperal-1)/2) peralte(h,:) zeros(1,numpal/2-(lperal-1)/2)];
    for g=borde_izdo
        indice(g,h)=contadorp; %A la esquina inferior izquierda le asignamos un numero de punto
        %La coordenada está expresada como número complejo
        base=lasx(h)+1j*lasy(h);
        num=base+(mitad-sum(dist(g:end)))*vector_perpendicular(h);% +1j* (h-1)*4;
        coordenadas(g,h)=num;
        x(contadorp)=real(num);
        y(contadorp)=imag(num);
        z(contadorp)=lasz(h)+inclinacion(g);
        u(contadorp)=u_texturas(g);
        v(contadorp)=distancia_acumulada(h)/80;%Cada 80 metros se repite
        contadorp=contadorp+1;
    end
end

for h=1:numpanelesvertical+1
    inclinacion=[zeros(1,numpal/2-(lperal-1)/2) peralte(h,:) zeros(1,numpal/2-(lperal-1)/2)];
    for g=borde_dcho
        indice(g,h)=contadorp; %A la esquina inferior izquierda le asignamos un numero de punto
        %La coordenada está expresada como número complejo
        base=lasx(h)+1j*lasy(h);
        num=base+(mitad-sum(dist(g:end)))*vector_perpendicular(h);% +1j* (h-1)*4;
        coordenadas(g,h)=num;
        x(contadorp)=real(num);
        y(contadorp)=imag(num);
        z(contadorp)=lasz(h)+inclinacion(g);
        u(contadorp)=u_texturas(g);
        v(contadorp)=distancia_acumulada(h)/80;%Cada 80 metros se repite
        contadorp=contadorp+1;
    end
end
% 
%Numeramos el resto de nodos
for h=1:numpanelesvertical+1
    inclinacion=[zeros(1,numpal/2-(lperal-1)/2) peralte(h,:) zeros(1,numpal/2-(lperal-1)/2)];
    for g=[1:(borde_izdo-1) (borde_izdo+1):(borde_dcho-1) (borde_dcho+1):(numpal+1)]
        indice(g,h)=contadorp; %A la esquina inferior izquierda le asignamos un numero de punto
        %La coordenada está expresada como número complejo
        base=lasx(h)+1j*lasy(h);
        num=base+(mitad-sum(dist(g:end)))*vector_perpendicular(h);% +1j* (h-1)*4;
        coordenadas(g,h)=num;
        x(contadorp)=real(num);
        y(contadorp)=imag(num);
        z(contadorp)=lasz(h)+inclinacion(g);
        u(contadorp)=u_texturas(g);
        v(contadorp)=distancia_acumulada(h)/80;%Cada 80 metros se repite
        contadorp=contadorp+1;
    end
end




%Creamos quads que cubren todos los puntos, caracterizados por sus
%xmin,ymin e ymax de la rejilla
for h=1:numpanelesvertical
    for g=1:numpal
        quads(1,contador)=g;
        quads(2,contador)=h;
        quads(3,contador)=h+1;
        if (g<pos_muro_izq) || (g>=pos_muro_dcho)
            zonaquad(contador)=222;
        else
            zonaquad(contador)=111;
        end
        contador=contador+1;            
    end
end

%Recorremos todo el mallado, y si algún segmento vertical tiene menos de
%2m, lo juntamos con el siguiente panel en vertical
%fprintf(2,'D\n');
tria=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
tieneD=zeros(1,numpanelesvertical);
ll=0;
[quads,tria,tieneD,nzona,zonaquad]=optimizaD((numpal/2)-4:-1:4,quads,tria,numpanelesvertical,indice,[0 0.95],tieneD,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
[quads,tria,tieneD,nzona,zonaquad]=optimizaD(3:-1:2,quads,tria,numpanelesvertical,indice,[0 2],tieneD,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
%zonatria=111*ones(1,longitud(tria,3));

tieneD=ones(1,numpanelesvertical); %Forzamos quads
[quads,tria,tieneD,nzona,zonaquad]=optimizaD(1,quads,tria,numpanelesvertical,indice,[0 2],tieneD,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
tieneD=zeros(1,numpanelesvertical);%Forzamos Ds
[quads,tria,tieneD,nzona,zonaquad]=optimizaD(1,quads,tria,numpanelesvertical,indice,[0.75 1.05],tieneD,coordenadas,4,zonaquad);%Forzamos Ds
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
%
%
%fprintf(2,'C\n');
tieneC=zeros(1,numpanelesvertical);
[quads,tria,tieneC,nzona,zonaquad]=optimizaC((numpal/2)+5:numpal-3,quads,tria,numpanelesvertical,indice,[0 0.95],tieneC,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
[quads,tria,tieneC,nzona,zonaquad]=optimizaC(numpal-2:numpal-1,quads,tria,numpanelesvertical,indice,[0 2],tieneC,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
tieneC=ones(1,numpanelesvertical); %Forzamos quads
[quads,tria,tieneC,nzona,zonaquad]=optimizaC(numpal,quads,tria,numpanelesvertical,indice,[0 2],tieneC,coordenadas,2,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);
tieneC=zeros(1,numpanelesvertical);
[quads,tria,tieneC,nzona,zonaquad]=optimizaC(numpal,quads,tria,numpanelesvertical,indice,[0.75 1.05],tieneC,coordenadas,4,zonaquad);
if isempty(nzona)==0,zonatria(ll+1:longitud(tria,3))=nzona;end,ll=length(zonatria);

contadort=1;
for contador=1:longitud(quads,3)
     if (quads(1,contador)~=-1)
        n1(contadort)= indice(quads(1,contador),quads(2,contador));%xmin,ymin
        n2(contadort)= indice(quads(1,contador),quads(3,contador));%xmin,ymax
        n3(contadort)= indice(quads(1,contador)+1,quads(3,contador));%xmax,ymax (siempre es +1, pues no se unen rectángulos en dimensión x)
        if (quads(1,contador)<pos_muro_izq) || (quads(1,contador)>=pos_muro_dcho)
            zone(contadort)=222;
            zone(contadort+1)=222;
        else
            zone(contadort)=111;
            zone(contadort+1)=111;
        end
        contadort=contadort+1;
        n1(contadort)= indice(quads(1,contador),quads(2,contador));%xmin,ymin
        n2(contadort)= indice(quads(1,contador)+1,quads(3,contador));%xmax,ymax
        n3(contadort)= indice(quads(1,contador)+1,quads(2,contador));%xmax,ymin
        contadort=contadort+1;
    end
end

tri=[n1' n2' n3'];%[n1' n2' n3'];
tri=[tri;tria];%Anyadimos los triangulos
tri=[tri(:,1) tri(:,3) tri(:,2)]; %Normales hacia arriba
zone=[zone zonatria];
trimesh(tri,x,y,z);
axis('equal')

ii=find(zone==111);
graba(x,y,z,tri(ii,:),'salida/nodos0.txt','salida/elements0.txt','salida/texturas0.txt',zone(ii),u,v);
ii=find(zone==222);
graba(x,y,z,tri(ii,:),'salida/nodos1.txt','salida/elements1.txt','salida/texturas1.txt',zone(ii),u,v);

msh_to_obj('salida/nodos0.txt','salida/elements0.txt','test.mtl');
system('copy salida\test.obj+salida\texturas0.txt salida\contexturas0.obj');
system('cat salida/test.obj salida/texturas0.txt > salida/contexturas0.obj');

msh_to_obj('salida/nodos1.txt','salida/elements1.txt','test.mtl');
system('copy salida\test.obj+salida\texturas1.txt salida\contexturas1.obj');
system('cat salida/test.obj salida/texturas1.txt > salida/contexturas1.obj');

system('copy salida\fichero_nodos.txt ..\s1_mesh\salida\nodos.txt');
system('copy salida\fichero_elements.txt ..\s1_mesh\salida\elements.txt');

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
        for g=borde_izdo:borde_dcho
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
    alturas=procesar_nodostxt([0 0],[(1:length(murox))' murox' muroy' muroz'],'salida/nodosizdoelevados.txt');
catch
    alturas=muroz;
    fprintf(2,'Wall not raised\n');
end %_try_catch
ponmuro(murox,muroy,alturas,'izdo');
msh_to_obj('salida/nodosmuroizdo.txt','salida/elementsmuroizdo.txt','transparente.mtl');
system('copy salida\test.obj+salida\texturasmuroizdo.txt salida\muroizdo.obj');
system('cat salida/test.obj salida/texturasmuroizdo.txt > salida/muroizdo.obj');

%Muro dcho
indmuro=indice(pos_muro_dcho,:);
murox=x(indmuro(1:4:end));
muroy=y(indmuro(1:4:end));
muroz=z(indmuro(1:4:end));
murox=fliplr(murox);muroy=fliplr(muroy);muroz=fliplr(muroz);%Forma sencilla de invertir las normales

try
    alturas=procesar_nodostxt([0 0],[(1:length(murox))' murox' muroy' muroz'],'salida/nodosdchoelevados.txt');
catch
    alturas=muroz;
    fprintf(2,'Wall not raised\n');
end %_try_catch
ponmuro(murox,muroy,alturas,'dcho');
msh_to_obj('salida/nodosmurodcho.txt','salida/elementsmurodcho.txt','transparente.mtl');
system('copy salida\test.obj+salida\texturasmurodcho.txt salida\murodcho.obj');
system('cat salida/test.obj salida/texturasmurodcho.txt > salida/murodcho.obj');


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

    function [implicados,trias]=insertarC(x,ymin,losquads,indice,tamanyo)
        primero=-1;
        segundo=-1;
        trias=[];
        for hp=1:length(losquads)            
            if (losquads(1,hp)~=-1) && (losquads(1,hp)==x) && (losquads(2,hp)==ymin)
                primero=hp;
                primera_altura=losquads(3,hp);%Donde acaba el primer quad
                ymax=ymin+tamanyo;
            end            
        end
        if primero~=-1            
            for hp=1:length(losquads)
                if (losquads(1,hp)~=-1) && (losquads(1,hp)==x) && (losquads(2,hp)==primera_altura) && (losquads(3,hp)==ymax)
                 segundo=hp;                        
                 trias=[indice(x,primera_altura) indice(x+1,ymax) indice(x+1,ymin) ;%izdacentro arribadcha abajodcha
                     indice(x,ymax) indice(x+1,ymax) indice(x,primera_altura);
                     indice(x,ymin) indice(x,primera_altura) indice(x+1,ymin) ];
                end                
            end
        end
        implicados=[primero segundo];
        
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [implicados,trias]=insertarD(x,ymin,losquads,indice,tamanyo)
        primero=-1;
        segundo=-1;
        trias=[];
        for hp=1:length(losquads)            
            if (losquads(1,hp)~=-1) && (losquads(1,hp)==x) && (losquads(2,hp)==ymin)
                primero=hp;
                primera_altura=losquads(3,hp);%Donde acaba el primer quad
                ymax=ymin+tamanyo;
            end            
        end
        if primero~=-1            
            for hp=1:length(losquads)
                if (losquads(1,hp)~=-1) && (losquads(1,hp)==x) && (losquads(2,hp)==primera_altura) && (losquads(3,hp)==ymax)
                 segundo=hp;                        
                 trias=[indice(x,ymin) indice(x,losquads(3,hp)) indice(x+1,primera_altura);%abazoizda arribaizda derechacentro
                     indice(x,losquads(3,hp)) indice(x+1,losquads(3,hp)) indice(x+1,primera_altura);%arribaizda arribadcha derechacentro
                     indice(x,ymin) indice(x+1,primera_altura) indice(x+1,ymin) ];
                end                
            end
        end
        implicados=[primero segundo];
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [implicados nuevo]=juntaquads(x,ymin,losquads)
    %Junta un quad con el siguiente    
        primero=-1;
        segundo=-1;
        nuevo=[];
        for hp=1:length(losquads)            
            if (losquads(1,hp)~=-1) &&(losquads(1,hp)==x) && (losquads(2,hp)==ymin)
                primero=hp;
                primera_altura=losquads(3,hp);%Donde acaba el primer quad
                ymax=ymin+2;
            end            
        end
        if primero~=-1            
            for hp=1:length(losquads)
                if (losquads(1,hp)~=-1) &&(losquads(1,hp)==x) && (losquads(2,hp)==primera_altura) && (losquads(3,hp)==ymax)
                 segundo=hp;                        
                 %nuevo=[indice(x,ymin) indice(x+1,ymin) indice(x,losquads(3,h))];
                 nuevo=[x ymin losquads(3,hp)];
                end                
            end
        end
        implicados=[primero segundo];
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function salida=localizaquad(x,y,losquads)
        salida=-1;
        for hp=1:length(losquads)
            
            if (losquads(1,hp)~=-1) &&(losquads(1,hp)==x) && (losquads(2,hp)==y)
                salida=hp;
            end            
        end
    end


    function [losquads,tria,tieneDD,nuevazona,zquad]=optimizaD(rango,losquads,tria,numpanelesvertical,indices,tamlimite,tieneDD,coor,tamanyo,zquad)
        %tieneD=zeros(1,numpanelesvertical);
        nuevazona=[];
        for gg=rango%En horizontal
            for pp=1:1:numpanelesvertical-1
                %En vertical
                %if (gg==2)
                %    fprintf(2,'%d',pp);
                %end
                pppar=fix((pp-1)/2)*2+1;
                pos=localizaquad(gg,pp,losquads);
                if (pos~=-1) %&& (tieneDD(pppar)==0) %Si ya hemos hecho un quad o una D en el quad, nos vamos
                    punto1=coor(losquads(1,pos),losquads(2,pos));%xmin,ymin del quad
                    punto2=coor(losquads(1,pos),losquads(3,pos));%xmin,ymax del quad
                    punto3=coor(losquads(1,pos)+1,losquads(2,pos));%xmax,ymin del quad
                    punto4=coor(losquads(1,pos)+1,losquads(3,pos));%xmax,ymax del quad
                    separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                    %Si se hace peque�o hacia la izquierda
                    %separacion1<separacion2
                    ratio=separacion1/separacion2;
                    if ((ratio<=tamlimite(2)) && (ratio>=tamlimite(1)))                        
                        if tieneDD(pppar)==1
                            %fprintf(2,'NQ h= %d  _ v= %d _ ratio=%f\n',gg,pppar,ratio);
                            [indi,nuevo]=juntaquads(gg,pppar,losquads);
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                losquads=[losquads nuevo'];
                                zquad(length(losquads))=zquad(indi(1));%Copiamos la zona de los quads desaparecidos
                            end
                        else                                                
                            %fprintf(2,'ID h= %d  _ v= %d _ ratio=%f\n',gg,pppar,ratio);
                            [indi,ntria]=insertarD(gg,pppar,losquads,indices,tamanyo);
                            %indi=[-1 -1];
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                tria=[tria;ntria];
                                tieneDD(pppar)=1;
                                [sa,sb]=size(ntria);
                                nuevazona=[nuevazona zquad(indi(1))*ones(1,sa*sb/3)];
                            end
                        end
                    end
                end
            end
        end
    end

    function [losquads,tria,tieneCC,nuevazona,zquad]=optimizaC(rango,losquads,tria,numpanelesvertical,indices,tamlimite,tieneCC,coor,tamanyo,zquad)
        %tieneC=zeros(1,numpanelesvertical);
        nuevazona=[];
        for gg=rango%En horizontal
            for p=1:1:numpanelesvertical-1 %En vertical
                
                pppar=fix((p-1)/2)*2+1;
                
                pos=localizaquad(gg,p,losquads);
                if pos~=-1
                    punto1=coor(losquads(1,pos),losquads(2,pos));
                    punto2=coor(losquads(1,pos),losquads(3,pos));
                    punto3=coor(losquads(1,pos)+1,losquads(2,pos));%xmax,ymin del quad
                    punto4=coor(losquads(1,pos)+1,losquads(3,pos));%xmax,ymax del quad
                    separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                    
                    ratio=separacion2/separacion1;
                    if ((ratio<=tamlimite(2)) && (ratio>=tamlimite(1)))
                        if tieneCC(pppar)==1
                            %fprintf(2,'NQ h= %d  _ v= %d _ ratio=%f\n',gg,pppar,ratio);
                            [indi,nuevo]=juntaquads(gg,pppar,losquads);
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                losquads=[losquads nuevo'];
                                zquad(length(losquads))=zquad(indi(1));%Copiamos la zona de los quads desaparecidos
                            end
                        else
                            %fprintf(2,'ID h= %d  _ v= %d _ ratio=%f\n',gg,pppar,ratio);
                            [indi,ntria]=insertarC(gg,pppar,losquads,indices,tamanyo);                            
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                tria=[tria;ntria];
                                tieneCC(pppar)=1;
                                [sa,sb]=size(ntria);
                                nuevazona=[nuevazona zquad(indi(1))*ones(1,sa*sb/3)];
                            end
                        end
                    end
                end
            end
        end
    end
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
