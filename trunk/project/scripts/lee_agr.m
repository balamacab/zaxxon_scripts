function lee_agr(file_name)
%Creates a lamalla.mat file from a single .agr file
			[mapeo]=textread('..\mapeo.txt','%f');
			
			if length(file_name)>0
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
				if length(pos_xllcorner)>0
					malla.rangox=xllcorner+cellsize*(0:(ncols-1))+cellsize/2;
					malla.rangoz=yllcorner+cellsize*(0:(nrows-1))+cellsize/2;
				else
					malla.rangox=xllcenter+cellsize*(0:(ncols-1));
					malla.rangoz=yllcenter+cellsize*(0:(nrows-1));
				end
				malla.malla_regular=flipud(reshape(datos,ncols,nrows)');
				
				%
				[utmx,utmz,zone]=deg2utm([mapeo(4) mapeo(8)],[mapeo(3) mapeo(7)]); %Averiguamos la zona
                %Averiguamos las coordenadas terrestres para las esquinas del fichero
				[latmin,longmin]=utm2deg(malla.rangox(1),malla.rangoz(1),zone(1,:));
				[latmax,longmax]=utm2deg(malla.rangox(end),malla.rangoz(end),zone(1,:));
				%Lo pasamos a coordenadas BTB
                [xmin nada zmin]=coor_a_BTB(longmin,latmin,0,mapeo);
                [xmax nada zmax]=coor_a_BTB(longmax,latmax,0,mapeo);

                rangox=linspace(xmin,xmax,length(malla.rangox));
                rangoz=linspace(zmin,zmax,length(malla.rangoz));
				malla_regular=malla.malla_regular;
				
				save -mat-binary 'salida\lamalla.mat' rangox rangoz malla_regular;
			end