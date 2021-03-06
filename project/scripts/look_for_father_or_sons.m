function [numero caminos]=look_for_father_or_sons(fichero,silencioso)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin==1
	silencioso=1;
end
    [BASEPATH status msg]=canonicalize_file_name(fichero);
    barras=findstr(BASEPATH,filesep);
    BASEPATH=BASEPATH(1:(barras(end-1)-1));

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
    pos=findstr(char(10),cadena); %Localizamos el car�cter de cambio de l�nea
    inicio=1;
    contador=1;
    if length(pos)>=1
        for h=1:length(pos)
            final=pos(h)-1;
            directorio=deblank(cadena(inicio:final));
            if (length(directorio)>0) 
                if length(findstr(directorio,':'))==0
                    directorio=canonicalize_file_name(strcat(BASEPATH,filesep(),directorio));
                end
                if length(directorio)>0
                    if contador==1
                        caminos=cellstr(directorio);
                    else
                        caminos(contador)=directorio;
                    end
                    contador=contador+1;
                end
            end
            inicio=pos(h)+1;
        end
    end
    %Ya hemos procesado todas las cadenas que hab�a antes de los cambios de l�nea
    final=length(cadena);
    directorio=deblank(cadena(inicio:final));
    if (length(directorio)>0) 
        if length(findstr(directorio,':'))==0
            directorio=canonicalize_file_name(strcat(BASEPATH,filesep(),directorio))
        end
        if contador==1
            caminos=cellstr(directorio);
        else
            caminos(contador)=directorio;
        end
        contador=contador+1;
    end
    numero=contador-1;
end

