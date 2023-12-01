from langchain.tools import BaseTool
import os
from typing import Optional, Type
from langchain.callbacks.manager import (AsyncCallbackManagerForToolRun, CallbackManagerForToolRun)
import json

DIR = os.path.abspath(os.path.dirname(__file__))
FILESTORE = os.path.join(DIR, "..", "..", "filestore")

class Extract(BaseTool):
    name = "content_finder"
    description = """
    - The input to this tool must only be the file name mentioned in the user input. Example: FILENAME.txt
    - Use this tool when you want to extract content from a file before performing any analysis or task.
    - After you have finished with the execution of this tool, find the next tool to execute based on the user's query, to analyse the contents extracted from the file.
    - If you are not able to find the file with the same filename, try finding another file in the directory that is similar or matches the file requested by the user.
    """
    def _run(self, query: str, run_manager: Optional[CallbackManagerForToolRun] = None) -> str:
        filename = query
        try:
            filepath = os.path.join(FILESTORE, filename)
            textfile = open(filepath, 'r')
            lines = textfile.readlines()
            content = "\n".join(lines)
            return content
        except Exception as e:
            files_list = [f for f in os.listdir(FILESTORE) if os.path.isfile(os.path.join(FILESTORE, f)) and f.endswith('.txt')]
            msg = f"The following error occured: {str(e)}. Other available files are: {','.join(files_list)}"
            return msg
    
    async def _arun(
        self, query: str, run_manager: Optional[AsyncCallbackManagerForToolRun] = None
    ) -> str:
        """Use the tool asynchronously."""
        raise NotImplementedError("custom_search does not support async")