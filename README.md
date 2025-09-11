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

![ERD for Maji Ndogo water_services database](https://github.com/lawaloa/SQL_Project_3/blob/main/EER_Project_3.png?raw=true)


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

*(Content placeholder – describe how you imported the audit report into the database)*  

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


