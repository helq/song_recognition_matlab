function h = huella
    h.spectrogram = @shortSpectrogram;
    h.get_huella  = @get_huella;
    h.song2huella = @song2huella;
end

% crea un espectograma de un sonido, dada su frecuencia, y el intervalo
% entre cada frecuencia de las que se quiere mostrar
function [Y F T PXX] = shortSpectrogram(a, fs, intervalo_f)
    %[~, f t Pxx] = spectrogram(a, 512, 480, 1024, fs, 'yaxis');
    %[~, f t Pxx] = spectrogram(a, 1024, 940, 1024, fs, 'yaxis'); % más detallado
    %[~, f t Pxx] = spectrogram(a, 2048, 1920, 1024, fs, 'yaxis'); % aún más detallado
    f_detalle = fs/intervalo_f; % VALOR FIJO PARA OBTENER UN VALOR POR CADA Hz
    chunk_size = 8192;
    half_chunk_size = floor(chunk_size/2);

    len_f_to_cut = 305/intervalo_f; % 305 es el límite del rango a mostrar
    
    PXX_size = floor(length(a)/half_chunk_size)-1;
    
    PXX = zeros(len_f_to_cut, PXX_size);
    
    portion_pos = 1;
    i=1;
    while portion_pos < length(a)
    %for i=1:1
        a_ = a(portion_pos : min(portion_pos+(chunk_size*100),length(a)) );
        portion_pos = portion_pos + (chunk_size*100) - half_chunk_size;
        [~, f, ~, Pxx] = spectrogram(a_, chunk_size, half_chunk_size, f_detalle, fs, 'yaxis');

        PXX(:, i:i+size(Pxx,2)-1) = Pxx(1:len_f_to_cut,:);
        i=i+size(Pxx,2);
    end
    F = f(1:len_f_to_cut);
    Y = 10*log10(abs(PXX)+eps);
    %Y = log10(abs(PXX)+1);
    T = (1:size(Y,2))/(fs/half_chunk_size);
end

function [song_h] = get_huella(spect, intervalo_f)
    RANGES = [30,40,80,120,180,300]/intervalo_f;
    RANGES(end) = RANGES(end)+1;
    
    n = length(RANGES)-1;
    song_h = zeros(n, size(spect,2)); % huella de la canción a retornar
    for i=1:n
        [~, I] = max( spect(RANGES(i):RANGES(i+1)-1,:) );
        song_h(i,:) = I+RANGES(i)-1;
    end
    song_h = song_h*5;
end

function [huellaSong t] = song2huella(song)
    % multiples canales a mono
    if size(song,2) > 1        
        n = size(song, 2);
        song = sum(a)/n;
    end
    
    intervalo_frecuencia = 5;
    [y, ~, t] = shortSpectrogram(song, fs, intervalo_frecuencia);
    huellaSong = get_huella(y, intervalo_frecuencia);
end