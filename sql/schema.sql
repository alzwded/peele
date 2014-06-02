PRAGMA foreign_keys = TRUE ;
CREATE TABLE IF NOT EXISTS main (
    id VARCHAR(40) PRIMARY KEY,
    stype VARCHAR(10) NOT NULL
    );
CREATE TABLE IF NOT EXISTS fields (
    id VARCHAR(40),
    value TEXT,
    FOREIGN KEY (id) REFERENCES main(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
    );
CREATE TABLE IF NOT EXISTS arrays (
    id VARCHAR(40) NOT NULL,
    idx INTEGER NOT NULL,
    value TEXT,
    FOREIGN KEY (id) REFERENCES main(id) ON DELETE CASCADE,
    PRIMARY KEY (id, idx)
    );
CREATE TABLE IF NOT EXISTS waves (
    id VARCHAR(40) NOT NULL,
    plotname VARCHAR(40) NOT NULL,
    idx INTEGER NOT NULL,
    value TEXT,
    FOREIGN KEY (id) REFERENCES main(id) ON DELETE CASCADE,
    PRIMARY KEY (id, plotname, idx)
    );
CREATE TABLE IF NOT EXISTS lambdas (
    id VARCHAR(40) NOT NULL,
    rettype VARCHAR(10) NOT NULL,
    value TEXT NOT NULL,
    FOREIGN KEY (id) REFERENCES main(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
    );
