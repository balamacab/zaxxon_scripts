function trocea_malla()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

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

primeralinea=find(isdigit(cadena(pos1+longitud+digitos(1)-1:pos1+100))==1);%Localizamos la primera línea de datos tras el recuento

pos1=pos1+longitud+digitos(1)+primeralinea(1)-2; %Nos saltamos el número de elementos y su salto de línea
pos2=findstr(token2,cadena);
pos2=pos2-1; 

fid2=my_fopen(fichero_salida,'w');
fprintf(fid2,'%s',cadena(pos1:pos2));
my_fclose(fid2);
end


