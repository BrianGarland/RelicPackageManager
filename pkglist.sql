CREATE OR REPLACE TABLE #RELIC/PKGLIST (
  PKG_ID INT NOT NULL WITH DEFAULT,    
  PKG_NAME CHAR (20) NOT NULL WITH DEFAULT, 
  PKG_DESC CHAR (25) NOT NULL WITH DEFAULT, 
  PKG_LINK CHAR (128) NOT NULL WITH DEFAULT,    
  PKG_FLDNAME CHAR (64) NOT NULL WITH DEFAULT
);

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