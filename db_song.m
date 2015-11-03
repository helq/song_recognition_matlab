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
                    toAdd(n+1).time   = timing(i);
                    toAdd(n+1).songID = songID;
                    
                    obj.dbHashes( hH ) = toAdd;
                else
                    toAdd(1).time = timing(i);
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

