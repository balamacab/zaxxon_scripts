function crear_superficies(fichero_todosanchors,fichero_pendientes,fichero_nodos_carretera,n_T,numnodos)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.



if nargin<5
    display('Calcula la forma que debe tener la carretera examinando la pendiente que hay desde los anchors de la carretera,');
    display('los nac primeros, hacia los anchors a ellos enganchados')
    display(' ')
    display('Ejemplo: crear_superficies(''anchors_originales.mat'',''pendientes.mat'',''nodos_carretera.mat'',5,7)');
    display(' ')
    display('Par�metros:');
    display('1) Fichero con todos los anchors Ej: anchors_originales.mat');
    display('2) Fichero pendientes (Ej: pendientes.mat');
    display('3) Fichero nodos de carretera (Ej: nodos_carretera.mat');
    display('4) Posici�n del nodo del terreno m�s cercano a la carretera. Ejemplo: 4.91 si se cre� con una surface que llegaba hasta 4.9 y el ancho del terreno creado fue de 0.01');
    display('5) N�mero de puntos de la carretera: 7 � 9');
    display(' ');
    display('Salida: surfaces.txt')
    display('Adem�s lee nac.mat');
    return;
end

ancho_s=0.1;
n_E=n_T-ancho_s; %Posici�n del nodo m�s externo de la carretera
n_I=n_E-ancho_s; %Posici�n del primer nodo interno de la carretera

%                  n_T ******************** n_E *******************n_I
%                          ancho_s=10cm          ancho_s=10cm
%                                             
%     <---20cm------|          <----5cm------|        <----5cm------|
%

S=load('..\nac.mat')
nac=S.nac;

S=load(fichero_pendientes)
p_izquierda=S.pendiente_izquierda;
p_derecha=S.pendiente_derecha;

S=load(fichero_nodos_carretera)
tree.Anchor=S.tree;
for h=1:length(tree.Anchor)
        elnodo(h)=tree.Anchor(h).StartNode  ;
        elporcentaje(h)=tree.Anchor(h).StartPercentage  ;
end

S=load('..\anchors.mat');
orig_x=S.x;
orig_y=S.y;
orig_z=S.z;

S=load(fichero_todosanchors)
datax=S.datax';
datay=S.datay';
dataz=S.dataz';

datax(1:nac)=orig_x;
datay(1:nac)=orig_y;
dataz(1:nac)=orig_z;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculamos una nueva posici�n para los anchors externos. No hay variaci�n
%de altura (en y)
%Los puntos que se mueven est�n separados 20cm (4.8m a 5m)
for h=1:nac
    if h<=nac/2
        vector_saliente=[datax(h)-datax(h+nac/2) datay(h)-datay(h+nac/2) dataz(h)-dataz(h+nac/2)];
    else
        vector_saliente=[datax(h)-datax(h-nac/2) datay(h)-datay(h-nac/2) dataz(h)-dataz(h-nac/2)];
    end
    unitario_saliente(h,:)=vector_saliente/norm(vector_saliente);
    movimiento_nodoI(h)=0.5*ancho_s*rand;%Primer nodo interno de la carretera se puede mover 5cm hacia fuera
    movimiento_nodoE(h)=0.5*ancho_s*rand;%Nodo Externo de la carretera se puede mover 5cm hacia fuera
    movimiento_nodoC(h,:)=0.2*rand*unitario_saliente(h,:);%Primer anchor del terreno se puede mover 20cm alej�ndose de la carretera
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cadenainicial='      <surfaces count=\"%d\">\n';
cadenafinal='      </surfaces>';
iniciosurface=strcat(...
    '        <surface SurfaceId=\"%d\" Visible=\"True\">\n', ...
    '          <StartNode>%d</StartNode>\n', ...
    '          <StartPercentage>%f</StartPercentage>\n', ...
    '          <Name>Surface%d</Name>\n', ...
    '          <SetShape>True</SetShape>\n');


zonas_izq=sign(p_izquierda);
zonas_dcha=sign(p_derecha);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%Dividimos la carretera en zonas seg�n la pendiente%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%ATENCI�N: las superficies no pueden empezar en anchors de carretera que
%%tengan porcentaje no nulo, porque entonces los anchors de carretera
%%cambian de posici�n -> En lugar de dividir por pendientes, simplemente
%%se crea una surface cada vez que llegamos a un nodo

contador=1;
id_zona=[];


contador=1;
for h=1:length(elnodo)/2-1
    if elporcentaje(h)==0
        id_zona(contador).centro=h; %El del centro tiene que tener porcentaje cero
        if h>1
            id_zona(contador).inicio=ceil((id_zona(contador-1).centro+id_zona(contador).centro)/2);
            id_zona(contador-1).fin=id_zona(contador).inicio-1;
        else
            id_zona(contador).inicio=1;
        end
        contador=contador+1;
    end
