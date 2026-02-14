--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE app;
ALTER ROLE app WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:fO40woegWhYmi8zUsEcmzQ==$vDAAd15JRA6WF+E+O68roCPbsvGdUKQwTLLYwb1dmLk=:GHaTANwZeMBA4Q/nXSufxsDM8xRdv+wNYEv6nFXi5D0=';
CREATE ROLE portfolio;
ALTER ROLE portfolio WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:itBlXQheiRJkxEOtxKZF8w==$f8CjayOXvbn9In2/7TPs4+knqBLeUHa2uSKNFMQphQo=:VgiH+AD4Q3EFSf29Wl8yjZXpFfrXUh8/8s1VTObNUek=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:KWoa88vHgbZxjtr8WmEAYg==$C/ghNuusLsleyWZAR45XNcKt/+/jZHgaasWoBchZiX4=:DVDyLT932TkewIrpB0sBYjqPamwlDxVh/qSW2hH2EkU=';
CREATE ROLE streaming_replica;
ALTER ROLE streaming_replica WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN REPLICATION NOBYPASSRLS;
COMMENT ON ROLE streaming_replica IS 'Special user for streaming replication created by CloudNativePG';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-2.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-2.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "app" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-2.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-2.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: DATABASE; Schema: -; Owner: app
--

CREATE DATABASE app WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';


ALTER DATABASE app OWNER TO app;

\connect app

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "portfolio" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-2.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-2.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: portfolio; Type: DATABASE; Schema: -; Owner: portfolio
--

CREATE DATABASE portfolio WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';


ALTER DATABASE portfolio OWNER TO portfolio;

\connect portfolio

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: portfolio
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO portfolio;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    owner character varying(255),
    repo character varying(255),
    description character varying(255),
    languages character varying[] DEFAULT (ARRAY[]::character varying[])::character varying(255)[],
    topics character varying[] DEFAULT (ARRAY[]::character varying[])::character varying(255)[],
    readme text,
    "imageUrl" text,
    "projectCreatedAt" timestamp with time zone,
    "projectUpdatedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255),
    "iconPath" character varying(255),
    type character varying(255),
    "subType" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: testimonials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testimonials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255),
    message character varying(255),
    name character varying(255),
    designation character varying(255),
    "imagePath" character varying(255),
    rating integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.testimonials OWNER TO postgres;

