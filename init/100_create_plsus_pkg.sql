-- Package Specification
CREATE OR REPLACE PACKAGE PLSUS_pkg IS
  -- Declare functions
  function adler32( p_src in blob ) RETURN VARCHAR2;

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

END PLSUS_pkg;
/
show errors;