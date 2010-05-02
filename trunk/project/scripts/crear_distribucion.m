function crear_distribucion(fichero_elements,fichero_de_nodos,identificador,separacion_minima,densidad,semilla,limites,fichero_salida)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin<8
    %display('Algunos tri�ngulos pr�ximos a la carretera parecen estar demasiado estirados y eso genera problemas visuales')
    display('Par�metros:')
    display('1) Fichero de definici�n de los tri�ngulos Ej: elements.txt')
    display('2) Fichero con alturas actualizadas Ej: nodos_conaltura.txt')
    display('3) Identificador de la superficie donde se van a plantar los �rboles. Ej: 111')
    display('4) Separaci�n m�nima entre dos objetos: Ej: 2 para �rboles, 0.4 para hierbas');
    display('5) Densidad de objetos. Cuanto menor, m�s denso. Ej: 1');
    display('6) Semilla para la incializaci�n aleatoria');
    display('7) L�mites (carretera y elevaci�n): [separacion_minima separacion_maxima altura_minima altura_maxima]');
    display('8) Fichero de salida');
    display('Ejemplo: crear_distribucion(''elements.txt'',''nodos_conaltura.txt'',111,2,1,123,[0 20 2700 4300],''distribucion.mat'')');        return;
end



rand('twister',semilla);

S=load('..\nac.mat')
nac=S.nac;

[numero x z y]=textread(fichero_de_nodos,'%d %f %f %f');

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

interpolar=0;

if interpolar==1
    %Pongo m�s puntos en la carretera para medir mejor la distancia de los
    %�rboles a ella
    interpolacion=3;
    filtro=[0.3333    0.6667    1.0000    0.6667    0.3333];%intfilt(3,1,'Lagrange');
    xizquierda=upsample(x(1:nac/2),interpolacion);
    xderecha=upsample(x(nac/2+1:nac),interpolacion);
    xizquierda=filter(filtro,1,xizquierda);
    xderecha=filter(filtro,1,xderecha);

    zizquierda=upsample(z(1:nac/2),interpolacion);
    zderecha=upsample(z(nac/2+1:nac),interpolacion);
    zizquierda=filter(filtro,1,zizquierda);
    zderecha=filter(filtro,1,zderecha);
else
    xizquierda=x(1:nac/2);
    xderecha=x(nac/2+1:nac);
    zizquierda=z(1:nac/2);
    zderecha=z(nac/2+1:nac);
end

%plot(1:1/interpolacion:nac/2,xizquierda(3:end),'+',1:nac/2,x(1:nac/2),'x');

xcarretera=[xizquierda(2:end);xderecha(2:end)];
zcarretera=[zizquierda(2:end);zderecha(2:end)];

contador=0;
display('Maximo de 200000 puntos');
yaplantados=zeros(200000,3);
plantacion_posicion=zeros(200000,3);
plantacion_separacioncarretera=zeros(200000,1);
plantacion_normal=zeros(200000,3);
plantacion_plantable=zeros(200000,1);

display('Poniendo puntos')

for h=1:length(n1)

    if mod(h,100)==0
            mensaje=sprintf('%.2f - %d\n',h/length(n1),contador);
	    display(mensaje);
    end

    if length(find(id_superficie(h)==identificador))>0
	%display('Entro');
	%tic        
        vertice1=[x(n1(h)) y(n1(h)) z(n1(h))];
        vertice2=[x(n2(h)) y(n2(h)) z(n2(h))];
        vertice3=[x(n3(h)) y(n3(h)) z(n3(h))];
	lado1=norm(vertice1-vertice2);
	lado2=norm(vertice2-vertice3);
	lado3=norm(vertice3-vertice1);
	ladomax=max([lado1 lado2 lado3]);

        [normal plantable]=examinarsup(n1(h),n2(h),n3(h),x,y,z,nac);

        area=elarea(vertice1,vertice2,vertice3);

	%Para que los tri�ngulos con �rea<densidad no tengan siempre al menos un �rbol (acelera mucho el proceso)
	area=area-densidad*rand;
	%toc
        while (area>0)
	    %display('Lazo1')	
	    %tic    
            punto=aleatorio(vertice1,vertice2,vertice3);
            punto_x=punto(1);
            punto_z=punto(3);
            punto_y=punto(2);
            distancias=sqrt((punto_x-xcarretera).^2+(punto_z-zcarretera).^2);
            separacion=min(distancias);
	    if separacion>2*ladomax
		break;
	    end
            if (contador>0) & (separacion_minima>0) 
                distancias_a_yaplantados=sqrt((punto_x-yaplantados(1:contador,1)).^2+(punto_z-yaplantados(1:contador,3)).^2);
                distancia_a_yaplantados=min(distancias_a_yaplantados);
            else
                distancia_a_yaplantados=100;%Valor que har� que el primero se acepte
            end
            %toc
	    %display('Lazo2')	
	    %tic
            if (distancia_a_yaplantados>separacion_minima) && (separacion>=limites(1)) && (separacion<=limites(2)) && (punto_y>=limites(3)) && (punto_y<=limites(4))
                contador=contador+1;
                plantacion_posicion(contador,:)=[punto_x punto_y punto_z];
                plantacion_separacioncarretera(contador)=separacion;
                plantacion_normal(contador,:)=normal;
                plantacion_plantable(contador)=plantable;
                yaplantados(contador,:)=[punto_x punto_y punto_z];
            end
            area=area-densidad;
	    %toc
        end
    end
