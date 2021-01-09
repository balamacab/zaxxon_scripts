function crear_mats()    

    display('Generando ..\anchors.mat...)');
    
    [tree] = leer_anchors('anchors_s1.xml','Position');
    
    for h=1:length(tree.TerrainAnchor)
        x(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.x  ;
        y(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.y  ;
        z(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.z  ;
        if h>1
            if (x(h)==x(h-1)) && (z(h)==z(h-1))
                display('Duplicado')
            end
        end
    end
    save '..\anchors.mat' x y z tree;

    longitud=length(x);
    nac=longitud
    save '..\nac.mat' nac


   
    leer_porcentajes('porcentajes.xml','porcentajes.mat')
    
    leer_nodos('nodes.xml','nodos.mat')

end
