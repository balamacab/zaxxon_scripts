function mallado(params,lasx,lasy,lasz)
   
generico=0;
numpal=20; %Numero total de paneles

orientacion=1;

if nargin<3
    if (generico==1)
        %A partir de nodos cualesquiera -> los llevamos a 4 m de distancia
        fid=fopen('nodes.txt');
        [salida]=textscan(fid,'%d %f %f %f %f %f');
        fclose(fid);

        x=salida{2};
        y=salida{3};
        z=salida{4};%¿Estaba incompleto?

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
        orientacion=1;
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
if (nargin==0)|(nargin==3)
    amp_ruido=0;
    ancho_carretera=5*ones(1,length(x));%Ancho de la carretera en metros

else
    amp_ruido=params.amp_ruido;
    ancho_carretera=crearanchos(params.ancho_carretera,length(lasx));%Ancho de la carretera en metros
end

numpanelesvertical=length(lasx)-1;

distancias=sqrt(sum(diff(lasx).^2+diff(lasy).^2,2));
distancia_acumulada=cumsum([0; distancias]);

%Ancho (m) de los paneles
panelesTRESMETROS=numpal/2-4-1;%Total menos los que son de carretera y los dos de los extremos
%paneles_carretera=(ancho_carretera/sum([1.25 1.25 1.25 1.25]))*[0.75 0.75 1.25 1.25 1.25 1.25 0.75 0.75];
%dist=[5 3*ones(1,panelesTRESMETROS) paneles_carretera 3*ones(1,panelesTRESMETROS) 5];

for hh=1:numpanelesvertical+1
    paneles_carretera=(ancho_carretera(hh)/sum([1.25 1.25 1.25 1.25]))*[0.75 0.75 1.25 1.25 1.25 1.25 0.75 0.75];
    dist(:,hh)=[5 3*ones(1,panelesTRESMETROS) paneles_carretera 3*ones(1,panelesTRESMETROS) 5];
end
%numpal=length(dist);
%%%%%%%%%%%%%%%%%%%%%%BORDES CARRETERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
borde_izdo=numpal/2-3+2;%solo 4 paneles -1,0,1,2,3
borde_dcho=numpal/2+5-2;%solo 4 paneles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%BORDES MURO%%%%%%%%%%%%%%%%
pos_muro_izq=2;%4;  %--%--%--%
pos_muro_dcho=numpal;%numpal-2; %--%--%--% numpal+1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

peralte=calcula_curvatura(lasx,orientacion*lasy,distancias,dist,borde_izdo,borde_dcho,amp_ruido);

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
vector_perpendicular=vector_perpendicular./abs(vector_perpendicular);
%cambio=abs(diff(unwrap(0.5*angle(diff(mispuntos(1:end-1)))+0.5*angle(diff(mispuntos(2:end))))))/(2*pi);
cambio=abs(diff(unwrap(angle(diff(mispuntos(1:end))))))/(2*pi);
cambio=filter([0.1 0.3 0.5 0.3 0.1],1,cambio);
cambio=fliplr(flipud(filter([0.1 0.3 0.5 0.3 0.1],1,fliplr(flipud(cambio)))));
cambio_angulo=[1; 1-cambio.^0.7;1];
dir_suavizada=filter([0.15 0.2 0.4 0.2 0.15],1,vector_perpendicular);
dir_suavizada=[vector_perpendicular(1); vector_perpendicular(2); dir_suavizada(5:end-4) ;dir_suavizada(end-4); vector_perpendicular(end-3); vector_perpendicular(end-2); vector_perpendicular(end-1) ; vector_perpendicular(end); vector_perpendicular(end)];
vector_perpendicular=abs(vector_perpendicular).*exp(1j*angle(dir_suavizada))./cambio_angulo;




%18x100 paneles
%El primer y ultimo panel seria la parte no conducible (lo pongo por coherencia con
%la forma de trabajar antigua)
[ttt,yyy]=size(dist);
mitad=sum(dist(1:ttt/2,:));


%Forzamos que los 7 valores centrales vayan entre u1=0.5-0.0525 y u2=0.5+0.0525
u1=0.5-0.063+0.0085;
u2=0.5+0.063-0.0085;

