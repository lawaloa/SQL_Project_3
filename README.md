# SQL PROJECT 3 | 💧 Maji Ndogo Water Crisis – Turning Data into Community Insights  

---

## 📑 Table of Contents

- [Project Overview: Setting the stage for our data exploration journey](#project-overview-setting-the-stage-for-our-data-exploration-journey) 
- [Generating an ERD: Understanding the database structure](#-generating-an-erd-understanding-the-database-structure)  
- [Integrating the report: Adding the auditor report to our database](#-integrating-the-report-adding-the-auditor-report-to-our-database)  
- [Linking records: Joining employee data to the report](#-linking-records-joining-employee-data-to-the-report)  
- [Gathering evidence: Building a complex query seeking truth](#-gathering-evidence-building-a-complex-query-seeking-truth)  
- [Personal Takeaway](#-personal-takeaway)  

---

## 📝 Project Overview: Setting the stage for our data exploration journey
---

This project reflects my personal journey into SQL and its ability to transform raw datasets into actionable insights. The **Maji Ndogo Water Crisis Project** is a fictional case study crafted to simulate real-world scenarios of database auditing, governance, and community-centered decision-making.  

At the heart of the story is an independent audit of the Maji Ndogo water project, where discrepancies in water source records demanded closer scrutiny. By writing SQL queries, building Entity Relationship Diagrams (ERDs), and experimenting with joins and aggregations, I explored how data can reveal both truths and irregularities — ultimately shaping better governance.  

For me, this project wasn’t just about practicing SQL. It was about **learning how to weave analysis into a narrative** — turning queries and numbers into a compelling data story that resonates with both technical and non-technical audiences.  

---

### 📧 Audit Correspondence (Narrative Layer of the Project)  

#### From: **Independent Auditor (fictional role I adopted in the project)**  

**Subject:** Audit review of Maji Ndogo water project database  

Dear President Naledi,  

As part of the ongoing review of the Maji Ndogo water project, my team and I conducted an independent audit of the water source database. The purpose was to verify the integrity, accuracy, and reliability of the stored data, especially after earlier reports pointed out possible discrepancies.  

Through systematic SQL queries and data checks, we examined the records for signs of inconsistency and tampering. I am pleased to share that most of the data aligns well with principles of transparency and accountability. 
However, a few anomalies were detected — data entries that appear to have been altered. I have attached the flagged records for your immediate review. Addressing these irregularities will further strengthen the credibility of the project and ensure that data-driven governance remains at the forefront of decision-making.  

Respectfully,  
**Independent Auditor**  

---

#### From: **President Aziza Naledi**  

**Re:** Audit review of Maji Ndogo water project database  

Dear Auditor,  

Thank you for your comprehensive analysis of our water project records. Your findings validate our ongoing commitment to integrity and highlight the importance of maintaining robust data governance.  

I appreciate both the positive confirmation of our efforts and the identification of areas requiring attention. I will be instructing our data team to immediately investigate the anomalies you highlighted and implement corrective measures.  

This audit reinforces the role of data in driving accountability, and I commend you for your contribution.  

Sincerely,  
**Aziza Naledi**  

---

> [!Note]
> ### 💡 Key Takeaways  
>
> - Practiced **SQL queries, ERDs, joins, and aggregations** in a real-world styled project.  
> - Learned to approach datasets as stories — beyond numbers, they reflect lived experiences.  
> - Developed stronger skills in **data validation, auditing, and storytelling** for both technical and non-technical audiences.  

---

## 🔗 Generating an ERD: Understanding the database structure
---

<details>
<summary>Click to view chart</summary>
  
![ERD for Maji Ndogo water_services database](https://github.com/lawaloa/SQL_Project_3/blob/main/EER_Project_3.png?raw=true)

</details>

Before I could integrate the auditor’s report, I realized it was crucial to fully understand the **database structure**. This meant starting with an **Entity Relationship Diagram (ERD)** to map out how the tables in the `md_water_services` database connected to each other.  

The **visits** table quickly stood out as the central table. It links to other tables using foreign keys:  
- `location_id` → connected to the **location** table  
- `source_id` → connected to the **water_source** table  
- `assigned_employee_id` → connected to the **employee** table  

Each of these is a primary key in its respective table, but they act as foreign keys within **visits**.  

Here’s how I interpreted some of the relationships:  

- **Location ↔ Visits (One-to-Many):**  
  Each unique entry in the `location` table represents one place we’ve been, while the `visits` table logs *every single time* we visited that location. Naturally, one location can have many visits, making this a one-to-many relationship.  

- **Visits ↔ Water Quality (Intended One-to-One):**  
  My initial understanding was that every recorded visit should have *exactly one* corresponding water quality score. That would make this a one-to-one relationship. However, when I checked the ERD, it showed a many-to-one relationship — which didn’t make sense.  

I double-checked the database and confirmed that `record_id` is unique in both the `visits` and `water_quality` tables, which supports the one-to-one relationship I expected. To correct this, I updated the relationship in the ERD by editing the foreign key settings and changing the cardinality to **one-to-one**.  

This small exercise was a powerful reminder: **getting the relationships right at the start prevents big headaches later**. Misrepresenting relationships could lead to faulty joins, misleading results, and ultimately bad decisions. By carefully validating the ERD, I ensured my queries (and the audit integration) would stand on solid ground.  



## 📥 Integrating the Report: Adding the auditor report to our database
---

After mapping out the database structure with the ERD, the next step was to bring in the **auditor’s report**. This report came as a `.csv` file containing independent verification of water source quality across multiple locations.  

---

### 🗄️ Creating the Auditor Report Table  

To prepare the database, I created a table to hold the auditor’s results:  

<details>
<summary>Click to view SQL query</summary>
  
```sql
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
  `location_id` VARCHAR(32),
  `type_of_water_source` VARCHAR(64),
  `true_water_source_score` INT DEFAULT NULL,
  `statements` VARCHAR(255)
);
```

</details>

I then imported the `.csv` file. The dataset contained **1,620 records**, each representing a revisited water source.  

---

### 📑 Auditor’s Dataset Structure  

The dataset included the following columns:  

- **`location_id`** → unique identifier for each site  
- **`type_of_water_source`** → e.g., well, pump, stream  
- **`true_water_source_score`** → independently verified quality score  
- **`statements`** → remarks from locals at the site  

---

### 🔍 Framing the Key Questions  

At this point, I wanted to answer two main questions:  

1. **Is there a difference between the surveyors’ recorded scores and the auditors’ scores?**  
2. **If so, are there patterns in those differences?**  

---

### 🔗 Linking Auditor Data with Surveyor Data  

A challenge appeared:  

- The **`auditor_report`** table used `location_id`  
- The **`water_quality`** table used `record_id`  
- The **`visits`** table acted as the bridge, since it links `location_id` and `record_id`

To bring these together, I wrote the following query and to make the results easier to read, I also renamed the scores:  

- `surveyor_score` → from the `water_quality` table  
- `auditor_water_score` → from the `auditor_report` table    

<details>
<summary>Click to view SQL query</summary>
  
```sql
SELECT 
    v.location_id AS visit_location_id,
    v.record_id AS visit_record_id,
    a.location_id AS auditor_location_id,
    a.true_water_source_score AS auditor_water_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id;
```
  
</details>


📊 **Sample Output**

The query produced a comparison of the auditor’s independent scores and the surveyor’s recorded scores for the same sites:

<details>
<summary>Click to view output</summary>

| visit_location_id | visit_record_id | audit_location_id | auditor_water__score | surveyor_quality_score |
|-------------------|-----------------|------------------|-----------------------|--------------------------|
| SoRu34980         | 5185            | SoRu34980      | 1                        | 2                        |
| AkRu08112         | 59367           | AkRu08112      | 3                        | 4                        |
| AkLu02044         | 37379           | AkLu02044      | 0                        | 1                        |
| ...               | ...             | ...            | ...                      | ...                      |

</details>

#### 🧹 Cleaning Up the Join Results

At first, my query gave me **two `location_id` columns** — one from `visits` and one from `auditor_report`. Since they were duplicates, I decided to keep **just one `location_id`** (from `visits`) along with `record_id` as the anchor for linking data.  



<details>
<summary>Click to view 💻 Cleaned SQL Query</summary>

```sql
SELECT 
    v.record_id AS record_id,
    v.location_id AS location_id,
    w.subjective_quality_score AS surveyor_score,
    a.true_water_source_score AS auditor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id;
```

</details>

📊 **Cleaned Sample Output**

Now the output is tidy and easy to interpret — just one `location_id`, plus the surveyor’s and auditor’s scores:

<details>
<summary>Click to view output</summary>

| record\_id | location\_id | surveyor\_score | auditor\_score |
| ---------- | ------------ | --------------- | -------------- |
| 5185       | SoRu34980    | 2               | 1              |
| 59367      | AkRu08112    | 4               | 3              |
| 37379      | AkLu02044    | 1               | 0              |
| ...        | ...          | ...             | ...            |

</details>

## 🔗 Linking Records: Joining employee data to the report
---

*(Content placeholder – explain how you joined employee data with the audit findings)*  

## 🔍 Gathering Evidence: Building a complex query seeking truth
---

*(Content placeholder – highlight the complex SQL queries you wrote to uncover tampered records)*  

---

## ✨ Personal Takeaway  

Working on this project has reinforced my belief that **data is more than numbers — it is a powerful story-telling tool.** SQL empowered me to not only detect inconsistencies but also to narrate the findings in a way that matters for decision-making and governance.  

---

👤 **Author:** Tendai Mubarak  


