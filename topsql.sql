PROMPT +----------------------------+
PROMPT | SQL DIAGNOSIS              |
PROMPT |  TOP SQL                   |
PROMPT +----------------------------+
SET SERVEROUTPUT ON
SET LINES 200
DECLARE
  TYPE T_AVG_EXEC                IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  L_MAX_INST                     BINARY_INTEGER;

  L_AVG_EXEC                     T_AVG_EXEC;
BEGIN
  SELECT MAX(INST_ID) INTO L_MAX_INST
    FROM GV$INSTANCE;

  FOR MAIN IN 1 .. L_MAX_INST LOOP
    SELECT SUM(EXECUTIONS)/COUNT(*) INTO L_AVG_EXEC(MAIN)
      FROM V$SQLAREA
     WHERE PARSING_SCHEMA_NAME NOT IN (
            'XS$NULL','XDB','WMSYS','TSMSYS','SYSTEM','SYSMAN','SYSKM',
            'SYSDG','SYSBACKUP','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
            'SI_INFORMTN_SCHEMA','PERFSTAT','OWBSYS_AUDIT','OWBSYS','OUTLN',
            'ORDSYS','ORDPLUGINS','ORDDATA','ORACLE_OCM','OLAPSYS','OJVMSYS',
            'MGMT_VIEW','MDSYS','MDDATA','GSMUSER','GSMCATUSER','GSMADMIN_INTERNAL',
            'FLOWS_FILES','EXFSYS','DMSYS','DIP','DBSNMP','CTXSYS','AUDSYS',
            'APPQOSSYS','APEX_PUBLIC_USER','APEX_030200','ANONYMOUS' );

    DBMS_OUTPUT.PUT_LINE('INSTANCE #'||MAIN);
    DBMS_OUTPUT.PUT_LINE(' Top 3 user SQL Ordered by average buffergets');
    DBMS_OUTPUT.PUT_LINE(' --------------------------------------');
    DBMS_OUTPUT.PUT('  '||RPAD('SQL_ID',15)||' ');
    DBMS_OUTPUT.PUT(RPAD('PLAN_HV',13)||' ');
    DBMS_OUTPUT.PUT(LPAD('TOT BUFFER GETS',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG BUFFER GETS',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('TOTAL EXEC',13)||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('PARSE SNAME',11));

    DBMS_OUTPUT.PUT('  '||RPAD('-',15,'-')||' ');
    DBMS_OUTPUT.PUT(RPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',11,'-'));

    -- TOP 3 Ordered by Average Buffer gets.
    -- 25% more executed than total average sql executed.
    FOR C_TOPQ IN ( SELECT *
                      FROM ( SELECT SS.SQL_ID,
                                    SS.PLAN_HASH_VALUE,
                                    SS.BUFFER_GETS,
                                    SS.BUFFER_GETS/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS) AS AVG_BUFF,
                                    SS.EXECUTIONS,
                                    SA.PARSING_SCHEMA_NAME
                               FROM GV$SQLSTATS SS, V$SQLAREA SA
                              WHERE SS.SQL_ID = SA.SQL_ID
                                AND SS.PLAN_HASH_VALUE = SA.PLAN_HASH_VALUE
                                AND SS.INST_ID = MAIN
                                AND SA.PARSING_SCHEMA_NAME NOT IN (
                                 'XS$NULL','XDB','WMSYS','TSMSYS','SYSTEM','SYSMAN','SYSKM',
                                 'SYSDG','SYSBACKUP','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
                                 'SI_INFORMTN_SCHEMA','PERFSTAT','OWBSYS_AUDIT','OWBSYS','OUTLN',
                                 'ORDSYS','ORDPLUGINS','ORDDATA','ORACLE_OCM','OLAPSYS','OJVMSYS',
                                 'MGMT_VIEW','MDSYS','MDDATA','GSMUSER','GSMCATUSER','GSMADMIN_INTERNAL',
                                 'FLOWS_FILES','EXFSYS','DMSYS','DIP','DBSNMP','CTXSYS','AUDSYS',
                                 'APPQOSSYS','APEX_PUBLIC_USER','APEX_030200','ANONYMOUS')
                                AND SS.EXECUTIONS > L_AVG_EXEC(MAIN)*1.4
                             ORDER BY 3 DESC, 5 DESC
                           )
                     WHERE ROWNUM < 4
                  ) LOOP
      DBMS_OUTPUT.PUT('  '||RPAD(C_TOPQ.SQL_ID,15)||' ');
      DBMS_OUTPUT.PUT(RPAD(C_TOPQ.PLAN_HASH_VALUE,13)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.BUFFER_GETS,16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_BUFF,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.EXECUTIONS,13)||' ');
      DBMS_OUTPUT.PUT_LINE(LPAD(C_TOPQ.PARSING_SCHEMA_NAME,11));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' Top 3 user SQL Ordered by average CPU time');
    DBMS_OUTPUT.PUT_LINE(' --------------------------------------');
    DBMS_OUTPUT.PUT('  '||RPAD('SQL_ID',15)||' ');
    DBMS_OUTPUT.PUT(RPAD('PLAN_HV',13)||' ');
    DBMS_OUTPUT.PUT(LPAD('CPU_TIME',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG CPU_TIME',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('TOTAL EXEC',13)||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('PARSE SNAME',11));

    DBMS_OUTPUT.PUT('  '||RPAD('-',15,'-')||' ');
    DBMS_OUTPUT.PUT(RPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',11,'-'));

    -- TOP 3 Ordered by Average CPU_TIME.
    -- 25% more executed than total average sql executed.
    FOR C_TOPQ IN ( SELECT *
                      FROM ( SELECT SS.SQL_ID,
                                    SS.PLAN_HASH_VALUE,
                                    SS.CPU_TIME,
                                    SS.CPU_TIME/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS) AS AVG_CPU,
                                    SS.EXECUTIONS,
                                    SA.PARSING_SCHEMA_NAME
                               FROM GV$SQLSTATS SS, V$SQLAREA SA
                              WHERE SS.SQL_ID = SA.SQL_ID
                                AND SS.PLAN_HASH_VALUE = SA.PLAN_HASH_VALUE
                                AND SS.INST_ID = MAIN
                                AND SA.PARSING_SCHEMA_NAME NOT IN (
                                 'XS$NULL','XDB','WMSYS','TSMSYS','SYSTEM','SYSMAN','SYSKM',
                                 'SYSDG','SYSBACKUP','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
                                 'SI_INFORMTN_SCHEMA','PERFSTAT','OWBSYS_AUDIT','OWBSYS','OUTLN',
                                 'ORDSYS','ORDPLUGINS','ORDDATA','ORACLE_OCM','OLAPSYS','OJVMSYS',
                                 'MGMT_VIEW','MDSYS','MDDATA','GSMUSER','GSMCATUSER','GSMADMIN_INTERNAL',
                                 'FLOWS_FILES','EXFSYS','DMSYS','DIP','DBSNMP','CTXSYS','AUDSYS',
                                 'APPQOSSYS','APEX_PUBLIC_USER','APEX_030200','ANONYMOUS')
                                AND SS.EXECUTIONS > L_AVG_EXEC(MAIN)*1.4
                             ORDER BY 3 DESC, 5 DESC
                           )
                     WHERE ROWNUM < 4
                  ) LOOP
      DBMS_OUTPUT.PUT('  '||RPAD(C_TOPQ.SQL_ID,15)||' ');
      DBMS_OUTPUT.PUT(RPAD(C_TOPQ.PLAN_HASH_VALUE,13)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.CPU_TIME,16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_CPU,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.EXECUTIONS,13)||' ');
      DBMS_OUTPUT.PUT_LINE(LPAD(C_TOPQ.PARSING_SCHEMA_NAME,11));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' Top 3 user SQL Ordered by average elapsed time');
    DBMS_OUTPUT.PUT_LINE(' --------------------------------------');
    DBMS_OUTPUT.PUT('  '||RPAD('SQL_ID',15)||' ');
    DBMS_OUTPUT.PUT(RPAD('PLAN_HV',13)||' ');
    DBMS_OUTPUT.PUT(LPAD('ELAPSED_TIME',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG ELAP_TIME',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('TOTAL EXEC',13)||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('PARSE SNAME',11));

    DBMS_OUTPUT.PUT('  '||RPAD('-',15,'-')||' ');
    DBMS_OUTPUT.PUT(RPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',11,'-'));

    -- TOP 3 Ordered by Average ELAPSED_TIME
    -- 25% more executed than total average sql executed.
    FOR C_TOPQ IN ( SELECT *
                      FROM ( SELECT SS.SQL_ID,
                                    SS.PLAN_HASH_VALUE,
                                    SS.ELAPSED_TIME,
                                    SS.ELAPSED_TIME/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS) AS AVG_TIME,
                                    SS.EXECUTIONS,
                                    SA.PARSING_SCHEMA_NAME
                               FROM GV$SQLSTATS SS, V$SQLAREA SA
                              WHERE SS.SQL_ID = SA.SQL_ID
                                AND SS.PLAN_HASH_VALUE = SA.PLAN_HASH_VALUE
                                AND SS.INST_ID = MAIN
                                AND SA.PARSING_SCHEMA_NAME NOT IN (
                                 'XS$NULL','XDB','WMSYS','TSMSYS','SYSTEM','SYSMAN','SYSKM',
                                 'SYSDG','SYSBACKUP','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
                                 'SI_INFORMTN_SCHEMA','PERFSTAT','OWBSYS_AUDIT','OWBSYS','OUTLN',
                                 'ORDSYS','ORDPLUGINS','ORDDATA','ORACLE_OCM','OLAPSYS','OJVMSYS',
                                 'MGMT_VIEW','MDSYS','MDDATA','GSMUSER','GSMCATUSER','GSMADMIN_INTERNAL',
                                 'FLOWS_FILES','EXFSYS','DMSYS','DIP','DBSNMP','CTXSYS','AUDSYS',
                                 'APPQOSSYS','APEX_PUBLIC_USER','APEX_030200','ANONYMOUS')
                                AND SS.EXECUTIONS > L_AVG_EXEC(MAIN)*1.4
                             ORDER BY 3 DESC, 5 DESC
                           )
                     WHERE ROWNUM < 4
                  ) LOOP
      DBMS_OUTPUT.PUT('  '||RPAD(C_TOPQ.SQL_ID,15)||' ');
      DBMS_OUTPUT.PUT(RPAD(C_TOPQ.PLAN_HASH_VALUE,13)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.ELAPSED_TIME,16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_TIME,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.EXECUTIONS,13)||' ');
      DBMS_OUTPUT.PUT_LINE(LPAD(C_TOPQ.PARSING_SCHEMA_NAME,11));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' Top 3 user SQL Ordered by executions');
    DBMS_OUTPUT.PUT_LINE(' --------------------------------------');
    DBMS_OUTPUT.PUT('  '||RPAD('SQL_ID',15)||' ');
    DBMS_OUTPUT.PUT(RPAD('PLAN_HV',13)||' ');
    DBMS_OUTPUT.PUT(LPAD('EXECUTIONS',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG BUFF_GETS',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG CPU_TIME',16)||' ');
    DBMS_OUTPUT.PUT(LPAD('AVG ELAP_TIME',16)||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('PARSE SNAME',11));

    DBMS_OUTPUT.PUT('  '||RPAD('-',15,'-')||' ');
    DBMS_OUTPUT.PUT(RPAD('-',13,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT(LPAD('-',16,'-')||' ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',11,'-'));

    -- TOP 3 Ordered by executions
    FOR C_TOPQ IN ( SELECT *
                      FROM ( SELECT SS.SQL_ID,
                                    SS.PLAN_HASH_VALUE,
                                    SS.EXECUTIONS,
                                    SS.BUFFER_GETS/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS) AS AVG_BUFF,
                                    SS.CPU_TIME/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS)    AS AVG_CPU,
                                    SS.ELAPSED_TIME/DECODE(SS.EXECUTIONS,NULL,1,0,1,SS.EXECUTIONS) AS AVG_ELAP,
                                    SA.PARSING_SCHEMA_NAME
                               FROM GV$SQLSTATS SS, V$SQLAREA SA
                              WHERE SS.SQL_ID = SA.SQL_ID
                                AND SS.PLAN_HASH_VALUE = SA.PLAN_HASH_VALUE
                                AND SS.INST_ID = MAIN
                                AND SA.PARSING_SCHEMA_NAME NOT IN (
                                 'XS$NULL','XDB','WMSYS','TSMSYS','SYSTEM','SYSMAN','SYSKM',
                                 'SYSDG','SYSBACKUP','SPATIAL_WFS_ADMIN_USR','SPATIAL_CSW_ADMIN_USR',
                                 'SI_INFORMTN_SCHEMA','PERFSTAT','OWBSYS_AUDIT','OWBSYS','OUTLN',
                                 'ORDSYS','ORDPLUGINS','ORDDATA','ORACLE_OCM','OLAPSYS','OJVMSYS',
                                 'MGMT_VIEW','MDSYS','MDDATA','GSMUSER','GSMCATUSER','GSMADMIN_INTERNAL',
                                 'FLOWS_FILES','EXFSYS','DMSYS','DIP','DBSNMP','CTXSYS','AUDSYS',
                                 'APPQOSSYS','APEX_PUBLIC_USER','APEX_030200','ANONYMOUS')
                             ORDER BY 3 DESC
                           )
                     WHERE ROWNUM < 4
                  ) LOOP
      DBMS_OUTPUT.PUT('  '||RPAD(C_TOPQ.SQL_ID,15)||' ');
      DBMS_OUTPUT.PUT(RPAD(C_TOPQ.PLAN_HASH_VALUE,13)||' ');
      DBMS_OUTPUT.PUT(LPAD(C_TOPQ.EXECUTIONS,16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_BUFF,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_CPU,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(C_TOPQ.AVG_ELAP,'FM9999999999999999.00'),16)||' ');
      DBMS_OUTPUT.PUT_LINE(LPAD(C_TOPQ.PARSING_SCHEMA_NAME,11));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE(' ');
  END LOOP;
END;
/
