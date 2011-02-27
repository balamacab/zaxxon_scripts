function zgui()

if exist('s0_import')!=7
    disp('Use this script only on the root folder of the project');
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
[numero_sons caminos]=look_for_father_or_sons('.\sons.txt',1);
[numero_father caminos]=look_for_father_or_sons('.\father.txt',1);
if numero_sons>0, 
	tipo='FATHER';
elseif numero_father>0
	tipo='SON';
else
	tipo='NORMAL';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
pantalla=nargin;
current_dir=pwd();
%addpath([current_dir,'\scripts']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		

% Main program
[in out] = popen2("gtk-server","-stdin");
% Initialization.
gtk(in,out,"gtk_init NULL NULL");
% 'win' is a handle (ID number) to the main GUI window.
win = gtk(in,out,"gtk_window_new 0");
% Set window's title, size and position.
% Note that the message sent to gtk-server is always a string.
gtk(in,out,["gtk_window_set_title ", win, '"',tipo,'"']);
if (pantalla==1)
	if (strcmp(tipo,'NORMAL')==1)
		gtk(in,out,["gtk_window_set_default_size ", win, " 800 400"]);
	elseif (strcmp(tipo,'FATHER')==1)
		gtk(in,out,["gtk_window_set_default_size ", win, " 800 400"]);
	else %El SON no tiene segunda pantalla
		disp('The SON does not use the second GUI')
		return;
	end
else
	if (strcmp(tipo,'NORMAL')==1)
		gtk(in,out,["gtk_window_set_default_size ", win, " 800 600"]);
	elseif (strcmp(tipo,'FATHER')==1)
		gtk(in,out,["gtk_window_set_default_size ", win, " 800 600"]);
	else
		gtk(in,out,["gtk_window_set_default_size ", win, " 800 500"]);
	end
end
gtk(in,out,["gtk_window_set_position ", win, " 1"]);
% We'll set our widgets in a table, one widget per row-column
% combination.
maintbl = gtk(in,out,"gtk_table_new 2 4 0.1 0.1");
gtk(in,out,["gtk_container_add ", win, " ", maintbl]);
tbl = gtk(in,out,"gtk_table_new 80 60 0.1 0.1");
tbl2 = gtk(in,out,"gtk_table_new 80 60 0.1 0.1");
tbl3 = gtk(in,out,"gtk_table_new 80 60 0.1 0.1");
gtk(in,out,["gtk_table_attach_defaults ", maintbl, " ", tbl, " 1 4 1 4"]);
gtk(in,out,["gtk_table_attach_defaults ", maintbl, " ", tbl2, " 1 2 5 6"]);
gtk(in,out,["gtk_table_attach_defaults ", maintbl, " ", tbl3, " 3 4 5 6"]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (pantalla==0)
	[ancho,espaciado,fichero]=inicializa_s0;
	fs0=gtk(in,out,"gtk_frame_new");
	lbls0 = gtk(in,out,"gtk_label_new s0_import");
	%http://library.gnome.org/devel/gtk/2.12/gtk-Stock-Items.html
	buts0 = gtk(in,out,"gtk_button_new_with_label 'Import the kml'");
	if strcmp(fichero,'File not found')==1
		gtk(in,out,["gtk_widget_set_sensitive ",buts0,"0"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",buts0,"1"]);
	end
	buts0_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	lbls0kml = gtk(in,out,["gtk_label_new -"]);gtk(in,out,["gtk_label_set_text ", lbls0kml,sprintf("'%s'",fichero)]);gtk(in,out,["gtk_misc_set_alignment ",lbls0kml,"0 0.5"]);
	lbls0width = gtk(in,out,"gtk_label_new 'Road\nwidth (m):'");gtk(in,out,["gtk_misc_set_alignment ",lbls0width,"0 0.5"]);
	lbls0spacing = gtk(in,out,"gtk_label_new 'Panel\nspacing (m):'");gtk(in,out,["gtk_misc_set_alignment ",lbls0spacing,"0 0.5"]);
	widths0 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",widths0,sprintf('%.1f',ancho)]);gtk(in,out,["gtk_entry_set_width_chars ",widths0,'4']);
	spacings0 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",spacings0,sprintf('%.1f',espaciado)]);gtk(in,out,["gtk_entry_set_width_chars ",spacings0,'4']);
	%ver=gtk(in,out,["gtk_entry_get_width_chars ",widths0])
	s0_pb = gtk(in,out,"gtk_progress_bar_new ");
	hseps0s1 = gtk(in,out,"gtk_hseparator_new");
	
	 %so ocupa del 1 al 4
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", fs0, " 3 4 1 160"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls0, " 1 3 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts0, " 30 32 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts0_refresh, " 1 3 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls0kml, " 5 6 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s0_pb, " 28 34 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls0width, " 20 22 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls0spacing, " 20 22 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", widths0, " 23 24 1 2"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", spacings0, " 23 24 2 3"]);
 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps0s1, " 1 80 3 4"]);
