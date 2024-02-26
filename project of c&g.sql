
create database cg;
use cg;
-- Table to store information about different models
CREATE TABLE Models (
    ModelID INT PRIMARY KEY,
    ModelName VARCHAR(255) NOT NULL
);

-- Table to store information about various capabilities
CREATE TABLE Capabilities (
    CapabilityID INT PRIMARY KEY,
    CapabilityName VARCHAR(255) NOT NULL
);

-- Table to store benchmark scores for different models and capabilities
CREATE TABLE Benchmarks (
    BenchmarkID INT PRIMARY KEY,
    ModelID INT,
    CapabilityID INT,
    BenchmarkName VARCHAR(255) NOT NULL,
    ScoreGemini FLOAT,
    ScoreGPT4 FLOAT,
    Description TEXT,
    FOREIGN KEY (ModelID) REFERENCES Models(ModelID),
    FOREIGN KEY (CapabilityID) REFERENCES Capabilities(CapabilityID)
);

-- Insert data into the Models table
INSERT INTO Models (ModelID, ModelName) VALUES
(1, 'Gemini Ultra'),
(2, 'GPT-4');

-- Insert data into the Capabilities table
INSERT INTO Capabilities (CapabilityID, CapabilityName) VALUES
(1, 'General'),
(2, 'Reasoning'),
(3, 'Math'),
(4, 'Code'),
(5, 'Image'),
(6, 'Video'),
(7, 'Audio');

-- Insert data into the Benchmarks table
INSERT INTO Benchmarks (BenchmarkID, ModelID, CapabilityID, BenchmarkName, ScoreGemini, ScoreGPT4, Description) VALUES
-- General Capabilities
(1, 1, 1, 'MMLU', 90.00, 86.40, 'Representation of questions in 57 subjects'),
(2, 2, 1, 'MMLU', 86.40, NULL, 'Representation of questions in 57 subjects'),

-- Reasoning Capabilities
(3, 1, 2, 'Big-Bench Hard', 83.60, 83.10, 'Diverse set of challenging tasks requiring multi-step reasoning'),
(4, 2, 2, 'Big-Bench Hard', 83.10, NULL, 'Diverse set of challenging tasks requiring multi-step reasoning'),
(5, 1, 2, 'DROP', 82.4, 80.9, 'Reading comprehension (Fl Score)'),
(6, 2, 2, 'DROP', 80.9, NULL, 'Reading comprehension (Fl Score)'),
(7, 1, 2, 'HellaSwag', 87.80, 95.30, 'Commonsense reasoning for everyday tasks'),
(8, 2, 2, 'HellaSwag', 95.30, NULL, 'Commonsense reasoning for everyday tasks'),

-- Math Capabilities
(9, 1, 3, 'GSM8K', 94.40, 92.00, 'Basic arithmetic manipulations, incl. Grade School math problems'),
(10, 2, 3, 'GSM8K', 92.00, NULL, 'Basic arithmetic manipulations, incl. Grade School math problems'),
(11, 1, 3, 'MATH', 53.20, 52.90, 'Challenging math problems, incl. algebra, geometry, pre-calculus, and others'),
(12, 2, 3, 'MATH', 52.90, NULL, 'Challenging math problems, incl. algebra, geometry, pre-calculus, and others'),

-- Code Generation Capabilities
(13, 1, 4, 'HumanEval', 74.40, 67.00, 'Python code generation'),
(14, 2, 4, 'HumanEval', 67.00, NULL, 'Python code generation'),
(15, 1, 4, 'Natura12Code', 74.90, 73.90, 'Python code generation. New held out dataset HumanEval-like, not leaked on the web'),
(16, 2, 4, 'Natura12Code', 73.90, NULL, 'Python code generation'),

-- Image Capabilities
(17, 1, 5, 'MIMMU', 59.40, 56.80, 'Multi-discipline college-level reasoning problems'),
(18, 2, 5, 'VQAv2', 77.80, 77.20, 'Natural image understanding'),
(19, 1, 5, 'TextVQA', 82.30, 78.00, 'OCR on natural images'),
(20, 2, 5, 'DocVQA', 90.90, 88.40, 'Document understanding'),
(21, 1, 5, 'Infographic VQA', 80.30, 75.10, 'Infographic understanding'),
(22, 2, 5, 'MathVista', 53.00, 49.90, 'Mathematical reasoning in visual contexts'),

-- Video Capabilities
(23, 1, 6, 'VATEX', 62.7, 56, 'English video captioning (CIDEr)'),
(24, 2, 6, 'Perception Test MCQA', 54.70, 46.30, 'Video question answering'),