%uinicial=linspace(0,u1,8);%6
%ufinal=linspace(u2,1,8);%6
dac=cumsum([0; dist(:,1)])';
uinicial=u1*(dac(2:9)-dac(2))/(dac(9)-dac(2));
ufinal=fliplr(1-uinicial);
u_texturas=[-uinicial(2) uinicial(1:end-1) linspace(u1,u2,5) ufinal(2:end) ufinal(end)+uinicial(2)];%9 en linspace

contador=1;
contadorp=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creamos el mallado de puntos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Matriz de nodos. 1) Izquierda (MSB el más a la izquierda) 2) Derecha (LSB
%el más de la derecha)
%
mascara=uint8([255-1 255-2 255-4 255-8 255-16 255-32 255-64 255-128]);
barridoizq(8)=mascara(8);
for ty=7:-1:1 %Para poner a cero desde el bit indicado (empezando en 1) hacia el MSB
    barridoizq(ty)=bitand(barridoizq(ty+1),mascara(ty));
end
barridoder(1)=mascara(1);
for ty=2:8 %Para poner a cero desde el bit indicado (empezando en 1) hacia el MSB
    barridoder(ty)=bitand(barridoder(ty-1),mascara(ty));
end
izquierdo=1;
derecho=2;
mnodos=uint8(255*ones(2,numpanelesvertical+1));
%En el lado izquierdo nos saltamos seguro 2 de cada 4
mnodos(izquierdo,2:4:end)=bitand(mnodos(izquierdo,2:4:end),barridoizq(6));
mnodos(izquierdo,4:4:end)=bitand(mnodos(izquierdo,4:4:end),barridoizq(6));
%Lo mismo en el lado derecho
mnodos(derecho,2:4:end)=bitand(mnodos(derecho,2:4:end),barridoder(3));
mnodos(derecho,4:4:end)=bitand(mnodos(derecho,4:4:end),barridoder(3));

contadorp=1;

%Borde izdo
lperal=length(peralte(1,:));
for h=1:numpanelesvertical+1
    inclinacion=[zeros(1,numpal/2-(lperal-1)/2) peralte(h,:) zeros(1,numpal/2-(lperal-1)/2)];
    for g=borde_izdo
        indice(g,h)=contadorp; %A la esquina inferior izquierda le asignamos un numero de punto
        %La coordenada está expresada como número complejo
        base=lasx(h)+1j*lasy(h);
        num=base+(mitad(h)-sum(dist(g:end,h)))*vector_perpendicular(h);% +1j* (h-1)*4;
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
        num=base+(mitad(h)-sum(dist(g:end,h)))*vector_perpendicular(h);% +1j* (h-1)*4;
        coordenadas(g,h)=num;
        x(contadorp)=real(num);
        y(contadorp)=imag(num);
        z(contadorp)=lasz(h)+inclinacion(g);
        u(contadorp)=u_texturas(g);
        v(contadorp)=distancia_acumulada(h)/80;%Cada 80 metros se repite
        contadorp=contadorp+1;
    end
end
%Reservamos a lo grande y luego recortaremos
tri=zeros(numpal*2*numpanelesvertical,3);
zone=zeros(1,numpal*2*numpanelesvertical);
contadortris=0;
%
%Numeramos el resto de nodos
for h=1:numpanelesvertical+1
    inclinacion=[zeros(1,numpal/2-(lperal-1)/2) peralte(h,:) zeros(1,numpal/2-(lperal-1)/2)];
    for g=[1:(borde_izdo-1) (borde_izdo+1):(borde_dcho-1) (borde_dcho+1):(numpal+1)]
        indice(g,h)=contadorp; %A la esquina inferior izquierda le asignamos un numero de punto
        %La coordenada está expresada como número complejo
        base=lasx(h)+1j*lasy(h);
        num=base+(mitad(h)-sum(dist(g:end,h)))*vector_perpendicular(h);% +1j* (h-1)*4;
        coordenadas(g,h)=num;
        x(contadorp)=real(num);
        y(contadorp)=imag(num);
        z(contadorp)=lasz(h)+inclinacion(g);
        u(contadorp)=u_texturas(g);
        v(contadorp)=distancia_acumulada(h)/80;%Cada 80 metros se repite
        contadorp=contadorp+1;
    end
end

