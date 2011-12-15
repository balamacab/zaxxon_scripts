function split_agr(file_name,numtrozos)
%Creates a lamalla.mat file from a single .agr file

			if length(file_name)>0
				fid=fopen(strcat(file_name,'.asc'),'r');
				contenido=fread(fid,1000);
				fclose(fid);
				contenido=char(contenido)';
				contenido=lower(contenido);
				
				pos_ncols=findstr(contenido,'ncols');
				ncols=sscanf(contenido((pos_ncols+length('ncols')+1):end),'%d',1);
				pos_nrows=findstr(contenido,'nrows');
				nrows=sscanf(contenido((pos_nrows+length('nrows')+1):end),'%d',1);
				
				pos_yllcorner=strfind(contenido,'yllcorner');
				if length(pos_yllcorner)>0
					yllcorner=sscanf(contenido((pos_yllcorner+length('yllcorner')+1):end),'%f',1);
                else 
                    yllcorner=-1;
				end
				pos_xllcorner=findstr(contenido,'xllcorner');
				if length(pos_xllcorner)>0
					xllcorner=sscanf(contenido((pos_xllcorner+length('xllcorner')+1):end),'%f',1);
                else 
                    xllcorner=-1;
				end
				pos_yllcenter=strfind(contenido,'yllcenter');
				if length(pos_yllcenter)>0
					yllcenter=sscanf(contenido((pos_yllcenter+length('yllcenter')+1):end),'%f',1);
                else 
                    yllcenter=-1;
                end
                
				pos_xllcenter=findstr(contenido,'xllcenter');
				if length(pos_xllcenter)>0
					xllcenter=sscanf(contenido((pos_xllcenter+length('xllcenter')+1):end),'%f',1);
                else
                    xllcenter=-1;
				end
				pos_cellsize=findstr(contenido,'cellsize');
				cellsize=sscanf(contenido((pos_cellsize+length('cellsize')+1):end),'%f',1);
				pos_nodata=findstr(contenido,'nodata_value');
				datos=sscanf(contenido((pos_nodata+length('nodata_value')+1):end),'%f',inf);
				
             
                fid=fopen(strcat(file_name,'.asc'),'r'); %Volvemos al principio

                %Doy por supuesto que después de nodata_value vienen todos los datos
				contenido=fread(fid,pos_nodata+length('nodata_value')-1);
				nodata=fscanf(fid,'%f',1);

                fichero=zeros(numtrozos,numtrozos);
                corte_ncols=round(linspace(1,ncols,numtrozos+1));
                corte_nrows=round(linspace(1,nrows,numtrozos+1));
                for h=1:numtrozos
                    for g=1:numtrozos
                        fichero(h,g)=fopen(sprintf('%s_%02d_%02d.agr',file_name,h,g),'w');
                        display(sprintf('%s_%02d_%02d.agr',file_name,h,g))
                        numcols=corte_ncols(g+1)-corte_ncols(g)+1;
                        numrows=corte_nrows(h+1)-corte_nrows(h)+1;
                        if xllcorner>=0
                            xllco=xllcorner+cellsize*(corte_ncols(g)-1);
                            yllco=yllcorner+cellsize*(corte_nrows(numtrozos-h+1)-1);
                        else
                            xllco=-1;
                            yllco=-1;
                        end
                        if xllcenter>=0
                            xllce=xllcenter+cellsize*(corte_ncols(g)-1);
                            yllce=yllcenter+cellsize*(corte_nrows(numtrozos-h+1)-1);
                        else
                            xllce=-1;
                            yllce=-1;
                        end
                        escribe_cabecera(fichero(h,g),numcols,numrows,xllco,yllco,cellsize,nodata,xllce,yllce);
                    end
                end
                for row=1:nrows %Hay nrows bloques de datos, de ncols datos cada uno
                    datos=fscanf(fid,'%f ',ncols);
				    %Repartimos los datos entre los numtrozos ficheros
                    for g=1:numtrozos
                        %Si row está en el rango
                        %corte_nrows(t):corte_nrows(t+1)) hay que grabar
                        %esa fila en el fichero t
                        for t=1:numtrozos
                            if ((row>=corte_nrows(t)) & (row<=corte_nrows(t+1)))
                                fprintf(fichero(t,g),'%.3f ',datos(corte_ncols(g):corte_ncols(g+1)));
                                fprintf(fichero(t,g),'\r\n');
                            end
                        end
                    end
                end
				fclose(fid);

               
                %Cerramos los ficheros
                for h=1:numtrozos
                    for g=1:numtrozos
                        fclose(fichero(h,g));
                    end
                end
            end
end
function escribe_cabecera(fid,ncols,nrows,xcorner,ycorner,cellsize,nodata,xcenter,ycenter)
                cabecera1='NCOLS %d\r\nNROWS %d\r\nXLL%s %d\r\nYLL%s %d\r\nCELLSIZE %d\r\nNODATA_VALUE %d\r\n';
                if xcorner>=0
                    fprintf(fid,cabecera1,ncols,nrows,'CORNER',xcorner,'CORNER',ycorner,cellsize,nodata);
                else
                    fprintf(fid,cabecera1,ncols,nrows,'CENTER',xcenter,'CENTER',ycenter,cellsize,nodata);
                end
end