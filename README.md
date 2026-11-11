An end-to-end clinical analytics pipeline transitioning from raw data storage and complex relational query processing in DuckDB (SQL) to an executive dashboard in Power BI Desktop.
​This portfolio project models acute patient populations, isolates high-risk inflammatory cohorts, and evaluates how lifestyle behaviors correlate with GI health indicators.
​
 Executive Summary
​Domain: Healthcare & Gastrointestinal Clinical Operations
​Primary Objective: Analyze acute GI patient cohorts to stratify clinical risk, measure inflammatory markers (fecal_calprotectin), monitor gut microbiome integrity (microbiome_index), and evaluate the impact of lifestyle habits (diet, stress, smoking, physical activity).
​Key Findings: Identified core stress-and-smoking operational bottlenecks across high-risk cohorts and provided actionable visual segmentation for clinic resource planning.

Database Architecture & Schema
​The dataset consists of three normalized tables joined via patient_id:


Technical Stack & Tooling
Tool / Layer Usage & Focus Area

DuckDB (sql-workbench.com)-High-performance SQL processing, data transformation, aggregate analytical queries, CTEs, window functions (DENSE_RANK), and conditional logic.
Power BI Desktop-Star-schema data modeling, cross-table filtering, interactive report pages, dynamic matrix heatmaps, and custom visualization layout.
DAX (Data Analysis Expressions)-Dynamic measure creation (CALCULATE, DISTINCTCOUNT, DIVIDE), risk tier calculated columns (SWITCH(TRUE())), and custom sort orders.

Key Analytical Queries (SQL / DuckDB)
The project includes 6 business and clinical queries executing critical analytical tasks:

Risk Stratification: Categorizing patient cohorts based on inflammation scores (fecal_calprotectin > 200 as high risk) and autoimmune triggers.

Operational Matrix Aggregations: Cross-tabulating high-risk counts across multi-variable lifestyle indicators (Smoking Status vs. Stress Level).

Cohort Comparisons: Aggregating average gut diversity (microbiome_index) across patients presenting with autoimmune disorders vs. general population.

Top Performer Ranking: Utilizing window functions (DENSE_RANK()) to identify top gut diversity scores per obesity tier.

Elevated Risk Ratios: Calculating proportional distribution of elevated risk indicators grouped by dietary habits.
Power BI Architecture & DAX Formulas
Data Modeling & Relationships
Patients \rightarrow Clinical_Metrics: 1-to-Many (1:*), Single Direction.
Patients \rightarrow Lifestyle_Habits: 1-to-Many (1:*), Bidirectional cross-filtering enabled for matrix dynamic propagation.

Core Measures (_Measures Table)
1. Total Patient Population

Total Patients = DISTINCTCOUNT('Clinical_Metrics'[patient_id])

2)  Average Fecal Calprotectin (Inflammation)

Avg Fecal Calprotectin = AVERAGE('Clinical_Metrics'[fecal_calprotectin])

3)  Severe Patient Population Count

Severe Patients Count = 
CALCULATE(
    [Total Patients],
    'Clinical_Metrics'[fecal_calprotectin] > 200
)

4)   Elevated Patient Percentage

Pct Elevated Patients = 
DIVIDE(
    CALCULATE([Total Patients], 'Clinical_Metrics'[fecal_calprotectin] > 100),
    [Total Patients],
    0
)

5)   Calculated Column: Clinical Risk Tiering
Clinical_Risk_Tier = 
SWITCH(
    TRUE(),
    'Clinical_Metrics'[fecal_calprotectin] > 200 
        || 'Clinical_Metrics'[microbiome_index] < 0.40 
        || (NOT(ISBLANK('Clinical_Metrics'[autoimmune_disorders])) && 'Clinical_Metrics'[autoimmune_disorders] <> "None"), 
    "High Risk",
    
    ('Clinical_Metrics'[fecal_calprotectin] >= 101 && 'Clinical_Metrics'[fecal_calprotectin] <= 200) 
        || ('Clinical_Metrics'[microbiome_index] >= 0.40 && 'Clinical_Metrics'[microbiome_index] <= 0.60), 
    "Moderate Risk",
    
    "Low Risk"
)

Dashboard Page Structure
Page 1: Executive Overview & Risk Tiering

KPI Cards: Total Patients, Average Fecal Calprotectin, Average Microbiome Index.

Donut Chart: Patient distribution by Clinical_Risk_Tier (High, Moderate, Low).

Clustered Column Chart: Microbiome diversity comparison across Autoimmune Disorder classifications.

Page 2: Operational Resource Allocation & Lifestyle Risk
Matrix Heatmap: Severe patient concentration mapped by smoking_status (Rows) \times stress_level (Columns) with conditional color scale formatting.

100% Stacked Bar Chart: Proportional breakdown of elevated risk across diet_type and physical_activity.

Interactive Slicers: Dynamic slicing across obesity_status and diet_type.


