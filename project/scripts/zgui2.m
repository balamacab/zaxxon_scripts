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
s10_blend = gtk(in,out,["gtk_check_button_new_with_label 'Blend with\nBackground' 1"]);
hseps2bs3 = gtk(in,out,"gtk_hseparator_new");
lbls10_grid = gtk(in,out,"gtk_label_new 'Split terrain\nwith grid:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10_grid,"1 0.5"]);
for h=1:16
	gtk(in,out,["gtk_combo_box_append_text ", drops10X, "\"" ,	sprintf('%d',h) , "\""]);
	gtk(in,out,["gtk_combo_box_append_text ", drops10Y, "\"" ,	sprintf('%d',h) , "\""]);
end
%inicializa_s10(in,out,buts2b_makegrid,buts2b_raisekml,buts2b_readgrid,buts2b_plotlamalla,lbls2blimits,'s2_elevation_b','limits_b.kml')

buts3_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
lbls3 = gtk(in,out,"gtk_label_new s3_road");
buts3_readdata = gtk(in,out,"gtk_button_new_with_label 'Read Elevation Data'");
buts3_createprofile = gtk(in,out,"gtk_button_new_with_label 'Create Elevation Profile'");
buts3_consolidate = gtk(in,out,"gtk_button_new_with_label 'Consolidate'");
buts3_fixterrain = gtk(in,out,"gtk_button_new_with_label 'Fix terrain (opt)'");
buts3_removeretoques = gtk(in,out,"gtk_button_new_with_label 'Remove hand-fixes'");
s3_pb_readdata = gtk(in,out,"gtk_progress_bar_new ");
s3_pb_consolidate = gtk(in,out,"gtk_progress_bar_new ");
s3_usecenter = gtk(in,out,["gtk_check_button_new_with_label 'Use\ncenterline' 0"]);
lbls3smooth1 = gtk(in,out,"gtk_label_new 'Smooth\nFactor:'");gtk(in,out,["gtk_misc_set_alignment ",lbls3smooth1,"0 0.5"]);
s3_smoothfactor = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",s3_smoothfactor,"15"]);gtk(in,out,["gtk_entry_set_width_chars ",s3_smoothfactor,'3']);
lbls3_slopelimit = gtk(in,out,"gtk_label_new 'Slope\nlimit:'");gtk(in,out,["gtk_misc_set_alignment ",lbls3_slopelimit,"0 0.5"]);
s3_slopelimit= gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",s3_slopelimit,"0.25"]);gtk(in,out,["gtk_entry_set_width_chars ",s3_slopelimit,'5']);
hseps3s1= gtk(in,out,"gtk_hseparator_new");

inicializa_s3(in,out,buts3_readdata,buts3_createprofile,buts3_fixterrain,buts3_consolidate);

buts1_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
lbls1 = gtk(in,out,"gtk_label_new s1_mesh");
lbls1width = gtk(in,out,"gtk_label_new 'Width (m):'");gtk(in,out,["gtk_misc_set_alignment ",lbls1width,"0 0.5"]);
widths1 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",widths1,"20"]);gtk(in,out,["gtk_entry_set_width_chars ",widths1,'3']);
lbls1panels = gtk(in,out,"gtk_label_new 'Panels:'");gtk(in,out,["gtk_misc_set_alignment ",lbls1panels,"0 0.5"]);
panelss1 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",panelss1,"5"]);;gtk(in,out,["gtk_entry_set_width_chars ",panelss1,'3']);
buts1 = gtk(in,out,"gtk_button_new_with_label 'Create .geo'");
hseps1fin= gtk(in,out,"gtk_hseparator_new");
s1_regular = gtk(in,out,["gtk_check_button_new_with_label 'Force\nregular' 0"]);
s1_includelimits = gtk(in,out,["gtk_check_button_new_with_label 'Include\nElevation Limits' 1"]);
gtk(in,out,["gtk_toggle_button_set_active ",s1_includelimits,"1"]);
s1_pb_creategeo = gtk(in,out,"gtk_progress_bar_new ");

inicializa_s1(in,out,buts1);

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
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_refresh, " 1 3 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createsplit, " 30 32 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_splittrack, " 30 32 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createterrain, " 60 62 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_pb_createterrain, " 58 64 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10X, " 50 52 8 9"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10Y, " 50 52 9 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_blend, " 48 50 10 11"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10_grid, " 48 50 8 10"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps2bs3, " 1 80 11 12"]);
%s3
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls3, " 1 3 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts3_refresh, " 1 3 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts3_readdata, " 23 24 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts3_createprofile, " 45 47 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts3_consolidate, " 60 62 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts3_fixterrain, " 45 47 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s3_pb_readdata, " 23 24 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s3_usecenter, " 20 22 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s3_pb_consolidate, " 58 64 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls3smooth1, " 28 30 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s3_smoothfactor, " 30 34 12 13"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls3_slopelimit, " 28 30 13 14"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s3_slopelimit, " 30 34 13 14"]);
 



gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps3s1, " 1 80 14 15"]);
%s1
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls1, " 1 3 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts1_refresh, " 1 3 17 18"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls1width, " 20 22 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", widths1, " 23 24 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls1panels, " 20 22 17 18"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", panelss1, " 23 24 17 18"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts1, " 30 32 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s1_pb_creategeo, " 28 34 17 18"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s1_regular, " 20 22 18 19"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s1_includelimits, " 23 24 18 19"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps1fin, " 1 80 19 20"]);

gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible, " 24 28 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible2, " 4 5 16 17"]);
gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible3, " 19 20 16 17"]);

% Some Octave advertisement
adv = gtk(in,out,"gtk_text_view_new 'Created with Octave!'");
advb = gtk(in,out,["gtk_text_view_get_buffer ",adv]);
gtk(in,out,["gtk_table_attach_defaults ", tbl2, " ", adv, " 1 2 58 60"]);
cadena='To start:\nCopy your kml to the s0_import folder\nand press \"Import the kml\" button';
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
		if strcmp(event, buts3_readdata )
			informa_nuevo(in,out,advb,'S3');
			try
				valor_usecenter=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s3_usecenter]))
				global progress_bar;
				progress_bar.id=s3_pb_readdata;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s3_road');
				ejecuta(in,out,advb,'coge_datos');
				ejecuta(in,out,advb,sprintf('creartrack1(%d)',valor_usecenter));
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts3_createprofile,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts3_createprofile )
			informa_nuevo(in,out,advb,'S3');
			try
				slope_limit = str2num(gtk(in,out,["gtk_entry_get_text ", s3_slopelimit]));
				smooth_factor1 = str2num(gtk(in,out,["gtk_entry_get_text ", s3_smoothfactor]));
				if mod(smooth_factor1,2)==1
					ejecuta(in,out,advb,'cd s3_road');
					cadena=sprintf('dar_altura(%d,%.2f,%.2f,%.1f);',smooth_factor1, slope_limit,-slope_limit,2*smooth_factor1);
					ejecuta(in,out,advb,cadena);
					gtk(in,out,["gtk_widget_set_sensitive ",buts3_fixterrain,"1"]);
					gtk(in,out,["gtk_widget_set_sensitive ",buts3_consolidate,"1"]);
					gtk(in,out,["gtk_progress_bar_set_fraction ",s3_pb_consolidate,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
					informa_anyade(in,out,advb,'Operation Successful');
				else
					informa_anyade(in,out,advb,'Operation Failed. Use an odd smoothing factor');
				end
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(event, buts3_consolidate)
			informa_nuevo(in,out,advb,'S3');
			try
				global progress_bar;
				progress_bar.id=s3_pb_consolidate;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd venue;');
				ejecuta(in,out,advb,'btb06');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts1,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts3_refresh )
			informa_nuevo(in,out,advb,'S3');
			try
				inicializa_s3(in,out,buts3_readdata,buts3_createprofile,buts3_fixterrain,buts3_consolidate);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if strcmp(event, buts3_fixterrain)
			informa_nuevo(in,out,advb,'S3');
			try
				slope_limit = str2num(gtk(in,out,["gtk_entry_get_text ", s3_slopelimit]));
				smooth_factor1 = str2num(gtk(in,out,["gtk_entry_get_text ", s3_smoothfactor]));
				ejecuta(in,out,advb,'cd s3_road');
				ejecuta(in,out,advb,'corregir');
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end		
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(event, buts1)
			informa_nuevo(in,out,advb,'S1');
			try
				valor_regular=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s1_regular]))
				valor_includelimits=str2num(gtk(in,out,["gtk_toggle_button_get_active ",s1_includelimits]))
				global progress_bar;
				progress_bar.id=s1_pb_creategeo;
				progress_bar.in=in;
				progress_bar.out=out;
				terrain_width= str2num(gtk(in,out,["gtk_entry_get_text ", widths1]));
				terrain_panels = str2num(gtk(in,out,["gtk_entry_get_text ", panelss1]));
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s1_mesh;');
				ejecuta(in,out,advb,sprintf('mallado_regular(%.2f,%d,%d)',terrain_width,round(terrain_panels),valor_regular));
				if valor_includelimits==1
					informa_anyade(in,out,advb,'Select an option in command-line window');
					ejecuta(in,out,advb,'addgrid(1,1)')
				end
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		if strcmp(event, buts1_refresh)
			informa_nuevo(in,out,advb,'S1');
			try
				inicializa_s1(in,out,buts1);
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

	[errores,nadena]=system('dir s4_terrain\salida\elements.txt /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts7,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts7,"0"]);
	end
end

function inicializa_s2(in,out,buts2_makegrid,buts2_raisekml,buts2_readgrid,buts2_plotlamalla,lbls2limits,folder,ficherokml)
	[numero_padres caminos]=look_for_father_or_sons('father.txt');
	
    if (exist('..\agr')==7) || (exist('..\lidar')==7) || (numero_padres~=0) %No usamos s2_elevation
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_makegrid,"0"]);
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_raisekml,"0"]);
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_readgrid,"0"]);
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_plotlamalla,"0"]);
				gtk(in,out,["gtk_label_set_text ",lbls2limits,'"AGR Dir\nFound"'])
				if (exist('..\agr')==7)
					gtk(in,out,["gtk_label_set_text ",lbls2limits,'"AGR Dir\nFound"'])
				else
					gtk(in,out,["gtk_label_set_text ",lbls2limits,'"lidar Dir\nFound"'])
				end
	else
				[errores,nadena]=system('dir mapeo.txt /b');
				existe_mapeo=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
				
				[errores,nadena]=system(['dir ',folder,'\',ficherokml,' /b']);
				numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
				if (numero_ficheros>0) & (existe_mapeo)
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_makegrid,"1"]);
				else
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_makegrid,"0"]);
				end
				if (numero_ficheros>0)
					gtk(in,out,["gtk_label_set_text ",lbls2limits,'"',ficherokml,'\nFound"'])
				else
					gtk(in,out,["gtk_label_set_text ",lbls2limits,'"',ficherokml,'\nNOT Found"'])					
				end
				
				[errores,nadena]=system(['dir ',folder,'\salida\grid*.kml /b']);
			    numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
				if (numero_ficheros>0) & ((exist('c:\python27')==7))
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_raisekml,"1"]);
				else
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_raisekml,"0"]);
				end
				[errores,nadena]=system(['dir ',folder,'\salida\grid*_relleno.kml /b']);
			    numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
				if numero_ficheros>0
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_readgrid,"1"]);
				else
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_readgrid,"0"]);
				end
				[errores,nadena]=system(['dir ',folder,'\salida\lamalla.mat /b']);
			    numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
				if numero_ficheros>0
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_plotlamalla,"1"]);
				else
					gtk(in,out,["gtk_widget_set_sensitive ",buts2_plotlamalla,"0"]);
				end
		end
