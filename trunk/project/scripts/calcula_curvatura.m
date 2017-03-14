function offset=calcula_curvatura(lasx,lasy,distancias,dist,borde_izdo,borde_dcho)

ancho_total=sum(dist(borde_izdo:borde_dcho-1));

pdte_max=0.07;%pdte maxima
pdte_min=-0.02;%pdte minima
distancias(end+1)=distancias(end);
num=lasx+1j*lasy;
num=num';
cambios_angulo=([0 (diff(unwrap(angle(diff(num))))) 0])';

%curvatura:
%En un circulo de radio R, se cambian 2pi grados en total
%Distancia 2piR -> 2pi radianes. Cambio de 1/R radianes por metro 
% Cambio de R metros por radian
%R = distancia_recorrida/angulo_cambiado

%Cambio de angulo por metro recorrido
curvatura=cambios_angulo./distancias;
curvatura=filter([0.2 0.2 0.2 0.2 0.2],1,curvatura)
curvatura=[0; 0 ;curvatura(5:end); 0 ;0 ];
% for h=2:length(curvatura)
%     if sign(curvatura(h))~=sign(curvatura(h-1))
%         curvatura(h-1)=curvatura(h-1)*0.1;
%         curvatura(h)=curvatura(h)*0.1;
%     end
% end
%curvatura=[curvatura(2:end);0];
%figure,plot(curvatura);
%filtro=0.5*[-0.0625         0    0.5625    1.0000    0.5625         0   -0.0625];
%curvatura=filter(filtro,1,curvatura);
%curvatura=filter(filtro,1,curvatura);

%Como si hubiera dos carriles
%Elpunto central de cada carril está a la altura cero
%En el perfil de una recta el borde
%de la carretera está a altura -1% respecto del centro del carril
%En una curva el borde interior baja al -5%
%El borde exterior sube el 5%
%Centro: elevado entre 1% y 5% respecto de centro de carril
%afectado por la curvatura total, sin importar el signo
%Borde interior: entre -1% (recta) y -5% (curva máxima)
%Borde exterior: entre -1% (recta) y +5% (curva máxima)
%Centro de carril: altura 0 en lado interno

%Cambio en angulo positivo, el lado izquierdo es el interno
perfiles=zeros(3,length(lasx));%izda,centro,dcha
centro=(borde_izdo+borde_dcho)/2;
maximo=max(abs(curvatura));
satura=find(abs(curvatura)>maximo/2);
curvatura(satura)=sign(curvatura(satura))*maximo/2;
%curvatura=sign(curvatura)*maximo/2;
maximo=maximo/2;
% curvatura=[curvatura(4:end)' 0 0 0];
% umbral=0.1*maximo;
% rectas=find(abs(curvatura)<umbral);
% curvatura(rectas)=sign(curvatura(rectas))*umbral;
% curvatura=curvatura-sign(curvatura)*umbral;
% maximo=max(abs(curvatura));
medioancho=sum(dist(borde_izdo:centro-1));
distancias_al_centro=cumsum([0 dist])-sum([0 dist(1:centro-1)]);

for g=1:length(curvatura)
    if curvatura(g)<0 %Curva a izquierdas
        perfiles(2,g)=0;%Altura del centro de la calzada
        %interno
        perfiles(1,g)=medioancho*(pdte_min-(pdte_min+pdte_max)*abs(curvatura(g))/maximo);
        %Externo
        perfiles(3,g)=medioancho*(pdte_min+pdte_max*abs(curvatura(g))/maximo);
    elseif curvatura(g)<0%Curva a derechas
        perfiles(2,g)=0;%Altura del centro de la calzada
        %externo
        perfiles(1,g)=medioancho*(pdte_min+pdte_max*abs(curvatura(g))/maximo);
        %interno
        perfiles(3,g)=medioancho*(pdte_min-(pdte_min+pdte_max)*abs(curvatura(g))/maximo);
    else
        perfiles(2,g)=0;
        perfiles(1,g)=pdte_min*medioancho;
        perfiles(3,g)=pdte_min*medioancho;
    end
    offset(g,:)=interp1([-medioancho,0,medioancho],perfiles(:,g),distancias_al_centro(borde_izdo:borde_dcho),'linear','extrap');
end
%perfiles(1,g)=filter(filtro,1,perfiles(1,g));
%perfiles(3,g)=filter(filtro,1,perfiles(3,g));
%plot3(lasx,lasy,perfiles(1,:)),hold on
%plot3(lasx,lasy,perfiles(3,:),'r')

[p,k]=size(offset);
irregularidad=ruido(p,k);
offset=offset+irregularidad;

save('curvaturas.mat','offset');

    function salida=ruido(n1,n2)
        rng(189);
        r = 5; % radius (maximal 49)
        n1min = r+1; n1max = n1+r;
        n2min = r+1; n2max = n2+r;
        
        noise=zeros(n1+2*r+1,n2+2*r+1);
        promediados=5;
        for t=1:promediados
            noise = noise+randn(n1+2*r+1,n2+2*r+1);
        end
        noise=noise/(promediados/2);%Media 0
        noise=noise-mean(mean(noise));
        [a,b]=meshgrid(-r:r,-r:r);
        mask=((a.^2+b.^2)<=r^2); %(2*r+1)x(2*r+1) bit mask
        salida = zeros(n1+2*r,n2+2*r);

        for i=n1min:n1max
            for j=n2min:n2max
                A = noise((i-r):(i+r), (j-r):(j+r));
                salida(i,j) = sum(sum(A.*mask));
            end
        end
        Nr = sum(sum(mask)); salida = salida(n1min:n1max, n2min:n2max)/Nr;
    end
end