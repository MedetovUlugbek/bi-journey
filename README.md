BI Journey – SQL Analysis

Dataset

This project uses the open‑source dvdrental sample dataset provided by PostgreSQL. It captures a video rental business with tables for customers, films, inventory, rentals and payments.  The dataset is ideal for exploring business‑oriented analytical questions in a small, self‑contained environment.

Tools
	•	PostgreSQL – the database engine used to store and query the dvdrental data.
	•	TablePlus – a graphical client for interacting with PostgreSQL.  Queries in this repository were written and tested using TablePlus.
	•	Visual Studio Code & Git – used for editing SQL files and managing version control.

SQL Files

The sql_files directory contains the analysis scripts.  Each file is numbered chronologically to reflect the order in which the analyses were developed.
	•	01.sql – Analyses overall business performance, monthly revenue and transaction counts, revenue by film category, top customers by sales, top customers per store and percent‑of‑total revenue metrics.
	•	02.sql – Additional exploratory queries or reporting (update this section to describe what the second script does once you add more analysis).

Getting Started

To reproduce the analyses or build your own queries:
	1.	Restore the dvdrental database into your local PostgreSQL instance.  If you need a copy of the dataset, it can be downloaded from the official PostgreSQL sample database repository.
	2.	Open the scripts in the sql_files directory with TablePlus or your preferred SQL editor.
	3.	Run the queries and review the results to explore transaction trends, customer behavior and category performance.

Feel free to fork this repository and add your own analyses.  Contributions and suggestions are welcome!