end

plantacion=struct('posicion',num2cell(plantacion_posicion(1:contador,:),2),'separacion_carretera',num2cell(plantacion_separacioncarretera(1:contador),2),'normal',num2cell(plantacion_normal(1:contador,:),2),'plantable',num2cell(plantacion_plantable(1:contador),2));

display('Grabando ficheros');

fidg=fopen('salida\plantacion.geo','w');
for h=1:length(plantacion)
    punto_x=plantacion(h).posicion(1);
    punto_y=plantacion(h).posicion(2);
    punto_z=plantacion(h).posicion(3);
    fprintf(fidg,'Point(%d) = {%f, %f, %f};\n',h,punto_x,punto_y,punto_z);
end
fclose(fidg);

save(fichero_salida,'plantacion')

function area=elarea(a,b,c)
area=triangle_area([a;b;c]);
end


%Let A, B, C be the three vertices of your triangle. Any point P inside can be expressed uniquely as P = aA + bB + cC, 
%where a+b+c=1 and a,b,c are each ? 0. Knowing a and b permits you to calculate c=1-a-b. So if you can generate two random 
%numbers a and b, each in [0,1], such that their sum ? 1, you�ve got a random point in your triangle.

%One way to do this is to generate random a and b independently and uniformly in [0,1] (just divide the standard C rand() by 
%its max value to get such a random number.) If a+b>1, replace a by 1-a, b by 1-b. Let c=1-a-b. Then aA + bB + cC is uniformly 
%distributed in triangle ABC: the reflection step a=1-a; b=1-b gives a point (a,b) uniformly distributed in the triangle (0,0)(1,0)(0,1), 
%which is then mapped affinely to ABC. Now you have barycentric coordinates a,b,c. Compute your point P = aA + bB + cC. 

    function punto=aleatorio(vertice1,vertice2,vertice3)
        a=rand();
        b=rand();
        while (a+b)>1,
            a=1-a;
            b=1-b;
        end
        c=1-a-b;
        punto=a*vertice1+b*vertice2+c*vertice3;
    end

    function [normal plantable]=examinarsup(n1,n2,n3,x,y,z,nac) 
        pendiente_cortado=0.5;
        plantable=1;
        vertice1=[x(n1) y(n1) z(n1)];
        vertice2=[x(n2) y(n2) z(n2)];
        vertice3=[x(n3) y(n3) z(n3)];
        vector1=vertice1-vertice2;
        vector2=vertice2-vertice3;
        normal=cross(vector1,vector2);
        if normal(2)<0
            normal=-normal;
        end
		if norm(normal)==0
			plantable=0;
			display('Tri�ngulo mal formado');
			return;
		end
        normal=normal/norm(normal);
            
        if (n1>nac) && (n2>nac) && (n3>nac)
            plantable=1;
        else            
            if n1<=nac/2
                saliente=vertice1-[x(n1+nac/2) y(n1+nac/2) z(n1+nac/2)];%vector que cruza la carretera de lado a lado saliente 
            else
                if n1<=nac
                    saliente=vertice1-[x(n1-nac/2) y(n1-nac/2) z(n1-nac/2)];%vector que cruza la carretera de lado a lado saliente 
                end
            end
            if n2<=nac/2
                saliente=vertice2-[x(n2+nac/2) y(n2+nac/2) z(n2+nac/2)];%vector que cruza la carretera de lado a lado saliente 
            else
                if n2<=nac
                    saliente=vertice2-[x(n2-nac/2) y(n2-nac/2) z(n2-nac/2)];%vector que cruza la carretera de lado a lado saliente 
                end
            end
            if n3<=nac/2
                saliente=vertice3-[x(n3+nac/2) y(n3+nac/2) z(n3+nac/2)];%vector que cruza la carretera de lado a lado saliente 
            else
                if n3<=nac
                    saliente=vertice3-[x(n3-nac/2) y(n3-nac/2) z(n3-nac/2)];%vector que cruza la carretera de lado a lado saliente 
                end
            end
            %Si la normal a la superficie va en la misma direcci�n que el vector que cruza la carretera aceptamos la superficie,
            %si no es as� lo condicionamos a su pendiente
            versigno=dot(saliente,normal);
            if versigno>0  % La monta�a junto a la carretera baja
                plantable=1; 
            else           % La monta�a junto a la carretera sube
                if abs(normal(2))<abs(pendiente_cortado+0.05*randn);
                    plantable=1          %sube poco
                else
                    plantable=0;         %es un cortado -> sin �rboles
                end
            end
        end
    end
end
