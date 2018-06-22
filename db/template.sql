--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.13
-- Dumped by pg_dump version 9.5.13

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
-- Name: array_contains_all_regex(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT CASE WHEN 0 = jsonb_array_length("values") THEN true = false ELSE (SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements_text("array") as elt WHERE elt LIKE ANY (SELECT jsonb_array_elements_text("values"))) as RES) END; $$;


ALTER FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) OWNER TO postgres;

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
-- Name: Alert; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Alert" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    switch text,
    "readingModel" text,
    reading text,
    "analysisModel" text,
    "analysisResult" text,
    "analysisInstance" text,
    "alertLevel" double precision
);


ALTER TABLE public."Alert" OWNER TO postgres;

--
-- Name: AnalysisInstance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AnalysisInstance" (
    _wperm text[],
    "updatedAt" timestamp with time zone,
    _rperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "analysisModel" text,
    "targetType" text,
    target text,
    trigger text,
    status text
);


ALTER TABLE public."AnalysisInstance" OWNER TO postgres;

--
-- Name: AnalysisModel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AnalysisModel" (
    _rperm text[],
    _wperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    type text
);


ALTER TABLE public."AnalysisModel" OWNER TO postgres;

--
-- Name: AnalysisResult; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AnalysisResult" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    "analysisModel" text,
    "analysisInstance" text,
    "resultType" text,
    result text
);


ALTER TABLE public."AnalysisResult" OWNER TO postgres;

--
-- Name: Log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Log" (
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    "objectId" text NOT NULL,
    _wperm text[],
    type text,
    content text,
    level double precision
);


ALTER TABLE public."Log" OWNER TO postgres;

--
-- Name: SCHEMA_COPY; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SCHEMA_COPY" (
    "isParseClass" boolean,
    "className" text,
    schema jsonb
);


ALTER TABLE public."SCHEMA_COPY" OWNER TO postgres;

--
-- Name: SchemaExtend; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SchemaExtend" (
    _rperm text[],
    "objectId" text NOT NULL,
    _wperm text[],
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "className" text,
    "schemaExtend" text
);


ALTER TABLE public."SchemaExtend" OWNER TO postgres;

--
-- Name: SensorInstance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorInstance" (
    _wperm text[],
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    "objectId" text NOT NULL,
    name text,
    model text,
    switch text
);


ALTER TABLE public."SensorInstance" OWNER TO postgres;

--
-- Name: SensorModel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorModel" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    name text
);


ALTER TABLE public."SensorModel" OWNER TO postgres;

--
-- Name: SensorReadingModel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorReadingModel" (
    _rperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _wperm text[],
    name text,
    model text,
    "dataFormat" text,
    "targetClass" text,
    mapping jsonb,
    "parentReadingModel" text,
    sort double precision
);


ALTER TABLE public."SensorReadingModel" OWNER TO postgres;

--
-- Name: COLUMN "SensorReadingModel"."dataFormat"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SensorReadingModel"."dataFormat" IS '数据形式';


--
-- Name: SensorReadingTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SensorReadingTemplate" (
    _wperm text[],
    _rperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "readingModel" text,
    switch text,
    sensor text,
    "parentReading" text,
    sort double precision,
    rawdata double precision
);


ALTER TABLE public."SensorReadingTemplate" OWNER TO postgres;

--
-- Name: SwitchInstance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SwitchInstance" (
    "updatedAt" timestamp with time zone,
    _rperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    _wperm text[],
    "switchNumber" text,
    name text,
    bureau text,
    station text,
    substation text,
    model text,
    voltage text,
    current text,
    "operationCurrent" text,
    "serialNumber" text,
    "operatedAt" timestamp with time zone,
    "voltageLevel" text,
    latitude double precision,
    longitude double precision,
    altitude double precision,
    manufacturer text
);


ALTER TABLE public."SwitchInstance" OWNER TO postgres;

