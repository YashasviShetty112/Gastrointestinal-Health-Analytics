Create table patients( patient_id int primary key, age int, gender varchar(20), ethnicity varchar(50), BMI Float, Body_Weight float, Obesity_status varchar(20) );
create table lifestyle_habits( record_id int primary key, patient_id int, diet_type varchar(50), smoking_status varchar(20), alcohol_use varchar(20), stress_level varchar(20), physical_activity varchar(50), foreign key (patient_id) references patients(patient_id));
create table clinical_metrics( metric_id int primary key, patient_id int, microbiome_index float, fecal_calprotectin float, H_Pylori_Status varchar(20), Antibiotic_use varchar(10), Abdominal_pain varchar(10), Bloating varchar(10), Autoimmune_Disorders varchar(50), foreign key (patient_id) references patients(patient_id));


CREATE TABLE Patients AS SELECT DISTINCT Patient_ID, Age, Gender, Ethnicity, BMI, Body_Weight, Obesity_Status FROM 'gastrointestinal_disease_dataset.csv';
CREATE TABLE Lifestyle_Habits AS SELECT ROW_NUMBER() OVER (ORDER BY Patient_ID) AS Record_ID, Patient_ID, Diet_Type, Smoking_Status, Alcohol_Use, Stress_Level, Physical_Activity FROM 'gastrointestinal_disease_dataset.csv';
CREATE TABLE Clinical_Metrics AS SELECT ROW_NUMBER() OVER (ORDER BY Patient_ID) AS Metric_ID, Patient_ID, Microbiome_Index, Fecal_Calprotectin, H_Pylori_Status, Antibiotic_Use, Abdominal_Pain, Bloating, Autoimmune_Disorders FROM 'gastrointestinal_disease_dataset.csv';


with lowest_average as( select patient_id from "Clinical_Metrics"
 where fecal_calprotectin<(select avg(fecal_calprotectin) from "Clinical_Metrics") 
 )
select l.patient_id, l.diet_type, l.smoking_status, l.alcohol_use, l.stress_level, l.physical_activity, avg(c.Fecal_Calprotectin) as avg_fecal_calprotectin from "Lifestyle_Habits" as l inner join "Clinical_Metrics" as c on l.patient_id=c.patient_id inner join lowest_average as la on la.patient_id=c.patient_id group by l.diet_type, l.smoking_status, l.alcohol_use, l.stress_level, l.physical_activity, l.patient_id order by avg_fecal_calprotectin asc;
-------------------

select count(c.patient_id) as severe_count, c.fecal_calprotectin,
l.smoking_status, l.stress_level 
from "Clinical_Metrics" as c inner join 
"Lifestyle_Habits" as l on c.Patient_id=l.Patient_id 
where c.Fecal_Calprotectin>200 
group by c.fecal_calprotectin,l.smoking_status, 
l.stress_level order by severe_count desc;
----------------------

SELECT CASE WHEN autoimmune_disorders = 0 
OR autoimmune_disorders IS NULL THEN 'Broader Population (No Autoimmune)' 
ELSE 'Patients with Autoimmune Disorder' END AS patient_cohort, 
COUNT(patient_id) AS total_patients, ROUND(CAST(AVG(microbiome_index) 
AS NUMERIC), 2) AS avg_microbiome_index, ROUND(CAST(MIN(microbiome_index)
 AS NUMERIC), 2) AS min_microbiome_index, 
 ROUND(CAST(MAX(microbiome_index) AS NUMERIC), 2) AS max_microbiome_index
 FROM "Clinical_Metrics" GROUP BY 1;
 --------------------
 
 with cohort as( select p.obesity_status, p.patient_id, c.microbiome_index, 
 case when c.microbiome_index between 0.0 and 0.40 then 'low performimg'
 when c.microbiome_index between 0.41 and 0.70 then 'Moderate' 
 else 'High performing' end as microbiome_perfomance,
 dense_rank() over (partition by Obesity_status order by microbiome_index desc) as r 
 from "Clinical_Metrics" as c inner join "Patients" as p on c.patient_id=p.patient_id ) 
 select patient_id,obesity_status,microbiome_perfomance,microbiome_index,r 
 from cohort where r<=5 order by obesity_status,r;
 ---------------------------
 
 
 select l.diet_type,l.physical_activity,count(c.patient_id),
 count(case when c.fecal_calprotectin>100 then 1 end) as elevated_patients_count,
 round(cast(count(case when c.fecal_calprotectin>100 then 1 end )*100/count(c.patient_id) as numeric),2) as pct_elevated_patients 
 from "Clinical_Metrics" as c inner join "Lifestyle_Habits" as l
 on c.Patient_id=l.Patient_id 
 group by l.Diet_Type, l.Physical_Activity 
 order by pct_elevated_patients desc;
 ---------------------
 
 WITH patient_risk_classification AS ( SELECT patient_id, fecal_calprotectin, microbiome_index, 
 autoimmune_disorders, 
 CASE WHEN fecal_calprotectin > 200 OR microbiome_index < 0.40 
 OR (autoimmune_disorders IS NOT NULL) THEN 'High Risk' 
 WHEN fecal_calprotectin BETWEEN 101 AND 200 
 OR microbiome_index BETWEEN 0.40 AND 0.60 THEN 'Moderate Risk' 
 ELSE 'Low Risk' END AS clinical_risk_tier FROM "Clinical_Metrics" )
 SELECT clinical_risk_tier, COUNT(patient_id) AS total_patients, 
 ROUND( CAST(COUNT(patient_id) * 100.0 / SUM(COUNT(patient_id))
 OVER () AS NUMERIC), 2 ) AS pct_of_total_population, 
 ROUND(CAST(AVG(fecal_calprotectin) AS NUMERIC), 2) AS avg_fecal_calprotectin,
 ROUND(CAST(AVG(microbiome_index) AS NUMERIC), 4) AS avg_microbiome_index 
 FROM patient_risk_classification 
 GROUP BY clinical_risk_tier 
 ORDER BY CASE clinical_risk_tier WHEN 'High Risk' THEN 1 WHEN 'Moderate Risk' THEN 2 WHEN 'Low Risk' THEN 3 END;
 
 
 ------------------END--------------------