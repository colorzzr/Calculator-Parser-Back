--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.14
-- Dumped by pg_dump version 9.5.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: array_add(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_add("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
  SELECT array_to_json(ARRAY(SELECT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) ||  ARRAY(SELECT jsonb_array_elements("values")))))::jsonb;
$$;


ALTER FUNCTION public.array_add("array" jsonb, "values" jsonb) OWNER TO postgres;

--
-- Name: array_add_unique(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
  SELECT array_to_json(ARRAY(SELECT DISTINCT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) ||  ARRAY(SELECT DISTINCT jsonb_array_elements("values")))))::jsonb;
$$;


ALTER FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) OWNER TO postgres;

--
-- Name: array_contains(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_contains("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
  SELECT RES.CNT >= 1 FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements("array") as elt WHERE elt IN (SELECT jsonb_array_elements("values"))) as RES ;
$$;


ALTER FUNCTION public.array_contains("array" jsonb, "values" jsonb) OWNER TO postgres;

--
-- Name: array_contains_all(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
  SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements("array") as elt WHERE elt IN (SELECT jsonb_array_elements("values"))) as RES ;
$$;


ALTER FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) OWNER TO postgres;

--
-- Name: array_remove(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_remove("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
  SELECT array_to_json(ARRAY(SELECT * FROM jsonb_array_elements("array") as elt WHERE elt NOT IN (SELECT * FROM (SELECT jsonb_array_elements("values")) AS sub)))::jsonb;
$$;


ALTER FUNCTION public.array_remove("array" jsonb, "values" jsonb) OWNER TO postgres;

--
-- Name: json_object_set_key(jsonb, text, anyelement); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT concat('{', string_agg(to_json("key") || ':' || "value", ','), '}')::jsonb
  FROM (SELECT *
          FROM jsonb_each("json")
         WHERE "key" <> "key_to_set"
         UNION ALL
        SELECT "key_to_set", to_json("value_to_set")::jsonb) AS "fields"
$$;


ALTER FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: _GlobalConfig; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_GlobalConfig" (
    "objectId" text NOT NULL,
    params jsonb
);


ALTER TABLE public."_GlobalConfig" OWNER TO postgres;

--
-- Name: _Hooks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Hooks" (
    "functionName" text,
    "className" text,
    "triggerName" text,
    url text
);


ALTER TABLE public."_Hooks" OWNER TO postgres;

--
-- Name: _JobStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_JobStatus" (
    "updatedAt" timestamp with time zone,
    _rperm text[],
    message text,
    "jobName" text,
    source text,
    _wperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    status text,
    params jsonb,
    "finishedAt" timestamp with time zone
);


ALTER TABLE public."_JobStatus" OWNER TO postgres;

--
-- Name: _Join:roles:_Role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Join:roles:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:roles:_Role" OWNER TO postgres;

--
-- Name: _Join:users:_Role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Join:users:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:users:_Role" OWNER TO postgres;

--
-- Name: _PushStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_PushStatus" (
    _wperm text[],
    "updatedAt" timestamp with time zone,
    "objectId" text NOT NULL,
    "failedPerType" jsonb,
    "pushHash" text,
    status text,
    count double precision,
    "createdAt" timestamp with time zone,
    "numFailed" double precision,
    "sentPerType" jsonb,
    _rperm text[],
    "numSent" double precision,
    "errorMessage" jsonb,
    "pushTime" text,
    source text,
    query text,
    payload text,
    expiry double precision,
    title text
);


ALTER TABLE public."_PushStatus" OWNER TO postgres;

--
-- Name: _Role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Role" (
    _wperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    name text
);


ALTER TABLE public."_Role" OWNER TO postgres;

--
-- Name: _SCHEMA; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_SCHEMA" (
    "className" character varying(120) NOT NULL,
    schema jsonb,
    "isParseClass" boolean
);


ALTER TABLE public."_SCHEMA" OWNER TO postgres;

--
-- Name: _User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_User" (
    _perishable_token text,
    _password_history jsonb,
    "objectId" text NOT NULL,
    _rperm text[],
    username text,
    _failed_login_count double precision,
    _hashed_password text,
    _wperm text[],
    _email_verify_token_expires_at timestamp with time zone,
    _email_verify_token text,
    email text,
    "emailVerified" boolean,
    _account_lockout_expires_at timestamp with time zone,
    _perishable_token_expires_at timestamp with time zone,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "authData" jsonb,
    _password_changed_at timestamp with time zone
);


