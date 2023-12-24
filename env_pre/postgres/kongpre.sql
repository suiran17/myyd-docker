--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10 (Debian 11.10-1.pgdg90+1)
-- Dumped by pg_dump version 11.10 (Debian 11.10-1.pgdg90+1)

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
-- Name: sync_tags(); Type: FUNCTION; Schema: public; Owner: kongpre
--

CREATE FUNCTION public.sync_tags() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF (TG_OP = 'TRUNCATE') THEN
            DELETE FROM tags WHERE entity_name = TG_TABLE_NAME;
            RETURN NULL;
          ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM tags WHERE entity_id = OLD.id;
            RETURN OLD;
          ELSE

          -- Triggered by INSERT/UPDATE
          -- Do an upsert on the tags table
          -- So we don't need to migrate pre 1.1 entities
          INSERT INTO tags VALUES (NEW.id, TG_TABLE_NAME, NEW.tags)
          ON CONFLICT (entity_id) DO UPDATE
                  SET tags=EXCLUDED.tags;
          END IF;
          RETURN NEW;
        END;
      $$;


ALTER FUNCTION public.sync_tags() OWNER TO kongpre;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acls; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.acls (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    "group" text,
    cache_key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.acls OWNER TO kongpre;

--
-- Name: acme_storage; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.acme_storage (
    id uuid NOT NULL,
    key text,
    value text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.acme_storage OWNER TO kongpre;

--
-- Name: apis; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.apis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    name text,
    upstream_url text,
    preserve_host boolean NOT NULL,
    retries smallint DEFAULT 5,
    https_only boolean,
    http_if_terminated boolean,
    hosts text,
    uris text,
    methods text,
    strip_uri boolean,
    upstream_connect_timeout integer,
    upstream_send_timeout integer,
    upstream_read_timeout integer
);


ALTER TABLE public.apis OWNER TO kongpre;

--
-- Name: basicauth_credentials; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.basicauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    username text,
    password text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.basicauth_credentials OWNER TO kongpre;

--
-- Name: ca_certificates; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.ca_certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text NOT NULL,
    tags text[],
    cert_digest text NOT NULL
);


ALTER TABLE public.ca_certificates OWNER TO kongpre;

--
-- Name: certificates; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text,
    key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.certificates OWNER TO kongpre;

--
-- Name: cluster_events; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.cluster_events (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    at timestamp with time zone NOT NULL,
    nbf timestamp with time zone,
    expire_at timestamp with time zone NOT NULL,
    channel text,
    data text
);


ALTER TABLE public.cluster_events OWNER TO kongpre;

--
-- Name: consumers; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.consumers (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    username text,
    custom_id text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.consumers OWNER TO kongpre;

--
-- Name: hmacauth_credentials; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.hmacauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    username text,
    secret text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.hmacauth_credentials OWNER TO kongpre;

--
-- Name: jwt_secrets; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.jwt_secrets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    key text,
    secret text,
    algorithm text,
    rsa_public_key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.jwt_secrets OWNER TO kongpre;

--
-- Name: keyauth_credentials; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.keyauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    key text,
    tags text[],
    ttl timestamp with time zone,
    ws_id uuid
);


ALTER TABLE public.keyauth_credentials OWNER TO kongpre;

--
-- Name: locks; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.locks (
    key text NOT NULL,
    owner text,
    ttl timestamp with time zone
);


ALTER TABLE public.locks OWNER TO kongpre;

--
-- Name: oauth2_authorization_codes; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.oauth2_authorization_codes (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    credential_id uuid,
    service_id uuid,
    code text,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    challenge text,
    challenge_method text,
    ws_id uuid
);


ALTER TABLE public.oauth2_authorization_codes OWNER TO kongpre;

--
-- Name: oauth2_credentials; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.oauth2_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text,
    consumer_id uuid,
    client_id text,
    client_secret text,
    redirect_uris text[],
    tags text[],
    client_type text,
    hash_secret boolean,
    ws_id uuid
);


ALTER TABLE public.oauth2_credentials OWNER TO kongpre;

--
-- Name: oauth2_tokens; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.oauth2_tokens (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    credential_id uuid,
    service_id uuid,
    access_token text,
    refresh_token text,
    token_type text,
    expires_in integer,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    ws_id uuid
);


ALTER TABLE public.oauth2_tokens OWNER TO kongpre;

--
-- Name: plugins; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.plugins (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text NOT NULL,
    consumer_id uuid,
    service_id uuid,
    route_id uuid,
    api_id uuid,
    config jsonb NOT NULL,
    enabled boolean NOT NULL,
    cache_key text,
    protocols text[],
    tags text[],
    ws_id uuid
);


ALTER TABLE public.plugins OWNER TO kongpre;

--
-- Name: ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer,
    ttl timestamp with time zone
);


ALTER TABLE public.ratelimiting_metrics OWNER TO kongpre;

--
-- Name: response_ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.response_ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


ALTER TABLE public.response_ratelimiting_metrics OWNER TO kongpre;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.routes (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    service_id uuid,
    protocols text[],
    methods text[],
    hosts text[],
    paths text[],
    regex_priority bigint,
    strip_path boolean,
    preserve_host boolean,
    name text,
    snis text[],
    sources jsonb[],
    destinations jsonb[],
    tags text[],
    https_redirect_status_code integer,
    headers jsonb,
    path_handling text DEFAULT 'v0'::text,
    ws_id uuid
);


ALTER TABLE public.routes OWNER TO kongpre;

--
-- Name: schema_meta; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.schema_meta (
    key text NOT NULL,
    subsystem text NOT NULL,
    last_executed text,
    executed text[],
    pending text[]
);


ALTER TABLE public.schema_meta OWNER TO kongpre;

--
-- Name: services; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.services (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    retries bigint,
    protocol text,
    host text,
    port bigint,
    path text,
    connect_timeout bigint,
    write_timeout bigint,
    read_timeout bigint,
    tags text[],
    client_certificate_id uuid,
    tls_verify boolean,
    tls_verify_depth smallint,
    ca_certificates uuid[],
    ws_id uuid
);


ALTER TABLE public.services OWNER TO kongpre;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    session_id text,
    expires integer,
    data text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.sessions OWNER TO kongpre;

--
-- Name: snis; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.snis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text NOT NULL,
    certificate_id uuid,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.snis OWNER TO kongpre;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.tags (
    entity_id uuid NOT NULL,
    entity_name text,
    tags text[]
);


ALTER TABLE public.tags OWNER TO kongpre;

--
-- Name: targets; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.targets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    upstream_id uuid,
    target text NOT NULL,
    weight integer NOT NULL,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.targets OWNER TO kongpre;

--
-- Name: ttls; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.ttls (
    primary_key_value text NOT NULL,
    primary_uuid_value uuid,
    table_name text NOT NULL,
    primary_key_name text NOT NULL,
    expire_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ttls OWNER TO kongpre;

--
-- Name: upstreams; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.upstreams (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    name text,
    hash_on text,
    hash_fallback text,
    hash_on_header text,
    hash_fallback_header text,
    hash_on_cookie text,
    hash_on_cookie_path text,
    slots integer NOT NULL,
    healthchecks jsonb,
    tags text[],
    algorithm text,
    host_header text,
    client_certificate_id uuid,
    ws_id uuid
);


ALTER TABLE public.upstreams OWNER TO kongpre;

--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: kongpre
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name text,
    comment text,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    meta jsonb,
    config jsonb
);


ALTER TABLE public.workspaces OWNER TO kongpre;

--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.acls (id, created_at, consumer_id, "group", cache_key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: acme_storage; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.acme_storage (id, key, value, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: apis; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.apis (id, created_at, name, upstream_url, preserve_host, retries, https_only, http_if_terminated, hosts, uris, methods, strip_uri, upstream_connect_timeout, upstream_send_timeout, upstream_read_timeout) FROM stdin;
\.


--
-- Data for Name: basicauth_credentials; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.basicauth_credentials (id, created_at, consumer_id, username, password, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: ca_certificates; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.ca_certificates (id, created_at, cert, tags, cert_digest) FROM stdin;
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.certificates (id, created_at, cert, key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: cluster_events; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.cluster_events (id, node_id, at, nbf, expire_at, channel, data) FROM stdin;
39896fc5-5399-4a57-b6e4-5eea50197468	17c61c1c-44ce-43da-a5ee-ec05157c6bc9	2021-08-17 04:46:37.983+00	\N	2021-08-17 05:46:37.983+00	invalidations	plugins:ydauth_sso:97d95c95-cb98-4067-9b20-8b5de0c6c389::::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
cdc9dcb5-742e-41ca-93c1-bb4f593ab882	17c61c1c-44ce-43da-a5ee-ec05157c6bc9	2021-08-17 04:46:37.984+00	\N	2021-08-17 05:46:37.984+00	invalidations	plugins_iterator:version
\.


--
-- Data for Name: consumers; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.consumers (id, created_at, username, custom_id, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: hmacauth_credentials; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.hmacauth_credentials (id, created_at, consumer_id, username, secret, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: jwt_secrets; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.jwt_secrets (id, created_at, consumer_id, key, secret, algorithm, rsa_public_key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: keyauth_credentials; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.keyauth_credentials (id, created_at, consumer_id, key, tags, ttl, ws_id) FROM stdin;
\.


--
-- Data for Name: locks; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.locks (key, owner, ttl) FROM stdin;
\.


--
-- Data for Name: oauth2_authorization_codes; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.oauth2_authorization_codes (id, created_at, credential_id, service_id, code, authenticated_userid, scope, ttl, challenge, challenge_method, ws_id) FROM stdin;
\.


--
-- Data for Name: oauth2_credentials; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.oauth2_credentials (id, created_at, name, consumer_id, client_id, client_secret, redirect_uris, tags, client_type, hash_secret, ws_id) FROM stdin;
\.


--
-- Data for Name: oauth2_tokens; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.oauth2_tokens (id, created_at, credential_id, service_id, access_token, refresh_token, token_type, expires_in, authenticated_userid, scope, ttl, ws_id) FROM stdin;
\.


--
-- Data for Name: plugins; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.plugins (id, created_at, name, consumer_id, service_id, route_id, api_id, config, enabled, cache_key, protocols, tags, ws_id) FROM stdin;
cf38344d-2947-4587-acf8-d2566eae7b7e	2019-09-12 02:11:59+00	cors	\N	e539ebdb-91a5-409f-a791-cbac36898bab	\N	\N	{"headers": ["Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Auth-Token"], "max_age": 3600, "methods": ["POST", "GET", "PUT", "DELETE", "HEAD", "OPTIONS"], "origins": ["*"], "credentials": true, "exposed_headers": null, "preflight_continue": false}	t	plugins:cors::e539ebdb-91a5-409f-a791-cbac36898bab:::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	{grpc,grpcs,http,https}	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
188f40e3-2f62-47d1-a315-baea1554e639	2019-09-12 02:19:55+00	cors	\N	21431dff-79ec-4f32-9351-71f9f257c64a	\N	\N	{"headers": ["Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Auth-Token"], "max_age": 3600, "methods": ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"], "origins": ["*"], "credentials": true, "exposed_headers": null, "preflight_continue": false}	t	plugins:cors::21431dff-79ec-4f32-9351-71f9f257c64a:::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	{grpc,grpcs,http,https}	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
600f3fbb-b4a6-4cb9-b006-1fd63858ba3a	2020-03-29 13:39:45+00	ydauth_sso	\N	\N	3909d9b3-3efe-49e1-bc6d-fb276f24f9e0	\N	{"redis_host": "172.16.100.111", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "pi2paUAEDrTwfD9MzDnkTGDIm-QB0FLH", "not_login_message": "没有登录"}	t	plugins:ydauth_sso:3909d9b3-3efe-49e1-bc6d-fb276f24f9e0::::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	{grpc,grpcs,http,https}	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
be17731e-90fa-4bca-b498-fca87c4b5b45	2019-09-12 02:17:38+00	admin-login-yd	\N	e539ebdb-91a5-409f-a791-cbac36898bab	\N	\N	{"redis_host": "172.16.100.226", "redis_port": 6379, "session_name": "PHPSESSID", "redis_timeout": 2000, "redis_database": 6, "redis_password": "pi2paUAEDrTwfD9MzDnkTGDIm-QB0FLH", "session_prefix": "PHPREDIS_SESSION:", "not_login_message": "没有登录", "serialize_handler": "php_serialize"}	t	plugins:admin-login-yd::e539ebdb-91a5-409f-a791-cbac36898bab:::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	{grpc,grpcs,http,https}	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b05b14db-a71f-44f7-a2c1-25faa82f174c	2021-08-17 04:46:37+00	ydauth_sso	\N	\N	97d95c95-cb98-4067-9b20-8b5de0c6c389	\N	{"not_login_message": "没有登录"}	t	plugins:ydauth_sso:97d95c95-cb98-4067-9b20-8b5de0c6c389::::612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	{grpc,grpcs,http,https}	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
\.


--
-- Data for Name: ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value, ttl) FROM stdin;
\.


--
-- Data for Name: response_ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.response_ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value) FROM stdin;
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.routes (id, created_at, updated_at, service_id, protocols, methods, hosts, paths, regex_priority, strip_path, preserve_host, name, snis, sources, destinations, tags, https_redirect_status_code, headers, path_handling, ws_id) FROM stdin;
4e5e0139-a95f-4706-904c-fcc0c886f326	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	dispatchapi_GetServerIpInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8a90445b-7420-4d93-a9b8-70577363d16d	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/list}	5	f	f	dispatchapi_GetServerIpList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
da819e34-e81c-432e-849c-3a5e52fb4b62	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/serverIps}	5	f	f	dispatchapi_GetServerIps	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
63ce09ac-e9cb-4e50-b8ae-de57220c9b22	2019-09-11 11:59:46+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag/info}	5	f	f	service_tag_TagInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fbcea680-5a3a-48c9-a268-6fa5d9812267	2019-09-11 11:59:47+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{POST}	{}	{/tag/save}	5	f	f	service_tag_TagSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
15110c8b-ba7a-4db7-a8f4-82580537583b	2019-09-11 14:15:25+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag/tree}	5	f	f	service_tag_TagTree	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
987301b2-760c-45d2-aa81-fbeb0a466a57	2019-09-11 11:59:47+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag_type/info}	5	f	f	service_tag_TagTypeInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0203ee85-f687-412f-80c8-9e5f19dc9706	2019-09-11 11:59:47+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{POST}	{}	{/tag_type/save}	5	f	f	service_tag_TagTypeSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
71102f32-f5dc-456f-a471-d321fdcc0640	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/asset}	0	t	f	dispatchapi_uripre_asset	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c4f6257f-8a66-46cc-a0c8-e43e12f09399	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/region/get}	5	f	f	dispatchapi_GetRegion	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6adc1fb2-cabd-443c-b843-d22482f003a8	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/update}	5	f	f	dispatchapi_UpdateServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9ce9d005-b80e-4563-9b3d-6e071da616a6	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/add_to_dispatch}	5	f	f	dispatchapi_addServerIpToDispatch	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3033c82b-0c29-4148-b0e7-5742edcaa3c9	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/add}	5	f	f	dispatchapi_AddServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a61613ae-21e2-4a54-905d-cecbb8fe789e	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/update}	5	f	f	dispatchapi_UpdateServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
dd3de381-680c-4384-939e-df08c1fb418a	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/add}	5	f	f	dispatchapi_AddIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
66203a90-61c9-428c-8aef-d6eb257e394f	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/del}	5	f	f	dispatchapi_DelIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
38875ca6-bf00-4a91-bbf4-48be432f445b	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/idc_house/info}	5	f	f	dispatchapi_GetIdcHouseInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c30cbbd1-5139-44ce-8a37-cf021ae6ac50	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/idc_house/list}	5	f	f	dispatchapi_GetIdcHouseList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1533bb3c-1152-4f03-bc43-2e4ce8f2c8ca	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/del}	5	f	f	dispatchapi_DelServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7dae13a0-f931-4607-bec6-f2ab4905720c	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	dispatchapi_GetServerInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ea189145-c1ca-4c72-be41-a0f0d6305fb2	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/server/list}	5	f	f	dispatchapi_GetServerList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1207cf88-513c-4798-a8e5-607134feb17b	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/add}	5	f	f	dispatchapi_AddServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5d88e214-079d-4c00-b9dd-3a9942c7906f	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/del}	5	f	f	dispatchapi_DelServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1e3450a8-4661-49fe-ba43-d209a3302a4a	2019-09-11 15:08:51+00	2019-09-11 15:08:51+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/update}	5	f	f	dispatchapi_UpdateIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f4ecbb5a-8e61-4448-ab6f-47c2ae9d8dbe	2019-09-11 14:15:25+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag/delete}	5	f	f	service_tag_TagDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
943e088e-d03c-4eed-a9c2-7e7701fe4185	2019-09-11 11:59:47+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag/list}	5	f	f	service_tag_TagList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ed7b592c-2581-4c3b-84b9-c479c90040cc	2019-09-11 11:59:47+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET}	{}	{/tag_type/list}	5	f	f	service_tag_TagTypeList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
635fe812-818e-443d-b6ef-0f7d3bc73d26	2019-09-11 08:45:10+00	2019-12-27 03:54:46+00	21431dff-79ec-4f32-9351-71f9f257c64a	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/tag}	0	t	f	service_tag_uripre_tag	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
38ee041a-88ac-4e38-818f-a5e494f6f39b	2019-10-24 06:49:27+00	2019-10-24 06:49:27+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/sync/save}	5	f	f	service_disp_DomainSyncSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f659070a-1eae-451b-8f3f-98069f07039d	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/tag/bind}	5	f	f	service_disp_IpBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1579b67f-3fec-482a-9a59-88e9d5f10ff6	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/tag/clear}	5	f	f	service_disp_IpClearTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ef4fb535-7452-419b-ba17-efdd28870bcc	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/delete}	5	f	f	service_disp_IpDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
249da714-5a36-485a-b307-ec1661905b8e	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/info}	5	f	f	service_disp_IpInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c2b71721-fb59-43a2-8383-9dbeecc061bf	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/list}	5	f	f	service_disp_IpList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
dadeb9ed-2054-44e2-9033-82cb890a1f25	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/turn_status}	5	f	f	service_disp_IpTurnStatus	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f790b7b8-16ca-4af4-8e28-81842e79bf9e	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/group/unbind}	5	f	f	service_disp_IpUnbindGroup	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d5683e61-7765-4a4a-90fe-2d67efb3e526	2019-10-24 06:49:26+00	2019-12-27 04:05:46+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/sync/save}	5	f	f	service_disp_IpSyncSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
59d98bd8-3164-4c76-957f-7e6beee30184	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/line/unbind}	5	f	f	service_disp_IpUnbindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6c89d025-4495-45a8-87bb-fd6fc268393e	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/tag/unbind}	5	f	f	service_disp_IpUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0cd0d2d4-1d82-407a-b5ec-ea0c2fed028d	2019-10-24 06:49:26+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/group/info}	5	f	f	service_disp_IpGroupInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2a2d41ba-c0a3-4100-858e-f32b6cacfb49	2019-10-24 06:49:26+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/group/list}	5	f	f	service_disp_IpGroupList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
70242a04-38ce-4337-badf-408506a2c07c	2019-10-24 06:49:26+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/group/save}	5	f	f	service_disp_IpGroupSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
32a53492-0e12-4985-a273-733f94b6d920	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/agent/line/bind}	5	f	f	service_disp_AgentBindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e85dc091-8fd3-4f0d-8b2a-ee98a8b7e645	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/agent/info}	5	f	f	service_disp_AgentInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
50592f65-eb67-42d9-99fa-fdff425656f4	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/agent/list}	5	f	f	service_disp_AgentList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f13366d3-5ddb-4a86-b967-fb55e433cece	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/agent/save}	5	f	f	service_disp_AgentSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
79f74d1b-72a8-48a0-82da-fb87a2971657	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/agent/line/unbind}	5	f	f	service_disp_AgentUnbindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
cd3a0816-1292-4ad0-b555-274e7487ee3e	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/line/bind}	5	f	f	service_disp_DomainBindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a17a8c3c-e773-42ad-b802-1fbdabeb0b82	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/tag/bind}	5	f	f	service_disp_DomainBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7d240e09-4185-4f3b-9225-82054f407cb4	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/domain/info}	5	f	f	service_disp_DomainInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
24cc2597-b43c-4761-bcfa-8222e283654f	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/domain/list}	5	f	f	service_disp_DomainList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e5c76b10-afb3-4c5c-9fef-a649ad0e8e61	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/domain/turn_net}	5	f	f	service_disp_DomainTurnNet	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c6863ad5-6f5e-4f9b-8fce-78ac62e8d6f7	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/tag/unbind}	5	f	f	service_disp_DomainUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8194f151-896f-4f74-a109-b21a302a5106	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/group/bind}	5	f	f	service_disp_IpBindGroup	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
67be3da5-29ce-4b5d-a8ba-7c5c83be4b92	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/line/bind}	5	f	f	service_disp_IpBindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d906ce89-b8bb-49ba-9092-6623d91dfbe2	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/meal/tag/bind}	5	f	f	service_disp_MealBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0d8aca01-f7ee-4944-8424-314f1355e232	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/meal/info}	5	f	f	service_disp_MealInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9994a730-ecca-498a-a139-5f2e34f9d5de	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/meal/list}	5	f	f	service_disp_MealList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
317ce8e0-3a0e-49a7-a1df-894903c1968b	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/meal/save}	5	f	f	service_disp_MealSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
118ec966-47da-47f0-b5c7-244607a9aade	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/meal/line/unbind}	5	f	f	service_disp_MealUnbindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c7761f44-686b-4f12-b5da-98b7ac9490b1	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/meal/tag/unbind}	5	f	f	service_disp_MealUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
26ecf9b7-1dfe-4a14-b03a-64fa2a9e0e9e	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/tag/all}	5	f	f	service_disp_TagAll	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1e8233cd-fe37-40d0-9112-11cb6cfec73b	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/tag/list}	5	f	f	service_disp_TagList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
385e9e26-77df-45a1-a235-32b74f9b1a03	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/tag/log/list}	5	f	f	service_disp_TagLogList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
841c2298-c1a3-4dbb-bf3a-e147c96c9e70	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/tag/sync/save}	5	f	f	service_disp_TagSyncSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7b1908b1-952f-4974-8c21-c3f33ac01300	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/tag/tree}	5	f	f	service_disp_TagTree	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9f16fbd5-7260-47fe-b3be-4be6b2a88449	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/user/line/bind}	5	f	f	service_disp_UserBindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
23f264c7-5f95-497b-b0c8-c1ed0ff4b841	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/user/tag/bind}	5	f	f	service_disp_UserBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
49af37b3-b04a-41a0-a783-9c42e79145e3	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/user/info}	5	f	f	service_disp_UserInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
da8b2c29-bdec-4c8b-9335-4a2b611e7074	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/user/list}	5	f	f	service_disp_UserList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
57cacf32-cc80-4920-a071-22bfa4c746e7	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/user/save}	5	f	f	service_disp_UserSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3ef38161-33c2-412a-8cf4-8a14c45e2e7e	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/user/line/unbind}	5	f	f	service_disp_UserUnbindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2751ecc9-6a3d-4e35-9734-7058d5c95635	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/user/tag/unbind}	5	f	f	service_disp_UserUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
cac312e0-38cd-434a-84eb-5aac732ffb34	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/monitor/ip/event}	5	f	f	service_disp_Monitor_IpEvent	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e6f827fe-4f67-40f2-9a95-bc3a5cda91dd	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/monitor/ip/list}	5	f	f	service_disp_Monitor_IpList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
73608267-6d5f-4723-bd1b-01626d0c2952	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/all}	5	f	f	service_disp_LineAll	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0e3fa330-720f-4fc7-b892-3b0c6ae02e5f	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/line/backip/bind}	5	f	f	service_disp_LineBindBackip	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b6b16ea3-bd35-45dd-b62a-9a56dfe2826b	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/delete}	5	f	f	service_disp_LineDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ea276277-b143-4b07-8381-b10eb77161b5	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/info}	5	f	f	service_disp_LineInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
bf94a284-289c-4704-a082-cc5cbb9612fd	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/list}	5	f	f	service_disp_LineList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5f31137d-530b-44dc-9147-40b37315d72b	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/line/save}	5	f	f	service_disp_LineSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5f974fef-740e-43e8-8f0b-1cc8eb6ea1bb	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/agent/tag/unbind}	5	f	f	service_disp_AgentUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fa699974-20a6-4d06-9d6a-29c1fc97a3f8	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/meal/line/bind}	5	f	f	service_disp_MealBindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
43606fb8-298f-4c2c-bed5-dc103c545328	2019-10-24 06:49:27+00	2019-10-24 06:49:27+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/record/list2}	5	f	f	service_disp_DispRecord2	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
dfff3586-e229-43c4-b863-1a27521a4af6	2019-12-19 11:00:22+00	2019-12-20 07:26:39+00	8213b0f4-2049-4fe4-adf4-077f908267f8	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/notify}	0	t	f	service_notify_uripre_notify	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
67769d54-13b5-47b7-83f0-e51bd969f541	2019-12-19 11:00:22+00	2019-12-20 07:26:39+00	8213b0f4-2049-4fe4-adf4-077f908267f8	{http,https}	{POST}	{}	{/v1/emailbatch}	5	f	f	service_notify_Emailbatch	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
036f552a-7024-42a9-8cf8-ed8407966552	2019-12-19 11:00:22+00	2019-12-20 07:26:39+00	8213b0f4-2049-4fe4-adf4-077f908267f8	{http,https}	{POST}	{}	{/v1/notice}	5	f	f	service_notify_Notice	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5fd83302-58ed-411e-8a89-370e4300290f	2019-12-19 11:00:23+00	2019-12-20 07:26:39+00	8213b0f4-2049-4fe4-adf4-077f908267f8	{http,https}	{POST}	{}	{/v1/smsbatch}	5	f	f	service_notify_Smsbatch	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6465724f-9c94-4f55-ab7c-d8ff103d2877	2019-12-19 11:00:23+00	2019-12-20 07:26:39+00	8213b0f4-2049-4fe4-adf4-077f908267f8	{http,https}	{POST}	{}	{/v1/voice1}	5	f	f	service_notify_Voice	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b3cb2e45-61d8-4f63-b4a0-59b79e12803c	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/domains/server_list}	5	f	f	service_dns_AdminDnsDomain_serverList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
29cea4f9-2618-4d05-8f6e-80c698ddb5d5	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/records/line_list}	5	f	f	service_dns_AdminDnsRecords_lineList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
70acd5f2-b5f1-449d-824a-832ed3c2a3a2	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/tree/nosearch}	5	f	f	service_disp_LineTreeNoSearch	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
4875487c-4f15-4ac3-b367-260dc77508ad	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/line/backip/unbind}	5	f	f	service_disp_LineUnbindBackip	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
967e96af-f8bc-44d9-b9f4-51092cb78224	2019-12-20 07:26:58+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/domains/change_server}	5	f	f	service_dns_AdminDnsDomain_domainsChangeServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
532fbfcc-dbd5-4661-adba-a8c2595553b1	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/domains/list}	5	f	f	service_dns_AdminDnsDomain_domainsList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0672ad73-2ffe-4bc6-aa1f-2282495b969e	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/domains/set_status}	5	f	f	service_dns_AdminDnsDomain_domainsSetStatus	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fa2891cb-7542-4bd8-9a1d-05db1702f32c	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/agent/domain}	5	f	f	service_disp_DispAgent_domain	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
26ee3a3f-31b1-4c4b-b32f-6adcc3e60431	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/domain}	5	f	f	service_disp_DispDomain	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6bc3f793-71a9-470d-82b3-bca01deaed1d	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/log}	5	f	f	service_disp_DispLogList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ccf1dc30-7860-4aa2-a4ca-a6bc1d9c3d44	2019-10-24 06:49:27+00	2019-12-27 04:05:46+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/agent/useip}	5	f	f	service_disp_DispAgent_useIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b9de7da2-6ad5-492d-a495-ecbe4c17a32c	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/meal/domain}	5	f	f	service_disp_DispMeal_domain	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5bc97199-a329-4ee1-ab5e-6d3553525970	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/user/domain}	5	f	f	service_disp_DispUser_domain	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
39f5eac4-47c8-4d50-a6c4-1f266a6aa4f5	2019-10-24 06:49:27+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/record/list}	5	f	f	service_disp_DispRecord	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7ac7f268-9a1a-4a24-9a5a-5795933efaf9	2019-10-24 06:49:27+00	2019-12-27 04:05:46+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/meal/useip}	5	f	f	service_disp_DispMeal_useIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d147c190-0cf0-44d4-a230-577b59c3c3d6	2019-10-24 06:49:27+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/record/delete}	5	f	f	service_disp_DispRecordDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
26bf2030-9fd7-411c-882a-dcc04d5ae0f8	2019-10-24 06:49:27+00	2019-12-27 04:05:46+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/user/useip}	5	f	f	service_disp_DispUser_useIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c5fa2d40-776e-4598-b23e-0c8b13cd6984	2019-10-24 06:49:27+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/disp/record/save}	5	f	f	service_disp_DispRecordSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
dfdc7f8b-402c-4529-96bb-a97838097285	2019-10-24 06:49:27+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/record/turn_status}	5	f	f	service_disp_DispRecordTurnStatus	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
21aa178f-7b3f-475a-aa62-594aedf93915	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/tree}	5	f	f	service_disp_LineTree	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f2eb8912-75f8-476f-adca-9ac63e2985f2	2019-12-20 07:26:58+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/domains/add}	5	f	f	service_dns_AdminDnsDomain_domainsAdd	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
662796a0-4d12-4f1c-91be-6e0e2043ec7c	2019-09-16 03:56:09+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/asset}	0	t	f	service_asset_uripre_asset	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2fbd3201-1606-47e4-b7f3-d17499356a56	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/region/get}	5	f	f	service_asset_GetRegion	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2db804bd-4880-4aa5-bca2-8b30ca66b1c0	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/add}	5	f	f	service_asset_AddServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
bdee985f-598d-49ed-bb30-e5ec8924ee05	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/del}	5	f	f	service_asset_DelServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b9dc3748-f565-40da-8847-71621fb43fc4	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	service_asset_GetServerInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1431cc31-b572-44d0-9f1b-81ece865256f	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/server/list}	5	f	f	service_asset_GetServerList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2c24104b-149e-4124-bd36-4c39f32805ab	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/add}	5	f	f	service_asset_AddServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9c1fe7f2-ee2f-4752-b199-c38586f91487	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/del}	5	f	f	service_asset_DelServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
351b1a83-ae4a-4e37-808d-f628ca74e27a	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	service_asset_GetServerIpInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
03c683b7-a1da-432b-b8fe-298842a4128a	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/list}	5	f	f	service_asset_GetServerIpList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
33c74969-05c7-471c-9c66-0d868d7a13d2	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/serverIp/serverIps}	5	f	f	service_asset_GetServerIps	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
36ea104a-15f4-4eed-910e-95a5ec5f9c12	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/update}	5	f	f	service_asset_UpdateServerIp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
4d5f8c7b-639e-4dff-9a19-f5437bac1d8e	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/add_to_dispatch}	5	f	f	service_asset_addServerIpToDispatch	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c31f1c66-e33f-435c-8d0a-e9e4dfbb15e4	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/serverIp/dispatchNotice}	5	f	f	service_asset_dispatchNotice	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
632b6e2b-1d94-4ce1-a197-48b240d848f4	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/server/update}	5	f	f	service_asset_UpdateServer	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b69cda3a-f073-4941-9c51-243fc44877b9	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/add}	5	f	f	service_asset_AddIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5563007e-3005-416b-883f-41254c4c29c2	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/del}	5	f	f	service_asset_DelIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
63ca3656-5beb-4a19-87ee-07d0a3d641e2	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/records/add}	5	f	f	service_dns_AdminDnsRecords_recordsAdd	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3f3e90de-f900-46ed-9e09-95c1f8a17983	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{DELETE}	{}	{/records/batch_del}	5	f	f	service_dns_AdminDnsRecords_recordsBatchDel	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f6339170-c599-4cfc-9ea5-b7b19186262d	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/records/list}	5	f	f	service_dns_AdminDnsRecords_recordsList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9c569711-6b8d-4355-8cea-477a32e40e8e	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/records/save}	5	f	f	service_dns_AdminDnsRecords_recordsSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3e7fed4b-03bb-4ab8-adee-7358e8a05c1e	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/tag_type/info}	5	f	f	service_dns_GetTag_typeInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5ebe26db-4044-4eeb-b56d-58fbfc967847	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/tag_type/list}	5	f	f	service_dns_GetTag_typeList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
88e29f77-79a0-430c-a46f-c8920311574f	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{POST}	{}	{/tag_type/save}	5	f	f	service_dns_PostTag_typeSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8ccbfa9b-3a3f-4a2a-bfb6-cece57a13772	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/idc_house/info}	5	f	f	service_asset_GetIdcHouseInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f0bb81ee-3bdd-477f-8d96-a8a4389c5b4a	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{GET}	{}	{/v1/idc_house/list}	5	f	f	service_asset_GetIdcHouseList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e8e6c0a4-c350-4c75-97af-715df7075fd6	2019-12-27 03:54:36+00	2019-12-27 03:54:36+00	e539ebdb-91a5-409f-a791-cbac36898bab	{http,https}	{POST}	{}	{/v1/idc_house/update}	5	f	f	service_asset_UpdateIdcHouse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fb2f5b40-6c19-4662-bd45-df87e9b53fcc	2020-03-16 07:36:41+00	2020-03-16 07:36:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/s_oplog}	0	t	f	service_oplog_uripre_batch	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
12704f99-2519-4b5b-85ec-7194d01fbf3b	2020-03-16 07:36:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog}	1	t	f	service_oplog_uripre_agw	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3909d9b3-3efe-49e1-bc6d-fb276f24f9e0	2020-03-29 13:34:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog/console}	0	t	f	service_oplog_uripre_agw_console	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f0d5f5cf-f7f8-49cd-bcda-4b91e180bb10	2020-03-16 07:36:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET}	{}	{/oplog/info}	5	f	f	service_oplog_OpLog_info	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
28ae7451-0deb-4609-b6ba-77737c5be3b1	2020-03-16 07:36:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET}	{}	{/oplog/list}	5	f	f	service_oplog_OpLog_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
db52d456-e99d-4dbf-8ded-96fbbe6eac05	2020-03-16 07:36:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{POST}	{}	{/oplog/save}	5	f	f	service_oplog_OpLog_save	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fcec7fbc-0f43-484c-b63b-342a27988138	2020-03-29 13:34:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET}	{}	{/user/oplog/info}	5	f	f	service_oplog_User_opLog_info	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2b5f5aa1-548d-4cd9-90a0-b6394663818a	2020-03-29 13:34:41+00	2020-03-29 13:34:41+00	07cbd02b-a390-4573-8fb1-7008cb29f0db	{http,https}	{GET}	{}	{/user/oplog/list}	5	f	f	service_oplog_User_opLog_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
573d5def-4651-402c-beab-b5a5d33af4a1	2019-12-20 07:26:58+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/dns}	0	t	f	service_dns_uripre_dns	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
42984f16-3bea-47b8-a49e-f8eba3365945	2020-03-31 08:00:06+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/dns}	1	t	f	service_dns_uripre_agw	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9f68b2a0-4592-4c6d-a11d-e5051fe2ac86	2020-03-31 08:00:06+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns/admin}	0	t	f	service_dns_uripre_agw_dns_admin	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
799a1b87-a776-40a3-8b31-657d4a3a7cba	2020-03-31 08:00:06+00	2020-03-31 08:00:06+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns/console}	0	t	f	service_dns_uripre_agw_dns_console	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
88612406-626a-443f-9f8c-f8dcf0c00012	2019-12-20 07:26:58+00	2020-03-31 08:00:07+00	839c0b75-a0e9-4083-b91a-5e1fac7dd79a	{http,https}	{GET}	{}	{/records/info}	5	f	f	service_dns_AdminDnsRecords_recordsInfo	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
38072f23-8fc0-4047-bcdc-5d86768a6af4	2020-03-31 08:01:47+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch/admin}	0	t	f	service_batch_uripre_agw_batch_admin	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
66474517-ee74-4d78-8751-5c59817ecf55	2020-03-31 08:01:47+00	2020-03-31 08:01:47+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/batch}	1	t	f	service_batch_uripre_agw	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8a42f27f-2332-4d95-b14f-a5403a4c2f31	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET}	{}	{/v1/subtask/list}	5	f	f	service_batch_ListSubTask	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e6a06c45-9645-4ac6-9ee2-b08080ce9a10	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET}	{}	{/v1/task/list}	5	f	f	service_batch_ListTask	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1c276833-7d76-42ab-a1d7-ea414580ff78	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/line/unbind}	5	f	f	service_disp_DomainUnbindLine	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
315e9cba-1ecb-45f5-b4f3-dc8ecccb232e	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/batch}	0	t	f	service_batch_uripre_batch	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6f3014ca-8b31-4185-966f-9fcf3a9c376b	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET}	{}	{/v1/subtask/info}	5	f	f	service_batch_InfoSubTask	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1eb1f380-2e3b-4926-aa4c-f9dd5abbe1e1	2019-10-24 06:49:27+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/agent/tag/bind}	5	f	f	service_disp_AgentBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a028a44f-4bbc-4ca9-9749-ae865a55ba6f	2019-12-27 04:05:46+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/domain/save}	5	f	f	service_disp_DomainSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
794e5dff-9181-44e7-8aca-3982bf2e044f	2019-12-27 04:05:46+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/agent}	5	f	f	service_disp_DispAgent	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
43355e64-4634-4ed5-9d9f-fc957e6c0ba9	2019-12-27 04:05:46+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/meal}	5	f	f	service_disp_DispMeal	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8b580543-6854-4d0b-9cff-c7d2c8adb5c1	2019-12-27 04:05:46+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/user}	5	f	f	service_disp_DispUser	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a05c656a-950d-48c1-aef6-cd462b9b4cf6	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/s_disp}	0	t	f	service_disp_uripre_disp	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
97d95c95-cb98-4067-9b20-8b5de0c6c389	2020-03-31 08:01:47+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch/console}	0	t	f	service_batch_uripre_agw_batch_console	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
79ae02e2-1811-416a-9770-2194f3b7566b	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	9b80a005-910e-47ee-aa1e-d93580872de1	{http,https}	{POST}	{}	{/v1/task/add}	5	f	f	service_batch_AddTask	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6c0cb6ba-e6a8-4948-850e-af0d09534eae	2020-07-10 07:40:50+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/save}	5	f	f	service_disp_IpSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
56b57c98-a43c-4cf4-b19d-aa4bdffa1eab	2020-08-04 07:36:22+00	2020-08-05 02:03:28+00	807df635-5117-4795-b5f2-ab4f0e01e49f	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/dns_check}	0	t	f	dns_check_uripre_dns_check	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a4c1c48f-3d89-4781-a9bc-1112aabcb8b1	2020-08-04 07:36:22+00	2020-08-05 02:03:28+00	807df635-5117-4795-b5f2-ab4f0e01e49f	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns_check}	0	t	f	dns_check_uripre_agw_dns_check	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c6757650-1175-4697-805a-adea5fa28363	2020-08-05 02:03:28+00	2020-08-05 02:03:28+00	807df635-5117-4795-b5f2-ab4f0e01e49f	{http,https}	{GET,POST}	{}	{/domains/cname_domains/rabbitmq}	5	f	f	dns_check_DomainsCnameRabbitmq	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
45b2c65d-6b0d-4fbc-ae75-8e8eaacd52de	2020-08-05 02:03:28+00	2020-08-05 02:03:28+00	807df635-5117-4795-b5f2-ab4f0e01e49f	{http,https}	{GET,POST}	{}	{/domains/info_domains/list}	5	f	f	dns_check_DomainsInfoList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7518dde6-a795-43b2-be83-12aac8ca0330	2020-08-05 02:03:28+00	2020-08-05 02:03:28+00	807df635-5117-4795-b5f2-ab4f0e01e49f	{http,https}	{GET,POST}	{}	{/domains/info_domains/map}	5	f	f	dns_check_DomainsInfoMap	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3f60901d-2d49-43df-b2bb-4bb0f8b0bced	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/cdn}	1	t	f	service_cdn_uripre_cdn	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
035e06bd-7198-4a88-95a2-d10471a6d3bb	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/cdn/admin}	1	t	f	service_cdn_uripre_agw_cdn_admin	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
191847e7-f941-40eb-aa7c-6ca3dc1fc9a0	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/cdn/console}	0	t	f	service_cdn_uripre_agw_cdn_console	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
39023471-6299-4e72-a795-5cf29f5def48	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET}	{}	{/domain/delete}	5	f	f	service_cdn_Domain_delete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0d665290-92b0-4146-b401-424ab1b2d4c9	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET}	{}	{/domain/info}	5	f	f	service_cdn_Domain_info	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2175fd5a-7034-4efa-bfdc-510a1062de25	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET}	{}	{/domain/list}	5	f	f	service_cdn_Domain_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a139e787-c51c-4b99-901c-269182503ee9	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{POST}	{}	{/ca/verify}	5	f	f	service_cdn_Ca_verify	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1ea78ffb-6fb9-4d6d-b917-3d5a536e4c57	2020-07-10 07:40:50+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/disp/admin}	0	t	f	service_disp_uripre_agw_disp_admin	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fbaca1ab-a6e5-421c-8615-44e816f85887	2020-07-10 07:40:50+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/disp/console}	0	t	f	service_disp_uripre_agw_disp_console	\N	\N	\N	\N	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6776399f-6141-4db9-9af5-6bcbb735331d	2020-07-10 07:40:51+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/tag/check_use}	5	f	f	service_disp_TagCheckUse	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b7560e97-8cbf-4fd1-9a9b-e2fc31dd1569	2020-07-10 07:40:50+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/batch_record}	5	f	f	service_disp_Ip_batchRecord	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
bba83567-678a-4004-8eda-6cd597eff05b	2020-07-10 07:40:50+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/redisp}	5	f	f	service_disp_Ip_redisp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
efc1a8d1-aa39-47db-87a3-2fc0b437392c	2020-07-10 07:40:51+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/monitor/event/add}	5	f	f	service_disp_Monitor_EventAdd	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
871b5644-dc0d-4f71-99b7-7359bb61d3d8	2020-07-10 07:40:51+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/ips}	5	f	f	service_disp_DispIps	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c955afec-5dea-41a9-bc99-3ea8b3dd92b0	2020-07-10 07:40:51+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/meal/ips}	5	f	f	service_disp_DispMealIps	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
99fd5aed-bbd3-49ce-a661-dc64b845d061	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{POST}	{}	{/domain/save}	5	f	f	service_cdn_Domain_Save	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6602f548-ab4c-48ec-9d00-a8451f554157	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{DELETE}	{}	{/user.ip.item.del}	5	f	f	service_cdn_User_ip_item_del	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
11654f8d-e5da-41ac-824c-77331b167fd1	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{POST}	{}	{/user.ip.item.all}	5	f	f	service_cdn_User_ip_item_del_check	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
5390a071-0f11-4b71-ae4b-643277889b18	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{PUT}	{}	{/user.ip.item.edit}	5	f	f	service_cdn_User_ip_item_edit	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7194f47a-7626-44fd-832e-4abd419a6804	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{POST}	{}	{/user.ip.item.file.save}	5	f	f	service_cdn_User_ip_item_file_save	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b33414ac-08ab-4f36-81ae-24542097a256	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{GET}	{}	{/user.ip.item.list}	5	f	f	service_cdn_User_ip_item_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d0f93257-101e-442f-baa8-e7a135816536	2020-10-10 02:32:57+00	2020-10-10 02:32:57+00	e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	{http,https}	{POST}	{}	{/user.ip.item.text.save}	5	f	f	service_cdn_User_ip_item_text_save	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
621f502d-85cb-41fb-b1f5-c6ee15215213	2020-12-04 08:34:33+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/distribute/list}	5	f	f	service_disp_IpDistributeList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
648d5fff-b4d4-4e8c-96e8-0eebb7f5541b	2020-12-04 08:34:33+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/distribute/op}	5	f	f	service_disp_IpDistributeOp	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
33c705fb-0f60-4ab1-a61d-335ae6c1fd98	2020-12-04 08:34:33+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/distributeinfo/list}	5	f	f	service_disp_IpDistributeinfoList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e918eaef-f4dc-40c6-ab37-46c4f8b2a0d0	2020-12-04 08:34:33+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/batch_save_status}	5	f	f	service_disp_Ip_batchSaveStatus	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2bafd1f3-e447-4f0c-bf20-c9850bb7bc44	2020-12-04 08:34:33+00	2020-12-04 08:34:33+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/line_group/bind}	5	f	f	service_disp_Ip_bindLineGroup	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
7552d5f8-e3fd-4630-a4b3-e8ad618c4f75	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/group/delete}	5	f	f	service_disp_IpGroupDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0dff9a57-0337-4988-bd50-16e8ee11ef29	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/event/add}	5	f	f	service_disp_Event_add	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2b36b9c4-0d8d-4126-911a-a720c0641a36	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/event/list}	5	f	f	service_disp_Event_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8dec1811-4480-4665-ac30-133e15f419a6	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line/tree/region}	5	f	f	service_disp_Line_treeRegion	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
dec0b116-22be-45fb-801e-a76148f13c1a	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line_group/delete}	5	f	f	service_disp_LineGroup_delete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
be786e8e-2a43-4054-b4c2-70d5bd91beee	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line_group/info}	5	f	f	service_disp_LineGroup_info	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
bb57983b-01c6-4796-9eae-28aff9550d68	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/line_group/list}	5	f	f	service_disp_LineGroup_list	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
c75cc2d9-8301-49d1-bf55-712d992056ae	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/line_group/save}	5	f	f	service_disp_LineGroup_save	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d330e028-3c66-4944-9ed4-7fc8181b13bf	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/line_group/switch_status}	5	f	f	service_disp_LineGroup_switch_status	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ec0b5aa9-20e7-46c7-a27d-acb818453d16	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/policy/ip/select}	5	f	f	service_disp_DispPolicyIpSelect	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
37c71f93-f69c-4083-a18a-f175d57d7c91	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/policy/list}	5	f	f	service_disp_DispPolicyList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9f3b56d6-ef0c-42f6-91a7-a47bf094a687	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/disp/policy/operate}	5	f	f	service_disp_DispPolicyOperate	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ef4b9232-0e04-415a-a194-12fea722473d	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/disp/group/list}	5	f	f	service_disp_DispGroupList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b7cb855a-92c3-45f6-b4bc-5f5f0a8eb38d	2020-12-04 08:34:34+00	2020-12-04 08:34:34+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/disp/group/save}	5	f	f	service_disp_DispGroupSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
03251760-d599-4d79-b19c-dad1393fc8c6	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/pool/tag/bind}	5	f	f	service_disp_IpPoolBindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b742a786-e0da-476f-89bb-0bd2baeb3d9a	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/group/list}	5	f	f	service_disp_IpPoolGroupList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0d1852f9-fc5d-42c3-842e-ad415311e17d	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/ip/add}	5	f	f	service_disp_IpPoolIpAdd	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
371dcd52-4629-4351-98d4-5352f01f2ed8	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/ip/delete}	5	f	f	service_disp_IpPoolIpDelete	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0d40dc1f-1440-4348-9b8e-a95b7e34c39a	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/ip/on}	5	f	f	service_disp_IpPoolIpOn	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
52731cfb-cfc9-472a-bfb1-ca29fbd51b3f	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/ip/pause}	5	f	f	service_disp_IpPoolIpPause	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
08ef2c6f-598f-496b-a87d-ba6a686f72ed	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/ip/select}	5	f	f	service_disp_IpPoolIpSelect	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d6c4d85f-f410-459a-8164-edd402741c78	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/list}	5	f	f	service_disp_IpPoolList	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
630381c3-350b-4818-b9c2-91fe55628894	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{GET}	{}	{/ip/pool/obtain}	5	f	f	service_disp_IpPoolObtain	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a85b3ded-4410-4d51-bc9b-83cf7d47322e	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/pool/save}	5	f	f	service_disp_IpPoolSave	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
f8f862a5-54b2-4a9d-a62b-41651108dc07	2020-12-04 08:34:35+00	2020-12-04 08:34:35+00	8f48b943-b3c7-4066-80f6-fb7d7a8f210b	{http,https}	{POST}	{}	{/ip/pool/tag/unbind}	5	f	f	service_disp_IpPoolUnbindTag	{}	\N	\N	{}	426	\N	v1	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
\.


