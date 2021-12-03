/* SQL Commands */

/* Chapter 1 - Basic Commands
/      Ran on: University Admission SQLs
*/

/* BASIC definitions
    Table - Relation
    Column - Attribute, Field
    SELECT - Displays the specific cols
    FROM - Takes info from a Table
    WHERE - A filter clause
    AGGREGATIONS - min(), max(), sum(), avg(), count()
    NULL - any value in the database which is undefined or unknown
*/

/* SEARCH using regular expression style on an attribute */

    select A1, A2, ..., An
    from R1
    where A1 like '%str'

    select *
    from Apply
    where major like '%bio%';

/* FILTER col by simple integer */

    select A1, A2, ..., An
    from R1
    where A1 > num 

    select sID, sName, GPA
    from Student
    where GPA > 3.6;
    
/* COMBINE relations (cross product). Duplicates produced by multi-set model. */
    
    select A1, A2, ..., An
    from R1, R2
    where R1.Ax = R2.Ay 
    
    select sName, major
    from Student, Apply
    where Student.sID = Apply.sID;
    
/* a) No duplicates (on both fields sName AND major) */
    select distinct sName, major
    from Student, Apply
    where Student.sID = Apply.sID;

/* COMBINE and FILTER two tables. */
    
    select sName, GPA, decision
    from Student, Apply
    where Student.sID = Apply.sID
        and sizeHS < 1000 and major = 'CS' and cName = 'Stanford';
        
/* AMBIGUOUS col names resolution */

    select College.cName
    from College, Apply
    where College.cName = Apply.cName
        and enrollment > 20000 and major = 'CS';
        
/* TRIPLE COMBINE */

    select Student.sID, sName, GPA, Apply.cName, enrollment
    from Student, College, Apply
    where Apply.sID = Student.sID and Apply.cName = College.cName
    
/* ORDER Results. SQL is an unordered language and there is no order guarantee. Default is ASC. Can order by 2+ things - one by one. */

    select Student.sID, sName, GPA, Apply.cName, enrollment
    from Student, College, Apply
    where Apply.sID = Student.sID and Apply.cName = College.cName
    order by GPA desc, enrollment;

/* PRINT All cols */
    
    select *
    from Student, College;
    
/* ARITHMETIC in SELECT */
    
    select sID, sName, GPA, sizeHS, GPA * (sizeHS / 1000.0 )
    from Student;

/* COLUMN ALIAS name */

    select sID, sName, GPA, sizeHS, GPA * (sizeHS / 1000.0 ) as scaledGPA
    from Student;

/* TABLE VARIABLES. In FROM clause. SELF-JOINs and Aliasing of tables for clarity */
    
    select S.sID, sName, GPA, A.cName, enrollment
    from Student S, College C, Apply A
    where A.sID = S.sID and A.cName = C.cName
    
/* SELF-JOIN. Pair of rows, or two copies of the same table matched against each other */

    select S1.sID, S1.sName, S1.GPA, S2.sID, S2.sName, S2.GPA
    from Student S1, Student S2
    where S1.GPA = S2.GPA and S1.sID < S2.sID;
    
/* Set Operators - Union. Put together values from two different sets and eliminate duplicates.
   The two selects must return the same tuple signatures i.e. both cName and sName return text */
   
    select cName as name from College
    union
    select sName as name from Student
    
/*   P.S. If you want to keep the duplicates use union all  */

/*  Intersect. Create two sets and return the interection between them. */

    select sID from Apply where major = 'CS'
    intersect
    select sID from Apply where major = 'EE';

/* Systems with no Intersect available  */

    select distinct A1.sID
    from Apply A1, Apply A2
    where A1.sID=A2.sID and A1.major = 'CS' and A2.major='EE';

/* Except. Create two sets and return the values not common to both. */

    select sID from Apply where major = 'CS'
    except
    select sID from Apply where major = 'EE';

/*  If except is not defined in the SQL language version    */

    select sID, sName
    from Student
    where sID in (select sID from Apply where major='CS')
        and sID not in (select sID from Apply where major = 'EE');


/*  Subquery in the where clause. Inside paranthesis returns a set of the wehere attribute  */

    select sID, sName
    from Student
    where sID in (select sId from Apply where major='CS');

/*  Without subquery in where clause    */

    select distinct Student.sID, sName
    from Student, Apply
    where Student.sID = Apply.sID and major='CS';
    