-- Audio Capabilities
(25, 1, 7, 'CoV0ST 2', 40.1, 29.1, 'Automatic speech translation (BLEU score)'),
(26, 2, 7, 'FLEURS', 7.60, 17.60, 'Automatic speech recognition (word error rate)');

select * from benchmarks; -- 26
select * from capabilities; -- 7
select * from models; -- 2

-- 1)What are the average scores for each capability on both the Gemini Ultra and GPT-4 models?
select CapabilityName, round(avg(ScoreGemini),0) as Avg_gemini_score, round(avg(ScoreGPT4),0) as Avg_gpt_score
from benchmarks b inner join capabilities c using (CapabilityID)
inner join models m using (ModelID)
group by CapabilityName;

-- 2)Which benchmarks does Gemini Ultra outperform GPT-4 in terms of scores?

select distinct BenchmarkName
from benchmarks
where ScoreGemini>ScoreGPT4 ;

-- 3)What are the highest scores achieved by Gemini Ultra and GPT-4 for each benchmark in the Image capability?
select BenchmarkName,max(ScoreGemini) as Highest_gemini_score, max(ScoreGPT4) as Highest_gpt4_score
from capabilities c inner join benchmarks b using (capabilityid)
where CapabilityName = 'Image'
group by BenchmarkName;


-- 4)Calculate the percentage improvement of Gemini Ultra over GPT-4 for each benchmark?

select BenchmarkName, 
			round(case when  
				   ScoreGemini is not null and ScoreGPT4 is not null then
                   (( ScoreGemini - ScoreGPT4 ) / ScoreGPT4) * 100
                      else 0 end,2) as `% improvement`
from benchmarks inner join models using(modelID)
group by BenchmarkName,ScoreGPT4,ScoreGemini
order by `% improvement` desc ;

-- 5)Retrieve the benchmarks where both models scored above the average for their respective models?
/*Average threshold for both the models */
select round(AVG(ScoreGemini),1) as Avg_gemini_score
from benchmarks inner join models using(modelID);

select round(AVG(ScoreGPT4),1) as Avg_gpt_score
from benchmarks inner join models using(modelID);

/*Checking for above average scores */
select BenchmarkName,ScoreGemini, ScoreGPT4
from benchmarks inner join models using(modelID)
where ScoreGemini > (SELECT AVG(ScoreGemini) FROM benchmarks WHERE ScoreGemini IS NOT NULL) and
	  ScoreGPT4 > (SELECT AVG(ScoreGPT4) FROM benchmarks WHERE ScoreGemini IS NOT NULL);

-- 6)Which benchmarks show that Gemini Ultra is expected to outperform GPT-4 based on the next score?

with cte as (
select *,
lead(ScoreGemini) over (order by ScoreGemini desc) as Next_score_Gemini_ultra
from benchmarks)

select BenchmarkName, ScoreGPT4, Next_score_Gemini_ultra
from cte
where Next_score_Gemini_ultra > ScoreGPT4 and Next_score_Gemini_ultra is not null;


-- 7)Classify benchmarks into performance categories based on score ranges?

select BenchmarkName, ScoreGemini,
case 
		when ScoreGemini >=90 then "Excellent"
		when ScoreGemini >=70 then "Very Good"
		when ScoreGemini >= 50 then "Good"
		when ScoreGemini >= 30 then "Poor"
		when ScoreGemini >= 10 then "Very Poor"
else "Worst" end as Gemini_Performance,

ScoreGPT4,
case 
		when ScoreGPT4 >=90 then "Excellent"
		when ScoreGPT4 >=77 then "Very Good"
		when ScoreGPT4 >= 67 then "Good"
		when ScoreGPT4 >= 30 then "Poor"
		when ScoreGPT4 >= 10 then "Very Poor"
else "Worst" end as GPT4_Performance
 from benchmarks
 where ScoreGPT4 is not null
 order by ScoreGPT4 desc;

-- 8) Retrieve the rankings for each capability based on Gemini Ultra scores?

select CapabilityName, ScoreGemini,
rank() over (partition by CapabilityName order by ScoreGemini desc) as Rnk
from capabilities inner join benchmarks using (CapabilityID);

-- 9)Convert the Capability and Benchmark names to uppercase?

select upper(BenchmarkName) as Uppercase_benchmark,upper(CapabilityName) as Uppercase_Capability_name
from capabilities inner join benchmarks using (CapabilityID);

-- 10) Can you provide the benchmarks along with their descriptions in a concatenated format?

select concat(BenchmarkName,"   &   ", Description) as Concatednated_benchmarks
from benchmarks;