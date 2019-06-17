/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name AS facility_name,
	   membercost AS member_cost
	FROM Facilities
	WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS free_facility_count
	FROM Facilities
	WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,
       name,
       membercost,
       monthlymaintenance
    FROM Facilities
    WHERE membercost > 0
        AND membercost < 0.2*monthlymaintenance
    ORDER BY facid
    
/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT  facid,
        guestcost,
        initialoutlay,
        membercost,
        monthlymaintenance,
        name
    FROM Facilities
	WHERE facid IN (1,5)
    ORDER BY facid

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT  name,
        monthlymaintenance,
        CASE 
            WHEN monthlymaintenance > 100 THEN 'Expensive'
            ELSE 'Cheap'
        END AS maintenance_tag
    FROM Facilities
    ORDER BY monthlymaintenance

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT  Members.firstname,
        Members.surname,
        Members.joindate
    FROM Members
    JOIN 
        (
            SELECT MAX(joindate) AS latest_join_date
                FROM Members
        ) max_member
        ON Members.joindate = max_member.latest_join_date
        
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* Main query joins the memid field from the second subquery with the memid field from Members to extract name info from memid's */
SELECT	DISTINCT m.firstname,
		m.surname,
		sub2.name
    FROM
    /* Second subquery to join the bookings from sub1 with the memid field from Bookings */
    (
        SELECT	b.memid,
                sub1.name
            FROM Bookings b
            JOIN
            (
                /* First subquery to filter for Tennis Court facilities*/
                SELECT  f.facid,
                        f.name
                FROM Facilities f
                WHERE name LIKE '%Tennis Court%'
            ) sub1
            ON b.facid = sub1.facid
    ) sub2
	JOIN Members m
		ON m.memid = sub2.memid
	ORDER BY m.surname


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT	f.name,
		m.firstname,
        m.surname,
		CASE
			WHEN b.memid = 0 THEN b.slots*f.guestcost
			ELSE b.slots*f.membercost
		END AS session_cost
	FROM Bookings b
	JOIN Facilities f
		ON b.facid = f.facid
	JOIN Members m
		ON b.memid = m.memid
	WHERE b.starttime < '2012-09-15'
		AND b.starttime > '2012-09-14'
	HAVING session_cost > 30
	ORDER BY session_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT  m.firstname,
        m.surname,
        sub.facility_name,
        sub.total_cost
    FROM
    (
        SELECT  f.name AS facility_name,
                f.guestcost,
                f.membercost,
                b.memid,
                b.slots,
                /*Calculate the total cost guest/member spent for that facility*/
                CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
                    ELSE f.membercost * b.slots END AS total_cost,
                b.starttime
        FROM Bookings b
        JOIN Facilities f
            ON b.facid = f.facid
        /* Filter to include all bookings made on 2012-09-14 */
        WHERE b.starttime < '2012-09-15'
            AND b.starttime > '2012-09-14'
        ORDER BY b.starttime DESC
    ) sub
JOIN Members m
    ON m.memid = sub.memid
    
/* Filter to include all total_cost values greater than $30 for that day*/
WHERE sub.total_cost > 30
ORDER BY sub.total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT	f.name,
		/*Total the amount charged to members/guests that used the facility to get profit*/
        SUM(
            CASE 
            	WHEN b.memid = 0 THEN f.guestcost * b.slots
                ELSE f.membercost * b.slots 
            END)
        /*Count the number of distinct months in Bookings, multiply by monthlymaintenance, and subtract from profit to get total_revenue*/
		- COUNT(
            DISTINCT MONTH(b.starttime)
            )
		* f.monthlymaintenance AS total_revenue
	FROM Bookings b
	JOIN Facilities f
		ON b.facid = f.facid
	GROUP BY 1
    /* Filter the revenue for facilities that made less than $1000 */
	HAVING total_revenue < 1000
	ORDER BY 2
    
    
