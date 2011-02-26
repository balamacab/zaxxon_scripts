function zgui2()

if exist('s0_import')!=7
    disp('Use this script only on the root folder of the project');
	return;
end

current_dir=pwd();
addpath([current_dir,'\scripts']);

% Main program
[in out] = popen2("gtk-server","-stdin");
% Initialization.
gtk(in,out,"gtk_init NULL NULL");
% 'win' is a handle (ID number) to the main GUI window.
win = gtk(in,out,"gtk_window_new 0");
% Set window's title, size and position.
% Note that the message sent to gtk-server is always a string.
gtk(in,out,["gtk_window_set_title ", win, "'zaxxon scripts (2)'"]);
gtk(in,out,["gtk_window_set_default_size ", win, " 800 600"]);
gtk(in,out,["gtk_window_set_position ", win, " 1"]);
% We'll set our widgets in a table, one widget per row-column
% combination.
maintbl = gtk(in,out,"gtk_table_new 2 4 0.1 0.1");
gtk(in,out,["gtk_container_add ", win, " ", maintbl]);
tbl = gtk(in,out,"gtk_table_new 80 60 0.1 0.1");
tbl2 = gtk(in,out,"gtk_table_new 80 60 0.1 0.1");
gtk(in,out,["gtk_table_attach_defaults ", maintbl, " ", tbl, " 1 2 1 2"]);
gtk(in,out,["gtk_table_attach_defaults ", maintbl, " ", tbl2, " 1 2 2 3"]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs0=gtk(in,out,"gtk_frame_new");

lbls4 = gtk(in,out,"gtk_label_new s4_terrain");
%http://library.gnome.org/devel/gtk/2.12/gtk-Stock-Items.html
buts4_raise = gtk(in,out,"gtk_button_new_with_label 'Give Elevation\nto the mesh'");
s4_pb_raise = gtk(in,out,"gtk_progress_bar_new ");
buts4_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
%Si es SON, esta casilla debería estar desmarcada porque no tiene sentido
s4_createhlg = gtk(in,out,["gtk_check_button_new_with_label 'Create\ngrid.hlg' 1"]);
s4_createobj = gtk(in,out,["gtk_check_button_new_with_label 'Create\ntest.obj' 1"]);
buts4_accept = gtk(in,out,"gtk_button_new_with_label 'Accept\nthe mesh'");
s4_pb_accept = gtk(in,out,"gtk_progress_bar_new ");

hseps4s7 = gtk(in,out,"gtk_hseparator_new");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lbls7 = gtk(in,out,"gtk_label_new s7_walls");
buts7_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
buts7 = gtk(in,out,"gtk_button_new_with_label 'Create walls'");
s7_pb_createwalls = gtk(in,out,"gtk_progress_bar_new ");
hseps7s10 = gtk(in,out,"gtk_hseparator_new");

inicializa_s7(in,out,buts7)

buts10_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
lbls10 = gtk(in,out,"gtk_label_new s10_split");
buts10_createsplit = gtk(in,out,"gtk_button_new_with_label 'Create split points'");
buts10_splittrack = gtk(in,out,"gtk_button_new_with_label 'Split the track'");
buts10_createterrain = gtk(in,out,"gtk_button_new_with_label 'Create the terrain'");
s10_pb_createterrain = gtk(in,out,"gtk_progress_bar_new ");
drops10X = gtk(in,out,"gtk_combo_box_new_text '");
drops10Y = gtk(in,out,"gtk_combo_box_new_text '");
lbls10split = gtk(in,out,"gtk_label_new '# segments:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10split,"0 0.5"]);
s10_split = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",s10_split,"1"]);gtk(in,out,["gtk_entry_set_width_chars ",s10_split,'3']);
s10_blend = gtk(in,out,["gtk_check_button_new_with_label 'Blend with\nBackground' 1"]);
hseps2bs3 = gtk(in,out,"gtk_hseparator_new");
lbls10_grid = gtk(in,out,"gtk_label_new 'Split terrain\nwith grid:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10_grid,"1 0.5"]);
lbls10_distancia=gtk(in,out,"gtk_label_new 'Split terrain\nwith grid:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10_distancia,"1 0.5"]);
for h=1:16
	gtk(in,out,["gtk_combo_box_append_text ", drops10X, "\"" ,	sprintf('%d',h) , "\""]);
	gtk(in,out,["gtk_combo_box_append_text ", drops10Y, "\"" ,	sprintf('%d',h) , "\""]);
end
%gtk(in,out,["gtk_combo_box_set_wrap_width  ",drops10split, " \" 2\""]);

inicializa_s10(in,out,buts10_createsplit,buts10_splittrack,buts10_createterrain,lbls10_distancia)

lbls9 = gtk(in,out,"gtk_label_new s9_join");
buts9_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
buts9_joinall = gtk(in,out,"gtk_button_new_with_label 'Create Venue.xml'");
s9_pb_joinall = gtk(in,out,"gtk_progress_bar_new ");
%s9_includebg = gtk(in,out,["gtk_check_button_new_with_label 'Include\nlist_bi.txt' 1"]);
hseps9end= gtk(in,out,"gtk_hseparator_new");



invisible = gtk(in,out,"gtk_label_new '      '");
invisible2 = gtk(in,out,"gtk_label_new '      '");
invisible3 = gtk(in,out,"gtk_label_new '      '");



 %so ocupa del 1 al 4
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", fs0, " 3 4 1 60"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls4, " 1 3 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_refresh, " 1 3 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_raise, " 30 32 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_pb_raise, " 28 34 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_accept, " 60 62 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_pb_accept, " 58 64 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_createhlg, " 20 22 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_createobj, " 20 22 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps4s7, " 1 80 3 4"]);
 
%s7
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls7, " 1 3 4 5"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts7_refresh, " 1 3 5 6"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts7, " 30 32 4 5"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s7_pb_createwalls, " 28 34 5 6"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps7s10, " 1 80 7 8"]);

gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10, " 1 3 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10split, " 20 21 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10_distancia, " 20 21 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_split, " 21 22 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10Y, " 61 64 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10X, " 58 61 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_refresh, " 1 3 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createsplit, " 30 32 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_splittrack, " 30 32 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createterrain, " 60 62 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_pb_createterrain, " 58 64 10 11"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_blend, " 48 50 10 11"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10_grid, " 48 50 8 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps2bs3, " 1 80 11 12"]);
%s9
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls9, " 1 3 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts9_refresh, " 1 3 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts9_joinall, " 30 32 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s9_pb_joinall, " 28 34 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps9end, " 1 80 14 15"]);

%gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible, " 24 28 15 16"]);
%gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible2, " 4 5 16 17"]);
%gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible3, " 19 20 16 17"]);

% Some Octave advertisement
adv = gtk(in,out,"gtk_text_view_new 'Created with Octave!'");
advb = gtk(in,out,["gtk_text_view_get_buffer ",adv]);
gtk(in,out,["gtk_table_attach_defaults ", tbl2, " ", adv, " 1 2 58 60"]);
cadena='';
informa_nuevo(in,out,advb,cadena)

inicializa_s4(in,out,buts4_raise,buts4_accept,advb)

gtk(in,out,["gtk_widget_show_all ", win]);

% endless loop; we only break out of it when the quit button is clicked
event = "";

while (1)
		
        event = gtk(in,out,"gtk_server_callback wait");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		
        % The user clicked on the windows 'close' button.
        if strcmp(event, win)
                break;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
        if strcmp(event, buts4_raise)
					informa_nuevo(in,out,advb,'S2');
					valor_createhlg=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s4_createhlg]));
					valor_createobj=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s4_createobj]));
					
					try
						global progress_bar;
						progress_bar.id=s4_pb_raise;
						progress_bar.in=in;
						progress_bar.out=out;
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]); gtk(in,out,"gtk_server_callback update");
						ejecuta(in,out,advb,'cd s1_mesh');
						ejecuta(in,out,advb,'trocea_malla');
						if (valor_createhlg==1)
							ejecuta(in,out,advb,'create_hlg');
						end
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0.1)]);gtk(in,out,"gtk_server_callback update");
						ejecuta(in,out,advb,'cd ..\s4_terrain');
						ejecuta(in,out,advb,'coge_datos');
						ejecuta(in,out,advb,'procesar_nodostxt');
						if valor_createobj==1
							ejecuta(in,out,advb,"msh_to_obj('salida/nodos_conaltura.txt','elements.txt');");
						end
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
						gtk(in,out,["gtk_widget_set_sensitive ",buts4_accept,"1"]);
						informa_anyade(in,out,advb,'Operation Successful');
					catch
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);
						informa_anyade(in,out,advb,'"Operation failed %f"');
					end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
        if strcmp(event, buts4_accept)
					informa_nuevo(in,out,advb,'S2');
					try
						global progress_bar;
						progress_bar.id=s4_pb_accept;
						progress_bar.in=in;
						progress_bar.out=out;
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]); gtk(in,out,"gtk_server_callback update");
						ejecuta(in,out,advb,'cd s4_terrain');
						ejecuta(in,out,advb,'accept_mesh');
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
						gtk(in,out,["gtk_widget_set_sensitive ",buts7,"1"]);
						informa_anyade(in,out,advb,'Operation Successful');
					catch
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);
						informa_anyade(in,out,advb,sprintf('"Operation failed %f"',ancho));
					end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
		if strcmp(event, buts4_refresh)
			informa_nuevo(in,out,advb,'S4');
			try
				inicializa_s4(in,out,buts4_raise,buts4_accept,advb)
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
        if strcmp(event, buts7)
			informa_nuevo(in,out,advb,'S7');
			try
				global progress_bar;
				progress_bar.id=s7_pb_createwalls;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s7_walls');
				ejecuta(in,out,advb,'coge_datos');
				ejecuta(in,out,advb,'poner_muro');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		if strcmp(event, buts7_refresh )
			informa_nuevo(in,out,advb,'S7');
			try
				inicializa_s7(in,out,buts7)	
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end 


		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts10_createsplit )
			informa_nuevo(in,out,advb,'S10');
			try
				num_segmentos=str2num(gtk(in,out,["gtk_entry_get_text ", s10_split]));
				cd s10_split
				cd ..
				ejecuta(in,out,advb,'cd s10_split');
				ejecuta(in,out,advb,'coge_datos');
				ejecuta(in,out,advb,sprintf('split_track(%d)',num_segmentos));
				gtk(in,out,["gtk_widget_set_sensitive ",buts10_splittrack,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(event, buts10_splittrack )
			informa_nuevo(in,out,advb,'S10');
			try
				ejecuta(in,out,advb,'cd s10_split');
				ejecuta(in,out,advb,'partir_track');
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts10_createterrain )
			informa_nuevo(in,out,advb,'S10');
			gridX=str2num(gtk(in,out,["gtk_combo_box_get_active_text ", drops10X]));
			gridY=str2num(gtk(in,out,["gtk_combo_box_get_active_text ", drops10Y]));
			mezclar=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s10_blend]));
			try
				global progress_bar;
				progress_bar.id=s10_pb_createterrain;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s10_split');
				ejecuta(in,out,advb,sprintf('procesar_elementstxt_mt(%d,%d,%d)',gridX,gridY,mezclar));				
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts10_refresh		)
			informa_nuevo(in,out,advb,'S10');
			try
				inicializa_s10(in,out,buts10_createsplit,buts10_splittrack,buts10_createterrain,lbls10_distancia)
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts9_joinall)
			informa_nuevo(in,out,advb,'S9');
			try
				global progress_bar;
				progress_bar.id=s9_pb_joinall;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s9_join');
				ejecuta(in,out,advb,'join_all');				
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
			end
		end		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		if strcmp(event, buts9_refresh)
			informa_nuevo(in,out,advb,'S1');
			try
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
	clear progress_bar;
	chdir(current_dir); %Siempre volvemos al origen
