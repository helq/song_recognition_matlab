function toRet = test_huella()
    test1;
end

function db = test4()
    c = cargarSonido;
    db = db_song();

    names = {
        'sounds/Parus_major_15mars2011.wav', ...
        'sounds/fkkireta.wav', ...
        'sounds/Violin_for_spectrogram.wav', ...
        'sounds/Johnny Delusional - FFS.wav', ...
        'sounds/12_Marcos Valle Batacuda.wav'
        };

    for i=1:length(names)
        [a, fs] = c.cargar( names{i} );

        tic
        fprintf('\n%s \n', names{i});
        db.addSong(a, fs, names{i});
        toc
    end

    % cargando una pista de audio
    [a, fs] = c.cargar( names{1} );
    a = c.agregarRuido( a, 0.05 );

    % determinando a canción corresponde la pista de audio
    [nombresCanciones, matches] = db.determineSong(a, fs);

    fprintf('\n\nCanciones encontradas, ordenadas por el número de similitudes encontradas con el audio dado:\n');
    for i=1:length(nombresCanciones)
        fprintf('%02d: %s\n', matches(i), nombresCanciones{i});
    end
end

function db = test3()
    db = db_song();
    
    name = 'sounds/Violin_for_spectrogram.wav';
    [a, fs] = wavread( name );
    db.addSong(a, fs, name);

    name = 'sounds/Parus_major_15mars2011.wav';
    [a, fs] = wavread( name );
    db.addSong(a, fs, name);
end

function test2()
    [a, fs] = wavread('sounds/Violin_for_spectrogram.wav');

    h = huella();
    [y, ~, t] = h.spectrogram(a, fs);
    huellaSong = h.get_huella(y);

    db = db_song();
    %hashHuella = db.hash(huellaSong);
    db.addSong(huellaSong, t, 1);
end

function test1()
    cancion = 'sounds/Violin_for_spectrogram.wav';
    %cancion = 'sounds/Parus_major_15mars2011.wav';
    %cancion = 'sounds/Johnny Delusional - FFS.wav';
    %cancion = 'sounds/12_Marcos Valle Batacuda.wav';
    %cancion = 'sounds/fkkireta.wav';
    
    c = cargarSonido;
    [a fs] = c.cargar(cancion);
    
    % agregando ruido
    a = c.agregarRuido(a, 0.05);

    h = huella();
    
    intervalo_frecuencia = 5;
    [y f t] = h.spectrogram(a, fs, intervalo_frecuencia);
    song_h = h.get_huella(y, intervalo_frecuencia);
    
    % ==== GRAFICANDO RESULTADOS ====
    subplot(211); % Espectrograma
    surf(t,f,y,'EdgeColor','none');
    %contour(t,f,y,5);
    axis xy; axis tight;
    colormap(jet);
    %colorbar;
    view(0,90);
    %view(-77,72);
    
    subplot(212); % Huella
    for i=1:size(song_h,1) % por cada nivel de frecuencias
        scatter(t, song_h(i,:), '.');
        if i ~= size(song_h,1)
            hold on;
        end
    end
    axis([0 t(end) -inf inf]);
    hold off;
end