function [tree]=leer_nodos(fichero_entrada,fichero_salida)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

fid = fopen(fichero_entrada,'r');
if fid==-1
  display('Fichero no encontrado');
  return;
end

contador=1;
contador_anchors=0;

while ~feof(fid),
    linea=fgets(fid);
    disp(linea);
    nuevo_anchor=findstr(linea,'<nodes ');
    if length(nuevo_anchor)>=1
        break;
    end
end

disp('Leyendo datos');

tree=[];
while ~feof(fid),
    linea=fgets(fid);
    nuevo_anchor=findstr(linea,'<node ');
    fin_anchors=findstr(linea,'</nodes>');
    if length(fin_anchors)>=1
        break;
    end
    if length(nuevo_anchor)>=1
        contador_anchors=contador_anchors+1;
        estructura.inicializado=1;
    else
        if contador_anchors>0
            while isempty(findstr(linea,'</node>')) && (length(linea)>0) && (~feof(fid)),
                remain=linea;
                [campo, nada] = strtok(remain, ' ');
                campo=campo(2:end); %Quitamos el <
                estructura=setfield(estructura,campo,[]);
                [str, remain] = strtok(remain, ' ');
                [remain,nada] = strtok(remain, '/');
                while true
                    [str, remain] = strtok(remain, ' ');
                    if isempty(str),
                        break;
                    end
                    [Parametro, valor] = strtok(str, '=');
					if mod(contador_anchors,1000)==0
						mensaje=sprintf('%s = %s\n',Parametro(1:end),valor(3:end-1));
						display(mensaje);
					end	
                    estructura.(campo)=setfield(estructura.(campo),strcat(Parametro(1:end)),str2num(valor(3:end-1)));

                end
                linea=fgets(fid);
            end
            if length(findstr(linea,'</node>'))>0
                estructura=rmfield(estructura,'inicializado');
                tree=[tree;estructura];
            end
        end
    end


end
fclose(fid)

save(fichero_salida,'tree'); 
