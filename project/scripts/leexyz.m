function leexyz(fichero,distancia)

fid=fopen(fichero,'r');
datos=fscanf(fid,'%f');
x=datos(1:3:end);
y=datos(2:3:end);
z=datos(3:3:end);

rangox=min(x):distancia:max(x);
rangoz=min(y):distancia:max(y);

malla_regular=reshape(z,1024,1024)';
save -binary 'lamalla.mat' rangox rangoz malla_regular
surf(malla_regular(1:4:end,1:4:end));
