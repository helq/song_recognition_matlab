% cargar cualquier sonido y 
function c = cargarSonido
    c.cargar = @cargar;
    c.agregarRuido = @agregarRuido;
end

function [ a, fs ] = cargar( nameSong )
    [a, fs] = audioread( nameSong );
    % stereo to mono
    if size(a,2) > 1
        a = ( a(:,1)+a(:,2) )/2;
    end
    
    % filtering
    [b,a_butter]=butter(10,3e3/(fs/2),'low'); 
    a=filtfilt(b,a_butter,a);

end

function a = agregarRuido( a, percentage )
    [x, y] = size(a);
    a = a + (percentage * rand(x,y));
end