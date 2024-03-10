/*********************************************
 * Create base table with the most recent 10-K
 * for each company
 *********************************************/
create or replace table sec_reports_base as 
SELECT
    txt.sec_document_id,
    companies.cik,
    txt.variable_name as document_type,
    companies.company_name,
    companies.sic_code_category,
    companies.sic_code_description,
    companies.country,
    txt.period_end_date,
    txt.value
FROM 
    llm_training_essentials.cybersyn.sec_report_text_attributes AS txt
    JOIN llm_training_essentials.cybersyn.sec_cik_index AS companies ON (companies.cik = txt.cik)
WHERE 
    txt.period_end_date >= '2020-01-01'
    and document_type = '10-K Filing Text'
qualify row_number() over (partition by companies.cik order by period_end_date desc) = 1;

/*********************************************
 * Chunk content and get embeddings for chunks
 *********************************************/
create or replace table content_chunks_10k as 
select 
    sec_document_id,
    document_type,
    company_name,
    sic_code_category,
    sic_code_description,
    country,
    period_end_date,
    chunk as content_chunk,
    snowflake.cortex.embed_text('e5-base-v2', content_chunk) embedding,
    start_index,
    row_number() over (partition by sec_document_id order by sec_document_id, start_index) as document_index_rownum,
    row_number() over (order by sec_document_id, start_index) as rownum
from 
    sec_reports_base,
    table(chunk_text(value))
where 
    length(content_chunk) <= 1000;