%Recorremos la parte izquierda
for pp=2:2:numpanelesvertical-1
            actual=mnodos(izquierdo,pp);
            siguiente=mnodos(izquierdo,pp+1);
            %El bit 3 es el primero eliminable (pendiente de parametrizar)
            elbit=3;
            while (elbit<8)
                punto1=coordenadas(9-elbit,pp);%xmin,ymin del quad
                punto2=coordenadas(9-elbit,pp+1);%xmin,ymax del quad
                punto3=coordenadas(9-elbit+1,pp);%xmax,ymin del quad
                punto4=coordenadas(9-elbit+1,pp+1);%xmax,ymax del quad
                separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                %Si se hace peque�o hacia la izquierda
                %separacion1<separacion2
                ratio=separacion1/separacion2;
                if (separacion1<3)
                    mnodos(izquierdo,pp)=bitand(mnodos(izquierdo,pp),barridoizq(elbit));
                end
                elbit=elbit+1;
            end
end

%Recorremos la parte derecha
for pp=2:2:numpanelesvertical-1
            actual=mnodos(derecho,pp);
            siguiente=mnodos(derecho,pp+1);
            %El bit 3 es el primero eliminable (pendiente de parametrizar)
            elbit=6;
            while (elbit>1)
                punto1=coordenadas(numpal+1-elbit,pp);%xmin,ymin del quad
                punto2=coordenadas(numpal+1-elbit,pp+1);%xmin,ymax del quad
                punto3=coordenadas(numpal+1-elbit+1,pp);%xmax,ymin del quad
                punto4=coordenadas(numpal+1-elbit+1,pp+1);%xmax,ymax del quad
                separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                %Si se hace peque�o hacia la izquierda
                %separacion1<separacion2
                ratio=separacion1/separacion2;
                if (separacion1<3)
                    mnodos(derecho,pp)=bitand(mnodos(derecho,pp),barridoder(elbit));
                end
                elbit=elbit-1;
            end
end

%
%Lateral izquierdo
for pp=1:2:numpanelesvertical-4
            actual=mnodos(izquierdo,pp);
            siguiente=mnodos(izquierdo,pp+2);
            if (bitand(actual,uint8(128+64))==uint8(128+64))&&(bitand(siguiente,uint8(128+64))==uint8(128+64))
                %El bit 3 es el primero eliminable (pendiente de parametrizar)
                elbit=7;
                %while (bitand(actual,2^elbit)>0)&&(elbit<8)
                    punto1=coordenadas(9-elbit,pp);%xmin,ymin del quad
                    punto2=coordenadas(9-elbit,pp+2);%xmin,ymax del quad
                    %punto3=coordenadas(9-elbit+1,pp);%xmax,ymin del quad
                    %punto4=coordenadas(9-elbit+1,pp+2);%xmax,ymax del quad
                    separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    %separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                    %Si se hace peque�o hacia la izquierda
                    %separacion1<separacion2
                    %ratio=separacion1/separacion2;
                    if (separacion1<5)
                        mnodos(izquierdo,pp+2)=bitand(mnodos(izquierdo,pp+2),barridoizq(elbit));
                    end
                 %   elbit=elbit+1;
                %end
            end
end

%Lateral derecho
for pp=1:2:numpanelesvertical-4
            actual=mnodos(derecho,pp);
            siguiente=mnodos(derecho,pp+2);
            if (bitand(actual,uint8(2+1))==uint8(2+1))&&(bitand(siguiente,uint8(2+1))==uint8(2+1))
                %El bit 3 es el primero eliminable (pendiente de parametrizar)
                elbit=numpal+1-2;
                %while (bitand(actual,2^elbit)>0)&&(elbit<8)
                    punto1=coordenadas(elbit,pp);%xmin,ymin del quad
                    punto2=coordenadas(elbit,pp+2);%xmin,ymax del quad
                    %punto3=coordenadas(9-elbit+1,pp);%xmax,ymin del quad
                    %punto4=coordenadas(9-elbit+1,pp+2);%xmax,ymax del quad
                    separacion1=sqrt((real(punto1)-real(punto2))^2+(imag(punto1)-imag(punto2))^2);
                    %separacion2=sqrt((real(punto3)-real(punto4))^2+(imag(punto3)-imag(punto4))^2);
                    %Si se hace peque�o hacia la izquierda
                    %separacion1<separacion2
                    %ratio=separacion1/separacion2;
                    if (separacion1<5)
                        mnodos(derecho,pp+2)=bitand(mnodos(derecho,pp+2),barridoder(2));
                    end
                 %   elbit=elbit+1;
                %end
            end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%zone=[];
