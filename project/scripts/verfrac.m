
function [ ret ] = verfrac ()
   S=load('s11_m3d/anchors.mat');
   nac=length(S.x)/2;
   figure,plot(S.x(1:nac),S.z(1:nac));
   hold on,text(S.x(1),S.z(1),'s','horizontalalignment','center');
   for g=0.1:0.1:0.9
      hold on,text(S.x(round(g*nac)),S.z(round(g*nac)),'x','horizontalalignment','center','horizontalalignment','center');
   end
   hold on,text(S.x(end),S.z(end),'e','horizontalalignment','center');
endfunction
