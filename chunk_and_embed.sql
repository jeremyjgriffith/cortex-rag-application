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
    snowflake.ml.embed_text('e5-base-v2', content_chunk) embedding,
    start_index,
    row_number() over (partition by sec_document_id order by sec_document_id, start_index) as document_index_rownum,
    row_number() over (order by sec_document_id, start_index) as rownum
from 
    sec_reports_base,
    table(chunk_text(value))
where 
    length(content_chunk) <= 1000;
