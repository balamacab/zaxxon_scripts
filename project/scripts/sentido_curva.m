function sentido_horario=sentido_curva(Px,Py);
%1->sentido horario

direcciones=mod(atan2(diff([Py Py(1) Py(2)]),diff([Px Px(1) Px(2)])),2*pi);
angulos=diff(direcciones);
mayores=find(angulos>pi);
angulos(mayores)=angulos(mayores)-2*pi;
menores=find(angulos<-pi);
angulos(menores)=angulos(menores)+2*pi;

sentido_horario=-sign(sum(angulos));
%La suma de los �ngulos internos es (n-2)*pi para un pol�gono de n-lados