/*  Correlated Reference with exists. Exists seems to return a truth table on the matched entries. */

    select cName, state
    from College C1
    where exists (select * from College C2 where C2.state=C1.state and C1.cName <> C2.cName);

/* Using All construct. Finds all matches (returns true) against the whole set on the right */

    select sName, GPA
    from Student
    where GPA >= all (select GPA from Student);     

    select cName
    from College C1
    where enrollment > all (select enrollment from College C2 where C2.cName <> C1.cName);

/*  Using Any construct. Satisfied with 1 or more elements from the Subquery    */

    select cName
    from College S1
    where not S1.enrollment <= any (select enrollment from College S2 where S2.cName<>S1.cName);

    select sID, sName, sizeHS
    from Student
    where sizeHS > any ( select sizeHS from Student );
    
/*      SQLLite where any is NOT defined, we can replace with exists. (Can always be substituted)  */
    
    select sID, sName, sizeHS
    from Student S1
    where exists ( select * from Student S2 where S2.sizeHS < S1.sizeHS )

/* TEMP Table. Using a SUBQUERY in the FROM clause. */

    select *
    from
    (
        select sID, sName, GPA, GPA * (sizeHS / 1000.0) as scaledGPA
        from Student
    ) G
    where abs( G.scaledGPA - GPA ) > 1.0;
    
/* Using SUBQUERY in the SELECT clause. CAUTION: subquery MUST return 1 value.*/
    
    select cName, state, 
    (
        select distinct GPA
        from Apply, Student
        where GroupByCollege.cName = Apply.cName 
            and Apply.sID = Student.sID
            and GPA >= all 
            (
                select GPA
                from Student, Apply
                where Student.sID = Apply.sID
                    and Apply.cName = GroupByCollege.cName
            )
    ) as GPA
    from College GroupByCollege;


/* Chapter 2 - Joins
/      Ran on: University Admission SQLs */

/* INNER join. Relational algebra's cross product (natural join) */
    
    select distinct sName, major
    from Student inner join Apply
    on Student.sID = Apply.sID;

/* TRIPLE INNER Join. CAUTION: Order of JOINs can be set by using parenthesis, and it CAN affect the runtime */

    select *
    from Apply join Student
    on Apply.sID = Student.sID
    join College
    on Apply.cName = College.cName;

/* NATURAL JOIN. Finds the common column implicitly/automatically (common by name). It eliminates duplicate column names automatically (joined cols). */

    select distinct sName, major
    from Student natural join Apply;

/* EXPLICIT JOIN. On a specific column. */

    select sName, GPA
    from Student join Apply using( sID )
    where sizeHS < 1000 and major = 'CS' and cName = 'Stanford';

    select S1.sID, S1.sName, S1.GPA, S2.sID, S2.sName, S2.GPA
    from Student S1 join Student S2 using( GPA )
    where S1.sID < S2.sID;

/* LEFT Join. AKA Left OUTER Join. Take everything from the left, and fill tuples with nulls that don't exists on the right (dangling tuples). */

    select *
    from Student left outer join Apply using( sID );

    select *
    from Student natural right outer join Apply;

/* EXPLICIT LEFT Outer join, without using outer join feature of the language. */
    
    select sName, Student.sID, cName, major
    from Student, Apply
    where Student.sID = Apply.sID
    union
    select sName, sID, null, null
    from Student
    where sID not in ( select sID from Apply )

/* FULL OUTER JOIN. NOT Associative. */

    select *
    from Student full outer join Apply using( sID );

    select *
    from (T1 natural full outer join T2) natural full outer join T3;
/*      Does NOT equal (due to non-associativity of full outer joins) */
    select *
    from T1 natural full outer join (T2 natural full outer join T3);

/* Chapter 3 : AGGREGATIONS. 
/   Commonly used with GROUP BY and HAVING clauses. WHERE filters by single row, while HAVING will filter through the GROUP (could be many rows). */

/* AVERAGE over whole col. */
    
    select avg(GPA)
    from Student;

/* MIN of the whole col. */

    select min(GPA)
    from Student
    where sID in ( select sID from Apply where major = 'CS');

/* COUNT in select (col 1 = cName), distinctly by another col (col 2 = sID). */

    select count( distinct sID )
    from Apply 
    where cName = 'Cornell';