else
	buts0=-1;buts0_refresh=-1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (pantalla==0) && (strcmp(tipo,'SON')==0)
	buts2_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	lbls2 = gtk(in,out,"gtk_label_new s2_elevation");
	lbls2limits = gtk(in,out,"gtk_label_new 'File not found'");gtk(in,out,["gtk_misc_set_alignment ",lbls2limits,"0 0.5"]);
	buts2_makegrid = gtk(in,out,"gtk_button_new_with_label 'Make Grid'");
	buts2_raisekml = gtk(in,out,"gtk_button_new_with_label 'Raise Kmls'");
	buts2_readgrid = gtk(in,out,"gtk_button_new_with_label 'Read Grid'");
	buts2_plotlamalla = gtk(in,out,"gtk_button_new_with_label 'Plot\nData'");
	s2_pb_makegrid = gtk(in,out,"gtk_progress_bar_new ");
	s2_pb_raisekml = gtk(in,out,"gtk_progress_bar_new ");
	s2_pb_readgrid = gtk(in,out,"gtk_progress_bar_new ");
	lbls2step = gtk(in,out,"gtk_label_new 'Step (m):'");gtk(in,out,["gtk_misc_set_alignment ",lbls2step,"0 0.5"]);
	steps2 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",steps2,"20"]);gtk(in,out,["gtk_entry_set_width_chars ",steps2,'3']);
	lbls2size = gtk(in,out,"gtk_label_new 'File size\n(points):'");gtk(in,out,["gtk_misc_set_alignment ",lbls2size,"0 0.5"]);
	sizes2 = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",sizes2,"5000"]);;gtk(in,out,["gtk_entry_set_width_chars ",sizes2,'5']);
	hseps2s2b = gtk(in,out,"gtk_hseparator_new");

	inicializa_s2(in,out,buts2_makegrid,buts2_raisekml,buts2_readgrid,buts2_plotlamalla,lbls2limits,'s2_elevation','limits.kml')
	
	%s2
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2, " 1 3 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2_plotlamalla, " 78 80 4 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2_refresh, " 1 3 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2limits, " 5 6 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2_makegrid, " 30 32 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2_readgrid, " 60 62 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2_raisekml, " 45 47 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2_pb_makegrid, " 28 34 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2_pb_readgrid, " 58 64 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2_pb_raisekml, " 43 49 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2step, " 20 22 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", steps2, " 23 24 4 5"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2size, " 20 22 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", sizes2, " 23 24 5 6"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps2s2b, " 1 80 6 7"]);

else
	buts2_refresh=-1;buts2_makegrid=-1;buts2_raisekml=-1;buts2_readgrid=-1;buts2_plotlamalla=-1;
end


