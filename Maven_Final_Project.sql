  -- PART I: SCHOOL ANALYSIS -- 1. VIEW the schools AND school details tables
SELECT
  *
FROM
  `Maven_Final_Project.schools`;
SELECT
  *
FROM
  `Maven_Final_Project.school_details`;
SELECT
  MAX(yearID),
  MIN(yearID)
FROM
  `Maven_Final_Project.schools`; 
  
  
-- 2. IN each decade,how many schools were there that produced players?
WITH
  cte_4 AS (
  SELECT
    yearID,
    COUNT(DISTINCT schoolID)players_count,
    CAST(FLOOR(yearID/10)*10 AS int64) decade
  FROM
    `Maven_Final_Project.schools`
  GROUP BY
    yearID
  ORDER BY
    yearID)
SELECT
  cte_4.decade,
  SUM(cte_4.players_count) no_of_schhols_per_dec
FROM
  cte_4
GROUP BY
  cte_4.decade
ORDER BY
  cte_4.decade; 
  
  
--3. What are the names OF the top 5 schools that produced the most players?
WITH
  cte_3 AS (
  SELECT
    schoolID,
    COUNT(DISTINCT playerID) nos_of_player_produced
  FROM
    `Maven_Final_Project.schools`
  GROUP BY
    schoolID
  ORDER BY
    nos_of_player_produced DESC
  LIMIT
    5)
SELECT
  name_full,
  nos_of_player_produced
FROM
  `Maven_Final_Project.school_details` sd
JOIN
  cte_3
ON
  sd.schoolID = cte_3.schoolID
ORDER BY
  nos_of_player_produced DESC; 
  
  
-- 4. FOR each decade, what were the names OF the top 3 schools that produced the most players?
SELECT
  *
FROM
  `Maven_Final_Project.schools`;
WITH
  cte_4 AS (
  SELECT
    yearID,
    schoolID,
    COUNT(DISTINCT playerID)players_count,
    CAST(FLOOR(yearID/10)*10 AS int64) decade
  FROM
    `Maven_Final_Project.schools`
  GROUP BY
    yearID,
    schoolID
  ORDER BY
    yearID),
  cte_4_1 AS (
  SELECT
    cte_4.decade,
    schoolID,
    SUM(cte_4.players_count) no_of_players_per_dec
  FROM
    cte_4
  GROUP BY
    cte_4.decade,
    schoolID
  ORDER BY
    cte_4.decade),
  cte_4_F AS (
  SELECT
    *
  FROM (
    SELECT
      decade,
      schoolID,
      no_of_players_per_dec,
      ROW_NUMBER() OVER(PARTITION BY cte_4_1.decade ORDER BY cte_4_1.no_of_players_per_dec DESC) ranks
    FROM
      cte_4_1)
  WHERE
    ranks <= 3)
SELECT
  cte_4_F.decade,
  name_full,
  cte_4_F.no_of_players_per_dec
FROM
  cte_4_F
JOIN
  `Maven_Final_Project.school_details` sd
ON
  sd.schoolID = cte_4_F.schoolID; 
  
  
-- PART II: SALARY ANALYSIS 
-- 1. VIEW the salaries TABLE
SELECT
  *
FROM
  `Maven_Final_Project.salaries`; 
  
  
-- 2. Return the top 20% OF teams IN terms OF average annual spending
WITH
  cte_2II AS (
  SELECT
    teamID,
    ROUND(AVG(salary),1) annual_salary
  FROM
    `Maven_Final_Project.salaries`
  GROUP BY
    teamID
  ORDER BY
    annual_salary DESC)
SELECT
  teamID AS top_20,
  annual_salary
FROM (
  SELECT
    *,
    NTILE(5) OVER(ORDER BY cte_2II.annual_salary DESC) distribution
  FROM
    cte_2II
  ORDER BY
    cte_2II.annual_salary DESC)
WHERE
  distribution = 1; 
  
  
--3. FOR each team,show the cumulative sum OF spending OVER the years
SELECT
  *
FROM
  `Maven_Final_Project.salaries`;
SELECT
  DISTINCT yearID years
FROM
  `Maven_Final_Project.salaries`
ORDER BY
  years;
WITH
  cte_3II AS (
  SELECT
    yearID,
    teamID,
    SUM(salary) sum_sal
  FROM
    `Maven_Final_Project.salaries`
  GROUP BY
    yearID,
    teamID
  ORDER BY
    teamID,
    yearID)
SELECT
  *,
  SUM(sum_sal) OVER(PARTITION BY teamID ORDER BY teamID, yearID) cum
