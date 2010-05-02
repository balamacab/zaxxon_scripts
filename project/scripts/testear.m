function  testear()

  fichero_de_nodos_con_altura='nodos_conaltura.txt';
  fichero_elements='elements.txt';


nac=obtener_nac();
%nac es el número de anchors de la carretera
%Si son 7824 la numeración de los enganches de la carretera llega desde 0 hasta
%nac-1=7823

[numero x y z]=textread(fichero_de_nodos_con_altura,'%d %f %f %f');
temp=y;
y=z;
z=temp;

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

tamanyo=length(n1);
tramos=cargar_tramos();
for h=1:1:nac
  [anchor1 anchor1B]=obtener_anchor(h-1,1,0,0,1,tramos,nac);
   display(sprintf('%d - %s',h,anchor1));
end
  
  function [anchor anchorB]= obtener_anchor(numero,escarretera,altura,distancia,esconducible,tramos,nac)
        % 0% de mezcla significa todo tierra, 1% todo césped
        altura_inicial=2375; 
        altura_final=2425;
        if altura>altura_final
            porcentaje=1;
        else
            if altura<altura_inicial
                porcentaje=0;
            else
                porcentaje=1-1*(altura_final-altura)/(altura_final-altura_inicial);
            end
        end

        if esconducible==1 % En la zona conducible pasamos de 0 a 1 entre los metros de distancia 5 y 10
            porcentaje=1; %CAMBIO: SI ES CONDUCIBLE NO HACEMOS CASO DE LA ALTURA
            if distancia<5
                porcentaje=0;
            else if distancia>10
                    porcentaje=1*porcentaje; %No más césped que el que corresponda por altura
                else %Entre 10 y 20 metros
                    porcentaje=0+porcentaje*(distancia-5)/5; %No más césped que el que corresponda por altura
                end
            end
        end
		anchorB='';
        if escarretera==1
			%display(sprintf('1)%d',numero));
			numero_original=numero;
			if numero_original>=nac/2 %si es de la parte derecha
				numero=numero-nac/2; %Lo "convertimos" momentáneamente en nodo de la parte izquierda
				%display(sprintf('2)%d',numero));
			end
			[track nodo_inicial frontera]=dame_nodo_inicial(numero,tramos); %Este cálculo solo sirve para parte izquierda
			if numero_original>=nac/2 %si es de la parte derecha
				numero=numero+(tramos(track+1,2)-tramos(track+1,1))+1; %Lo devolvemos a la parte derecha
				%display(sprintf('3)%d',numero));
			end
			%display(sprintf('4)%d\n',numero-nodo_inicial));
			anchor=sprintf('T%d %d" P="%.2f',track,numero-nodo_inicial,porcentaje);
			anchorB=anchor; %En los anchors de carretera no conflictivos, anchor y anchorB coinciden
			if frontera==1 
			    display('*');
				% anchorB tiene la numeración más alta del track anterior, por si hace falta
				trackb=track-1;
				if numero_original>=nac/2;%Derecha
						anchorB=sprintf('T%d %d" P="%.2f',trackb,2*(tramos(trackb+1,2)-tramos(trackb+1,1))+1,porcentaje);   %último de la derecha del tramo anterior
				else
						anchorB=sprintf('T%d %d" P="%.2f',trackb,(tramos(trackb+1,2)-tramos(trackb+1,1)),porcentaje);		%último de la izquierda	del tramo anterior			
				end
			end
        else
            anchor=sprintf('A%d" P="%.2f',numero,porcentaje);
        end
    end

end

function tramos=cargar_tramos()
	tramos=load('tramos.mat');
	tramos=tramos.tramos;
	longitud_actual=tramos(end,2)+1;
	[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

	for h=1:numero_sons
		tramos_extra=load(strcat(char(caminos(h)),'\s10_split\tramos.mat'));
		tramos_extra=tramos_extra.tramos;
		longitud=tramos(end,2)+1;
		tramos=[tramos; tramos_extra+longitud];
		tama=size(tramos);
	end		
	save('temporal.mat','tramos');
end

function nac=obtener_nac()
    S=load('..\nac.mat');
    nac=S.nac;
	[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

	for h=1:numero_sons
		nac_extra=load(strcat(char(caminos(h)),'\nac.mat'));
		nac_extra=nac_extra.nac;
		nac=nac+nac_extra;
	end
	save('temporal2.mat','nac');
end	