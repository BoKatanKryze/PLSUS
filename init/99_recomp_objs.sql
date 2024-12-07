BEGIN
   DBMS_OUTPUT.PUT_LINE('Recompiling objects for schema: SYSTEM');

   -- Recompile all objects in the SYSTEM schema, excluding tables
   FOR obj IN (
      SELECT object_name, object_type
      FROM dba_objects
      WHERE owner = 'SYSTEM'
        AND object_type NOT IN ('TABLE', 'INDEX', 'PARTITION', 'LOB', 'SEQUENCE', 'TABLE PARTITION', 'SYNONIM', 'INDEX PARTITION') -- Exclude non-compilable objects
   ) LOOP
      BEGIN
         -- Dynamically compile each object
         EXECUTE IMMEDIATE 'ALTER ' || obj.object_type || ' "SYSTEM"."'
            || obj.object_name || '" COMPILE';
         DBMS_OUTPUT.PUT_LINE('Compiled: ' || obj.object_type || ' - SYSTEM.' || obj.object_name);
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error compiling: ' || obj.object_type || ' - SYSTEM.' || obj.object_name || ': ' || SQLERRM);
      END;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE('All objects in SYSTEM schema (excluding tables) have been recompiled.');
END;
/