FROM
  cte_3II; 
  
  
-- 4. Return the FIRST year that each team's cumulative spending surpassed 1 billion
WITH
  cte_4II AS (
  SELECT
    yearID,
    teamID,
    SUM(salary) sum_sal
  FROM
    `Maven_Final_Project.salaries`
  GROUP BY
    yearID,
    teamID
  ORDER BY
    teamID,
    yearID),
  cte_4_1_II AS (
  SELECT
    *,
    SUM(sum_sal) OVER(PARTITION BY teamID ORDER BY teamID, yearID) cum
  FROM
    cte_4II)
SELECT
  *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY yearID) minn
  FROM (
    SELECT
      *,
      CASE
        WHEN cum > 1000000000 THEN 1
        ELSE 0
    END
      billion
    FROM
      cte_4_1_II)
  WHERE
    billion = 1)
WHERE
  minn = 1
ORDER BY
  teamID; 
  
  
-- PART III: PLAYER CAREER ANALYSIS 
-- 1. VIEW the players TABLE AND find the number OF players IN the TABLE
SELECT
  *
FROM
  `Maven_Final_Project.players`;
SELECT
  *
FROM
  `Maven_Final_Project.players_updated`;
SELECT
  MIN(birthYear),
  MAX(birthYear)
FROM
  `Maven_Final_Project.players`;
SELECT
  COUNT(DISTINCT playerID)
FROM
  `Maven_Final_Project.players`;
CREATE OR REPLACE VIEW
  `Maven_Final_Project.players_updates` AS
SELECT
  *,
-- 1. Remove the LAST 6 characters (' 00:00'). 
-- 2. Use SAFE_CAST TO convert the resulting string TO a DATE type. 
  SAFE_CAST(SUBSTR(t1.debut, 1, LENGTH(t1.debut) - 6) AS DATE) AS debut_date,
  SAFE_CAST(SUBSTR(t1.finalGame, 1, LENGTH(t1.finalGame) - 6) AS DATE) AS finalGame_date,
FROM
  `Maven_Final_Project.players_updated` AS t1;
SELECT
  *
FROM
  `Maven_Final_Project.players_updates`; 
  
  
-- 2. FOR each player,calculate their age AT their FIRST game,their LAST game,AND their career length (ALL IN years). Sort FROM longest career TO shortest career.
WITH
  years AS (
  SELECT
    playerID,
    nameGiven,
    SAFE_CAST(CONCAT(birthYear,"-",birthMonth,"-",birthDay) AS date) birthday,
    debut_date,
    finalGame_date
  FROM
    `Maven_Final_Project.players_updates`)
SELECT
  playerID,
  nameGiven,
  (EXTRACT(year
    FROM (debut_date)) - EXTRACT(year
    FROM
      years.birthday)) debut_age,
  (EXTRACT (year
    FROM (finalGame_date)) - EXTRACT (year
    FROM (years.birthday))) lastGame_age,
  (EXTRACT (year
    FROM (finalGame_date)) - EXTRACT (year
    FROM (debut_date))) career_lenght
FROM
  years
ORDER BY
  career_lenght DESC; 
  
  
-- 3. What team did each player play ON FOR their starting AND ending years?
WITH
  cte_3_main AS (
  WITH
    cte_3II AS (
    SELECT
      pu.playerID,
      nameGiven,
      debut_date,
      finalGame_date,
      yearID,
      teamID,
      ROW_NUMBER() OVER(PARTITION BY pu.playerID ORDER BY yearID) teams_follow
    FROM
      `Maven_Final_Project.players_updates` pu
    JOIN
      `Maven_Final_Project.salaries` s
    ON
      s.playerID = pu.playerID
    ORDER BY
      pu.playerID,
      yearID),
    ranked_data AS (
    SELECT
      *,
      MAX(teams_follow) OVER(PARTITION BY cte_3II.playerID) maxs,
      MIN(teams_follow) OVER(PARTITION BY cte_3II.playerID) mins
    FROM
      cte_3II)
  SELECT
    * EXCEPT(teams_follow,
      maxs,
      mins),
    CASE
      WHEN teams_follow = mins THEN 'Start'
      WHEN teams_follow = maxs THEN 'End'
  END
    AS pivot_col
  FROM
    ranked_data
  WHERE
    ranked_data.teams_follow = maxs
    OR ranked_data.teams_follow = mins)
SELECT
  *
FROM
  cte_3_main
PIVOT
  ( ANY_VALUE(yearID) AS Year,
    ANY_VALUE(teamID) AS Team FOR pivot_col IN ('Start',
      'End') )
