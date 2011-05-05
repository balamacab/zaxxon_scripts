function nodes_to_geo(curvas)

S=load('nodos.mat');
longitud=length(S.tree);

fid=my_fopen('nodes.geo','w');
fprintf(fid,'numk=newp;\n');
fprintf(fid,'numc=newc;\n')

contador=0;
for h=1:longitud
	        x=S.tree(h).Position.x;
            y=S.tree(h).Position.z;
            fprintf(fid,'Point (numk+%d)={%f, %f, %f};\r\n',contador,x,y,0);%nada(h) en lugar de 0
			if (isempty(findstr(curvas,'t'))==0) & (h>1)
			    fprintf(fid,'Line(numc+%d)={numk+%d,numk+%d};\r\n',contador,contador-1,contador);
			end
			contador=contador+1;
end

if (isempty(findstr(curvas,'t'))==0) 
            fprintf(fid,'Line(numc+%d)={numk+%d,numk+%d};\r\n',0,contador-1,0);
end

if (isempty(findstr(curvas,'s'))==0)
            fprintf(fid,'numc=newc;\n');
			
			fprintf(fid,'Spline(numc)={');
			for h=1:longitud
			    fprintf(fid,'numk+%d,',h-1);
			end
			fprintf(fid,'numk+%d};\r\n',0);
end

my_fclose(fid);