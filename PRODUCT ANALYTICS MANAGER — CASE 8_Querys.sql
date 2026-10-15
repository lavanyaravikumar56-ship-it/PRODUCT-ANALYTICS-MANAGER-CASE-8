create database project2;
use project2;
#1

USE project2;

SELECT
    c.customer_id,
    c.channel,
    s.total_sessions,
    o.total_orders,
    o.total_gmv,
    p.total_promo_discount,
    r.active_months
FROM customer1 c

LEFT JOIN (
    SELECT
        customer_id,
        COUNT(*) AS total_sessions
    FROM sessions
    GROUP BY customer_id
) s
    ON c.customer_id = s.customer_id

LEFT JOIN (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(gmv) AS total_gmv
    FROM orders1
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id

LEFT JOIN (
    SELECT
        customer_id,
        SUM(discount) AS total_promo_discount
    FROM promo_usage
    GROUP BY customer_id
) p
    ON c.customer_id = p.customer_id

LEFT JOIN (
    SELECT
        customer_id,
        SUM(active) AS active_months
    FROM retention
    GROUP BY customer_id
) r
    ON c.customer_id = r.customer_id;
    
DESCRIBE customer1;

ALTER TABLE customer1
CHANGE `ï»¿customer_id` customer_id TEXT;

DESCRIBE customer1;

#2
DESCRIBE orders1;

ALTER TABLE orders1
CHANGE `ï»¿order_id` order_id TEXT;

WITH order_classified AS (
    SELECT
        order_id,
        customer_id,
        source,
        gmv,
        discount,
        margin,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_id
        ) AS order_number
    FROM orders1
)
SELECT
    CASE
        WHEN order_number = 1 THEN 'First Order'
        ELSE 'Repeat Order'
    END AS order_type,
    COUNT(*) AS total_orders,
    SUM(gmv) AS total_gmv,
    SUM(discount) AS total_discount,
    SUM(gmv * margin) AS contribution
FROM order_classified
GROUP BY
    CASE
        WHEN order_number = 1 THEN 'First Order'
        ELSE 'Repeat Order'
    END;
    
#3
DESCRIBE marketing_campaign;
SHOW TABLES;
DESCRIBE marketing_campaings;
ALTER TABLE marketing_campaings
CHANGE `ï»¿campaign_id` campaign_id TEXT;
SELECT
    campaign_id,
    channel,
    budget,
    target_roas,
    RANK() OVER (
        ORDER BY budget DESC
    ) AS budget_rank
FROM marketing_campaings
WHERE campaign_id IS NOT NULL
ORDER BY budget_rank;

SELECT
    campaign_id,
    channel,
    budget,
    RANK() OVER (ORDER BY budget DESC) AS budget_rank,
    SUM(budget) OVER (
        ORDER BY budget DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_budget
FROM marketing_campaings
WHERE campaign_id IS NOT NULL
ORDER BY budget_rank;

WITH channel_budget AS (
    SELECT
        channel,
        SUM(budget) AS total_budget
    FROM marketing_campaings
    GROUP BY channel
)
SELECT
    channel,
    total_budget,
    RANK() OVER (
        ORDER BY total_budget DESC
    ) AS channel_rank,
    SUM(total_budget) OVER (
        ORDER BY total_budget DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_budget
FROM channel_budget
ORDER BY channel_rank;

#4
SELECT
    channel,
    COUNT(*) AS customer_count
FROM customer1
GROUP BY channel
ORDER BY customer_count DESC;

SELECT
    channel AS first_touch_channel,
    COUNT(*) AS customers
FROM customer1
GROUP BY channel
ORDER BY customers DESC;

DESCRIBE sessions;

SELECT
    source AS last_observed_touch,
    COUNT(DISTINCT customer_id) AS customers
FROM sessions
WHERE customer_id IS NOT NULL
GROUP BY source
ORDER BY customers DESC;

WITH first_touch AS (
    SELECT
        channel AS touch_channel,
        COUNT(*) AS first_touch_customers
    FROM customer1
    GROUP BY channel
),
last_touch AS (
    SELECT
        source AS touch_channel,
        COUNT(DISTINCT customer_id) AS last_touch_customers
    FROM sessions
    WHERE customer_id IS NOT NULL
    GROUP BY source
)
SELECT
    COALESCE(f.touch_channel, l.touch_channel) AS channel,
    COALESCE(f.first_touch_customers, 0) AS first_touch_customers,
    COALESCE(l.last_touch_customers, 0) AS last_touch_customers
FROM first_touch f
LEFT JOIN last_touch l
    ON f.touch_channel = l.touch_channel

UNION

SELECT
    l.touch_channel AS channel,
    COALESCE(f.first_touch_customers, 0) AS first_touch_customers,
    l.last_touch_customers
FROM last_touch l
LEFT JOIN first_touch f
    ON f.touch_channel = l.touch_channel
WHERE f.touch_channel IS NULL

ORDER BY first_touch_customers DESC;

WITH first_touch AS (
    SELECT
        channel,
        COUNT(*) AS first_touch_customers
    FROM customer1
    GROUP BY channel
),
last_touch AS (
    SELECT
        source AS channel,
        COUNT(DISTINCT customer_id) AS last_touch_customers
    FROM sessions
    WHERE customer_id IS NOT NULL
    GROUP BY source
)
SELECT
    COALESCE(f.channel, l.channel) AS channel,
    COALESCE(f.first_touch_customers, 0) AS first_touch_customers,
    COALESCE(l.last_touch_customers, 0) AS last_touch_customers,
    (
        COALESCE(f.first_touch_customers, 0) * 0.5
        +
        COALESCE(l.last_touch_customers, 0) * 0.5
    ) AS multi_touch_attribution
FROM first_touch f
LEFT JOIN last_touch l
    ON f.channel = l.channel

UNION

SELECT
    l.channel,
    COALESCE(f.first_touch_customers, 0),
    l.last_touch_customers,
    (
        COALESCE(f.first_touch_customers, 0) * 0.5
        +
        COALESCE(l.last_touch_customers, 0) * 0.5
    )
FROM last_touch l
LEFT JOIN first_touch f
    ON f.channel = l.channel
WHERE f.channel IS NULL

ORDER BY multi_touch_attribution DESC;

#5
DESCRIBE marketing_spend;

SELECT
    date,
    campaign_id,
    spend,
    conversions
FROM marketing_spend
LIMIT 10;

SELECT
    DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS month,
    SUM(spend) AS total_spend,
    SUM(conversions) AS total_conversions
FROM marketing_spend
WHERE spend IS NOT NULL
GROUP BY DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'), '%Y-%m')
ORDER BY month;

WITH monthly AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m'
        ) AS month,
        SUM(spend) AS total_spend,
        SUM(conversions) AS total_conversions
    FROM marketing_spend
    WHERE spend IS NOT NULL
      AND date IS NOT NULL
    GROUP BY DATE_FORMAT(
        STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'),
        '%Y-%m'
    )
),
growth AS (
    SELECT
        month,
        total_spend,
        total_conversions,
        LAG(total_spend) OVER (ORDER BY month) AS previous_spend,
        LAG(total_conversions) OVER (ORDER BY month) AS previous_conversions
    FROM monthly
)
SELECT
    month,
    ROUND(total_spend, 2) AS total_spend,
    total_conversions,
    ROUND(
        (total_spend - previous_spend) / previous_spend * 100,
        2
    ) AS spend_growth_pct,
    ROUND(
        (total_conversions - previous_conversions)
        / previous_conversions * 100,
        2
    ) AS conversion_growth_pct