end

function inicializa_s3(in,out,buts3_readdata,buts3_createprofile,buts3_fixterrain,buts3_consolidate);
	if (exist('..\agr')==7) || (exist('..\lidar')==7) %No usamos s2_elevation
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_readdata,"1"]);
	else
		[numero_padres caminos]=look_for_father_or_sons('father.txt');
		if numero_padres==0
			[errores,nadena]=system('dir s2_elevation\salida\lamalla.mat /b');
			numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
		else
			[errores,nadena]=system(sprintf('dir %s\\s3_road\\lamalla.mat',char(caminos(1))));
			numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
		end
		if numero_ficheros>0
			gtk(in,out,["gtk_widget_set_sensitive ",buts3_readdata,"1"]);
		else
			gtk(in,out,["gtk_widget_set_sensitive ",buts3_readdata,"0"]);
		end
	end
	[errores,nadena]=system('dir s3_road\alturas_track1.mat /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_createprofile,"1"]);
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_fixterrain,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_createprofile,"0"]);
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_fixterrain,"0"]);
	end
	[errores,nadena]=system('dir s3_road\track0.mat /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_consolidate,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts3_consolidate,"0"]);
	end

function inicializa_s1(in,out,buts1);
	[errores,nadena]=system('dir anchors.mat /b');
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",buts1,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts1,"0"]);
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