function crearbase()
[mapeo]=textread('..\mapeo.txt','%f');
paso=50;
coordenadaxinicial=mapeo(1)%-105.037205228836; %mapeo(3)
coordenadaxfinal=mapeo(5)%-105.042881979876; %mapeo(7)
coordenadazinicial=mapeo(2)%38.9209304085051; %mapeo(4)
coordenadazfinal=mapeo(6)%38.8405926230566;   %mapeo(8)

try 
  S=load('lamalla2.mat');
catch
  S=load('lamalla.mat');
end_try_catch

margenx1=floor(abs(S.rangox(1)-coordenadaxinicial)/paso)-1;
margenx2=floor(abs(S.rangox(end)-coordenadaxfinal)/paso)-1;
margenz1=floor(abs(S.rangoz(1)-coordenadazinicial)/paso)-1;
margenz2=floor(abs(S.rangoz(end)-coordenadazfinal)/paso)-1;
clear S;

[x,y] = meshgrid(coordenadaxinicial-margenx1*paso:paso:coordenadaxfinal+margenx2*paso,coordenadazinicial-margenz1*paso:paso:coordenadazfinal+margenz2*paso);


[m,n]=size(x);
num=1:m*n;
x=reshape(x,m*n,1);
num=reshape(num,m,n);
tri=[];
for h=1:m-1
   for g=1:n-1
	   tri=[tri;[num(h,g)  num(h+1,g+1) num(h+1,g)]];
	   tri=[tri;[num(h+1,g+1)  num(h,g) num(h,g+1)]];
   end
end
[m,n]=size(y);
y=reshape(y,m*n,1);

z=x*0;
try
    alturas=procesar_nodostxt([0 0],[(1:length(x))' x y z],'salida/fondo.txt');
catch
    alturas=z;
    fprintf(2,'background not raised\n');
end %_try_catch

u=(x-coordenadaxinicial)/(coordenadaxfinal-coordenadaxinicial);
v=(y-coordenadazinicial)/(coordenadazfinal-coordenadazinicial);
graba(x,y,alturas,tri,'salida/nodosbg.txt','salida/elementsbg.txt','salida/texturasbg.txt',ones(1,longitud(tri,3)),u,v);
msh_to_obj('salida/nodosbg.txt','salida/elementsbg.txt','test.mtl');
system('copy salida\\test.obj salida\\fondo.obj');

    function salida=longitud(a,tam_elemento)
        if isempty(a)==0
            [mm,nn]=size(a);
            salida=mm*nn/tam_elemento;
        else
            salida=1;8
        end
    end
  function graba(x,y,z,tri,fi_nodos,fi_elem,fi_text,zone,uu,vv)%'salida/fichero_nodos.txt' 'salida/fichero_elements.txt' 'salida/texturas.txt'
        rango=(1:length(x));
        [s1,s2]=size(rango);if (s2<s1) rango=rango.';end
        [s1,s2]=size(x);if (s2<s1) x=x.';end
        [s1,s2]=size(y);if (s2<s1) y=y.';end
        [s1,s2]=size(z);if (s2<s1) z=z.';end

        fid=fopen(fi_nodos,'w');
        fprintf(fid,'%d %f %f %f\n',[rango' x' y' z']');%En este fichero la última columna es la altura
        fclose(fid);

        fid=fopen(fi_elem,'w');
        fprintf(fid,'%d 2 2 %d 0 %d %d %d  \n',[(1:longitud(tri,3))' zone' tri ]');
        fclose(fid);

        fid=fopen(fi_text,'w');
        fprintf(fid,'vt %f %f\n',[uu;vv]);
        fclose(fid);
    end
	
	end
