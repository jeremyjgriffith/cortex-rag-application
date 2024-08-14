create or replace database sec_cortex_demo;
use database sec_cortex_demo;

create or replace function chunk_text(text varchar)
returns table(chunk varchar, start_index int)
language  python
runtime_version = '3.10'
handler = 'text_chunker'
packages=('pandas','langchain-text-splitters' )
as
$$
from langchain_text_splitters import RecursiveCharacterTextSplitter
import pandas as pd

class text_chunker:
    def process(self,text):        
        text_raw=[]
        text_raw.append(text) 
        
        text_splitter = RecursiveCharacterTextSplitter(
            separators = ["\n", "."], # Define an appropriate separator. New line is good typically!
            chunk_size = 1000, #Adjust this as you see fit
            chunk_overlap  = 200, #This lets text have some form of overlap. Useful for keeping chunks contextual
            length_function = len,
            add_start_index = True #Optional but useful if you'd like to feed the chunk before/after
        )
    
        chunks = text_splitter.create_documents(text_raw)
        df = pd.DataFrame([[d.page_content, d.metadata] for d in chunks], columns=['chunks','meta'])

        df['meta'] = df['meta'].apply(lambda x: x['start_index']).astype(int)
        df['chunks'] = df['chunks'].apply(lambda x: x)
        
        yield from df.itertuples(index=False, name=None)
$$;
