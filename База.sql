CREATE TABLE stations
(
    station_name text NOT NULL UNIQUE,      -- название станции
    resourse_type text,                     -- тип ресурса
    capasity integer,                       -- вместимость
    number_of_units smallint,               -- кол-во погрузщиков
    source_for text,                        -- для производства чего используется
    linked_train text,                      -- связанный поезд
    filing_spead integer,                   -- скорость заполнения
    type_of_put text DEFAULT 'разгрузка',   -- используется для погрузки или разгрузки (по умолчанию после строительства выставлены на разгрузку)
    
    CHECK (number_of_units >= filing_spead/1240)  -- у каждого погрузщика два входных и два выходных отверстия, максимальная скорость конвеера 720 ед. в минуту, учитывая то, что во время работы с вагоном поезда отверстия не функционируют итоговая проводимость уменьшается примерно на 100 ед. в минуту на отверстие, таким образом количество погрузщиков не должно быть меньше чем скорость заполнения/((720-100)*2), нет смысла нагружать и без того не самый производительный питон ненужными вычислениями и сразу запишем как /1240
    PRIMARY KEY (station_name)
    FOREIGN KEY (resourse_type)
        REFERENCES resourses (resourse_type)
    FOREIGN KEY (source_for)
        REFERENCES factory (produce)
    FOREIGN KEY (linked_train)
        REFERENCES trains (train_name)
)

CREATE TABLE resourses
(
    resourse_type text NOT NULL UNIQUE,     -- название ресурса
    gather_rate integer,                    -- скорость добычи
    used integer,                           -- используется
    max_gather_rate integer,                -- максимально возможная скорость добычи
    used_for text,                          -- используется в создании
    use_trains text,                        -- транспортирующие поезда
    use_stations text,                      -- станции для добычи и передачи

    CHECK (gather_rate < max_gather_rate)   -- да, добыча не может быть только меньше максимальной добычи т.к. скорость добычи богатых залежей выше скорости конвеера
    PRIMARY KEY (resourse_type)
    FOREIGN KEY (used_for)
    FOREIGN KEY (use_trains)
    FOREIGN KEY (use_stations)
)

CREATE TABLE factory
(
    produce text NOT NULL UNIQUE,           -- производимый ресурс
    produce_rate integer,                   -- скорость производства
    ways_to_produce text,                   -- способы производства
    min_produce integer,                    -- минимальная скорость производства
    max_produce integer,                    -- максимальная скорость производства
    used_resourses text,                    -- используемые в производстве материалы
    connected_stations text,                -- станции подключенные к заводу
    linked_trains text,                     -- поезда доставляющие ресурсы и вывозящие готовый продукт

    CHECK (min_produce <= max_produce)      -- можно бы было ещё добавить проверку текущей скорости производства, но она может быть и выше максимальной
    PRIMARY KEY (produce)
    FOREIGN KEY (used_resourses)
    FOREIGN KEY (connected_stations)
    FOREIGN KEY (linked_trains)
)

CREATE TABLE trains
(
    train_name text NOT NULL UNIQUE,        -- название поезда
    number_of_units smallint,               -- кол-во вагонов
    main_station text,                      -- последняя станция в цикле
    way text,                               -- маршрут
    conteined_resourse text,                -- тип перевозимых ресурсов
    time_for_circle float,                  -- время затрачиваемое на цикл (среднее)
    linked_factory text,                    -- связанное производство

    PRIMARY KEY (train_name)
    FOREIGN KEY (main_station)
        REFERENCES stations (station_name)
    FOREIGN KEY (conteined_resourse)
        REFERENCES resourses (resourse_type)
    FOREIGN KEY (linked_factory)
        REFERENCES factory (produce)
)







INSERT INTO stations (station_name, resourse_type, capasity, number_of_units, source_for, linked_train, filing_spead, type_of_put)
        VALUES ('1) Железо +480', 'Железо', 2400, 1, 'Железные слитки', 'Железо 1', 480, 'погрузка');
            ('2) Железо +1440', 'Железо', 4800, 2, 'Железные слитки', 'Железо 2', 1440, 'погрузка');
            ('1) Медь +2880', 'Медь', 9600, 4, 'Медные слитки', 'Медь 1', 2880, 'погрузка');
            ('1) Железо -480', 'Железо', 2400, 1, 'Железные слитки', 'Железо 1', 480, 'разгрузка');
            ('2) Железо -1440', 'Железо', 4800, 2, 'Железные слитки', 'Железо 2', 1440, 'разгрузка');
            ('1) Медь -2880', 'Медь', 9600, 4, 'Медные слитки', 'Медь 1', 2880, 'разгрузка');


INSERT INTO trains (train_name, number_of_units, main_station, way, conteined_resourse, time_for_circle, linked_factory)
        VALUES ('Железо 1', 1, '1) Железо -480', '1) Железо -480 - 1) Железо +480', 'Железо', 4,'Железные слитки');
            ('Железо 2', 2, '2) Железо -1440', '2) Железо +1440 - 2) Железо -1440', 'Железо', 7,'Железные слитки');
            ('Медь 1', 4, '1) Медь -2880', '1) Медь +2880 - 1) Медь -2880 ', 'Медь', 10,'Медные слитки');
