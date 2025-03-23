-- Package Specification
CREATE OR REPLACE PACKAGE PLSUS_pkg IS
  -- Declare functions
  function adler32( p_src in blob ) RETURN VARCHAR2;
  FUNCTION generate_html_table(query_str IN VARCHAR2) RETURN NVARCHAR2;
END PLSUS_pkg;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY PLSUS_pkg IS
function adler32( p_src in blob )
return varchar2
is
  s1 pls_integer := 1;
  s2 pls_integer := 0;
begin
  for i in 1 .. dbms_lob.getlength( p_src )
  loop
    s1 := mod( s1 + to_number( rawtohex( dbms_lob.substr( p_src, 1, i ) ), 'XX' ), 65521 );
    s2 := mod( s2 + s1, 65521);
  end loop;
  return to_char( s2, 'fm0XXX' ) || to_char( s1, 'fm0XXX' );
end adler32;


FUNCTION generate_html_table(query_str IN VARCHAR2) RETURN NVARCHAR2 IS
type ref_cursor is ref cursor;
    rc ref_cursor;
    html_str NVARCHAR2(32767) := '<table border="1"><tr>';
    column_value VARCHAR2(4000);
    column_name VARCHAR2(100);
    column_count INTEGER;
    description DBMS_SQL.DESC_TAB;
    cursor_id INTEGER;
    
    execution_result INTEGER;
BEGIN

    -- Open dynamic cursor
    cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(cursor_id, query_str, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(cursor_id, column_count, description);

    -- Define columns dynamically
    FOR i IN 1 .. column_count LOOP
        DBMS_SQL.DEFINE_COLUMN(cursor_id, i, column_value, 4000);
        html_str := html_str || '<th>' || description(i).col_name || '</th>';
    END LOOP;
    html_str := html_str || '</tr>';

    -- Execute the query
    execution_result := DBMS_SQL.EXECUTE(cursor_id);

    -- Fetch each row
    WHILE DBMS_SQL.FETCH_ROWS(cursor_id) > 0 LOOP
        html_str := html_str || '<tr>';
        FOR i IN 1 .. column_count LOOP
            DBMS_SQL.COLUMN_VALUE(cursor_id, i, column_value);
            html_str := html_str || '<td>' || TO_CHAR(column_value) || '</td>';
        END LOOP;
        html_str := html_str || '</tr>';
    END LOOP;

    -- Close cursor and return HTML string
    html_str := html_str || '</table>';
    DBMS_SQL.CLOSE_CURSOR(cursor_id);

     RETURN html_str;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_SQL.CLOSE_CURSOR(cursor_id);
        html_str := 'Error in running function:';
        html_str := html_str || CHR(10);
        html_str := html_str || SQLERRM;
        RETURN html_str;
    --RAISE;
END;


END PLSUS_pkg;
/
show errors;