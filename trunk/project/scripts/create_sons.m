function create_sons(camino,keep_names)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

actual=pwd;
barras=findstr(actual,filesep);
actual=actual(barras(end):end);

if nargin==0
	camino=pwd;
	keep_names=1;
end

if nargin==1
    keep_names=1;
end

if exist(char(camino))
	%Leer kmls
	[errores,filename]=system(sprintf('dir %s\\*.kml /b',camino));
    ficheros=strsplit(filename,strcat(char(13),char(10)));
    contador=1;
    for h=1:length(ficheros)
        file_name=deblank(char(ficheros(h)));
        if length(file_name)>0
            file_name=canonicalize_file_name(strcat(camino,filesep(),file_name));
            if contador==1
                caminos=cellstr(file_name);
            else
                caminos(contador)=file_name;
            end
            contador=contador+1;
        end
    end
    ficheros=caminos;
	num_files=length(caminos);
	copiar_kmls=1;
else
	num_files=camino;
	copiar_kmls=0;
end

fid=fopen('sons.txt','w');
for h=1:num_files
	if copiar_kmls==1
		[dir, name, ext, ver] = fileparts (char(ficheros(h)));
		if keep_names==1
			name=name;
		else
			name=sprintf('son%02d',h);
		end
	else
		name=sprintf('son%02d',h);
	end
	fprintf(fid,'%s\n',name);
	basedir=strcat('..\',name);
	mkdir(basedir);
	system(sprintf('xcopy default_son_files\*.* %s /E /Y',basedir));
	if copiar_kmls==1
        comando=sprintf('copy %s %s\\s0_import\\ /Y',char(ficheros(h)),basedir);
		system(comando);
	end
	fids=fopen(sprintf('%s\\father.txt',basedir),'w');
	fprintf(fids,'%s\n',actual);
	fclose(fids);
end	
fclose(fid)