# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col, call_function

# Write directly to the app
st.title("	:chart_with_upwards_trend: 10-K Explorer")
session = get_active_session()

reports = session.table('sec_reports_base')
companies = reports.select(col('COMPANY_NAME')).distinct().sort('COMPANY_NAME')

selected_company = st.selectbox("Company", companies)

selected_document = reports.where(col('COMPANY_NAME') == selected_company)

question = st.text_input("Enter Question:")

if question: 
    
    question_response = session.sql(f"""
    with question as (
    select 
        '{question}' as question,
        snowflake.cortex.embed_text('e5-base-v2', question) as embedding
    ),
    context as ( 
        select 
            content_chunk as context,
            sec_document_id,
            start_index as document_index
        from 
            content_chunks_10k as content,
            question
        where 
            company_name = '{selected_company}'
        order by 
            vector_cosine_distance(content.embedding, question.embedding) desc
        limit 1
    )
    select 
        snowflake.cortex.complete('llama2-70b-chat',
                                  'Use only the context provided to answer the question. Be concise.' ||
                                  '### ' ||  
                                  'Context: ' || context || 
                                  '### ' ||
                                  'Question: ' || question ||
                                  'Answer: ') as response,
        sec_document_id,
        document_index,
        context
    from 
        question,
        context
    """  
    ).collect()[0]

    st.write(question_response['RESPONSE'].replace("$","\$"))
    
    with st.expander("See context from original document", expanded=False):

        st.markdown(f'''
            **Document ID:** {question_response['SEC_DOCUMENT_ID']}  
            **Context Index in Document:** {question_response['DOCUMENT_INDEX']}  
            **Context from Document:**  
            {question_response['CONTEXT']}
        '''.replace("$","\$"))
