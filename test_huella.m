% probando que la base de datos, la huella y otros componentes funcionen
function toRet = test_huella()
    toRet = test6;
end

function db = test6()
    db_name = 'database/database.mat';
    
    %creado la base de datos si no existe o cargarla si ya existe
    if ~exist(db_name, 'file')
        db = test6a();
        save(db_name, 'db');
    else
        load(db_name, 'db');
    end

    test6b(db); % detectando una canción
end

function db = test6a()
    %%
    c = cargarSonido; % libreria
    db = db_song();

    % Directorio donde se encuentran las canciones en formato mp3
    dir_sounds = rdir('/home/helq/Music/mp3/**/*.mp3');
    names = { dir_sounds.name };

    t_total = tic;
    for i=1:length(names)
        fprintf('leyendo archivo "%s" ... ', names{i});

        tic
        [a, fs] = c.cargar( names{i} );
        fprintf('agregando a la base de datos ... ');
        db.addSong(a, fs, names{i});
        fprintf('%.3f segundos\n', toc);
    end
    fprintf('\nTiempo total creando la base de datos: %.3f segundos\n', toc(t_total));
end

function test6b(db)
    %%
    % cargando una pista de audio
    c = cargarSonido;
    [a, fs] = c.cargar( 'sounds/un_archivo.mp3' );
    a = c.agregarRuido( a, 0.15 );
    %sound(a, fs);

    tic
    % determinando a canción corresponde la pista de audio
    [nombresCanciones, matches] = db.determineSong(a, fs);

    fprintf('\n\nCanciones encontradas, ordenadas por el número de similitudes encontradas con el audio dado:\n');
    for i=1:length(nombresCanciones)
        % descartar aquellas canciones en las que halla menos de 10 'matches'
        if matches(i) <= 10
            break
        end
        fprintf('%02d: %s\n', matches(i), nombresCanciones{i});
    end
    fprintf('tiempo total en búsqueda: %.3f segs\n', toc);
end

function db = test5()
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
    [a, fs] = c.cargar( 'sounds/Johnny_part.wav' );
    a = c.agregarRuido( a, 0.15 );
    %sound(a, fs);

    % determinando a canción corresponde la pista de audio
    ms = db.getMatches(a, fs);

    % similitudes
    simds = zeros(1, length(ms));
    for i=1:length(ms)
        timeMuestra = [ms(i).timing.timeMuestra];
        times       = {ms(i).timing.times};

        simds(i) = db.similitudesTiming(timeMuestra, times);
    end

    [simds, I] = sort( simds, 'descend' );

    for i=1:length(I)
        fprintf('%02d: %s\n', simds(i), db.dbNames{ms(I(i)).songID} );
    end
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
    [a, fs] = c.cargar( 'sounds/Johnny_part.wav' );
    a = c.agregarRuido( a, 0.35 );

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
    %%
    %cancion = 'sounds/Mago_part.wav';
    cancion = '/home/helq/Music/mp3/08.Gumi - 九龍レトロ.mp3';
    
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
