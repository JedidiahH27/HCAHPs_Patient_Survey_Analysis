CREATE TABLE hospital_beds
(
     provider_ccn integer
    ,hospital_name character varying(255)
    ,fiscal_year_begin_date character varying(10)
    ,fiscal_year_end_date character varying(10)
    ,number_of_beds integer
);

CREATE TABLE HCAHPS_data
(
    facility_id character varying(10),
    facility_name character varying(255),
    address character varying(255),
    city character varying(50),
    state character varying(2),
    zip_code character varying(10),
    county_or_parish character varying(50),
    telephone_number character varying(20),
    hcahps_measure_id character varying(255),
    hcahps_question character varying(255),
    hcahps_answer_description character varying(255),
    hcahps_answer_percent integer,
    num_completed_surveys integer,
    survey_response_rate_percent integer,
    start_date character varying(10),
    end_date character varying(10)
)

CREATE TABLE cleaned_hcahps_data AS (

WITH cte_hospital_beds AS (SELECT LPAD(CAST(provider_ccn AS TEXT), 6, '0') AS provider_ccn,
       hospital_name,
       TO_DATE(fiscal_year_begin_date, 'MM/DD/YYYY') AS fiscal_year_begin_date,
       TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY') AS fiscal_year_end_date,
       number_of_beds,
       ROW_NUMBER() OVER(PARTITION BY provider_ccn ORDER BY fiscal_year_begin_date)
FROM hospital_beds),

hospital_beds_cleaned AS (SELECT provider_ccn, 
       hospital_name, 
       fiscal_year_begin_date,
       fiscal_year_end_date,
       number_of_beds
FROM cte_hospital_beds
WHERE row_number = 1),

hcahps_cleaned AS (SELECT LPAD(CAST(facility_id AS TEXT), 6, '0') AS hcahps_provider_ccn,
        	TO_DATE(start_date, 'MM/DD/YYYY') AS start_date_converted,
       		TO_DATE(end_date, 'MM/DD/YYYY') AS end_date_converted ,
	   		*
FROM hcahps_data)

SELECT * FROM hcahps_cleaned AS hcahps
LEFT JOIN hospital_beds_cleaned AS beds
ON hcahps.hcahps_provider_ccn = beds.provider_ccn
);

