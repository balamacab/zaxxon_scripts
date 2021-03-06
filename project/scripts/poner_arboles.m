function poner_arboles(fichero_distribucion,listado_arboles,fichero_salida)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin<2
    display('poner_arboles(''arboles2_20.mat'',''vegetacion.txt'',''salida\plantacion_arboles.txt'')');
    return;
end
[ancho_min ancho_max altura_min altura_max chocable escalado nombre proporcion]=textread(listado_arboles,'%f %f %f %f %d %f %s %f');

S=load(fichero_distribucion);
plantacion=S.plantacion;

coordenadas=zeros(length(plantacion),3);

for hh=1:length(plantacion)
  coordenadas(hh,1)=plantacion(hh).posicion(1);
  coordenadas(hh,2)=plantacion(hh).posicion(2);
  coordenadas(hh,3)=plantacion(hh).posicion(3);
end

afinidad=-1;%0.75;% Si un n�mero al azar entre 0 y 1 es menor que afinidad, repito mismo �rbol que el m�s cercano (tambi�n puedo repetir un hueco)
huecos=0.0;%Porcentaje de huecos que dejo en la plantaci�n

yahay=0;
indices=zeros(length(plantacion),1);
for hh=1:length(plantacion)
    if mod(hh,100)==0
      mensaje=sprintf('%f - %d\n',hh/length(plantacion),sum(indices>0));
      display(mensaje);
    end
    if plantacion(hh).plantable==1
         naleatorio=rand;
         if naleatorio>huecos
             naleatorio=rand;
             if (naleatorio<afinidad) && (yahay) 
	         %display('-');
                 indarbol=dame_mascercano(hh,coordenadas,indices);
                 arbol=indices(indarbol); %Repito el m�s cercano
		 if arbol==0
                    display('*')
		 end
	     else
		 %display('o');
                 arbol=dame_arbol(plantacion(hh),ancho_min,ancho_max,altura_min,altura_max,proporcion,nombre);
             end
	 else
	     arbol=0;
         end
    else
        arbol=0;
    end
    indices(hh)=arbol;
    if arbol>0
        yahay=1;
    end
end

inicio=strcat(...
'    <Object>\n',...
'      <Name>%s</Name>\n',...
'      <Path>%s</Path>\n',...
'      <Instances>\n');

Instancia=strcat(...
'        <Instance GroupId="0" %s>\n',...
'          <Planted>True</Planted>\n',...
'          <Scale x="%f" y="%f" z="%f" />\n',...
'          <Rotation x="%f" y="%f" z="%f" />\n',...
'          <Translate x="%f" y="%f" z="%f" />\n',...
'        </Instance>\n');

%display('Salvando ficheros');
%save -mat entorno.mat

display('Grabando');

%figure
%hold on
%colores='rgbmrgbmcwrgbmcw';

fid=fopen(fichero_salida,'w');
lineas_usables=ones(length(ancho_min),1);
cadena_a_grabar='';
for h=1:length(ancho_min)
    grupos_mismo_nombre=find(strcmp(nombre,nombre{h})==1);
    grupo=[];
    h_real=[];
    for t=1:length(grupos_mismo_nombre)
        if lineas_usables(grupos_mismo_nombre(t))==1
            losobjetos=find(indices==grupos_mismo_nombre(t));
            grupo=[grupo;losobjetos]; %Seleccionamos los �rboles de tipo h
            sush=grupos_mismo_nombre(t)*ones(size(losobjetos));
            h_real=[h_real;sush];
            lineas_usables(grupos_mismo_nombre(t))=0;
        end
    end
    if length(grupo)>0
        cadena=sprintf(inicio,nombre{h},nombre{h});
        cadena_a_grabar=strcat(cadena_a_grabar,cadena);
        for g=1:length(grupo)
            posicion=grupo(g);
            escalax=escalado(h_real(g))*(1+0.5*(rand-0.5));%variaci�n de +-25%
            escalay=escalado(h_real(g))*(1+0.5*(rand-0.5)); %varici�n de +-25%
            escalaz=escalax;
            rotacionx=0.05*rand;
            rotaciony=2*pi*rand;
            rotacionz=0.05*rand;
            posicionx=plantacion(posicion).posicion(1);
            posiciony=plantacion(posicion).posicion(2);
            posicionz=plantacion(posicion).posicion(3);
            %plot(posicionx,posicionz,strcat('o',colores(h)));
            if (chocable(h_real(g))==1) %&& (plantacion(posicion).separacion_carretera>3) %Remedio provisonal porque no me gusta c�mo se choca el coche con los �rboles
                Colisionable='Collisions="True"';
            else
                Colisionable='';
            end
            cadena=sprintf(Instancia,Colisionable,escalaz,escalay,escalaz,rotacionx,rotaciony,rotacionz,posicionx,posiciony,posicionz);
	    cadena_a_grabar=strcat(cadena_a_grabar,cadena);
        end
        cadena=sprintf('      </Instances>\n    </Object>\n');
        cadena_a_grabar=strcat(cadena_a_grabar,cadena);
    end
end
display('...');
fprintf(fid,'%s',cadena_a_grabar);
fclose(fid);



    function indice=dame_arbol(plantacion,ancho_min,ancho_max,altura_min,altura_max,proporcion,nombre);
        filtro1=(plantacion.separacion_carretera>=ancho_min);
        filtro2=(plantacion.separacion_carretera<=ancho_max);
        filtro3=(plantacion.posicion(2)>=altura_min);
        filtro4=(plantacion.posicion(2)<=altura_max);
        filtro=filtro1.*filtro2.*filtro3.*filtro4;
        %mensaje=sprintf('%d-%d-%d-%d',filtro1,filtro2,filtro3,filtro4);
        %display(mensaje)
        seleccion=(filtro>0);
        if sum(seleccion)>0
          seleccion=seleccion.*(proporcion);
          seleccion=seleccion/sum(seleccion);
          indice=aleatorio(seleccion);
          %if indice>0
          %    mensaje=sprintf('Arbol plantado: %s\n',nombre{indice});
          %    display(mensaje);
          %end
        else
          indice=0;
        end
    end

    function indarbol=dame_mascercano(hh,coordenadas,indices);
            x=coordenadas(hh,1);
            z=coordenadas(hh,3);
	    posibilidades=find(indices(1:hh-1)>0);
            coordenadas=coordenadas(posibilidades,:);
            [distancias indmin]=min((x-coordenadas(:,1)).^2+(z-coordenadas(:,3)).^2);
            indarbol=posibilidades(indmin);
    end

    function indice=aleatorio(seleccion)
        indice=0;
        n=rand();
        limite=seleccion(1);
        for h=1:length(seleccion)
            if n<limite
                indice=h;
                return;
            else
                if h<length(seleccion)
                    limite=limite+seleccion(h+1);
                else
                    indice=0;
                    return;
                end
            end
        end
    end

end
