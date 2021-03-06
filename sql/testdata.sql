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
    ('w3', 'p1', 1, '41'),
    ('w3', 'p2', 0, '42'),
    ('w3', 'p2', 1, '43'),
    ('l4', 'plot', 0, '42'),
    ('l4', 'plot', 1, '1');
INSERT INTO lambdas
    (id, rettype, value)
    VALUES
    ('l4', 'wave', '{"plugin":"a","config":{"@b":["1","2","3"],"$a":"qwe"}}'),
    ('l5', 'field', '{"plugin":"a","config":{"@b":["1","2","3"],"$a":"qwe"}}');