if (pantalla==0) && (strcmp(tipo,'SON')==0)
	buts2b_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	lbls2b = gtk(in,out,"gtk_label_new s2_elevation_b");
	lbls2blimits = gtk(in,out,"gtk_label_new 'File not found'");gtk(in,out,["gtk_misc_set_alignment ",lbls2blimits,"0 0.5"]);
	buts2b_makegrid = gtk(in,out,"gtk_button_new_with_label 'Make Grid'");
	buts2b_raisekml = gtk(in,out,"gtk_button_new_with_label 'Raise Kmls'");
	buts2b_readgrid = gtk(in,out,"gtk_button_new_with_label 'Read Grid'");
	buts2b_plotlamalla = gtk(in,out,"gtk_button_new_with_label 'Plot\nData'");
	s2b_pb_makegrid = gtk(in,out,"gtk_progress_bar_new ");
	s2b_pb_raisekml = gtk(in,out,"gtk_progress_bar_new ");
	s2b_pb_readgrid = gtk(in,out,"gtk_progress_bar_new ");
	lbls2bstep = gtk(in,out,"gtk_label_new 'Step (m):'");gtk(in,out,["gtk_misc_set_alignment ",lbls2bstep,"0 0.5"]);
	steps2b = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",steps2b,"75"]);;gtk(in,out,["gtk_entry_set_width_chars ",steps2b,'3']);
	lbls2bsize = gtk(in,out,"gtk_label_new 'File size\n(points):'");gtk(in,out,["gtk_misc_set_alignment ",lbls2bsize,"0 0.5"]);
	sizes2b = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",sizes2b,"5000"]);;gtk(in,out,["gtk_entry_set_width_chars ",sizes2b,'5']);
	hseps2bs3 = gtk(in,out,"gtk_hseparator_new");
	
	inicializa_s2(in,out,buts2b_makegrid,buts2b_raisekml,buts2b_readgrid,buts2b_plotlamalla,lbls2blimits,'s2_elevation_b','limits_b.kml')
	
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2b, " 1 3 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2b_plotlamalla, " 78 80 8 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2b_refresh, " 1 3 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2blimits, " 5 6 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2b_makegrid, " 30 32 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2b_readgrid, " 60 62 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts2b_raisekml, " 45 47 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2b_pb_makegrid, " 28 34 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2b_pb_readgrid, " 58 64 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s2b_pb_raisekml, " 43 49 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2bstep, " 20 22 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", steps2b, " 23 24 8 9"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls2bsize, " 20 22 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", sizes2b, " 23 24 9 10"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps2bs3, " 1 80 10 11"]);

else

	buts2b_refresh=-1;buts2b_makegrid=-1;buts2b_raisekml=-1;buts2b_readgrid=-1;buts2b_plotlamalla=-1;
end

if (pantalla==0)
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

else
	buts3_readdata=-1;	buts3_createprofile = 1;	buts3_consolidate = -1;	buts3_fixterrain = -1;	buts3_removeretoques=-1;buts3_refresh=-1;
end

if (pantalla==0)
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

else
	buts1_refresh=-1;buts1=-1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs0=gtk(in,out,"gtk_frame_new");

if (pantalla==1) && (strcmp(tipo,'SON')==0)
	lbls4 = gtk(in,out,"gtk_label_new s4_terrain");
	%http://library.gnome.org/devel/gtk/2.12/gtk-Stock-Items.html
	buts4_raise = gtk(in,out,"gtk_button_new_with_label 'Give Elevation to the mesh'");
	s4_pb_raise = gtk(in,out,"gtk_progress_bar_new ");
	buts4_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	%Si es SON, esta casilla debería estar desmarcada porque no tiene sentido
	s4_createhlg = gtk(in,out,["gtk_check_button_new_with_label 'Create grid.hlg' 1"]);
	s4_createobj = gtk(in,out,["gtk_check_button_new_with_label 'Create test.obj' 1"]);
	buts4_accept = gtk(in,out,"gtk_button_new_with_label 'Accept the mesh'");
	s4_pb_accept = gtk(in,out,"gtk_progress_bar_new ");

	hseps4s7 = gtk(in,out,"gtk_hseparator_new");
	
	 %so ocupa del 1 al 4
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", fs0, " 3 4 101 160"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls4, " 1 3 101 102"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_refresh, " 1 3 102 103"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_raise, " 30 32 101 102"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_pb_raise, " 28 34 102 103"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts4_accept, " 60 62 101 102"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_pb_accept, " 58 64 102 103"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_createhlg, " 20 22 101 102"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s4_createobj, " 20 22 102 103"]);
	 gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps4s7, " 1 80 103 104"]);

