function convertir(fichero_entrada,fichero_salida)

fid=fopen(fichero_entrada,'r');
[salida1]=fscanf(fid,'%f,%f,%f ',inf);
longitud=salida1(1:3:end);
latitud=salida1(2:3:end);
altura=salida1(3:3:end);
fclose(fid);

[mapeo]=textread('..\mapeo.txt','%f');

malla=load('lamalla.mat');

[x y z]=coor_a_BTB(longitud,latitud,altura,mapeo);

alturas=interp2(malla.rangox,malla.rangoz,malla.malla_regular,x,z);

fid=fopen(fichero_salida,'w');
for h=1:length(x)
	% fprintf(fid,'%f %f %f\r\n',x(h),alturas(h),z(h));
	imprime_nodo(fid,h,x(h),z(h),alturas(h),0,0,1,1);
end
fclose(fid);


function imprime_nodo(fid,h,Px,Pz,Py,AXZ,AY,EnD,ExD);
	
	fprintf(fid,'        <node NodeId=\"%d\">\r\n',h);
	fprintf(fid,'          <Position x=\"%f\" y=\"%f\" z=\"%f\" />\r\n',Px,Py,Pz);
	fprintf(fid,'          <ControlPoints AngleXZ=\"%f\" AngleY=\"%f\" EntryDistance=\"%f\" ExitDistance=\"%f\" />\r\n',AXZ,AY,EnD,ExD);
	fprintf(fid,'        </node>\r\n');

end



end