/* FORM two single number computations and take the difference (done via FROM clause) */

    select CS.avgGPA - nonCS.avgGPA
    from
    (
        select avg(GPA) as avgGPA
        from Student where sID in ( select sID from Apply where major = 'CS' ) 
    ) as CS,
    (
        select avg(GPA) as avgGPA
        from Student where sID not in ( select sID from Apply where major = 'CS' ) 
    ) as nonCS;

/* GROUP by a col (collect the similar rows in that col) and count their occurances. Displaying col makes sense, since it is PART of the group. */
    
    select cName, count(cName)
    from Apply
    group by cName;
    
/* VIEW GROUPS */

    select cName
    from Apply
    group by cName

/* GROUP BY multiple col/attritube group with aggregate calculation */

    select cName, major, min( GPA ), max( GPA )
    from Student, Apply
    where Student.sID = Apply.sID
    group by cName, major;

/* GROUP by gives RANDOM col name to attritubes outside of the group. PostGRE throws error, but it works in SQLite with random results. Remove comment to make it work. */

    select Student.sID, sName, count( distinct cName )
    from Student, Apply
    where Student.sID = Apply.sID
    group by Student.sID /*, Student.sName */;

/* ADD 0s to count where we would have nulls (Counting nulls) */

    select Student.sID, count( distinct cName )
    from Student, Apply
    where Student.sID = Apply.sID
    group by Student.sID
    union
    select sID, 0
    from Student
    where sID not in ( select sID from Apply );

/* FILTER Aggregation using HAVING clause. */

    select cName, count(cName)
    from Apply
    group by cName
    having count(cName) < 5;

/* REPLACING GROUP BY. Every query using GROUP BY/HAVING using a more clunky formulation. */
    
    select distinct cName
    from Apply A1
    where 5 > ( select count(*) from Apply A2 where A2.cName = A1.cName )

/* LARGER 2-column Group with HAVING clause */

    select cName, count( decision )
    from Apply
    group by cName, decision
    having decision = 'N';

/* NESTED AGGREGATION in HAVING clause. */

    select major
    from Student, Apply
    where Student.sID = Apply.sID
    group by major
    having max( GPA ) < ( select avg( GPA ) from Student );

/* SEARCHING for all values in a column, including nulls! */

    select sID, sName, GPA
    from Student
    where GPA > 3.5 or GPA <= 3.5 or GPA is null;

/* 3-VALUED LOGIC example. Even though it doesn't match one clause it if matches ANY it will show up in result. */

    select sID, sName, GPA, sizeHS
    from Student
    where GPA < 3.5 or sizeHS < 1600 or sizeHS >= 1600; /* Even if we have students with NULL gpas they will show up if they have non-NULL sizeHS */ 

/* AGGREGATION and NULL discreptancies. Use caution in aggregation functions when working with NULLs */

    select distinct GPA
    from Student; /* will show NULLs */
    
    select count( distinct GPA )
    from Student; /* will NOT count NULLs */

/* Chapter 4 - MODIFICATIONS
/   Insert, update and delete statements. */

/* Inserting, Deleting, Updating Syntax.
    insert into Table
        values( A1, A2, ... , An )
    
    insert into Table
        select-statement
        
    delete from Table
    where condition
    
    update Table
    set Attr = Expression
    where Condition
    
    update Table
    set A1=Expr1, A2=Expr2, ... , An=Exprn
    where Condition
*/

/* INSERT a single value. */
    
    insert into College values( 'Carnegie Mellon', 'PA', 11500);

/* INSERT a series of values, constucted by a subquery */

    insert into Apply
    select sID, 'Carnegie Mellon', 'CS', null
    from Student
    where sID not in ( select sID from Apply );

/* DELETE using a subquery in the where clause. Caution: some DBMS do not allow for deletion from the same table as the query, but PostGRE does. */

    delete from Apply
    where sID in 
    (
        select sID
        from Apply
        group by sID
        having count( distinct major ) > 2
    );

/* UPDATE setting two attributes and updating using a where clause of two conditions */

    update Apply
    set decision = 'Y', major = 'economics'
    where cName = 'Carnegie Mellon'
    and sID in ( select sID from Student where GPA < 3.6 );

    update Apply
    set decision = 'Y';
    
    update Apply
    set major = 'CS'
    where major = 'EE' and
    sID in 
    (
        select sID 
        from Student
        where GPA >= all 
        (
            select GPA 
            from Student
            where sID in ( select sID from Apply where major = 'EE' )
        )
    );















