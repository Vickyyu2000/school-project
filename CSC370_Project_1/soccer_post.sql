/*The questions in this assignment are about doing soccer analytics using SQL.
Create the tables by importing the csv files provided: 
     england.csv, france.csv, germany.csv, italy.csv
Use DataGrip to import the files and automatically create the tables.
The data will then be in tables England, France, Germany, and Italy.
The tables contain more than 100 years of soccer game statistics.

Write SQL statements to answer the questions.

Submit this file after adding your queries.
Replace "Your query here" text with your query for each question.
Submit one spreadsheet file with your visualizations for questions 2, 7, 9, 10, 12
(one sheet per question named by question number, e.g. Q2, Q7, etc).
*/


/*Q1 (1 pt)
Find all the games in England between seasons 1920 and 1999 such that the total goals are at least 13.
Order by total goals descending.*/

/*Your query here*/
SELECT *
FROM england
WHERE season >= 1920 AND season <= 1999 AND totgoal >= 13
ORDER BY totgoal DESC;

/*Sample result
1935-12-26,1935,Tranmere Rovers,Oldham Athletic,13,4,3,17,9,H
1958-10-11,1958,Tottenham Hotspur,Everton,10,4,1,14,6,H
...*/


/*Q2 (2 pt)
For each total goal result, find how many games had that result.
Use the england table and consider only the seasons since 1980.
Order by total goal.*/

/*Your query here*/
SELECT totgoal, COUNT(*) AS games_count
FROM england
WHERE season >= 1980
GROUP BY totgoal
ORDER BY totgoal;

/*Sample result
0,6085
1,14001
...*/

/*Visualize the results using a barchart.*/


/*Q3 (2 pt)
Find for each team in England in tier 1 the total number of games played since 1980.
Report only teams with at least 300 games.

Hint. Find the number of games each team has played as "home".
Find the number of games each team has played as "visitor".
Then union the two and take the sum of the number of games.
*/

/*Your query here*/
SELECT team, SUM(num_games) AS total_games
FROM (
  SELECT home AS team, COUNT(*) AS num_games
  FROM england
  WHERE season >= 1980 AND tier = 1
  GROUP BY home

  UNION ALL

  SELECT visitor AS team, COUNT(*) AS num_games
  FROM england
  WHERE season >= 1980 AND tier = 1
  GROUP BY visitor
) AS games
GROUP BY team
HAVING SUM(num_games) >= 300
ORDER BY total_games DESC;

/*Sample result
Everton,1451
Liverpool,1451
...*/


/*Q4 (1 pt)
For each pair team1, team2 in England, in tier 1,
find the number of home-wins since 1980 of team1 versus team2.
Order the results by the number of home-wins in descending order.

Hint. After selecting the tuples needed (... WHERE tier=1 AND ...) do a GROUP BY home, visitor.
*/

/*Your query here*/
SELECT home, visitor, COUNT(*) AS home_wins
FROM england
WHERE tier = 1 AND season >= 1980 AND hgoal > vgoal
GROUP BY home, visitor
ORDER BY home_wins DESC;

/*Sample result
Manchester United,Tottenham Hotspur,27
Arsenal,Everton,26
...*/


/*Q5 (1 pt)
For each pair team1, team2 in England in tier 1
find the number of away-wins since 1980 of team1 versus team2.
Order the results by the number of away-wins in descending order.*/

/*Your query here*/
SELECT visitor AS team1, home AS team2, COUNT(*) AS away_wins
FROM england
WHERE tier = 1 AND season >= 1980 AND visitor != home AND result = 'A'
GROUP BY visitor, home
ORDER BY away_wins DESC;

/*Sample result
Manchester United,Aston Villa,18
Manchester United,Everton,17
...*/

/*Q6 (2 pt)
For each pair team1, team2 in England in tier 1 report the number of home-wins and away-wins
since 1980 of team1 versus team2.
Order the results by the number of away-wins in descending order.

Hint. Join the results of the two previous queries. To do that you can use those
queries as subqueries. Remove their ORDER BY clause when making them subqueries.
Be careful on the join conditions.
*/

/*Your query here*/
SELECT hw.home AS team1, hw.visitor AS team2, hw.home_wins AS home_wins, aw.away_wins AS away_wins
FROM (
    SELECT home, visitor, COUNT(*) AS home_wins
    FROM england
    WHERE tier = 1 AND result = 'H' AND season >= 1980
    GROUP BY home, visitor
) hw
JOIN (
    SELECT home AS visitor, visitor AS home, COUNT(*) AS away_wins
    FROM england
    WHERE tier = 1 AND result = 'A' AND season >= 1980
    GROUP BY home, visitor
) aw
ON hw.home = aw.home AND hw.visitor = aw.visitor
ORDER BY away_wins DESC;

