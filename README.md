# autoScrum


### About Assignment:
Group: B10 

Assignement Description: 
- The motivation for this tool comes from daily scrum calls. Teams gather around first to discuss issues, updates and blockers and then the developers, scrum masters, and product owners will have to update the respective issues or tickets with the details of the scrum calls.
- It also becomes necessary for these individuals to track every issue created to prevent duplicate issues from being created or link existing issues to new ones.
- Also defining the done-criteria for each issue according to organizational standards is an issue.
- We have created this autoScrum application that will allow users to specify the details of the product, and scrum practices as the context to the agent and ask the agent to perform several tasks such as creating, updating, and deleting issues.
- The agent can also process example transcripts from meetings to identify tasks and perform them, making it easier for users to process scrum documents.

Simple Architecture Diagram:
![arch](https://github.com/CPAD2023/CPAD2023SecBTeam10/assets/66842711/9782f738-5b5f-44e5-a62d-d9d053fbd893)

Tech Stack
- OpenAI and Langchain for LLM tasks.
- ChromaDB for vector databases in RAG (powered by sentence transformers).
- Flask for API services.
- Server hosted on EC2, with a warm stand-by and configured Elastic IP.
- Database on hosted on: RDS with postgreSQL engine.
- Docker for defining images and docker-compose for creating interactable services.
- Flutter and Dart for Frontend
- Xcode for building the application for ios simulators

Video Demo: https://drive.google.com/file/d/1qGwHffrAZprrDHPHIwg9PW-MvOrL3TbY/view





### How To:
Run Backend:
