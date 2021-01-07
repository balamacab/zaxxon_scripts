function message(mcode)
fflush(stdout);

if (exist('..\..\agr')==7) || (exist('..\..\lidar')==7)
	modo_agr=1;
	else
	modo_agr=0;
end

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt',1);
[numero_father caminos]=look_for_father_or_sons('..\father.txt',1);
if numero_sons>0, 
	tipo='FATHER';
elseif numero_father>0
	tipo='SON';
else
	tipo='NORMAL';
end
	
try 
   procedencia=load('..\venue\procedencia.mat'); %Comprobamos la procedencia del nodes.xml procesado. Puede venir de importakml o de dar_altura
   procedencia=procedencia.procedencia;
catch
   procedencia='desconocida';
end

try  
    fid=fopen('pos_nodes.txt')
    pos_nodes=fscanf(fid,'%d ',inf);
    fclose(fid);
    trozos=length(pos_nodes)-1;
	pos_nodes_existe=1;
catch
    trozos=5;
	pos_nodes_existe=0;
end

		  try 
	          S=load('..\anchors.mat');
			  nac=length(S.x);
			  ancho=sqrt((S.x(1)-S.x(nac/2+1))^2+(S.z(1)-S.z(nac/2+1))^2);
			  ancho=ancho*10;
			  ancho=round(ancho);
			  ancho=ancho/10;
		  catch
		      ancho=5;
		  end	  

display('                                                                -')
display('-------------------------------------------multitrack- 12/11/10  ')
display(sprintf('----------------------  Next step  ---------------------- %s',tipo));
display('-----------------------------------------------------------------')
display('                                                   short form   -')
display('                                                                -')

if (modo_agr==1)&&(mcode==1)
	mcode=2;
end

