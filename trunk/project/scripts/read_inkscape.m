function [a,b]=read_inkscape(fichero,ficherocoo)
%Las coordenadas que se leen están referidas a la esquina superior izquierda
if nargin!=2
   disp('Parameters are the .svg file and the coordinates file')
end

%Conseguimos las coordenadas originales (UMT o terrestres) de la imagen
[esquina1 esquina2]=getimagecoordinates(ficherocoo);

fid=fopen(fichero,'r');
contenido=fread(fid,inf);
contenido=char(contenido)';
fclose(fid)

%Localizamos la imagen dentro del .svg################################
pos_image=findstr('<image',contenido);
if length(pos_image)!=1
    disp('There should be exactly one image in the .svg file')
	return
end
final_image=findstr('/>',contenido(pos_image(1):end));
fragmento_image=contenido(pos_image(1):final_image(1)+pos_image(1)-1);

%Sacamos los datos de la imagen######################################
posx=findstr('x=',fragmento_image);
image_x=sscanf(fragmento_image(posx+3:end),'%f',1);
posy=findstr('y=',fragmento_image);
image_y=sscanf(fragmento_image(posy+3:end),'%f',1);
posheight=findstr('height=',fragmento_image);
image_height=sscanf(fragmento_image(posheight+8:end),'%f',1);
poswidth=findstr('width=',fragmento_image);
image_width=sscanf(fragmento_image(poswidth+7:end),'%f',1);

%Localizamos el camino################################################
pos_path=findstr('<path',contenido);

for g=1:length(pos_path)
	final_path=findstr('/>',contenido(pos_path(g):end));
	fragmento_path=contenido(pos_path(g):final_path(1)+pos_path(g)-1);
    ini_id=findstr('id="',fragmento_path);
    fin_id=findstr('"',fragmento_path(ini_id+4:end));
	fin_id=fin_id(1);
	id_path=fragmento_path(ini_id+4:(ini_id+fin_id+2));
	display(sprintf('Processing %s',id_path));
	%Sacamos los datos del path##########################################
	pos_datos=findstr('d="M ',fragmento_path);
	if length(pos_datos)<1
		display('The following path has mistakes. It must have absolute coordinates (M, not m)');
		display(id_path);
	else
		ini_datos=pos_datos(1);
	
		fragmento_path=fragmento_path(ini_datos+3:end);
		pos_datos=findstr('"',fragmento_path);
		fin_datos=pos_datos(1);

		fragmento_path=fragmento_path(1:fin_datos-1);

		posM=findstr('M',fragmento_path);
		

		posM=[posM length(fragmento_path)+1];

		for h=1:length(posM)-1
			inicio=posM(h)+1;
			fin=posM(h+1)-1;
			cadena=strrep(fragmento_path(inicio:fin),'C',' ');
			coordenadas=sscanf(cadena,'%f,%f ',inf);
			longitud_x=coordenadas(1:2:end);
			latitud_y=coordenadas(2:2:end);
			normalizada_long=(longitud_x-image_x)/image_width;
			normalizada_lat=1-(latitud_y-image_y)/image_height;
			[mapeo]=textread('mapeo.txt','%f');
			
			longitud=esquina1(1)+normalizada_long*(esquina2(1)-esquina1(1));
			latitud=esquina1(2)+normalizada_lat*(esquina2(2)-esquina1(2));
			
			[lax nada laz]=coor_a_BTB(longitud,latitud,0,mapeo);
			hold on, plot(lax(1:3:end),laz(1:3:end))
			
			if length(lax(1:3:end-3))<2
			    display('ERROR: this track has less than 3 nodes')
			else
			    imprime_track(sprintf('%s.xml',id_path),[lax(1:3:end-3) laz(1:3:end-3)]',[lax(2:3:end-2) laz(2:3:end-2)]' ,[lax(3:3:end-1) laz(3:3:end-1)]',[lax(4:3:end) laz(4:3:end)]',zeros(length(lax)+1,1),zeros(length(lax)+1,1));
			end
		end
	end
end
	
function imprime_track(nombre,controlA,controlB,controlC,controlD,alturas_nodos,angulover)
	
	fid=my_fopen(nombre,'w');
	fprintf(fid,'      <nodes count=\"%d\">\n        %s\n        %s\n',length(controlA)+1,'<OnlyOneNodeSelected>1</OnlyOneNodeSelected>','<LineType>BezierSpline</LineType>');
	for h=1:length(controlA)+1
		altura=alturas_nodos(h);
		anguloy=-angulover(h);
		if h<=length(controlA)
			complejo=-j*(controlB(1,h)-controlA(1,h))-(controlB(2,h)-controlA(2,h));
			angulo=angle(complejo);
			exdis=abs(complejo);
		end
		if h==1
			imprime_nodo(fid,h-1,controlA(1,h),controlA(2,h),altura,angulo,anguloy,4,exdis);
		elseif h==(length(controlA)+1)
			complejo=-j*(controlD(1,h-1)-controlC(1,h-1))-(controlD(2,h-1)-controlC(2,h-1));
			angulo=angle(complejo);
			endis=abs(complejo);
			imprime_nodo(fid,h-1,controlD(1,h-1),controlD(2,h-1),altura,angulo,anguloy,endis,4);
		else
			complejo=-j*(controlD(1,h-1)-controlC(1,h-1))-(controlD(2,h-1)-controlC(2,h-1));
			angulo=angle(complejo);
			endis=abs(complejo);
			imprime_nodo(fid,h-1,controlA(1,h),controlA(2,h),altura,angulo,anguloy,endis,exdis);
        end

	end
    fprintf(fid,'      </nodes>');
    my_fclose(fid);
end


function imprime_nodo(fid,h,Px,Pz,Py,AXZ,AY,EnD,ExD);
	
	fprintf(fid,'        <node NodeId=\"%d\">\r\n',h);
	fprintf(fid,'          <Position x=\"%f\" y=\"%f\" z=\"%f\" />\r\n',Px,Py,Pz);
	fprintf(fid,'          <ControlPoints AngleXZ=\"%f\" AngleY=\"%f\" EntryDistance=\"%f\" ExitDistance=\"%f\" />\r\n',AXZ,AY,EnD,ExD);
	fprintf(fid,'        </node>\r\n');

end
