# ── 1. TOTAL MATCHES PER SEASON ──────────────────────────────
pd.read_sql("""
    SELECT season, COUNT(*) AS total_matches
    FROM matches
    GROUP BY season
    ORDER BY season;
""", engine)

# ── 2. TEAM WIN PERCENTAGE ───────────────────────────────────
pd.read_sql("""
    SELECT winner, COUNT(*) AS wins
    FROM matches
    WHERE winner IS NOT NULL
    GROUP BY winner
    ORDER BY wins DESC
    LIMIT 10;
""", engine)

# ── 3. TOSS DECISION IMPACT ──────────────────────────────────
pd.read_sql("""
    SELECT toss_decision,
           COUNT(*) AS total,
           SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_won_match,
           ROUND(SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_pct
    FROM matches
    GROUP BY toss_decision;
""", engine)

# ── 4. TOP 10 BATSMEN BY RUNS ────────────────────────────────
pd.read_sql("""
    SELECT batter, SUM(batsman_runs) AS total_runs
    FROM deliveries
    GROUP BY batter
    ORDER BY total_runs DESC
    LIMIT 10;
""", engine)

# ── 5. TOP 10 BOWLERS BY WICKETS ─────────────────────────────
pd.read_sql("""
    SELECT bowler, COUNT(*) AS total_wickets
    FROM deliveries
    WHERE is_wicket = 1
    AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
    GROUP BY bowler
    ORDER BY total_wickets DESC
    LIMIT 10;
""", engine)

# ── 6. TOP 10 VENUES BY MATCHES HOSTED ──────────────────────
pd.read_sql("""
    SELECT venue, COUNT(*) AS matches_hosted
    FROM matches
    GROUP BY venue
    ORDER BY matches_hosted DESC
    LIMIT 10;
""", engine)

# ── 7. TOP MAN OF THE MATCH WINNERS ──────────────────────────
pd.read_sql("""
    SELECT player_of_match, COUNT(*) AS awards
    FROM matches
    WHERE player_of_match IS NOT NULL
    GROUP BY player_of_match
    ORDER BY awards DESC
    LIMIT 10;
""", engine)

# ── 8. HIGHEST TEAM SCORES IN A MATCH ────────────────────────
pd.read_sql("""
    SELECT match_id, batting_team, SUM(total_runs) AS total_score
    FROM deliveries
    WHERE inning = 1
    GROUP BY match_id, batting_team
    ORDER BY total_score DESC
    LIMIT 10;
""", engine)

# ── 9. MOST SIXES HIT BY A BATSMAN ───────────────────────────
pd.read_sql("""
    SELECT batter, COUNT(*) AS total_sixes
    FROM deliveries
    WHERE batsman_runs = 6
    GROUP BY batter
    ORDER BY total_sixes DESC
    LIMIT 10;
""", engine)

# ── 10. MOST FOURS HIT BY A BATSMAN ──────────────────────────
pd.read_sql("""
    SELECT batter, COUNT(*) AS total_fours
    FROM deliveries
    WHERE batsman_runs = 4
    GROUP BY batter
    ORDER BY total_fours DESC
    LIMIT 10;
""", engine)

# ── 11. AVERAGE SCORE PER SEASON ─────────────────────────────
pd.read_sql("""
    SELECT m.season,
           ROUND(AVG(d.total_runs), 2) AS avg_runs_per_ball,
           ROUND(SUM(d.total_runs) / COUNT(DISTINCT d.match_id), 2) AS avg_score_per_match
    FROM deliveries d
    JOIN matches m ON d.match_id = m.id
    GROUP BY m.season
    ORDER BY m.season;
""", engine)

# ── 12. WIN % BY BATTING OR FIELDING FIRST ───────────────────
pd.read_sql("""
    SELECT toss_decision,
           COUNT(*) AS total_matches,
           SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS wins,
           ROUND(SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_pct
    FROM matches
    WHERE result = 'runs' OR result = 'wickets'
    GROUP BY toss_decision;
""", engine)

# ── 13. MOST ECONOMICAL BOWLERS (MIN 20 OVERS) ───────────────
pd.read_sql("""
    SELECT bowler,
           ROUND(SUM(total_runs) * 1.0 / COUNT(*) * 6, 2) AS economy,
           COUNT(*) AS balls_bowled
    FROM deliveries
    WHERE extras_type != 'wides' OR extras_type IS NULL
    GROUP BY bowler
    HAVING balls_bowled >= 120
    ORDER BY economy ASC
    LIMIT 10;
""", engine)

# ── 14. PLAYER WITH MOST WINS AS CAPTAIN (PROXY: MOST MOM) ───
pd.read_sql("""
    SELECT player_of_match, COUNT(*) AS mom_awards
    FROM matches
    GROUP BY player_of_match
    ORDER BY mom_awards DESC
    LIMIT 10;
""", engine)

# ── 15. SEASON-WISE TOP RUN SCORER (WINDOW FUNCTION) ─────────
pd.read_sql("""
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
""", engine)

# ── 16. SEASON-WISE TOP WICKET TAKER (WINDOW FUNCTION) ───────
pd.read_sql("""
    SELECT season, bowler, total_wickets
    FROM (
        SELECT m.season, d.bowler,
               COUNT(*) AS total_wickets,
               RANK() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) AS rnk
        FROM deliveries d
        JOIN matches m ON d.match_id = m.id
        WHERE d.is_wicket = 1
        GROUP BY m.season, d.bowler
    ) ranked
    WHERE rnk = 1
    ORDER BY season;
""", engine)