else
	buts4_refresh=-1;buts4_accept=-1;buts4_raise=-1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (pantalla==1) && (strcmp(tipo,'SON')==0)
	lbls7 = gtk(in,out,"gtk_label_new s7_walls");
	buts7_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	buts7 = gtk(in,out,"gtk_button_new_with_label 'Create walls'");
	s7_pb_createwalls = gtk(in,out,"gtk_progress_bar_new ");
	hseps7s10 = gtk(in,out,"gtk_hseparator_new");

	inicializa_s7(in,out,buts7);
	
	%s7
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls7, " 1 3 104 105"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts7_refresh, " 1 3 105 106"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts7, " 30 32 104 105"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s7_pb_createwalls, " 28 34 105 106"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps7s10, " 1 80 107 108"]);
else
	buts7_refresh=-1;buts7=-1;
end

if (pantalla==1) || ((pantalla==0) && (strcmp(tipo,'SON')))
	buts10_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	lbls10 = gtk(in,out,"gtk_label_new s10_split");
	buts10_createsplit = gtk(in,out,"gtk_button_new_with_label 'Create split points'");
	buts10_splittrack = gtk(in,out,"gtk_button_new_with_label 'Split the track'");
	buts10_createterrain = gtk(in,out,"gtk_button_new_with_label 'Create the terrain'");
	s10_pb_createterrain = gtk(in,out,"gtk_progress_bar_new ");
	drops10X = gtk(in,out,"gtk_combo_box_new_text '");
	drops10Y = gtk(in,out,"gtk_combo_box_new_text '");
	lbls10split = gtk(in,out,"gtk_label_new '# segments:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10split,"1 0.5"]);
	s10_split = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",s10_split,"1"]);gtk(in,out,["gtk_entry_set_width_chars ",s10_split,'3']);
	s10_blend = gtk(in,out,["gtk_check_button_new_with_label 'Blend with\nBackground' 1"]);
	hseps2bs3 = gtk(in,out,"gtk_hseparator_new");
	lbls10_grid = gtk(in,out,"gtk_label_new 'Split terrain\nwith grid:'");gtk(in,out,["gtk_misc_set_alignment ",lbls10_grid,"1 0.5"]);
	lbls10_distancia=gtk(in,out,"gtk_label_new '0m'");gtk(in,out,["gtk_misc_set_alignment ",lbls10_distancia,"1 0.5"]);
	for h=1:16
		gtk(in,out,["gtk_combo_box_append_text ", drops10X, "\"" ,	sprintf('%d',h) , "\""]);
		gtk(in,out,["gtk_combo_box_append_text ", drops10Y, "\"" ,	sprintf('%d',h) , "\""]);
	end
	%gtk(in,out,["gtk_combo_box_set_wrap_width  ",drops10split, " \" 2\""]);

	inicializa_s10(in,out,buts10_createsplit,buts10_splittrack,buts10_createterrain,lbls10_distancia);

	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10, " 1 3 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10split, " 20 21 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10_distancia, " 20 21 109 110"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_split, " 23 24 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10Y, " 61 64 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", drops10X, " 58 61 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_refresh, " 1 3 109 110"]);
	%gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createsplit, " 28 31 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createsplit, " 23 24 109 110"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_splittrack, " 30 32 109 110"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts10_createterrain, " 60 62 109 110"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_pb_createterrain, " 58 64 110 111"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s10_blend, " 45 47 109 110"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls10_grid, " 45 47 108 109"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps2bs3, " 1 80 111 112"]);
else
	buts10_refresh =-1;	buts10_createsplit = -1; buts10_splittrack = -1; buts10_createterrain=-1;