ALTER TABLE public."_User" OWNER TO postgres;

--
-- Name: returnPack; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."returnPack" (
    "updatedAt" timestamp with time zone,
    _rperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    _wperm text[],
    answer text,
    date text,
    "errorMsg" text,
    "operationMode" double precision
);


ALTER TABLE public."returnPack" OWNER TO postgres;

--
-- Data for Name: _GlobalConfig; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_GlobalConfig" ("objectId", params) FROM stdin;
\.


--
-- Data for Name: _Hooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Hooks" ("functionName", "className", "triggerName", url) FROM stdin;
\.


--
-- Data for Name: _JobStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_JobStatus" ("updatedAt", _rperm, message, "jobName", source, _wperm, "objectId", "createdAt", status, params, "finishedAt") FROM stdin;
\.


--
-- Data for Name: _Join:roles:_Role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Join:roles:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _Join:users:_Role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Join:users:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _PushStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_PushStatus" (_wperm, "updatedAt", "objectId", "failedPerType", "pushHash", status, count, "createdAt", "numFailed", "sentPerType", _rperm, "numSent", "errorMessage", "pushTime", source, query, payload, expiry, title) FROM stdin;
\.


--
-- Data for Name: _Role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Role" (_wperm, "objectId", "createdAt", "updatedAt", _rperm, name) FROM stdin;
\.


--
-- Data for Name: _SCHEMA; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_SCHEMA" ("className", schema, "isParseClass") FROM stdin;
_User	{"fields": {"email": {"type": "String"}, "_rperm": {"type": "Array"}, "_wperm": {"type": "Array"}, "authData": {"type": "Object"}, "objectId": {"type": "String"}, "username": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "emailVerified": {"type": "Boolean"}, "_hashed_password": {"type": "String"}}, "className": "_User", "classLevelPermissions": null}	t
_Role	{"fields": {"name": {"type": "String"}, "roles": {"type": "Relation", "targetClass": "_Role"}, "users": {"type": "Relation", "targetClass": "_User"}, "_rperm": {"type": "Array"}, "_wperm": {"type": "Array"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "_Role", "classLevelPermissions": null}	t
returnPack	{"fields": {"date": {"type": "String"}, "_rperm": {"type": "Array"}, "_wperm": {"type": "Array"}, "answer": {"type": "String"}, "errorMsg": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "operationMode": {"type": "Number"}}, "className": "returnPack", "classLevelPermissions": null}	t
\.


--
-- Data for Name: _User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_User" (_perishable_token, _password_history, "objectId", _rperm, username, _failed_login_count, _hashed_password, _wperm, _email_verify_token_expires_at, _email_verify_token, email, "emailVerified", _account_lockout_expires_at, _perishable_token_expires_at, "createdAt", "updatedAt", "authData", _password_changed_at) FROM stdin;
\.


--
-- Data for Name: returnPack; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."returnPack" ("updatedAt", _rperm, "objectId", "createdAt", _wperm, answer, date, "errorMsg", "operationMode") FROM stdin;
\.


--
-- Name: _GlobalConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_GlobalConfig"
    ADD CONSTRAINT "_GlobalConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_JobStatus"
    ADD CONSTRAINT "_JobStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Join:roles:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "_Join:roles:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:users:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_Join:users:_Role"
    ADD CONSTRAINT "_Join:users:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _PushStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_PushStatus"
    ADD CONSTRAINT "_PushStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_Role"
    ADD CONSTRAINT "_Role_pkey" PRIMARY KEY ("objectId");


--
-- Name: _SCHEMA_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_SCHEMA"
    ADD CONSTRAINT "_SCHEMA_pkey" PRIMARY KEY ("className");


--
-- Name: _User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT "_User_pkey" PRIMARY KEY ("objectId");


--
-- Name: returnPack_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."returnPack"
    ADD CONSTRAINT "returnPack_pkey" PRIMARY KEY ("objectId");


--
-- Name: unique_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_Role"
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

