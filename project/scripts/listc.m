function listc()
fid=my_fopen('salida\joined.geo','r');
contents=fread(fid,Inf);
my_fclose(fid);
cadena=char(contents)';
pos=strfind(cadena,'END OF JOINED');
pos_inicial=pos(1);
[s, e, te, m, t, nm] = regexp (cadena, 'Plane Surface\((\d+)\)');
fid=my_fopen('salida\listc.geo','w');
for h=1:length(t)
	fprintf(fid,'%s,',char(t{h}));
end
my_fclose(fid)
