function [tree]=leer_porcentajes(fichero_entrada,fichero_salida)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

fid = my_fopen(fichero_entrada,'r');

contador=1;
contador_anchors=0;

while ~feof(fid),
    linea=fgets(fid);
    nuevo_anchor=findstr(linea,'Anchors');
    if length(nuevo_anchor)>=1
        break;
    end
end


tree=[];
contador=0;
while ~feof(fid),
    linea=fgets(fid);
    nuevo_anchor=findstr(linea,'<Anchor>');
    if length(nuevo_anchor)>=1
        contador_anchors=contador_anchors+1;
        estructura.inicializado=1;
    else
        while isempty(findstr(linea,'</Anchor')) && (length(linea)>0) && (~feof(fid)),
		    if mod(contador,4000)==0
			     display(strcat(' -',linea));
		    end
            remain=linea;
            [str, remain] = strtok(remain, '>');
            %if isempty(remain),
            % 	break;
            %end
            [previo Parametro]= strtok(str,'<');
            [valor resto]= strtok(remain,'<');
            %mensaje=sprintf('%d- %s = %s\n',contador,Parametro(2:end),valor(2:end));
            %display(mensaje);
            estructura=setfield(estructura,Parametro(2:end),str2num(valor(2:end)));
            linea=fgets(fid);
	    %disp(sprintf('(->%s)',linea))
	    %isempty(findstr(linea,'</Anchor>'))
	    contador=contador+1;
        end
        if length(findstr(linea,'</Anchor>'))>0
            estructura=rmfield(estructura,'inicializado');
            tree=[tree;estructura];
        end
    end

end
my_fclose(fid)

display(sprintf('Grabando %s',fichero_salida));
save(fichero_salida,'tree'); 