FROM growth
WHERE previous_spend IS NOT NULL
ORDER BY month;

SELECT
    campaign_id,
    SUM(spend) AS total_spend,
    SUM(conversions) AS total_conversions
FROM marketing_spend
WHERE campaign_id IS NOT NULL
GROUP BY campaign_id
ORDER BY total_spend DESC
LIMIT 20;

WITH monthly_campaign AS (
    SELECT
        campaign_id,
        DATE_FORMAT(
            STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m'
        ) AS month,
        SUM(spend) AS monthly_spend,
        SUM(conversions) AS monthly_conversions
    FROM marketing_spend
    WHERE campaign_id IS NOT NULL
      AND date IS NOT NULL
    GROUP BY
        campaign_id,
        DATE_FORMAT(
            STR_TO_DATE(date, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m'
        )
),
growth AS (
    SELECT
        campaign_id,
        month,
        monthly_spend,
        monthly_conversions,
        LAG(monthly_spend) OVER (
            PARTITION BY campaign_id
            ORDER BY month
        ) AS previous_spend,
        LAG(monthly_conversions) OVER (
            PARTITION BY campaign_id
            ORDER BY month
        ) AS previous_conversions
    FROM monthly_campaign
)
SELECT
    campaign_id,
    month,
    ROUND(monthly_spend, 2) AS monthly_spend,
    monthly_conversions,
    ROUND(
        (monthly_spend - previous_spend)
        / previous_spend * 100,
        2
    ) AS spend_growth_pct,
    ROUND(
        (monthly_conversions - previous_conversions)
        / previous_conversions * 100,
        2
    ) AS conversion_growth_pct
FROM growth
WHERE previous_spend IS NOT NULL
  AND previous_conversions IS NOT NULL
  AND monthly_spend > previous_spend
  AND monthly_conversions < previous_conversions
ORDER BY
    (spend_growth_pct - conversion_growth_pct) DESC
LIMIT 20;

DESCRIBE delivery_cx;
SHOW TABLES;
DESCRIBE orders1;
DESCRIBE sessions;
DESCRIBE retention;
DESCRIBE promo_usage;
DESCRIBE customer1;
DESCRIBE marketing_spend;
DESCRIBE marketing_campaings;

SELECT
    c.customer_id,
    c.channel,
    c.segment,
    c.city,
    COUNT(DISTINCT s.session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.gmv) AS total_gmv,
    SUM(o.Contribution) AS total_contribution,
    SUM(p.discount) AS total_promo_discount,
    COUNT(DISTINCT r.retention_id) AS retention_records
FROM customer1 c
LEFT JOIN sessions s
    ON c.customer_id = s.customer_id
LEFT JOIN orders1 o
    ON c.customer_id = o.customer_id
LEFT JOIN promo_usage p
    ON o.order_id = p.order_id
LEFT JOIN retention r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.channel,
    c.segment,
    c.city;
   
SELECT
    c.customer_id,
    c.channel,
    c.segment,
    c.city,
    COUNT(DISTINCT s.`ï»¿session_id`) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(DISTINCT o.gmv) AS total_gmv,
    SUM(DISTINCT o.Contribution) AS total_contribution,
    SUM(DISTINCT p.discount) AS total_promo_discount,
    COUNT(DISTINCT r.`ï»¿retention_id`) AS retention_records
FROM customer1 c
LEFT JOIN sessions s
    ON c.customer_id = s.customer_id
LEFT JOIN orders1 o
    ON c.customer_id = o.customer_id
LEFT JOIN promo_usage p
    ON o.order_id = p.order_id
LEFT JOIN retention r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.channel,
    c.segment,
    c.city;  
  
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(gmv) AS total_gmv,
    SUM(Contribution) AS total_contribution
FROM orders1
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 10;  

WITH order_rank AS (
    SELECT
        customer_id,
        order_id,
        gmv,
        Contribution,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_id
        ) AS order_number
    FROM orders1
),
order_economics AS (
    SELECT
        CASE
            WHEN order_number = 1 THEN 'First Order'
            ELSE 'Repeat Order'
        END AS order_type,
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(gmv) AS total_gmv,
        SUM(Contribution) AS total_contribution
    FROM order_rank
    GROUP BY
        CASE
            WHEN order_number = 1 THEN 'First Order'
            ELSE 'Repeat Order'
        END
)
SELECT *
FROM order_economics
ORDER BY order_type;