switch(mcode)
  case 1, %importakml
		if numero_father==0
          display('cd ..\s2_elevation                                  gs2');
          display('    Create lamalla.mat. Options:                       ');
		  display('        1) Use make_grid/raise_kml/read_grid           ');
		  display('        2) Use leer_gridfloat or leehgt(2)             ');  
          display('-');
          display('cd ..\s2_elevation_b                                gs2b');
          display('    Create lamalla.mat. Same options as above ')
		  display('-');
		  display('Run plot_lamalla if you want to see the data');
		else
		  display('cd ..\Venue                                         gv')
	      display(sprintf('btb06(%.1f,1)',ancho));
		end
  
  case 2, %read_grid,leer_gridfloat
	    display('cd ..\Venue                                         gv')
		display(sprintf('btb06(%.1f,1)',ancho)); 

  case 3, %btb06
		if strcmp(procedencia,'importakml') %El nodes.xml viene de importakml -> todavía no tiene altura
          display('cd ..\s3_road                                       gs3');
          display('s3_coge_datos                                       s3coge');
		  
		else
			if strcmp(procedencia,'dar_altura')==0 %Si no sabemos de dónde venimos, sacamos toda la información
				display('cd ..\s3_road                                       gs3');
				display('s3_coge_datos                                       s3coge');
				display('---------------------------or------------------------');
			end
			display('cd ..\s1_mesh                                           gs1')
			display('mallado_regular(12,3)');
		end

  case 4, %coge_datos en s3_road
          display('creartrack1                                         ct1');

  case 5, %creartrack1
          display('dar_altura(19,0.2,-0.2)');

  case 6, %dar_altura
          display('cd ..\Venue                                        gv');
          display(sprintf('btb06  (no parameter needed)                     btb06',ancho));

  case 7, %trocear_malla 
          display('cd ..\s4_terrain                                    gs4');
          display('s4_coge_datos                                       s4coge');

  case 8, %coge_datos en s4_terrain
          display('    Check that all the check messages above are "ok"');
          display('procesar_nodostxt                                   p_n');
          
  case 9, %coge_datos en s4_terrain
          display('ERROR: your elevation data does NOT cover up all the terrain') 
		  display('FIX THE PROBLEM BEFORE GOING ON')

  case 10, %simplificar
	  display('    Process salida\*.ply with MeshLab')
	  display('juntar_mallas                                       j_m')

  case 11, %juntar_mallas
	  display('cd ..\s7_walls                                      gs7'); 
	  display('s7_coge_datos                                       s7coge');

  case 12, %coge_datos en s7_walls
 	  display('poner_muro                                          p_m'); 

  case 13, %poner_muro
          display('cd ..\s10_split                                     gs10');
          display('s10_coge_datos                                      s10coge');  

  case 14, %coge_datos en s10_split
		  %if pos_nodes_existe==1
		  %    display('    pos_nodes.txt file EXISTS. Delete it or use split_track again to change number of segments and split points');
		  %end
          display(sprintf('split_track(%d)',trozos));
          %display(sprintf('partir_track(%d)       if you have already run split_track or you don''t want to check split points',trozos));    

  case 15, %partir_track
		    if numero_father>0
				display('    Processing of this son has been completed');
				display('    Process all the sons before running join_geos');
				display('    inside father''s s1_mesh directory');
			else
				display('procesar_elementstxt_mt                             p_e');  
			end	

  case 16, %procesar_elements_mt
          display('cd ..\s9_join                                       gs9')
          display('join_all                                            j_a')
          display('    Try to open salida\Venue.xml with BTB')
  case 17, %split_track
          display('    Edit pos_nodes.txt if you want to change split-points') 
		  display(sprintf('    Approximated total length of the track is: %.0fm',dime_distancia));
		  display('                                                                -')
          display(sprintf('partir_track                                        p_t'));
	case 18, %mallado_regular
			if numero_sons>0
		      display('    Create meshes for the sons with mallado_regular and then...');
		      display('join_geos                                           j_g');
			elseif numero_father>0 %Si tiene padre, no procesamos el .geo sino que nos vamos a partir el track
				display('    Check anchors_carretera.geo with gmsh before proceeding');			
				display('cd ..\s10_split                                     gs10');
				display('s10_coge_datos                                      s10coge');  
			else
                display('    Process salida\anchors_carretera.geo with gmsh, save the mesh and...');
				display('trocea_malla                                        t_m');
			end 
    case 19, %join_geos
				display('    Process salida\joined.geo with gmsh, save the mesh as anchors_carretera.msh');
				display('trocea_malla                                        t_m');
	case 20, %make_grid
         display('cd ..\s2_elevation                                  gs2');
          display('    Raise gridXXX.kml. Options:                       ');
		  display('        1) raise_kml           ');
		  display('        2) BTBLofty (or 3DRouteBuilder)           ');  
          display('-');
          display('cd ..\s2_elevation_b                                gs2b');
          display('    Raise gridXXX.kml. Same options as above ')
		  display('-');
		  display('Use read_grid to create lamalla.mat');
		  display('Run plot_lamalla if you want to see the data');	
    case 21, %corregir
          display('Run dar_altura again with more realistic parameters')	
          display('(but before that, consider deleting retoques.txt)')	
    case 22,%procesar_nodostxt
	      display('(Reading doc/gmsh_threshold.pdf is encouraged)');
		  display('-');
		  display('Option 1) accept_mesh  (skips MeshLab step)          a_m');
	      display('Option 2) simplificar (deprecated)                  simp');
    case 23,%accept mesh
	      display('read_grid                                               ');
end
display('                                                                -')
display('-----------------------------------------------------------------')

%[error, mensaje_pantalla]=system('svn st -u');if length(findstr(mensaje_pantalla,'*'))>0, display('Update your scripts');end

if (numero_sons>0) & (numero_father>0)
	display('WARNING: You have both father.txt and sons.txt on the root folder of this track. Remove one of them');
end

function distancia=dime_distancia()
S=load('..\anchors.mat');
x=S.x;
z=S.z;
nac=length(x);
x=0.5*(x(1:nac/2)+x(nac/2+1:end));
y=0.5*(z(1:nac/2)+z(nac/2+1:end));

xy = [x;y]; 
df = diff(xy,1,2); 

  %Cálculo basto de la longitud
distancia = cumsum([0, sqrt([1 1]*(df.*df))]);
distancia=distancia(end);