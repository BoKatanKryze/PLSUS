create or replace directory CSV_TEST_IN as 'C:\Private\Dev\Oracle\Directories\csv_test';

grant execute, read, write on directory SYS.CSV_TEST_IN to c##sKauro;