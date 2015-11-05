function c = cargarSonido
    c.cargar = @cargar;
    c.agregarRuido = @agregarRuido;
end

function [ a, fs ] = cargar( nameSong )
    [a, fs] = wavread( nameSong );
    % stereo to mono
    if size(a,2) > 1
        a = ( a(:,1)+a(:,2) )/2;
    end
end

function a = agregarRuido( a, percentage )
    [x y] = size(a);
    a = a + (percentage * rand(x,y));
end