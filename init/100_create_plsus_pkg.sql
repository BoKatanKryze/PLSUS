-- Package Specification
CREATE OR REPLACE PACKAGE PLSUS_pkg IS
  -- Declare functions
  function adler32( p_src in blob ) RETURN VARCHAR2;
  FUNCTION generate_html_table(query_str IN VARCHAR2) RETURN NVARCHAR2;
  procedure test_csv_import;
PROCEDURE process_csv_file (p_directory IN VARCHAR2, p_filename IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ';');



-- Create a type for handling rows as arrays of strings
TYPE t_string_array IS TABLE OF VARCHAR2(4000);

PROCEDURE process_csv_file_generic (p_directory  VARCHAR2, p_filename   VARCHAR2, p_separator  VARCHAR2 DEFAULT ';');
PROCEDURE process_row_generic(p_row t_string_array);

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
END generate_html_table;


procedure test_csv_import IS
  v_destination_loc clob;
  v_source_loc bfile;
  v_lobsize number := dbms_lob.lobmaxsize;
  v_destination_offset number := 1;
  v_source_offset number := 1;
  v_language_context number := dbms_lob.default_lang_ctx;
  v_warning number;

  v_source_charset_id number := 873;

begin
  null;

end test_csv_import; 

PROCEDURE process_csv_file (
    p_directory  VARCHAR2,
    p_filename   VARCHAR2,
    p_separator  VARCHAR2 DEFAULT ';' -- Default separator is a comma
) AS
    l_file    UTL_FILE.FILE_TYPE;
    l_line    VARCHAR2(32767);
    l_idx     INTEGER;
    l_value   VARCHAR2(32767);
    l_remainder VARCHAR2(32767);
BEGIN
    -- Open the file for reading
    l_file := UTL_FILE.FOPEN(p_directory, p_filename, 'r', 32767);

    -- Read the file line by line and process
    LOOP
        BEGIN
            UTL_FILE.GET_LINE(l_file, l_line);
            l_line := l_remainder || l_line;  -- Append remainder from the previous line if any
            l_remainder := '';

            -- Process each field in the line
            LOOP
                -- Extract field up to the separator or end of line
                l_idx := INSTR(l_line, p_separator);
                IF l_idx = 0 THEN
                    l_value := l_line;
                    l_line := '';
                ELSE
                    l_value := SUBSTR(l_line, 1, l_idx - 1);
                    l_line := SUBSTR(l_line, l_idx + LENGTH(p_separator));
                END IF;
                DBMS_OUTPUT.PUT_LINE('Field: ' || l_value);

                EXIT WHEN l_idx = 0; -- Exit when no more separators are found
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;  -- Exit the loop when no more lines are available
            WHEN OTHERS THEN
                -- Capture partial lines if buffer overflows
                l_remainder := SUBSTR(l_line, 1, 32766);
                DBMS_OUTPUT.PUT_LINE('Buffer overflow, capturing partial data.');
        END;
    END LOOP;

    -- Close the file
    UTL_FILE.FCLOSE(l_file);
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        RAISE;
END process_csv_file;




-- Example callback procedure
-- This should be customized based on specific processing needs
PROCEDURE process_row_generic(p_row t_string_array) is
BEGIN
        FOR i IN 1 .. p_row.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Field ' || TO_CHAR(i) || ': ' || p_row(i));
    END LOOP;
    -- Add your custom logic here, e.g., logging or further data manipulation
    DBMS_OUTPUT.PUT_LINE('Row processed.');
    -- Add your custom logic here, e.g., insert into a table, log, etc.
END process_row_generic;

-- CSV processing procedure
PROCEDURE process_csv_file_generic (
    p_directory  VARCHAR2,
    p_filename   VARCHAR2,
    p_separator  VARCHAR2 DEFAULT ';'
) AS
    l_file  UTL_FILE.FILE_TYPE;
    l_clob  CLOB;
    l_buffer VARCHAR2(32767);
    l_line   VARCHAR2(32767);
    l_fields t_string_array;
    l_pos    INTEGER := 1;
    l_next_pos INTEGER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting procedure...');
    DBMS_LOB.createtemporary(l_clob, TRUE);
    l_file := UTL_FILE.FOPEN(p_directory, p_filename, 'r', 32767);

    -- Read the entire file into the CLOB
    BEGIN
        LOOP
            UTL_FILE.GET_LINE(l_file, l_buffer);
            DBMS_LOB.WRITEAPPEND(l_clob, LENGTH(l_buffer), l_buffer || CHR(10));
            DBMS_OUTPUT.PUT_LINE('Reading line...');
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            UTL_FILE.FCLOSE(l_file);
            DBMS_OUTPUT.PUT_LINE('End of file reached...');
    END;

    DBMS_OUTPUT.PUT_LINE('Processing CLOB...');

    -- Ensure the CLOB is processed even if no newline at the end
    DBMS_LOB.APPEND(l_clob, CHR(10));  -- Append a newline to handle the last line properly

    -- Process the CLOB line by line
    LOOP
        l_next_pos := INSTR(l_clob, CHR(10), l_pos);
        EXIT WHEN l_next_pos = 0;
        l_line := SUBSTR(l_clob, l_pos, l_next_pos - l_pos);
        l_pos := l_next_pos + 1;
        DBMS_OUTPUT.PUT_LINE('Processing line: ' || l_line);

        -- Split the line into fields
        l_fields := t_string_array();
        LOOP
            l_next_pos := INSTR(l_line, p_separator);
            IF l_next_pos = 0 THEN
                l_fields.EXTEND;
                l_fields(l_fields.COUNT) := l_line;
                EXIT;
            ELSE
                l_fields.EXTEND;
                l_fields(l_fields.COUNT) := SUBSTR(l_line, 1, l_next_pos - 1);
                l_line := SUBSTR(l_line, l_next_pos + LENGTH(p_separator));
            END IF;
        END LOOP;

        -- Call the processing function if fields are found
        IF l_fields.COUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Calling process_row_generic for ' || l_fields.COUNT || ' fields...');
            process_row_generic(l_fields);
        END IF;
    END LOOP;

    -- Free the CLOB
    DBMS_LOB.FREETEMPORARY(l_clob);
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        DBMS_LOB.FREETEMPORARY(l_clob);
        RAISE;
END;



END PLSUS_pkg;
/
show errors;