function salida=leerdls(fuente)
fid = fopen(fuente,'r');
texto=fread(fid,8);
inicio1=fread(fid,16*7+4+12);
%inicio2=fread(fid,19,'integer*4');

%fread(fid,2,'integer*4')

for h=1:inicio1(85)
    d2=fread(fid,2,'integer*4');
    d1=fread(fid,1,'single');    
    %fprintf(2,'%d %f %d %d = %s %s %s\n',h,d2(1),d2(2),d1,dec2hex(d2(1),8),dec2hex(d2(2),8),num2hex(single(d1)));
    salida(h,:)=[d2(1) d2(2) d1];
end
hueco=fread(fid,32);
otracosa=fread(fid,16);
tams=fread(fid,2,'integer*4');
cadenafinal=fread(fid,tams(2));
fclose(fid);
end
