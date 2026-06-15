# IPL Match Analysis

An end-to-end data analytics project analysing **15+ IPL seasons** across **1,095 matches** and **260,920 ball-by-ball deliveries** — using Python, MySQL, and Power BI to uncover win patterns, player performance trends, and toss impact insights.

---

## Project Overview

The Indian Premier League generates one of the richest sports datasets in the world. This project builds a complete data pipeline — from raw CSV ingestion to interactive dashboard — to answer key cricket analytics questions:

- Which teams win the most and why?
- Does winning the toss actually help?
- Who are the best batsmen, bowlers, and all-round performers across all seasons?
- Which venues favour batting or bowling?

---

## Key Findings

| Insight | Finding |
|---|---|
| Toss + Field first win % | **53.55%** — chasing is statistically superior in modern IPL |
| Top run scorer (all time) | Identified via RANK() window function across all seasons |
| Top wicket taker (all time) | Filtered for valid dismissals (excl. run outs, retired hurt) |
| Most matches hosted | Top 10 venues ranked by matches hosted |
| Most economical bowler | Minimum 20 overs (120 balls) threshold applied for fairness |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| **Python** | Data ingestion, cleaning, EDA, visualisation |
| **Pandas** | Data manipulation and transformation |
| **Matplotlib** | Charts and visualisations |
| **MySQL** | Relational querying and aggregation |
| **SQLAlchemy** | Python-MySQL connection via engine |
| **Power BI** | Interactive dashboard with season slicer |

---

## Project Structure

```
IPL-Match-Analysis/
│
├── I_M_A.ipynb              # Main analysis notebook (EDA + SQL + visualisations)
├── queries.sql              # All 16 SQL queries (documented)
├── matches.csv              # Match-level dataset (1,095 matches)
├── deliveries.csv           # Ball-by-ball dataset (260,920 deliveries)
│
├── top_batsmen.png          # Top 10 batsmen by total runs
├── top_bowlers.png          # Top 10 bowlers by wickets
├── top_venues.png           # Top 10 venues by matches hosted
├── team_win_pct.png         # Team win percentage chart
└── season_matches.png       # Matches per season trend
```

---

## Dataset

| File | Records | Description |
|---|---|---|
| `matches.csv` | 1,095 rows | Match-level data: season, teams, toss, result, venue |
| `deliveries.csv` | 260,920 rows | Ball-by-ball data: batsman runs, bowler, extras, wickets |

---

## SQL Queries (16 Total)

All queries are run from Python using `pd.read_sql()` via SQLAlchemy engine.

| # | Query | Concept Used |
|---|---|---|
| 1 | Total matches per season | GROUP BY, COUNT |
| 2 | Top 10 teams by wins | GROUP BY, ORDER BY, LIMIT |
| 3 | Toss decision impact on match result | CASE WHEN, aggregation |
| 4 | Top 10 batsmen by total runs | SUM, GROUP BY |
| 5 | Top 10 bowlers by wickets | WHERE with NOT IN filter |
| 6 | Top 10 venues by matches hosted | COUNT, GROUP BY |
| 7 | Top Man of the Match winners | COUNT, GROUP BY |
| 8 | Highest team scores in a match | SUM, GROUP BY on match + team |
| 9 | Most sixes by a batsman | WHERE filter, COUNT |
| 10 | Most fours by a batsman | WHERE filter, COUNT |
| 11 | Average score per season | AVG, JOIN, GROUP BY |
| 12 | Win % by batting vs fielding first | CASE WHEN, ROUND, GROUP BY |
| 13 | Most economical bowlers (min 20 overs) | Economy formula, HAVING |
| 14 | Most Player of the Match awards | COUNT, GROUP BY |
| 15 | **Season-wise top run scorer** | **RANK() WINDOW FUNCTION** |
| 16 | **Season-wise top wicket taker** | **RANK() WINDOW FUNCTION** |

---

##  Window Function Highlight

Queries 15 and 16 use `RANK() OVER (PARTITION BY season ORDER BY ...)` to find the **top performer for every season in a single query** — instead of running 15 separate queries.

```sql
-- Season-wise top run scorer
SELECT season, batter, total_runs
FROM (
    SELECT m.season, d.batter,
           SUM(d.batsman_runs) AS total_runs,
           RANK() OVER (PARTITION BY m.season ORDER BY SUM(d.batsman_runs) DESC) AS rnk
    FROM deliveries d
    JOIN matches m ON d.match_id = m.id
    GROUP BY m.season, d.batter
) ranked
WHERE rnk = 1
ORDER BY season;
```

---

## How to Run

### 1. Clone the repository
```bash
git clone https://github.com/Prajjawal-kumar/IPL-Match-Analysis.git
cd IPL-Match-Analysis
```

### 2. Install dependencies
```bash
pip install pandas numpy matplotlib sqlalchemy pymysql jupyter
```

### 3. Set up MySQL
```sql
CREATE DATABASE ipl_analysis;
```

### 4. Update connection string in notebook
```python
from sqlalchemy import create_engine
engine = create_engine("mysql+pymysql://username:password@localhost/ipl_analysis")
```

### 5. Run the notebook
```bash
jupyter notebook I_M_A.ipynb
```

---

## Visualisations

| Chart | Description |
|---|---|
| `top_batsmen.png` | Horizontal bar chart — top 10 run scorers of all time |
| `top_bowlers.png` | Horizontal bar chart — top 10 wicket takers (valid dismissals only) |
| `top_venues.png` | Bar chart — most matches hosted per venue |
| `team_win_pct.png` | Bar chart — team win counts across all seasons |
| `season_matches.png` | Line chart — number of matches per IPL season |

---

## Business Insights

1. **Toss Strategy** — Teams winning the toss and choosing to field first win 53.55% of matches, confirming chasing is the dominant modern T20 strategy.
2. **Venue Impact** — Certain venues consistently host more matches and show batting/bowling trends worth accounting for in team selection.
3. **Economy Rate** — A minimum 120-ball threshold is applied to economy rankings to avoid bias from low-sample bowlers.
4. **Season Trends** — Visualising matches per season shows how the IPL has evolved from 58 matches in 2008 to 74+ in recent seasons.

---

## 🚀 Future Scope

- Add **scikit-learn** classification model to predict match winner based on toss, venue, and team composition
- Build **K-Means clustering** to group player performance profiles
- Deploy as an interactive **Streamlit web app**
- Add **2024 and 2025 IPL season data** for updated analysis