%tri=[];
%Generamos los triangulos de la parte izquierda
for pp=1:numpanelesvertical-1
            actual=mnodos(izquierdo,pp);            
            %Si encontramos segmento, generamos el triangulo
            elbit=uint8(128+64);%11000000 que se desplaza hacia la derecha
            contadorbit=1;
            while (elbit>=3)  %00000011 es la ultima mascara
                if bitand(actual,elbit)==elbit
                     encontrado=false;
                     contador=1;
                     while encontrado==false;
                        siguiente=mnodos(izquierdo,pp+contador);
                        encontrado=(bitand(siguiente,elbit)==elbit);                                        
                        contador=contador+1;
                     end
                     contador=contador-1;

                     %Una vez encontrado el segmento opuesto, puede ser que
                     %haya nodo intermedio, formandose una D
                     esmitad=fix(contador/2);
                     if contador>1
                         intermedio=mnodos(izquierdo,pp+esmitad);
                         hayintermedio=(bitand(intermedio,elbit)>0);  
                     else
                         hayintermedio=0;
                     end
                     if contadorbit==1,lazona=222;else lazona=111;end
                     if hayintermedio
                         trias=[indice(contadorbit,pp) indice(contadorbit,pp+contador) indice(contadorbit+1,pp+esmitad) ;%izdacentro arribadcha abajodcha
                         indice(contadorbit,pp+contador) indice(contadorbit+1,pp+contador) indice(contadorbit+1,pp+esmitad);
                         indice(contadorbit,pp) indice(contadorbit+1,pp+esmitad) indice(contadorbit+1,pp) ];                     
                         zone(contadortris+1:contadortris+3)=lazona*ones(1,3);
                         tri(contadortris+1:contadortris+3,:)=trias; contadortris=contadortris+3;
                     else
                         trias=[indice(contadorbit,pp) indice(contadorbit,pp+contador) indice(contadorbit+1,pp) ;%izdacentro arribadcha abajodcha
                         indice(contadorbit,pp+contador) indice(contadorbit+1,pp+contador) indice(contadorbit+1,pp)                       ];                     
                         zone(contadortris+1:contadortris+2)=lazona*ones(1,2);
                         tri(contadortris+1:contadortris+2,:)=trias;contadortris=contadortris+2;
                     end
                                                           
                 
                end %if
                contadorbit=contadorbit+1;
                elbit=bitshift(elbit,-1);
            end %while
            
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%zone=[];
%tri=[];
%Generamos los triangulos de la parte derecha
for pp=1:numpanelesvertical-1
            actual=mnodos(derecho,pp);            
            %Si encontramos segmento, generamos el triangulo
            elbit=uint8(64+32);%01100000 que se desplaza hacia la derecha
            contadorbit=1;
            while (elbit>=3)  %00000011 es la ultima mascara
                if bitand(actual,elbit)==elbit
                     encontrado=false;
                     contador=1;
                     while encontrado==false;
                        siguiente=mnodos(derecho,pp+contador);
                        encontrado=(bitand(siguiente,elbit)==elbit);                                        
                        contador=contador+1;
                     end
                     contador=contador-1;

                     %Una vez encontrado el segmento opuesto, puede ser que
                     %haya nodo intermedio, formandose una C
                     esmitad=fix(contador/2);
                     if contador>1
                         intermedio=mnodos(derecho,pp+esmitad);
                         hayintermedio=(bitand(intermedio,elbit)>0);  
                     else
                         hayintermedio=0;
                     end
                     if contadorbit==6,lazona=222;else lazona=111;end
                     numeropanel=numpal-6+contadorbit;
                     if hayintermedio
                         trias=[indice(numeropanel,pp+esmitad) indice(numeropanel+1,pp+contador) indice(numeropanel+1,pp) ;%izdacentro arribadcha abajodcha
                         indice(numeropanel,pp+contador) indice(numeropanel+1,pp+contador) indice(numeropanel,pp+esmitad);
                         indice(numeropanel,pp) indice(numeropanel,pp+esmitad) indice(numeropanel+1,pp) ];                     
                         zone(contadortris+1:contadortris+3)=lazona*ones(1,3);
                         tri(contadortris+1:contadortris+3,:)=trias; contadortris=contadortris+3;
                     else
                         trias=[indice(numeropanel,pp) indice(numeropanel,pp+contador) indice(numeropanel+1,pp) ;%izdacentro arribadcha abajodcha
                         indice(numeropanel,pp+contador) indice(numeropanel+1,pp+contador) indice(numeropanel+1,pp)                       ];                     
                         zone(contadortris+1:contadortris+2)=lazona*ones(1,2);
                         tri(contadortris+1:contadortris+2,:)=trias;contadortris=contadortris+2;
                     end
                                                           
                 
                end %if
                contadorbit=contadorbit+1;
                elbit=bitshift(elbit,-1);
            end %while
            
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Ponemos la parte central
for pp=1:numpanelesvertical-1
            contador=1;
            for numeropanel=8:numpal+1-7
                         trias=[indice(numeropanel,pp) indice(numeropanel,pp+contador) indice(numeropanel+1,pp) ;%izdacentro arribadcha abajodcha
                         indice(numeropanel,pp+contador) indice(numeropanel+1,pp+contador) indice(numeropanel+1,pp)                       ];                     
                         zone(contadortris+1:contadortris+2)=111*ones(1,2);
                         tri(contadortris+1:contadortris+2,:)=trias;contadortris=contadortris+2;
            end                                                                                            
            
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tri=tri(1:contadortris,:);
%tri=[n1' n2' n3'];%[n1' n2' n3'];
%tri=[tri;tria];%Anyadimos los triangulos
tri=[tri(:,1) tri(:,3) tri(:,2)]; %Normales hacia arriba
%zone=[zone zonatria];
%trimesh(tri,x,y,z);
%axis('equal')

