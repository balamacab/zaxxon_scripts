function trocea_malla()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

subdirectorio='salida\';
fichero_entrada='anchors_carretera.msh';
fid=fopen(strcat(subdirectorio,fichero_entrada),'r');
if fid==-1
    subdirectorio='';    
    fid=my_fopen(strcat(subdirectorio,fichero_entrada),'r');
else
   display('Abriendo el fichero salida\anchors_carretera.msh');	
end
contenido=fread(fid,Inf); 
my_fclose(fid)

extrae(contenido,'$Nodes','$EndNodes',strcat(subdirectorio,'nodos.txt'));
extrae(contenido,'$Elements','$EndElements',strcat(subdirectorio,'elements.txt'));

message(7);

function extrae(contenido,token1,token2,fichero_salida);

longitud=length(token1)+2;
cadena=char(contenido)';
pos1=findstr(token1,cadena);
digitos=find(isdigit(cadena(pos1+longitud:pos1+100))==0);%Nos saltamos el recuento

primeralinea=find(isdigit(cadena(pos1+longitud+digitos(1)-1:pos1+100))==1);%Localizamos la primera l�nea de datos tras el recuento

pos1=pos1+longitud+digitos(1)+primeralinea(1)-2; %Nos saltamos el n�mero de elementos y su salto de l�nea
pos2=findstr(token2,cadena);
pos2=pos2-1; 

fid2=my_fopen(fichero_salida,'w');
fprintf(fid2,'%s',cadena(pos1:pos2));
my_fclose(fid2);
end