WITH campaign_performance AS (
    SELECT
        m.campaign_id,
        c.channel,
        SUM(m.spend) AS total_spend,
        SUM(m.conversions) AS total_conversions,
        AVG(m.clicks) AS avg_clicks
    FROM marketing_spend m
    LEFT JOIN marketing_campaings c
        ON m.campaign_id = c.campaign_id
    GROUP BY
        m.campaign_id,
        c.channel
)
SELECT
    campaign_id,
    channel,
    total_spend,
    total_conversions,
    RANK() OVER (
        ORDER BY total_conversions DESC
    ) AS campaign_rank
FROM campaign_performance
ORDER BY campaign_rank;

WITH channel_contribution AS (
    SELECT
        c.channel,
        SUM(m.spend) AS total_spend,
        SUM(m.conversions) AS total_conversions
    FROM marketing_spend m
    LEFT JOIN marketing_campaings c
        ON m.campaign_id = c.campaign_id
    GROUP BY c.channel
)
SELECT
    channel,
    total_spend,
    total_conversions,
    SUM(total_conversions) OVER (
        ORDER BY total_conversions DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_conversions
FROM channel_contribution
ORDER BY total_conversions DESC;

WITH customer_touchpoints AS (
    SELECT
        customer_id,
        source,
        engagement,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY engagement DESC
        ) AS touch_rank
    FROM sessions
),
attribution AS (
    SELECT
        customer_id,
        MAX(CASE WHEN touch_rank = 1 THEN source END) AS first_touch,
        MAX(CASE WHEN touch_rank = 1 THEN source END) AS last_touch,
        COUNT(*) AS touchpoints
    FROM customer_touchpoints
    GROUP BY customer_id
)
SELECT
    first_touch,
    last_touch,
    COUNT(DISTINCT customer_id) AS customers,
    AVG(touchpoints) AS avg_touchpoints
FROM attribution
GROUP BY first_touch, last_touch
ORDER BY customers DESC;

WITH monthly_campaign AS (
    SELECT
        campaign_id,
        DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d'), '%Y-%m') AS month,
        SUM(spend) AS total_spend,
        SUM(conversions) AS total_conversions
    FROM marketing_spend
    GROUP BY campaign_id, month
),
growth AS (
    SELECT
        campaign_id,
        month,
        total_spend,
        total_conversions,
        LAG(total_spend) OVER (
            PARTITION BY campaign_id
            ORDER BY month
        ) AS previous_spend,
        LAG(total_conversions) OVER (
            PARTITION BY campaign_id
            ORDER BY month
        ) AS previous_conversions
    FROM monthly_campaign
),
growth_rates AS (
    SELECT
        campaign_id,
        month,
        total_spend,
        total_conversions,
        previous_spend,
        previous_conversions,
        (total_spend - previous_spend)
            / NULLIF(previous_spend, 0) AS spend_growth_rate,
        (total_conversions - previous_conversions)
            / NULLIF(previous_conversions, 0) AS conversion_growth_rate
    FROM growth
)
SELECT
    campaign_id,
    month,
    total_spend,
    total_conversions,
    spend_growth_rate,
    conversion_growth_rate
FROM growth_rates
WHERE previous_spend IS NOT NULL
  AND previous_conversions IS NOT NULL
  AND spend_growth_rate > conversion_growth_rate
ORDER BY spend_growth_rate DESC;