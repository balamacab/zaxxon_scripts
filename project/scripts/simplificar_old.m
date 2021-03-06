function simplificar(id_conducible,id_noconducible,id_apoyo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


if nargin<3
    display('Identificadores de las superficies f�sicas CONDUCIBLE, NO CONDUCIBLE y DE APOYO')
    display('simplificar(111,222,333)');
    return;
end

display('Leyendo datos entrada')

S=load('..\nac.mat')
nac=S.nac;

nodos=load('salida\anchors_originales.mat')
x=nodos.datax;
y=nodos.datay;
z=nodos.dataz;

display('Leyendo elements')

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread('elements.txt','%d %d %d %d %d %d %d %d %d');

Data_c.vertex.x = x;
Data_c.vertex.y = y;
Data_c.vertex.z = z;

Data_ci.vertex.x = x;
Data_ci.vertex.y = y;
Data_ci.vertex.z = z;

Data_nc.vertex.x = x;
Data_nc.vertex.y = y;
Data_nc.vertex.z = z;

Data_apoyo.vertex.x = x;
Data_apoyo.vertex.y = y;
Data_apoyo.vertex.z = z;


contador_nc=1;
contador_c=1;
contador_ci=1;
contador_apoyo=1;

display('Separando tri�ngulos')

%trisurf ( [n1 n2 n3], x, y, z );

for h=1:length(n1)
    if mod(h,200)==0
        mensaje=sprintf('%.2f',h/length(n1));
	display(mensaje);
    end
    if length(find(id_conducible==id_superficie(h)))>0
        if (n1(h)>nac) && (n2(h)>nac) & (n3(h)>nac)
            Data_c.face.vertex_indices{contador_c} = ([n1(h)-1 n2(h)-1 n3(h)-1]);
            contador_c=contador_c+1;
        else %Los tri�ngulos que tocan el borde interior son intocables
            Data_ci.face.vertex_indices{contador_ci} = ([n1(h)-1 n2(h)-1 n3(h)-1]);
            contador_ci=contador_ci+1;
        end
    end
    if length(find(id_noconducible==id_superficie(h)))>0
        Data_nc.face.vertex_indices{contador_nc} = ([n1(h)-1 n2(h)-1 n3(h)-1]);
        contador_nc=contador_nc+1;
    end
    if length(find(id_apoyo==id_superficie(h)))>0
        Data_apoyo.face.vertex_indices{contador_apoyo} = ([n1(h)-1 n2(h)-1 n3(h)-1]);
        contador_apoyo=contador_apoyo+1;
    end
end

display('Escribiendo ficheros')

plywrite(Data_c,'salida\conducibles.ply','ascii');
plywrite(Data_nc,'salida\noconducibles.ply','ascii');
plywrite(Data_ci,'salida\intocables.ply','ascii');
plywrite(Data_apoyo,'salida\apoyo.ply','ascii');

    

end