--
-- Name: COLUMN "SwitchInstance"."objectId"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance"."objectId" IS '设备全局id';


--
-- Name: COLUMN "SwitchInstance"."switchNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance"."switchNumber" IS '设备ID';


--
-- Name: COLUMN "SwitchInstance".name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance".name IS '设备名称';


--
-- Name: COLUMN "SwitchInstance".model; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance".model IS '开关型号';


--
-- Name: COLUMN "SwitchInstance".voltage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance".voltage IS '额定电压';


--
-- Name: COLUMN "SwitchInstance".current; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance".current IS '额定电流';


--
-- Name: COLUMN "SwitchInstance"."operationCurrent"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance"."operationCurrent" IS '额定短路开断电流';


--
-- Name: COLUMN "SwitchInstance"."serialNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance"."serialNumber" IS '出厂编号';


--
-- Name: COLUMN "SwitchInstance"."operatedAt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."SwitchInstance"."operatedAt" IS '投产时间';


--
-- Name: SwitchTag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SwitchTag" (
    _wperm text[],
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    switch text,
    "tagName" text
);


ALTER TABLE public."SwitchTag" OWNER TO postgres;

--
-- Name: _Audience; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Audience" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    query text,
    "lastUsed" timestamp with time zone,
    "timesUsed" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Audience" OWNER TO postgres;

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
-- Name: _JobSchedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_JobSchedule" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    description text,
    params text,
    "startAfter" text,
    "daysOfWeek" jsonb,
    "timeOfDay" text,
    "lastRun" double precision,
    "repeatMinutes" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_JobSchedule" OWNER TO postgres;

--
-- Name: _JobStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_JobStatus" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    source text,
    status text,
    message text,
    params jsonb,
    "finishedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[]
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
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "pushTime" text,
    source text,
    query text,
    payload text,
    title text,
    expiry double precision,
    expiration_interval double precision,
    status text,
    "numSent" double precision,
    "numFailed" double precision,
    "pushHash" text,
    "errorMessage" jsonb,
    "sentPerType" jsonb,
    "failedPerType" jsonb,
    "sentPerUTCOffset" jsonb,
    "failedPerUTCOffset" jsonb,
    count double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_PushStatus" OWNER TO postgres;

--
-- Name: _Role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_Role" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    _rperm text[],
    _wperm text[]
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
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    username text,
    email text,
    "emailVerified" boolean,
    "authData" jsonb,
    _rperm text[],
    _wperm text[],
    _hashed_password text,
    _email_verify_token_expires_at timestamp with time zone,
    _email_verify_token text,
    _account_lockout_expires_at timestamp with time zone,
    _failed_login_count double precision,
    _perishable_token text,
    _perishable_token_expires_at timestamp with time zone,
    _password_changed_at timestamp with time zone,
    _password_history jsonb
);


ALTER TABLE public."_User" OWNER TO postgres;

--
-- Data for Name: Alert; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Alert" ("objectId", "createdAt", "updatedAt", _rperm, _wperm, switch, "readingModel", reading, "analysisModel", "analysisResult", "analysisInstance", "alertLevel") FROM stdin;
\.


--
-- Data for Name: AnalysisInstance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AnalysisInstance" (_wperm, "updatedAt", _rperm, "objectId", "createdAt", "analysisModel", "targetType", target, trigger, status) FROM stdin;
\.


--
-- Data for Name: AnalysisModel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AnalysisModel" (_rperm, _wperm, "objectId", "createdAt", "updatedAt", name, type) FROM stdin;
\.


--
-- Data for Name: AnalysisResult; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AnalysisResult" ("objectId", "createdAt", "updatedAt", _rperm, _wperm, "analysisModel", "analysisInstance", "resultType", result) FROM stdin;
\.


--
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Log" ("createdAt", "updatedAt", _rperm, "objectId", _wperm, type, content, level) FROM stdin;
\.


