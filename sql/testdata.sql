PRAGMA foreign_keys = TRUE ;
INSERT INTO main
    (id, stype)
    VALUES
    ('f1', 'field'),
    ('a2', 'array'),
    ('w3', 'wave'),
    ('l4', 'lambda'),
    ('l5', 'lambda');
INSERT INTO fields
    (id, value)
    VALUES
    ('f1', '42'),
    ('l5', '23');
INSERT INTO arrays
    (id, idx, value)
    VALUES
    ('a2', 0, '1'),
    ('a2', 1, '2'),
    ('a2', 2, '3');
INSERT INTO waves
    (id, plotname, idx, value)
    VALUES
    ('w3', 'p1', 0, '42'),
    ('w3', 'p2', 0, '42'),
    ('l4', 'plot', 0, '42');
INSERT INTO lambdas
    (id, rettype)
    VALUES
    ('l4', 'wave', 'f:{"@b":["1","2","3"],"$a":"qwe"}'),
    ('l5', 'field', 'f:{"@b":["1","2","3"],"$a":"qwe"}');