--
-- Data for Name: schema_meta; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.schema_meta (key, subsystem, last_executed, executed, pending) FROM stdin;
schema_meta	acme	000_base_acme	{000_base_acme}	\N
schema_meta	hmac-auth	003_200_to_210	{000_base_hmac_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	ip-restriction	001_200_to_210	{001_200_to_210}	{}
schema_meta	jwt	003_200_to_210	{000_base_jwt,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	basic-auth	003_200_to_210	{000_base_basic_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	key-auth	003_200_to_210	{000_base_key_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	bot-detection	001_200_to_210	{001_200_to_210}	{}
schema_meta	core	011_212_to_213	{000_base,001_14_to_15,002_15_to_1,003_100_to_110,004_110_to_120,005_120_to_130,006_130_to_140,007_140_to_150,008_150_to_200,009_200_to_210,010_210_to_211,011_212_to_213}	{}
schema_meta	response-ratelimiting	002_15_to_10	{000_base_response_rate_limiting,001_14_to_15,002_15_to_10}	{}
schema_meta	session	000_base_session	{000_base_session}	\N
schema_meta	oauth2	005_210_to_211	{000_base_oauth2,001_14_to_15,002_15_to_10,003_130_to_140,004_200_to_210,005_210_to_211}	{}
schema_meta	acl	003_200_to_210	{000_base_acl,001_14_to_15,002_130_to_140,003_200_to_210}	{004_212_to_213}
schema_meta	rate-limiting	004_200_to_210	{000_base_rate_limiting,001_14_to_15,002_15_to_10,003_10_to_112,004_200_to_210}	{}
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.services (id, created_at, updated_at, name, retries, protocol, host, port, path, connect_timeout, write_timeout, read_timeout, tags, client_certificate_id, tls_verify, tls_verify_depth, ca_certificates, ws_id) FROM stdin;
8213b0f4-2049-4fe4-adf4-077f908267f8	2019-12-19 11:00:22+00	2019-12-20 07:26:39+00	service_notify	5	http	service_notify	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e539ebdb-91a5-409f-a791-cbac36898bab	2019-09-11 15:08:51+00	2019-12-27 03:54:36+00	service_asset	5	http	service_asset	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
21431dff-79ec-4f32-9351-71f9f257c64a	2019-09-11 08:45:10+00	2019-12-27 03:54:46+00	service_tag	5	http	service_tag	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
07cbd02b-a390-4573-8fb1-7008cb29f0db	2020-03-16 07:36:41+00	2020-03-29 13:34:41+00	service_oplog	5	http	service_oplog	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
839c0b75-a0e9-4083-b91a-5e1fac7dd79a	2019-12-20 07:26:58+00	2020-03-31 08:00:06+00	service_dns	5	http	service_dns	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9b80a005-910e-47ee-aa1e-d93580872de1	2020-03-06 07:32:22+00	2020-03-31 09:00:44+00	service_batch	5	http	service_batch	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
807df635-5117-4795-b5f2-ab4f0e01e49f	2020-08-04 07:36:22+00	2020-08-05 02:03:28+00	dns_check	5	http	dns_check	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	2020-10-10 02:32:56+00	2020-10-10 02:32:56+00	service_cdn	5	http	service_cdn	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8f48b943-b3c7-4066-80f6-fb7d7a8f210b	2019-10-24 06:49:26+00	2020-12-04 08:34:33+00	service_disp	5	http	service_disp	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.sessions (id, session_id, expires, data, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: snis; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.snis (id, created_at, name, certificate_id, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.tags (entity_id, entity_name, tags) FROM stdin;
516d3669-4a1a-4e3d-8f6b-21c6c85c6d3a	targets	\N
ac0b6c2d-222e-434d-9670-4aef3ff2be09	targets	\N
68eaf77d-d043-4518-8150-072c9276b5bc	targets	\N
2d864a34-5484-4677-9855-db681b35980e	targets	\N
38ee041a-88ac-4e38-818f-a5e494f6f39b	routes	{}
600f3fbb-b4a6-4cb9-b006-1fd63858ba3a	plugins	\N
8f48b943-b3c7-4066-80f6-fb7d7a8f210b	services	\N
a05c656a-950d-48c1-aef6-cd462b9b4cf6	routes	\N
71102f32-f5dc-456f-a471-d321fdcc0640	routes	\N
8194f151-896f-4f74-a109-b21a302a5106	routes	{}
c4f6257f-8a66-46cc-a0c8-e43e12f09399	routes	{}
3033c82b-0c29-4148-b0e7-5742edcaa3c9	routes	{}
1533bb3c-1152-4f03-bc43-2e4ce8f2c8ca	routes	{}
7dae13a0-f931-4607-bec6-f2ab4905720c	routes	{}
ea189145-c1ca-4c72-be41-a0f0d6305fb2	routes	{}
1207cf88-513c-4798-a8e5-607134feb17b	routes	{}
5d88e214-079d-4c00-b9dd-3a9942c7906f	routes	{}
4e5e0139-a95f-4706-904c-fcc0c886f326	routes	{}
8a90445b-7420-4d93-a9b8-70577363d16d	routes	{}
da819e34-e81c-432e-849c-3a5e52fb4b62	routes	{}
6adc1fb2-cabd-443c-b843-d22482f003a8	routes	{}
9ce9d005-b80e-4563-9b3d-6e071da616a6	routes	{}
a61613ae-21e2-4a54-905d-cecbb8fe789e	routes	{}
dd3de381-680c-4384-939e-df08c1fb418a	routes	{}
66203a90-61c9-428c-8aef-d6eb257e394f	routes	{}
38875ca6-bf00-4a91-bbf4-48be432f445b	routes	{}
c30cbbd1-5139-44ce-8a37-cf021ae6ac50	routes	{}
1e3450a8-4661-49fe-ba43-d209a3302a4a	routes	{}
cf38344d-2947-4587-acf8-d2566eae7b7e	plugins	\N
188f40e3-2f62-47d1-a315-baea1554e639	plugins	\N
be17731e-90fa-4bca-b498-fca87c4b5b45	plugins	\N
21431dff-79ec-4f32-9351-71f9f257c64a	services	\N
6b8b4f3b-ffe2-4e92-9fa5-7d054a349b97	targets	\N
635fe812-818e-443d-b6ef-0f7d3bc73d26	routes	\N
f4ecbb5a-8e61-4448-ab6f-47c2ae9d8dbe	routes	{}
63ce09ac-e9cb-4e50-b8ae-de57220c9b22	routes	{}
943e088e-d03c-4eed-a9c2-7e7701fe4185	routes	{}
fbcea680-5a3a-48c9-a268-6fa5d9812267	routes	{}
15110c8b-ba7a-4db7-a8f4-82580537583b	routes	{}
987301b2-760c-45d2-aa81-fbeb0a466a57	routes	{}
ed7b592c-2581-4c3b-84b9-c479c90040cc	routes	{}
0203ee85-f687-412f-80c8-9e5f19dc9706	routes	{}
67be3da5-29ce-4b5d-a8ba-7c5c83be4b92	routes	{}
8f90568b-38c8-49be-8061-8c110894766d	targets	\N
662796a0-4d12-4f1c-91be-6e0e2043ec7c	routes	\N
f659070a-1eae-451b-8f3f-98069f07039d	routes	{}
43606fb8-298f-4c2c-bed5-dc103c545328	routes	{}
1579b67f-3fec-482a-9a59-88e9d5f10ff6	routes	{}
ba66b6d1-b61e-40f6-a981-7f51275c1268	targets	\N
65436512-1a41-4b2a-b6cc-d7dbf95271b6	upstreams	\N
8213b0f4-2049-4fe4-adf4-077f908267f8	services	\N
ddf1fd92-afcb-4483-b7dc-051e654c5f78	upstreams	\N
e539ebdb-91a5-409f-a791-cbac36898bab	services	\N
b5e04a4b-f4fd-4576-9b3f-e920441e3b64	upstreams	\N
ef4fb535-7452-419b-ba17-efdd28870bcc	routes	{}
249da714-5a36-485a-b307-ec1661905b8e	routes	{}
c2b71721-fb59-43a2-8383-9dbeecc061bf	routes	{}
dadeb9ed-2054-44e2-9033-82cb890a1f25	routes	{}
f790b7b8-16ca-4af4-8e28-81842e79bf9e	routes	{}
59d98bd8-3164-4c76-957f-7e6beee30184	routes	{}
6c89d025-4495-45a8-87bb-fd6fc268393e	routes	{}
0cd0d2d4-1d82-407a-b5ec-ea0c2fed028d	routes	{}
2a2d41ba-c0a3-4100-858e-f32b6cacfb49	routes	{}
d5683e61-7765-4a4a-90fe-2d67efb3e526	routes	{}
70242a04-38ce-4337-badf-408506a2c07c	routes	{}
32a53492-0e12-4985-a273-733f94b6d920	routes	{}
e85dc091-8fd3-4f0d-8b2a-ee98a8b7e645	routes	{}
50592f65-eb67-42d9-99fa-fdff425656f4	routes	{}
79f74d1b-72a8-48a0-82da-fb87a2971657	routes	{}
cd3a0816-1292-4ad0-b555-274e7487ee3e	routes	{}
a17a8c3c-e773-42ad-b802-1fbdabeb0b82	routes	{}
7d240e09-4185-4f3b-9225-82054f407cb4	routes	{}
24cc2597-b43c-4761-bcfa-8222e283654f	routes	{}
e5c76b10-afb3-4c5c-9fef-a649ad0e8e61	routes	{}
1c276833-7d76-42ab-a1d7-ea414580ff78	routes	{}
c6863ad5-6f5e-4f9b-8fce-78ac62e8d6f7	routes	{}
1eb1f380-2e3b-4926-aa4c-f9dd5abbe1e1	routes	{}
5f974fef-740e-43e8-8f0b-1cc8eb6ea1bb	routes	{}
fa699974-20a6-4d06-9d6a-29c1fc97a3f8	routes	{}
d906ce89-b8bb-49ba-9092-6623d91dfbe2	routes	{}
0d8aca01-f7ee-4944-8424-314f1355e232	routes	{}
9994a730-ecca-498a-a139-5f2e34f9d5de	routes	{}
317ce8e0-3a0e-49a7-a1df-894903c1968b	routes	{}
118ec966-47da-47f0-b5c7-244607a9aade	routes	{}
26ecf9b7-1dfe-4a14-b03a-64fa2a9e0e9e	routes	{}
1e8233cd-fe37-40d0-9112-11cb6cfec73b	routes	{}
385e9e26-77df-45a1-a235-32b74f9b1a03	routes	{}
841c2298-c1a3-4dbb-bf3a-e147c96c9e70	routes	{}
7b1908b1-952f-4974-8c21-c3f33ac01300	routes	{}
9f16fbd5-7260-47fe-b3be-4be6b2a88449	routes	{}
23f264c7-5f95-497b-b0c8-c1ed0ff4b841	routes	{}
49af37b3-b04a-41a0-a783-9c42e79145e3	routes	{}
da8b2c29-bdec-4c8b-9335-4a2b611e7074	routes	{}
57cacf32-cc80-4920-a071-22bfa4c746e7	routes	{}
3ef38161-33c2-412a-8cf4-8a14c45e2e7e	routes	{}
2751ecc9-6a3d-4e35-9734-7058d5c95635	routes	{}
cac312e0-38cd-434a-84eb-5aac732ffb34	routes	{}
e6f827fe-4f67-40f2-9a95-bc3a5cda91dd	routes	{}
73608267-6d5f-4723-bd1b-01626d0c2952	routes	{}
0e3fa330-720f-4fc7-b892-3b0c6ae02e5f	routes	{}
ea276277-b143-4b07-8381-b10eb77161b5	routes	{}
bf94a284-289c-4704-a082-cc5cbb9612fd	routes	{}
5f31137d-530b-44dc-9147-40b37315d72b	routes	{}
21aa178f-7b3f-475a-aa62-594aedf93915	routes	{}
70acd5f2-b5f1-449d-824a-832ed3c2a3a2	routes	{}
4875487c-4f15-4ac3-b367-260dc77508ad	routes	{}
fa2891cb-7542-4bd8-9a1d-05db1702f32c	routes	{}
26ee3a3f-31b1-4c4b-b32f-6adcc3e60431	routes	{}
6bc3f793-71a9-470d-82b3-bca01deaed1d	routes	{}
b9de7da2-6ad5-492d-a495-ecbe4c17a32c	routes	{}
5bc97199-a329-4ee1-ab5e-6d3553525970	routes	{}
39f5eac4-47c8-4d50-a6c4-1f266a6aa4f5	routes	{}
d147c190-0cf0-44d4-a230-577b59c3c3d6	routes	{}
ccf1dc30-7860-4aa2-a4ca-a6bc1d9c3d44	routes	{}
dfdc7f8b-402c-4529-96bb-a97838097285	routes	{}
3a442f2d-9196-43fa-9a4b-b27d421b6c5c	upstreams	\N
7ac7f268-9a1a-4a24-9a5a-5795933efaf9	routes	{}
26bf2030-9fd7-411c-882a-dcc04d5ae0f8	routes	{}
0fe90040-705d-4ad6-a9b9-0843b018ec8f	targets	\N
dfff3586-e229-43c4-b863-1a27521a4af6	routes	\N
67769d54-13b5-47b7-83f0-e51bd969f541	routes	{}
036f552a-7024-42a9-8cf8-ed8407966552	routes	{}
5fd83302-58ed-411e-8a89-370e4300290f	routes	{}
6465724f-9c94-4f55-ab7c-d8ff103d2877	routes	{}
535f090a-ceef-4200-a146-e5794758e7fa	targets	\N
65425949-2052-4d98-96bf-acb760078d24	targets	\N
8c26f6f9-a06a-4626-a9f8-90cd64fad92d	upstreams	\N
727b6cc1-76af-4f9b-ad13-9e2dcb7364cb	targets	\N
362002c3-ca92-4416-b9a8-d326fd1aebcb	targets	\N
839c0b75-a0e9-4083-b91a-5e1fac7dd79a	services	\N
573d5def-4651-402c-beab-b5a5d33af4a1	routes	\N
42984f16-3bea-47b8-a49e-f8eba3365945	routes	\N
9f68b2a0-4592-4c6d-a11d-e5051fe2ac86	routes	\N
799a1b87-a776-40a3-8b31-657d4a3a7cba	routes	\N
f2eb8912-75f8-476f-adca-9ac63e2985f2	routes	{}
967e96af-f8bc-44d9-b9f4-51092cb78224	routes	{}
532fbfcc-dbd5-4661-adba-a8c2595553b1	routes	{}
0672ad73-2ffe-4bc6-aa1f-2282495b969e	routes	{}
b3cb2e45-61d8-4f63-b4a0-59b79e12803c	routes	{}
29cea4f9-2618-4d05-8f6e-80c698ddb5d5	routes	{}
63ca3656-5beb-4a19-87ee-07d0a3d641e2	routes	{}
3f3e90de-f900-46ed-9e09-95c1f8a17983	routes	{}
88612406-626a-443f-9f8c-f8dcf0c00012	routes	{}
f6339170-c599-4cfc-9ea5-b7b19186262d	routes	{}
6971d6dc-c9c5-40cc-b905-d45894bd67ad	targets	\N
9c569711-6b8d-4355-8cea-477a32e40e8e	routes	{}
de76cef1-4145-4b76-97fa-a0efe3d88a0b	targets	\N
3e7fed4b-03bb-4ab8-adee-7358e8a05c1e	routes	{}
5ebe26db-4044-4eeb-b56d-58fbfc967847	routes	{}
88e29f77-79a0-430c-a46f-c8920311574f	routes	{}
66474517-ee74-4d78-8751-5c59817ecf55	routes	\N
38072f23-8fc0-4047-bcdc-5d86768a6af4	routes	\N
97d95c95-cb98-4067-9b20-8b5de0c6c389	routes	\N
cc763bf8-aa03-427c-859f-fae171802b88	targets	\N
871b5644-dc0d-4f71-99b7-7359bb61d3d8	routes	{}
8e0c7179-26f7-427c-95e4-d5f0e232e831	targets	\N
115a9757-5d87-44cf-8ba0-39406ca807ec	targets	\N
c6757650-1175-4697-805a-adea5fa28363	routes	{}
45b2c65d-6b0d-4fbc-ae75-8e8eaacd52de	routes	{}
7518dde6-a795-43b2-be83-12aac8ca0330	routes	{}
d80a8fa4-e556-428f-ab11-ccdbea5f660d	targets	\N
1ea78ffb-6fb9-4d6d-b917-3d5a536e4c57	routes	\N
fbaca1ab-a6e5-421c-8615-44e816f85887	routes	\N
621f502d-85cb-41fb-b1f5-c6ee15215213	routes	{}
648d5fff-b4d4-4e8c-96e8-0eebb7f5541b	routes	{}
33c705fb-0f60-4ab1-a61d-335ae6c1fd98	routes	{}
c955afec-5dea-41a9-bc99-3ea8b3dd92b0	routes	{}
6c0cb6ba-e6a8-4948-850e-af0d09534eae	routes	{}
b7560e97-8cbf-4fd1-9a9b-e2fc31dd1569	routes	{}
ef4b9232-0e04-415a-a194-12fea722473d	routes	{}
efafd70a-21b5-4cd7-a1a3-fb7d74e44f8f	targets	\N
b7cb855a-92c3-45f6-b4bc-5f5f0a8eb38d	routes	{}
03251760-d599-4d79-b19c-dad1393fc8c6	routes	{}
b742a786-e0da-476f-89bb-0bd2baeb3d9a	routes	{}
0d1852f9-fc5d-42c3-842e-ad415311e17d	routes	{}
371dcd52-4629-4351-98d4-5352f01f2ed8	routes	{}
0d40dc1f-1440-4348-9b8e-a95b7e34c39a	routes	{}
52731cfb-cfc9-472a-bfb1-ca29fbd51b3f	routes	{}
08ef2c6f-598f-496b-a87d-ba6a686f72ed	routes	{}
d6c4d85f-f410-459a-8164-edd402741c78	routes	{}
630381c3-350b-4818-b9c2-91fe55628894	routes	{}
a85b3ded-4410-4d51-bc9b-83cf7d47322e	routes	{}
f8f862a5-54b2-4a9d-a62b-41651108dc07	routes	{}
1c2b21dc-1e5e-4018-a0e1-3bc006a553fb	targets	\N
75a68570-3341-4622-af25-0a5f4a37e59c	targets	\N
2fbd3201-1606-47e4-b7f3-d17499356a56	routes	{}
2db804bd-4880-4aa5-bca2-8b30ca66b1c0	routes	{}
bdee985f-598d-49ed-bb30-e5ec8924ee05	routes	{}
b9dc3748-f565-40da-8847-71621fb43fc4	routes	{}
1431cc31-b572-44d0-9f1b-81ece865256f	routes	{}
2c24104b-149e-4124-bd36-4c39f32805ab	routes	{}
9c1fe7f2-ee2f-4752-b199-c38586f91487	routes	{}
351b1a83-ae4a-4e37-808d-f628ca74e27a	routes	{}
03c683b7-a1da-432b-b8fe-298842a4128a	routes	{}
33c74969-05c7-471c-9c66-0d868d7a13d2	routes	{}
36ea104a-15f4-4eed-910e-95a5ec5f9c12	routes	{}
4d5f8c7b-639e-4dff-9a19-f5437bac1d8e	routes	{}
c31f1c66-e33f-435c-8d0a-e9e4dfbb15e4	routes	{}
632b6e2b-1d94-4ce1-a197-48b240d848f4	routes	{}
b69cda3a-f073-4941-9c51-243fc44877b9	routes	{}
5563007e-3005-416b-883f-41254c4c29c2	routes	{}
8ccbfa9b-3a3f-4a2a-bfb6-cece57a13772	routes	{}
f0bb81ee-3bdd-477f-8d96-a8a4389c5b4a	routes	{}
e8e6c0a4-c350-4c75-97af-715df7075fd6	routes	{}
cfb1dc94-ce39-42e8-90d9-1da1df05898e	targets	\N
160438e2-fe73-4564-a8d6-ed993a5f17d3	targets	\N
e918eaef-f4dc-40c6-ab37-46c4f8b2a0d0	routes	{}
2bafd1f3-e447-4f0c-bf20-c9850bb7bc44	routes	{}
bba83567-678a-4004-8eda-6cd597eff05b	routes	{}
7552d5f8-e3fd-4630-a4b3-e8ad618c4f75	routes	{}
0dff9a57-0337-4988-bd50-16e8ee11ef29	routes	{}
2b36b9c4-0d8d-4126-911a-a720c0641a36	routes	{}
6776399f-6141-4db9-9af5-6bcbb735331d	routes	{}
efc1a8d1-aa39-47db-87a3-2fc0b437392c	routes	{}
8dec1811-4480-4665-ac30-133e15f419a6	routes	{}
dec0b116-22be-45fb-801e-a76148f13c1a	routes	{}
be786e8e-2a43-4054-b4c2-70d5bd91beee	routes	{}
bb57983b-01c6-4796-9eae-28aff9550d68	routes	{}
c75cc2d9-8301-49d1-bf55-712d992056ae	routes	{}
d330e028-3c66-4944-9ed4-7fc8181b13bf	routes	{}
ec0b5aa9-20e7-46c7-a27d-acb818453d16	routes	{}
37c71f93-f69c-4083-a18a-f175d57d7c91	routes	{}
9f3b56d6-ef0c-42f6-91a7-a47bf094a687	routes	{}
ba9ec99b-5a71-497c-afcf-368ee5bd4a40	targets	\N
fb2f5b40-6c19-4662-bd45-df87e9b53fcc	routes	\N
6dec570e-6cd9-48d2-be83-7ba6961e2c14	upstreams	\N
052d08da-f246-4e86-8138-4a7334312a80	targets	\N
07cbd02b-a390-4573-8fb1-7008cb29f0db	services	\N
12704f99-2519-4b5b-85ec-7194d01fbf3b	routes	\N
3909d9b3-3efe-49e1-bc6d-fb276f24f9e0	routes	\N
f0d5f5cf-f7f8-49cd-bcda-4b91e180bb10	routes	{}
28ae7451-0deb-4609-b6ba-77737c5be3b1	routes	{}
db52d456-e99d-4dbf-8ded-96fbbe6eac05	routes	{}
fcec7fbc-0f43-484c-b63b-342a27988138	routes	{}
2b5f5aa1-548d-4cd9-90a0-b6394663818a	routes	{}
e7e50737-3d69-449f-b7f3-438d422942a9	targets	\N
e453dccd-cc64-4f06-8b00-af4f679e8401	upstreams	\N
9b80a005-910e-47ee-aa1e-d93580872de1	services	\N
315e9cba-1ecb-45f5-b4f3-dc8ecccb232e	routes	\N
79ae02e2-1811-416a-9770-2194f3b7566b	routes	{}
6f3014ca-8b31-4185-966f-9fcf3a9c376b	routes	{}
8a42f27f-2332-4d95-b14f-a5403a4c2f31	routes	{}
e6a06c45-9645-4ac6-9ee2-b08080ce9a10	routes	{}
fc8d946d-f838-4c45-b8a5-ed1c775111a9	targets	\N
57e2e71e-d8d4-4cbc-90e6-c246b50d1270	upstreams	\N
807df635-5117-4795-b5f2-ab4f0e01e49f	services	\N
56b57c98-a43c-4cf4-b19d-aa4bdffa1eab	routes	\N
a4c1c48f-3d89-4781-a9bc-1112aabcb8b1	routes	\N
25d7d127-1c8d-4d6e-a7e1-15fcdbbe0156	upstreams	\N
4fb0edf4-269b-4336-b84c-01f571e26b10	targets	\N
e4dac1c1-2ec8-4ee8-88a3-5d6dcea32d02	services	\N
3f60901d-2d49-43df-b2bb-4bb0f8b0bced	routes	\N
035e06bd-7198-4a88-95a2-d10471a6d3bb	routes	\N
191847e7-f941-40eb-aa7c-6ca3dc1fc9a0	routes	\N
39023471-6299-4e72-a795-5cf29f5def48	routes	{}
0d665290-92b0-4146-b401-424ab1b2d4c9	routes	{}
2175fd5a-7034-4efa-bfdc-510a1062de25	routes	{}
a139e787-c51c-4b99-901c-269182503ee9	routes	{}
99fd5aed-bbd3-49ce-a661-dc64b845d061	routes	{}
6602f548-ab4c-48ec-9d00-a8451f554157	routes	{}
11654f8d-e5da-41ac-824c-77331b167fd1	routes	{}
5390a071-0f11-4b71-ae4b-643277889b18	routes	{}
7194f47a-7626-44fd-832e-4abd419a6804	routes	{}
b33414ac-08ab-4f36-81ae-24542097a256	routes	{}
d0f93257-101e-442f-baa8-e7a135816536	routes	{}
f13366d3-5ddb-4a86-b967-fb55e433cece	routes	{}
a028a44f-4bbc-4ca9-9749-ae865a55ba6f	routes	{}
c7761f44-686b-4f12-b5da-98b7ac9490b1	routes	{}
b6b16ea3-bd35-45dd-b62a-9a56dfe2826b	routes	{}
794e5dff-9181-44e7-8aca-3982bf2e044f	routes	{}
43355e64-4634-4ed5-9d9f-fc957e6c0ba9	routes	{}
8b580543-6854-4d0b-9cff-c7d2c8adb5c1	routes	{}
c5fa2d40-776e-4598-b23e-0c8b13cd6984	routes	{}
a48328e5-e48d-4167-88c8-9db4b60586ec	targets	\N
8e0ecf7d-3cb5-4963-afcb-32765d2d4fb4	targets	\N
86ba1e72-d09c-40bc-9470-73e18c5e1a3b	targets	\N
e14274cd-fd9a-4025-b449-a3cc760f954b	targets	\N
3693638e-a3b2-49d4-92e2-c0db5af7820b	targets	\N
8afe9d22-54b3-4125-8575-d7cb7e911b10	targets	\N
2e931199-1f86-43df-b6a9-48e54e4bfc3a	targets	\N
199893f2-60e8-4af9-85f9-f8a81713e9aa	targets	\N
b55a7a32-8291-4968-bf72-b751acd1a853	targets	\N
92116cc7-613a-4365-865b-57f5a77a974e	targets	\N
2747ac40-d739-4f78-aed2-5a35c08948ad	targets	\N
e27efb6c-80ff-42c1-be31-7fc0bafe29c3	targets	\N
ecec43d5-77b9-4daf-8e9d-805d0ab5f958	targets	\N
41357cef-161e-42d7-a0dd-293a3780303b	targets	\N
21fdea98-0e76-4a20-bb0d-85f88505486c	targets	\N
9f8beec3-cbc8-4a81-b580-dcd871be3b03	targets	\N
d719b14c-599a-4e36-baa4-54eca966efb2	targets	\N
549f6da6-a1b9-491a-b90c-8aa9c887d40c	targets	\N
4d4a63dc-8718-490a-b591-7a079cb08a63	targets	\N
34c126e0-0aac-43f3-8a9f-a4cc44b6a4d1	targets	\N
b05b14db-a71f-44f7-a2c1-25faa82f174c	plugins	\N
\.


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.targets (id, created_at, upstream_id, target, weight, tags, ws_id) FROM stdin;
68eaf77d-d043-4518-8150-072c9276b5bc	2019-09-11 14:15:24.582+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.33:7971	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2d864a34-5484-4677-9855-db681b35980e	2019-09-11 14:15:24.717+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.33:7971	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6b8b4f3b-ffe2-4e92-9fa5-7d054a349b97	2019-09-16 03:56:04.858+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.165:7971	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8f90568b-38c8-49be-8061-8c110894766d	2019-09-16 03:56:09.476+00	ddf1fd92-afcb-4483-b7dc-051e654c5f78	172.16.100.165:9089	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
516d3669-4a1a-4e3d-8f6b-21c6c85c6d3a	2019-09-16 06:49:30.625+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.33:7971	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ac0b6c2d-222e-434d-9670-4aef3ff2be09	2019-10-24 06:49:26.786+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.165:7970	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ba66b6d1-b61e-40f6-a981-7f51275c1268	2019-12-19 11:00:22.583+00	65436512-1a41-4b2a-b6cc-d7dbf95271b6	172.16.100.33:8085	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
0fe90040-705d-4ad6-a9b9-0843b018ec8f	2019-12-20 07:26:39.73+00	65436512-1a41-4b2a-b6cc-d7dbf95271b6	172.16.100.165:8085	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
535f090a-ceef-4200-a146-e5794758e7fa	2019-12-20 07:26:49.795+00	65436512-1a41-4b2a-b6cc-d7dbf95271b6	172.16.100.33:8085	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
65425949-2052-4d98-96bf-acb760078d24	2019-12-20 07:26:58.194+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.33:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
727b6cc1-76af-4f9b-ad13-9e2dcb7364cb	2019-12-20 07:27:45.162+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6971d6dc-c9c5-40cc-b905-d45894bd67ad	2019-12-20 07:27:56.266+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.33:7972	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
de76cef1-4145-4b76-97fa-a0efe3d88a0b	2019-12-23 08:53:31.12+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8e0c7179-26f7-427c-95e4-d5f0e232e831	2019-12-26 02:22:27.191+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
efafd70a-21b5-4cd7-a1a3-fb7d74e44f8f	2019-12-26 02:36:19.559+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
75a68570-3341-4622-af25-0a5f4a37e59c	2019-12-27 03:54:36.509+00	ddf1fd92-afcb-4483-b7dc-051e654c5f78	172.16.100.165:9089	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
cfb1dc94-ce39-42e8-90d9-1da1df05898e	2019-12-27 03:54:46.128+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.165:7971	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
160438e2-fe73-4564-a8d6-ed993a5f17d3	2019-12-27 04:05:45.958+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.165:7970	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ba9ec99b-5a71-497c-afcf-368ee5bd4a40	2020-03-16 07:36:41.806+00	6dec570e-6cd9-48d2-be83-7ba6961e2c14	172.16.100.188:7979	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
052d08da-f246-4e86-8138-4a7334312a80	2020-03-29 13:34:40.992+00	6dec570e-6cd9-48d2-be83-7ba6961e2c14	172.16.100.111:59104	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e7e50737-3d69-449f-b7f3-438d422942a9	2020-03-29 13:35:02.454+00	6dec570e-6cd9-48d2-be83-7ba6961e2c14	172.16.100.188:7979	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
362002c3-ca92-4416-b9a8-d326fd1aebcb	2020-03-31 08:00:06.864+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	50	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
cc763bf8-aa03-427c-859f-fae171802b88	2020-07-10 07:40:50.168+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.111:7970	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
fc8d946d-f838-4c45-b8a5-ed1c775111a9	2020-08-04 07:36:22.457+00	57e2e71e-d8d4-4cbc-90e6-c246b50d1270	172.16.100.111:59106	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
115a9757-5d87-44cf-8ba0-39406ca807ec	2020-08-05 02:03:28.52+00	57e2e71e-d8d4-4cbc-90e6-c246b50d1270	172.16.100.111:59106	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
4fb0edf4-269b-4336-b84c-01f571e26b10	2020-10-10 02:32:56.91+00	25d7d127-1c8d-4d6e-a7e1-15fcdbbe0156	172.16.100.111:59108	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d80a8fa4-e556-428f-ab11-ccdbea5f660d	2020-12-04 08:34:33.557+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.111:7970	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
1c2b21dc-1e5e-4018-a0e1-3bc006a553fb	2021-06-09 12:15:24.209+00	e453dccd-cc64-4f06-8b00-af4f679e8401	172.16.100.111:59105	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
a48328e5-e48d-4167-88c8-9db4b60586ec	2021-08-16 07:49:45.528+00	25d7d127-1c8d-4d6e-a7e1-15fcdbbe0156	service_cdn.pre.nodevops.cn:59108	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8e0ecf7d-3cb5-4963-afcb-32765d2d4fb4	2021-08-16 07:49:52.049+00	25d7d127-1c8d-4d6e-a7e1-15fcdbbe0156	172.16.100.111:59108	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
86ba1e72-d09c-40bc-9470-73e18c5e1a3b	2021-08-16 07:50:23.188+00	57e2e71e-d8d4-4cbc-90e6-c246b50d1270	dns_check.pre.nodevops.cn:59106	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e14274cd-fd9a-4025-b449-a3cc760f954b	2021-08-16 07:50:27.889+00	57e2e71e-d8d4-4cbc-90e6-c246b50d1270	172.16.100.111:59106	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3693638e-a3b2-49d4-92e2-c0db5af7820b	2021-08-16 07:50:55.573+00	6dec570e-6cd9-48d2-be83-7ba6961e2c14	sevice_oplog.pre.nodevops.cn:59104	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8afe9d22-54b3-4125-8575-d7cb7e911b10	2021-08-16 07:50:59.376+00	6dec570e-6cd9-48d2-be83-7ba6961e2c14	172.16.100.111:59104	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2e931199-1f86-43df-b6a9-48e54e4bfc3a	2021-08-16 07:53:28.408+00	e453dccd-cc64-4f06-8b00-af4f679e8401	service_batch.pre.nodevops.cn:59105	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
199893f2-60e8-4af9-85f9-f8a81713e9aa	2021-08-16 07:53:31.726+00	e453dccd-cc64-4f06-8b00-af4f679e8401	172.16.100.111:59105	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b55a7a32-8291-4968-bf72-b751acd1a853	2021-08-16 07:56:13.118+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	service_dns.pre.nodevps.cn:7972	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
92116cc7-613a-4365-865b-57f5a77a974e	2021-08-16 07:56:16.56+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	service_dns.pre.nodevps.cn:7972	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
2747ac40-d739-4f78-aed2-5a35c08948ad	2021-08-16 07:56:20.323+00	8c26f6f9-a06a-4626-a9f8-90cd64fad92d	172.16.100.165:7972	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e27efb6c-80ff-42c1-be31-7fc0bafe29c3	2021-08-16 07:57:10.28+00	65436512-1a41-4b2a-b6cc-d7dbf95271b6	service_notify.pre.nodevops.cn:8085	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ecec43d5-77b9-4daf-8e9d-805d0ab5f958	2021-08-16 07:57:14.388+00	65436512-1a41-4b2a-b6cc-d7dbf95271b6	172.16.100.165:8085	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
41357cef-161e-42d7-a0dd-293a3780303b	2021-08-16 07:59:54.38+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	service_disp.pre.nodevops.cn:7970	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
21fdea98-0e76-4a20-bb0d-85f88505486c	2021-08-16 07:59:58.083+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.111:7970	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
9f8beec3-cbc8-4a81-b580-dcd871be3b03	2021-08-16 08:00:00.571+00	3a442f2d-9196-43fa-9a4b-b27d421b6c5c	172.16.100.165:7970	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
d719b14c-599a-4e36-baa4-54eca966efb2	2021-08-16 08:00:44.138+00	ddf1fd92-afcb-4483-b7dc-051e654c5f78	serivce_asset.pre.nodevops.cn:9089	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
549f6da6-a1b9-491a-b90c-8aa9c887d40c	2021-08-16 08:00:47.85+00	ddf1fd92-afcb-4483-b7dc-051e654c5f78	172.16.100.165:9089	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
4d4a63dc-8718-490a-b591-7a079cb08a63	2021-08-16 08:01:47.904+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	serivce_tag.pre.nodevops.cn:7971	100	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
34c126e0-0aac-43f3-8a9f-a4cc44b6a4d1	2021-08-16 08:01:50.981+00	b5e04a4b-f4fd-4576-9b3f-e920441e3b64	172.16.100.165:7971	0	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
\.


--
-- Data for Name: ttls; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.ttls (primary_key_value, primary_uuid_value, table_name, primary_key_name, expire_at) FROM stdin;
\.


--
-- Data for Name: upstreams; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.upstreams (id, created_at, name, hash_on, hash_fallback, hash_on_header, hash_fallback_header, hash_on_cookie, hash_on_cookie_path, slots, healthchecks, tags, algorithm, host_header, client_certificate_id, ws_id) FROM stdin;
65436512-1a41-4b2a-b6cc-d7dbf95271b6	2019-12-19 11:00:22+00	service_notify	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
3a442f2d-9196-43fa-9a4b-b27d421b6c5c	2019-10-24 06:49:26+00	service_disp	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
ddf1fd92-afcb-4483-b7dc-051e654c5f78	2019-09-16 03:56:09+00	service_asset	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
b5e04a4b-f4fd-4576-9b3f-e920441e3b64	2019-09-11 08:45:10+00	service_tag	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
8c26f6f9-a06a-4626-a9f8-90cd64fad92d	2019-12-20 07:26:58+00	service_dns	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
e453dccd-cc64-4f06-8b00-af4f679e8401	2020-03-06 07:32:21+00	service_batch	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
6dec570e-6cd9-48d2-be83-7ba6961e2c14	2020-03-16 07:36:41+00	service_oplog	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
57e2e71e-d8d4-4cbc-90e6-c246b50d1270	2020-08-04 07:36:22+00	dns_check	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
25d7d127-1c8d-4d6e-a7e1-15fcdbbe0156	2020-10-10 02:32:56+00	service_cdn	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	612b9197-4d0f-4ec5-bab1-52c67ccfc2ff
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: kongpre
--

COPY public.workspaces (id, name, comment, created_at, meta, config) FROM stdin;
612b9197-4d0f-4ec5-bab1-52c67ccfc2ff	default	\N	2021-01-02 14:42:28+00	\N	\N
\.


--
-- Name: acls acls_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_cache_key_key UNIQUE (cache_key);


--
-- Name: acls acls_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: acls acls_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: acme_storage acme_storage_key_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_key_key UNIQUE (key);


--
-- Name: acme_storage acme_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_pkey PRIMARY KEY (id);


--
-- Name: apis apis_name_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.apis
    ADD CONSTRAINT apis_name_key UNIQUE (name);


--
-- Name: apis apis_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.apis
    ADD CONSTRAINT apis_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: basicauth_credentials basicauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: ca_certificates ca_certificates_cert_digest_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_cert_digest_key UNIQUE (cert_digest);


--
-- Name: ca_certificates ca_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: cluster_events cluster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.cluster_events
    ADD CONSTRAINT cluster_events_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: consumers consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_ws_id_custom_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_custom_id_unique UNIQUE (ws_id, custom_id);


--
-- Name: consumers consumers_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: hmacauth_credentials hmacauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: hmacauth_credentials hmacauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: jwt_secrets jwt_secrets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: jwt_secrets jwt_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_pkey PRIMARY KEY (id);


--
-- Name: jwt_secrets jwt_secrets_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: keyauth_credentials keyauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: keyauth_credentials keyauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: locks locks_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (key);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_code_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_code_unique UNIQUE (ws_id, code);


--
-- Name: oauth2_credentials oauth2_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_credentials oauth2_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_pkey PRIMARY KEY (id);


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_client_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_client_id_unique UNIQUE (ws_id, client_id);


--
-- Name: oauth2_tokens oauth2_tokens_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_tokens oauth2_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_access_token_unique UNIQUE (ws_id, access_token);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_refresh_token_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_refresh_token_unique UNIQUE (ws_id, refresh_token);


--
-- Name: plugins plugins_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_cache_key_key UNIQUE (cache_key);


--
-- Name: plugins plugins_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: ratelimiting_metrics ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.ratelimiting_metrics
    ADD CONSTRAINT ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: response_ratelimiting_metrics response_ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.response_ratelimiting_metrics
    ADD CONSTRAINT response_ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: routes routes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: routes routes_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: schema_meta schema_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.schema_meta
    ADD CONSTRAINT schema_meta_pkey PRIMARY KEY (key, subsystem);


--
-- Name: services services_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: services services_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: snis snis_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: snis snis_name_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_name_key UNIQUE (name);


--
-- Name: snis snis_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (entity_id);


--
-- Name: targets targets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: ttls ttls_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.ttls
    ADD CONSTRAINT ttls_pkey PRIMARY KEY (primary_key_value, table_name);


--
-- Name: upstreams upstreams_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: upstreams upstreams_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_pkey PRIMARY KEY (id);


--
-- Name: upstreams upstreams_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: workspaces workspaces_name_key; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_name_key UNIQUE (name);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: acls_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX acls_consumer_id_idx ON public.acls USING btree (consumer_id);


--
-- Name: acls_group_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX acls_group_idx ON public.acls USING btree ("group");


--
-- Name: acls_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX acls_tags_idex_tags_idx ON public.acls USING gin (tags);


--
-- Name: basicauth_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX basicauth_consumer_id_idx ON public.basicauth_credentials USING btree (consumer_id);


--
-- Name: basicauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX basicauth_tags_idex_tags_idx ON public.basicauth_credentials USING gin (tags);


--
-- Name: certificates_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX certificates_tags_idx ON public.certificates USING gin (tags);


--
-- Name: cluster_events_at_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX cluster_events_at_idx ON public.cluster_events USING btree (at);


--
-- Name: cluster_events_channel_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX cluster_events_channel_idx ON public.cluster_events USING btree (channel);


--
-- Name: cluster_events_expire_at_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX cluster_events_expire_at_idx ON public.cluster_events USING btree (expire_at);


--
-- Name: consumers_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX consumers_tags_idx ON public.consumers USING gin (tags);


--
-- Name: consumers_username_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX consumers_username_idx ON public.consumers USING btree (lower(username));


--
-- Name: hmacauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX hmacauth_credentials_consumer_id_idx ON public.hmacauth_credentials USING btree (consumer_id);


--
-- Name: hmacauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX hmacauth_tags_idex_tags_idx ON public.hmacauth_credentials USING gin (tags);


--
-- Name: jwt_secrets_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX jwt_secrets_consumer_id_idx ON public.jwt_secrets USING btree (consumer_id);


--
-- Name: jwt_secrets_secret_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX jwt_secrets_secret_idx ON public.jwt_secrets USING btree (secret);


--
-- Name: jwtsecrets_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX jwtsecrets_tags_idex_tags_idx ON public.jwt_secrets USING gin (tags);


--
-- Name: keyauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX keyauth_credentials_consumer_id_idx ON public.keyauth_credentials USING btree (consumer_id);


--
-- Name: keyauth_credentials_ttl_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX keyauth_credentials_ttl_idx ON public.keyauth_credentials USING btree (ttl);


--
-- Name: keyauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX keyauth_tags_idex_tags_idx ON public.keyauth_credentials USING gin (tags);


--
-- Name: locks_ttl_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX locks_ttl_idx ON public.locks USING btree (ttl);


--
-- Name: oauth2_authorization_codes_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_authorization_codes_authenticated_userid_idx ON public.oauth2_authorization_codes USING btree (authenticated_userid);


--
-- Name: oauth2_authorization_codes_ttl_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_authorization_codes_ttl_idx ON public.oauth2_authorization_codes USING btree (ttl);


--
-- Name: oauth2_authorization_credential_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_authorization_credential_id_idx ON public.oauth2_authorization_codes USING btree (credential_id);


--
-- Name: oauth2_authorization_service_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_authorization_service_id_idx ON public.oauth2_authorization_codes USING btree (service_id);


--
-- Name: oauth2_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_credentials_consumer_id_idx ON public.oauth2_credentials USING btree (consumer_id);


--
-- Name: oauth2_credentials_secret_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_credentials_secret_idx ON public.oauth2_credentials USING btree (client_secret);


--
-- Name: oauth2_credentials_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_credentials_tags_idex_tags_idx ON public.oauth2_credentials USING gin (tags);


--
-- Name: oauth2_tokens_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_tokens_authenticated_userid_idx ON public.oauth2_tokens USING btree (authenticated_userid);


--
-- Name: oauth2_tokens_credential_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_tokens_credential_id_idx ON public.oauth2_tokens USING btree (credential_id);


--
-- Name: oauth2_tokens_service_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_tokens_service_id_idx ON public.oauth2_tokens USING btree (service_id);


--
-- Name: oauth2_tokens_ttl_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX oauth2_tokens_ttl_idx ON public.oauth2_tokens USING btree (ttl);


--
-- Name: plugins_api_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_api_id_idx ON public.plugins USING btree (api_id);


--
-- Name: plugins_consumer_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_consumer_id_idx ON public.plugins USING btree (consumer_id);


--
-- Name: plugins_name_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_name_idx ON public.plugins USING btree (name);


--
-- Name: plugins_route_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_route_id_idx ON public.plugins USING btree (route_id);


--
-- Name: plugins_service_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_service_id_idx ON public.plugins USING btree (service_id);


--
-- Name: plugins_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX plugins_tags_idx ON public.plugins USING gin (tags);


--
-- Name: ratelimiting_metrics_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX ratelimiting_metrics_idx ON public.ratelimiting_metrics USING btree (service_id, route_id, period_date, period);


--
-- Name: ratelimiting_metrics_ttl_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX ratelimiting_metrics_ttl_idx ON public.ratelimiting_metrics USING btree (ttl);


--
-- Name: routes_service_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX routes_service_id_idx ON public.routes USING btree (service_id);


--
-- Name: routes_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX routes_tags_idx ON public.routes USING gin (tags);


--
-- Name: services_fkey_client_certificate; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX services_fkey_client_certificate ON public.services USING btree (client_certificate_id);


--
-- Name: services_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX services_tags_idx ON public.services USING gin (tags);


--
-- Name: session_sessions_expires_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX session_sessions_expires_idx ON public.sessions USING btree (expires);


--
-- Name: snis_certificate_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX snis_certificate_id_idx ON public.snis USING btree (certificate_id);


--
-- Name: snis_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX snis_tags_idx ON public.snis USING gin (tags);


--
-- Name: tags_entity_name_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX tags_entity_name_idx ON public.tags USING btree (entity_name);


--
-- Name: tags_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX tags_tags_idx ON public.tags USING gin (tags);


--
-- Name: targets_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX targets_tags_idx ON public.targets USING gin (tags);


--
-- Name: targets_target_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX targets_target_idx ON public.targets USING btree (target);


--
-- Name: targets_upstream_id_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX targets_upstream_id_idx ON public.targets USING btree (upstream_id);


--
-- Name: ttls_primary_uuid_value_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX ttls_primary_uuid_value_idx ON public.ttls USING btree (primary_uuid_value);


--
-- Name: upstreams_fkey_client_certificate; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX upstreams_fkey_client_certificate ON public.upstreams USING btree (client_certificate_id);


--
-- Name: upstreams_tags_idx; Type: INDEX; Schema: public; Owner: kongpre
--

CREATE INDEX upstreams_tags_idx ON public.upstreams USING gin (tags);


--
-- Name: acls acls_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER acls_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.acls FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: basicauth_credentials basicauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER basicauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.basicauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: ca_certificates ca_certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER ca_certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.ca_certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: certificates certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: consumers consumers_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER consumers_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.consumers FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: hmacauth_credentials hmacauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER hmacauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.hmacauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: jwt_secrets jwtsecrets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER jwtsecrets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.jwt_secrets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: keyauth_credentials keyauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER keyauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keyauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: oauth2_credentials oauth2_credentials_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER oauth2_credentials_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.oauth2_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: plugins plugins_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER plugins_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.plugins FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: routes routes_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER routes_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.routes FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: services services_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER services_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.services FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: snis snis_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER snis_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.snis FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: targets targets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER targets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.targets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: upstreams upstreams_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kongpre
--

CREATE TRIGGER upstreams_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.upstreams FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: acls acls_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: acls acls_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: basicauth_credentials basicauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: certificates certificates_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: consumers consumers_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: hmacauth_credentials hmacauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: jwt_secrets jwt_secrets_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: jwt_secrets jwt_secrets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keyauth_credentials keyauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_credentials oauth2_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_tokens oauth2_tokens_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: plugins plugins_api_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_api_id_fkey FOREIGN KEY (api_id) REFERENCES public.apis(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_route_id_fkey FOREIGN KEY (route_id, ws_id) REFERENCES public.routes(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: routes routes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id);


--
-- Name: routes routes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: services services_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_client_certificate_id_fkey FOREIGN KEY (client_certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: services services_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: snis snis_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_certificate_id_fkey FOREIGN KEY (certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: snis snis_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: targets targets_upstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_upstream_id_fkey FOREIGN KEY (upstream_id, ws_id) REFERENCES public.upstreams(id, ws_id) ON DELETE CASCADE;


--
-- Name: targets targets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: upstreams upstreams_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_client_certificate_id_fkey FOREIGN KEY (client_certificate_id) REFERENCES public.certificates(id);


--
-- Name: upstreams upstreams_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kongpre
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- PostgreSQL database dump complete
--