--
-- Data for Name: SCHEMA_COPY; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SCHEMA_COPY" ("isParseClass", "className", schema) FROM stdin;
t	SCHEMA_COPY	{"fields": {"ACL": {"type": "ACL"}, "schema": {"type": "Object"}, "objectId": {"type": "String"}, "className": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "isParseClass": {"type": "Boolean"}}, "className": "SCHEMA_COPY", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	_User	{"fields": {"ACL": {"type": "ACL"}, "email": {"type": "String"}, "authData": {"type": "Object"}, "objectId": {"type": "String"}, "password": {"type": "String"}, "username": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "emailVerified": {"type": "Boolean"}}, "className": "_User", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SensorReadingTemplate	{"fields": {"ACL": {"type": "ACL"}, "sort": {"type": "Number"}, "sensor": {"type": "String"}, "switch": {"type": "String"}, "rawdata": {"type": "Number"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "readingModel": {"type": "String"}, "parentReading": {"type": "String"}}, "className": "SensorReadingTemplate", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	Alert	{"fields": {"ACL": {"type": "ACL"}, "switch": {"type": "String"}, "reading": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "alertLevel": {"type": "Number"}, "readingModel": {"type": "String"}, "analysisModel": {"type": "String"}, "analysisResult": {"type": "String"}, "analysisInstance": {"type": "String"}}, "className": "Alert", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	AnalysisInstance	{"fields": {"ACL": {"type": "ACL"}, "status": {"type": "String"}, "target": {"type": "String"}, "trigger": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "targetType": {"type": "String"}, "analysisModel": {"type": "String"}}, "className": "AnalysisInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	Log	{"fields": {"ACL": {"type": "ACL"}, "type": {"type": "String"}, "level": {"type": "Number"}, "content": {"type": "String", "subName": "xuliehao"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "Log", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	_Role	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "roles": {"type": "Relation", "targetClass": "_Role"}, "users": {"type": "Relation", "targetClass": "_User"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "_Role", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SwitchInstance	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "model": {"type": "String"}, "bureau": {"type": "String"}, "current": {"type": "String"}, "station": {"type": "String"}, "voltage": {"type": "String"}, "altitude": {"type": "Number"}, "latitude": {"type": "Number"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "longitude": {"type": "Number"}, "updatedAt": {"type": "Date"}, "operatedAt": {"type": "Date"}, "substation": {"type": "String"}, "manufacturer": {"type": "String"}, "serialNumber": {"type": "String"}, "switchNumber": {"type": "String"}, "voltageLevel": {"type": "String"}, "operationCurrent": {"type": "String"}}, "className": "SwitchInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SensorReadingModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "sort": {"type": "Number"}, "model": {"type": "String"}, "mapping": {"type": "Object"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "dataFormat": {"type": "String"}, "targetClass": {"type": "String"}, "parentReadingModel": {"type": "String"}}, "className": "SensorReadingModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	AnalysisModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "type": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "AnalysisModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SchemaExtend	{"fields": {"ACL": {"type": "ACL"}, "objectId": {"type": "String"}, "className": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "schemaExtend": {"type": "String"}}, "className": "SchemaExtend", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SensorInstance	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "model": {"type": "String"}, "switch": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SensorInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SensorModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SensorModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	SwitchTag	{"fields": {"ACL": {"type": "ACL"}, "switch": {"type": "String"}, "tagName": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SwitchTag", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
t	AnalysisResult	{"fields": {"ACL": {"type": "ACL"}, "result": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "resultType": {"type": "String"}, "analysisModel": {"type": "String"}, "analysisInstance": {"type": "String"}}, "className": "AnalysisResult", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}
\.


--
-- Data for Name: SchemaExtend; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SchemaExtend" (_rperm, "objectId", _wperm, "createdAt", "updatedAt", "className", "schemaExtend") FROM stdin;
\.


--
-- Data for Name: SensorInstance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SensorInstance" (_wperm, "createdAt", "updatedAt", _rperm, "objectId", name, model, switch) FROM stdin;
\.


--
-- Data for Name: SensorModel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SensorModel" ("objectId", "createdAt", "updatedAt", _rperm, _wperm, name) FROM stdin;
\.


--
-- Data for Name: SensorReadingModel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SensorReadingModel" (_rperm, "objectId", "createdAt", "updatedAt", _wperm, name, model, "dataFormat", "targetClass", mapping, "parentReadingModel", sort) FROM stdin;
\.


--
-- Data for Name: SensorReadingTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SensorReadingTemplate" (_wperm, _rperm, "objectId", "createdAt", "updatedAt", "readingModel", switch, sensor, "parentReading", sort, rawdata) FROM stdin;
\.


--
-- Data for Name: SwitchInstance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SwitchInstance" ("updatedAt", _rperm, "objectId", "createdAt", _wperm, "switchNumber", name, bureau, station, substation, model, voltage, current, "operationCurrent", "serialNumber", "operatedAt", "voltageLevel", latitude, longitude, altitude, manufacturer) FROM stdin;
\.


--
-- Data for Name: SwitchTag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SwitchTag" (_wperm, "objectId", "createdAt", "updatedAt", _rperm, switch, "tagName") FROM stdin;
\.


--
-- Data for Name: _Audience; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Audience" ("objectId", "createdAt", "updatedAt", name, query, "lastUsed", "timesUsed", _rperm, _wperm) FROM stdin;
\.


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
-- Data for Name: _JobSchedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_JobSchedule" ("objectId", "createdAt", "updatedAt", "jobName", description, params, "startAfter", "daysOfWeek", "timeOfDay", "lastRun", "repeatMinutes", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _JobStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_JobStatus" ("objectId", "createdAt", "updatedAt", "jobName", source, status, message, params, "finishedAt", _rperm, _wperm) FROM stdin;
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

COPY public."_PushStatus" ("objectId", "createdAt", "updatedAt", "pushTime", source, query, payload, title, expiry, expiration_interval, status, "numSent", "numFailed", "pushHash", "errorMessage", "sentPerType", "failedPerType", "sentPerUTCOffset", "failedPerUTCOffset", count, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _Role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_Role" ("objectId", "createdAt", "updatedAt", name, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _SCHEMA; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_SCHEMA" ("className", schema, "isParseClass") FROM stdin;
SCHEMA_COPY	{"fields": {"ACL": {"type": "ACL"}, "schema": {"type": "Object"}, "objectId": {"type": "String"}, "className": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "isParseClass": {"type": "Boolean"}}, "className": "SCHEMA_COPY", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
_User	{"fields": {"ACL": {"type": "ACL"}, "email": {"type": "String"}, "authData": {"type": "Object"}, "objectId": {"type": "String"}, "password": {"type": "String"}, "username": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "emailVerified": {"type": "Boolean"}}, "className": "_User", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SensorReadingTemplate	{"fields": {"ACL": {"type": "ACL"}, "sort": {"type": "Number"}, "sensor": {"type": "String"}, "switch": {"type": "String"}, "rawdata": {"type": "Number"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "readingModel": {"type": "String"}, "parentReading": {"type": "String"}}, "className": "SensorReadingTemplate", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
Alert	{"fields": {"ACL": {"type": "ACL"}, "switch": {"type": "String"}, "reading": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "alertLevel": {"type": "Number"}, "readingModel": {"type": "String"}, "analysisModel": {"type": "String"}, "analysisResult": {"type": "String"}, "analysisInstance": {"type": "String"}}, "className": "Alert", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
AnalysisInstance	{"fields": {"ACL": {"type": "ACL"}, "status": {"type": "String"}, "target": {"type": "String"}, "trigger": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "targetType": {"type": "String"}, "analysisModel": {"type": "String"}}, "className": "AnalysisInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
Log	{"fields": {"ACL": {"type": "ACL"}, "type": {"type": "String"}, "level": {"type": "Number"}, "content": {"type": "String", "subName": "xuliehao"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "Log", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
_Role	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "roles": {"type": "Relation", "targetClass": "_Role"}, "users": {"type": "Relation", "targetClass": "_User"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "_Role", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SwitchInstance	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "model": {"type": "String"}, "bureau": {"type": "String"}, "current": {"type": "String"}, "station": {"type": "String"}, "voltage": {"type": "String"}, "altitude": {"type": "Number"}, "latitude": {"type": "Number"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "longitude": {"type": "Number"}, "updatedAt": {"type": "Date"}, "operatedAt": {"type": "Date"}, "substation": {"type": "String"}, "manufacturer": {"type": "String"}, "serialNumber": {"type": "String"}, "switchNumber": {"type": "String"}, "voltageLevel": {"type": "String"}, "operationCurrent": {"type": "String"}}, "className": "SwitchInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SensorReadingModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "sort": {"type": "Number"}, "model": {"type": "String"}, "mapping": {"type": "Object"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "dataFormat": {"type": "String"}, "targetClass": {"type": "String"}, "parentReadingModel": {"type": "String"}}, "className": "SensorReadingModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
AnalysisModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "type": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "AnalysisModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SchemaExtend	{"fields": {"ACL": {"type": "ACL"}, "objectId": {"type": "String"}, "className": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "schemaExtend": {"type": "String"}}, "className": "SchemaExtend", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SensorInstance	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "model": {"type": "String"}, "switch": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SensorInstance", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SensorModel	{"fields": {"ACL": {"type": "ACL"}, "name": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SensorModel", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
SwitchTag	{"fields": {"ACL": {"type": "ACL"}, "switch": {"type": "String"}, "tagName": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "SwitchTag", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
AnalysisResult	{"fields": {"ACL": {"type": "ACL"}, "result": {"type": "String"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "resultType": {"type": "String"}, "analysisModel": {"type": "String"}, "analysisInstance": {"type": "String"}}, "className": "AnalysisResult", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {"*": true}}}	t
\.


--
-- Data for Name: _User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_User" ("objectId", "createdAt", "updatedAt", username, email, "emailVerified", "authData", _rperm, _wperm, _hashed_password, _email_verify_token_expires_at, _email_verify_token, _account_lockout_expires_at, _failed_login_count, _perishable_token, _perishable_token_expires_at, _password_changed_at, _password_history) FROM stdin;
\.


--
-- Name: Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_pkey" PRIMARY KEY ("objectId");


--
-- Name: AnalysisInstance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisInstance"
    ADD CONSTRAINT "AnalysisInstance_pkey" PRIMARY KEY ("objectId");


--
-- Name: AnalysisModel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisModel"
    ADD CONSTRAINT "AnalysisModel_pkey" PRIMARY KEY ("objectId");


--
-- Name: AnalysisResult_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "AnalysisResult_pkey" PRIMARY KEY ("objectId");


--
-- Name: Log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Log"
    ADD CONSTRAINT "Log_pkey" PRIMARY KEY ("objectId");


--
-- Name: SchemaExtend_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SchemaExtend"
    ADD CONSTRAINT "SchemaExtend_pkey" PRIMARY KEY ("objectId");


--
-- Name: SensorInstance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorInstance"
    ADD CONSTRAINT "SensorInstance_pkey" PRIMARY KEY ("objectId");


--
-- Name: SensorModel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorModel"
    ADD CONSTRAINT "SensorModel_pkey" PRIMARY KEY ("objectId");


--
-- Name: SensorReadingModel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingModel"
    ADD CONSTRAINT "SensorReadingModel_pkey" PRIMARY KEY ("objectId");


--
-- Name: SensorReadingTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingTemplate"
    ADD CONSTRAINT "SensorReadingTemplate_pkey" PRIMARY KEY ("objectId");


--
-- Name: SwitchInstance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SwitchInstance"
    ADD CONSTRAINT "SwitchInstance_pkey" PRIMARY KEY ("objectId");


--
-- Name: SwitchTag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SwitchTag"
    ADD CONSTRAINT "SwitchTag_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Audience_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_Audience"
    ADD CONSTRAINT "_Audience_pkey" PRIMARY KEY ("objectId");


--
-- Name: _GlobalConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_GlobalConfig"
    ADD CONSTRAINT "_GlobalConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_JobSchedule"
    ADD CONSTRAINT "_JobSchedule_pkey" PRIMARY KEY ("objectId");


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
-- Name: 设备全局ID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SwitchInstance"
    ADD CONSTRAINT "设备全局ID" UNIQUE ("objectId");


--
-- Name: Alert_analysisInstance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_analysisInstance_fkey" FOREIGN KEY ("analysisInstance") REFERENCES public."AnalysisInstance"("objectId");


--
-- Name: Alert_analysisModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_analysisModel_fkey" FOREIGN KEY ("analysisModel") REFERENCES public."AnalysisModel"("objectId");


--
-- Name: Alert_analysisResult_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_analysisResult_fkey" FOREIGN KEY ("analysisResult") REFERENCES public."AnalysisResult"("objectId");


--
-- Name: Alert_readingModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_readingModel_fkey" FOREIGN KEY ("readingModel") REFERENCES public."SensorReadingModel"("objectId");


--
-- Name: Alert_switch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_switch_fkey" FOREIGN KEY (switch) REFERENCES public."SwitchInstance"("objectId");


--
-- Name: AnalysisInstance_analysisModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisInstance"
    ADD CONSTRAINT "AnalysisInstance_analysisModel_fkey" FOREIGN KEY ("analysisModel") REFERENCES public."AnalysisModel"("objectId");


--
-- Name: AnalysisResult_analysisInstance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "AnalysisResult_analysisInstance_fkey" FOREIGN KEY ("analysisInstance") REFERENCES public."AnalysisInstance"("objectId");


--
-- Name: AnalysisResult_analysisModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AnalysisResult"
    ADD CONSTRAINT "AnalysisResult_analysisModel_fkey" FOREIGN KEY ("analysisModel") REFERENCES public."AnalysisModel"("objectId");


--
-- Name: SensorInstance_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorInstance"
    ADD CONSTRAINT "SensorInstance_model_fkey" FOREIGN KEY (model) REFERENCES public."SensorModel"("objectId");


--
-- Name: SensorInstance_switch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorInstance"
    ADD CONSTRAINT "SensorInstance_switch_fkey" FOREIGN KEY (switch) REFERENCES public."SwitchInstance"("objectId");


--
-- Name: SensorReadingModel_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingModel"
    ADD CONSTRAINT "SensorReadingModel_model_fkey" FOREIGN KEY (model) REFERENCES public."SensorModel"("objectId");


--
-- Name: SensorReadingModel_parentReadingModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingModel"
    ADD CONSTRAINT "SensorReadingModel_parentReadingModel_fkey" FOREIGN KEY ("parentReadingModel") REFERENCES public."SensorReadingModel"("objectId");


--
-- Name: SensorReadingTemplate_readingModel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingTemplate"
    ADD CONSTRAINT "SensorReadingTemplate_readingModel_fkey" FOREIGN KEY ("readingModel") REFERENCES public."SensorReadingModel"("objectId");


--
-- Name: SensorReadingTemplate_readingModel_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingTemplate"
    ADD CONSTRAINT "SensorReadingTemplate_readingModel_fkey1" FOREIGN KEY ("readingModel") REFERENCES public."SwitchInstance"("objectId");


--
-- Name: SensorReadingTemplate_sensor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SensorReadingTemplate"
    ADD CONSTRAINT "SensorReadingTemplate_sensor_fkey" FOREIGN KEY (sensor) REFERENCES public."SensorInstance"("objectId");


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