end

if (pantalla==1) && (strcmp(tipo,'SON')==0)
	lbls9 = gtk(in,out,"gtk_label_new s9_join");
	buts9_refresh = gtk(in,out,"gtk_button_new_from_stock 'gtk-refresh'");
	buts9_joinall = gtk(in,out,"gtk_button_new_with_label 'Create Venue.xml'");
	s9_pb_joinall = gtk(in,out,"gtk_progress_bar_new ");
	lbls9dotdat = gtk(in,out,'gtk_label_new ".dat files are in dir:"'); gtk(in,out,["gtk_misc_set_alignment ",lbls9dotdat,"0.5 0.5"]);
	s9_dotdat = gtk(in,out,"gtk_entry_new"); gtk(in,out,["gtk_entry_set_text ",s9_dotdat,"\"",regexprep(char(current_dir),'\\','/'),"/images\""]);gtk(in,out,["gtk_entry_set_width_chars ",s9_dotdat,'20']);
	%s9_includebg = gtk(in,out,["gtk_check_button_new_with_label 'Include\nlist_bi.txt' 1"]);
	hseps9end= gtk(in,out,"gtk_hseparator_new");
	
	%s9
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls9, " 1 3 112 113"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", lbls9dotdat, " 20 22 112 113"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s9_dotdat, " 20 22 113 114"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts9_refresh, " 1 3 113 114"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", buts9_joinall, " 30 32 112 113"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", s9_pb_joinall, " 28 34 113 114"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", hseps9end, " 1 80 114 115"]);
else
	buts9_refresh=-1;buts9_joinall=-1;
end

if (pantalla==0)
	invisible = gtk(in,out,"gtk_label_new '      '");
	invisible2 = gtk(in,out,"gtk_label_new '      '");
	invisible3 = gtk(in,out,"gtk_label_new '      '");
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible, " 24 28 16 17"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible2, " 4 5 16 17"]);
	gtk(in,out,["gtk_table_attach_defaults ", tbl, " ", invisible3, " 19 20 16 17"]);
end

adv = gtk(in,out,"gtk_text_view_new 'Created with Octave!'");
advb = gtk(in,out,["gtk_text_view_get_buffer ",adv]);
gtk(in,out,["gtk_table_attach_defaults ", tbl2, " ", adv, " 1 2 58 60"]);
adv2 = gtk(in,out,"gtk_text_view_new 'Created with Octave!'");
advb2 = gtk(in,out,["gtk_text_view_get_buffer ",adv2]);
gtk(in,out,["gtk_table_attach_defaults ", tbl3, " ", adv2, " 1 2 58 60"]);


