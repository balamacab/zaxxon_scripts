function calcular_pendientes(fichero_de_nodos_con_altura,fichero_elements,id_conducible)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin<3
    display('Calcula la forma que debe tener la carretera examinando la pendiente que hay desde los anchors de la carretera,');
    display('los nac primeros, hacia los anchors a ellos enganchados')
    display(' ')
    display('Ejemplo: calcular_pendientes(''anchors_originales.mat'',''elements.txt'',111)');
    display(' ')
    display('Parámetros:');
    display('1) Fichero con todos los anchors (Ej: anchors_originales.mat');
    display('2) Fichero con los triángulos  (Ej: elements.txt');
    display('3) Identificador de la zona conducible  (Ej: 111')
    display(' ');
    display('Genera pendientes.mat');
    return;
end

S=load('..\nac.mat')
nac=S.nac;
%nac es el número de anchors de la carretera
%Si son 7824 la numeración de los enganches de la carretera llega desde 0 hasta
%nac-1=7823

S=load(fichero_de_nodos_con_altura);
x=S.datax;
y=S.datay;
z=S.dataz;

S=load('..\anchors.mat');
orig_x=S.x;
orig_y=S.y;
orig_z=S.z;

x(1:nac)=orig_x;
y(1:nac)=orig_y;
z(1:nac)=orig_z;

% S=load('conducibles_originales.mat'); %Numerados de 1 en adelante
% n1=S.data1;
% n2=S.data2;
% n3=S.data3;

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');
% contador_c=1;
% for h=1:length(n1)
%     if length(find(id_conducible==id_superficie(h)))>0
%         data1(contador_c,1)=n1(h);
%         data2(contador_c,1)=n2(h);
%         data3(contador_c,1)=n3(h);
%         contador_c=contador_c+1;
%     end
% end

tamanyo=length(n1);

fid=fopen('salida\pendientes.geo','w');

yaconsideradas=zeros(tamanyo,1);
pendiente=zeros(tamanyo,1);
vector=zeros(tamanyo,3);
contadorpuntos=1;
contadorlineas=1;
for h=1:tamanyo
    if length(find(id_conducible==id_superficie(h)))>0
        for nvertice=1:3
            if nvertice==1
                vertice=n1(h);
                vertice_a=n2(h);
                vertice_b=n3(h);
            end
            if nvertice==2
                vertice=n2(h);
                vertice_a=n1(h);
                vertice_b=n3(h);
            end 
            if nvertice==3
                vertice=n3(h);
                vertice_a=n1(h);
                vertice_b=n2(h);
            end
            if (vertice<=nac)    %Es un anchor de carretera
                fprintf(fid,'Point(%d)={%f, %f, %f, 1};\n',contadorpuntos,x(vertice),z(vertice),y(vertice)); 
                inicio=contadorpuntos;
                contadorpuntos=contadorpuntos+1;
                if (vertice_a>nac) %Y n2(h) no lo es
                    distancia=sqrt((x(vertice)-x(vertice_a))^2+(z(vertice)-z(vertice_a))^2);
                    desnivel=y(vertice_a)-y(vertice);
                    if distancia>0.5
                        pendiente(vertice)=(desnivel/distancia+yaconsideradas(vertice)*pendiente(vertice))/(yaconsideradas(vertice)+1);
                        vector(vertice,:)=([x(vertice_a)-x(vertice) y(vertice_a)-y(vertice) z(vertice_a)-z(vertice)]+yaconsideradas(vertice)*vector(vertice,:))/(yaconsideradas(vertice)+1);
                        yaconsideradas(vertice)=yaconsideradas(vertice)+1;
                        fprintf(fid,'Point(%d)={%f, %f, %f, 1};\n',contadorpuntos,x(vertice_a),z(vertice_a),y(vertice_a));
                        fprintf(fid,'Line(%d)={%d, %d};\n',contadorlineas,inicio,contadorpuntos);
                        contadorpuntos=contadorpuntos+1;
                        contadorlineas=contadorlineas+1;
                    end
                end
                if (vertice_b>nac) %Y n2(h) no lo es
                    distancia=sqrt((x(vertice)-x(vertice_b))^2+(z(vertice)-z(vertice_b))^2);
                    desnivel=y(vertice_b)-y(vertice);
                    if distancia>0.5
                        pendiente(vertice)=(desnivel/distancia+yaconsideradas(vertice)*pendiente(vertice))/(yaconsideradas(vertice)+1);
                        vector(vertice,:)=([x(vertice_b)-x(vertice) y(vertice_b)-y(vertice) z(vertice_b)-z(vertice)]+yaconsideradas(vertice)*vector(vertice,:))/(yaconsideradas(vertice)+1);
                        yaconsideradas(vertice)=yaconsideradas(vertice)+1;
                        fprintf(fid,'Point(%d)={%f, %f, %f, 1};\n',contadorpuntos,x(vertice_b),z(vertice_b),y(vertice_b));
                        fprintf(fid,'Line(%d)={%d, %d};\n',contadorlineas,inicio,contadorpuntos);
                        contadorpuntos=contadorpuntos+1;
                        contadorlineas=contadorlineas+1;
                    end
                end
            end
        end
    end
end

fclose(fid);

for h=1:nac
    separacion(h)=sqrt( vector(h,1)^2+vector(h,3)^2 );
    desnivel(h)=vector(h,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for h=1:nac
    h
    if (norm(vector(h,:))==0)
       separacion(h)=(separacion(h-1)+separacion(h+1))/2
       desnivel(h)=(desnivel(h-1)+desnivel(h+1))/2
       if (separacion(h+1)==0) || (separacion(h-1)==0)
           desnivel(h)=0;
           separacion(h)=1;%Para que de pediente 0
       end       
    end
    pendiente(h)=desnivel(h)/separacion(h);
end

pendiente_izquierda = sgolayfilt(pendiente(1:nac/2),3,41);
pendiente_derecha = sgolayfilt(pendiente(nac/2+1:nac),3,41);

fprintf(1,'Ejecute crear_superficies.m\n');

save('pendientes.mat','pendiente_izquierda','pendiente_derecha')

end