end

% Clean up -- close all figures and tell gtk-server to quit.
close all;
gtk(in,out,"gtk_server_exit");

function inicializa_s4(in,out,buts4_raise,buts4_accept,advb);
	[errores,nadena]=system('dir s1_mesh\salida\anchors_carretera.msh /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts4_raise,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts4_raise,"0"]);
		informa_anyade(in,out,advb,'anchors_carretera.mesh NOT found');
	end
	[errores,nadena]=system('dir s4_terrain\salida\anchors_originales.mat /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts4_accept,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts4_accept,"0"]);
	end
end


function inicializa_s7(in,out,buts7)
	comprueba(in,out,'dir s4_terrain\salida\elements.txt /b',buts7);
end

function inicializa_s10(in,out,buts10_createsplit,buts10_splittrack,buts10_createterrain,lbls10_distancia)
	comprueba(in,out,'dir venue\porcentajes.mat /b',buts10_createsplit);
	comprueba(in,out,'dir s10_split\pos_nodes.txt /b',buts10_splittrack);
	comprueba(in,out,'dir s6_hairpins\salida\nodos_conaltura.txt /b',buts10_createterrain);
	try 
	          S=load('anchors.mat');
			  nac=length(S.x);
			  ancho=sqrt((S.x(1)-S.x(nac/2+1))^2+(S.z(1)-S.z(nac/2+1))^2);
			  ancho=ancho*10;
			  ancho=round(ancho);
			  ancho=ancho/10;
			  distancia=dame_distancia(S.x,S.z);
	catch
		      ancho=5;
			  distancia=0;
	end
	gtk(in,out,["gtk_label_set_text ",lbls10_distancia,sprintf('"%d m"',round(distancia(end)))]);
end
	
function fichero=encuentra_kml()

	[errores,filename]=system('dir *.kml /b');
	pos = findstr (filename, '.kml');
	filename=filename(1:pos+3);
	if length(filename)<3
		filename='File not found';
	end
	fichero=filename;
end
	
function distancia=dame_distancia(x,z)
try
		nac=length(x);
		x=0.5*(x(1:nac/2)+x(nac/2+1:end));
		y=0.5*(z(1:nac/2)+z(nac/2+1:end));

		xy = [x;y]; 
		df = diff(xy,1,2); 

		  %Cálculo basto de la longitud
		distancia = cumsum([0, sqrt([1 1]*(df.*df))]);
		ancho=distancia(end);
	catch
		distancia=5;
	end
end
	
	
	
function num_files=calcular_num_rellenos(ficherokml,tamfile,pasoenmetros)
    [longitud latitud altura]=leer_datos(ficherokml);
	[mapeo]=textread('..\mapeo.txt','%f');
	[lax nada laz]=coor_a_BTB(longitud,latitud,0,mapeo);
	xmin=min(lax)-pasoenmetros;
	xmax=max(lax)+pasoenmetros;
	zmin=min(laz)-pasoenmetros;
	zmax=max(laz)+pasoenmetros;

    [mapeo]=textread('..\mapeo.txt','%f');

     guarda_calentamiento=25;
     columnas=xmin:pasoenmetros:xmax;
     num_columnas=length(columnas);
     filas=zmin:pasoenmetros:zmax;
     num_filas=length(filas);

	 num_files=ceil(((guarda_calentamiento+num_filas)*num_columnas)/tamfile);
	 
function informa_nuevo(in,out,advb,cadena)
gtk(in,out,["gtk_text_buffer_set_text ",advb,strcat('"',cadena,'"'),' -1']);
function informa_anyade(in,out,advb,cadena)
gtk(in,out,["gtk_text_buffer_insert_at_cursor ",advb,strcat('"\n',cadena,'"'),' -1']);

function ejecuta(in,out,advb,cadena)

function ejecuta(in,out,advb,cadena)
informa_anyade(in,out,advb,['Running command:   ',strrep(cadena,'"','\"')]);gtk(in,out,"gtk_server_callback update");
eval(cadena);

function comprueba(in,out,ficheros,widget)
	[errores,nadena]=system(ficheros);
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",widget,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",widget,"0"]);
	end