cadena='To start:\nCopy your kml to the s0_import folder\nand press \"Import the kml\" button';
informa_nuevo(in,out,advb,cadena)
informa_nuevo(in,out,advb2,cadena)

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
        if strcmp(event, buts0)
				informa_nuevo(in,out,advb,'S0');
				%gtk(in,out,["gtk_label_set_text ",adv,sprintf('"Processing"')]);
				ancho = gtk(in,out,["gtk_entry_get_text ", widths0]);
				[ancho cuenta] = sscanf(ancho,'%f',1);
				espaciado = str2num(gtk(in,out,["gtk_entry_get_text ", spacings0]));
				if cuenta==1
					try
						global progress_bar;
						progress_bar.id=s0_pb;
						progress_bar.in=in;
						progress_bar.out=out;
						ejecuta(in,out,advb,'cd s0_import;');
						fichero=encuentra_kml(); 
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]); gtk(in,out,"gtk_server_callback update");
						ejecuta(in,out,advb,sprintf('importakml(''%s'')',fichero));
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0.5)]);gtk(in,out,"gtk_server_callback update");
						ejecuta(in,out,advb,'cd ..\venue');
						ejecuta(in,out,advb,sprintf('btb06(%.1f,1,%.1f)',ancho,espaciado));
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
						cd .. %Necesario para inicializa_s2
						inicializa_s2(in,out,buts2b_makegrid,buts2b_raisekml,buts2b_readgrid,buts2b_plotlamalla,lbls2blimits,'s2_elevation_b','limits_b.kml')
						inicializa_s2(in,out,buts2_makegrid,buts2_raisekml,buts2_readgrid,buts2_plotlamalla,lbls2limits,'s2_elevation','limits.kml')
						informa_anyade(in,out,advb,'Operation Successful');
					catch
						gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);
						informa_anyade(in,out,advb,sprintf('"Operation failed %f"',ancho));
					end
									else
				informa_anyade(in,out,advb,"Operation failed. Set the width of the road");
				end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
		if strcmp(event, buts0_refresh)
			informa_nuevo(in,out,advb,'S0');
			try
				[ancho,espaciado,fichero]=inicializa_s0;
				gtk(in,out,["gtk_label_set_text ", lbls0kml,sprintf("'%s'",fichero)]);
				gtk(in,out,["gtk_entry_set_text ",widths0,sprintf('%.1f',ancho)]);
				gtk(in,out,["gtk_entry_set_text ",spacings0,sprintf('%.1f',espaciado)]);
				if strcmp(fichero,'File not found')==1
					gtk(in,out,["gtk_widget_set_sensitive ",buts0,"0"]);
				else
					gtk(in,out,["gtk_widget_set_sensitive ",buts0,"1"]);
				end
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
        if strcmp(event, buts2_makegrid)
			informa_nuevo(in,out,advb,'S2');
			try
				global progress_bar;
				progress_bar.id=s2_pb_makegrid;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				tamfile = str2num(gtk(in,out,["gtk_entry_get_text ", sizes2]));
				paso = str2num(gtk(in,out,["gtk_entry_get_text ", steps2]));
				ejecuta(in,out,advb,'cd s2_elevation');
				ejecuta(in,out,advb,sprintf('make_grid("limits.kml",%.1f,%d);',paso,tamfile));
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_raisekml,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		if strcmp(event, buts2_readgrid )
			informa_nuevo(in,out,advb,'S2');
			try
				global progress_bar;
				progress_bar.id=s2_pb_readgrid;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s2_elevation');
				ejecuta(in,out,advb,'read_grid;');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_plotlamalla,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		if strcmp(event, buts2_plotlamalla )
			informa_nuevo(in,out,advb,'S2');
			try
				ejecuta(in,out,advb,'cd s2_elevation');
				ejecuta(in,out,advb,'figure,plot_lamalla;');
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		if strcmp(event, buts2_refresh )
			informa_nuevo(in,out,advb,'S2');
			inicializa_s2(in,out,buts2_makegrid,buts2_raisekml,buts2_readgrid,buts2_plotlamalla,lbls2limits,'s2_elevation','limits.kml')
			try	
				cd s2_elevation;
				ficherokml = 'limits.kml';
				tamfile = str2num(gtk(in,out,["gtk_entry_get_text ", sizes2]));
				paso = str2num(gtk(in,out,["gtk_entry_get_text ", steps2]));
				cadena=sprintf('%d _relleno files needed',calcular_num_rellenos(ficherokml,tamfile,paso));
				informa_anyade(in,out,advb,cadena);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
		if strcmp(event, buts2_raisekml )
			informa_nuevo(in,out,advb,'S2');
			try
				global progress_bar;
				progress_bar.id=s2_pb_raisekml;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s2_elevation');
				ejecuta(in,out,advb,'raise_kml');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts2_readgrid,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
        if strcmp(event, buts2b_makegrid)
			informa_nuevo(in,out,advb,'S2b');
			try
				global progress_bar;
				progress_bar.id=s2b_pb_makegrid;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				tamfile = str2num(gtk(in,out,["gtk_entry_get_text ", sizes2b]));
				paso = str2num(gtk(in,out,["gtk_entry_get_text ", steps2b]));
				ejecuta(in,out,advb,'cd s2_elevation_b');
				ejecuta(in,out,advb,sprintf('make_grid("limits.kml",%.1f,%d);',paso,tamfile));
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts2b_raisekml,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		if strcmp(event, buts2b_readgrid )
			informa_nuevo(in,out,advb,'S2b');
			try
				global progress_bar;
				progress_bar.id=s2b_pb_readgrid;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s2_elevation_b;');
				ejecuta(in,out,advb,'read_grid;');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts2b_plotlamalla,"1"]);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
		if strcmp(event, buts2b_plotlamalla )
			informa_nuevo(in,out,advb,'S2b');
			try
				ejecuta(in,out,advb,'cd s2_elevation_b;');
				ejecuta(in,out,advb,'figure,plot_lamalla');
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		if strcmp(event, buts2b_refresh )
			informa_nuevo(in,out,advb,'S2b');
			inicializa_s2(in,out,buts2b_makegrid,buts2b_raisekml,buts2b_readgrid,buts2b_plotlamalla,lbls2blimits,'s2_elevation_b','limits_b.kml')
			try	
				cd s2_elevation_b;
				ficherokml = 'limits_b.kml';
				tamfile = str2num(gtk(in,out,["gtk_entry_get_text ", sizes2b]));
				paso = str2num(gtk(in,out,["gtk_entry_get_text ", steps2b]));
				cadena=sprintf('%d _relleno files needed',calcular_num_rellenos(ficherokml,tamfile,paso));
				informa_anyade(in,out,advb,cadena);
				informa_anyade(in,out,advb,'Operation Successful');
			catch
				informa_anyade(in,out,advb,'Operation Failed');
			end
		end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
		if strcmp(event, buts2b_raisekml )
			informa_nuevo(in,out,advb,'S2b');
			try
				global progress_bar;
				progress_bar.id=s2b_pb_raisekml;
				progress_bar.in=in;
				progress_bar.out=out;
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				ejecuta(in,out,advb,'cd s2_elevation_b');
				ejecuta(in,out,advb,'raise_kml');
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',1)]);gtk(in,out,"gtk_server_callback update");
				gtk(in,out,["gtk_widget_set_sensitive ",buts2b_readgrid,"1"]);
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
				dotdatdir=char(gtk(in,out,["gtk_entry_get_text ", s9_dotdat]));
				global progress_bar;
				progress_bar.id=s9_pb_joinall;
				progress_bar.in=in;
				progress_bar.out=out;
				
				gtk(in,out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0)]);gtk(in,out,"gtk_server_callback update");
				dotdatdir=strtrim(dotdatdir);
				if (exist(dotdatdir)==7)
					ejecuta(in,out,advb,'cd s1_mesh');
					ejecuta(in,out,advb,sprintf('add_dat_to_geo(\"%s\")',dotdatdir));
					ejecuta(in,out,advb,'cd ..');
				end
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

function [ancho,default_panel_length,fichero,distancia]=inicializa_s0()
		try 
	          S=load('..\anchors.mat');
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
		cd s0_import;
		fichero=encuentra_kml();
		default_panel_length=get_option('PANEL_LENGTH','%f');
		cd ..;
		
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
end

function informa_nuevo(in,out,advb,cadena)
gtk(in,out,["gtk_text_buffer_set_text ",advb,strcat('"',cadena,'"'),' -1']);
end

function informa_anyade(in,out,advb,cadena)
gtk(in,out,["gtk_text_buffer_insert_at_cursor ",advb,strcat('"\n',cadena,'"'),' -1']);
end

function ejecuta(in,out,advb,cadena)
informa_anyade(in,out,advb,['Running command:   ',strrep(cadena,'"','\"')]);gtk(in,out,"gtk_server_callback update");
eval(cadena);
end

function comprueba(in,out,ficheros,widget)
	[errores,nadena]=system(ficheros);
	numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena
	if numero_ficheros>0
		gtk(in,out,["gtk_widget_set_sensitive ",widget,"1"]);
	else
		gtk(in,out,["gtk_widget_set_sensitive ",widget,"0"]);
	end
end