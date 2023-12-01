from langchain.tools import BaseTool
from typing import Optional, Type
from langchain.callbacks.manager import (AsyncCallbackManagerForToolRun, CallbackManagerForToolRun)

class Scrum(BaseTool):
    name = "scrum_processor"
    description = "Use this tool when the user want you to find the age of a person"
    def _run(self, query: str, run_manager: Optional[CallbackManagerForToolRun] = None) -> str:
        return "Akshay's age is 21"
    
    async def _arun(
        self, query: str, run_manager: Optional[AsyncCallbackManagerForToolRun] = None
    ) -> str:
        """Use the tool asynchronously."""
        raise NotImplementedError("custom_search does not support async")