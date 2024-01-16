# cortex-rag-application

Create a simple RAG application using Snowflake Cortex and Streamlit

1. Get the [LLM Training Essentials](https://app.snowflake.com/marketplace/listing/GZTSZ290BUX1X/cybersyn-inc-llm-training-essentials) dataset from the Snowflake marketplace. Call the database `LLM_TRAINING_ESSENTIALS` when creating the shared database in your account. 
2. Create Chunking UDTF [chunking_udtf.sql](chunking_udtf.sql)
3. Create the base table then chunk data and get embeddings for the chunked data. [chunk_and_embed.sql](chunk_and_embed.sql)
4. Run [demo.sql](demo.sql) and explore.
5. Create Streamlit application in your Snowflake account. [streamlit.py](streamlit.py)
