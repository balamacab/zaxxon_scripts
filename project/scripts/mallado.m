function mallado(lasx,lasy,lasz)
   
generico=0;
if nargin==0
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
    %     S=load('anchors.mat');
    %     x=S.x;
    %     y=S.y;
        lasx=0.5*(x(1:end/2)+x(end/2+1:end));
        lasy=0.5*(y(1:end/2)+y(end/2+1:end));
        lasz=0.5*(z(1:end/2)+z(end/2+1:end));
    end
end
[s1,s2]=size(lasx);if (s2>s1) lasx=lasx.';lasy=lasy.';lasz=lasz.';end

distancias=sqrt(sum(diff(lasx).^2+diff(lasy).^2,2));
distancia_acumulada=cumsum([0; distancias]);

dist=[5 3 3 3 3 3 0.75 0.75 1.25 1.25 1.25 1.25 0.75 0.75 3 3 3 3 3 5];

numpal=length(dist);
borde_izdo=numpal/2-3;
borde_dcho=numpal/2+5;
peralte=calcula_curvatura(lasx,lasy,distancias,dist,borde_izdo,borde_dcho);

%figure,plot(x(1),y(1),'*');
%hold on
%plot(x,y);
%pause
%Puntos con los que aproximamos la perpendicular
antesx=interp1(distancia_acumulada,lasx,distancia_acumulada-0.25,'PCHIP','extrap');
despuesx=interp1(distancia_acumulada,lasx,distancia_acumulada+0.25,'PCHIP','extrap');
antesy=interp1(distancia_acumulada,lasy,distancia_acumulada-0.25,'PCHIP','extrap');
despuesy=interp1(distancia_acumulada,lasy,distancia_acumulada+0.25,'PCHIP','extrap');

vector_perpendicular=(antesy-despuesy)+1j*( despuesx-antesx);

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
        contador=contador+1;            
    end
end

%Recorremos todo el mallado, y si algún segmento vertical tiene menos de
%2m, lo juntamos con el siguiente panel en vertical
tria=[];
tieneD=zeros(1,numpanelesvertical);
[quads,tria,tieneD]=optimizaD((numpal/2):-1:4,quads,tria,numpanelesvertical,indice,2.75,tieneD,coordenadas,2);
[quads,tria,tieneD]=optimizaD(3:-1:2,quads,tria,numpanelesvertical,indice,15,tieneD,coordenadas,2);
tieneD=ones(1,numpanelesvertical);
zonatria=111*ones(1,longitud(tria,3));
ll=length(zonatria);
[quads,tria,tieneD]=optimizaD(1,quads,tria,numpanelesvertical,indice,100,tieneD,coordenadas,2);
if isempty(tria)==0
    zonatria(ll:longitud(tria,3))=222;
end
ll=length(zonatria);
%Forzamos quads
tieneD=zeros(1,numpanelesvertical);
%Forzamos Ds
[quads,tria,tieneD]=optimizaD(1,quads,tria,numpanelesvertical,indice,100,tieneD,coordenadas,4);
tieneC=zeros(1,numpanelesvertical);
[quads,tria,tieneC]=optimizaC((numpal/2)+1:numpal-3,quads,tria,numpanelesvertical,indice,2.75,tieneC,coordenadas,2);
[quads,tria,tieneC]=optimizaC(numpal-2:numpal-1,quads,tria,numpanelesvertical,indice,15,tieneC,coordenadas,2);
tieneC=ones(1,numpanelesvertical);
[quads,tria,tieneC]=optimizaC(numpal,quads,tria,numpanelesvertical,indice,100,tieneC,coordenadas,2);
if isempty(tria)==0
    zonatria(ll:longitud(tria,3))=111;
end
tieneC=zeros(1,numpanelesvertical);
[quads,tria,tieneC]=optimizaC(numpal,quads,tria,numpanelesvertical,indice,100,tieneC,coordenadas,4);
if isempty(tria)==0
    zonatria(ll:longitud(tria,3))=222;
end

contadort=1;
for contador=1:longitud(quads,3)
     if (quads(1,contador)~=-1)
        n1(contadort)= indice(quads(1,contador),quads(2,contador));
        n2(contadort)= indice(quads(1,contador),quads(3,contador));
        n3(contadort)= indice(quads(1,contador)+1,quads(3,contador));
        if (quads(1,contador)==1) || (quads(1,contador)==numpal)
            zone(contadort)=222;
            zone(contadort+1)=222;
        else
            zone(contadort)=111;
            zone(contadort+1)=111;
        end
        contadort=contadort+1;
        n1(contadort)= indice(quads(1,contador),quads(2,contador));
        n2(contadort)= indice(quads(1,contador)+1,quads(3,contador));
        n3(contadort)= indice(quads(1,contador)+1,quads(2,contador));
        contadort=contadort+1;
    end
