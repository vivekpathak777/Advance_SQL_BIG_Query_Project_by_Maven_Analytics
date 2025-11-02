# 🧠 Maven Final SQL Project — Advanced SQL Querying Techniques

### 🚀 About the Project
This repository contains my hands-on SQL project completed as part of the **“Advanced SQL Querying Techniques”** course by [Maven Analytics](https://www.mavenanalytics.io/), hosted on Udemy.  
The goal of this project was to explore advanced SQL concepts and apply them using **Google BigQuery** on real-world datasets.

---

## 💻 Platform & Tools
- **Cloud Platform:** Google BigQuery ☁️  
- **Language:** SQL (Standard SQL Syntax)  
- **Course Provider:** Maven Analytics 🎓  
- **Editor Features Used:** Auto-formatting, query history, built-in BigQuery functions like `COUNTIF()`, `SAFE_CAST()`, and `EXTRACT()`  

---

## 📚 Concepts Covered
Throughout this project, I explored several advanced SQL techniques including:
- 🧩 **Subqueries & Nested Logic**
- 🔁 **Common Table Expressions (CTEs)**
- 🪜 **Recursive CTEs**
- 🪞 **Self Joins**
- 📊 **Window Functions** (`RANK`, `ROW_NUMBER`, `LEAD`, `LAG`)
- 🔄 **Rolling Calculations**
- 📈 **Statistical Functions**
- ⚙️ **Pivot & Unpivot Operations**
- 📅 **Date & Time Handling**
- 🧮 **Aggregations & Analytical Reporting**

---

## 🧩 Project Structure

### **PART I: SCHOOL ANALYSIS**
- View and explore the `schools` and `school_details` tables  
- Find how many schools produced players per decade  
- Identify the top 5 schools producing the most players  
- Get the top 3 schools per decade with the highest player production  

### **PART II: SALARY ANALYSIS**
- Explore team salary data  
- Determine the top 20% of teams based on average annual spending  
- Calculate the cumulative sum of salary spending per team  
- Identify the first year each team’s spending surpassed $1 billion 💰  

### **PART III: PLAYER CAREER ANALYSIS**
- Calculate player age at debut, final game, and overall career length  
- Determine each player’s starting and ending teams  
- Find players who started and ended on the same team with careers over 10 years  

### **PART IV: PLAYER COMPARISON ANALYSIS**
- Identify players sharing the same birthdays 🎂  
- Compare the percentage of players batting Left (L), Right (R), or Both (B)  
- Analyze average height and weight trends per decade  

---

## 🧮 Example Query
Here’s one of the queries from **Salary Analysis**:

```sql
-- For each team, show the cumulative sum of spending over the years
WITH cte_3II AS (
  SELECT
    yearID,
    teamID,
    SUM(salary) AS sum_sal
  FROM
    `Maven_Final_Project.salaries`
  GROUP BY
    yearID, teamID
  ORDER BY
    teamID, yearID
)
SELECT
  *,
  SUM(sum_sal) OVER(PARTITION BY teamID ORDER BY teamID, yearID) AS cum
FROM
  cte_3II;
