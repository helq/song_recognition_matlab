classdef db_song < handle
    %DB_SONG Crear una base de datos para almacenar "hashes" de canciones
    
    properties
        dbHashes; % database of song hashes
        dbNames;  % base de datos para los nombres de las canciones
    end
    
    methods
        % constructor
        function obj = db_song()
            obj.dbHashes = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.dbNames = {};
        end
        function addSongUsandoHuella(obj, huella, timing, songID)
            hashHuella = obj.hash(huella);

            for i=1:length(huella)
                % si este elemento particular de la huella está en la base
                % de datos significa que otra canción ya está en este
                hH = hashHuella{i};
                if obj.dbHashes.isKey( hH )
                    toAdd = obj.dbHashes( hH );
                    n = size(toAdd,2);
                    toAdd(n+1).times  = timing(i);
                    toAdd(n+1).songID = songID;
                    
                    obj.dbHashes( hH ) = toAdd;
                else
                    toAdd(1).times = timing(i);
                    toAdd(1).songID = songID;
                    
                    obj.dbHashes( hH ) = toAdd;
                end
            end
        end
        
        function id = addNameSong(obj, nameSong)
            % si la canción ya se encuentra en la base de datos
            if sum( strcmp(nameSong, obj.dbNames) )
                id = 0;
            else
                % en caso de que no esté en la base de datos, agregarla
                id = length(obj.dbNames)+1;
                obj.dbNames{id} = nameSong;
            end
        end
        
        function done = addSong(obj, audio, fs, nameSong)
            h = huella();
            intervalo_frecuencia=5;
            [y, ~, t] = h.spectrogram(audio, fs, intervalo_frecuencia);
            % obteniendo huella de la canción
            huellaSong = h.get_huella(y, intervalo_frecuencia);

            % obteniendo un ID para el nombre de la canción
            nameID = obj.addNameSong(nameSong);
            
            % si la canción no está en la lista se agrega su hash
            if nameID
                % agregando el hash de la canción a la base de datos
                obj.addSongUsandoHuella(huellaSong, t, nameID);
                done = true;

            else % no se agrega la canción a la base de datos
                done = false;
            end
        end
    
        % dado un hash se buscan todas las coincidencias
        function toRetMatches = getMatchesUsandoHash(obj, hashHuella, timing)
            toRetMatches = struct('songID', [], 'timing', []);
            
            % analizando por cada entrada de la hash del sonido
            for i=1:length(hashHuella)
                hH = hashHuella{i};
                
                % si el elemento de la huella se encuentra en la db, return
                if obj.dbHashes.isKey( hH )
                    m = obj.dbHashes(hH);
                    
                    for songID=unique( [m.songID] )
                        % buscando posición en la lista songID
                        n = find(songID == [toRetMatches.songID]);
                        if isempty(n)
                            n = length([toRetMatches.songID])+1;
                            toRetMatches(n).songID = songID;
                            toRetMatches(n).timing = struct('timeMuestra', {}, 'times', {});
                        end
                        toRetMatches(n).timing(end+1).timeMuestra = timing(i);
                        toRetMatches(n).timing(end).times = [ m( songID == [m.songID] ).times ];
                    end
                end
            end
        end
        
        function matches = getMatches(obj, audio, fs)
            h = huella();
            intervalo_frecuencia=5;
            [y, ~, t] = h.spectrogram(audio, fs, intervalo_frecuencia);
            % obteniendo huella del sonido obtenido
            huellaSong = h.get_huella(y, intervalo_frecuencia);
            % obteniendo hash de la huella
            hashHuella = obj.hash(huellaSong);
            
            matches = obj.getMatchesUsandoHash(hashHuella, t);
        end
        
        function [probableSongs, numMatches] = determineSongUsingMatches(obj, matches, tipoDeBusqueda)

            if     strcmp(tipoDeBusqueda, 'PorNumeroDeMatches')
                % extrayendo número de 'matches' para cada canción
                [~, numMatches] = cellfun(@size, {matches.timing});
                
            elseif strcmp(tipoDeBusqueda, 'PorCoincidenciasEnTiming')
                
                % obteniendo número de 'matches' que coinciden en los Timing
                numMatches = zeros(1, length(matches));
                for i=1:length(matches)
                    timeMuestra = [matches(i).timing.timeMuestra];
                    times       = {matches(i).timing.times};

                    numMatches(i) = obj.similitudesTiming(timeMuestra, times);
                end

            end
            
            % ordenando canciones por el número de matches
            [numMatches, I] = sort(numMatches, 'descend');
            probableSongsIDs = [matches.songID];
            probableSongsIDs = probableSongsIDs(I);

            % obteniendo los nombres de los IDs de las canciones
            probableSongs = cellfun(@(id) obj.dbNames{id}, num2cell(probableSongsIDs), 'Uniform', false);
        end
        function [probableSongs, numMatches] = determineSong(obj, a, fs)
            % obteniendo los 'matches' de la base de datos
            ms = obj.getMatches(a, fs);
            [probableSongs, numMatches] = obj.determineSongUsingMatches(ms, 'PorCoincidenciasEnTiming');
        end
    end
    
    methods(Static)
        % tomar un valor de hash [32; 77; 81; 152; 199]
        %                a ----> '032077081152199'
        function hashHuella = hash(huella)
            C = num2cell(huella, 1);
            hashHuella = cellfun(@(x) num2str(x','%03d'), C, 'Uniform', false);
        end
        
        function similitudes = similitudesTimingOffset(timeMuestra, times, offset)
            similitudes = 0;
            timeMuestra = timeMuestra-timeMuestra(1);
            for i=1:length(timeMuestra)
                t = timeMuestra(i);
                coincidence = find( abs( times{i}-offset - t ) < 0.05 );
                if coincidence
                   similitudes = similitudes + 1; 
                end
            end
        end
        
        function similitudes = similitudesTiming(timeMuestra, times)
            t = times{1};
            similitudes = max( arrayfun(@(o) db_song.similitudesTimingOffset(timeMuestra, times, o), t) );
        end
    end
end

