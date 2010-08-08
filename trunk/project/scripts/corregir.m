function corregir(fichero,intensidad,tau_espacial)
if nargin<=1
   intensidad=1;
   tau_espacial=1;
end
tau_espacial=round(tau_espacial);
factor=2;
intensidad=(1/factor)*intensidad;

S=load('lamalla.mat');
matriz_correccion=0*S.malla_regular;
mat_contador=0*S.malla_regular;

if nargin==0 % Si no nos dan un kml con alturas, usamos la salida de creartrack1
	%Alturas según los datos de altura de la montaña

	display('Leyendo alturas_track1.mat');
	alturas1=load('alturas_track1.mat');
	alturas_track1=alturas1.alturas_track1;

	alturas1=load('track0.mat');
	alturas_suavizadas=alturas1.alturas_suavizadas;

	anchors=load('..\anchors.mat');

	x=anchors.x;
	y=anchors.y;
	z=anchors.z;

	nac=length(x);
	 
	x=0.5*(x(1:nac/2)+x(nac/2+1:end));
	z=0.5*(z(1:nac/2)+z(nac/2+1:end));
else  % Si nos dan un fichero kml, obtenemos la altura de la montaña para él y la comparamos con los datos del propio kml
    [numero_padres caminos]=look_for_father_or_sons('..\father.txt');
	[longitud latitud altura]=leer_datos(fichero);
	if numero_padres==0  % Si no hay padre, generamos mapeo.txt. Si no lo hay, usamos el mapeo.txt existente
		[mapeo]=textread('..\mapeo.txt','%f');
	else
		[mapeo]=textread(strcat(caminos(1),'\mapeo.txt'),'%f');
	end
	for h=1:length(longitud)    
			[lax nada laz]=coor_a_BTB(longitud(h),latitud(h),0,mapeo);
			x(h)=lax;
			z(h)=laz;
	end	
	%Alturas según la montaña
	alturas_track1=z_interp2(S.rangox,S.rangoz,S.malla_regular,x,z);
	alturas_suavizadas=altura; %Damos por altura buena la que viene del fichero
end

plot(1:length(alturas_track1),alturas_track1,1:length(alturas_suavizadas),alturas_suavizadas);

y=z; %Cambiamos la notación entre 'y' y 'z' a partir de aquí
xy = [x;y];
df = diff(xy,1,2); 

distancia = cumsum([0, sqrt([1 1]*(df.*df))]);  %La variable es la distancia

salto=(1/factor)*(S.rangox(2)-S.rangox(1))*(tau_espacial+1) %Es el alcance de cada corrección
posicion=1;
distancia_recorrida=-1;
while (posicion<=length(distancia))
     if distancia(posicion)>distancia_recorrida
     [matriz_correccion mat_contador]=corrige(S.rangox,S.rangoz,matriz_correccion,x(posicion),y(posicion),alturas_track1(posicion),alturas_suavizadas(posicion),mat_contador,intensidad,tau_espacial);
        distancia_recorrida=distancia_recorrida+salto;
     end
     posicion=posicion+1;
end

promediar=0;
if promediar==1
    mat_contador(mat_contador==0)=1;
    matriz_correccion=matriz_correccion./mat_contador;
end

rangox=S.rangox;
rangoz=S.rangoz;
malla_regular=S.malla_regular+matriz_correccion;
save('lamalla.mat','rangox','rangoz','malla_regular');

[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

%Actualizamos lamalla.mat en el directorio del padre
if numero_padres>0
   system(sprintf('copy lamalla.mat %s\\s3_road\\.',char(caminos(1))));
end


%para completar el proceso hay que volver a ejecutar dar_altura
creartrack1
message(21)




function [matriz mat_contador]=corrige(rangox,rangoy,matriz,x,y,alt1,alt2,mat_contador,intensidad,tau_espacial)
matriz=matriz';
mat_contador=mat_contador';
pasox=rangox(2)-rangox(1);
pasoy=rangoy(2)-rangoy(1);

indicex=floor((x-rangox(1))/pasox)+1;
indicey=floor((y-rangoy(1))/pasoy)+1;
difx=(x-((indicex-1)*pasox+rangox(1)))/pasox;
dify=(y-(rangoy(1)+(indicey-1)*pasoy))/pasoy;

correccion=intensidad*(alt2-alt1);

for indx=indicex-tau_espacial:indicex+tau_espacial+1
  for indy=indicey-tau_espacial:indicey+tau_espacial+1
     distanciax=abs(indicex-indx+difx);
     distanciay=abs(indicey-indy+dify);
     [matriz mat_contador]=retoca(matriz,mat_contador,rangox,rangoy,indx,indy,distanciax,distanciay,correccion,tau_espacial);
  end
end





matriz=matriz';
mat_contador=mat_contador';


function [matriz mat_contador]=retoca(matriz,mat_contador,rangox,rangoy,indicex,indicey,distx,disty,correccion,tau_espacial);
if ((indicex<=length(rangox)) && (indicey<=length(rangoy)) && (indicex>=1) && (indicey>=1))
  distancia=sqrt(distx^2+disty^2);
  matriz(indicex,indicey)+=correccion*(1-(distancia/(sqrt(2)*(tau_espacial+1))));
  mat_contador(indicex,indicey)+=1;
end
