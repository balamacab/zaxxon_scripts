[numero_padres caminos]=look_for_father_or_sons('..\father.txt',1);
if numero_padres==0 
   system('copy ..\s4_terrain\salida\elements.txt .')
   system('copy ..\s6_hairpins\salida\nodos_conaltura.txt .')
end
system('copy ..\Venue\nodos.mat .');
system('copy ..\Venue\porcentajes.mat .');

message(14);
