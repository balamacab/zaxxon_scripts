function alturas=elevar_agr(fichero_puntos,mapeo)
	z_scale=get_option('Z_SCALING_FACTOR','%f');
	if z_scale==-1
		z_scale=1
	end
	%Buscamos datos AGR
	[errores,filename]=system('dir ..\..\agr\*.agr /b');
	pos = findstr (filename, '.agr');
	ficheros=strsplit(filename,strcat(char(13),char(10)));
	
	if length(ficheros)>0
		fid=fopen(fichero_puntos);
		coordenadas=fscanf(fid,'%f',inf);
		coo_x=coordenadas(1:2:end);
		coo_z=coordenadas(2:2:end);
		fclose(fid);
		%if (fchecked=fopen('..\mapeo_uses_longlat.txt','r'))!=-1 %Si este fichero existe, hay que transformar las coordenadas que    
		%devuelve BTB_a_coor a UTM
		%fclose(fchecked);
		
		if hay_terrestres_en_mapeo(mapeo)	
			[coo_x coo_z]=deg2utm(coo_z,coo_x);
		end
		contador=1;
		alturas=[];
		for h=1:length(ficheros)
			file_name=deblank(char(ficheros(h)));
			if length(file_name)>0
				file_name=sprintf('..\\..\\agr\\%s',file_name);
				fid=fopen(file_name,'r');
				contenido=fread(fid,inf);
				fclose(fid);
				contenido=char(contenido)';
				contenido=tolower(contenido);
				
				pos_ncols=findstr(contenido,'ncols');
				ncols=sscanf(contenido((pos_ncols+length('ncols')+1):end),'%d',1);
				pos_nrows=findstr(contenido,'nrows');
				nrows=sscanf(contenido((pos_nrows+length('nrows')+1):end),'%d',1);
				
				pos_yllcorner=strfind(contenido,'yllcorner');
				if length(pos_yllcorner)>0
					yllcorner=sscanf(contenido((pos_yllcorner+length('yllcorner')+1):end),'%f',1);
				end
				pos_xllcorner=findstr(contenido,'xllcorner');
				if length(pos_xllcorner)>0
					xllcorner=sscanf(contenido((pos_xllcorner+length('xllcorner')+1):end),'%f',1);
				end
				pos_yllcenter=strfind(contenido,'yllcenter');
				if length(pos_yllcenter)>0
					yllcenter=sscanf(contenido((pos_yllcenter+length('yllcenter')+1):end),'%f',1);
				end
				pos_xllcenter=findstr(contenido,'xllcenter');
				if length(pos_xllcenter)>0
					xllcenter=sscanf(contenido((pos_xllcenter+length('xllcenter')+1):end),'%f',1);
				end
				pos_cellsize=findstr(contenido,'cellsize');
				cellsize=sscanf(contenido((pos_cellsize+length('cellsize')+1):end),'%f',1);
				pos_nodata=findstr(contenido,'nodata_value');
				datos=sscanf(contenido((pos_nodata+length('nodata_value')+1):end),'%f',inf);
				%Doy por supuesto que después de nodata_value vienen todos los datos
				nodata=datos(1);
				datos=datos(2:end);
				%
				%
				x_deseados=coo_x;
				z_deseados=coo_z;
				
				if length(pos_xllcorner)>0
					malla.rangox=xllcorner+cellsize*(0:(ncols-1))+cellsize/2;
					malla.rangoz=yllcorner+cellsize*(0:(nrows-1))+cellsize/2;
				else
					malla.rangox=xllcenter+cellsize*(0:(ncols-1));
					malla.rangoz=yllcenter+cellsize*(0:(nrows-1));
				end
				malla.malla_regular=flipud(reshape(datos,ncols,nrows)');
				
				%if h==3
				% surf(malla.rangox,malla.rangoz,malla.malla_regular);
				%end
				[indices indicesfuera]=comprobar_rangos(malla.rangox,malla.rangoz,x_deseados,z_deseados);
				alturas1=zeros(size(coo_x));
				display(sprintf('Looking for [%.1f,%.1f][%.1f,%.1f] in [%.1f,%.1f][%.1f,%.1f]',min(coo_x),max(coo_x),min(coo_z),max(coo_z),malla.rangox(1),malla.rangox(end),malla.rangoz(1),malla.rangoz(end)))
				if length(indices)>0
					alturas1(indices)=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,x_deseados(indices),z_deseados(indices));
					if contador==1
						alturas=alturas1;
						contador=contador+1;
					else
						%Nos aseguramos de no volver a sumar altura al mismo punto
						ya_conseguidos=find(alturas!=0);
						alturas1(ya_conseguidos)=0;
						sindatos=find(alturas1==nodata);
						alturas1(sindatos)=0;
						alturas=alturas+alturas1;
					end
				end
			end
		end
		alturas=z_scale*alturas';
		if length(alturas)==0
			display('ERROR: Those AGR files do not contain useful elevation data');
		end
	end
	
	[errores,filename]=system('dir ..\..\lidar\*.dtm /b');
	pos = findstr (filename, '.dtm');
	ficheros=strsplit(filename,strcat(char(13),char(10)));
	if length(ficheros)>0
		contador=1;
		fid=fopen('c:\FUSION\SurfaceSample.exe','r');
		if fid==-1
			display('c:\FUSION\SurfaceSample.exe not found');
			alturas=[];
			return;
		else
			fclose(fid)
		end
		for h=1:length(ficheros)
			file_name=deblank(char(ficheros(h)));
			if length(file_name)>0
				comando=sprintf('c:\\FUSION\\SurfaceSample /noheader ..\\..\\lidar\\%s %s temp.txt',file_name,fichero_puntos);
				system(comando);		
			
				fid=fopen('temp.txt','r');
				data=fscanf(fid,'%f,%f,%f ');
				fclose(fid); 
				alturas1=data(3:3:end);
				alturas1(find(alturas1==-1))=0;
				%alturas1=0.30479999798832*alturas1;
				if contador==1
					alturas=alturas1;
					contador=contador+1;
				else
					%Nos aseguramos de no volver a sumar altura al mismo punto
					ya_conseguidos=find(alturas!=0);
					alturas=alturas+alturas1;
				end	
			
				
			end
		end
		alturas=z_scale*alturas';
	end 
	

end


function [indices indicesfuera]=comprobar_rangos(rangox,rangoz,x,z)

dentrodelrango=(x>=min(rangox)).*(x<=max(rangox)).*(z>=min(rangoz)).*(z<=max(rangoz));
indices=find(dentrodelrango==1);
indicesfuera=find(dentrodelrango==0);

end

function salida=hay_terrestres_en_mapeo(mapeo)
%Si las coordenadas BTB son claramente mayores en magnitud que las otras, entonces deducimos que las otras son longitud/latitud
if log10(abs((mapeo(2)-mapeo(6))/(mapeo(4)-mapeo(8))))>2
	salida=1
else
	salida=0
end