end

tri=[n1' n2' n3'];
tri=[tri;tria];%Anyadimos los triangulos
zone=[zone zonatria];
%trimesh(tri,x,y,z);

rango=(1:length(x));[s1,s2]=size(rango);if (s2>s1) rango=rango.';end

fid=fopen('salida/fichero_nodos.txt','w');
fprintf(fid,'%d %f %f %f\n',[rango' x' y' z']');
fclose(fid);

fid=fopen('salida/fichero_elements.txt','w');
fprintf(fid,'%d 2 2 %d 0 %d %d %d  \n',[(1:longitud(tri,3))' zone' tri ]');
fclose(fid);

fid=fopen('salida/texturas.txt','w');
fprintf(fid,'vt %f %f\n',[u;v]);
fclose(fid);

msh_to_obj('salida/fichero_nodos.txt','salida/fichero_elements.txt');
system('copy salida\fichero_nodos.txt ..\s1_mesh\salida\nodos.txt');
system('copy salida\fichero_elements.txt ..\s1_mesh\salida\elements.txt');
%system('cp salida/fichero_nodos.txt ../s1_mesh/salida/nodos.txt');
%system('cp salida/fichero_elements.txt ../s1_mesh/salida/elements.txt');



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

%figure,plot(lasx,lasy);
%msh_to_obj('fichero_nodos.txt','fichero_elements.txt')
%msh_to_obj('nodos_conaltura.txt','fichero_elements.txt')
%system('copy test.obj+texturas.txt test_texturas.obj');
%system('cat salida/test.obj texturas.txt > test_texturas.obj');
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


    function [losquads,tria,tieneDD]=optimizaD(rango,losquads,tria,numpanelesvertical,indices,tamlimite,tieneDD,coor,tamanyo)
        %tieneD=zeros(1,numpanelesvertical);
        for gg=rango%En horizontal
            for pp=1:2:numpanelesvertical
                %En vertical
                pos=localizaquad(gg,pp,losquads);
                if pos~=-1
                    punto1=coor(losquads(1,pos),losquads(2,pos));%xmin,ymin del quad
                    punto2=coor(losquads(1,pos),losquads(3,pos));%xmin,ymax del quad
                    separacion=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    if separacion<tamlimite
                        if tieneDD(pp)==1
                            [indi,nuevo]=juntaquads(gg,pp,losquads);
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                losquads=[losquads nuevo'];                        
                            end
                        else                                                
                            [indi,ntria]=insertarD(gg,pp,losquads,indices,tamanyo);
                            %indi=[-1 -1];
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                tria=[tria;ntria];
                                tieneDD(pp)=1;
                            end
                        end
                    end
                end
            end
        end
    end

    function [losquads,tria,tieneCC]=optimizaC(rango,losquads,tria,numpanelesvertical,indices,tamlimite,tieneCC,coor,tamanyo)
        %tieneC=zeros(1,numpanelesvertical);
        for gg=rango%En horizontal
            for p=1:2:numpanelesvertical %En vertical
                pos=localizaquad(gg,p,losquads);
                if pos~=-1
                    punto1=coor(losquads(1,pos),losquads(2,pos));
                    punto2=coor(losquads(1,pos),losquads(3,pos));
                    separacion=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    if separacion<tamlimite
                        if tieneCC(p)==1
                            [indi,nuevo]=juntaquads(gg,p,losquads);
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                losquads=[losquads nuevo'];                         
                            end
                        else                                                
                            [indi,ntria]=insertarC(gg,p,losquads,indices,tamanyo);                            
                            if (indi(1)~=-1) && (indi(2)~=-1)
                                losquads(1,indi(1))=-1;
                                losquads(1,indi(2))=-1;
                                tria=[tria;ntria];
                                tieneCC(p)=1;
                            end
                        end
                    end
                end
            end
        end
    end
    function salida=longitud(a,tam_elemento)
        if isempty(a)==0
            [m,n]=size(a);
            salida=m*n/tam_elemento;
        else
            salida=1;
        end
    end
    
    end
