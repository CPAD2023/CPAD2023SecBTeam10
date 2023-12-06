import os
import chromadb
from chromadb.config import Settings

DIR = os.path.abspath(os.path.dirname(__file__))
class RetrivalAugmentedGeneration:
    def __init__(self):
        self.persistent_storage = os.path.join(DIR, 'persistent_storage')
        self.chroma_client = chromadb.PersistentClient(path=self.persistent_storage, settings=Settings(allow_reset=True, anonymized_telemetry=False))
        self.collection = self.chroma_client.get_or_create_collection(name="temporary_collection")
    
    def add_to_collection(self, issue_data):
        documents = [data.get("issue_desc") for data in issue_data]
        metadatas = [{"issue_id": data.get("issue_id"), "issue_title":data.get("issue_title")} for data in issue_data]
        ids = [str(i) for i in range(len(documents))]
        self.collection.add(documents=documents, metadatas=metadatas, ids = ids)

    def query(self, user_query):
        results = self.collection.query(query_texts=user_query, n_results=3)
        query_documents = results['documents'][0]
        query_metadatas = results['metadatas'][0]
        related_issues = [f"{issue['issue_id']}" for issue in query_metadatas]
        return ", ".join(related_issues)
    
    def clean_collection(self):
        self.chroma_client.delete_collection(name=self.collection.name)


    

