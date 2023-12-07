# autoScrum


### About Assignment:
Group: B10  Abhishek V Tatachar (2022SP93018) | Tushar Gahlot (2022SP93008) | M.Siddharth (2022SP93026)

Video Demo: https://drive.google.com/file/d/1qGwHffrAZprrDHPHIwg9PW-MvOrL3TbY/view

Assignement Description: 
- The motivation for this tool comes from daily scrum calls. Teams gather around first to discuss issues, updates and blockers and then the developers, scrum masters, and product owners will have to update the respective issues or tickets with the details of the scrum calls.
- It also becomes necessary for these individuals to track every issue created to prevent duplicate issues from being created or link existing issues to new ones.
- Also defining the done-criteria for each issue according to organizational standards is an issue.
- We have created this autoScrum application that will allow users to specify the details of the product, and scrum practices as the context to the agent and ask the agent to perform several tasks such as creating, updating, and deleting issues.
- The agent can also process example transcripts from meetings to identify tasks and perform them, making it easier for users to process scrum documents.

Simple Architecture Diagram: <br>
![autoScrum_arch](https://github.com/CPAD2023/CPAD2023SecBTeam10/assets/66842711/59285227-7745-4116-ae35-eb8d9a4dd33f)

Tech Stack
- OpenAI and Langchain for LLM tasks.
- ChromaDB for vector databases in RAG (powered by sentence transformers).
- Flask for API services.
- Server hosted on EC2, with a warm stand-by and configured Elastic IP.
- Database on hosted on: RDS with postgreSQL engine.
- Docker for defining images and docker-compose for creating interactable services.
- Flutter and Dart for Frontend
- Xcode for building the application for ios simulators


### How To:
Run Backend: (starts local server)
1. git clone https://github.com/CPAD2023/CPAD2023SecBTeam10.git
2. cd CPAD2023SecBTeam10/backend/app/agents
3. vi .env - replace the openAI key here.
4. cd ../../local
5. docker-compose up --build
6. Once the server is up, send a GET request to http://localhost:8080/hi to test if the server is running.

Run frontend:
1. cd CPAD2023SecBTeam10/frontend
2. flutter clean
3. flutter pub get
4. flutter create .
5. cd lib
6. flutter run