%Obtenemos alturas de montaña
try
    alturas=procesar_nodostxt([0 0],[(1:length(x))' x y z],'salida/n0elevados.txt');
catch
    alturas=z;
    fprintf(2,'nodos0 not raised\n');
end %_try_catch

save('salida/paraobjetos.mat');

ii=find(zone==111);
graba(x,y,alturas,tri(ii,:),'../s4_terrain/salida/nodos0.txt','../s4_terrain/salida/elements0.txt','../s4_terrain/salida/texturas0.txt',zone(ii),u,v);
ii=find(zone==222);
graba(x,y,alturas,tri(ii,:),'../s4_terrain/salida/nodos1.txt','../s4_terrain/salida/elements1.txt','../s4_terrain/salida/texturas1.txt',zone(ii),u,v);

msh_to_obj('../s4_terrain/salida/nodos0.txt','../s4_terrain/salida/elements0.txt','test.mtl');
system('copy salida\test.obj+..\s4_terrain\salida\texturas0.txt ..\s4_terrain\salida\contexturas0.obj');
%system('cat salida/test.obj salida/texturas0.txt > salida/contexturas0.obj');

msh_to_obj('../s4_terrain/salida/nodos1.txt','../s4_terrain/salida/elements1.txt','test.mtl');
system('copy salida\test.obj+..\s4_terrain\salida\texturas1.txt ..\s4_terrain\salida\contexturas1.obj');
%system('cat salida/test.obj salida/texturas1.txt > salida/contexturas1.obj');

system('copy ..\s4_terrain\salida\nodos0.txt ..\s1_mesh\salida\nodos.txt');
system('copy ..\s4_terrain\salida\elements0.txt ..\s1_mesh\salida\elements.txt');

fid_mtl=fopen(strcat('salida/test','.mtl'),'w');
fprintf(fid_mtl,'\nnewmtl material_%02d\nKa  0.6 0.6 0.6\nKd  0.6 0.6 0.6\nKs  0.9 0.9 0.9\nd  1.0\nNs  0.0\nillum 2\nmap_Kd %s\n',0,'Placa3.dds');
fclose(fid_mtl);


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

    function salida=crearanchos(anchos,longitud)
        hhh=1;
        anchos=[0 anchos];
        salida=anchos(2)*ones(1,longitud);
        hhh=hhh+2;
        while (hhh+1)<=length(anchos); 
            salida(round(anchos(hhh)*longitud):end)=anchos(hhh+1);
            hhh=hhh+2;
        end
        xx=filter([0.05 0.25 0.4 0.25 0.05],1,salida);
        xx=flipud(fliplr(filter([0.05 0.25 0.4 0.25 0.05],1,flipud(fliplr(xx)))));
        salida(10:end-9)=xx(10:end-9);
    end
    
    end
