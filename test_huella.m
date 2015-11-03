function toRet = test_huella()
    toRet = test4;
end

function db = test4()
    db = db_song();

    names = {
        'sounds/Violin_for_spectrogram.wav', ...
        'sounds/Parus_major_15mars2011.wav'
        };

    for i=1:length(names)
        [a, fs] = wavread( names{i} );
        % stereo to mono
        if size(a,2) > 1
            a = ( a(:,1)+a(:,2) )/2;
        end
        
        db.addSong(a, fs, names{i});
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
    [a, fs] = wavread('sounds/Violin_for_spectrogram.wav');
    %[a, fs] = wavread('sounds/Parus_major_15mars2011.wav');
    %[a, fs] = wavread('sounds/Johnny Delusional - FFS.wav');
    %[a, fs] = wavread('sounds/12_Marcos Valle Batacuda.wav');
    %[a, fs] = wavread('sounds/fkkireta.wav');
    
    % stereo to mono
    if size(a,2) > 1
        a = ( a(:,1)+a(:,2) )/2;
    end

    h = huella();
    
    [y f t] = h.spectrogram(a, fs);
    song_h = h.get_huella(y);
    
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
end