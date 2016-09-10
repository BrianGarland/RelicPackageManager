CREATE OR REPLACE TABLE #RELIC/PKGLIST (
  PKG_ID INT NOT NULL WITH DEFAULT,    
  PKG_NAME CHAR (20) NOT NULL WITH DEFAULT, 
  PKG_DESC CHAR (25) NOT NULL WITH DEFAULT, 
  PKG_LINK CHAR (128) NOT NULL WITH DEFAULT,    
  PKG_FLDNAME CHAR (64) NOT NULL WITH DEFAULT
);

DELETE FROM #RELIC/PKGLIST;

INSERT INTO #RELIC/PKGLIST VALUES(
  1, 
  'RelicPackageManager',
  'Package manager for IBM i', 
  'https://github.com/OSSILE/RelicPackageManager/archive/master.zip',                 
  'RelicPackageManager-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  2, 
  'FFEDIT',
  'Source member editor', 
  'https://github.com/RelicPackages/FFEDIT/archive/master.zip',                 
  'FFEDIT-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  3, 
  'RPG Dynamic Arrays',
  'Dynamic arrays in RPG', 
  'https://github.com/RelicPackages/RPGDYNARR/archive/master.zip',                 
  'RPGDYNARR-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  4, 
  'RPGMail',
  'by Aaron Bartell', 
  'https://github.com/RelicPackages/RPGMAIL/archive/master.zip',                 
  'RPGMAIL-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  5, 
  'SEUEXIT',
  'SEU Exit program', 
  'https://github.com/starbuck5250/SEUEXIT/archive/master.zip',                 
  'SEUEXIT-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  6, 
  'DB2GET',
  'Download files with DB2', 
  'https://github.com/WorksOfBarry/DB2GET/archive/master.zip',                 
  'DB2GET-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  7, 
  'FTPClient',
  'IBM i FTP Client', 
  'https://github.com/ChrisHird/FTPCLNT/archive/V1.0.0.2.zip',
  'FTPCLNT-1.0.0.2'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  8, 
  'ZLIB',
  'ZIP + UNZIP Commands', 
  'https://github.com/ChrisHird/ZLIB/archive/master.zip',
  'ZLIB-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  9, 
  'CRTFRMSTMF',
  'Create from Stream File', 
  'https://bitbucket.org/BrianGarland/crtfrmstmf/get/5b2d4cf7eafd.zip',
  'BrianGarland-crtfrmstmf-5b2d4cf7eafd'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  10, 
  'TOP',
  'Language and VM', 
  'https://github.com/OSSILE/TOP/archive/master.zip',
  'TOP-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  11, 
  'FTPAPI',
  'scottklement.com', 
  'https://github.com/RelicPackages/FTPAPI/archive/master.zip',
  'FTPAPI-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  12, 
  'HTTPAPI',
  'scottklement.com', 
  'https://github.com/RelicPackages/HTTPAPI/archive/master.zip',
  'HTTPAPI-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  13, 
  'CRTMIPGM',
  'Create MI Program', 
  'https://github.com/WorksOfBarry/CRTMIPGM/archive/master.zip',
  'CRTMIPGM-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  14, 
  'LSTFFD',
  'bvstools.com', 
  'https://bitbucket.org/WorksOfBarry/lstffd/get/7ca08d0f5792.zip',
  'WorksOfBarry-lstffd-7ca08d0f5792'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  15, 
  'iOpen Tools',
  'sqliquery.com', 
  'https://github.com/WorksOfBarry/iopen/archive/master.zip',
  'iopen-master'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  16, 
  'SCNMSGF',
  'Scan Message File', 
  'https://bitbucket.org/WorksOfBarry/scnmsgf/get/3af09424648f.zip',
  'WorksOfBarry-scnmsgf-3af09424648f'
);

INSERT INTO #RELIC/PKGLIST VALUES(
  17, 
  'base64',
  'scottklement.com', 
  'https://github.com/RelicPackages/base64/archive/master.zip',
  'base64-master'
);
