
  
    

    create or replace table `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
      
    
    

    OPTIONS()
    as (
      

-- Quick Ratio Analysis and Alert System
-- Tracks quick ratio trends across time periods and platforms
-- Provides early warning system for growth quality degradation

WITH base_growth_data AS (
    SELECT * FROM `heymax-interview`.`heymax_analytics`.`social_capital_growth_accounting`
),

-- Monthly quick ratio trends with moving averages
monthly_quick_ratio_trends AS (
    SELECT 
        activity_month,
        total_mau,
        new_users,
        retained_users,
        resurrected_users,
        churned_users,
        quick_ratio,
        growth_quality_category,
        retention_rate_pct,
        
        -- 3-month moving average quick ratio
        AVG(quick_ratio) OVER (
            ORDER BY activity_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as quick_ratio_3mo_avg,
        
        -- Previous month quick ratio for trend analysis
        LAG(quick_ratio) OVER (ORDER BY activity_month) as prev_month_quick_ratio,
        
        -- Quick ratio change
        quick_ratio - LAG(quick_ratio) OVER (ORDER BY activity_month) as quick_ratio_change,
        
        -- Months since data started (for growth stage analysis)
        ROW_NUMBER() OVER (ORDER BY activity_month) as months_since_start
    FROM base_growth_data
    WHERE activity_month IS NOT NULL
),

-- Platform-specific quick ratios (weekly analysis)
platform_weekly_analysis AS (
    SELECT 
        DATE_TRUNC(event_date, WEEK(MONDAY)) as week_start,
        platform,
        COUNT(DISTINCT user_id) as weekly_active_users,
        
        -- Calculate new vs returning users by platform
        COUNT(DISTINCT CASE 
            WHEN event_date = (
                SELECT MIN(event_date) 
                FROM `heymax-interview`.`heymax_analytics`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_users_platform,
        
        COUNT(DISTINCT CASE 
            WHEN event_date > (
                SELECT MIN(event_date) 
                FROM `heymax-interview`.`heymax_analytics`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as returning_users_platform
        
    FROM `heymax-interview`.`heymax_analytics`.`fct_events` f1
    GROUP BY week_start, platform
),

-- UTM source quick ratio analysis
utm_growth_quality AS (
    SELECT 
        DATE_TRUNC(event_date, MONTH) as activity_month,
        utm_source,
        COUNT(DISTINCT user_id) as monthly_active_users,
        
        -- New users by UTM source
        COUNT(DISTINCT CASE 
            WHEN event_date = (
                SELECT MIN(event_date) 
                FROM `heymax-interview`.`heymax_analytics`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_users_utm,
        
        -- User retention by UTM source (simplified)
        COUNT(DISTINCT CASE 
            WHEN event_date > (
                SELECT MIN(event_date) 
                FROM `heymax-interview`.`heymax_analytics`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as retained_users_utm
        
    FROM `heymax-interview`.`heymax_analytics`.`fct_events` f1
    WHERE utm_source IS NOT NULL
    GROUP BY activity_month, utm_source
),

-- Quick ratio alert conditions
quick_ratio_alerts AS (
    SELECT 
        activity_month,
        quick_ratio,
        prev_month_quick_ratio,
        quick_ratio_change,
        growth_quality_category,
        
        -- Alert flags
        CASE 
            WHEN quick_ratio < 1.0 THEN 'CRITICAL: Quick Ratio Below 1.0'
            WHEN quick_ratio < 1.2 AND prev_month_quick_ratio >= 1.2 THEN 'WARNING: Quick Ratio Dropped Below 1.2'
            WHEN quick_ratio_change < -0.3 THEN 'WARNING: Quick Ratio Declined >0.3 Points'
            WHEN churned_users > (new_users + resurrected_users) * 1.5 THEN 'WARNING: Churn Significantly Exceeding Growth'
            ELSE 'OK'
        END as alert_level,
        
        -- Growth quality score (0-100)
        CASE 
            WHEN quick_ratio IS NULL THEN NULL
            WHEN quick_ratio < 0.5 THEN 0
            WHEN quick_ratio >= 2.0 THEN 100
            ELSE ROUND(50 * quick_ratio, 0)
        END as growth_quality_score
        
    FROM monthly_quick_ratio_trends
),

-- Benchmark comparisons
growth_benchmarks AS (
    SELECT 
        activity_month,
        quick_ratio,
        retention_rate_pct,
        
        -- Consumer app benchmarks
        CASE 
            WHEN retention_rate_pct >= 80 THEN 'Excellent (80%+)'
            WHEN retention_rate_pct >= 60 THEN 'Good (60-80%)'
            WHEN retention_rate_pct >= 40 THEN 'Average (40-60%)'
            WHEN retention_rate_pct >= 20 THEN 'Below Average (20-40%)'
            ELSE 'Poor (<20%)'
        END as retention_benchmark,
        
        CASE 
            WHEN quick_ratio >= 2.0 THEN 'Top Tier (2.0+)'
            WHEN quick_ratio >= 1.5 THEN 'Strong (1.5-2.0)'
            WHEN quick_ratio >= 1.0 THEN 'Healthy (1.0-1.5)'
            WHEN quick_ratio >= 0.8 THEN 'Concerning (0.8-1.0)'
            ELSE 'Critical (<0.8)'
        END as quick_ratio_benchmark
        
    FROM monthly_quick_ratio_trends
)

-- Final output combining all analyses
SELECT 
    mqt.activity_month,
    mqt.total_mau,
    mqt.new_users,
    mqt.retained_users,
    mqt.resurrected_users,
    mqt.churned_users,
    
    -- Quick ratio metrics
    mqt.quick_ratio,
    mqt.quick_ratio_3mo_avg,
    mqt.quick_ratio_change,
    mqt.growth_quality_category,
    
    -- Alert system
    qra.alert_level,
    qra.growth_quality_score,
    
    -- Benchmarking
    gb.retention_benchmark,
    gb.quick_ratio_benchmark,
    
    -- Growth insights
    CASE 
        WHEN mqt.months_since_start <= 3 THEN 'Early Stage'
        WHEN mqt.months_since_start <= 12 THEN 'Growth Stage'
        ELSE 'Mature Stage'
    END as business_stage,
    
    -- Recommendations
    CASE 
        WHEN mqt.quick_ratio < 1.0 THEN 'Focus on reducing churn before growth'
        WHEN mqt.quick_ratio >= 1.5 AND mqt.retention_rate_pct >= 60 THEN 'Invest heavily in user acquisition'
        WHEN mqt.retention_rate_pct < 40 THEN 'Improve product stickiness and onboarding'
        WHEN mqt.new_users = 0 THEN 'Restart user acquisition efforts'
        ELSE 'Optimize current growth strategy'
    END as strategic_recommendation,
    
    -- Health indicators
    ROUND(100.0 * mqt.new_users / NULLIF(mqt.total_mau, 0), 1) as new_user_ratio_pct,
    ROUND(100.0 * mqt.resurrected_users / NULLIF(mqt.total_mau, 0), 1) as resurrection_ratio_pct,
    ROUND(100.0 * mqt.churned_users / NULLIF(LAG(mqt.total_mau) OVER (ORDER BY mqt.activity_month), 0), 1) as churn_impact_pct,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM monthly_quick_ratio_trends mqt
LEFT JOIN quick_ratio_alerts qra ON mqt.activity_month = qra.activity_month
LEFT JOIN growth_benchmarks gb ON mqt.activity_month = gb.activity_month
ORDER BY mqt.activity_month
    );
  