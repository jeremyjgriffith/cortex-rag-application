use schema sec_cortex_demo.public;
use warehouse xsmall;

select 
    snowflake.cortex.complete('llama2-70b-chat', 
                              'Where is Snowflake\'s headquarters?'
    );

select 
    snowflake.cortex.complete('llama2-70b-chat', 
                              'How many customers does Snowflake have?'
    );


/**********************************
 * Raw data
 *********************************/ 
select * from sec_reports_base 
where company_name = 'SNOWFLAKE INC.';

/**********************************
 * Chunked and embedded data
 *********************************/
select 
    content_chunk, 
    snowflake.cortex.embed_text('e5-base-v2', content_chunk) as embedding
from content_chunks_10k 
where company_name = 'SNOWFLAKE INC.'
order by document_index_rownum;

select 
    *
from content_chunks_10k 
where company_name = 'SNOWFLAKE INC.'
order by document_index_rownum;

select count(*) from content_chunks_10k;

/**********************************
 * Vector embeddings and search
 *********************************/
set question = 'How many customers does the company have?';
-- use vector search to find relevant content chunks
select 
    content_chunk
from 
    content_chunks_10k 
where 
    company_name = 'SNOWFLAKE INC.'
order by 
    vector_cosine_distance(embedding, snowflake.cortex.embed_text('e5-base-v2', $question)) desc
limit 10;

/**********************************
 * Vector search + LLM RAG
 *********************************/
with context as (
    select 
        content_chunk
    from 
        content_chunks_10k 
    where 
        company_name = 'SNOWFLAKE INC.'
    order by 
        vector_cosine_distance(embedding, snowflake.cortex.embed_text('e5-base-v2', $question)) desc
    limit 1
)
select 
    snowflake.cortex.complete('llama2-70b-chat',
                              'Use the provided context to answer the question. Be concise. ' ||
                              '###
                               CONTEXT: ' ||
                              context.content_chunk ||
                              '###
                              QUESTION: ' || $question ||
                              'ANSWER: ') as response,
    context.content_chunk
from 
    context
;
