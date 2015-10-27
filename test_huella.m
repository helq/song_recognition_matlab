function test_huella()
    %[a, fs] = wavread('sounds/Violin_for_spectrogram.wav');
    %[a, fs] = wavread('sounds/Parus_major_15mars2011.wav');
    [a, fs] = wavread('sounds/Johnny Delusional - FFS.wav');
    
    if size(a,2) > 1
        a = ( a(:,1)+a(:,2) )/2;
    end

    h = huella();
    
    [y f t] = h.spectrogram(a, fs);
    song_h = h.get_huella(y);
    
    subplot(211);
    surf(t,f,y,'EdgeColor','none');
    %contour(t,f,y,5);
    axis xy; axis tight;
    colormap(jet);
    %colorbar;
    view(0,90);
    %view(-77,72);
    
    subplot(212);
    axis([0 t(end) -inf inf]);
    for i=1:size(song_h,1) % por cada nivel de frecuencias
        scatter(t, song_h(i,:), '.');
        if i ~= size(song_h,1)
            hold on;
        end
    end
end