# Lab 3 The U.S. Congress and Alternative Facts

Welcome to the *third* COSC 480 Data Science Lab!

You are encouraged to work with a partner for this lab.  If you do not have a partner, let me know and I can assign one to you.  

Parts 1-3 of the lab are due **Monday, Feb. 27th 2017 at 11:59pm**.  Submission instructions are the same as previous labs.  *When you finish, please be sure to write a commit message!*

Part 4 of the lab will be due **Wednesday, Mar. 1st 2017 at 11:59pm**.


## Setup Instructions

Make some updates to your VM,

	vagrant@ubuntu:~$ cd /vagrant/lab3/
	vagrant@ubuntu:/vagrant/lab3$ sh setup_postgresql.sh

Download the data,

    vagrant@ubuntu:~$ cd /vagrant/lab3/
    vagrant@ubuntu:/vagrant/lab3$ curl -O http://cs.colgate.edu/~mhay/cosc480ds/congress.tgz
    vagrant@ubuntu:/vagrant/lab3$ tar xfz congress.tgz

The last command above will create several `.csv` files (`bills.csv`, `persons.csv`, etc.).  Please do **not** commit these files to your git repo.

Create a database,

	vagrant@ubuntu:/vagrant/lab3$ createdb congress

Populate it with data (don't worry about the "table ... does not exist" notices at the beginning):

	vagrant@ubuntu:/vagrant/lab3$ psql congress -f create.sql	


## About the data

You are encouraged to read `create.sql`.  First, it will tell you the *schema* of the data, which will be essential for making progress on this lab.  Second, it is a good model of how you might set up your database (if you choose to use one for your project).


## PostgreSQL Tips

Version 9.3 of PostgreSQL is installed.  You may want to consult the [documentation (especially sections I and II)](https://www.postgresql.org/docs/9.3/static/index.html).

Here's a short primer.

You can start the command-line SQL processor in *interactive mode*.

	vagrant@ubuntu:/vagrant/lab3$ psql congress 
	psql (9.3.15)
	Type "help" for help.

	congress=# 

You can now write SQL commands at the prompt.

	congress=# select * from persons limit 2;

There are also some helpful postgreSQL commands:

- `\d` list all tables and views
- `\d NAME` display the schema information for the table called `NAME`
- `\q` to quit
- `\i FILENAME` to execute commands stored in a local file called `FILENAME`
- `\?` for postgreSQL help

You can also execute in *immediate mode*.

	vagrant@ubuntu:/vagrant/lab3$ psql -c "select * from persons limit 2" congress

Finally, you can execute commands from a file, as in 

	vagrant@ubuntu:/vagrant/lab3$ psql congress -f create.sql	

Suggested workflow: you might open up two terminal windows.  In both, ssh into the vagrant VM.  In one window, open a command-line text editor (`nano`, `vi`, etc.).  In the other window, issue commands to the database (either in interactive mode or immediate mode).  (Note: if you wish, you can also edit the `.sql` files in PyCharm.)


## SQL commands

Some of fields are of type `date`.  SQL offers built-in functions for manipulating dates.  For example, this retrieves birth years of Congress members:

	congress=# select date_part('year', birthday) from persons limit 2;

More info is in the [Functions and Operators section](https://www.postgresql.org/docs/9.3/static/functions.html) of the PostgreSQL documentation.

Regular expressions.  If you want to match a string attribute to a regular expression, you use the `~` operator.  For example, this query finds Congress members with hyphenated last names.

	congress=# select * from persons where last_name ~ '.+-.+' limit 2;


## Your tasks

There are three high-level tasks.  I expect you will spend the bulk of your time working on parts 3-4 and the last few queries in part 1.  In terms of grading, I will give a fair bit of weight to parts 3 and 4.


### Part 1. Querying the Congress Database

For each of the following problems, write a SQL query that retrieves the requested information in the appropriate format.  Write each answer in the separate plain-text `.sql` files that have been provided for you (`q1.sql`, `q2.sql`, etc.).

1. List all persons (past and present members of the Congress) who are female and were born in or after 1976.  Result should include first and last names and a derived attribute called birth_year that contains the person's birth year. Write your answer in `q1.sql`.

2. This database contains every vote made by a Congressperson in 2015-2016.  List all the different possible vote record values (Aye, Nay, etc.) along with the number of times that value was voted.  Order the results from the most frequently cast vote value to the least frequent.  Do you notice anything unusual in the result? Write your answer in `q2.sql`.

3. Similar to previous query, except the query answer should be a single column, consisting of the vote record values (Aye, Nay, etc.) that received at least 1300 votes.  Order alphabetically by vote record value. Write your answer in `q3.sql`.

4. Votes are typically Aye, Nay, etc. yet someone once voted for 'Hon. Jeff Sessions'.  Write a query that returns the question for which that vote was cast. Write your answer in `q4.sql`.

5. Show the number of political parties that contain the word Jackson.  The result should be a single column named party.  Each party should appear only once (no duplicates). Write your answer in `q5.sql`.

6. Write a query that produces for each state and each political party, the number of senators from that political party in that state in the current Senate (use `cur_members`).  Order the results by state and then party, alphabetically. Write your answer in `q6.sql`.

7. Write a query that reports the number of states for which both senators come from the same political party (i.e., both Republican, both Democrat, etc.)  Hint: use the answer to your previous query as a subquery.  (Alternatively, you can use the WITH keyword to create a temporary table with the answer to the previous query.) Your answer should be a single number (i.e., a table with a single row and column). Write your answer in `q7.sql`.

8. List all NY Democratic senators (past and present). Output only first name, last name, and birthday. Order the results by birthday (youngest to oldest).  Duplicate rows should not appear. Write your answer in `q8.sql`.

9. Find the oldest current member of the House of Representatives for each state.  Result should include two attributes, state and birth_year.  The birth year should be that of the oldest member from that state.  Sort the results from oldest to youngest and then alphabetically by state (in case of ties in birth year).  Hint: you might find the cur_members table handy. Write your answer in `q9.sql`.

10. Which state has the largest number of representatives under 40 currently serving?  Write a query that returns the name of the state (a table with a single row and column). Write your answer in `q10.sql`.

11. List all NY Democratic senators (past and present) who have served at least 3 terms. Output only first name, last name and the number of times he/she served. Write your answer in `q11.sql`.

12. A bill can be voted on multiple times.  Write a query that returns the id of the bill that was voted on the most along with the number of times it was voted on.  (Hint 1: you can use the LIMIT clause to get the first row from a query that returns multiple rows.  Hint 2: you will need to use the votes_re_bills table use `\d votes_re_bills` to see the schema and foreign keys of that table.)  What is this bill?  Describe it in a comment below your query. Write your answer in `q12.sql`.

13. Find persons who have served in both the House and Senate, representing the state of NY in both houses.  Hint: if you join a table with itself on some attribute, can get pairs of rows from the original table that agree on the joining attribute.  The result should be the first and last name of the person (without duplicates). Write your answer in `q13.sql`.

14. Write a query that produces a relation that is essentially an augmented version of person_votes.  It should have the following fields: vote_id, person_id, first_name, last_name, party, and vote.  This captures a person's vote as well as party affiliation *at the time of the vote.*  Please limit your result to the first 100 rows ordered by vote_id and person_id (ascending order). Write your answer in `q14.sql`.

15. Who says Republicans and Democrats can't get along?  One of the major bills to pass in 2015 was the Every Child Achieves Act, an overhaul of Bush's No Child Left Behind Act.  Write a query that returns the vote tally broken down by party.  The result should have three columns: party (Democrat, etc.), vote (Yea, Nay, etc.), and count (number of people from this party voting this way).  Hint: Use your answer to the previous problem.  You can use it by taking advantage of the WITH keyword, as discussed in class.  You can query for the relevant bill by including some condition on the bill's short_title field.  This bill was voted on multiple times.  We want the final vote.  To achieve this, set the vote category to be "passage" and the vote type to have the word "Passage" in it. Write your answer in `q15.sql`.

### Part 2. Query Debugging

The file called `price-pelosi.sql` has a query that is producing puzzling results.  The intent of the query is to compare the voting records of David Price (D-NC) with Nancy Pelosi (D-CA).  The results of the query suggest that these two Democrats vote differently a significant fraction of the time.

	vagrant@ubuntu:/vagrant/lab3$ psql congress -f price-pelosi.sql 
	 agree | total |       percent       
	-------+-------+---------------------
	  1411 |  2649 | 53.2653831634579086

Try to figure out what's going on.  You are encouraged to make changes to `price-pelosi.sql` to help you figure out the issue.  When you figure it out, write your explanation in the file called `price-pelosi-explained.txt`.

### Part 3. Making Claims

In class we discussed the pitfalls of statistics.  One place where statistics are regularly abused is the political realm.  Organizations like [FactCheck.org](http://www.factcheck.org/) serve a valuable role in rooting out baseless claims as well as providing context for claims that may be technically true but are misleading ("truthful hyperbole" in the words of our current president).    This is a challenging task.  You might be interested to know that computer scientists have developed research prototypes that attempt to [automate some aspects of fact checking](http://dl.acm.org/citation.cfm?id=2732295).

Your job for this part is to find an interesting claim that is supported by the Congress database.  Your claim must satisfy the following properties:

1. The claim is attention grabbing.  (Ask yourself, would Trump tweet this?  Okay, that's a joke.  However, the interestingness of your claim will be a factor in the grade for this part of the assignment.)
2. The correctness of the claim can be verified by SQL queries over the congress database alone, without drawing from external data sources.
3. The claim is factually accurate but misleading.

The query in part 2 satisfies 1 and 2 but fails on 3 because the query answer is factually inaccurate (the SQL query contains a bug).

Here is an example of a fact that satisfies criteria 2 and 3 and, to some extent, 1.

> The average age of U.S. Representatives from D.C. is a whopping 79!

This is misleading because D.C. has only one representative.  (This query scores a bit low on the interestingness scale.)

**What to submit** In the file called `claim.txt`, provide 1) your claim, 2) SQL queries to support your claim, and 3) an explanation of how your claim is misleading.

### Part 4. Fact Checking

After part 3 is submitted, we will have a follow up round in which you will be asked to fact check the claims of other students.  The facts will be posted and then for each fact you take on, you can create a copy of `claim.txt` and fill it in accordingly.


### Challenge problem

The challenge problem this week is to generate more than one interesting claim and to analyze as many claims of others as you can.



##### Acknowledgments

Thanks to Ashwin Machanavajjhalla and Jun Yang of Duke University for providing the cleaned up database as well as some of the queries/exercises.