ORDER BY
  playerID; 
  
  
-- 4. How many players started AND ended ON the same team AND also played FOR OVER a decade?
WITH
  cte_3_main AS (
  WITH
    cte_3II AS (
    SELECT
      pu.playerID,
      nameGiven,
      yearID,
      teamID,
      ROW_NUMBER() OVER(PARTITION BY pu.playerID ORDER BY yearID) teams_follow
    FROM
      `Maven_Final_Project.players_updates` pu
    JOIN
      `Maven_Final_Project.salaries` s
    ON
      s.playerID = pu.playerID
    ORDER BY
      pu.playerID,
      yearID),
    ranked_data AS (
    SELECT
      *,
      MAX(teams_follow) OVER(PARTITION BY cte_3II.playerID) maxs,
      MIN(teams_follow) OVER(PARTITION BY cte_3II.playerID) mins
    FROM
      cte_3II)
  SELECT
    * EXCEPT(teams_follow,
      maxs,
      mins),
    CASE
      WHEN teams_follow = mins THEN 'Start'
      WHEN teams_follow = maxs THEN 'End'
  END
    AS pivot_col
  FROM
    ranked_data
  WHERE
    ranked_data.teams_follow = maxs
    OR ranked_data.teams_follow = mins),
  cte_4_m AS (
  SELECT
    *
  FROM
    cte_3_main
  PIVOT
    ( ANY_VALUE(yearID) AS Year,
      ANY_VALUE(teamID) AS Team FOR pivot_col IN ('Start',
        'End') )
  ORDER BY
    playerID)
SELECT
  *
FROM
  cte_4_m
WHERE
  Team_Start = Team_End
  AND (Year_End - Year_Start) > 10; 
  
  
-- PART IV: PLAYER COMPARISON ANALYSIS 
-- 1. VIEW the players TABLE
SELECT
  *
FROM
  `Maven_Final_Project.players_updates`; 
  
  
-- 2. Which players have the same birthday?
WITH
  cte_birthdate AS (
  SELECT
    playerID,
    nameGiven,
    SAFE_CAST(CONCAT(birthYear,"-",birthMonth,"-",birthDay) AS date) birthdate,
  FROM
    `Maven_Final_Project.players_updates`
  WHERE
    birthday IS NOT NULL
  ORDER BY
    birthDay DESC)
SELECT
  pu1.playerID,
  pu1.nameGiven,
  pu1.birthdate,
  pu2.playerID,
  pu2.nameGiven,
  pu2.birthdate
FROM
  cte_birthdate pu1
JOIN
  cte_birthdate pu2
ON
  pu1.birthdate = pu2.birthdate
WHERE
  pu1.nameGiven <> pu2.nameGiven
  AND pu1.playerID < pu2.playerID
ORDER BY
  pu1.birthdate DESC; 
  
  
-- 3. CREATE a summary TABLE that shows FOR each team, what percent OF players bat RIGHT, LEFT AND both
SELECT
  teamID,
  COUNT(bats) total_bats,
  COUNTIF(bats = "L")L,
  COUNTIF(bats = "R")R,
  COUNTIF(bats = "B")B,
  ROUND((COUNTIF(bats = "L")/COUNT(bats))*100,2)L_per,
  ROUND((COUNTIF(bats = "R")/COUNT(bats))*100,2)R_per,
  ROUND((COUNTIF(bats = "B")/COUNT(bats))*100,2)B_per
FROM
  `Maven_Final_Project.players_updates` pu
JOIN
  `Maven_Final_Project.salaries` s
ON
  s.playerID = pu.playerID
GROUP BY
  teamID; 
  
  
-- 4. How have average height AND weight AT debut game changed OVER the years, AND what's the decade-over-decade difference?
WITH
  cte_hw AS (
  SELECT
    EXTRACT(year
    FROM
      debut_date) years,
    ROUND(AVG(height),2) avg_height,
    ROUND(AVG(weight),2) avg_weight
  FROM
    `Maven_Final_Project.players_updates`
  WHERE
    EXTRACT(year
    FROM
      debut_date) IS NOT NULL
  GROUP BY
    years
  ORDER BY
    years)
SELECT
  CAST(FLOOR(years/10)*10 AS int64) decade,
  ROUND(AVG(avg_height),2) dec_avg_height,
  ROUND(AVG(avg_weight),2) dec_avg_weight
FROM
  cte_hw
GROUP BY
  decade
ORDER BY
  decade
  ---------------------------------------------------------Thank you!-----------------------------------------------------