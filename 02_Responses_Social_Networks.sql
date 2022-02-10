use social_net;
-- QUESTION 1
-- Find the names of all students who are friends with someone named Gabriel.
select Highschooler.name
from (select Friend.ID2
-- Because Friend has a pair of IDs recurring in each column, we split Highschooler into two
      from (Friend left join Highschooler as hs1 on Friend.ID1 = hs1.ID)
      where hs1.name = 'Gabriel'
      -- To return a single list of IDs from the other half of Highschooler, we use union
      union
      select Friend.ID1
      from (Friend left join Highschooler as hs2 on Friend.ID2 = hs2.ID)
      where hs2.name = 'Gabriel') as Friends_Selection
      -- Joining the resultant table with Highschooler to obtain desired names
      left join Highschooler on Friends_Selection.ID2 = Highschooler.ID;

-- QUESTION 2
-- For every student who likes someone 2 or more grades younger than themselves, 
-- return that student's name and grade, and the name and grade of the student they like.

-- creating a pair of names and grades to be returned as a table
select hs1.name as id1_name, hs1.grade as id1_grade, hs2.name as id2_name, hs2.grade as id2_grade
-- splitting highschooler into two
from (Likes left join Highschooler as hs1 on Likes.ID1 = hs1.ID) left join Highschooler as hs2 on Likes.ID2 = hs2.ID
-- extracting the difference in grades
where hs1.grade - hs2.grade >= 2; 
      
-- QUESTION 3
-- For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once, with the two names in alphabetical order.

select distinct hs1.name, hs1.grade, hs2.name, hs2.grade
from Likes as l1, Likes as l2, Highschooler as hs1, Highschooler as hs2
where l1.ID1 = hs1.ID and
      l1.ID2 = hs2.ID and
      l2.ID1 = hs1.ID and
      l2.ID2 = hs2.ID and
      hs1.name < hs2.name;
      
-- QUESTION 4
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. 
-- Sort by grade, then by name within each grade.
select name, grade
from Highschooler
-- Making a single list and comparing to Highschooler
where ID not in (
      select ID1 from Likes
      union
      select ID2 from Likes)
order by grade, name;

-- QUESTION 5
-- For every situation where student A likes student B, but we have no information about 
-- whom B likes (that is, B does not appear as an ID1 in the Likes table), 
-- return A and B's names and grades.

-- splitting name and grade variables into two
select distinct hs1.name, hs1.grade, hs2.name, hs2.grade
-- splitting Highschooler to two for easy pair name match and comparison 
from Highschooler as hs1, Highschooler as hs2, Likes
-- extracting ones liking each other from the resultant datasets 
where hs1.ID = Likes.ID1 and
      hs2.ID = Likes.ID2 and 
      -- for B that does not appear as ID1
      hs2.ID not in (select ID1 from Likes);
      
-- QUESTION 6
-- Find names and grades of students who only have friends in the same grade. 
-- Return the result sorted by grade, then by name within each grade.
select distinct hs1.name, hs1.grade
from Highschooler as hs1, Highschooler as hs2, Friend as fr
where hs1.ID = fr.ID1 and
      hs2.ID = fr.ID2 and
      -- excluding the ones that are not in the same grade
      hs1.ID not in (
             select hs1.ID
             from Highschooler as hs1, Highschooler as hs2, Friend as fr
             where hs1.ID = fr.ID1 and
                   hs2.ID = fr.ID2 and
                   hs1.grade != hs2.grade)
order by hs1.grade, hs1.name;
      

-- QUESTION 7
-- For each student A who likes a student B where the two are not friends, 
-- find if they have a friend C in common (who can introduce them!). 
-- For all such trios, return the name and grade of A, B, and C.

select distinct hs1.name, hs1.grade, hs2.name, hs2.grade, hs3.name, hs3.grade
from Highschooler as hs1, Highschooler as hs2, Highschooler as hs3, Likes, Friend
-- Identifying names of student A and B
where hs1.ID = Likes.ID1 and
      hs2.ID = Likes.ID2 and
      -- Determining that they are not friends
      hs1.ID not in (
          select Friend.ID2
          from Friend
          -- the liking student has a mutual friend in the list of the liked
          where Friend.ID1 = hs2.ID)
	  and
      -- detrmining if they have a mutual friend
      hs3.ID in (
          select Friend.ID2
          from Friend
          -- the liking student is friends with another liking student
          where Friend.ID1 = hs1.ID)
	  and hs3.ID in (
          select Friend.ID2
          from Friend
          -- the liking student is friends with another liked student
          where Friend.ID1 = hs2.ID);
          

-- QUESTION 8
-- Find the difference between the number of students in the school and 
-- the number of different first names.

select count(distinct ID) - (select count(distinct name) from Highschooler)
from Highschooler;

-- QUESTION 9
-- Find the name and grade of all students who are liked by more than one other student.
select Highschooler.name, Highschooler.grade
-- Listing names of students who are liked
from Likes left join Highschooler on Likes.ID2 = Highschooler.ID
group by Likes.ID2
-- where their likers are more than one
having count(Likes.ID1) > 1;