/*Sample result
Manchester United,Aston Villa,26,18
Arsenal,Aston Villa,20,17
...*/

--Create a view, called Wins, with the query for the previous question.
CREATE VIEW Wins AS
SELECT hw.home AS team1, hw.visitor AS team2, hw.home_wins AS home_wins, aw.away_wins AS away_wins
FROM (
    SELECT home, visitor, COUNT(*) AS home_wins
    FROM england
    WHERE tier = 1 AND result = 'H' AND season >= 1980
    GROUP BY home, visitor
) hw
JOIN (
    SELECT home AS visitor, visitor AS home, COUNT(*) AS away_wins
    FROM england
    WHERE tier = 1 AND result = 'A' AND season >= 1980
    GROUP BY home, visitor
) aw
ON hw.home = aw.home AND hw.visitor = aw.visitor
ORDER BY away_wins DESC;




/*Q7 (2 pt)
For each pair ('Arsenal', team2), report the number of home-wins and away-wins
of Arsenal versus team2 and the number of home-wins and away-wins of team2 versus Arsenal
(all since 1980).
Order the results by the second number of away-wins in descending order.
Use view W1.*/

/*Your query here*/
SELECT w1.team1 AS Arsenal, w1.team2 AS team2, w1.home_wins AS home_wins_Arsenal, w1.away_wins AS away_wins_Arsenal, w2.home_wins AS home_wins_team2, w2.away_wins AS away_wins_team2
FROM Wins AS w1
JOIN Wins AS w2 ON w1.team2 = w2.team1 AND w1.team1 = w2.team2
WHERE w1.team1 = 'Arsenal'
ORDER BY away_wins_team2 DESC;

/*Sample result
Arsenal,Liverpool,14,8,20,11
Arsenal,Manchester United,16,5,19,11
...*/

/*Drop view Wins.*/
DROP VIEW Wins;

/*Build two bar-charts, one visualizing the two home-wins columns, and the other visualizing the two away-wins columns.*/


/*Q8 (2 pt)
Winning at home is easier than winning as visitor.
Nevertheless, some teams have won more games as a visitor than when at home.
Find the team in Germany that has more away-wins than home-wins in total.
Print the team name, number of home-wins, and number of away-wins.*/

/*Your query here*/
SELECT team, h_num home_wins_num, v_num away_wins_num
from(select home team, count(hgoal) h_num
    FROM germany
    where hgoal>vgoal
    group by team) t1 NATURAL JOIN
    (select visitor team, count(vgoal) v_num
    from germany
    where hgoal<vgoal
    group by team) t2
where h_num < v_num;
/*Sample result
Wacker Burghausen	...	...*/


/*Q9 (3 pt)
One of the beliefs many people have about Italian soccer teams is that they play much more defense than offense.
Catenaccio or The Chain is a tactical system in football with a strong emphasis on defence.
In Italian, catenaccio means "door-bolt", which implies a highly organised and effective backline defence
focused on nullifying opponents' attacks and preventing goal-scoring opportunities.
In this question we would like to see whether the number of goals in Italy is on average smaller than in England.

Find the average total goals per season in England and Italy since the 1970 season.
The results should be (season, england_avg, italy_avg) triples, ordered by season.

Hint.
Subquery 1: Find the average total goals per season in England.
Subquery 2: Find the average total goals per season in Italy
   (there is no totgoal in table Italy. Take hgoal+vgoal).
Join the two subqueries on season.
*/

/*Your query here*/

--Build a line chart visualizing the results. What do you observe?

/*Sample result
1970,2.5290927021696252,2.1041666666666667
1971,2.5922090729783037,2.0125
...*/


/*Q10 (3 pt)
Find the number of games in France and England in tier 1 for each goal difference.
Return (goaldif, france_games, eng_games) triples, ordered by the goal difference.
Normalize the number of games returned dividing by the total number of games for the country in tier 1,
e.g. 1.0*COUNT(*)/(select count(*) from france where tier=1)  */

/*Your query here*/

/*Sample result
-8,0.00011369234850494562,0.000062637018477920450987
-7,0.00011369234850494562,0.00010439503079653408
...*/

/*Visualize the results using a barchart.*/


/*Q11 (2 pt)
Find all the seasons when England had higher average total goals than France.
Consider only tier 1 for both countries.
Return (season,england_avg,france_avg) triples.
Order by season.*/

/*Your query here*/

/*Sample result
1936,3.3658008658008658,3.3041666666666667
1952,3.2640692640692641,3.1437908496732026
...*/