--
-- Name: works; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.works (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "order" integer,
    "iconPath" character varying(255),
    title character varying(255),
    subtitle character varying(255),
    period character varying(255),
    description character varying(255),
    items character varying[],
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.works OWNER TO postgres;

--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, owner, repo, description, languages, topics, readme, "imageUrl", "projectCreatedAt", "projectUpdatedAt", "createdAt", "updatedAt") FROM stdin;
177273046	fayadchowdhury	IUText	IUText repository. Commit to test. If the commit is functional and required, it shall be merged into master.	{C,C++}	{}			2019-03-23 10:05:03+00	2019-03-23 10:05:05+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
858974857	fayadchowdhury	neural-network-scratch	Trying to create a neural network from scratch because (1) good practice and (2) why not?	{"Jupyter Notebook"}	{}			2024-09-17 21:20:12+00	2024-09-18 17:07:34+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1084506934	fayadchowdhury	infoblox-ai-flex	\N	{"Jupyter Notebook",Python}	{}	# Infoblox — AI + DDI Take‑Home (Option 3: Data Cleaning via LLM)\n\n## Challenge\nClean, normalize, and enrich `inventory_raw.csv` into a structured dataset fit for IPAM/DNS/DHCP workflows. Use deterministic rules first; use LLMs only where rules are weak. Log every prompt and explain your iterations briefly.\n\n## Deliverables\n1. `inventory_clean.csv`\n2. `anomalies.json`\n3. `prompts.md`\n4. `approach.md`\n5. `cons.md`\n6. `run.py` or `run.sh`\n7. (Optional) `ddi_ideas.md`\n\n## Target Schema\n```\nip, ip_valid, ip_version, subnet_cidr,\nhostname, hostname_valid, fqdn, fqdn_consistent, reverse_ptr,\nmac, mac_valid,\nowner, owner_email, owner_team,\ndevice_type, device_type_confidence,\nsite, site_normalized,\nsource_row_id, normalization_steps\n```\n\n## Provided\n- `inventory_raw.csv` (synthetic)\n- `run_ipv4_validation.py.txt` (example IPv4 normalization)\n- `TEMPLATES/` (documents to fill)\n- `run.py.txt` (orchestrator you can extend)\n		2025-10-27 19:17:36+00	2025-10-28 03:19:03+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
284666583	fayadchowdhury	RetrofitTest	\N	{Kotlin}	{}			2020-08-03 10:07:43+00	2020-09-08 17:13:19+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1019755991	fayadchowdhury	spark-jobs	Central repository to hold experimental PySpark jobs	{"Jupyter Notebook",Dockerfile}	{data,docker,python,spark,show}	![Banner](./assets/featured-image.png)\n\nThis repository is going to house all of my experimental PySpark scripts. I may set up a CI/CD pipeline to build Docker images with required JARs later.\n\n### TL;DR\n- Custom JARs to connect with Minio\n- Optimized Dockerfiles for SparkOnK8s\n- Docker Compose to set up 1 master and 2 workers\n\n## Setup\n\nClone this repository and do poetry install.\n\nTo run the Spark containers based on the image I build, refer to the [spark-image](#spark-image) section below.\n\n## Structure\n\nThe experiments/ folder contains all the Jupyter notebooks and the spark-image/ directory houses the latest Dockerfile and other binaries that I bundle with my version of Spark, and the rest of the files are according to their standard definitions in Python Poetry projects and Github repositories.\n\n## .env\n\nCreate a .env file in the root of this project and fill in the following values:\n\n- SPARK_MASTER: The endpoint for the Spark master (if you're deploying based on the commands I provided above, this will be spark://localhost:7077/)\n- MINIO_ENDPOINT: The endpoint for the Minio installation\n- MINIO_USER: The user for the Minio installation\n- MINIO_PASSWORD: The password for the Minio installation\n\n## Spark-image\n\nTo build the Docker image, just run docker build -t <repo>/<project>:<tag> spark-image.\nAnd then run it, forwarding ports (7077 for master, 8080 for worker etc.) and configuring as required.\nFor example, to deploy one master and one worker:\n\n```code\ndocker network create spark-net # To create a Docker network where the containers can access each other by their host names\n```\n\n```code\n# To run the master\ndocker run -d \\\n  --name spark-master \\\n  --network spark-net \\\n  -p 7077:7077 -p 8080:8080 \\\n  <repo>/<project>:<tag> \\\n  bash -c "/opt/spark/sbin/start-master.sh && tail -f /opt/spark/logs/\\*.out"\n```\n\n```code\n# To run the worker\ndocker run -d \\\n  --name spark-worker-1 \\\n  --network spark-net \\\n  -e SPARK_WORKER_CORES=2 -e SPARK_WORKER_MEMORY=2g \\\n  -p 8081:8081 \\\n  <repo>/<project>:<tag> \\\n  bash -c "/opt/spark/sbin/start-worker.sh spark://spark-master:7077 && tail -f /opt/spark/logs/\\*.out"\n```\n\nOr simply use Docker Compose. The docker-compose.yaml file sets up 3 things:\n\n- A spark-net network for the containers in the compose deployment to communicate with each other\n- 1 spark-master container\n- 2 spark-worker containers\n\n```code\ndocker compose up -d\n```\n\nI will set up CI/CD later.\n	https://raw.githubusercontent.com/fayadchowdhury/spark-jobs/master/assets/featured-image.png	2025-07-14 20:26:22+00	2025-09-10 06:40:11+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
576267179	fayadchowdhury	cherie-api	API for Cherie	{Python,PowerShell,C,CSS,JavaScript,Batchfile,Procfile}	{scripting,web}	This is the official github repository for the API for Cherie. Any push made to main will automatically be deployed to Heorku (unless something breaks).\n		2022-12-09 12:14:57+00	2025-09-09 23:58:57+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1040577029	fayadchowdhury	airflow-dags	\N	{Python}	{}	# airflow-dags		2025-08-19 07:33:12+00	2025-08-22 06:27:55+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
952160439	fayadchowdhury	airflow-weather-etl	A project to experiment with ETL pipelines in Apache Airflow using weather data from OpenMeteo	{"Jupyter Notebook",Python}	{airflow,data,show}	A project to experiment with ETL pipelines in Apache Airflow using weather data from OpenMeteo.\n\n### TL;DR\n- Airflow DAG fetching data from OpenMeteo API, transforming and pushing to Postgres in ETL pipeline\n- Airflow and Postgres running in Docker containers for concern isolation\n- TaskFlow API leveraged for clean, readable code\n\n## Project Overview\n\nThis project explores ETL on weather data using Apache Airflow to orchestrate the different tasks. The basic setup includes:\n\n1. **Apache Airflow**: Running as a container on a server on my network, where DAGs are submitted via a network directory share.\n2. **Postgres Database**: Running as a container on the same server to store transformed weather data.\n3. **ETL DAG**: Written in Python to acquire weather data (temperature, precipitation probability, and relative humidity), transform it, and store it in the Postgres database.\n\n## Setup with poetry\n\nAlthough technically we don't need to set up a full environment since we submit our DAGs to an Airflow container that already has everything set up correctly, we will be doing some experimentation in some Jupyter notebooks and poetry environments are the way to go\n\n## Connections\n\nTo set up the connection to the OpenMeteo API, we go into Airflow Web UI > Admin > Connections and create a new connection. Under connection ID, we type in the name that we use to refer to the connection in our DAG ("openmeteo_api" in our case) and select "HTTP" under connection type. Since we pass in the endpoint in code (making it easier to switch to different versions of the API hosted on the same domain and subdomain), we type in "[https://api.open-meteo.com/](https://api.open-meteo.com/). That should set things up normally.\n\nTo set up the connection to the Postgres database, we go into Airflow Web UI > Admin > Connections and create a new connection. Under connection ID, we type in the name that we use to refer to the connection in our DAG ("postgres" in our case) and select "Postgres" under connection type. Because we are also running the Postgres database as a Docker container, we type in "host.docker.internal" under host and provide the username, password, database name (or schema) and port number per usual. That should set things up normally.\n\n## Lessons\n\n1. TaskFlow API makes the code much easier to read and write with the dag and task decorators compared to the traditional way of setting a context with DAG.\n2. Apache Airflow is used as a workflow orchestrator and ideally data should not be passed between taskes via XCom (the source code also has a limit of 48KB set for data that can be transmitted between tasks using XCom). While this case was a simple exploration, ideally data would be stored in multiple buckets as it is processed in stages, and only some amount of metadata or flags would be passed between tasks.\n3. try-except blocks in tasks don't throw errors the way this code is written. We need to think of better error handling mechanisms in the pipeline.\n4. If we're connecting to Postgres (or possibly other containers on the same machine (??)), under host, we need to type in host.docker.internal to access Docker's internal network\n		2025-03-20 20:38:14+00	2025-09-10 06:18:15+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
281036961	fayadchowdhury	Appointment	\N	{Kotlin}	{}	# Appointment\n\nThe android app repository for Appointment\n\nOur app helps you create and manage appointments and medical history easily. The best part - it's all in the palm of your hand!\n\nTo compile the project yourself\n\n1. Fork to your account\n2. git clone https://github.com/ACCOUNT_NAME/Appointment\n3. Open up in Android Studio and compile\n\nIf you wish to contribute, and we welcome contributions with open arms, just drop a pull request :)\n\nFor a better explanation of the app, go through [this](https://docs.google.com/document/d/1J8R6ytla1cmTxWxvwleRP0GKfbi9EG8wTHkbm13XSME/edit?usp=sharing) document. \n		2020-07-20 06:47:41+00	2020-09-19 10:11:34+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
250088909	fayadchowdhury	appointment-backend	\N	{JavaScript}	{}			2020-03-25 20:53:07+00	2020-04-20 18:06:59+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
272427678	fayadchowdhury	appointment-backend-revamp	\N	{JavaScript}	{}			2020-06-15 12:04:22+00	2021-01-21 17:05:26+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
296000736	fayadchowdhury	BattleShip	Repo for BattleShip AR mobile game, mostly made in Unity 	{ASP.NET,C#,ShaderLab}	{}			2020-09-16 10:32:29+00	2020-09-16 10:34:30+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
205596052	fayadchowdhury	CarryMe-Android	The Android app repository	{Kotlin}	{}			2019-08-31 21:03:41+00	2020-03-24 22:32:11+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
515296580	fayadchowdhury	node-server-raw	Raw Node.JS server	{JavaScript}	{backend,show,web}	Raw Node.JS server without ExpressJS\n\n<h2><u><b>To run the project</b></u></h2>\n\n    node app.js\n\nThis creates a node server that starts its event loop and keeps running while there are listeners registered.\n		2022-07-18 18:23:52+00	2025-09-10 00:57:48+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
955149546	fayadchowdhury	personal-portfolio	React, tailwind, three.js, GSAP frontend for portfolio site	{TypeScript,CSS,JavaScript,HTML}	{featured,frontend,web,show}	![Frontend](./assets/featured-image.png)\n\nThe frontend for my portfolio site is built on React, tailwind, three.js and GSAP.\n\nIt's built on the principles of resuable components that are populated with props and all-round reusability and portability from an easily editable data store.\n\nGithub Actions takes care of my CI/CD process including deployment to AWS EC2.\n\nThere will be a blogs section soon and more CMS-like control in the future.\n\n### TL;DR\n- React, tailwind, three.js. GSAP\n- Easily editable with data stores and/or API\n- CI/CD via Github Actions to deploy to AWS EC2\n- WIP!\n	https://raw.githubusercontent.com/fayadchowdhury/personal-portfolio/master/assets/featured-image.png	2025-03-26 07:24:45+00	2025-09-12 00:50:09+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
212863025	fayadchowdhury	AdminPanel	General purpose admin panel for database management WIP	{Java}	{}			2019-10-04 16:55:31+00	2019-10-07 18:06:57+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
992199581	fayadchowdhury	semantic-book-recommender	Generate book recommendations based on cosine similarities on embeddings	{"Jupyter Notebook",Python}	{data-science,nlp,openai,recommender-system,transformers,data,featured,show}	![Runtime screenshot](./assets/featured-image.png)\n\nThis project uses a vector database (Chroma) to perform similarity search on embedded book dsecriptions and recommend books accordingly, filtered on the categories of fiction and/or non-fiction and the tone of the description. Throughout the project, as outlined in the notebooks, there are quite a few techniques used commonly in NLP projects, including various forms of data cleaning and augmentation, primary analysis to understand possible bias scopes, zero-shot text classification using pretrained BART and sentiment analysis using fine-tuned DistilRoBERTa. The end result is a Gradio app that can take in a user query and a few parameters like category, emotion etc. to generate a few recommendations.\n\nThis is based largely on the tutorial [here](https://youtu.be/Q7mS1VHm3Yw?si=ev73DlkrbTk4y8di) with a few changes from my own experimentation! Most if not all credits are due there!\n\n### TL;DR\n- LangChain and OpenAI for text chunking and embedding\n- Chroma as persistent vector store and cosine similarities\n- Zero-shot classification of book category using bart-mnli-large\n- Fine-tuned classification of emotion using emotion-english-distilroberta-base\n- Gradio UI for interaction with model output\n- Well-documented, manageable monolithic app\n\n## Setup and run\n\nClone the repository using\n\n```\ngit clone https://github.com/fayadchowdhury/semantic-book-recommender.git\n```\n\nInstall the dependencies using Poetry (to install poetry, refer to the [official documentation](https://python-poetry.org/docs/))\n\n```\npoetry install\n```\n\nSet up an OpenAI project and obtain an API key and paste that in a .env file as\n\n```\nOPENAI_API_KEY="api_key"\n```\n\nTo start the Gradio app\n\n```\npoetry run python3 app.py\n```\n\nThe Gradio app is then available on http://localhost:7860\n\n## Details\n\nThe idea behind this project is to find books with descriptions similar to the user's query or requirements. The descriptions are chunked by a CharacterTextSplitter, embedded using OpenAIEmbeddings and stored in a Chroma vector database. The user's query is also embedded using the same function and then a similarity search is performed against the vector database to return the top initial_k books with close descriptions. From there the system filters by category (fiction/non-ficiton/both for now) and ranks by the tone or emotion that the user is going for and returns the top final_k results with a thumbnail (displaying the cover-not-found asset photo if the URL does not exist) and a caption (author(s), title and first 30 words of description) in a Gradio UI.\n\n### Dataset\n\nThe dataset in use is the [7k books dataset from Dylan J Castillo](https://www.kaggle.com/datasets/dylanjcastillo/7k-books-with-metadata). This dataset is constructed using the ISBNs from another dataset ([Soumik's Goodreads-books dataset](https://www.kaggle.com/jealousleopard/goodreadsbooks)) and querying Google Books API to extract the information. The author notes that there are several ISBNs that return invalid results which is why there are 6810 records instead of the 10352 records in the other dataset.\n\n### Exploratory Analysis Findings:\n\n- The columns or attributes in the dataset are: isbn13, isbn10, title, subtitle, authors, categories, thumbnail, description, published_year, average_rating, num_pages, ratings_count\n- Of these, the columns of interest in building a semantic recommendation engine would be subtitle and description (assuming the user has no preferecnes for authors) but the subtitle column had quite a few null values (almost 2/3) so description proved to be the better choice (96% non-null)\n- Some records in the dataset showed consistencies in the attributes they were missing (num_pages, ratings_count, average_rating), but they were not too instrumental in this project, so they could be ignored\n- 303 rows where either num_pages, description, average_rating, published_year or any subset of these were missing were eliminated to have a more complete dataset\n- While there was a long tail towards longer lengths of description, most were between 20 and 100 words long and so choosing a minimum cutoff of 25 words proved to be a good measure\n- There were a lot of incredibly specific categories that applied to an incredibly small subset of books and they would be largely useless and lead to class imbalances for the classifiers, so only those categories that showed up more than 50 times throughout the dataset were analyzed and grouped into fiction and non-fiction while the rest were predicted with a classifier later in the pipeline\n\n### Cleaning and augmentation\n\nThe raw books.csv dataset undergoes a series of cleaning and augmentation steps for completeness:\n\n- Removing rows where num_pages, description, average_rating, published_year or any subset of those are missing\n- Removing rows where the description is less than 25 words long\n- Joining title and subtitle to form more concrete book names\n- Adding "&fife=w800" to thumbnail URLs where they are present or replacing the URL with the location of the cover-not-found.jpg asset picture where they are missing\n- Dropping unnecessary columns ("title", "subtitle")\n- Mapping categories that show up more than 50 times throughout the dataset to either "fiction" or "non-fiction"\n- Adding "fiction" or "non-fiction" category values to those missing those values using a zero-shot classifier\n- Adding columns describing the score for each of the emotions of (after a mapping) "joy", "surprise", "anger", "fear", "sadness", "neutral" using a fine-tuned classifier\n\n### Zero-shot category classification\n\nEven after the category mapping to "fiction" and "non-fiction" there are quite a few records with those missing because their original categories where hyper-specific. In these cases, a zero-shot classifier was used to predict the category based on the "description" text.\n\nThe model used was facebook/bart-mnli-large and the label (out of "fiction" and "non-fiction") with the highest probability was chosen. The accuracy measured against categories assigned previously as ground truths was 65.5%, which was not the best but it could be made better with a more fine-tuned model.\n\n### Fine-tuned emotion/tone classification\n\nTo assign emotions or tones, a fine-tuned classifier was used. j-hartmann/emotion-english-distilroberta-base was used in a text classification pipeline to generate emotion scores for the emotions "surprise", "neutral", "fear", "joy", "anger", "disgust" and "sadness" and those values were added as separate columns to each row.\n\nIn terms of accuracy, it achieves an evaluation accuracy if 66% compared to a baseline of 14% according to [this](https://dataloop.ai/library/model/j-hartmann_emotion-english-distilroberta-base/).\n\n### Chunking, embedding and vector databasing\n\nNormally, there are more effective chunking strategies than splitting on characters or a delimiter (semantic chunking for instance), each with its own use case. For this particular use case, where the description can be considered one continuous document/text body less than 200 words long (usually), a simple newline delimiter based chunking strategy works fairly well.\n\nEmbedding functions are used to numerically represent the text bodies they embed. Commonly OpenAI's text-embedding-ada-002 is used but SentenceTransformers and other LLM's embedding layers may also be used, the more domain-specific, the better. This project uses text-embedding-ada-002.\n\nA vector database stores vectors along with some metadata, making it the perfect candidate to store NLP embeddings, which are many dimensional vectors, with some identifier metadata. This project uses Chroma as the vector store and also saves a local copy of it for persistence through future runs. During retrieval, a cosine similarity metric is used to compare the embedded user query against similar document embeddings and return the ones most similar.\n\n### Gradio UI\n\nThe main app entry-point sets up a Gradio UI served at http://localhost:7860. As shown in the screenshot, the UI has\n\n- A TextBos to take a user query\n- A Dropdown to pick the category\n- A Dropdown to pick the tone\n- A Slider to set a value for initial_k\n- A Slider to set a value for final_k\n- A Button to take all of the inputs and pass them to the function to generate recommendations\n- A Gallery that displays thumbnails and a caption associated with the books being recommended\n\nThis is a very basic UI and can definitely be made even better, but the purpose of Gradio is to quickly demonstrate the output of code without having to draw up complex frontends, making it very useful for demo-ing AI work.\n\n### Logging\n\nThere are 4 handlers and 3 loggers used:\n\n- console for DEBUG statements from the root app\n- logs/app.log for DEBUG statements from the root app\n- logs/models.log for DEBUG statements from the classifier models\n- logs/etl.log for DEBUG statements from the ETL processes\n\nThe loggers are attached to from the individual modules and most of the logging is DEBUG statements for now, but there should be improvements to this in future iterations.\n\n## Directory structure\n\nWhile the initial experiments and all future experiments relevant to this project will probably be found in notebooks in the experiments/ folder, the actual app is a monolith with a single entry-point with components separated out into different folders. This section will serve as an overview since the individual files are decently documented.\n\n- assets/ - This directory holds the static assets - the screenshot used in this README and the cover-not-found photo\n- config/ - Currently this holds just the logger, but I plan to take a more object-oriented approach to this project where it may house more config objects\n- data/ - This holds a few CSVs generated from the notebooks as well as an input/ directory housing the raw input data (books.csv), and running the app will also generate an output/ directory housing a vector_db folder and a few more CSVs resulting from the ETL process\n- experiments/ - This houses the experimental notebooks\n- logs/ - This houses the log files from the app, the ETL process and the classifier models\n- processing/ - This houses most of the ETL code separated into extract.py, transform.py, load.py and an additional models.py to load and cache the classifier models\n- utils/ - This houses a few utility functions separated out into reelvant files (UI functions in ui_functions.py for example)\n- app.py - This is the single entry point and houses most of the constants, the entire control flow of the ETL process and the Gradio UI code\n- poetry.lock - The Poetry lock file configuring the dependencies for this project\n- pyproject.toml - This is where the dependencies are defined, or simply use poetry add <package_name>\n\n## TODO\n\n1. Fine-tune category classifier\n2. Set up incremental/batch processing pipeline for future books\n3. You tell me!\n	https://raw.githubusercontent.com/fayadchowdhury/semantic-book-recommender/master/assets/featured-image.png	2025-05-28 19:18:52+00	2025-09-10 06:39:03+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
177268667	fayadchowdhury	TripTREK	The actual app repository	{Java}	{}			2019-03-23 09:19:05+00	2019-03-23 09:19:08+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
180014088	fayadchowdhury	IUTilities	\N	{Kotlin}	{}	# IUTilities\n		2019-04-07 19:36:34+00	2019-07-20 18:31:42+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1046584314	fayadchowdhury	personal-portfolio-backend	Node, Express, Sequelize monolithic backend for portfolio site	{TypeScript}	{backend,featured,web,show}	![Backend](./assets/featured-image.png)\n\nThe backend for my portfolio site is built on Node, Express, TypeScript and Sequelize for an ORM.\n\nIt looks after my mailing service using Nodemailer and syncs with my Github repositories using Octokit to supply data for my site's Projects section.\n\nGithub Actions takes care of my CI/CD process including deployment to AWS EC2.\n\nIt is built to be modular and while it is monolithic now, I plan on splitting it out into isolated components that I will orchestrate as microservices.\n\n### TL;DR\n- Node, Express, TypeScript, Sequelize ORM\n- Nodemailer mailing service, Octokit Github project sync service\n- CI/CD via Github Actions to deploy to AWS EC2\n- WIP!\n	https://raw.githubusercontent.com/fayadchowdhury/personal-portfolio-backend/master/assets/featured-image.png	2025-08-28 22:55:54+00	2025-09-12 00:33:03+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1055763876	fayadchowdhury	rags-to-riches	Building a RAG pipeline sourcing knowledge from NLP course materials to build revision guides	{"Jupyter Notebook",HTML,Python,Shell}	{featured,nlp,rag,show}	![Frontend](./assets/featured-image.png)\n\nRetrieval-Augmented Generation, or RAG, has led to leaps and bounds in improvements in the Natural Language Processing scene. This project explores the use of RAG systems in an academic setting. Leveraging course materials and research papers commonly discussed in graduate level NLP courses at a variety of educational institutions, the RAG system aids students’ understanding of NLP. At its core, the project is an exploration in the tasks of question answering and synthetic question generation.\n\n### TL;DR\n\n- RAG pipeline fed with and ingesting NLP materials to help prep for grad-level NLP courses\n- Modular pipeline to easily swap out components like parsers, chunkers, embedders, vector stores, retrievers, generators, prompts etc.\n- MLflow experimentation pipeline to run trials on different prompts and LLM calls\n- Streamlit chat UI with session persistence\n\n## Motivation\n\nThe average human reads at around 250 words per minute. For a 7000 word research paper, that amounts to around 28 minutes to just go through the paper, and even longer to understand the content fully. In graduate level NLP courses, there are likely to be a large number of such research works, lecture slides, web pages, code, documentation etc. to go through for the duration of the course. One may quickly become overwhelmed with the thought of covering all of this content and fail to perform to their full potential.\n\nThis RAG system can equip an LLM (GPT-4o for example) with knowledge from course materials (web pages, documentation, PDFs, Python notebooks, Python code etc.) and research papers to answer questions previously encountered in assessments (mid-terms, sample questions etc.). It is also able to generate sample questions based on the content provided. The former task will allow students in NLP courses to strengthen their understanding with solutions and logical approaches to questions and the content they referred to, and the latter will assist them with preparing for their own assessments by adding to the pool of sample questions that they can attempt to test the breadth of their knowledge.\n\n## Approach\n\nThe approach is divided into three segments\n\n- Creating the RAG pipeline\n- Evaluating the system's performance in a series of MLflow experiments\n- Creating a Streamlit UI to mimic a chat-like interface to interact with the system\n\n### Creating the RAG pipeline\n\nThe pipeline consists of a set of parsers, a chunker, an embedder, a vector database/store, a retriever and an LLM call (a generator). The pipeline is built in a way that any of these components can be easily swapped in for other variants, by instantiating class objects accordingly. For example the Pinecone vector database can be swapped for a Chroma vector database by using ChromaVectorStore instead of PineconeVectorStore, both of which are abstracted in BaseVectorStore. It is also possible to configure individual components using YAML files which are loaded at runtime.\n\nThe pipeline's components achieve the following:\n\n#### Parsing and chunking materials\n\nThe input materials are parsed and divided into smaller, coherent chunks to ensure meaningful embeddings. Metadata such as the chunk text, its position in the source document, and the document type are retained for traceability.\n\nThere are parsers in place for PDFs, Python notebooks, HTML files and specifically formatted CSVs.\n\n#### Embedding chunks and storing on vector database\n\nAn embedder then takes the chunks of texts and generates embeddings (vectorizes) for each chunk to store in a vector database of choice.\n\nPrimarily, OpenAI's `text-embedding-ada-002` model is used to generate embeddings for each chunk. These embeddings may be stored in Pinecone or Chroma, along with associated metadata.\n\nLet:\n\n- $ C = \\{c_1, c_2, \\ldots, c_n\\} $ be the set of chunks.\n- $ E*C = \\{e*{c*1}, e*{c*2}, \\ldots, e*{c*n}\\} $ be the corresponding embeddings generated by the model, where \\( e*{c_i} \\in \\mathbb{R}^d \\).\n\nThe Pinecone database stores pairs $ \\{(e*{c_i}, \\text{metadata}\\_i)\\}*{i=1}^n $.\n\n#### Query embedding and retrieval\n\nAt runtime, user queries $ q $ are embedded into the same vector space as the chunks using the embedding model:  \n$ e_q = \\text{Embedding}(q) \\quad \\text{where} e_q \\in \\mathbb{R}^d. $\n\nTo identify relevant chunks:\n\n1. Compute cosine similarity between the query embedding $ e*q $ and all chunk embeddings $ e*{c*i} $:  \n   $\n   \\text{CosineSim}(e_q, e*{c*i}) = \\frac{e_q \\cdot e*{c*i}}{\\|e_q\\| \\|e*{c_i}\\|}\n   $\n2. Retrieve the top-k most similar chunks $ \\{c*{t_1}, c*{t*2}, \\ldots, c*{t_k}\\} $ based on the similarity scores.\n\nAlthough, now the project relies entirely on Top-K retrieval, there are other retrieval mechanisms that can be explored like agentic retrieval.\n\n#### Augmenting a prompt and generating a response\n\nThe retrieved chunks are combined with the query and fed to an LLM, in this case `gpt-4o-mini`, using a carefully designed prompt to generate a response.\n\n### Evaluating performance\n\nPerformance is evaluated using a series of MLflow experiments that can be easily configured using YAML files. MLflow serves as an efficient tracking system for each experimental run.\n\nThe experiment can be run from the root directory with:\n\n```\npython3 -m experiments.run_experiment <experiment-config-dir>\n```\n\nwhere experiment-config-dir is a folder in experiments/configs housing all the config files for the experiment (parsers.yaml, chunker.yaml, embedder.yaml, vector_store.yaml, retriever.yaml, generator.yaml, evaluator.yaml, experiment.yaml). These YAML files control the experiment:\n\n- parsers.yaml: Controls the kind of concrete parser to instantiate for each kind of supported file and the configuration to be passed to each\n- chunker.yaml: The type of chunker to be used and the configuration to be passed to it\n- embedder.yaml: The type of embedder to be used and the configuration to be passed to it\n- vector_store.yaml: The type of vector database/store to be used and the configuration to be passed to it\n- retriever.yaml: The type of retriever to be used and the configuration to be passed to it\n- generator.yaml: The generator LLM to be used and the configuration (including the path to the system prompt and the question-answering prompt template)\n- evaluator.yaml: The type of evaluator to use (primarily the LLM to use as a judge) and the configuration (including the path to the system prompt and the question-answering prompt template) to be passed to it\n- experiment.yaml: The data, check queries and their relevant docs to be used in the experiment\n\nThe MLflow runs, although basic, list down some metrics, parameters and artifacts stored as a result of the experimental run. The UI can be accessed using:\n\n```\nmlflow ui\n```\n\nPrimarily, the pipeline is evaluated on:\n\n#### Accuracy of retrieval\n\nUsing `Precision@k` and `Recall@k`, we measure how accurately our system can refer to and retrieve relevant documents from the database\n\n`Precision@k`  \nMeasures the proportion of relevant chunks in the top-\\(k\\) retrieved chunks:  \n$\n\\text{Precision@k} = \\frac{\\text{Number of relevant chunks in top-}k}{k}\n$\n\n`Recall@k`\nMeasures the proportion of all relevant chunks that appear in the top-\\(k\\):  \n$\n\\text{Recall@k} = \\frac{\\text{Number of relevant chunks in top-}k}{\\text{Total number of relevant chunks}}\n$\n\n#### Accuracy of generation\n\nResponses generated by the system are evaluated using a secondary LLM (`gpt-4o-mini`), which serves as a judge basing its responses on provided samples. The judgement is on the following criteria:\n\n- Factual correctness: Whether the generated answer is factually correct based on the context provided\n- Completeness: Whether the generated answer is complete in addressing the query\n- Reliance: Is the generated answer reliant solely on the retrieved context\n- Overall_accruacy: An overall accuracy score out of 100\n\n### Creating the Streamlit UI\n\nInteractions with the pipeline are done via the Streamlit UI.\n\nThe components of the pipeline are configured similary with YAML files (except there is no experiment adn evaluation here, so there are no experiment.yaml and evaluator.yaml files).\n\nThe UI is composed of elements that can be modified better in their individual classes. This leads to separation of concerns and allows more separation of concerns.\n\nThe UI does need a database to store session and message info, and to that end, an SQLite database is used, although it is entirely possible to switch to other databases.\n\nTo run the UI\n\n```\npython3 streamlit run app.py\n```\n\n## Data\n\nThe primary data were the CMPT-713 lecture PDFs, reference web pages, research papers, sample QAs and code as our source of LLM knowledge; these were the documents ingested into our RAG pipeline. The data is found in the data/input/full folder. Subsets of the data are also found in the data/input/subset and data/input/ones folders.\n\n## Setup and running\n\nPlace the following in a .env file:\n\n- OPENAI_API_KEY=openai_api_key\n- PINECONE_API_KEY=pinecone_api_key\n- PINECONE_INDEX_NAME=pinecone_index_to_be_used_with_pinecone_vector_store\n- DB_DATABASE=sqlite_db_location (later versions will also work with other database systems)\n\nInstall poetry and run\n\n```\npoetry install\n```\n\nIt is also possible to extract the library requirements from the pyproject.toml file or the poetry-lock.toml file into a requirements.txt and then run\n\n```\npip3 install -R requirements.txt\n```\n\n### Experiments\n\nFirst, create a folder in experiments/configs to reflect the name of the experiment (<experiment_name>) to house the config files.\n\nCreate another folder with the same name in experiments/prompts to house the prompt templates.\n\nRun the experiment with:\n\n```\npoetry run python3 -m experiments.run_experiment <experiment_name>\n```\n\nThe experiment_name must reflect the name of the folders created in the previous step\n\nTo view the metrics in MLflow, run\n\n```\npoetry run mlflow ui\n```\n\nAnd navigate to the mlflow local server (usually http://127.0.0.1:5000) to view the experiment\n\n### App\n\nEdit the config files in config/ to reflect the configuration desired.\n\nRun\n\n```\npoetry run streamlit run app.py\n```\n\nThere are delays where the app is processing things in the background\n\n## TODO\n\n- Make UI more informative, possibly via spinners to explain what the app is doing while input is blocked\n- Look into async programming for summaries and title generation\n- Implement a more generic CSV parser\n- Implement recursive chunking and a few other kinds of chunking strategies\n- Implement Weaviate, Milvus and a few other vector stores\n- Implement BM25 and agentic retrieval\n- Implement calls to Claude, ollama models etc.\n- Implement Postgres, MySQL and a few other kinds of app databases\n	https://raw.githubusercontent.com/fayadchowdhury/rags-to-riches/master/assets/featured-image.png	2025-09-12 19:08:27+00	2025-10-09 16:52:59+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
919673671	fayadchowdhury	real-time-stock-data-analysis	Based on the tutorials by Darshil Parmar, with maybe a few tweaks of my own	{"Jupyter Notebook",Python}	{aws,data,kafka,show,streamlit}	This project is a monolithic application that fetches stock data using the `yfinance` API, processes it in real-time with Kafka, and provides a Streamlit-based UI for monitoring system health. The app runs as a service with the producer and consumer running on individual threads.\n\n### TL;DR\n\n- Real-time stock data ingestion using Kafka streams\n- Streamlit UI with live health checks\n- AWS Glue + Athena integration for analytics\n\n## Installation and Running the App\n1. Clone the repository:\n   ```bash\n   git clone https://github.com/fayadchowdhury/real-time-stock-data-analysis.git\n   cd real-time-stock-data-analysis\n   ```\n2. Install dependencies:\n   ```bash\n   poetry install --no-root\n   ```\n3. Run the Streamlit dashboard:\n   ```bash\n   poetry run streamlit run main.py\n   ```\n\nThe Streamlit UI provides health checks including:\n- Last lines of the pull, push, consumer, and producer logs\n- Timestamp of the last fetched data\n- Last few records of fetched data\n\n## Setting Up Kafka on EC2\n\n### 1. Set Up the EC2 Instance\n1. Set up an EC2 instance on the free tier.\n2. Log in using EC2 Connect.\n\n### 2. Install Prerequisites\n1. Install Amazon Corretto 11:\n   ```bash\n   sudo yum install java-11-amazon-corretto-headless\n   ```\n2. Download Apache Kafka:\n   ```bash\n   wget https://downloads.apache.org/kafka/3.7.2/kafka_2.12-3.7.2.tgz\n   ```\n3. Extract the Kafka archive:\n   ```bash\n   tar -xvf kafka_2.12-3.7.2.tgz\n   ```\n\n### 3. Configure Kafka\nEdit the `config/server.properties` file to update the `advertised.listeners` hostname to the EC2 public IP. *(Consider using an Elastic IP for persistence.)*\n\n### 4. Start Zookeeper\n#### Option 1: Start Manually\n```bash\n<path-to-kafka-directory>/bin/zookeeper-server-start.sh config/zookeeper.properties\n```\n\n#### Option 2: Run as a Service\n1. Create a Zookeeper service file:\n   ```bash\n   sudo nano /etc/systemd/system/zookeeper.service\n   ```\n2. Add the following content:\n   ```ini\n   [Unit]\n   Requires=network.target remote-fs.target\n   After=network.target remote-fs.target\n\n   [Service]\n   Type=simple\n   User=ec2-user\n   ExecStart=/home/ec2-user/kafka_2.12-3.7.2/bin/zookeeper-server-start.sh /home/ec2-user/kafka_2.12-3.7.2/config/zookeeper.properties\n   ExecStop=/home/ec2-user/kafka_2.12-3.7.2/bin/zookeeper-server-stop.sh\n   Restart=on-abnormal\n\n   [Install]\n   WantedBy=multi-user.target\n   ```\n3. Start the service:\n   ```bash\n   sudo systemctl start zookeeper.service\n   ```\n4. Enable the service to start on boot:\n   ```bash\n   sudo systemctl enable zookeeper.service\n   ```\n\n### 5. Start Kafka\n#### Option 1: Start Manually\n1. Set the Kafka heap size:\n   ```bash\n   export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"\n   ```\n2. Start Kafka:\n   ```bash\n   <path-to-kafka-directory>/bin/kafka-server-start.sh config/server.properties\n   ```\n\n#### Option 2: Run as a Service\n1. Create a Kafka service file:\n   ```bash\n   sudo nano /etc/systemd/system/kafka.service\n   ```\n2. Add the following content:\n   ```ini\n   [Unit]\n   Requires=zookeeper.service\n   After=zookeeper.service\n\n   [Service]\n   Type=simple\n   User=ec2-user\n   Environment="KAFKA_HEAP_OPTS=-Xmx256M -Xms128M"\n   ExecStart=/home/ec2-user/kafka_2.12-3.7.2/bin/kafka-server-start.sh /home/ec2-user/kafka_2.12-3.7.2/config/server.properties\n   ExecStop=/home/ec2-user/kafka_2.12-3.7.2/bin/kafka-server-stop.sh\n   Restart=on-abnormal\n\n   [Install]\n   WantedBy=multi-user.target\n   ```\n3. Start the service:\n   ```bash\n   sudo systemctl start kafka.service\n   ```\n4. Enable the service to start on boot:\n   ```bash\n   sudo systemctl enable kafka.service\n   ```\n\n\n\n## Using Kafka\n\n### 1. Create a Topic\n```bash\n<path-to-kafka-directory>/bin/kafka-topics.sh --create --topic topic --bootstrap-server ec2-public-ip:9092 --replication-factor 1 --partitions 1\n```\n\n### 2. Create a Producer\n```bash\n<path-to-kafka-directory>/bin/kafka-console-producer.sh --topic topic --bootstrap-server ec2-public-ip:9092\n```\n\n### 3. Create a Consumer\n```bash\n<path-to-kafka-directory>/bin/kafka-console-consumer.sh --topic topic --bootstrap-server ec2-public-ip:9092\n```\n\n\n\n## AWS Glue Integration\n\n### 1. Set Up Glue Crawler\n1. Assign an IAM role to AWS Glue to access the S3 bucket.\n2. Create a database in Glue to store the crawled metadata.\n3. Set up a crawler to scan the S3 bucket based on metadata schema.\n4. Optionally set up ETL jobs such as getting rid of NULL values and saving as parquet files partitioned on ticker symbol etc.\n\n### 2. Query Data with Athena\n- Use AWS Athena to run SQL queries on the S3 data.\n- Specify an output location for query results in Athena settings.\n\n\n\n## Next Steps\n1. The app now connects to the `yfinance` API instead of AlphaVantage.\n2. Looking into PowerBI for visualization instead of QuickSight.\n3. Confluent wasn't necessary but may be revisited later.\n4. Exploring Infrastructure-as-Code (Boto3, Pulumi) in the future.\n		2025-01-20 19:48:21+00	2025-09-10 22:59:11+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
337504660	fayadchowdhury	noticeboard_api	\N	{JavaScript,Dockerfile}	{}			2021-02-09 18:52:44+00	2021-07-25 06:10:28+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
398202645	fayadchowdhury	PandasNotebooks	\N	{"Jupyter Notebook"}	{}			2021-08-20 08:07:36+00	2021-08-23 21:50:15+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
952377336	fayadchowdhury	pulse-stream	This project explores Azure EventHubs as a data source to be consumed within Databricks and a dashboard set up in PowerBI	{"Jupyter Notebook"}	{azure,data,databricks,show}	![Banner](./assets/featured-image.png)\n\nThis project explores Azure EventHubs as a data source to be consumed within Databricks and a dashboard set up in PowerBI\n\n### TL;DR\n- Real-time event data stream from Azure Event Hubs (relevant in IoT, telemetry, logging etc.)\n- Databricks stream processing in Medallion architecture\n- Live dashboarding in Power BI connected to Databricks\n\n# Azure Event Hubs\n\nAzure Event Hubs is a fully managed, real-time data ingestion service that is simple, trusted, and scalable. It can stream millions of events per second from any source to build dynamic data pipelines and immediately respond to business challenges. Event Hubs can process and store events, data, or telemetry produced by distributed software and devices. It is ideal for applications such as logging, telemetry, fraud detection, and live dashboarding.\n\nWe use this service to simulate data events generation.\n\n1. Event producers: Entities that generate and send data to event hubs. Examples include server applications, IoT devices etc.\n2. Event hubs: This is where data events are sent. There are partitions to segment data to improve parallel processing\n3. Consumer groups and event receivers: These allow different end clients to have different views/access of the data in the event hubs.\n\n# Databricks\n\nDatabricks is built on top of the Data Lakehouse and acts as a unified data analytics platform to process multiple different kinds of data that appear in the lakehouse, which combines features of the data warehouse and the data lake. Combined with the Unity Catalog, the Databricks platform allows end-to-end governance and usage of multiple accounts on multiple forms of data, multiple functions including ML models etc. Data is typically stored in the Medallion format (bronze -> raw ingested data with some extra auditing fields, silver -> transformations and joins to represent rudimentary business logic and prepare it in structure for basic business intelligence, gold -> aggregates representing finer business intelligence).\n\n# Setup\n\n### Databricks\n\nAlready set up on Azure with Unity Catalog for earlier experiments (will be deleted after a few runs of this project)\n\n### Azure Event Hubs\n\n1. Go to Azure portal > Event Hubs > Create\n2. Select an appropriate subscription\n3. Select an appropriate resource group (I picked the one where I hosted the Databricks workspace)\n4. Give the namespace a name\n5. Choose a location (preferably one close to the Databricks resources)\n6. Select the Basic (allowed 1 consumer group and stores data for 1 day) pricing tier (upgrade if you have the finance)\n7. Select the minimum throughput uints (upgrade if you have the finance)\n8. Review and create the namespace\n9. Go to resource and create Event Hub\n10. Give the event hub a name\n11. Select an appropriate number of partitions (I selected 1 for the purposes of this project)\n12. Select a clean up policy and retention time (Delete after 1 hour by default)\n13. Review and create\n14. Go to Settings > Shared access policies\n15. Click Add\n16. Give the policy a name and give it Listen access\n17. Click Create\n\n### Generating data events\n\n1. Go into the event hub and then Data Explorer\n2. Click Send events\n3. Select Custom payload if you're sending custom event data (we are)\n4. Select the JSON content type\n5. Fill up the payload in JSON format ({ "key" : "value"})\n6. Click send (repeat if required)\n\n### Connecting Databricks to Azure Event Hubs\n\n1. Create an all-purpose compute with the 12.2 LTS runtime and a decent node\n2. Go to Libraries and click Install new\n3. Select Maven as the library source and search for the azure-eventhubs-spark package (or enter this coordinate: "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.22")\n4. Attach the compute to a notebook\n5. For the Shared access policy created above, copy over the Primary connection string\n6. Also copy over the event hub name\n7. Create an eventHubs config by envrypting the connection and passing the event hub name\n8. Read the data in spark.readStream.format("eventhubs").options(\\*\\*eventHubsConfig).load(); this only reads the events that appear after the stream is started and the data is read in an encoded format\n	https://raw.githubusercontent.com/fayadchowdhury/pulse-stream/master/assets/featured-image.png	2025-03-21 07:20:37+00	2025-10-08 07:28:06+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
435662486	fayadchowdhury	solid-principles-java	An explanation of the SOLID principles in Java. Not super detailed, but gets the basic principles across.	{Java}	{show}	SOLID is an acronym coined by Michael Feathers for a subset of programming\nprinciples promoted by Robert C. Martin, widely known as Uncle Bob. They are\ncentred on Object Oriented Programming that make the code more effective,\nreadable, maintainable and flexible. They are especially useful for larger projects\nwhere the codebase can grow incredibly large and often difficult to manage\nwithout adherence to these principles.\n\nSOLID stands for:\n<ol>\n  <li> Single Responsibility Principle (SRP)</li>\n  <li> Open Closed Principle (OCP)</li>\n  <li> Liskov Substitution Principle (LSP)</li>\n  <li> Interface Segregation Principle (ISP)</li>\n  <li> Dependency Inversion Principle (DIP)</li>\n</ol>\n\n\nThe following portions explore each of the above principles in brief.\n\n## Single Responsibility Principle (SRP)\n\nSRP states that each class in a program should have only one responsibility and,\nhence, only one reason to change. This leads us to the advantage of the classes\nbeing **decoupled**, **organized** and **easier to test as units**.\n\nConsidering the case of a module of software that generates invoices. Assume a\nsingle class is created and tasked with the responsibilities of:\n\n1. Connecting to the database\n2. Fetching a customer’s order data\n3. Generating and printing invoices to a file or some other form of output\n\nIn such a scenario, **one** class handles **three** responsibilities and therefore there\nare at least 3 factors influencing the change of this class. This is a direct violation\nof SRP and makes this class highly subject to change and makes it very cluttered\nas well.\n\nIf instead we separate the responsibilities into three separate classes, we\nachieve adherence to SRP and make the module more **flexible** and **easily\nmaintainable.**\n\nThe DatabaseConnectionService is tasked with handling connections to the\ndatabase.\n\nThe OrderService class is tasked with the responsibility of order functionality.\n\nThe InvoiceServiceSrp class is tasked with the generation of invoices as an\noutput and other relevant functions.\n\nCreating objects of the separate classes and running the functions accordingly\nresults in the same output but, now that SRP has been achieved, it becomes\neasier to handle the submodules.\n\n## Open Closed Principle (OCP)\n\nOCP states that classes should be **open for extension, but closed for\nmodification.** This prevents us from modifying the existing code to add new\nfunctionality. Instead, we are encouraged to inherit or extend the existing class\nand add new functionality to the inheriting or extending class.\n\nThis is especially useful when there are **multiple developers working on a\nproject**. If developer A has written some code for a particular function that\ndeveloper B needs to change for his/her convenience, there may be **issues in\ndependencies** along the line. If instead there were a base class that both\ndevelopers A and B could inherit from and add functionality, the base class and\nthe children classes would be **easier to maintain.**\n\nConsider the case of a notification submodule that needs to send customers\nnotifications on new deals and whether a customer’s desired items are in stock.\nLet us assume that the business initially relied on emails, but are now wishing to\nadopt SMS notifications and predict a shift towards WhatsApp notifications as\nwell.\n\nIn the case that the initial NotificationService class was written keeping only\nemail notification related functionalities in mind, it would require **duplicated\nfunctions** to implement the same functionalities for other media. This would lead\nto **cluttered code**.\n\nA neater way to write this module is with the help of a NotificationInterface\ninterface that will have only the prototypes of the functions and classes\nimplementing this interface will need to override these functions according to\ntheir own logic.\n\nThe NotificationInterface interface that will be implemented by the\nSMSNotificationService, EmailNotificationService and\nWhatsAppNotificationService classes as per their own logic.\n\nThe EmailNotificationService class implements and overrides the functions in the\nNotificationInterface interface. The SMSNotificationService class and the WhatsAppNotificationService class are implemented similarly.\n\nThis adherence to OCP makes it **easier to extend functionality** while keeping\nthe **base code or logic unchanged.**\n\n**Liskov Substitution Principle (LSP)**\n\nLSP states that **if a class A is a subtype of classB (inherits from class B),\nthen it should be possible to replace instances of B with those of A without\ndisrupting the behaviour of the program.** This implies that **derived classes\nmust be completely substitutable for their base classes.**\n\nLSP essentially implies that whatever the base or parent class does, the derived\nor children classes do as well; the children classes may extend the functionality\ntoo, but they are never meant to act very differently from the parent class.\n\nThis principle is one of the **hardest to implement** since it requires foresight of\nhow the end program will shape up. There has to be great care towards\n**ensuring that the behaviour of parent and children classes are consistent**.\n\nConsider a parent class Vehicle that is a skeleton for all sorts of motor and\nelectric vehicles. Further consider a derived or child class, TeslaModelS, which is\na skeleton for all Tesla Model S vehicles. Both classes will have some function\nmove() that will detail how a generic vehicle moves (represented by the Vehicle\nclass) and how a Tesla Model S moves (represented by the TeslaModelS class).\nThere will be a vehicular movement tester submodule, represented by the\nVehicleMovementTesterService class. Ideally, the service should be designed in\nsuch a way that not only does it work for generic vehicles but also for very\nspecific makes like the Tesla.\n\nDesigning the very basic code keeping LSP in mind, we produce something like\nthe Vehicle and TeslaModelS classes.\n\nTo fully implement LSP, the portions of the code or the subsystems that\nincorporate these affected classes need also to be designed accordingly. In this\ncase, the VehicleMovementTesterService class has a testMovement() function\nthat needs to accept the generic parent Vehicle class as shown below.\n\nThe testMovement() function checks to see whether the Vehicle v’s move()\nfunction returns a true Boolean value or not.\n\nIn the main call area, it is observed that, because of the considerations made,\nthis testMovement() function within the VehicleMovementTesterService class not\nonly works for parent classes but also for derived or children classes.\n\nWriting code keeping LSP in mind makes it easier to **model the behaviour of\nchildren classes** and also to **write unit tests** for them. This makes the entire\nprogram more flexible and maintainable, at least at testing time.\n\n**Interface Segregation Principle (ISP)**\n\nISP states that **larger interfaces should be split into smaller interfaces such\nthat the classes implementing these interfaces can be concerned only\nabout the functionalities prototyped in these interfaces.**\n\nISP basically implies that **a client should never be forced to depend on\nmethods that they do not need**. By way of this principle, **“fat” interfaces**\n(those containing far too many method prototypes) are broken down into\n**“thinner” interfaces** (those with far fewer method prototypes that are very\nspecific to the interface’s purpose as per business logic).\n\nThis makes the codebase more **readable** and **maintainable,** especially for large\nprojects.\n\nConsider the case of a subsystem that generates reports and graphics for\ndifferent kinds of digital, ATL, BTL etc. marketing strategies. If we do not separate\nthe KPI analysis functions for each of the above in separate interfaces, we are\nforced to implement all of the functions in each of the performance analysis\nclasses (which themselves may have other functions like generating graphs or\ntargets or analysing ROIs and other metrics for example). This makes the\nclasses very clunky and populated with unnecessary code.\n\nA DigitalMarketingPerformanceService class that is forced to implement the ATL\nand BTL KPI functions as well because of the current implementation of the “fat”\nMarketingKpiInterface.\n\nKeeping in mind ISP, we separate the KPI calculation functions into 3 separate\ninterfaces - the AtlMarketingKpiInterface, the BtlMarketingKpiInterface and the DigitalMarketingKpiInterface.\n\nThe AtlMarketingKpiInterface with the prototype of the ATL marketing KPI\ncalculation function.\n\nThis allows the DigitalMarketingPerformanceService to implement the\nDigitalMarketingKpiInterface and not have to write functions for ATL and BTL KPI\ncalculations.\n\nThe DigitalMarketingPerformanceService class is now much **leaner** and **more\nreadable**.\n\n\n**Dependency Inversion Principle (DIP)**\n\nDIP states two things:\n\n<ul>\n  <li>High level modules will not depend on low level modules; both will depend on **abstractions**</li>\n  <li>Abstractions will not depend on details; details will depend on **abstractions**</li>\n</ul>\n\n\nThese two sub-principles combined allow us to model our codebases such that\nthey are very **flexible** and **robust,** by **removingtightcoupling.**\n\nConsider the case of a power switch and an electrical appliance, a light bulb for\nexample. A bad way to program this would be to make the power switch\nspecifically for the light bulb and adapt the functionalities of turning the switch on\nand off specifically for both the light bulb and the specific make of the power\nswitch. In the event of a new kind of switch (a remote switch for example) and/or\na new kind of appliance (a fan for example), the code would have to be\ndrastically modified or rewritten almost entirely.\n\nThe PowerSwitch class that is highly specific to the LightBulb class representing\nthe light bulb appliance. Implementing this functionality for a fan to be used with a\nremote switch becomes incredibly difficult here.\n\nThe LightBulb class implementation with very specific on/off functionalities.\n\nA good way to fix this and make the code more open to addition (in line with\nOCP) is by incorporating interfaces:\n\n1. A SwitchableApplianceInterface that the electrical appliances will\n    implement. This will contain the on/off function prototypes that each\n    electrical appliance’s class will override.\n2. A SwitchInterface that each kind of switch will implement. This will contain\n    the prototypes of the press function and the check function that each\n    switch’s class will override.\n\nA Fan class representing a fan and implementing the\nSwitchableApplianceInterface as outlined above. The LightBulb class is also\nmodified similarly to implement the SwitchableApplianceInterface.\n\nA RemoteSwitch class implementing the SwitchInterface and relying on and\noverriding the isOn() and press() functions defined in the interface. The\nPowerSwitch class is modified similarly.\n\nThe main call area also relies heavily on the interfaces as shown below and can\neasily adapt to classes implementing the interfaces.\n\nThe same interface object is used to point to different classes implementing the\ninterface. This makes the code much more **maintainable** , **readable** and **flexible**.\nIt also becomes much easier to write newer electrical appliance classes and\nswitch classes.\n\n\n**Conclusion**\n\nFollowing the SOLID principles\nis a “solid” first step to ensuring that the codebase for large projects becomes\neasier to handle. For small projects, however, a counter-argument may be posed\nby the large number of files needed to implement even a simple submodule. But,\nthese principles are a great starting point to writing organised, maintainable,\nreadable and flexible code.\n		2021-12-06 22:07:37+00	2025-09-10 00:57:27+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
713850621	fayadchowdhury	tlc-data-engineering	\N	{"Jupyter Notebook"}	{}	This project downloads TLC 2016 Data for NYC, performs EDA and fact-dimension data transformations, sets up a Mage pipeline on GCP to monitor the ETL flows, exports tables into BigQuery and finally visualizes results in Looked studio.		2023-11-03 11:16:29+00	2023-11-03 11:17:07+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1015866863	fayadchowdhury	homelab	Central repository for my homelab	{HCL,Python}	{homelab,iac,kubernetes-cluster,vm,featured,show}	![State of homelab](./assets/featured-image.png)\n\nThis repository contains the deployments in my homelab. This document will describe the details of my compute cluster and the structure of this repository in terms of the folders, and the individual folders will have more details about each deployment.\n\n### TL;DR\n- 6 Kubernetes nodes with 1 control plane node and 5 worker nodes\n- Pi-Hole as an ad-blocker and local DNS\n- Helm charts for easy deployment of applications\n- Easy version control with Git and Github\n\n## Cluster hardware\n\nMy homelab is composed of 3 mini computers, 1 Raspberry Pi 3B+ and 1 unmanaged 5 port TP-Link switch.\n\n### Mini computers\n\n1. Lenovo ThinkCenter M910q - i5-6500T @ 2.5GHz, 32GB DDR4 RAM, 120GB NVMe SSD, 250GB SATA SSD\n2. Dell OptiPlex 5050 - i5-6500T @ 2.5GHz, 16GB DDR4 RAM, 120GB NVMe SSD, 250GB SATA SSD\n3. Dell OptiPlex 5050 - i5-6500T @ 2.5GHz, 16GB DDR4 RAM, 120GB NVMe SSD, 2TB SATA HDD\n\n### Raspberry Pi\n\n1. Raspberry Pi 3B+ - ARM Cortex A53 @ 1.4GHz, 1GB RAM, 16GB MicroSD\n\n### Switch\n\n1. Unmanaged 5-port TP-Link TL-SG105 switch\n\n## Software setup\n\n- The mini computers all run Proxmox VE 8.4.1 configured in a HA cluster\n- The 250GB SATA SSDs and the 2TB SATA HDD are in a Ceph cluster storage\n- The Raspberry Pi 3B+ runs OpenWrt 24.10.0-rc1 to connect to my (rented apartment's) WiFi and then bridge the connection over to a LAN which connects to my main computer (Macbook Air M1 - 16GB RAM, 256GB storage)\n- 1 node in the cluster runs a PiHole container for DNS and ad-blocking\n- Tailscale is set up on 1 node and Tailscale DNS server is configured to PiHole for remote access and adblocking; other nodes use PiHole for DNS\n- Kubernetes setup with kubeadm across 1 master node Ubuntu Server VM and 3 worker node Ubuntu Server VMs (1 on each node in cluster) running Flannel, LocalPathProvisioner from Rancher, MetalLB, Ingress-NGINX, CloudNativePG and Minio (more details in kubernetes/README.md and kubernetes-helm/README.md)\n\n## Project folders structure\n\n- kubernetes/ - This contains the Kubernetes deployments that can be applied with kubectl apply\n- kubernetes-helm/ - This contains the entire platform as a Helm chart with the deployments templatized from kubernetes/\n\nBoth of these are WIPs\n\n## TODO\n\n1. Integrate CI/CD processes to make rollouts easier\n2. Explore IaC (TerraForm, Pulumi etc.) to provision VMs in code\n	https://raw.githubusercontent.com/fayadchowdhury/homelab/master/assets/featured-image.png	2025-07-08 06:44:18+00	2026-02-06 00:48:17+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
1071110746	fayadchowdhury	stock-pulse	Combine subreddit and stock data real-time to draw insights, powering everything on Databricks Free Edition	{}	{}	# stock-pulse\nCombine subreddit and stock data real-time to draw insights, powering everything on Databricks Free Edition\n		2025-10-06 22:05:09+00	2025-10-06 22:05:13+00	2025-12-22 08:00:29.869+00	2025-12-22 08:00:29.869+00
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (id, name, "iconPath", type, "subType", "createdAt", "updatedAt") FROM stdin;
1c560216-5b2b-42f0-ba7f-3e8475e64324	PySpark	/skill-icons/spark.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
cea935aa-9146-4c1d-b564-01a55bc24242	Pandas	/skill-icons/pandas.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
4feb5c8d-76af-48b8-8c73-411f02e95fb7	PowerBI	/skill-icons/powerbi.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
6643aa3a-07e0-4361-b96e-b39eed18e945	Tableau	/skill-icons/tableau.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
b2cbb3ac-728c-4aec-bc62-d1b539558915	Airflow	/skill-icons/airflow.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
c23e80c0-eb8e-4a44-8402-0bc584fefb93	Kafka	/skill-icons/kafka.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
32b08def-46ff-4a8f-ae5a-a93d69daa466	Looker Studio	/skill-icons/looker.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
d3434b6f-a850-4bb6-96bd-aeddb9f40121	HuggingFace	/skill-icons/huggingface.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
613531cb-b7fc-4d49-8ac3-4e1734b6b468	NumPy	/skill-icons/numpy.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
2f26b65c-2407-4c70-96d4-dfa8aee2c970	Seaborn	/skill-icons/seaborn.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
bc4a51d2-f35c-4d2a-b019-6393019d1017	OpenAI	/skill-icons/openai.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
14eb71e6-82f1-429c-a836-7647f8b882f6	TensorFlow	/skill-icons/tensorflow.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
3dc894e3-8ad6-44a2-9e95-e3095bd3e20a	Docker	/skill-icons/docker.svg	area	DevOps & Infra	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
6876910f-3bf7-4544-8126-12c8be1ea1de	Helm	/skill-icons/helm.svg	area	DevOps & Infra	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
490109fc-9e14-42a0-9acb-a78994320de2	Terraform	/skill-icons/terraform.svg	area	DevOps & Infra	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
dd3e5f6e-dd99-43d4-8caa-4cb299abf939	Github Actions	/skill-icons/github.svg	area	DevOps & Infra	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
40dcf1af-ff03-483a-8838-aeba6276a16e	Kubernetes	/skill-icons/kubernetes.svg	area	DevOps & Infra	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
1fc05dae-3014-4cad-8329-391dd47ae261	Python	/skill-icons/python.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
2a5e544c-5e82-4fbc-96a3-5023cd14c2bb	Java	/skill-icons/java.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
d71abf61-d58d-44bb-8b7b-07f3f0929fae	JavaScript	/skill-icons/javascript.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
ad5bad19-4afc-49a6-884e-a2952e4c6308	TypeScript	/skill-icons/typescript.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
af3f3fc6-37b0-4087-8d08-a1a3b47dfea4	HTML	/skill-icons/html.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
6cc2e2c9-c7da-4860-a593-eacf67143263	CSS	/skill-icons/css.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
1bddbab3-5838-44a5-addd-0448b46a26f6	Express.js	/skill-icons/express.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
6de581c4-db85-478b-b1b1-88aa6d9acf5c	Tailwind	/skill-icons/tailwind.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
cd4101b8-5a31-411e-8e04-130d8293259e	AWS	/skill-icons/aws.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
9a1a3300-f02a-47aa-bec9-bf9df5c31e6f	Bootstrap	/skill-icons/bootstrap.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
d2df2789-64a8-4171-bca3-2838dd3b950b	React.js	/skill-icons/reactjs.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
1539cf32-62a7-4616-aa86-81a1b3f24a2a	Node.js	/skill-icons/nodejs.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
01b776a7-b8ae-47bc-9671-8914d4c095d5	Azure	/skill-icons/azure.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
a1552dc4-88d5-4444-9a4e-0b7d0e1af29d	GCP	/skill-icons/gcp.svg	area	Web & Cloud	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
6d03cf43-e0cb-442a-9498-d2b865c8bd93	SQL	/skill-icons/sql.svg	core	Language	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
45eecca0-eeb4-4a1b-9c0e-597ef22e2a98	PyTorch	/skill-icons/pytorch.svg	area	Data & AI	2025-09-11 05:02:00.141+00	2025-09-11 05:02:00.141+00
\.


--
-- Data for Name: testimonials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testimonials (id, title, message, name, designation, "imagePath", rating, "createdAt", "updatedAt") FROM stdin;
b5a5d399-b7f2-4d43-b9e6-f80297654f9c	Excellent Service	I love using this service.	Jane Smith	Owner, DEF Bakery	/testimonial-pics/jane.jpg	4	2025-09-11 18:40:23+00	2025-09-11 18:40:24+00
f38ec6a7-7bc0-41a0-bcaf-dc65f38b69de	Outstanding Support	The support team was very helpful!	Bob Johnson	CTO, GHI Tech	/testimonial-pics/bob.jpg	5	2025-09-11 18:41:22+00	2025-09-11 18:41:23+00
0b8b78a3-316e-4b49-bb51-33a94c0b765c	Highly Recommend	Highly recommend to everyone.	Sally Mae	Marketing Director, JKL Digital	/testimonial-pics/sally.jpg	5	2025-09-11 18:42:16+00	2025-09-11 18:42:17+00
232e6492-3585-42a6-bb71-86c13a9d00e5	Great Product!	This is a fantastic product!	John Doe	CEO, ABC Consulting	/testimonial-pics/john.jpg	5	2025-09-11 18:38:13+00	2025-09-11 18:38:14+00
0a23d3fa-b0a0-4c38-bd48-d6d2369359e6	Potential to be the crown jewel of any team	Fayad has to be your go-to tech person when you have a problem at hand you don't know the solution to. He may not have the solution as well, but he will certainly excavate from heaven to hell and find you one.	Shafayat Hossain	Head of Marketing, Rayobyte	https://portfolio-site-static-assets.s3.us-east-1.amazonaws.com/testimonial-photos/shafayat.jpeg	5	2025-10-06 05:58:37+00	2025-10-06 05:58:40+00
\.


--
-- Data for Name: works; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.works (id, "order", "iconPath", title, subtitle, period, description, items, "createdAt", "updatedAt") FROM stdin;
0e4633c1-0bc5-4803-b888-afa4d4673e98	1	/work-icons/sfu.svg	Simon Fraser University	Graduate Teaching Assistant	Jan 2024 - Apr 2025	Supported and mentored nearly 400+ undergraduate and graduate students across three computing science courses, covering the basics of programming to cloud computing and big data systems	{"Assisted 113 students understand Python programming and debugging and encouraged algorithmic thinking and using abstract data structures","Outlined core OOP principles (encapsulation",inheritance,"polymorphism) in C++ lab sessions for 235 students","Helped 76 graduate students grasp core big data programming concepts in Apache Spark (mainly PySpark) and general ecosystem (CassandraDB",Kafka,"Airflow etc.) in lab sessions","Contributed to clarifying and solidifying understanding of theoretical concepts","going beyond the curriculum to impart interesting knowledge","over online office hours"}	2025-09-11 18:23:29+00	2025-09-11 18:23:30+00
e565ffe5-e50f-47d2-b9d3-da8b535e0c9b	3	/work-icons/banglalink.svg	Banglalink Digital Communications Ltd.	Data Engineer	Apr 2022 - Aug 2023	Identified and automated high-impact manual insight extraction workflows, enabling data-driven decision-making across the organization	{"Designed and unit-tested an ETL pipeline to scrape Meta Actionable Insights with Selenium","processing data in Pandas and loading into an on-prem MySQL cluster","Enabled 13% business growth by collaborating with marketing to build PowerBI dashboards aggregating 100k+ MySQL records for regional insights","Improved system robustness and scalability by contributing to the MyBL super app migration from PHP to Node.js","implementing microservices with RabbitMQ and Docker"}	2025-09-11 18:25:43+00	2025-09-11 18:25:44+00
2683e932-d7e0-40b3-aacc-68372fdcb452	2	/work-icons/klue.svg	Klue Labs Inc.	Data Analyst	May 2024 - Aug 2024	Constructed scalable, production-grade data pipelines to support GenAI use cases in technical and non-technical teams and enabled strategic decision-making	{"Saved 4+ hours weekly by developing and unit-testing a modular PDF parsing and embedding pipeline using GCP Cloud Functions and BigQuery for RAG ingestion","Processed 500+ unstructured client content requests by collaborating on unit-tested Python workflows","storing outputs in BigQuery for integration with vendor APIs","Drove refinement rollouts by building a BigQuery–Looker Studio dashboard to visualize the effect of modifying intelligence filters"}	2025-09-11 18:24:39+00	2025-09-11 18:24:40+00
\.


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: testimonials testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id);


--
-- Name: works works_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: TABLE projects; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.projects TO portfolio;


--
-- Name: TABLE skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.skills TO portfolio;


--
-- Name: TABLE testimonials; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.testimonials TO portfolio;


--
-- Name: TABLE works; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.works TO portfolio;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO portfolio;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-2.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-2.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: FUNCTION pg_ls_dir(text, boolean, boolean); Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT ALL ON FUNCTION pg_catalog.pg_ls_dir(text, boolean, boolean) TO streaming_replica;


--
-- Name: FUNCTION pg_read_binary_file(text); Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT ALL ON FUNCTION pg_catalog.pg_read_binary_file(text) TO streaming_replica;


--
-- Name: FUNCTION pg_read_binary_file(text, bigint, bigint, boolean); Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT ALL ON FUNCTION pg_catalog.pg_read_binary_file(text, bigint, bigint, boolean) TO streaming_replica;


--
-- Name: FUNCTION pg_stat_file(filename text, missing_ok boolean, OUT size bigint, OUT access timestamp with time zone, OUT modification timestamp with time zone, OUT change timestamp with time zone, OUT creation timestamp with time zone, OUT isdir boolean); Type: ACL; Schema: pg_catalog; Owner: postgres
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_file(filename text, missing_ok boolean, OUT size bigint, OUT access timestamp with time zone, OUT modification timestamp with time zone, OUT change timestamp with time zone, OUT creation timestamp with time zone, OUT isdir boolean) TO streaming_replica;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

