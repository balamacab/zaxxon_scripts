function haz_todo(id_conducible)

calcular_pendientes('anchors_originales.mat','elements.txt',id_conducible)
crear_superficies('anchors_originales.mat','pendientes.mat','nodos_carretera.mat',5,7)
genera_nuevos_anchors('anchors_originales.mat','nuevos_anchors.mat')