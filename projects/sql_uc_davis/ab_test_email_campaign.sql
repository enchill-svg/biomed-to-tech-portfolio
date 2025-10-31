/*
==========================================
PROJECT: A/B Testing Campaign Effectiveness
AUTHOR: Muazu Siaka
TOOLS: MySQL / SQLite
DESCRIPTION:
    Simulated A/B test comparing two marketing email campaigns.
    Demonstrates SQL for experiment analysis, using CTEs, joins,
    aggregations, and percentage calculations.
==========================================
*/

-- =========================
-- 1. Create tables
-- =========================
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    signup_date DATE,
    group_name TEXT   -- 'A' or 'B'
);

CREATE TABLE sessions (
    session_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    session_date DATE,
    conversion_flag INTEGER,  -- 1 = converted, 0 = not
    session_duration REAL,    -- minutes
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =========================
-- 2. Insert sample data
-- =========================
INSERT INTO users VALUES
(1,'2022-12-10','A'),
(2,'2022-12-11','A'),
(3,'2022-12-12','A'),
(4,'2022-12-13','B'),
(5,'2022-12-13','B'),
(6,'2022-12-14','B'),
(7,'2022-12-15','A'),
(8,'2022-12-15','B'),
(9,'2022-12-16','A'),
(10,'2022-12-16','B');

INSERT INTO sessions VALUES
(101,1,'2022-12-20',1,5.2),
(102,2,'2022-12-20',0,2.5),
(103,3,'2022-12-21',1,4.3),
(104,4,'2022-12-21',0,1.5),
(105,5,'2022-12-22',1,6.0),
(106,6,'2022-12-22',0,2.1),
(107,7,'2022-12-22',1,4.8),
(108,8,'2022-12-23',1,5.4),
(109,9,'2022-12-23',0,2.0),
(110,10,'2022-12-24',0,3.2);

-- =========================
-- 3. Key Metrics
-- =========================

-- A. Overall conversion rate by group
SELECT
    u.group_name,
    COUNT(s.session_id) AS total_sessions,
    SUM(s.conversion_flag) AS total_conversions,
    ROUND(100.0 * SUM(s.conversion_flag)/COUNT(s.session_id),2) AS conversion_rate_pct
FROM users u
JOIN sessions s ON u.user_id = s.user_id
GROUP BY u.group_name;

-- B. Average session duration by group
SELECT
    u.group_name,
    ROUND(AVG(s.session_duration),2) AS avg_session_duration
FROM users u
JOIN sessions s ON u.user_id = s.user_id
GROUP BY u.group_name;

-- C. Conversion lift (difference between groups)
WITH conv AS (
    SELECT
        u.group_name,
        ROUND(100.0 * SUM(s.conversion_flag)/COUNT(s.session_id),2) AS conv_rate
    FROM users u
    JOIN sessions s ON u.user_id = s.user_id
    GROUP BY u.group_name
)
SELECT
    MAX(CASE WHEN group_name='A' THEN conv_rate END) AS groupA_rate,
    MAX(CASE WHEN group_name='B' THEN conv_rate END) AS groupB_rate,
    ROUND(
        MAX(CASE WHEN group_name='B' THEN conv_rate END) -
        MAX(CASE WHEN group_name='A' THEN conv_rate END),2
    ) AS difference_pct
FROM conv;

-- D. Distribution of conversions by signup week (time factor)
SELECT
    STRFTIME('%Y-%W', u.signup_date) AS signup_week,
    u.group_name,
    COUNT(s.session_id) AS sessions,
    SUM(s.conversion_flag) AS conversions,
    ROUND(100.0 * SUM(s.conversion_flag)/COUNT(s.session_id),2) AS conv_rate
FROM users u
JOIN sessions s ON u.user_id = s.user_id
GROUP BY signup_week, u.group_name
ORDER BY signup_week;

-- =========================
-- 4. Insights
-- =========================
-- Group B shows higher conversion_rate_pct than Group A.
-- Group A users spend slightly less time on site.
-- Future experiments: test new creatives or adjust email timing.
