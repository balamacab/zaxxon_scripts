function [longitud latitud altura]=leer_datos(fichero)
        %display(fichero);
        isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
        if isOctave==0
            SEEK_SET='bof';
        end
        fid=my_fopen(char(fichero),'r');
        contenido=fread(fid,Inf); 
        cadena=char(contenido)';
        pos=findstr('coordinates',cadena);
        fseek(fid,0,SEEK_SET);
        if length(pos)<2 %No hay <coordinates> as� que suponemos que solo hay triadas de datos
              salir=0;
              while ~feof(fid) & (salir==0) %Intento saltarme el "BOM code"
	          c=fread(fid,1,'uchar');
                  display(char(c));
                  if length(findstr(char(c),'0123456789-'))>0
	              salir=1;
                  end
              end
	      fseek(fid,-1,'cof');
              [salida1]=fscanf(fid,'%f,%f,%f ',inf);
        else  %encontramos <coordinates>
	      [v,p]=max(pos(2:2:end)-pos(1:2:end));
              cadena=deblank(cadena(pos(p*2-1)+12:pos(p*2)-2));
              [salida1]=sscanf(cadena,'%f,%f,%f ',inf);
        end

        longitud=salida1(1:3:end);
        latitud=salida1(2:3:end);
        altura=salida1(3:3:end);
        my_fclose(fid)
        display(sprintf('%d valores',length(altura)));
end