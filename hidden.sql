col KSPPSTVL for a10
col KSPPINM for a35
SELECT KSPPINM, KSPPSTVL
FROM X$KSPPI X, X$KSPPCV Y
WHERE X.INDX = Y.INDX
AND X.KSPPINM LIKE '%&param%'
AND SUBSTR(X.KSPPINM, 1, 1) = '_'
/