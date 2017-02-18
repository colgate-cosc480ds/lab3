with votes_compare(vote_id, vote1, vote2) as
(select v1.vote_id, v1.vote, v2.vote
    from votes v, persons p1, persons p2, person_votes v1, person_votes v2
    where v.chamber = 'h' and (v.session = 2015 or v.session = 2016)
    and p1.last_name = 'Price' and p2.last_name = 'Pelosi'
    and v1.person_id = p1.id and v2.person_id = p2.id
    and v1.vote_id = v2.vote_id and v.id = v1.vote_id)
select 
count(*) as agree,
(select count(*) from votes_compare) as total,
(count(*)*100.00 / (select count(*) from votes_compare)) as percent
from votes_compare
where vote1 = vote2;