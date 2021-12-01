/* Delete the tables if they already exist */
drop table if exists College;


create table College(cName text, state text, enrollment int);
create table Student(sID int, cName text, major text, decision text);





