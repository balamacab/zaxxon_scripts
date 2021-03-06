function [tree]=leer_anchors(fichero_entrada,cadena)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

fid = my_fopen(fichero_entrada,'r');

contador=1;
while ~feof(fid),
    linea=fgets(fid);
    existe=findstr(linea,cadena);
    if length(existe)>=1
        remain=linea;
        num_trozo=1;
        while true
            [str, remain] = strtok(remain, '"');
            if isempty(str),  
                break;  
            end
            if mod(num_trozo,2)==0 %Nos interesan los pares
                salida(contador,num_trozo/2)=str2num(str);                
            end
            num_trozo=num_trozo+1;
            %disp(sprintf('%s', str))
        end
        contador=contador+1;
    end
end
my_fclose(fid)

for h=1:length(salida)
    tree.TerrainAnchor(h).Position.ATTRIBUTE.x=salida(h,1);
    tree.TerrainAnchor(h).Position.ATTRIBUTE.y=salida(h,2);
    tree.TerrainAnchor(h).Position.ATTRIBUTE.z=salida(h,3);
end
