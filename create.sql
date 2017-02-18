-- drop the tables if they already exist

DROP TABLE IF EXISTS bills CASCADE;
DROP TABLE IF EXISTS person_roles CASCADE;
DROP TABLE IF EXISTS persons CASCADE;
DROP VIEW IF EXISTS cur_members CASCADE;
DROP TABLE IF EXISTS person_votes CASCADE;
DROP TABLE IF EXISTS states CASCADE;
DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS votes_re_amendments CASCADE;
DROP TABLE IF EXISTS votes_re_bills CASCADE;
DROP TABLE IF EXISTS votes_re_nominations CASCADE;


-- create the tables and views
-- note: primary keys and foreign keys are specified at the end of this file 
-- (indexes created after data is loaded)


-- bills: describes each bill that has appeared in House or Senate in 2015-2016
CREATE TABLE bills (
    id character(20) NOT NULL,
    session integer NOT NULL,
    type character varying(10) NOT NULL,
    number integer NOT NULL,
    status text NOT NULL,
    status_at timestamp with time zone NOT NULL,
    official_title text NOT NULL,
    popular_title text,
    short_title text
);


-- persons: describes individuals
CREATE TABLE persons (
    id character(10) NOT NULL,
    id_govtrack integer NOT NULL,
    id_lis character(4),
    first_name character varying(50) NOT NULL,
    middle_name character varying(50),
    last_name character varying(50) NOT NULL,
    birthday date,
    gender character(1),
    religion character varying(50),
    CONSTRAINT persons_gender_check CHECK (((gender IS NULL) OR (gender = ANY (ARRAY['F'::bpchar, 'M'::bpchar]))))
);


-- person_roles: describes roles that individuals have fufilled (e.g., serving 
-- as a senator).  this is separate from persons because a person can serve 
-- multiple times for multiple different roles.
CREATE TABLE person_roles (
    person_id character(10) NOT NULL,
    type character(3) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    state character(2) NOT NULL,
    district integer,
    party character varying(50),
    CONSTRAINT person_roles_check CHECK ((((type = 'rep'::bpchar) AND (district IS NOT NULL)) OR ((type = 'sen'::bpchar) AND (district IS NULL)))),
    CONSTRAINT person_roles_type_check CHECK ((type = ANY (ARRAY['rep'::bpchar, 'sen'::bpchar])))
);


CREATE VIEW cur_members AS
 SELECT p.id,
    p.first_name,
    p.last_name,
    p.gender,
    p.birthday,
    p.religion,
    r.type,
    r.party,
    r.state
   FROM persons p,
    person_roles r
  WHERE (((p.id = r.person_id) AND (r.start_date <= ('now'::text)::date)) AND (('now'::text)::date <= r.end_date));


-- person_votes: how a person voted on a particular vote
CREATE TABLE person_votes (
    vote_id character(20) NOT NULL,
    person_id character(10) NOT NULL,
    vote character varying(50) NOT NULL
);


CREATE TABLE states (
    id character(2) NOT NULL
);


-- votes: describe a voting event that took place.  many votes are about bills
-- but there are other voting events too (nominations, amendments)  
CREATE TABLE votes (
    id character(20) NOT NULL,
    category character varying(50) NOT NULL,
    chamber character(1) NOT NULL,
    session integer NOT NULL,
    date date NOT NULL,
    number integer NOT NULL,
    question text NOT NULL,
    subject text,
    type text NOT NULL,
    result text NOT NULL,
    CONSTRAINT votes_chamber_check CHECK ((chamber = ANY (ARRAY['h'::bpchar, 's'::bpchar])))
);


-- votes_re_bills: provides a mapping between vote ids and bill ids
CREATE TABLE votes_re_bills (
    vote_id character(20) NOT NULL,
    bill_id character(20) NOT NULL
);


CREATE TABLE votes_re_nominations (
    vote_id character(20) NOT NULL,
    nomination_number integer NOT NULL,
    nomination_title text NOT NULL
);


CREATE TABLE votes_re_amendments (
    vote_id character(20) NOT NULL,
    amendment_id character(20) NOT NULL
);


-- load the data

COPY bills FROM '/vagrant/lab3/bills.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY person_roles FROM '/vagrant/lab3/person_roles.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY persons FROM '/vagrant/lab3/persons.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY person_votes FROM '/vagrant/lab3/person_votes.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY states FROM '/vagrant/lab3/states.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY votes FROM '/vagrant/lab3/votes.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY votes_re_amendments FROM '/vagrant/lab3/votes_re_amendments.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY votes_re_bills FROM '/vagrant/lab3/votes_re_bills.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');
COPY votes_re_nominations FROM '/vagrant/lab3/votes_re_nominations.csv' WITH 
(FORMAT csv, HEADER true, DELIMITER ',');


-- after data is loaded, add key and foreign key constraints and corresponding indexes

ALTER TABLE ONLY bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);

ALTER TABLE ONLY bills
    ADD CONSTRAINT bills_session_type_number_key UNIQUE (session, type, number);

ALTER TABLE ONLY person_votes
    ADD CONSTRAINT person_votes_pkey PRIMARY KEY (vote_id, person_id);

ALTER TABLE ONLY persons
    ADD CONSTRAINT persons_id_govtrack_key UNIQUE (id_govtrack);

ALTER TABLE ONLY persons
    ADD CONSTRAINT persons_id_lis_key UNIQUE (id_lis);

ALTER TABLE ONLY persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_chamber_session_number_key UNIQUE (chamber, session, number);

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY votes_re_amendments
    ADD CONSTRAINT votes_re_amendments_pkey PRIMARY KEY (vote_id);

ALTER TABLE ONLY votes_re_bills
    ADD CONSTRAINT votes_re_bills_pkey PRIMARY KEY (vote_id);

ALTER TABLE ONLY votes_re_nominations
    ADD CONSTRAINT votes_re_nominations_pkey PRIMARY KEY (vote_id);

ALTER TABLE ONLY person_roles
    ADD CONSTRAINT person_roles_person_id_fkey FOREIGN KEY (person_id) REFERENCES persons(id);

ALTER TABLE ONLY person_roles
    ADD CONSTRAINT person_roles_state_fkey FOREIGN KEY (state) REFERENCES states(id);

ALTER TABLE ONLY person_votes
    ADD CONSTRAINT person_votes_person_id_fkey FOREIGN KEY (person_id) REFERENCES persons(id);

ALTER TABLE ONLY person_votes
    ADD CONSTRAINT person_votes_vote_id_fkey FOREIGN KEY (vote_id) REFERENCES votes(id);

ALTER TABLE ONLY votes_re_amendments
    ADD CONSTRAINT votes_re_amendments_vote_id_fkey FOREIGN KEY (vote_id) REFERENCES votes(id);

ALTER TABLE ONLY votes_re_bills
    ADD CONSTRAINT votes_re_bills_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES bills(id);

ALTER TABLE ONLY votes_re_bills
    ADD CONSTRAINT votes_re_bills_vote_id_fkey FOREIGN KEY (vote_id) REFERENCES votes(id);

ALTER TABLE ONLY votes_re_nominations
    ADD CONSTRAINT votes_re_nominations_vote_id_fkey FOREIGN KEY (vote_id) REFERENCES votes(id);

