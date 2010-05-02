function [numero caminos]=look_for_father_or_sons(fichero,silencioso)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin==1
	silencioso=1;
end

%Los ficheros sons.txt y father.txt deben contener el path a los tramos secundarios y al tramo principal respectivamente
%de un proyecto
		numero=0;
		caminos='';
		if silencioso==1, fid=fopen(fichero,'r'); else fid=my_fopen(fichero,'r'); end
		if fid==-1
			%display(sprintf('File %s not found'),fichero);
			return
		end
        contenido=fread(fid,Inf);
		if silencioso==1, fclose(fid); else my_fclose(fid); end
        cadena=char(contenido)';
        pos=findstr(char(10),cadena);
		inicio=1;
		contador=1;
        if length(pos)>=1
			for h=1:length(pos)
				final=pos(h)-1;
				haybarra=findstr('\',cadena(inicio:final));
				if (isempty(haybarra)==0) %Si hay una barra invertida, es un path
					if contador==1
						caminos=cellstr(deblank(cadena(inicio:final)));
					else
						caminos(contador)=deblank(cadena(inicio:final));
					end
					contador=contador+1;
				end
				inicio=pos(h)+1;
			end
		end
		%Ya hemos procesado todas las cadenas que había antes de los cambios de línea
		final=length(cadena);
		haybarra=findstr('\',cadena(inicio:final));
		if (isempty(haybarra)==0)
			if contador==1
				caminos=cellstr(deblank(cadena(inicio:final)));
			else
				caminos(contador)=deblank(cadena(inicio:final));
			end
			contador=contador+1;
		end
		numero=contador-1;
    end
end


end