end
id_zona(end).fin=length(elnodo)/2;
       
separacion_maxima=inf; %No troceamos


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numnodos==7
    forma=superficie_normal7();
else %numnodos=9
    forma=superficie_normal9();
end

fid=fopen('salida\surfaces.txt','w');


h=1; %nodo en el que empieza la surface
comienzo=1; %contador de cambios de surface obligatorios
contador=1; %contador de surfaces
fprintf(fid,cadenainicial,length(id_zona));%%%%%%%%%%%%%%POR ANTICIPADO!!!!!!!!!!
%IMPORTANTE: El valor de una zona debe aplicarse en su punto medio

material='ground_track000';

for zona=1:length(id_zona)
    h=id_zona(zona).inicio;
    final=id_zona(zona).fin;
    punto_medio=id_zona(zona).centro;
    
    %5 materiales distintos, cambiando en t�rmino medio cada 20 zonas
    n_aleatorio=rand;
    
    if n_aleatorio<0.01 %Suceder� en 1 de cada 100 zonas, en t�rmino medio
        n_aleatorio=randint(1,1,5);
        material=sprintf('ground_track00%d',n_aleatorio);
    end
    
    fprintf(fid,iniciosurface,contador,elnodo(punto_medio),elporcentaje(punto_medio),contador);
    
    pendiente_media_izq=mean(p_izquierda(h:final));
    pendiente_media_dcha=mean(p_derecha(h:final));
    factor=0.2; %La carretera solo se inclina un poco
    
    %Un �nico desplazamiento para todo el tramo
    nodo1=-n_E-movimiento_nodoE(punto_medio);
    nodo2=-n_I-movimiento_nodoI(punto_medio); 
    nodo8=n_I+movimiento_nodoI(punto_medio+nac/2);
    nodo9=n_E+movimiento_nodoE(punto_medio+nac/2);
    %Los nodos 2 y 7 est�n a altura 0
    altura_nodo1=factor*pendiente_media_izq*(nodo2-nodo1);
    altura_nodo9=factor*pendiente_media_dcha*(nodo9-nodo8);
    
    altura_nodo_carretera_izquierdo(h:final)=factor*pendiente_media_izq*((n_T-n_I)+modulo(movimiento_nodoC(h:final,:))-movimiento_nodoI(punto_medio));
    hd=h+nac/2;
    finald=final+nac/2;
    altura_nodo_carretera_derecho(h:final)=factor*pendiente_media_dcha*((n_T-n_I)+modulo(movimiento_nodoC(hd:finald,:))-movimiento_nodoI(punto_medio+nac/2));
    
    anchor_original=[datax(h:final);datay(h:final);dataz(h:final)]';
    desplazamiento_horizontal=movimiento_nodoC(h:final,:);
    desplazamiento_vertical=altura_nodo_carretera_izquierdo(h:final)';
    nuevo_anchor(h:final,:)=anchor_original+desplazamiento_horizontal;
    nuevo_anchor(h:final,2)=nuevo_anchor(h:final,2)+desplazamiento_vertical;
    
    anchor_original=[datax(hd:finald) ;datay(hd:finald) ;dataz(hd:finald)]';
    desplazamiento_horizontal=movimiento_nodoC(hd:finald,:);
    desplazamiento_vertical=altura_nodo_carretera_derecho(h:final)';
    nuevo_anchor(hd:finald,:)=anchor_original+desplazamiento_horizontal;
    nuevo_anchor(hd:finald,2)=nuevo_anchor(hd:finald,2)+desplazamiento_vertical;
        
    fprintf(fid,forma,...
            nodo1,altura_nodo1,...
            nodo2,0,...
            nodo8,0,...
            nodo9,altura_nodo9,...
            material);
    
    contador=contador+1;

end
nuevo_anchor(final+1:nac/2,:)=[datax(final+1:nac/2);datay(final+1:nac/2);dataz(final+1:nac/2)]';
nuevo_anchor(finald+1:nac,:)=[datax(finald+1:nac);datay(finald+1:nac);dataz(finald+1:nac)]';

fprintf(fid,'%s',cadenafinal);
fclose(fid);
%fprintf(1,'Hay %d superficies. AN�TALO EN surfaces.txt',contador-1);

save('nuevos_anchors.mat','nuevo_anchor')
diferencias=modulo(nuevo_anchor(1:nac,:)-[datax(1:nac);datay(1:nac);dataz(1:nac)]');
find(diferencias>0.3)

%display('Ejecute genera_nuevos_anchors');

function m=modulo(a)
        m=sqrt(a(:,1).^2+a(:,2).^2+a(:,3).^2);
end


end