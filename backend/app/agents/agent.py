import os
import openai
from langchain.chat_models import ChatOpenAI
from langchain.llms import OpenAI
from langchain.schema import HumanMessage
from langchain.prompts.chat import (
    ChatPromptTemplate,
    SystemMessagePromptTemplate,
    AIMessagePromptTemplate,
    HumanMessagePromptTemplate,
)
import time
from dotenv import load_dotenv
import json



DIR = os.path.abspath(os.path.dirname(__file__))

class AgentInstance:
    def __init__(self, action):
        load_dotenv()
        self.action = action
        self.llm = ChatOpenAI(temperature=0)
        with open(os.path.join(DIR, "prompt", "system.txt"), 'r') as system_prompt_file:
            lines = system_prompt_file.readlines()
            template = "\n".join(lines)
            self.system_message_prompt = SystemMessagePromptTemplate.from_template(template)
        system_prompt_file.close()
        
    def ask_gpt(self, context:str, task:str, user_input):
        if self.action == "create_issue":
            human_template="This is the details about the project: {context} \n\n You need to create a new issue. {task} \n\n Here are the details that the user gave to create a new ticket: {user_input}."
            human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
            chat_prompt = ChatPromptTemplate.from_messages([self.system_message_prompt, human_message_prompt])
            output = self.llm(chat_prompt.format_prompt(context=context, task=task, user_input=user_input).to_messages())
            output = output.to_json()["kwargs"]["content"]
            return output
        elif self.action == "update_issue":
            human_template="Here is the details of the existing issue. {context} \n\n This issue has to be updated. {task} \n\n  This is what the user wants to update in the json: {user_input}. Update the issue and return only the new json"
            human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
            chat_prompt = ChatPromptTemplate.from_messages([self.system_message_prompt, human_message_prompt])
            output = self.llm(chat_prompt.format_prompt(context=context, task=task, user_input=user_input).to_messages())
            output = output.to_json()["kwargs"]["content"]
            parsed_output = self.create_parsable_ouptut(current_output=output)
            return parsed_output
        elif self.action == "process_scrum_update":
            human_template = "This is the conversation that took place between the team memebers: {context} \n\n {task}"
            human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
            chat_prompt = ChatPromptTemplate.from_messages([self.system_message_prompt, human_message_prompt])
            output = self.llm(chat_prompt.format_prompt(context=context, task=task, user_input=user_input).to_messages())
            output = output.to_json()["kwargs"]["content"]
            return output
    
    def create_parsable_ouptut(self, current_output):
        is_parsable = False
        try_count = 0
        max_try_limit = 3
        while not is_parsable:
            if try_count < max_try_limit:
                try:
                    json_data = json.loads(current_output)
                    is_parsable = True
                    return json.dumps(json_data)
                except:
                        try_count = try_count + 1
                        fixable_prompt = f"I have the following data: {current_output} Here there are other text along with the json data. Just extract the json and return the json without any addional text. Even you don't have to add any other text. Keep your output in a format that can be out of the box fed to json.loads()"
                        bit_client = OpenAI()
                        current_output = str(bit_client.invoke(fixable_prompt))
                        current_output = current_output.replace("\n", "")
            else:
                time.sleep(23)
                try_count = 0