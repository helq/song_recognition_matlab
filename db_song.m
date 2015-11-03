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
            [y, ~, t] = h.spectrogram(audio, fs);
            % obteniendo huella de la canción
            huellaSong = h.get_huella(y);

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
        function matches = getMatchesUsandoHash(obj, hashHuella, timing)
            matches = struct('songID', [], 'timing', []);
            for i=1:length(hashHuella)
                hH = hashHuella{i};
                if obj.dbHashes.isKey( hH )
                    m = obj.dbHashes(hH);
                    
                    for songID=unique( [m.songID] )
                        % buscando posición en la lista songID
                        n = find(songID == matches.songID);
                        if isempty(n)
                            n = length(matches.songID)+1;
                            matches(n).songID = songID;
                            matches(n).timing = struct('timeMuestra', {}, 'times', {});
                        end
                        matches(n).timing(end+1).timeMuestra = timing(i);
                        matches(n).timing(end).times = [ m( songID == [m.songID] ).times ];
                    end
                end
            end
        end
        
        function matches = getMatches(obj, audio, fs)
            h = huella();
            [y, ~, t] = h.spectrogram(audio, fs);
            % obteniendo huella del sonido obtenido
            huellaSong = h.get_huella(y);
            % obteniendo hash de la huella
            hashHuella = obj.hash(huellaSong);
            
            matches = obj.getMatchesUsandoHash(hashHuella, t);
        end
    end
    
    methods(Static)
        % tomar un valor de hash [32; 77; 81; 152; 199]
        %                a ----> '032077081152199'
        function hashHuella = hash(huella)
            C = num2cell(huella, 1);
            hashHuella = cellfun(@(x) num2str(x','%03d'), C, 'Uniform', false);
        end
    end
    
end

