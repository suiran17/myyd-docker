--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2
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
-- Name: sync_tags(); Type: FUNCTION; Schema: public; Owner: kong
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


ALTER FUNCTION public.sync_tags() OWNER TO kong;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acls; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.acls OWNER TO kong;

--
-- Name: acme_storage; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.acme_storage (
    id uuid NOT NULL,
    key text,
    value text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.acme_storage OWNER TO kong;

--
-- Name: apis; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.apis OWNER TO kong;

--
-- Name: basicauth_credentials; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.basicauth_credentials OWNER TO kong;

--
-- Name: ca_certificates; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.ca_certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text NOT NULL,
    tags text[],
    cert_digest text NOT NULL
);


ALTER TABLE public.ca_certificates OWNER TO kong;

--
-- Name: certificates; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text,
    key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.certificates OWNER TO kong;

--
-- Name: cluster_events; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.cluster_events OWNER TO kong;

--
-- Name: consumers; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.consumers (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    username text,
    custom_id text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.consumers OWNER TO kong;

--
-- Name: hmacauth_credentials; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.hmacauth_credentials OWNER TO kong;

--
-- Name: jwt_secrets; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.jwt_secrets OWNER TO kong;

--
-- Name: keyauth_credentials; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.keyauth_credentials OWNER TO kong;

--
-- Name: locks; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.locks (
    key text NOT NULL,
    owner text,
    ttl timestamp with time zone
);


ALTER TABLE public.locks OWNER TO kong;

--
-- Name: oauth2_authorization_codes; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.oauth2_authorization_codes OWNER TO kong;

--
-- Name: oauth2_credentials; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.oauth2_credentials OWNER TO kong;

--
-- Name: oauth2_tokens; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.oauth2_tokens OWNER TO kong;

--
-- Name: plugins; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.plugins OWNER TO kong;

--
-- Name: ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.ratelimiting_metrics OWNER TO kong;

--
-- Name: response_ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.response_ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


ALTER TABLE public.response_ratelimiting_metrics OWNER TO kong;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.routes OWNER TO kong;

--
-- Name: schema_meta; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.schema_meta (
    key text NOT NULL,
    subsystem text NOT NULL,
    last_executed text,
    executed text[],
    pending text[]
);


ALTER TABLE public.schema_meta OWNER TO kong;

--
-- Name: services; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.services OWNER TO kong;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    session_id text,
    expires integer,
    data text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.sessions OWNER TO kong;

--
-- Name: snis; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.snis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text NOT NULL,
    certificate_id uuid,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.snis OWNER TO kong;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.tags (
    entity_id uuid NOT NULL,
    entity_name text,
    tags text[]
);


ALTER TABLE public.tags OWNER TO kong;

--
-- Name: targets; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.targets OWNER TO kong;

--
-- Name: ttls; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.ttls (
    primary_key_value text NOT NULL,
    primary_uuid_value uuid,
    table_name text NOT NULL,
    primary_key_name text NOT NULL,
    expire_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ttls OWNER TO kong;

--
-- Name: upstreams; Type: TABLE; Schema: public; Owner: kong
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


ALTER TABLE public.upstreams OWNER TO kong;

--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name text,
    comment text,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    meta jsonb,
    config jsonb
);


ALTER TABLE public.workspaces OWNER TO kong;

--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.acls (id, created_at, consumer_id, "group", cache_key, tags, ws_id) FROM stdin;
af40ae40-8598-4c4c-8b61-ab1a207a033f	2019-04-25 22:48:03+08	bd60db2a-877b-4c0a-a287-da3024fa2290	tester	acls:bd60db2a-877b-4c0a-a287-da3024fa2290:tester:::	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: acme_storage; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.acme_storage (id, key, value, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: apis; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.apis (id, created_at, name, upstream_url, preserve_host, retries, https_only, http_if_terminated, hosts, uris, methods, strip_uri, upstream_connect_timeout, upstream_send_timeout, upstream_read_timeout) FROM stdin;
\.


--
-- Data for Name: basicauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.basicauth_credentials (id, created_at, consumer_id, username, password, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: ca_certificates; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.ca_certificates (id, created_at, cert, tags, cert_digest) FROM stdin;
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.certificates (id, created_at, cert, key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: cluster_events; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.cluster_events (id, node_id, at, nbf, expire_at, channel, data) FROM stdin;
\.


--
-- Data for Name: consumers; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.consumers (id, created_at, username, custom_id, tags, ws_id) FROM stdin;
bd60db2a-877b-4c0a-a287-da3024fa2290	2019-04-25 22:41:33+08	lidq	lidq	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: hmacauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.hmacauth_credentials (id, created_at, consumer_id, username, secret, tags, ws_id) FROM stdin;
8575c676-683c-45aa-bef6-90573636aa2c	2020-04-29 00:18:26+08	bd60db2a-877b-4c0a-a287-da3024fa2290	lidq	xxxx	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: jwt_secrets; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.jwt_secrets (id, created_at, consumer_id, key, secret, algorithm, rsa_public_key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: keyauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.keyauth_credentials (id, created_at, consumer_id, key, tags, ttl, ws_id) FROM stdin;
a5970013-2828-4286-abe0-079a3eaba54f	2019-04-25 22:46:57+08	bd60db2a-877b-4c0a-a287-da3024fa2290	tester	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: locks; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.locks (key, owner, ttl) FROM stdin;
\.


--
-- Data for Name: oauth2_authorization_codes; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.oauth2_authorization_codes (id, created_at, credential_id, service_id, code, authenticated_userid, scope, ttl, challenge, challenge_method, ws_id) FROM stdin;
\.


--
-- Data for Name: oauth2_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.oauth2_credentials (id, created_at, name, consumer_id, client_id, client_secret, redirect_uris, tags, client_type, hash_secret, ws_id) FROM stdin;
\.


--
-- Data for Name: oauth2_tokens; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.oauth2_tokens (id, created_at, credential_id, service_id, access_token, refresh_token, token_type, expires_in, authenticated_userid, scope, ttl, ws_id) FROM stdin;
\.


--
-- Data for Name: plugins; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.plugins (id, created_at, name, consumer_id, service_id, route_id, api_id, config, enabled, cache_key, protocols, tags, ws_id) FROM stdin;
7eaaece6-55d8-406d-861b-c661d8716904	2019-07-12 18:52:01+08	cors	\N	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	\N	\N	{"headers": ["User-Agent", "Authorization", "Content-Length", "Content-Type", "Content-MD5", "Accept", "Accept-Version", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "X-Requested-With", "X-Token", "Lang", "Request-Id", "Date", "X-Auth-Token"], "max_age": 1, "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"], "origins": ["*"], "credentials": true, "exposed_headers": null, "preflight_continue": false}	f	plugins:cors::88dde9c8-8a9c-4e12-84ce-4348ee825bb5:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
8fea4b40-0cc8-402b-9ce0-9fc03fd4e4d9	2019-06-19 17:41:03+08	cors	\N	16ebe251-c8c8-482f-9d60-4775b64ad0cd	\N	\N	{"headers": ["User-Agent", "Authorization", "Content-Length", "Content-Type", "Content-MD5", "Accept", "Accept-Version", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "X-Requested-With", "X-Token", "Lang", "Request-Id", "Date", "X-Auth-Token"], "max_age": 1, "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"], "origins": ["*"], "credentials": true, "exposed_headers": null, "preflight_continue": false}	f	plugins:cors::16ebe251-c8c8-482f-9d60-4775b64ad0cd:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
ea42473e-aa05-4f4d-882a-40e065bf89fd	2019-08-16 13:49:00+08	request-size-limiting	\N	4da87494-91dd-48e3-ae5b-b2943397cf6c	\N	\N	{"allowed_payload_size": 128}	t	plugins:request-size-limiting::4da87494-91dd-48e3-ae5b-b2943397cf6c:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f55cd8f6-355f-42d8-a720-5f23fb49c8a0	2019-08-16 14:00:32+08	request-termination	\N	4da87494-91dd-48e3-ae5b-b2943397cf6c	\N	\N	{"body": null, "message": null, "status_code": 503, "content_type": null}	t	plugins:request-termination::4da87494-91dd-48e3-ae5b-b2943397cf6c:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
4516aaeb-2dfa-4904-9ac6-1d1f9212dfe8	2019-06-19 14:01:03+08	cors	\N	de2547a8-e779-4bd3-9146-72ec9d34dcfe	\N	\N	{"headers": ["User-Agent", "Authorization", "Content-Length", "Content-Type", "Content-MD5", "Accept", "Accept-Version", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "X-Requested-With", "X-Token", "Lang", "Request-Id", "Date", "X-Auth-Token"], "max_age": 3600, "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"], "origins": ["*"], "credentials": true, "exposed_headers": [], "preflight_continue": false}	f	plugins:cors::de2547a8-e779-4bd3-9146-72ec9d34dcfe:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
e99e2fa5-5c3a-4784-91fd-e2865f1889c2	2020-09-25 18:37:33+08	ydauth_sso	\N	\N	23d8463a-d9b6-4956-bc43-86e024c86acb	\N	{"not_login_message": "没有登录"}	t	plugins:ydauth_sso:23d8463a-d9b6-4956-bc43-86e024c86acb::::9b57a89e-2dcf-40ad-a478-782b7457c157	{grpc,grpcs,http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
ee3fc66c-de97-4196-bdc2-f31ae81d9f54	2020-03-28 12:26:38+08	ydauth_sso	\N	0cadc5bf-9092-4000-9301-23bd6979e6f0	\N	\N	{"redis_host": "172.16.100.112", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "没有登录"}	f	plugins:ydauth_sso::0cadc5bf-9092-4000-9301-23bd6979e6f0:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
addc8d5e-cdbf-4f0d-9721-446d6ff4715b	2019-08-16 18:31:15+08	admin-login-yd	\N	4da87494-91dd-48e3-ae5b-b2943397cf6c	\N	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "PHPSESSID", "redis_timeout": 2000, "redis_database": 0, "redis_password": null, "session_prefix": "PHPREDIS_SESSION:", "not_login_message": "没有登录", "serialize_handler": "php_serialize"}	f	plugins:admin-login-yd::4da87494-91dd-48e3-ae5b-b2943397cf6c:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
8842b004-83cf-4a4c-84aa-3c6b27f59eef	2020-04-02 09:58:27+08	ydauth_sso	\N	\N	b7fe88f0-0e58-42a8-b9c2-2923a39c4768	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "没有登录"}	t	plugins:ydauth_sso:b7fe88f0-0e58-42a8-b9c2-2923a39c4768::::9b57a89e-2dcf-40ad-a478-782b7457c157	{grpc,grpcs,http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0e9f303e-221e-4ea8-b028-13f438d37d02	2020-03-28 15:13:47+08	ydauth_sso	\N	\N	c4259ddc-33b4-4b92-889f-fcace9d1787b	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "没有登录"}	t	plugins:ydauth_sso:c4259ddc-33b4-4b92-889f-fcace9d1787b::::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
2ba30216-235a-401d-9f7b-2d336a4c8257	2020-03-31 16:15:56+08	ydauth_sso	\N	\N	94e7e730-719f-4575-a696-ca5495047428	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "not login"}	t	plugins:ydauth_sso:94e7e730-719f-4575-a696-ca5495047428::::9b57a89e-2dcf-40ad-a478-782b7457c157	{grpc,grpcs,http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
01cefdd7-c1cc-4ce9-b6c0-8530e84e8f0b	2020-03-29 11:04:43+08	ydauth_sso	\N	\N	e4b99411-f68c-4880-b34d-9835e851efb9	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "没有登录"}	t	plugins:ydauth_sso:e4b99411-f68c-4880-b34d-9835e851efb9::::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
7f0aeb18-80cd-462b-91cf-0a5d4364d2a0	2020-04-09 09:31:48+08	ydauth_sso	\N	\N	574193ae-8341-4e93-a6f8-6e721429517c	\N	{"redis_host": "172.16.100.112", "redis_port": 6379, "session_name": "sso_token_yundunv5", "redis_timeout": 2000, "redis_password": "Gmck7X02", "not_login_message": "没有登录"}	t	plugins:ydauth_sso:574193ae-8341-4e93-a6f8-6e721429517c::::9b57a89e-2dcf-40ad-a478-782b7457c157	{grpc,grpcs,http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
d71dfa0e-df3f-4d27-81b7-a582a3da5307	2019-08-17 10:47:16+08	admin-login-yd	\N	de2547a8-e779-4bd3-9146-72ec9d34dcfe	\N	\N	{"redis_host": "172.16.100.106", "redis_port": 6379, "session_name": "PHPSESSID", "redis_timeout": 2000, "redis_database": 6, "redis_password": "Gmck7X02", "session_prefix": "PHPREDIS_SESSION:", "not_login_message": "没有登录啊", "serialize_handler": "php_serialize"}	f	plugins:admin-login-yd::de2547a8-e779-4bd3-9146-72ec9d34dcfe:::9b57a89e-2dcf-40ad-a478-782b7457c157	{http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
5ec599f6-9990-4091-a883-6b76a32b499d	2021-04-02 20:02:12+08	cors	\N	0cadc5bf-9092-4000-9301-23bd6979e6f0	\N	\N	{"headers": ["User-Agent", "Authorization", "Content-Length", "Content-Type", "Content-MD5", "Accept", "Accept-Version", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "X-Requested-With", "X-Token", "Lang", "Request-Id", "Date", "X-Auth-Token"], "max_age": null, "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"], "origins": null, "credentials": true, "exposed_headers": null, "preflight_continue": false}	f	plugins:cors::0cadc5bf-9092-4000-9301-23bd6979e6f0:::9b57a89e-2dcf-40ad-a478-782b7457c157	{grpc,grpcs,http,https}	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value, ttl) FROM stdin;
\.


--
-- Data for Name: response_ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.response_ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value) FROM stdin;
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.routes (id, created_at, updated_at, service_id, protocols, methods, hosts, paths, regex_priority, strip_path, preserve_host, name, snis, sources, destinations, tags, https_redirect_status_code, headers, path_handling, ws_id) FROM stdin;
a38e6da6-c7c1-451f-a210-e4badc3ced72	2019-11-22 09:45:13+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dingzhi.zhengan.domain.ban_ip}	5	f	f	apiv4_PostDingzhiZhenganDomainBan_ip	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
39188bf8-fbfb-4c15-87a7-93c59a1896e9	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.waf.web.cc.overview}	5	f	f	apiv4_Get_postStatisticWafWebCcOverview	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
886852e4-607a-45a8-af52-06719d1ad332	2019-10-23 11:50:32+08	2020-04-10 10:51:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.province.visit.top}	5	f	f	apiv4_Get_postStatisticTjkdAppProvinceVisitTop	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69bbaf37-69bd-478c-baae-3ae6a671f706	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.line}	5	f	f	apiv4_Get_postStatisticTjkdPlusDdosLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5b09a292-882d-4b23-a049-394f68eda45c	2019-06-21 11:41:42+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/serverIps}	5	f	f	dispatchapi_GetServerIps	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ded6d0a-0da0-45a6-9a97-2be1aeed7e2d	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/finance.coupon.list}	5	f	f	apiv4_Get_postFinanceCouponList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f2b2d903-9016-4c1b-ba4b-820b58df4096	2019-06-27 16:47:03+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.AddGroupRelation}	5	f	f	apiv4_addGroupRelation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e03333c0-99ef-49aa-a954-790c0e24fbf7	2019-10-30 10:59:31+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Web.ca.batch.operat}	5	f	f	apiv4_batchOperatSsl	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ecb2f20e-04ed-4f7d-a7bd-75a1a1f7cb29	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.all.app.flow.forward.line}	5	f	f	apiv4_Get_postStatisticTjkdAllAppFlowForwardLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f8369e5-1470-4d8b-b566-a8808874889b	2019-10-23 11:50:32+08	2020-04-10 10:51:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.country.visit.top}	5	f	f	apiv4_Get_postStatisticTjkdAppCountryVisitTop	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a3d31f7f-e8da-4e0f-89fa-4b73ab756c2f	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache.rules"}	5	f	f	apiv4_get_cdn_advance_cache_rule_list	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
adcad3e6-5378-492f-8f0b-9876ca051b0c	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.pause}	5	f	f	apiv4_CloudMonitor_monitorTaskPause	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2a8ef125-0933-4047-b50a-dc7a82bdc618	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/smgc.property.verify}	5	f	f	apiv4_ScanObserveProperty_verifyProperty	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
602d0d5a-6373-4d76-8ef1-1dc114cc4b7d	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.delay.avg.availability}	5	f	f	apiv4_Get_postStatisticMonitorTaskDelayAvgAvailability	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
97e72e0a-74ff-4e10-80f5-297a6214403a	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.package.port.list}	5	f	f	apiv4_GetTjkdAppPackagePortList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6f8c22f1-60c1-41cd-99e9-f4e666135d7e	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_auto_dynamic_static_separation"}	5	f	f	apiv4_WebCdnDomainSetting_put_page_auto_dynamic_static_separation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
367b0666-dbb2-4b2d-b610-b05cfca0b0a6	2019-06-27 16:47:07+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Traffic.bindwidth}	5	f	f	apiv4_getBindWidthStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8e73b4ac-4f5d-4734-b0ed-186f7dfa56eb	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.availability}	5	f	f	apiv4_Get_postStatisticMonitorTaskAvailability	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f945930e-541e-4773-8a37-6c0b78f60962	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_404"}	5	f	f	apiv4_WebCdnDomainSetting_get_diy_404	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3db8e552-9567-4145-a7ee-ce8e02576162	2019-06-27 16:46:57+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.cloudmonitor.monitor.resume}	5	f	f	apiv4_CloudMonitor_monitorResume	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
482d36a9-6010-4581-92c9-9261e8d8159b	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.package.list.all}	5	f	f	apiv4_GetTjkdAppPackageListAll	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9fc479c6-9200-4352-95d9-bfeaf544653b	2019-06-27 16:46:31+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.linkage.log}	5	f	f	apiv4_CloudMonitor_MonitorStats_linkageLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
afae8fdf-df4d-4b14-8591-b8d3f1d20639	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.template.get}	5	f	f	apiv4_getDsTemplateList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
862e129d-54a6-4949-aa55-1d36f8a1089f	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.template.rule.get}	5	f	f	apiv4_getDsTemplateRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
920fa795-faf5-4bdd-bb31-009bc5945bc7	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.product.get}	5	f	f	apiv4_getDsTemplateProduct	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c6eeea26-d833-407f-85b0-9e750773dc67	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_404"}	5	f	f	apiv4_WebCdnDomainSetting_put_diy_404	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6fea94f0-aaa5-45e8-8e32-b82d7b6e32cf	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.package.change.protect.node}	5	f	f	apiv4_Get_postTjkdPlusPackageChangeProtectNode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9026ef86-1169-4acd-8fc7-f644f822742a	2019-06-27 16:46:56+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/common.cloudmonitor.task}	5	f	f	apiv4_CloudMonitor_getAllTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dc014037-ff56-4d96-b618-05f41d49f782	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.exist.rule.get}	5	f	f	apiv4_getExistRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
30d14147-c1b9-49a2-9386-09d6eb6aed80	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.domain_redirect"}	5	f	f	apiv4_WebCdnDomainSetting_put_domain_redirect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f4b05593-3d6c-451e-8e3b-b2de4a739a13	2019-06-27 16:46:56+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.cloudmonitor.monitor.down}	5	f	f	apiv4_CloudMonitor_monitorDown	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4737288c-47b9-4b9a-b6b8-534b1466cb8f	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_502_or_504"}	5	f	f	apiv4_WebCdnDomainSetting_get_diy_page_502_or_504	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e94a274a-a502-47fa-821d-c006d300a7de	2019-06-27 16:47:03+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.addAlias}	5	f	f	apiv4_addDnsDomainAlias	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4f7744ab-1d1e-4d9e-833f-6f7a75f08502	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchPause}	5	f	f	apiv4_DnsDomainRecords_batchPauseRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
acd6aceb-7c2b-491a-ae32-7df73ce1e7cb	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/dispatch.template.del}	5	f	f	apiv4_delBatchTemplate	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69d9725d-8d7d-49db-be96-4372c02bf86a	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_edit_visit_limit_blacklist_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a86c0ba3-c652-478e-b59c-52ebb7ff4a25	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.package.ip.list}	5	f	f	apiv4_Get_postTjkdPlusPackageIpList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
13ea26a0-91c6-4697-ba20-295482a2d50e	2019-07-16 15:15:15+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.channel.source.batch.save}	5	f	f	apiv4_PostTjkdAppChannelSourceBatchSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6a59d6ca-3ff0-4df0-96bb-96ee7159e651	2019-07-09 11:48:37+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.add.subUser}	5	f	f	apiv4_permission_add_sbuser	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5d7e1f11-52ec-4259-a677-caf8bac88838	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/tjkd.app.domain.list}	5	f	f	apiv4_Get_postTjkdAppDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e6da971d-1960-495b-8bbd-d5387bb9636a	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.template.rule.list.get}	5	f	f	apiv4_getDsTemplateRuleList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ce679bf8-030d-49f4-8bb1-ba8494d915eb	2020-10-29 18:56:02+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/event/add}	5	f	f	service_disp_Event_add	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
63713a31-d94b-43d6-8370-cf0c1d696164	2020-10-29 18:56:02+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/event/list}	5	f	f	service_disp_Event_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f7eea087-de2b-4c65-86e8-72425a61eceb	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line_group/delete}	5	f	f	service_disp_LineGroup_delete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ccdd0b56-691a-40c2-aae5-7e6e32ad82ce	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.list}	5	f	f	apiv4_Get_postStatisticTjkdPlusDdosList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
98f23b69-8efd-4fa8-a87c-a298fd28da92	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.WebP"}	5	f	f	apiv4_WebCdnDomainSetting_put_WebP	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
15027737-e5dc-4517-a6ff-e65113914a2c	2019-11-11 18:02:04+08	2020-04-10 10:51:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.channel.ip.status.line}	5	f	f	apiv4_Get_postStatisticTjkdAppChannelIpStatusLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c94ad7bd-aae9-47ee-8729-46fa83e3c851	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Code.statDetail}	5	f	f	apiv4_getStatusCodeStatDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f38603e2-c602-4fd3-826d-317f181b01d2	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.WebP"}	5	f	f	apiv4_WebCdnDomainSetting_get_WebP	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a84cd075-2eca-44a7-af6f-c37229a3dc61	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_502_or_504"}	5	f	f	apiv4_WebCdnDomainSetting_put_diy_page_502_or_504	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3ac234b8-343d-46af-aba6-0f2d6312abb5	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/private.node.related.info}	5	f	f	apiv4_Get_postPrivateNodeRelatedInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
859d34c1-eda8-40b3-9f21-62f000e4ba6e	2019-06-27 16:47:07+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.reCheck}	5	f	f	apiv4_reCheck	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f1648051-3e87-432a-a97e-069aff271b9d	2019-10-29 11:07:42+08	2019-10-30 10:59:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.DomainId.Settings.getSettings}	5	f	f	apiv4_get_merge_settings	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
53be28d5-5073-40a6-be3f-bfd852779e25	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers.rules"}	5	f	f	apiv4_createSettingsRule_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
91c6e50e-6b45-400d-9966-7bfb976a71c8	2019-06-27 16:46:59+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DiyViews.add}	5	f	f	apiv4_addDiyView	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a5ab2c17-c3ad-4aba-96e0-d4361714b937	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.ajax_load"}	5	f	f	apiv4_WebCdnDomainSetting_get_ajax_load	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dbb00893-65bb-4b09-b996-a6d286da5b6c	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_get_page_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8e806871-9abf-4e9b-98d1-21e90e148934	2019-06-27 16:46:47+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/product.status.get}	5	f	f	apiv4_ProductStatus_getProductStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0d6acd6d-4a76-4c32-83fe-7f25a6296720	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.search_engine_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_get_search_engine_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a0af1a7d-c54c-4b61-9230-ae2f7b79c414	2019-06-27 16:46:59+08	2019-12-26 10:49:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.editPlanStatus}	5	f	f	apiv4_editPlanStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ae773d9b-9bdf-4892-b3c1-f2275751e465	2019-06-27 16:46:59+08	2019-12-26 10:49:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.getDetailInfo}	5	f	f	apiv4_getDetailInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
887a3f7a-e7d7-4980-906e-c77138a092a6	2019-06-27 16:46:47+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.new.domain}	5	f	f	apiv4_PostSendnoticeNewDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eedae31e-e570-4150-9e8f-9cb53c9290b8	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.whiteblackip.add}	5	f	f	apiv4_PostTjkdPlusForwardRuleWhiteblackipAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f182a6dc-68c2-48d2-aead-b3e9451041db	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.detailList}	5	f	f	apiv4_Get_postStatisticTjkdPlusDdosDetaillist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
39a13220-cde5-4ecc-9daf-9a9e4bd41b29	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.always_online"}	5	f	f	apiv4_WebCdnDomainSetting_get_always_online	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5f0f26f3-aef9-4eab-b2e8-1cdfde42a658	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.always_online"}	5	f	f	apiv4_WebCdnDomainSetting_put_always_online	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c5b88e77-a319-4f4b-98ba-a9177826aa6e	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTFingerPrint}	5	f	f	apiv4_getWafAPTFingerPrint	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8efaa9a9-5b3d-4275-a506-22ad8bdbdbd7	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.Web.op.log.list}	5	f	f	apiv4_Web_getTjkdWebOpLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
42b0afe8-58d1-42b1-a8f7-d6fac7d3cb1d	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.report.checkMemberReportPlanStatus}	5	f	f	apiv4_checkMemberReportPlanStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5517c44f-3174-46b5-9089-c1ce03291379	2019-06-27 16:46:59+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DiyViews.delete}	5	f	f	apiv4_deleteDiyView	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
683281bb-2940-469d-a88c-fc1fb5ecdc75	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache"}	5	f	f	apiv4_WebCdnDomainSetting_put_cdn_advance_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a53605af-751c-45ee-a81d-4d7c9d403abf	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.message.noticesetting.list}	5	f	f	apiv4_Get_postMessagecenterMessageNoticesettingList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
58232479-594d-4413-b927-469b9f576e39	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.member.list}	5	f	f	apiv4_invoice_getsMemberInvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4f44333b-fbfe-436d-9afe-507a54cd093f	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.forward.rule.packet.message.list}	5	f	f	apiv4_Get_postTjkdPlusForwardRulePacketMessageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eb953002-f2f4-4b88-9618-cd9bdfd539c2	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/messagecenter.noticesetting.detele}	5	f	f	apiv4_DeleteMessagecenterNoticesettingDetele	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a74436aa-0e78-4af4-bbfd-b7ff47b8ae5b	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/line_group/save}	5	f	f	service_disp_LineGroup_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b8090ba1-2faa-4ba3-ac2b-1fb496cd0ca0	2020-08-04 15:50:27+08	2021-01-01 21:36:30+08	1710d7c1-d63d-418c-a0cc-8dc6d475fc41	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns_check}	0	t	f	dns_check_uripre_agw_dns_check	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c3cb55cc-22ac-43a8-8103-c9e39f110786	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.package.overview}	5	f	f	apiv4_Get_postTjkdPlusPackageOverview	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e741f1a1-fb3c-4775-92e4-7483c3a1d9b5	2019-06-27 16:46:59+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.All.Domains}	5	f	f	apiv4_getAllDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
33f09184-c533-479b-a86d-71f954d1184f	2019-06-27 16:46:59+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc.rules"}	5	f	f	apiv4_addAntiCcRule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d9858a0-f038-4556-84b9-24e4efe69bd9	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.package.max_ddos_cc}	5	f	f	apiv4_Get_postStatisticTjkdPlusPackageMax_ddos_cc	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1459d67d-7631-497b-95e9-044008b1adec	2019-06-27 16:46:59+08	2019-12-26 10:49:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.getList}	5	f	f	apiv4_getHostScanPlanList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e4915d0-5d99-4ad6-bd13-b999bd3aa9f9	2019-06-27 16:46:59+08	2019-12-26 10:49:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.getDetailList}	5	f	f	apiv4_getDetailList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
05b48042-3af7-4b24-801a-b5ea00169daa	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/line_group/switch_status}	5	f	f	service_disp_LineGroup_switch_status	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1a7692d1-e0b4-4ccb-a7e4-3eaa0a82b57b	2020-08-04 15:50:27+08	2021-01-01 21:36:30+08	1710d7c1-d63d-418c-a0cc-8dc6d475fc41	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/dns_check}	0	t	f	dns_check_uripre_dns_check	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
208e5bec-4ba5-485a-9375-7114dc437971	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line_group/info}	5	f	f	service_disp_LineGroup_info	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bea003da-8149-4000-9ef5-38d12d5e579c	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line_group/list}	5	f	f	service_disp_LineGroup_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
72696043-6a44-4a3c-b6c8-9f87e09a0f96	2019-06-27 16:46:59+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache.rules"}	5	f	f	apiv4_add_cdn_advance_cache_rule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
714c159e-a782-4764-b4ba-f175caf8927a	2019-06-27 16:46:58+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.search_engine_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_put_search_engine_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cecce448-d1a1-49fe-997a-9f54f2032db2	2019-06-27 16:47:02+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers.rules"}	5	f	f	apiv4_listSettingsRule_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c8f96ae-30bb-4c64-8627-b0f09834df83	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket.rules"}	5	f	f	apiv4_add_websocket_rule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4a34ab59-8bc6-4411-95f0-2ed7d7a4e6fc	2019-06-27 16:47:06+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.YunDunDns}	5	f	f	apiv4_isYunDunDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
af18c4bd-6879-497e-be5f-9f8e7b238a2a	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/statistic.tai.cc.line}	5	f	f	apiv4_getCcLineStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
050f8e2d-f905-46cd-95fd-b7361fe9c730	2019-06-27 16:47:05+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.getWhoisEmail}	5	f	f	apiv4_getDomainWhoisEmail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
85712699-2a11-48b3-8d3e-a61325dc1842	2020-08-05 10:01:44+08	2021-01-01 21:36:30+08	1710d7c1-d63d-418c-a0cc-8dc6d475fc41	{http,https}	{GET,POST}	{}	{/domains/info_domains/map}	5	f	f	dns_check_DomainsInfoMap	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9850bf76-1295-4138-b5ba-504fd7c0ea33	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.info}	5	f	f	apiv4_DomainGroup_getGroupInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ba631a4-531f-44ca-9438-a2c79c0f692b	2019-06-27 16:47:06+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.makeTxtRecord}	5	f	f	apiv4_makeDomainRetrieveTxtRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
12742cf2-2bc3-42a4-8c37-c193f8d4930b	2019-06-27 16:47:02+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist.rules"}	5	f	f	apiv4_get_visit_limit_blacklist_rules_list	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2156547c-c1bc-44c0-85a5-95f706beeb9a	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.noticesetting.info}	5	f	f	apiv4_Get_postMessagecenterNoticesettingInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a1cdc84f-9a24-4a69-a1d9-2e3204fb924c	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/shield.risk.setting.status.save}	5	f	f	apiv4_PutShieldRiskSettingStatusSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
791d066f-4887-4189-a9e6-9699c82de6de	2019-06-27 16:47:05+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/CloudDns.Domain.tjkdDns.expiringDomains}	5	f	f	apiv4_getTjkdDnsExpiringDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e1eadde4-ec5d-4b98-9bbd-022e2548a10f	2019-06-27 16:46:59+08	2019-12-26 10:49:13+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.addDomainMap}	5	f	f	apiv4_addDomainMap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ad17f640-f070-4808-b007-cc6a0ba88748	2019-06-27 16:47:00+08	2019-12-26 10:49:14+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.deleteDomainMap}	5	f	f	apiv4_deleteDomainMap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f068c433-9a47-4cea-a8f7-fa85736b69c9	2019-06-27 16:47:00+08	2019-12-26 10:49:14+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.delete}	5	f	f	apiv4_deleteDomainGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1508cf41-469f-43b8-9141-18009f84b232	2019-06-27 16:47:01+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.slice"}	5	f	f	apiv4_filterPutDomainSettingData_domain_backsource_slice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b6bde8c-8b84-433a-b858-2ca17a40f7c6	2019-06-27 16:47:00+08	2019-12-26 10:49:15+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.edit}	5	f	f	apiv4_editDomainGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da02835a-71e7-4c17-9551-092da9fc57fc	2020-08-05 10:01:44+08	2021-01-01 21:36:30+08	1710d7c1-d63d-418c-a0cc-8dc6d475fc41	{http,https}	{GET,POST}	{}	{/domains/info_domains/list}	5	f	f	dns_check_DomainsInfoList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd5ba993-cf99-43b0-b65d-fcc32addb0bf	2020-03-07 00:16:30+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.cache.clean.list}	5	f	f	apiv4_GetWebDomainDashboardCacheCleanList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78dc59e5-5986-47fd-b3eb-e99f4d8a0142	2020-08-05 10:01:44+08	2021-01-01 21:36:30+08	1710d7c1-d63d-418c-a0cc-8dc6d475fc41	{http,https}	{GET,POST}	{}	{/domains/cname_domains/rabbitmq}	5	f	f	dns_check_DomainsCnameRabbitmq	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
18d7d8a6-5d62-4966-b2c9-c361fa9df92e	2019-06-27 16:47:01+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getMealList}	5	f	f	apiv4_getMemberMealList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b9da0573-2b5f-490e-8692-218aacaf49c8	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_detailSettingsRule_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ee683a4b-ee14-4ffb-8ce1-a4b101f39c8f	2019-06-27 16:47:02+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/finance.recharge.recharge}	5	f	f	apiv4_recharge	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b2ea849-a5d6-47a8-b988-4350d132aaa4	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.property.all.usable.list}	5	f	f	apiv4_ScanObserveProperty_getAllUsablePropertyList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
02b3d60c-c353-448f-8455-466b8af0da71	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_getAntiCcRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f3680c0-f5cc-41f4-9c77-a42375537044	2019-06-27 16:47:02+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.receive.scan}	5	f	f	apiv4_memberReceiveScan	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e99b857-7205-484d-a0d9-dcd3d7c55e37	2020-03-07 00:16:34+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidthhost.operate.record}	5	f	f	apiv4_updateHostStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62a28942-a6df-41f6-9865-99ba360b645b	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc.rules"}	5	f	f	apiv4_getAntiCcRuleList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80f0bdb0-c2ce-424e-a840-369501341263	2019-06-27 16:47:02+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/finance.recharge.rechargeList}	5	f	f	apiv4_rechargeList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f348b7d9-8a7c-4f9a-9b52-4fdde7f624a1	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.line}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
55e11492-f097-4be7-b98e-03e32317f2b1	2019-06-27 16:47:01+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers"}	5	f	f	apiv4_get_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
421fa34b-3ecd-48ae-a936-db83bcb905a3	2019-06-27 16:47:02+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.add}	5	f	f	apiv4_addDnsDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
00ae3c83-1750-41a2-840e-2a95050cb3d6	2019-06-27 16:47:01+08	2019-12-26 10:49:16+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DomainGroup.list}	5	f	f	apiv4_getListDomainGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
140af5f5-6bd7-4833-b189-9d2bdb4e6c15	2020-03-31 16:00:05+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns/admin}	0	t	f	service_dns_uripre_agw_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7b15741f-cfaf-49f3-ba26-a14c6851b418	2019-06-27 16:47:02+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.risk.callback.url}	5	f	f	apiv4_riskCallBackUrl	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6ca18272-176e-4366-95f7-b652a50d29f5	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.package.visit}	5	f	f	apiv4_Get_postStatisticTjkdPackageVisit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3bc9dc2d-42b0-48ef-a22a-069b03f1528e	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.noticesetting.save}	5	f	f	apiv4_PutMessagecenterNoticesettingSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e5b29289-aa95-4bea-8ddf-c1b07a46f945	2019-06-27 16:47:02+08	2019-12-26 10:49:18+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.addRecord}	5	f	f	apiv4_addRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7fe88f0-0e58-42a8-b9c2-2923a39c4768	2020-03-31 16:00:05+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/dns/console}	0	t	f	service_dns_uripre_agw_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
310397a0-e428-4be5-8198-da1b865d6d82	2019-06-27 16:47:02+08	2019-12-26 10:49:19+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.editRecord}	5	f	f	apiv4_editRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
af186f6c-f505-41d9-8fbc-64ed9adbdbe5	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.downpay}	5	f	f	apiv4_Order_DownPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d71570aa-1383-4e7e-80df-60307d2bd33f	2020-03-31 16:00:05+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/dns}	1	t	f	service_dns_uripre_agw	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ffa375c3-da9f-4e9e-9b2b-97c8545ad65e	2020-03-07 00:16:34+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidth.const.list}	5	f	f	apiv4_updateStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fe62ab21-fd95-441c-852a-5230114b963f	2020-08-10 16:54:11+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/api}	0	t	f	apiv4_uripre_agw_apiv4	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ff61d00-274c-4e23-94ec-c8c18cbe9861	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.ca.list}	5	f	f	apiv4_batch_caList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
147c4b50-888a-4aab-9380-2d5bba037071	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Web.Domain.batch.domain.info}	5	f	f	apiv4_batch_domainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d52af112-c673-42d1-9517-daa46f60a298	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.listen.port}	5	f	f	apiv4_batch_listenPort	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa1c522e-bf10-47cf-bd78-78f19bf18a25	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.log.detail}	5	f	f	apiv4_batch_logDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
392f1393-7963-4755-893b-2e4cefd08b8a	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_editAntiCcRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d79d9d9b-7fbb-4d81-b160-183106bbca94	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.Email.sendRetrieveVerifyCode}	5	f	f	apiv4_emailRetrieveVerifyCode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d5d24bc-adc6-4047-bb62-5ea6bedc7563	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.member.save}	5	f	f	apiv4_invoice_saveMemberInvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7f8ceabb-5f1d-40b8-8be2-4b7402b77c86	2019-06-27 16:47:01+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getPlanDetail}	5	f	f	apiv4_getMemberPlanDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8bd936d3-3f70-4b37-94b2-6fa999a398f9	2020-08-10 16:54:15+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.plan.suoronguplimt}	5	f	f	apiv4_Order_suorongUpperLimit	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6995ad6c-a2e6-4d49-868e-e6b4e214dafe	2019-06-27 16:47:03+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.AddGroup}	5	f	f	apiv4_addMemberGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0802b148-eb39-445b-b08f-8ccc6e88f15b	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,PUT,DELETE}	{}	{/V4/dispatch.template.rule.save}	5	f	f	apiv4_saveDsTemplateRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b1bb26c-c9b2-4688-9953-22c57f3e2344	2020-03-31 16:01:41+08	2020-04-06 21:05:50+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch/admin}	0	t	f	service_batch_uripre_agw_batch_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eaf20d8d-75d3-4d28-8198-6df13d966b79	2019-06-27 16:47:04+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.DelGroup}	5	f	f	apiv4_delMemberGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c58951c8-18cb-4e9c-8dda-aaeb9149bf9b	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.package.property.list}	5	f	f	apiv4_ScanObserveProperty_getPackagePropertyList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
06fef246-0e8d-469c-8b78-f65042914503	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.listenPort.add}	5	f	f	apiv4_addListenPortAndSource	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
61be5be5-7694-4c12-bc50-b9b53e20b1a3	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.mobile_jump"}	5	f	f	apiv4_WebCdnDomainSetting_put_mobile_jump	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7093520-81a8-4911-b87b-f4c94d7c32cf	2020-08-10 16:54:13+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.ddos.list}	5	f	f	apiv4_GetTjkdAppDdosList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cda61616-3e28-4c7c-9083-b7d0691ad61c	2020-08-10 16:54:15+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.suorong_price}	5	f	f	apiv4_Order_SuorongPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4e561e32-48a1-445e-b7a5-0d0eb7d05631	2019-11-22 09:45:18+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,PUT}	{}	{/V4/dispatch.template.save}	5	f	f	apiv4_saveDsTemplate	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
94e7e730-719f-4575-a696-ca5495047428	2020-03-31 16:01:41+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch/console}	0	t	f	service_batch_uripre_agw_batch_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c629bc4b-9f62-4a75-8460-308cb52c6287	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/pool/tag/bind}	5	f	f	service_disp_IpPoolBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
81c20d88-dc2a-4b37-bab9-5ebe2f9a83cc	2019-10-29 11:07:43+08	2019-10-30 10:59:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.DomainId.Settings.getRuleSettings}	5	f	f	apiv4_get_merge_rule_settings	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
539b6f9d-40be-439f-910d-123ab5df4deb	2020-10-29 18:56:03+08	2021-01-01 21:36:25+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/list}	5	f	f	service_disp_IpPoolList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2a8dca07-95e8-4302-8483-ee59b72de329	2020-10-29 18:56:03+08	2021-01-01 21:36:25+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/obtain}	5	f	f	service_disp_IpPoolObtain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d26f262a-3aa9-48b0-be71-b3ec7417684e	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Info}	5	f	f	apiv4_getDomainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64b8aeeb-c888-4bff-b2cf-9aa0c03e778a	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.check.cname.use.yundun}	5	f	f	apiv4_getAliasList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b5065f48-dfda-4ad7-b09a-731ccc66c0e1	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.All.Domain.Warn}	5	f	f	apiv4_getAllDomainForWarn	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dc0cda60-b532-4511-8c28-5a10f7a3832e	2020-03-12 14:44:03+08	2020-03-31 16:11:32+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog}	1	t	f	service_oplog_uripre_agw	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aab9f32a-2b14-448b-9807-2db921186119	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.browser_cache"}	5	f	f	apiv4_WebCdnDomainSetting_put_browser_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ddfda831-25e0-480f-8dca-7585b8bbe8ae	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.aliasList}	5	f	f	apiv4_getDnsDomainAliases	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
44e090a9-419b-422a-84c5-10e906bbe8fe	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.PackageInfo}	5	f	f	apiv4_getDnsDomainPackageInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
277deb6e-3658-4407-89a0-d7b4c16b80bb	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_mainid}	5	f	f	apiv4_Get_postFirewallPolicyGet_mainid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cb358e5e-97d2-48e8-9f99-92cf9a90d486	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.DnsStat}	5	f	f	apiv4_getDnsDomainStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e16be72f-fbcc-4db1-be05-b9a9a808ebab	2019-06-27 16:47:05+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getReportList}	5	f	f	apiv4_getMemberReportList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9515d782-0399-4f44-b43f-11e7037d2d5d	2020-03-07 00:16:34+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidthuser.operate.record}	5	f	f	apiv4_updateUserStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eb5e6c34-10c9-4e1e-941d-097532ee4f99	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.scan.task.list}	5	f	f	apiv4_Get_postShieldScanTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0f42024b-cbdb-44aa-9a46-affabd9bdbf5	2019-08-22 16:47:20+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_tjkdappid}	5	f	f	apiv4_Get_postFirewallPolicyGet_tjkdappid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f296c8e8-9a71-4e65-9598-d5a347c09b0e	2019-06-27 16:47:05+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.GroupList}	5	f	f	apiv4_getMemberGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4184f2de-e7a8-4f8c-8703-ae28f29d42f3	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.enable}	5	f	f	apiv4_monitorTaskEnable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ae4744b-ea92-4214-8452-9527b9df5740	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DomainRemark.info}	5	f	f	apiv4_getDomainRemarkInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
57404641-4c6f-4c50-8f19-45b7823c6a56	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.downprice}	5	f	f	apiv4_Order_DownPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
05d042d5-38b8-416e-b047-a307d657e1bf	2019-06-27 16:47:05+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Member.Email.list}	5	f	f	apiv4_getMemberEmail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
15aa1fe3-ce58-45d7-9ebb-6a270471be2d	2019-06-27 16:47:05+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/CloudDns.Member.Line.getMemberLines}	5	f	f	apiv4_getMemberLines	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
00a2245b-c3da-4373-a664-eabf36428672	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.request.save}	5	f	f	apiv4_invoice_saveRequest	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
adfbd3a6-bf3b-4306-b940-c97b280b1b50	2019-06-27 16:46:45+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.savebasicinfo}	5	f	f	apiv4_PostCustomerManageSavebasicinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
925f19d0-e8e0-4cea-9e34-10e488ac8689	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.kuorongorder}	5	f	f	apiv4_Order_KuorongOrder	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b6a1e931-3b12-4d50-ac21-ca7d59168dbc	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.kuorongprice}	5	f	f	apiv4_Order_KuorongPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ff4c0bea-0347-438f-bd26-07200bdee709	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.renewpay}	5	f	f	apiv4_Order_RenewPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d6aa303-b40f-4801-b4ac-9a5dca13b520	2019-06-27 16:47:07+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.verify.verifyFileCode}	5	f	f	apiv4_verifyFileCode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7757e550-817b-488e-a1ec-4f97a8f47c1e	2019-07-10 18:36:21+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.center.usableSmsNumber}	5	f	f	apiv4_Get_postMessagecenterCenterUsablesmsnumber	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c1ed0d61-452e-4e87-87e2-c91355141075	2019-06-27 16:47:07+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainRemark.save}	5	f	f	apiv4_saveRemark	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2dd4d53e-ea98-4e7c-b785-97e8b31f8b81	2019-06-27 16:47:07+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainTransfer.transfer}	5	f	f	apiv4_transfer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
18f969c0-1a92-42bd-a062-cb1b1a4580f8	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.Province.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcProvinceTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
672ef9c0-9d6b-40a0-851b-9f5b9e37cf1e	2019-06-27 16:47:08+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/stati.data.newget}	5	f	f	apiv4_getStaticsDataNew	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7de80d7f-96e9-4be2-a210-989024321cf3	2019-06-27 16:47:07+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainTransfer.transferConfirm}	5	f	f	apiv4_transferConfirm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b32f04f-4077-4bdb-b157-bbe79ecfdf69	2020-03-31 16:52:27+08	2020-03-31 16:52:27+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch}	2	t	f	service_batch_uripre_agw_batch	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
33fc3d89-aab3-464e-9901-baa68924573d	2019-07-25 15:28:17+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.aliyunvoice}	5	f	f	apiv4_PostSendnoticeAliyunvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
973c5834-82de-4bf6-8a5d-1891ca2c9b7d	2019-06-27 16:47:07+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.editReport}	5	f	f	apiv4_editMemberReport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c96c2c9e-24ba-4254-85fb-acadf3676731	2019-06-27 16:47:07+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.addReport}	5	f	f	apiv4_addMemberReport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8e9a9df8-ea20-4a9b-a51e-d3ede554ad28	2019-06-27 16:47:07+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.verify.verifyTXTRecords}	5	f	f	apiv4_verifyTXTRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0ec1f3d1-c326-48c9-ae63-4e1e623b9368	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_delAntiCcRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
91c18e67-0b17-44d2-ac60-297c678d8ea4	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.create_pay}	5	f	f	apiv4_order_createPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
79c37c16-7f10-4881-99d2-2c10f0e1118e	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.create_price}	5	f	f	apiv4_order_createPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
05ca7054-3ff9-4571-8766-720663516d6a	2020-08-10 16:54:14+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.renewprice}	5	f	f	apiv4_Order_RenewPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0a7eab77-8e33-41cf-9de4-a7231d9d98f6	2019-10-30 10:56:09+08	2019-10-30 10:59:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/web.domain.set.get}	5	f	f	apiv4_get_set	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bfb04dbb-d615-4e4f-8b57-118c48f17468	2019-06-27 16:47:07+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.retrieve}	5	f	f	apiv4_retrieveDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b08566c-d560-4fbd-aa62-b0146b454de3	2019-11-26 16:25:13+08	2020-01-14 16:34:41+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dingzhi.baishan_atd.domain.deny_ip}	5	f	f	apiv4_PostDingzhiBaishan_atdDomainDeny_ip	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1b789ce4-dfc2-4e43-8ef2-b0db5b5aa9f4	2020-08-10 16:54:15+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.uppay}	5	f	f	apiv4_Order_UpPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
934fe162-d09b-4de5-825f-b11a17f0f2cf	2020-08-10 16:54:15+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.upprice}	5	f	f	apiv4_Order_UpPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dc3a4ff6-9e85-4caa-8825-d1e3d0aedcb5	2020-08-10 16:54:15+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.suorong_pay}	5	f	f	apiv4_Order_SuorongPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
188e8261-7983-4924-9637-2f7f48822c75	2020-10-29 18:56:03+08	2021-01-01 21:36:25+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/pool/tag/unbind}	5	f	f	service_disp_IpPoolUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d7cbaa8-a327-4557-825e-08688bf31462	2020-03-07 00:19:16+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/member.product.plan}	5	f	f	apiv4_GetMemberProductPlan	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e5ab277-ed71-426a-9327-41e819f2d8bf	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_packageid}	5	f	f	apiv4_Get_postFirewallPolicyGet_packageid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
767efe60-fded-4248-80b2-22ac89bc9f9e	2020-04-06 20:55:28+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/tag/console}	0	t	f	service_tag_uripre_agw_tag_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cba0bb69-730d-42fa-bf04-c67c7291a65d	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.cycle.scan.save}	5	f	f	apiv4_PostShieldCycleScanSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c663d4a-93be-415b-8f75-4636e6335737	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cancel}	5	f	f	apiv4_order_cancel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b7cd3df-5446-440a-97a6-c16bfd1304a7	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_get_cdn_advance_cache_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c66a39ea-9b4b-4388-9823-ad6c436ecea1	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.rule.del}	5	f	f	apiv4_ZeroTrustAppRule_delAppRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
418c7c41-cb37-4111-92ef-0c3af10655af	2020-04-06 20:55:28+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/tag/admin}	0	t	f	service_tag_uripre_agw_tag_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d99c7413-07bb-4f62-9ee3-5150f0a035ea	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackIpTopCountry}	5	f	f	apiv4_getWafAttackIpTopCountry	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c20d634-6fc4-482f-bdfc-9101ef800071	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.rule.save}	5	f	f	apiv4_ZeroTrustAppRule_saveAppRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
66acdc42-3b44-43b6-a55e-457a9655db51	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.rule.add}	5	f	f	apiv4_ZeroTrustAppRule_addAppRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4e86bfe2-2f11-4db2-b891-054478e1485b	2019-06-27 16:46:48+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/remit.gets_memberid}	5	f	f	apiv4_Get_postRemitGets_memberid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
84303426-66f0-4144-8ae8-b97ac4284f89	2019-11-26 16:25:12+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.loss}	5	f	f	apiv4_PostCustomerManageLoss	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b85b9f07-b890-445c-b55c-fae525a34968	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Request.country}	5	f	f	apiv4_getTopCountry	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
df590319-a970-41a6-b051-66d75885a94e	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.waf_block_diy_page"}	5	f	f	apiv4_WebCdnDomainSetting_put_waf_block_diy_page	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5c73fdec-67a1-4898-bd52-6c98cf19fb8c	2019-07-10 18:56:24+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.notice.verify}	5	f	f	apiv4_PutMessagecenterNoticeVerify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b2a542fe-8098-47ac-b230-8477b3c98f6a	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.binddomain}	5	f	f	apiv4_order_bindDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f41efb66-a433-4f4d-a52c-32059fddcd3f	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Code.stat}	5	f	f	apiv4_getStatusCodeStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0261ef7c-897f-4235-b5c0-8774f16346ec	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.coupon.unuse}	5	f	f	apiv4_order_couponsUnUse	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f7be5b5b-539a-4b49-b2d2-fdcacc60bffd	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.create}	5	f	f	apiv4_order_create	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b41b9d6-0201-4ba6-bfa1-25f2702f69db	2019-10-30 10:56:10+08	2019-10-30 10:59:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/web.domain.set.get.rule}	5	f	f	apiv4_get_set_rule	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ba8e6441-6a99-4492-aa37-0a704a1c2434	2020-03-12 18:04:34+08	2020-07-16 15:12:16+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/api}	0	t	f	apiv4_uripre_agw	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f1f1608-01ba-4dc5-b631-afdd3e72cab6	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.rule.sort}	5	f	f	apiv4_ZeroTrustAppRule_sortAppRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2dbac621-27f2-4190-ab31-85abdeaa2f89	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.renew_price}	5	f	f	apiv4_order_renewPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7c95a52e-4604-4e52-9ee6-4bc34e896b6c	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/asset/admin}	0	t	f	service_asset_uripre_agw_asset_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dfff7eba-3c46-4d0a-96ba-e48b247997fa	2020-03-09 15:57:24+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/member.plan.actions}	5	f	f	apiv4_GetMemberPlanActions	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ab2c914e-09ae-44a0-8a21-00f2d4c9ccad	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.package.info}	5	f	f	apiv4_getHwwsPackageInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
729762c4-9a19-4cbc-bae8-40ddf5403e9f	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payback.save}	5	f	f	apiv4_order_paybackSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
448be9e6-1822-4f9e-8480-500a7b451abe	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.zengzhi}	5	f	f	apiv4_order_zengzhi	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
af61b990-65bf-44a1-b7e6-42b3ee2a686a	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.zengzhi_price}	5	f	f	apiv4_order_zengzhiPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ea76f58-a230-41e7-aa1e-eb47ab70b059	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.save_edit}	5	f	f	apiv4_order_saveEdit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b827a880-6e00-41f5-9c93-1a797710fb7d	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.notice.updatenoticememberstatus}	5	f	f	apiv4_PutMessagecenterNoticeUpdatenoticememberstatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c213966-0bf9-4b8c-ac6b-0c979b884fe3	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/messagecenter.message.noticesetting.save}	5	f	f	apiv4_PostMessagecenterMessageNoticesettingSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d0612459-d70f-4595-9f88-2af9467e7c10	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/shield.cycle.scan.cancel}	5	f	f	apiv4_PutShieldCycleScanCancel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9502224c-8f90-4e99-874a-966257b2e331	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/order.plan.list}	5	f	f	apiv4_order_planOrders	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
148e9865-fb99-4abb-8e03-5c03bc6c54ce	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.edit_price}	5	f	f	apiv4_order_editPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e3bf1984-2a97-4577-b344-4ba7ecd0a4f5	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.renew}	5	f	f	apiv4_order_renew	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b3a4607f-7031-43e4-961f-c3ff030eb000	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.up}	5	f	f	apiv4_order_up	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b3e6b05c-e55c-49a2-999e-f639e16dad2a	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot"}	5	f	f	apiv4_WebCdnDomainSetting_put_web_honeypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ab0d1320-4454-4687-b9b8-c874df8c2dd3	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payback.list_order}	5	f	f	apiv4_order_paybackList_order	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9a17f3f3-48dd-4b69-bb2b-71f1e4c9506d	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.renew_pay}	5	f	f	apiv4_order_renewPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e446131-4858-46fd-ae2d-d7f89e9328e8	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.up_pay}	5	f	f	apiv4_order_upPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
95bddf8a-c984-4588-bf75-345b1dc0c03a	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/asset}	0	t	f	service_asset_uripre_asset	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b97a4e20-8b37-43be-b062-95a3020bd5dd	2019-06-27 16:47:11+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.getWebShell}	5	f	f	apiv4_GetWebDomainDashboardGetwebshell	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1d286099-e757-4953-9ca3-eca40c74a990	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.refund.confirm}	5	f	f	apiv4_invoice_refundConfirm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d166bf04-1c1e-47e1-8127-e1208fadf7ee	2019-06-27 16:47:02+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/finance.recharge.getMemberBalance}	5	f	f	apiv4_getMemberBalance	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
72223b4b-7c4e-4d80-9c9a-a358ac7c75c6	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.batch.info}	5	f	f	apiv4_PostTjkdPlusForwardRuleBatchInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
485b19d3-4d9b-4a66-a335-ba92a37e8302	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.audit}	5	f	f	apiv4_invoice_audit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0f8ab593-57aa-4769-ac46-1e8f4f8c9f57	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.get}	5	f	f	apiv4_invoice_getInvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1bb0b516-4400-4cad-9870-db5ec05c59d9	2019-06-27 16:47:12+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.cloudmonitor.task}	5	f	f	apiv4_CloudMonitor_NewCloudMonitorCallBack	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cb3b8034-4e50-4967-951b-a4f02bb2714b	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.count.list}	5	f	f	apiv4_Get_postShieldPropertyCountList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d1dec174-29d9-48e2-b5ae-63b95b682f2c	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.refund.request}	5	f	f	apiv4_invoice_refundRequest	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d6db761-02ec-4c4b-b5fc-5e91ff2ce8e7	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/region/get}	5	f	f	service_asset_GetRegion	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cb5fb003-bdc6-4bda-ad5c-46f32c34b8ad	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.list}	5	f	f	apiv4_invoice_getsInvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3deaa3f7-ae5b-4155-9846-cf1ba67beb69	2019-06-27 16:47:12+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/overview.guide.memberDisplayProduct}	5	f	f	apiv4_addDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
74d7e1a0-e0f8-4ee1-9487-72c06b41236f	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.domain.batch.info}	5	f	f	apiv4_GetTjkdAppDomainBatchInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4fbe2d91-70f6-450c-9a3d-e8d91d116dcc	2019-06-27 16:47:12+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/plan.get.meal_flag}	5	f	f	apiv4_getPlanForMealFlag	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
307477f1-41b2-4699-8269-20871e944e2b	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.list.doing}	5	f	f	apiv4_invoice_getsInvoiceDoing	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d8bd9227-e30a-44b0-8326-65f7afc3f312	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.revoke}	5	f	f	apiv4_invoice_revoke	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
850249c8-acba-4a64-a82d-aa360a1cb3ef	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.list.done}	5	f	f	apiv4_invoice_getsInvoiceDone	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
935f22b3-8f97-42b5-ad97-255a5abeb2d4	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.request}	5	f	f	apiv4_invoice_saveOrderInvoice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62125ad5-fa15-4663-9546-cbdb0eacd3ab	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.end}	5	f	f	apiv4_order_end	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9474e130-eca2-4a94-a124-311690a75df4	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.delete}	5	f	f	apiv4_PostClouddnsDomainDomaingroupDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
72c0f629-1d6e-426e-a517-cecc2dcae3d2	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.info}	5	f	f	apiv4_Get_postShieldPropertyInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2aa8e0c6-4430-46c0-89c1-ff6186cb74a2	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.down_price}	5	f	f	apiv4_order_downPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b1bc588d-bf89-431b-8d11-c0a67c04255e	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.alertSetting.info}	5	f	f	apiv4_CloudMonitor_alertSettingInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c751ebe9-0865-4584-ab9a-cc3ad2426ac3	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.end_price}	5	f	f	apiv4_order_endPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a740c57e-ed37-4c01-a3bf-da8be823be99	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.addDomainMap}	5	f	f	apiv4_PostClouddnsDomainDomaingroupAdddomainmap	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cceb90cd-556b-4296-9547-3a19b847bd35	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.replaceMirror.orderInfo}	5	f	f	apiv4_PostBuyReplacemirrorOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
00481578-215c-4783-b21f-558332be5d59	2019-08-05 14:29:14+08	2019-08-05 14:33:38+08	4da87494-91dd-48e3-ae5b-b2943397cf6c	{http,https}	{}	{example.com}	{/a}	0	t	f	\N	\N	\N	\N	\N	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
60d64212-62a5-4c7f-b134-50ef536b9130	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DomainGroup.list}	5	f	f	apiv4_GetClouddnsDomainDomaingroupList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eafd749b-3813-485d-bb13-a6bad91b2d7f	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.domain.list}	5	f	f	apiv4_CloudDns_DomainGroup_getGroupDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ffca55f-c4eb-4d3c-8463-b61005284651	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.monitor.events}	5	f	f	apiv4_ddos_monitorEvents	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d241191-d5b7-40ef-866e-95f8bb18975f	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.all.list}	5	f	f	apiv4_DomainGroup_getAllGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2429cbc7-aaab-417a-bc37-5772d0857d25	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	service_asset_GetServerInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3f1034ba-dc62-4c43-abf8-335ea5f97b6c	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.del}	5	f	f	apiv4_CloudDns_DomainGroup_delGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
24bdba7a-4c33-47ed-a3d2-0a2f2dc98886	2019-06-27 16:46:46+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/private.node.related.batch.add}	5	f	f	apiv4_PostPrivateNodeRelatedBatchAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8bc53dbd-5bd4-4c9e-b4be-c54b165d9891	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.deleteDomainMap}	5	f	f	apiv4_PostClouddnsDomainDomaingroupDeletedomainmap	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
89c7799b-a310-4237-a8c5-78e5f2b6fac3	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.oplog}	5	f	f	apiv4_Get_postFirewallOplog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e76770d-810a-428d-bce2-fcbf0fb7594c	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.info}	5	f	f	apiv4_CloudDns_DomainGroup_getGroupInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
be988e0e-46ab-4c61-bb60-e6884ed63305	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.dns.domain.group.all.list}	5	f	f	apiv4_CloudDns_DomainGroup_getAllGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
04d3a114-82bb-49ef-b674-f1eb6c056636	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.add}	5	f	f	apiv4_PostClouddnsDomainDomaingroupAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f84675cb-7d8f-49c4-878d-9e4e23a2dd3a	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_ids"}	5	f	f	apiv4_WebCdnDomainSetting_put_cloud_ids	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d373ad4-d5ff-42fd-822a-6cdd1c1fe8d3	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Visit.uv}	5	f	f	apiv4_getUvStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8b999772-62a9-4c3a-a5eb-a7ff44407b4e	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/del}	5	f	f	service_asset_DelServer	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5a28742c-aea3-482f-bdfd-ffde3e1dea5b	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.block.risk.connect.line}	5	f	f	apiv4_Get_postStatisticTjkdAppBlockRiskConnectLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ef2f03d-688b-43a0-9bcd-25df954d2617	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.domain.save}	5	f	f	apiv4_CloudDns_DomainGroup_saveDomainToGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f641eb78-befd-4b2f-a378-85dd6000274a	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.save}	5	f	f	apiv4_CloudDns_DomainGroup_saveGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
963eca9c-a776-4616-aa7c-c5fb99771dfa	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.up_price}	5	f	f	apiv4_order_upPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69f7013c-8bf7-4a19-b270-feab116d63c6	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.ca.self.(?<id>\\\\d+)"}	5	f	f	apiv4_getCaDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
feaef837-7fdf-46c9-84d5-239653e7d84a	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/del}	5	f	f	service_asset_DelServerIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6dd41e55-f89a-4983-83e2-d0ff5ecef3e6	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.down_pay}	5	f	f	apiv4_order_downPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
130f2585-1b27-4321-b624-c6bfa673400e	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.delete}	5	f	f	apiv4_DnsHijackTask_taskDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7cc1bff8-1ec3-4e04-a0ad-36586378ef0d	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.property.add}	5	f	f	apiv4_PostShieldPropertyAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
216b1f81-0983-42bb-a3ab-70839dfa44d7	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloud.dns.domain.group.list}	5	f	f	apiv4_CloudDns_DomainGroup_getGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0065e823-5483-4bae-a68e-2910a10559df	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/add}	5	f	f	service_asset_AddServerIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
19483a10-e7c4-4000-a1f0-d1512ec3988b	2019-06-27 16:47:11+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Request.overview}	5	f	f	apiv4_overViewRequest	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8ee07953-c422-48ae-b6f9-63aae42aa91c	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.log_order}	5	f	f	apiv4_order_getsLog_order	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e983a63f-d3ef-4888-aa81-e1c09488bde5	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.waf.web.cc.line}	5	f	f	apiv4_Get_postStatisticWafWebCcLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8533b167-a76f-442d-b758-546e4b9e3060	2019-06-27 16:47:11+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.DashBoard.addWebShell}	5	f	f	apiv4_PutWebDomainDashboardAddwebshell	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
478970c2-6a9c-4f95-85f3-002ada3a2675	2019-12-11 15:55:10+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.abnormal.template.rule.get}	5	f	f	apiv4_getDsAbnormalTemplateRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6912e187-b4f2-44fb-93e5-5bae6599e8a3	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.add}	5	f	f	apiv4_DnsHijackTask_taskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7cc009b5-2f56-4b48-b025-82e7576f9f47	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.info}	5	f	f	apiv4_DnsHijackTask_getTaskInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b245ff65-675b-49c3-aea8-cce6e4670845	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/dns.hijack.event.log.province.top}	5	f	f	apiv4_DnsHijack_getDnsHijackProvinceTopStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1086acae-0933-4cdb-92dc-433c749eb680	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.DashBoard.save.preheat.cache}	5	f	f	apiv4_WebCdnPreheatCache_savePreheatCache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cdac2fc2-c134-45a8-aba9-3d3d9a2fe0dd	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.strategy}	5	f	f	apiv4_GetPermissionGetStrategy	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
acaa9bb4-4593-4033-ad2d-ed883090e963	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.save}	5	f	f	apiv4_Get_postCrontabSystemSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9528a1da-b67f-41cf-810e-b410636e4941	2019-11-05 11:49:39+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/web.domain.set.del.rule}	5	f	f	apiv4_web_cdn_del_rule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2249ddb9-c055-4e2b-a2b6-115994a71c1c	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/serverIps}	5	f	f	service_asset_GetServerIps	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
050227f7-ef77-485e-a260-7fe3e0ead77b	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/list}	5	f	f	service_asset_GetServerIpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ed2558c-2fa1-492b-8eb3-02427d12c957	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.save}	5	f	f	apiv4_DnsHijackTask_taskSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bfb37172-38fa-40ae-8aea-f8916662164c	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/order.list}	5	f	f	apiv4_order_lists	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1206bbcb-91aa-404d-9d4c-12ae492d630c	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/dns.hijack.task.domains}	5	f	f	apiv4_DnsHijack_getAllTaskDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d5ab8e8c-c1a0-4994-98a4-5038828de578	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/smgc.package.change.name}	5	f	f	apiv4_ScanObservePackage_changePackageName	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d2b0e1de-fdc5-4fb6-a38b-c8f13863229f	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_getCloudWafRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
16634c41-0cf8-41ee-8700-230e0b918ff4	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,DELETE}	{}	{/V4/smgc.package.unbind.property}	5	f	f	apiv4_ScanObservePackage_unbindPropertyFromPackage	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d3421a7-f477-4a3c-bc28-352c7864162d	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.property.info}	5	f	f	apiv4_ScanObserveProperty_getPropertyInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c7206dec-7990-4704-98ef-c4370b9d1004	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/order.member.list}	5	f	f	apiv4_order_memberOrders	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
415c81d9-1ff9-4d50-ba1b-811129707633	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.kuorong}	5	f	f	apiv4_order_kuorong	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
028b42af-efd6-40f7-a45c-127a7bdd5943	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.ca.apply.list}	5	f	f	apiv4_listApplyCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eed03fc9-34a6-42cd-b15e-a8aa476834cd	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.flaw}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcFlaw	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c0c026c1-6c90-4a5a-8557-f8b5a0e7ad40	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.replaceMirror.products}	5	f	f	apiv4_Get_postBuyReplacemirrorProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
21605554-a52a-4326-9f34-05abcd57cde6	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/order.pay}	5	f	f	apiv4_order_pay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5edd8368-3915-4d2d-adf2-2c9c9a4f3e55	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.scan.task.again}	5	f	f	apiv4_PostShieldScanTaskAgain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9dcf669c-e3fa-4ad8-bdf7-24e0cd34bedc	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.kuorong_pay}	5	f	f	apiv4_order_kuorongPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
baf60502-b8b0-4983-82e9-f97126d8f1e7	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.kuorong_price}	5	f	f	apiv4_order_kuorongPrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
db397b07-3bb2-418a-a0d4-eb49563e2de5	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	service_asset_GetServerIpInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
06554b79-433f-427c-aca8-713372946201	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/update}	5	f	f	service_asset_UpdateServerIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a64a9301-ba45-483e-807c-43b4b90047d5	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cdntpl.apply}	5	f	f	apiv4_cdntplApply	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c9c67321-5322-4299-8ea2-a0b99fc6dd17	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.enable}	5	f	f	apiv4_DnsHijackTask_taskEnable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80c665c3-31cd-4c57-b27f-c0fd89129fd3	2019-11-08 12:12:01+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.ca.info.edit}	5	f	f	apiv4_editCaInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
73f936bd-38c1-4de5-9555-3325c6504d9d	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.safe_snap"}	5	f	f	apiv4_WebCdnDomainSetting_put_safe_snap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0279e5bd-bb2a-4df0-ae90-94c211499a05	2019-08-22 16:47:20+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/firewall.policy.get_groupId}	5	f	f	apiv4_GetFirewallPolicyGet_groupid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d904e8f9-2a1c-444a-9795-4f516cf4380f	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/dns.hijack.task.list}	5	f	f	apiv4_DnsHijack_getTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
89cda439-4a68-4cf1-9265-5bac52b678f7	2019-08-06 17:10:59+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.ip.risk.control.status.line}	5	f	f	apiv4_Get_postStatisticTjkdAppIpRiskControlStatusLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa869713-59c2-48f1-97bd-aa580441b1b9	2019-12-11 15:55:11+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dispatch.rule.sort.save}	5	f	f	apiv4_saveRuleOrderBy	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
650bcdc6-feeb-46ed-9d6b-48f561b040ed	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_500"}	5	f	f	apiv4_WebCdnDomainSetting_get_diy_page_500	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1ce80ae3-e5fa-4dd0-8369-973d0b97cd47	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf"}	5	f	f	apiv4_WebCdnDomainSetting_put_cloud_waf	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
94b61ca1-d2d4-4cce-a508-70dcc525b88b	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/dns.hijack.event.list}	5	f	f	apiv4_DnsHijack_getDnsHijackEventListStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e8e1689d-357f-4e22-984d-dba4b8265daf	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/update}	5	f	f	service_asset_UpdateServer	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
54c92605-bd90-4dab-9f7f-25b8bb489b06	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/dns.hijack.event.log.line}	5	f	f	apiv4_DnsHijack_getDnsHijackLineStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e3b45d5-6a1f-4a9a-ab5c-acb37c7e52d5	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/add_to_dispatch}	5	f	f	service_asset_addServerIpToDispatch	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
315dd29c-982f-49b9-934a-acf55ef157bf	2019-12-11 15:55:11+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dispatch.custom.template.rule.save}	5	f	f	apiv4_saveCustomTemplate	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
959ddfe2-9562-4d9d-ab28-7fa832e24fe0	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.hwws.createOrder}	5	f	f	apiv4_PostBuyHwwsCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
25d48655-7eac-4236-8302-e4904cd47928	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.hwws.orderInfo}	5	f	f	apiv4_PostBuyHwwsOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f34c672e-5839-49e5-8dee-a30eada63dd8	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.monitor.callback}	5	f	f	apiv4_ddos_monitorCallback	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9bc360c2-ae9b-404c-88d7-4ffdfba7e1bd	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.content_replace"}	5	f	f	apiv4_WebCdnDomainSetting_put_content_replace	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5a6f1aba-48bc-44d2-9d0e-ba9d52fb3ce3	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.tjkd_web_import_url_protect"}	5	f	f	apiv4_WebCdnDomainSetting_get_tjkd_web_import_url_protect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
723398b6-c43c-46ac-85f3-048f8f6f0ca1	2019-12-11 15:55:11+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,PUT,DELETE}	{}	{/V4/dispatch.abnormal.template.rule.save}	5	f	f	apiv4_saveDsAbnormalTemplateRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4cd95fe0-f40b-4e80-95d9-ae09d5e2e5b0	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/dispatchNotice}	5	f	f	service_asset_dispatchNotice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
83635081-33aa-4351-bda6-a83bc9a197f5	2019-12-11 16:12:21+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/notify}	1	t	f	service_notify_uripre_notify	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
02f85448-3fa4-459c-925d-58349480a84e	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/add}	5	f	f	service_asset_AddIdcHouse	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1c0d4484-74d7-4b48-bc72-9068b6f23963	2019-12-11 15:55:11+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.template.bind.get}	5	f	f	apiv4_getTemplateBindAll	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5112f813-cf2f-4632-97dd-c73e418f1f20	2020-04-06 20:55:29+08	2021-01-01 21:36:18+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/idc_house/list}	5	f	f	service_asset_GetIdcHouseList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
935fb5d8-6470-425a-be97-789fa8d1ea8c	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/V4/service.apply.email.check}	5	f	f	apiv4_GetV4ServiceApplyEmailCheck	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c8adedbf-e18e-4cb2-aabf-9e8f0c1017fe	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.forward.rule.batch.info}	5	f	f	apiv4_PostTjkdAppForwardRuleBatchInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5bf84f09-e0f0-4016-abcd-ed9c444953f0	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.message.createOrder}	5	f	f	apiv4_PostBuyMessageCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f25b3b8e-0af2-495a-a09d-a2ac250637c9	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_refer"}	5	f	f	apiv4_WebCdnDomainSetting_put_anti_refer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3f7b972a-c532-4bfd-a8fa-db83f7a311aa	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.forward.rule.batch.save}	5	f	f	apiv4_PostTjkdAppForwardRuleBatchSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
741b6dc4-d2b7-4bf6-bb3b-96777f51199d	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policy.close}	5	f	f	apiv4_PostFirewallPolicyClose	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64d15392-08fa-49d2-8e1c-768ee6ec1c0c	2020-04-06 20:55:29+08	2021-01-01 21:36:18+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/update}	5	f	f	service_asset_UpdateIdcHouse	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a2e92834-0e05-4960-adc8-6024ff82a3a5	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.message.orderInfo}	5	f	f	apiv4_PostBuyMessageOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
40e71503-4443-4458-a1e2-3e7a0bdb1bfa	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudsafe.hwws.package.add}	5	f	f	apiv4_addHwwsPackage	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
229d9ec9-f76b-496b-a085-cb2024f5f2a9	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudsafe.hwws.package.bind.domain}	5	f	f	apiv4_bindDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ade69953-2850-4efb-bf40-ce30f1f382f8	2019-12-12 10:49:12+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{POST}	{}	{/v1/voice1}	5	f	f	service_notify_Voice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d1e33816-da2f-4dc3-93b4-9de0dd5c0d78	2020-04-06 20:55:30+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/notify/admin}	1	t	f	service_notify_uripre_agw_notify_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d2bcc5b3-1282-414d-aade-efe1f0841eec	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.forward.rule.save}	5	f	f	apiv4_PostTjkdAppForwardRuleSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
12f220aa-61a7-4355-bdc4-c6986d005229	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Tjkd.plus.domain.del}	5	f	f	apiv4_DeleteTjkdPlusDomainDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
52f8f9a7-cb38-4f13-849a-3b2d8c057248	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/shield.risk.task.delete}	5	f	f	apiv4_RiskDetection_deleteRiskTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
88a315f7-b05b-434d-b605-4e7c7f194102	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.replaceMirror.createOrder}	5	f	f	apiv4_PostBuyReplacemirrorCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
86dd3d2f-a356-41db-916b-c020266fc02f	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.domain.fw_policy_status.trigger}	5	f	f	apiv4_PostFirewallDomainFw_policy_statusTrigger	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a292c360-1ab4-4918-ae01-17875b3767c5	2019-06-27 16:47:07+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Visit.list}	5	f	f	apiv4_getAllStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48c37d32-b5ff-4837-8c37-618692e8783d	2019-11-11 15:53:27+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/web.domain.list.short}	5	f	f	apiv4_getDomainShortList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ddfcd00f-2cf0-485c-ac7b-46fb5cae8ba4	2020-04-06 20:55:30+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/notify/console}	0	t	f	service_notify_uripre_agw_notify_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f7dd7230-ef90-47d9-ba22-4a4787eaedc3	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/del}	5	f	f	service_asset_DelIdcHouse	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a327fd91-6b59-4450-b79e-7cd63e5da433	2019-12-12 10:49:12+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{POST}	{}	{/v1/notice}	5	f	f	service_notify_Notice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27c746ea-6491-49b0-b48f-2e7e9d8c099f	2019-12-12 10:49:12+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{POST}	{}	{/v1/smsbatch}	5	f	f	service_notify_Smsbatch	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
96bff0dc-941e-4e32-bb16-32338a6bd291	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Safe.ids}	5	f	f	apiv4_getIdsStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92bc8c56-ae88-42ae-97f8-c16c9f8d3473	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cdntpl.task.child}	5	f	f	apiv4_cdntplGetsJobChild	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f94b471a-76fc-4b7a-8a79-9e3991062805	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.ca.apply.(?<id>\\\\d+)"}	5	f	f	apiv4_getApplyCaDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f6438bb0-b419-42eb-8378-7d54e43b58d6	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Web.ca.self.del}	5	f	f	apiv4_delCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1652433f-d83b-4914-865c-a37991bb42da	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.domain.bind}	5	f	f	apiv4_cdntplBindDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3e2b684e-c88e-4573-8885-e801e348ea86	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Web.ca.apply.del}	5	f	f	apiv4_delApplyCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
abe5b49b-2e2a-47ff-b1a1-96d86eb5449f	2019-12-12 10:49:12+08	2021-01-01 21:37:32+08	df264124-bf20-4629-9d7c-e0fe9fa63d89	{http,https}	{POST}	{}	{/v1/emailbatch}	5	f	f	service_notify_Emailbatch	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bac1835f-b82e-474c-8b1f-6cd8fa608bec	2019-06-27 16:46:58+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_500"}	5	f	f	apiv4_WebCdnDomainSetting_put_diy_page_500	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b4de2654-3343-4894-8f73-c859b5eac1e2	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.ca.self.cloudspeedbycertificate}	5	f	f	apiv4_cloudSpeedByCertificate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
89aeb733-dc1a-481a-bc21-2b0f3c52de62	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.save}	5	f	f	apiv4_cdntplSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f9124ba7-9b5b-4d3a-b4a9-36d93e31939d	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.delete}	5	f	f	apiv4_cdntplDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b921ff7-014d-485c-bdcb-ff72730a87d6	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.ca.self.add}	5	f	f	apiv4_addCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27659ccc-9c7f-49d6-942f-5446c4f3374f	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.ca.self.editcaname}	5	f	f	apiv4_editCaName	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
56d397a9-512d-4d82-bfee-2cc6d6141a56	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot.rules"}	5	f	f	apiv4_createSettingsRuleWebHoneypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b9f703fd-4cd4-4951-a7eb-22ea1a768e9b	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.ca.self.export}	5	f	f	apiv4_editCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
627dcfa2-b0c1-4d41-a52e-cf11e525d806	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.domain.unbind}	5	f	f	apiv4_cdntplUnbindDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b755ebe2-ed16-45ca-9f6a-98b0790587cd	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.ip.delete}	5	f	f	apiv4_ddos_ipDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b2f37cd4-9914-4492-8229-4638a89e8a72	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.list}	5	f	f	apiv4_cdntplGets	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4ce3c98f-8373-49a3-aba8-f29a421b7acc	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cdntpl.oplog}	5	f	f	apiv4_cdntplGetsLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f2bd20e5-3a0c-4aa2-81c6-f2282d1e3400	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cdntpl.info}	5	f	f	apiv4_cdntplInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6a335eed-fcad-43cd-883e-0a668c6b61b0	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.ip.list}	5	f	f	apiv4_ddos_ipGets	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6ef503a8-4c4c-457d-bbec-0770145a624c	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.ip.save}	5	f	f	apiv4_ddos_ipSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
07a58e00-3838-4a41-b7d7-4e4150f6f105	2019-06-27 16:47:02+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_get_websocket_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a0772ed8-520c-46cb-ad6a-d692112ecda1	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/dns}	0	t	f	service_dns_uripre_notify	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b2efced5-f9c0-4dc9-aa65-970524c65800	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.scan.createOrder}	5	f	f	apiv4_PostBuyScanCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f297a290-43ed-443d-94bd-75766fee970a	2019-06-27 16:47:02+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket.rules"}	5	f	f	apiv4_get_websocket_rule_list	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4072876e-bfbf-480b-9911-a0d77f5e4d40	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecordsLogs.export}	5	f	f	apiv4_GetClouddnsDomainrecordslogsExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cbeb1c11-7041-4448-b1e0-cce36349521c	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.block.details}	5	f	f	apiv4_Get_postFirewallReportBlockDetails	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
746189d5-cac8-4598-b3fe-af0f7ac8fe5a	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.package.channel.list}	5	f	f	apiv4_GetTjkdAppPackageChannelList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
365f6c81-c71c-47f3-bb79-c01bbd44c07a	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.riskDetection.createOrder}	5	f	f	apiv4_PostBuyRiskdetectionCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e11f1eab-82da-4081-8bcd-f54f99fb4524	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafscanlogs}	5	f	f	apiv4_getScanEventLogs	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ea555a7-3545-4822-8287-e6d2e5af5b7e	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.scan.orderInfo}	5	f	f	apiv4_PostBuyScanOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7387ef9f-3710-49ed-b2dc-5afb6e05dda8	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.waf.web.cc.top}	5	f	f	apiv4_Get_postStatisticWafWebCcTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
94cca026-3462-4bbe-8bda-e7935e2ee2b6	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.oplog.export}	5	f	f	apiv4_Get_postFirewallOplogExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92299eda-c032-4c11-b0e0-7126c6a5bc9c	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_delCloudWAfRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
949449c6-f809-4181-b029-d20ed0a1da14	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/domains/change_server}	5	f	f	service_dns_AdminDnsDomain_domainsChangeServer	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
12395eb2-c573-4317-a9a1-d3d47edd74ed	2020-04-06 20:55:30+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/oplog}	1	t	f	service_oplog_uripre_oplog	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a67965b2-0a9a-424b-b91d-aa6595170f20	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/cloudsafe.hwws.domain.del}	5	f	f	apiv4_delHwwsDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7e66a4e-29be-4bc9-8e0c-0fe611ba7d2d	2020-04-06 20:55:30+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog/admin}	1	t	f	service_oplog_uripre_agw_oplog_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e0007db-6925-4af2-826a-b662ef3bc3d6	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.add}	5	f	f	apiv4_CloudDns_DomainGroup_addGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e1251394-6c9c-4f8f-9099-0090398306b8	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainLogs.list}	5	f	f	apiv4_GetClouddnsDomainlogsList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d3a0217b-28dd-4e74-8536-ad526fb679d6	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.package.list}	5	f	f	apiv4_GetTjkdAppPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
daf78c30-8b60-4b19-9629-71484696c56b	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.riskDetection.orderInfo}	5	f	f	apiv4_PostBuyRiskdetectionOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e55d351-5c6b-4553-b6e5-ff73cd13dcef	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.forward.rule.info}	5	f	f	apiv4_GetTjkdPlusForwardRuleInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b9708018-04fc-4e8a-9a43-edc696d9f06e	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.tjkd.dns.createOrder}	5	f	f	apiv4_PostBuyTjkdDnsCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d22073a8-7311-4669-862c-b5efa49256c3	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.editDomainMap}	5	f	f	apiv4_PostClouddnsDomainDomaingroupEditdomainmap	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
04a95946-846e-4c26-9c06-b66e027ee8a6	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.info}	5	f	f	apiv4_monitorTaskInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9b262ee5-75b0-419d-b24e-70ad91f561b4	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.save}	5	f	f	apiv4_monitorTaskSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b08a341-14f4-469a-9b70-c4d6f69e5c2a	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getPdfReportList}	5	f	f	apiv4_getMemberPdfReportList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bb884ed9-32b9-4bd1-8b4f-69ed531c65c9	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.alertSetting.info}	5	f	f	apiv4_MonitorAlert_getAlertSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5d24825c-4b7e-44ef-b8d6-f524d17725ec	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.delay.avg}	5	f	f	apiv4_MonitorTaskStat_getDelayAvgLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1b21ccf7-1e27-4dac-9863-f42ee5a2ec93	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.delete}	5	f	f	apiv4_Get_postCrontabSystemDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ca90677-96c6-42b7-8ff5-827e2e362784	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.alertSetting.save}	5	f	f	apiv4_MonitorAlert_saveAlertSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9dbf6372-b68c-405b-8771-04d975a6697e	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.delete}	5	f	f	apiv4_monitorTaskDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6c9ed579-5b60-4702-a4d3-791189e75301	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Domain.Dispatch.domainTask.add}	5	f	f	apiv4_Dispatch_domainDispatchTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa7b303e-0d9a-4fc6-b585-05e2f5e98d21	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.alertSetting.config}	5	f	f	apiv4_MonitorAlert_getAlertSettingConfig	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
496c89a3-9516-44e8-9d84-3e28ebbe0e26	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/cloud.monitor.event.list}	5	f	f	apiv4_MonitorEvent_monitorEventList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d62407d9-f3c2-4805-a75d-79557742508e	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/domains/set_status}	5	f	f	service_dns_AdminDnsDomain_domainsSetStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e0369f35-c832-4f2d-b0aa-1ea91a9e603d	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.add}	5	f	f	apiv4_monitorTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
00f08394-7ca6-424e-a7d6-57e81fe4df77	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.disable}	5	f	f	apiv4_monitorTaskDisable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ff44be98-c3c3-457e-a6e8-b1b7d67eef9a	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.task.list}	5	f	f	apiv4_monitorTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ab0e27c0-7774-41a2-b2b2-195a59fb4a69	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.op.log.export}	5	f	f	apiv4_GetTjkdPlusOpLogExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c66e3014-9530-4543-bdf9-0b5ecd266891	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.point.availability}	5	f	f	apiv4_Get_postStatisticMonitorPointAvailability	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
77b45228-2da3-4da5-b6ed-4c0c358573df	2019-06-27 16:46:59+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.delReport}	5	f	f	apiv4_delMemberReport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bd25b119-4e35-4031-982f-be603caf9f08	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_delSettingsRuleWebHoneypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0fcc7272-ceda-4745-a689-62934ae6739c	2019-06-27 16:46:59+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DiyViews.deleteAll}	5	f	f	apiv4_deleteAllDiyView	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8df74001-af6a-4cc4-9e9b-d09aded8ab2c	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/domains/list}	5	f	f	service_dns_AdminDnsDomain_domainsList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
de9aa3e1-c16c-4729-9e06-d8a631bee628	2019-06-27 16:46:59+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DiyViews.edit}	5	f	f	apiv4_editDiyView	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d9a9172-2893-4a2d-8064-71efb6328797	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.info}	5	f	f	apiv4_ZeroTrustApp_getAppInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e0599c3-5749-4dbd-8a99-ae8165bd29e6	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.flow.forward.line}	5	f	f	apiv4_Get_postStatisticTjkdAppFlowForwardLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0028325b-9426-48b5-a440-217880e2a201	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.cdntemplate}	5	f	f	apiv4_PostOrderCdnCdntemplate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b3ce153-46d0-4633-9de1-8921d68d64b1	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/tag_type/save}	5	f	f	service_dns_PostTag_typeSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a67b2d65-521b-45ec-afe1-6520b28590f6	2019-06-27 16:46:27+08	2019-12-30 16:20:41+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.get.preheat.cache.list}	5	f	f	apiv4_WebCdnPreheatCache_getPreheatCacheList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0fead794-feb8-4869-adc1-d905f5ee22e4	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.start.app.times}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitStartAppTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
66f6fb1b-10d9-47c8-b421-353c92403410	2019-06-27 16:46:50+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/site.today.report.allplat}	5	f	f	apiv4_GetSiteTodayReportAllplat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ffa51583-c876-49ec-bca2-7f399e81c77c	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/tag_type/list}	5	f	f	service_dns_GetTag_typeList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d8be5812-f817-4f2c-ac12-c21b0386f99a	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.list}	5	f	f	apiv4_Get_postCrontabCrontabList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b1352b95-115f-45ab-8a06-c4dbee6abfae	2019-06-27 16:47:03+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.domain.search}	5	f	f	apiv4_batch_searchDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f0a9e0a4-d690-4191-8787-07714e882e66	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.pagecfg.hwws}	5	f	f	apiv4_Get_postFirewallPagecfgHwws	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
368c7dd9-123b-4a47-8e1a-fede50b871c3	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.game.session.time}	5	f	f	apiv4_Get_postStatisticTjkdAppGameSessionTime	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
31ec77bf-718e-4374-895b-96c54c8fbdbf	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.game.top}	5	f	f	apiv4_Get_postStatisticTjkdAppGameTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8c506cc1-c2cf-4e7e-85f6-39be8944cbc4	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/asset/console}	0	t	f	service_asset_uripre_agw_asset_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9ba638da-c6e4-44ce-b993-a52e71f8ab4d	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.block.risk.device.line}	5	f	f	apiv4_Get_postStatisticTjkdAppBlockRiskDeviceLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9bb347b0-3197-4fe8-bcae-845ee3340c57	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.game.visit.line}	5	f	f	apiv4_Get_postStatisticTjkdAppGameVisitLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
60da1527-ca67-4dc5-8f1c-926994c83e00	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.country.top}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitCountryTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ebef31ed-8832-4ece-a5c2-a7e67a4cc7ec	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.line}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e2a03a1b-f438-477f-a50a-5eae9fe043de	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.Province.top}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitProvinceTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a3a8463c-a78d-4a50-9417-cf88a581a34e	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.session.time.pre}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitSessionTimePre	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a9c07314-35cf-41bd-964a-7a15cc41e757	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.list}	5	f	f	apiv4_Get_postCrontabProcessList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
18965395-d461-4bce-8ca2-320873f27d8a	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/tag_type/info}	5	f	f	service_dns_GetTag_typeInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
afa6a1c9-a1af-4829-a0f8-770e78266d41	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/server/list}	5	f	f	service_asset_GetServerList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
240357c2-87c3-45e8-b1f4-a1e0b5272123	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/add}	5	f	f	service_asset_AddServer	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f79951e9-e57e-447a-8ab7-db9421f49872	2019-06-27 16:46:39+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.delete}	5	f	f	apiv4_Get_postCrontabCrontabDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
01b9cb4a-c3f8-4766-bf9b-c6bce2ed2809	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/smgc.package.bind.property}	5	f	f	apiv4_ScanObservePackage_bindPropertyToPackage	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
30489db9-58a9-4fb2-bfa4-772ed53bd46f	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist.rules"}	5	f	f	apiv4_add_visit_limit_blacklist_rule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4561c716-7116-4d98-a008-008a22bda959	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.info}	5	f	f	apiv4_getDnsDomainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dc73e53b-a44b-4386-ae95-146933a3b7d8	2019-06-27 16:46:59+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DiyViews.list}	5	f	f	apiv4_getDiyViewList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1a3877a7-117b-4097-a091-c534df78596b	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.detail}	5	f	f	apiv4_Get_postCrontabCrontabDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d8400932-6706-423a-be4d-149e11227d60	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.detail}	5	f	f	apiv4_Get_postCrontabSystemDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b54f8ab4-9b62-4953-90be-b8ed56cf3cfd	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.list}	5	f	f	apiv4_Get_postCrontabSystemList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3c05c095-95b3-458b-a26a-11b878a19816	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.open}	5	f	f	apiv4_Get_postCrontabSystemOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a2ba11b-95a9-40f4-af74-321ddf059609	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.idp.conf.fields}	5	f	f	apiv4_ZeroTrust_getIdpConfFields	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
18029c75-ee63-43bf-a7c4-8be6fd7aac5a	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.pagecfg}	5	f	f	apiv4_Get_postFirewallPagecfg	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
34f6bb9e-5f96-4423-9f3f-7a3fe6cd8159	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/domains/server_list}	5	f	f	service_dns_AdminDnsDomain_serverList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aa744eb7-8759-461b-bb95-4a48e1ff3e2f	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.del}	5	f	f	apiv4_ZeroTrustApp_saveApp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0cdc3ec9-037d-48d9-bb1d-98f9a367aa31	2019-06-27 16:46:24+08	2020-03-29 14:36:01+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.ca.apply.add}	5	f	f	apiv4_addApplyCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1cf652c9-787c-46bd-b0a5-6a1715fef42c	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.api.get.configureation}	5	f	f	apiv4_GetTjkdAppApiGetConfigureation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
90cbfa0e-2075-445c-b994-fb5500ec21ad	2019-06-27 16:46:36+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.domain.add}	5	f	f	apiv4_PostTjkdPlusDomainAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bd529f94-264b-41b3-a15e-34ea2db7c879	2019-06-27 16:46:36+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.plus.domain.cc.data}	5	f	f	apiv4_PostTjkdPlusDomainCcData	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d889eceb-4aea-4cdb-8025-ef6c7e626619	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.rule.add}	5	f	f	apiv4_ZeroTrustAccessGroupRule_addGroupRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
06d024d7-7763-4e23-b21e-79bc62c6b4d6	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.rule.del}	5	f	f	apiv4_ZeroTrustAccessGroupRule_delGroupRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
685d1b3e-6fb6-4455-8f2a-17bccb3f5aae	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/zero.trust.app.list}	5	f	f	apiv4_ZeroTrustApp_getAppList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
241740a2-eebf-4d29-aaa5-4d3b83996992	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.save.idp}	5	f	f	apiv4_ZeroTrustApp_saveAppIdp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a03f225c-c8c9-4b22-9424-235ffa130bf0	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.app.rule.conf.fields}	5	f	f	apiv4_ZeroTrust_getAppRuleFields	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1763700c-d5c9-48c0-ba5c-89a48faa930e	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.app.access.group.rule.conf.fields}	5	f	f	apiv4_ZeroTrust_getGroupRuleFields	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c9e14bc-7e5f-4677-8d2a-513c2c6ce30b	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.cloudMonitor.products}	5	f	f	apiv4_Get_postBuyCloudmonitorProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7c00827-3f28-4ff8-b7f4-b87e1a6d0758	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTFingerPrintAssociationAttackIP}	5	f	f	apiv4_getWafAPTFingerPrintAssociationAttackIP	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6b791ff8-a47e-4130-bf52-3ee162f19ac0	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/smgc.property.add}	5	f	f	apiv4_ScanObserveProperty_addProperty	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1336118e-951a-4803-bf61-1f5a875f45c9	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/host.scan.getDetailList}	5	f	f	apiv4_HostScan_getDetailList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aea0885d-630f-4489-b194-d02394c4af63	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/host.scan.getDetailInfo}	5	f	f	apiv4_HostScan_getDetailInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
542396d8-ef0d-4370-b0ae-232290d26bd6	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.monitor.query}	5	f	f	apiv4_ddos_monitorQuery	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6cac144b-4e1a-4ce2-a8af-9a131ce6f78d	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/smgc.property.del}	5	f	f	apiv4_ScanObserveProperty_delProperty	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
93872a70-d7f6-4d94-b8db-67ae800ee5a7	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.edit.remark}	5	f	f	apiv4_DnsDomainRecords_editRecordRemark	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ff453733-3487-40b5-9ba2-9526caaa3427	2019-06-27 16:46:55+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket"}	5	f	f	apiv4_WebCdnDomainSetting_put_websocket	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eed5c6c0-8cdc-427b-9185-bd39da751f7f	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.getDomainDns}	5	f	f	apiv4_DnsDomainRecords_getDomainDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
16bc126a-4850-42d6-b01a-2eeddec8144c	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.package.list}	5	f	f	apiv4_ScanObservePackage_getPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a2dfb34d-38d5-4ca5-9a03-9652d6414764	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.editRecord}	5	f	f	apiv4_HostScan_editRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c21f78b4-e199-46d3-8823-9cecde3ba779	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/host.scan.editPlanStatus}	5	f	f	apiv4_HostScan_editPlanStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ee1c38c8-7230-4ef0-8b66-c2a3809564e3	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.property.all.list}	5	f	f	apiv4_ScanObserveProperty_getAllPropertyList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f335320f-8ca5-453d-8a86-1de573790eb4	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTAttackLineDays}	5	f	f	apiv4_getWafAPTAttackLineDays	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ed97a7f-3bf3-4269-8810-c25ba0e220d3	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.hwws.getDomains}	5	f	f	apiv4_Get_postBuyHwwsGetdomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
31a06924-a724-4f0a-8ed1-563f27df79cc	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/CloudDns.DomainRecords.batchDetail}	5	f	f	apiv4_DnsDomainRecords_getRecordBatchDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e8d5b9a-3e8c-49d1-8cc6-f06155aa4005	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/smgc.property.list}	5	f	f	apiv4_ScanObserveProperty_getPropertyList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3929ad5e-9c99-4b84-bda4-fdc070495fc9	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.hwws.products}	5	f	f	apiv4_Get_postBuyHwwsProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5465e5ed-af15-420b-96eb-a0b67638bfaf	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.message.products}	5	f	f	apiv4_Get_postBuyMessageProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e58cafd-411a-40eb-a9f3-7f0ee165832a	2020-04-10 10:51:03+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/ads.api}	5	f	f	apiv4_PostAdsApi	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64d4e098-effb-4fcf-81f5-18a906b29acc	2020-04-10 10:51:03+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/ads.plan.ip.block.del}	5	f	f	apiv4_PostAdsPlanIpBlockDel	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e076e221-ef86-42a9-8464-293839ab50e8	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/host.scan.addRecord}	5	f	f	apiv4_HostScan_addRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5e38affb-caed-46ca-9d6e-746f1fece5a2	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.tjkd.dns.getDomains}	5	f	f	apiv4_Get_postBuyTjkdDnsGetdomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6b00d6f5-ee7f-4a64-86f7-9a4719a3b5fd	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.save}	5	f	f	apiv4_ZeroTrustAccessGroup_saveGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62c81750-ae10-4ed0-af6b-e0ac780e87ea	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.tjkd.dns.products}	5	f	f	apiv4_Get_postBuyTjkdDnsProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c35c7faf-373e-47c7-a5ca-bbaa3f49327a	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.get.RelactionList}	5	f	f	apiv4_getDomainRelationList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7262e58-bde8-4ab8-ac6f-61b491eefe1b	2019-06-27 16:47:05+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.listenPort.list}	5	f	f	apiv4_getListenPortAdnSourceList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b26a4369-5cf7-4a3b-9c7b-c284df4538df	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.open}	5	f	f	apiv4_Get_postCrontabProcessOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
216bab1d-3a13-4c11-b4f7-ab318b920f87	2019-08-22 16:47:21+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policyGroup.save}	5	f	f	apiv4_PostFirewallPolicygroupSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
10b42538-3688-4304-be32-f0ad84cc7c18	2019-08-22 16:47:21+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policyGroup.sort}	5	f	f	apiv4_PostFirewallPolicygroupSort	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e7b16a0-75ed-4e1f-9e5c-43b70d39f4b1	2019-12-11 15:55:04+08	2020-04-10 10:51:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.edit}	5	f	f	apiv4_PostClouddnsDomainDomaingroupEdit	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
827f1ef4-1198-431c-a4af-0ce4136ff621	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/zero.trust.app.access.group.list}	5	f	f	apiv4_ZeroTrustAccessGroup_getGroupList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7d58f7a4-1b0f-4f55-92c5-a63fd49193a6	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Domain.Dispatch.IpTask.add}	5	f	f	apiv4_ipDispatchTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
50c500cd-7926-4a9d-9edc-45c2497c8023	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/replaceMirror.mirror.add}	5	f	f	apiv4_PostReplacemirrorMirrorAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7c7511f1-589b-45fb-85d1-201d67bf5e66	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/replaceMirror.mirror.configure}	5	f	f	apiv4_PostReplacemirrorMirrorConfigure	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92440477-8799-43c2-b254-f8b9642a23ff	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/replaceMirror.mirror.refresh}	5	f	f	apiv4_PostReplacemirrorMirrorRefresh	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b2daa10f-26cf-4fee-bd7f-7ede5381ca6b	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/replaceMirror.mirror.updateBackupCapacity}	5	f	f	apiv4_PostReplacemirrorMirrorUpdatebackupcapacity	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fd4aadaf-5c77-43c2-b3a5-7b1ab320e54a	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.cloudMonitor.createOrder}	5	f	f	apiv4_PostBuyCloudmonitorCreateorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cec7d2c3-0f7f-42dc-828f-a121a5d4f7fa	2019-06-27 16:46:30+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.cloudMonitor.orderInfo}	5	f	f	apiv4_PostBuyCloudmonitorOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d980338c-a132-432e-beed-7f5ac5ef7363	2020-04-10 10:51:03+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/ads.plan.ip.block.edit}	5	f	f	apiv4_PostAdsPlanIpBlockEdit	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c66f6e67-0337-4984-990a-98079b63d0b7	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.rule.save}	5	f	f	apiv4_ZeroTrustAccessGroupRule_saveGroupRule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
181f7b06-9b61-4571-8a22-3a27d779a5d2	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.add}	5	f	f	apiv4_ZeroTrustAccessGroup_addGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e0e0f7e8-e4c8-4f60-9b1a-7d6b37ff0d91	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.del}	5	f	f	apiv4_ZeroTrustAccessGroup_delGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
772dcb86-d741-418f-812d-c5d4eaf2f8a3	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.access.group.info}	5	f	f	apiv4_ZeroTrustAccessGroup_getGroupInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78afe70c-c52b-4699-805f-b4cf316e1b5a	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.del}	5	f	f	apiv4_DomainGroup_delGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d6d439cb-f07d-4d6f-a84b-57a4fcd41cec	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/web.domain.group.domain.list}	5	f	f	apiv4_DomainGroup_getGroupDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c3437b0-5d78-47af-b62c-aac41a22bc93	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.domain.save}	5	f	f	apiv4_DomainGroup_saveDomainToGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a8d1aadf-f6ea-411d-aa92-cc37ce1a179e	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.save}	5	f	f	apiv4_DomainGroup_saveGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd8ce77c-50e2-4fee-a857-538a7b5ce98b	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/host.scan.getHostScanNumber}	5	f	f	apiv4_HostScan_getHostScanNumber	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c55946df-05f3-4da0-b6b9-faba7d34b144	2019-06-27 16:46:31+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.availability}	5	f	f	apiv4_CloudMonitor_MonitorStats_statsAvailability	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f37e9df1-b638-4ea7-ba75-61d585ccd4cb	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getarticlelists}	5	f	f	apiv4_Get_postOverviewHomeGetarticlelists	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b33f0b0e-11b2-46ec-a164-619f176668eb	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.save}	5	f	f	apiv4_Get_postCrontabProcessSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9313e7a4-0385-404e-9f8c-f638a965495f	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.stop}	5	f	f	apiv4_Get_postCrontabProcessStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e79ee21b-bb1b-4e1e-b964-2fdc96e17809	2019-08-22 16:47:21+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policyGroup.stop}	5	f	f	apiv4_PostFirewallPolicygroupStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3ea57c6a-b123-4708-8619-ab245ca1d25e	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.otp.send}	5	f	f	apiv4_ZeroTrustOTP_sendNotice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd376a4e-943d-40ad-88d7-c15d1e61842b	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.idp.add}	5	f	f	apiv4_ZeroTrustIdp_addIdp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b5bfb6a-b93d-4287-ab82-ca1a25baea13	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.idp.list}	5	f	f	apiv4_ZeroTrustIdp_getIdpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
87d89dc6-0085-4e9a-be04-1d917fa9532e	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.ca.self.list}	5	f	f	apiv4_listCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
476ad275-0da1-4c88-954f-0cd3b1540330	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.add}	5	f	f	apiv4_DomainGroup_addGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aa852057-0300-4b33-8c01-61174239a93a	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.api.get.configureation.v2}	5	f	f	apiv4_GetTjkdAppApiGetConfigureationV2	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4ef492db-deb8-45e7-9a98-f92bb66cbdc5	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.home.getmessagelist}	5	f	f	apiv4_Get_postMessagecenterHomeGetmessagelist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7eceeab7-eed9-4252-abee-d3d12484049d	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.idps}	5	f	f	apiv4_ZeroTrustIdp_getIdps	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4e9632fe-ceb9-47e8-9ce0-3f68e50e3515	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.idp.save}	5	f	f	apiv4_ZeroTrustIdp_saveIdp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
71619507-3f42-4df0-b84c-1c81d5dc6809	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.idp.test.conf}	5	f	f	apiv4_ZeroTrustIdp_testIpdConf	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f7df578-8bb1-4262-8fb0-9cb2d3fc2640	2020-03-27 19:31:02+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET}	{}	{/user/oplog/list}	5	f	f	service_oplog_User_opLog_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c6334e4d-4a86-4c36-9f52-91cd70bdb404	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/zero.trust.idp.del}	5	f	f	apiv4_ZeroTrustIdp_delIdp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
134365b0-66c3-4b98-9355-a8126aaa12fc	2020-03-27 22:09:45+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET}	{}	{/user/oplog/info}	5	f	f	service_oplog_User_opLog_info	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ca25ec00-ed76-4a5f-9a55-04d5608a2104	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.package.overview}	5	f	f	apiv4_CloudMonitor_getPackageOverview	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1d82916a-9c4e-4d0f-b312-9a3cf682e9bf	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.package.block.details}	5	f	f	apiv4_Get_postFirewallReportPackageBlockDetails	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e7c31a77-f76b-4a6e-a016-7baea36dbf72	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.info}	5	f	f	apiv4_CloudMonitor_linkageInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b148b372-caa9-4427-b02a-b368199d764a	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.package.block.list}	5	f	f	apiv4_Get_postFirewallReportPackageBlockList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0ef23cca-9b91-42b0-a742-ae32a548cc8c	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/tjkd.app.domain.del}	5	f	f	apiv4_DeleteTjkdAppDomainDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ae22bc0a-3343-49f8-9f73-03498a8c37ae	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.platform}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitPlatform	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
32aa9a58-b3ad-44c7-bcc4-c6b75001b995	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.all.package.list}	5	f	f	apiv4_ScanObservePackage_getAllPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28750471-b1ad-409c-9bee-e5e7b477994b	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache"}	5	f	f	apiv4_WebCdnDomainSetting_get_cdn_advance_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
16d5f8f9-8130-40a6-85e3-f9cd9e74921d	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/tjkd.app.forward.rule.del}	5	f	f	apiv4_DeleteTjkdAppForwardRuleDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f8fab4a9-77f0-4eb9-8119-c3ed2bb5bb92	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.delete}	5	f	f	apiv4_Get_postCrontabServerDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
05cdec41-1bce-416d-b7ff-1e1fefa6c64d	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.detail}	5	f	f	apiv4_Get_postCrontabServerDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8097bb67-84e6-4439-a600-2794a732d5e9	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.list}	5	f	f	apiv4_Get_postCrontabServerList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c06d567-e029-4936-8e43-bdd722193b7f	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.block.list}	5	f	f	apiv4_Get_postFirewallReportBlockList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
98afcc7e-bf75-4582-af9e-744212423cd0	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.member.sso.info}	5	f	f	apiv4_ZeroTrustMemberSso_getSsoInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d2a6d1ec-41e5-4ea5-ada0-cb44cf2aef4e	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.member.sso.save.authdomain}	5	f	f	apiv4_ZeroTrustMemberSso_saveAuthDomain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
61aa1896-e85e-4d36-a39e-be4aa7989905	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.otp.verify}	5	f	f	apiv4_ZeroTrustOTP_verificationCode	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
099d4ea5-971d-4844-bb12-4bbcc79f5625	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/meal/tag/bind}	5	f	f	service_disp_MealBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8697c156-532e-4f45-a6a3-017793bb4899	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/tree/region}	5	f	f	service_disp_Line_treeRegion	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0413c91b-dbc6-4157-9e6e-ca6b9674eadf	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/policy/list}	5	f	f	service_disp_DispPolicyList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7cd7590b-b9b8-4e1a-b9da-48f394684bb4	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/disp/policy/operate}	5	f	f	service_disp_DispPolicyOperate	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da1cfc52-e668-45d6-9d2a-4fe505d0e18b	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/group/list}	5	f	f	service_disp_DispGroupList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bada221d-3d05-4860-8bb7-3e8c5c950884	2020-10-29 18:56:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/disp/group/save}	5	f	f	service_disp_DispGroupSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
492aa7ab-d8a2-4ed2-a084-4bf322ca817a	2019-06-27 16:47:08+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/stati.data.get}	5	f	f	apiv4_getStaticsData	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
313ef525-d5ce-4d3c-9872-fcf8f50ae9bf	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.scan.products}	5	f	f	apiv4_Get_postBuyScanProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d001a265-ec14-468f-bd4d-c3631539eb1f	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.op.log.list}	5	f	f	apiv4_GetTjkdAppOpLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6ada0aad-7dee-46d5-9984-dbd223d6c598	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.open}	5	f	f	apiv4_Get_postCrontabServerOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cd1ebde2-47ee-4723-b389-7a6818578c66	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.domain.add}	5	f	f	apiv4_PostTjkdAppDomainAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8f33ccd0-f79c-446a-af3b-0d3ef697920e	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.domain.edit}	5	f	f	apiv4_PostTjkdAppDomainEdit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
57ad57d4-d558-4989-9c88-d9e204aa6af4	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.forward.rule.batch.add}	5	f	f	apiv4_PostTjkdAppForwardRuleBatchAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6343f485-5d16-4226-95c2-da3b32d144a5	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Tjkd.plus.forward.rule.del}	5	f	f	apiv4_DeleteTjkdPlusForwardRuleDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ccc2184-2e0b-45e3-a486-18db51d0fda3	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.save}	5	f	f	apiv4_Get_postCrontabServerSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a90fbee-72bf-404f-bcf5-c3a01884b146	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Tjkd.plus.forward.rule.whiteblackip.del}	5	f	f	apiv4_DeleteTjkdPlusForwardRuleWhiteblackipDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
42f28363-2f41-42cb-ab46-5010ffb584bf	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.domain.usable}	5	f	f	apiv4_GetTjkdPlusDomainUsable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bfb1ec68-0b25-44ea-8f7e-cc65e4d8a979	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.server.stop}	5	f	f	apiv4_Get_postCrontabServerStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
07cad934-a5bb-4f41-83e5-af2e2296d70c	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.member.sso.save.design.status}	5	f	f	apiv4_ZeroTrustMemberSso_setLoginDesignStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6bde394d-4471-4dc3-9c7b-d5edfc13ad24	2019-06-27 16:46:52+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.Label.Tai.add}	5	f	f	apiv4_Domain_labelAddTai	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a3cf6bc9-5802-496d-a84e-b4480f095edf	2020-09-09 15:19:02+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.performance.edit}	5	f	f	apiv4_Order_PerformanceEdit	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aed9840a-22cf-473e-a6a9-073c410dcec2	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.alertSetting.save}	5	f	f	apiv4_CloudMonitor_alertSettingSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3f8b6c01-a7a4-448a-ac5d-1cec5124f602	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchDelete}	5	f	f	apiv4_DnsDomainRecords_batchDeleteRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7625221-b0bb-454b-891e-7b66fc154aa3	2019-06-27 16:46:32+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.api.get.report.getSetting}	5	f	f	apiv4_GetTjkdAppApiGetReportGetsetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3741e1f4-3d94-4fa7-b74b-e7aab41165e7	2020-04-19 21:09:59+08	2020-04-19 22:22:05+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/ads}	0	t	f	ads_uripre_asset	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bd61063c-ef95-4b2c-87aa-a61651690f1f	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/ip/add}	5	f	f	service_disp_IpPoolIpAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3940f03b-8576-4c0c-bea2-f34efde86bf2	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/ip/delete}	5	f	f	service_disp_IpPoolIpDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2844c9e9-bc84-4bc1-98dd-8e0b957ab053	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/ip/pause}	5	f	f	service_disp_IpPoolIpPause	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
490cd055-5343-4003-80b8-07e52e8518bb	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.member.sso.save.design.conf}	5	f	f	apiv4_ZeroTrustMemberSso_saveLoginDesignConf	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d131de5-849f-4387-a29d-5fec30c55e93	2020-11-04 17:01:44+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/group/list}	5	f	f	service_disp_IpPoolGroupList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78b5c5a0-d947-48e3-8017-59e157961faf	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.forward.rule.change.use.cdn}	5	f	f	apiv4_PostTjkdAppForwardRuleChangeUseCdn	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
efaa903b-be39-404f-8871-71baece3b397	2019-06-27 16:46:36+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.plus.ddos.data}	5	f	f	apiv4_PostTjkdPlusDdosData	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e4b99411-f68c-4880-b34d-9835e851efb9	2020-03-28 15:04:34+08	2020-03-31 16:11:32+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog/console}	0	t	f	service_oplog_uripre_agw_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
618cb810-ad86-44ef-9955-e497e1bcd199	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/buy.tjkd.dns.orderInfo}	5	f	f	apiv4_PostBuyTjkdDnsOrderinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80f9ea21-072b-483f-a9bd-becec4420e63	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.plus.package.port.list}	5	f	f	apiv4_GetTjkdPlusPackagePortList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ad35af1-e32c-4cee-98f1-19d1cde8c35b	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.domain.change.protect.status}	5	f	f	apiv4_Get_postTjkdPlusDomainChangeProtectStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78d593c1-bcf9-4af0-b43b-72474326fe10	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.domain.list}	5	f	f	apiv4_Get_postTjkdPlusDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c51a3bed-d3cc-4df7-9c00-7aad787b504c	2020-04-19 21:26:43+08	2020-04-19 22:22:07+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/realtimeAttack/dstIpStatus}	5	f	f	ads_dstIpStatusUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
941cc241-c5b6-4f46-885d-88c23c08a592	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.forward.rule.list}	5	f	f	apiv4_Get_postTjkdPlusForwardRuleList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f16d912-72ff-450f-808a-3bb993f1943e	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.forward.rule.whiteblackip.list}	5	f	f	apiv4_Get_postTjkdPlusForwardRuleWhiteblackipList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e37e8aa-3d98-49dc-bd66-353fbf98d28a	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.package.change.elasticity.protect.status}	5	f	f	apiv4_Get_postTjkdPlusPackageChangeElasticityProtectStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e25279f9-5db3-4c7b-9d72-2646035a0529	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/tjkd.plus.package.domains}	5	f	f	apiv4_Get_postTjkdPlusPackageDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
655d339d-1f6f-4adb-bc22-94c323edc573	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.protect.ip.firewall.info}	5	f	f	apiv4_Get_postTjkdPlusProtectIpFirewallInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9610915d-f56a-4924-86f8-28d87288e7e8	2020-09-09 15:18:59+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.info}	5	f	f	apiv4_GetPermissionGetInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
47b02209-0e7e-4a29-b0f6-64ad7046aa38	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.group.info}	5	f	f	apiv4_GetPermissionGroupInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
212c9a74-a98c-4b8a-93e5-a343aa50c95d	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.group.users}	5	f	f	apiv4_GetPermissionGroupUsers	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5a419dde-c626-45ef-94b6-dd323d10a39b	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.strategy.users}	5	f	f	apiv4_GetPermissionStrategyUsers	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
524b40cd-8e52-43ae-8bb1-d81eba336a6c	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.group.bind.user}	5	f	f	apiv4_PostPermissionGroupBindUser	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
623dda1b-f609-454c-8169-ccd8a24a1f8f	2020-09-09 15:18:59+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/invoice.lock.request}	5	f	f	apiv4_invoice_lockRequest	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
46ef6dff-3c0e-4a06-99d8-783da2403960	2020-09-09 15:18:59+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/invoice.unlock.request}	5	f	f	apiv4_invoice_unlockRequest	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1da96c3f-9f68-437a-bbb3-4fa44a98e148	2020-02-24 23:12:03+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.set.save}	5	f	f	apiv4_MemberSet_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7dbe191e-446c-414a-b260-e5e047664071	2020-09-09 15:18:59+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.ty.plan.bandwidth}	5	f	f	apiv4_webTyBandWidthAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5b7543c4-2fbb-4e59-be58-b934ba42912a	2020-09-09 15:18:59+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.child.info}	5	f	f	apiv4_GetPermissionChildInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
306bdd64-621f-497d-9966-6c02629f6028	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.packet.message.add}	5	f	f	apiv4_PostTjkdPlusForwardRulePacketMessageAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
23e553c3-db0b-451d-908d-0430b796788f	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.save}	5	f	f	apiv4_PostTjkdPlusForwardRuleSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7185e407-d3a5-4fe0-a45e-93d9c9a06692	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.conversation}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcConversation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b2491309-9dc0-4721-9405-53b4bcd47b41	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.Country.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcCountryTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d4f6563-0beb-49c9-94b8-fa6ee81b1dea	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/statistic.tai.ddos.line}	5	f	f	apiv4_getDDoSLineStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b4081abf-0ca4-40fe-b410-23dd1b9c40e8	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/statistic.tai.cc.top.province}	5	f	f	apiv4_getTopProvinceStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
79d30e3a-a767-4d41-a57f-d0f62508cd8a	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/statistic.tai.cc.top.country}	5	f	f	apiv4_getTopCountryStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
130c9265-2eb1-4836-b73d-372aec66deb6	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_domainid}	5	f	f	apiv4_Get_postFirewallPolicyGet_domainid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
01b0fdca-7eb7-418f-b5ed-6ca0ba430fbc	2019-08-09 12:12:05+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/host.scan.getList}	5	f	f	apiv4_HostScan_getHostScanPlanList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c19a8c06-4242-4060-aef8-6b729350a0e0	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.ajax_load"}	5	f	f	apiv4_WebCdnDomainSetting_put_ajax_load	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5fd398c8-6bf6-498d-8e0c-f0eab5e4aa1b	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.cc.setting.save}	5	f	f	apiv4_PostTjkdPlusForwardRuleCcSettingSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8c6cc209-5161-4a73-80df-61d27000c3b0	2020-03-28 15:12:01+08	2020-03-28 15:12:01+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/oplog}	1	t	f	service_oplog_uripre_api_agw	\N	\N	\N	\N	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c4259ddc-33b4-4b92-889f-fcace9d1787b	2020-03-28 15:12:01+08	2020-03-28 15:12:01+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api/agw/oplog/console}	0	t	f	service_oplog_uripre_api_agw_console	\N	\N	\N	\N	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c5c18ac7-79e6-4120-a08c-42d98ecefe91	2020-04-19 21:29:39+08	2020-04-19 22:22:06+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/rbwlist/query}	5	f	f	ads_queryUsingPOST18	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
885bc174-4ce0-4a73-8a63-3a1f5fb5a456	2020-04-19 21:29:38+08	2020-04-19 22:22:07+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/defense/query}	5	f	f	ads_queryUsingPOST14	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
092134aa-1545-418d-8a3e-f205240b6628	2020-04-19 21:29:38+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET}	{}	{"/v1/pub/download/pcapZip/{uuid}"}	5	f	f	ads_pcapZipUsingGET7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ba2d8065-7399-474b-b3b3-1c36e172c57c	2020-04-19 21:29:37+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/pcap/saveApi}	5	f	f	ads_saveApiUsingPOST55	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5b426ccd-3a15-42eb-a9df-ac7e6bc0b76b	2020-04-19 21:29:38+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/receiver/execute/}	5	f	f	ads_executeUsingPOST47	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd1570fd-9ef1-4a81-859f-3aa8dfcf8fda	2020-04-19 21:29:39+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET}	{}	{/v1/admin/cluster/getAllCluster}	5	f	f	ads_getAllClusterUsingGET7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e49fa4aa-9f15-4b3c-bac6-37f905cfca3e	2020-04-19 21:29:39+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/cluster/saveApi}	5	f	f	ads_saveApiUsingPOST15	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3f8110e9-4e62-4506-83e2-22c110887267	2020-04-19 21:29:38+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/bwlist/queryDynamic}	5	f	f	ads_queryDynamicUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d124c9e-3da5-4a9a-b937-268c21d9cd82	2020-04-19 21:29:38+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/defense/execute/}	5	f	f	ads_executeUsingPOST39	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
949b304b-6157-47c7-a93b-8654394b884f	2020-04-19 21:29:39+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/clusterStatus/query}	5	f	f	ads_queryUsingPOST13	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6b2f5f0d-bcdb-43db-9f57-50c0fc19311f	2020-04-19 21:29:38+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET}	{}	{/v1/admin/clusterStatus/queryAllIp}	5	f	f	ads_queryAllipUsingGET7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4ff78a5c-9b39-45a1-83e0-3ec6dcf0801e	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.retry_num}	5	f	f	apiv4_Order_reTryNum	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7973d9e0-be9f-4969-80a2-d1868a215fb4	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Tjkd.Web.Domain.del}	5	f	f	apiv4_delTjkdDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4fab8a8b-d7d8-4e7a-8223-8df3c516173c	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.permissionOverview}	5	f	f	apiv4_GetPermissionGetPermissionoverview	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b37b1add-8ac8-40e4-ab5c-fd7648fc7364	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.strategyList}	5	f	f	apiv4_GetPermissionGetStrategylist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5eaee2ed-4044-41eb-9f4e-6e4c930f53a7	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.strategySettingList}	5	f	f	apiv4_GetPermissionGetStrategysettinglist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ca36d26a-df2a-43d0-9829-39ce92ed9e42	2019-06-27 16:46:26+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.availability.line}	5	f	f	apiv4_MonitorTaskStat_getTaskAvailabilityLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d0083ad-1c33-428b-9159-f230b39f5528	2019-06-08 18:18:19+08	2019-06-09 11:28:45+08	\N	{http,https}	{POST}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.ca.apply.add}	5	t	f	addApplyCa	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
43f5c46e-e675-4532-b8f2-29f15b8461eb	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/finance.invoice.detail}	5	f	f	apiv4_Get_postFinanceInvoiceDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a14afe61-d28a-4f19-a017-dae5d161a49d	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/finance.invoice.list}	5	f	f	apiv4_Get_postFinanceInvoiceList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c66d774-8538-4d52-b949-a3613221f50e	2019-06-27 16:46:39+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/order.cdn.calctemplate}	5	f	f	apiv4_GetOrderCdnCalctemplate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a6015ceb-9af2-4586-bd3c-288f0ce09703	2019-12-12 18:51:16+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.ca.bind}	5	f	f	apiv4_web_domain_ca_bind	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
602de9ef-e8a4-49f6-9b21-bae5f230bf36	2020-04-19 21:29:40+08	2020-04-19 22:22:07+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeAttack/dstIpAckTop}	5	f	f	ads_dstIpAckTopUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9ba4c172-3ac7-42ca-8a56-c4496036dd2f	2020-04-19 21:29:39+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/accurate/execute/}	5	f	f	ads_executeUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e1d178d6-56a9-47cf-add1-b82e41a705d5	2020-04-19 21:29:40+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/cluster/query}	5	f	f	ads_queryUsingPOST1	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c33d7111-9fe6-4052-8eee-d46ab44f75bd	2020-04-19 21:29:41+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/realtimeAttack/dstIpAck}	5	f	f	ads_dstIpAckUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c13b4470-4d15-4e90-8af7-1e0a37671910	2020-04-19 21:29:39+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/bwlist/executeDynamic/}	5	f	f	ads_executeDynamicUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
76cf69c6-53b3-4db9-af50-1a8bcdbfa696	2020-04-19 21:29:40+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET}	{}	{/v1/admin/clusterStatus/queryAllCluster}	5	f	f	ads_queryAllClusterUsingGET7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
11a6586c-0fb9-49a6-8fa0-079e7c829425	2020-04-19 21:29:39+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{GET}	{}	{/v1/admin/defense/getAllDefense}	5	f	f	ads_getAllDefenseUsingGET7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
474f8782-e704-478e-8950-206f914ac9a1	2020-04-19 21:29:40+08	2020-04-19 22:22:09+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/defense/rule/}	5	f	f	ads_ruleOperateUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fdce23c4-73b0-47e1-891d-6b9a94868e70	2020-04-19 21:29:39+08	2020-04-19 22:22:09+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/pcap/query}	5	f	f	ads_queryUsingPOST16	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
32563794-da91-4fbb-a9d0-c8edcc47e369	2020-04-19 21:29:41+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/accurate/query}	5	f	f	ads_queryUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ffd1bd6-9745-49bf-b73c-f096c0c2e2c5	2020-04-19 21:29:40+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/template/execute/}	5	f	f	ads_executeUsingPOST63	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c735e9c-5c6f-4bd7-9c78-b6589f0a0a61	2020-04-19 21:29:40+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/clusterStatus/card}	5	f	f	ads_cardUsingPOST8	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1a0d447d-9d88-42d2-9037-3b07c6445f4f	2020-04-19 21:29:39+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/device/execute/}	5	f	f	ads_executeUsingPOST23	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c0e263fc-5441-4f2d-b482-b1540c5ad3cd	2020-04-19 21:29:40+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/device/query}	5	f	f	ads_queryUsingPOST2	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4787c1e4-df7f-4fad-9c70-e17222c019a3	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/replaceMirror.mirror.configureInfo}	5	f	f	apiv4_Get_postReplacemirrorMirrorConfigureinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dfdd6268-694a-4afe-b200-678d1e6a9aed	2019-06-27 16:47:03+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.batchAdd}	5	f	f	apiv4_batchAddDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
edc6c436-7f04-446c-a5d8-ff12c7e530b8	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Tjkd.plus.forward.rule.whiteblackip.save}	5	f	f	apiv4_PutTjkdPlusForwardRuleWhiteblackipSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
df6b15bf-832f-4238-8bb5-f5da2ece7a8b	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackOrdinaryTimes}	5	f	f	apiv4_getWafAttackOrdinaryTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cd468382-012c-44ea-a168-d1b1623d7dcb	2019-06-27 16:46:35+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.op.log.list}	5	f	f	apiv4_GetTjkdPlusOpLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f7fef9a9-7cee-4950-95ac-acc21c5b2d59	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/messagecenter.notice.addnoticemember}	5	f	f	apiv4_PostMessagecenterNoticeAddnoticemember	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5456ad26-4f0c-47b3-90dc-3822f92e77d1	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.avg.sessiontime.line}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcAvgSessiontimeLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7d6bdf74-9e22-49bd-bba8-9d24a14ea5b9	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.notice.updatenoticemember}	5	f	f	apiv4_PutMessagecenterNoticeUpdatenoticemember	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1899e324-1513-4171-961b-72ef843c2088	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/finance.invoice.apply}	5	f	f	apiv4_PostFinanceInvoiceApply	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c226d34d-a1da-4a39-a4bf-de7fda8ffe9c	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/replaceMirror.mirror.isPurchased}	5	f	f	apiv4_Get_postReplacemirrorMirrorIspurchased	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aef118db-a801-4f86-81ed-a7f5071badc7	2019-06-27 16:46:46+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.get.info}	5	f	f	apiv4_PostPermissionGetInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5193048d-a90a-4fc9-8499-fd30b89b9d52	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/replaceMirror.mirror.list}	5	f	f	apiv4_Get_postReplacemirrorMirrorList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9937b4f8-22d6-4503-b422-5ee50e7078c4	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackIpTop5}	5	f	f	apiv4_getWafAttackIpTop5	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4685721c-afe6-420e-981c-36898aa373bb	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackIpTopProvince}	5	f	f	apiv4_getWafAttackIpTopProvince	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d09473e6-e18e-46e9-a96a-3b341a07d07f	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackLine}	5	f	f	apiv4_getWafAttackLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c202c3fe-2885-4f06-83b1-8f38b93c5910	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackSeniorTimes}	5	f	f	apiv4_getWafAttackSeniorTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9694137c-1caa-4124-8627-b780e765ac75	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackSite}	5	f	f	apiv4_getWafAttackSite	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9e291431-ca59-42c8-9136-327bd2624198	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/replaceMirror.mirror.del}	5	f	f	apiv4_DeleteReplacemirrorMirrorDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cb2d5b54-2e0f-45b2-a90a-5547e1f2502d	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Tjkd.plus.forward.rule.packet.message.save}	5	f	f	apiv4_PutTjkdPlusForwardRulePacketMessageSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a3f7e15-1ec8-4152-bc1a-769887aeeff6	2020-04-19 21:29:42+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeAttack/ackTypePercentage}	5	f	f	ads_ackTypePercentageUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5adaac4a-82dc-4508-8743-a404f7e05b99	2020-04-19 21:29:42+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/bwlist/query}	5	f	f	ads_queryUsingPOST12	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6b08a116-d055-413a-b88b-6acf035a17da	2020-04-19 21:29:41+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/accurate/saveApi}	5	f	f	ads_saveApiUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e959ee4-a0a1-45b4-ab72-223d7cc61c3d	2020-04-19 21:29:42+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeAgentDevice/queryCard}	5	f	f	ads_cardUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e853571-3631-4d08-9f25-33c00b59d2ac	2019-06-27 16:46:52+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.notice.addmembertonoticegroup}	5	f	f	apiv4_Get_postMessagecenterNoticeAddmembertonoticegroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ae0e719e-1a58-4ddc-9531-1e06dc2acdbb	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.add.batch}	5	f	f	apiv4_addWebCdnDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
49784e90-d6e2-419e-8614-99b9796c0eb5	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Web.Domain.change.node}	5	f	f	apiv4_Get_postWebDomainChangeNode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
32fa3349-c943-42de-949f-c2571f90f5b8	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Web.Domain.listenPort.del}	5	f	f	apiv4_delListenPort	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ee18c50e-479a-4765-85a9-9849e7d0bdad	2019-06-27 16:46:53+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_refer"}	5	f	f	apiv4_WebCdnDomainSetting_get_anti_refer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f8336b39-e667-4e80-810f-71bdcf223087	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.Open.Close.Protect}	5	f	f	apiv4_cloudSpeedOpenCloseProtect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f0c9e38b-b313-4f76-a636-c3756f95525d	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.system.stop}	5	f	f	apiv4_Get_postCrontabSystemStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
063a5ba2-09cd-4ecd-8d1e-028d6ddb3cba	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.waf.web.cc.Country.top}	5	f	f	apiv4_Get_postStatisticWafWebCcCountryTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b222ab0-31a9-4111-9423-d696fe8d421a	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_modify"}	5	f	f	apiv4_WebCdnDomainSetting_put_anti_modify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cbd67e12-c342-4f82-adca-52cfe5fcf7a9	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/private.node.related.batch.info}	5	f	f	apiv4_Get_postPrivateNodeRelatedBatchInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7c048a9-407b-4669-aebb-4f938c1ca4f3	2019-06-27 16:47:03+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Web.Domain.remove}	5	f	f	apiv4_delDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ef7a02c-0670-4836-a975-98ea582c184c	2019-06-27 16:46:31+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/web.domain.group.list}	5	f	f	apiv4_DomainGroup_getGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7d9ae4b7-5dc8-47d1-a34e-6a3d9774e515	2019-11-05 11:49:39+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/web.domain.set.save}	5	f	f	apiv4_web_cdn_put_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
240404a7-ee8f-4951-89a1-9a63b35c8984	2019-06-27 16:47:06+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Member.makeMemberDns}	5	f	f	apiv4_makeMemberDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8f5bdb7b-769b-47cd-bfc8-9a7b6f478d36	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_id}	5	f	f	apiv4_Get_postFirewallPolicyGet_id	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6cb3a824-989c-4d4d-8fcc-f79324698f0d	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.domain.info}	5	f	f	apiv4_Hwws_getDomainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
825c527e-464f-4a11-b247-ec6c6650ab8b	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.domain.info}	5	f	f	apiv4_GetTjkdAppDomainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b7e5a30-6abe-4d0a-9c51-a161243386fa	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/private.node.list}	5	f	f	apiv4_Get_postPrivateNodeList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
396402d3-df74-4e22-bd59-7823d23738a6	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/private.node.monitor.log.list}	5	f	f	apiv4_Get_postPrivateNodeMonitorLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7b9e26a-3291-457a-ab47-19dd3c6d536a	2020-04-19 21:29:41+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/bwlist/saveApi}	5	f	f	ads_saveApiUsingPOST31	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
309521b7-ca91-46a1-bb32-1917337cebe8	2020-04-19 21:29:41+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeConnect/query}	5	f	f	ads_queryUsingPOST10	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d6f2f70-7981-4f3a-86c6-2c67e8f33af0	2020-04-19 21:29:41+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/bwlist/execute/}	5	f	f	ads_executeUsingPOST31	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1b7858bb-223d-40de-a73c-d93943a6982f	2020-04-19 21:29:42+08	2020-04-19 22:22:12+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/defense/saveApi}	5	f	f	ads_saveApiUsingPOST39	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
087b2e1a-9468-42c9-a191-8b7690af7135	2019-11-05 11:49:39+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/web.domain.set.get.rule}	5	f	f	apiv4_web_cdn_get_set_rule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6aacc542-5dc9-4175-80d9-82b41a8671bf	2019-06-27 16:47:01+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getReportDetail}	5	f	f	apiv4_getReportDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c74904a1-537d-4d99-bad8-41e16c176ec7	2019-06-27 16:47:01+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers"}	5	f	f	apiv4_filterPutDomainSettingData_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
73d1f1b1-d0cd-42d1-b00c-a6bb84a30845	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.listenPort.edit}	5	f	f	apiv4_editListenPortAndSource	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
875a848a-7572-49eb-9fd9-4df0562dcd04	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.strategy.get_binds}	5	f	f	apiv4_PostPermissionStrategyGet_binds	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eb2637c8-279a-45c4-8cde-aee6927e7b10	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.get.code}	5	f	f	apiv4_Get_postShieldPropertyGetCode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
be78b21d-d172-4ac9-bf20-b08b133d784a	2019-05-07 20:48:58+08	2019-05-07 20:48:58+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/addPersonalCertification}	0	f	f	sso-V4-addPersonalCertification	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
19bbbcba-391a-466b-8e37-32d277e56b4d	2019-05-07 20:48:58+08	2019-05-07 20:48:58+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/attach}	0	f	f	sso-V4-attach	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da0d6a8f-3246-4453-a929-1424f85b995e	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/findPass}	0	f	f	sso-V4-findPass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b309a87c-bd87-4f56-a622-0eee54534c90	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/findPassSendCap}	0	f	f	sso-V4-findPassSendCap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
75028ebb-8c6d-4478-8b9c-fffca60ebe68	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_ids"}	5	f	f	apiv4_WebCdnDomainSetting_get_cloud_ids	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c469100-2587-4b0c-b95c-cf98d2c6fc2e	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.router.import}	5	f	f	apiv4_PostPermissionRouterImport	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f3822137-6fe0-4f30-b9f7-881dbaf8b41e	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/ddos.ip.detail}	5	f	f	apiv4_ddos_ipDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4b23a43f-b38e-4f63-a05d-8d823b20ecf7	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.hsts"}	5	f	f	apiv4_WebCdnDomainSetting_get_hsts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6179dc98-5c79-456c-b334-d8034b8349ef	2019-06-27 16:46:59+08	2019-12-26 10:49:13+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.add}	5	f	f	apiv4_addDomainGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
072de41f-1abf-4f9e-a4a1-3c376cd80d44	2019-06-27 16:46:55+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.zone_limit"}	5	f	f	apiv4_WebCdnDomainSetting_put_zone_limit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
beef7e6d-0dac-4e58-8b12-b371babfb7d2	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_edit_cdn_advance_cache_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d9848291-aae3-46e3-9648-e64c7233c0ea	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTAttackLine}	5	f	f	apiv4_getWafAPTAttackLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
44c21064-e483-4eb0-a717-a37ff1a1954a	2019-06-27 16:46:58+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/messagecenter.noticesetting.add}	5	f	f	apiv4_PostMessagecenterNoticesettingAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1c2a4143-9e8d-4ec1-82ed-1f9aeb0d17d0	2019-06-28 10:58:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/getCertificationInfo}	5	f	f	apiv4_member_getCertificationInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8442d4fc-504b-4862-ba2a-0bb5293b62cb	2020-04-19 21:29:42+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/template/setConfig}	5	f	f	ads_setConfigUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
036bd326-cab7-4e78-8d96-a4bd943d0a7e	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.strategy.bind}	5	f	f	apiv4_PostPermissionStrategyBind	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1a71f6b4-5561-44dd-85ac-d07e5549d355	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/getCertificationInfo}	0	f	f	sso-V4-getCertificationInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
33511bf6-8f7e-4882-bf3d-583e5e2569a9	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/getLoginLog}	0	f	f	sso-V4-getLoginLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
666c5560-83dd-4d09-a571-3f3d3b781a5a	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/getMemberSetting}	0	f	f	sso-V4-getMemberSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
744e17ee-90b2-41fb-b04a-89ba573d230f	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/getSecurityQs}	0	f	f	sso-V4-getSecurityQs	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80b7a265-655b-4fba-b18d-980387eb1523	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/getUserInfo}	0	f	f	sso-V4-getUserInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d151ca4-d689-4edd-811e-92733f53c2cd	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/login}	0	f	f	sso-V4-login	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
331517ac-c74d-4745-97c9-0ce7fd59d253	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/logOut}	0	f	f	sso-V4-logOut	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
24079f5d-4ad7-492f-9989-585d44f8051b	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/modifyPass}	0	f	f	sso-V4-modifyPass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
60deb1da-88c2-4a19-a8ab-9aaf586c834d	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/modifyPassSendCap}	0	f	f	sso-V4-modifyPassSendCap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bd379623-c032-4140-a28b-519a8499fd21	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/register}	0	f	f	sso-V4-register	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fd995924-2a79-48a1-a9c2-88d42ba837c3	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/regSendMobileCap}	0	f	f	sso-V4-regSendMobileCap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bce5ea0e-f62d-40ff-a956-b53e351340ea	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/sso/V4/updateMemberSetting}	0	f	f	sso-V4-updateMemberSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d9f41237-f1a2-457c-b937-3dc13bb85e92	2019-05-07 20:48:59+08	2019-05-07 20:48:59+08	7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	{http}	{GET,POST,PUT,DELETE}	{homev5.kong.test.nodevops.cn}	{/api/V4/uploadfile}	0	f	f	api-V4-uploadfile	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
34347d4b-631e-477d-bf0b-623904ec30ce	2020-04-19 21:29:42+08	2020-04-19 22:22:08+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/receiver/query}	5	f	f	ads_queryUsingPOST15	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0ba59fca-00dd-4404-9a5a-17baf28fce91	2020-04-19 21:29:42+08	2020-04-19 22:22:05+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/cluster/execute/}	5	f	f	ads_executeUsingPOST15	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
73378220-0c4e-4412-8c96-5c125a93d110	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.Web.Domain.list}	5	f	f	apiv4_getDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e0eaea4-1615-4341-bc06-77e25405a578	2019-06-27 16:46:58+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_gzip"}	5	f	f	apiv4_WebCdnDomainSetting_put_page_gzip	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d4e0d67f-c450-4195-b16a-726ae5aba32c	2019-12-13 16:37:24+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET}	{}	{/v1/task/list}	5	f	f	service_batch_ListTask	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4874a0c2-b775-4f66-8301-7c4db80b1f30	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.all.country.visit.top}	5	f	f	apiv4_Get_postStatisticTjkdAppAllCountryVisitTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a744cba0-5da5-40af-b110-7b17dec67fa8	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.all.visit.line}	5	f	f	apiv4_Get_postStatisticTjkdAppAllVisitLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c00d9271-af18-46ba-bdf7-b5a82f7cdb97	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.source_site_protect"}	5	f	f	apiv4_WebCdnDomainSetting_get_source_site_protect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
37e20ca1-ba2b-4f4e-92a8-43ee927c4209	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.verify.generateFileCode}	5	f	f	apiv4_generateFileCode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3ac9063b-eb31-4a49-a9f5-237a3cb3d8bd	2019-06-27 16:47:04+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.verify.generateTXTRecords}	5	f	f	apiv4_generateTXTRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
56aedc5a-6d93-4e6d-b16b-775c75de816b	2019-06-27 16:47:09+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Visit.speed}	5	f	f	apiv4_getVisitSpeedStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
732e6cf9-c34e-40d3-90d7-ff600462c2d0	2019-06-27 16:46:58+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_put_page_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
57d101c5-fdd7-4168-a324-ef05267857e3	2019-12-13 16:37:24+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET}	{}	{/v1/subtask/info}	5	f	f	service_batch_InfoSubTask	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a3c0ba3a-b37d-43c9-a8d2-1276e7cb52f3	2019-12-13 16:37:24+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET}	{}	{/v1/subtask/list}	5	f	f	service_batch_ListSubTask	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
07fccb63-bb40-4a6e-9ed8-e8e1be0c3938	2019-06-27 16:46:58+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.DomainId.Settings.setCacheOrder}	5	f	f	apiv4_WebCdnDomainSetting_setCacheOrder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bdee667a-7d02-4924-b92a-d767c0026939	2019-06-27 16:47:05+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.listenPort.one}	5	f	f	apiv4_getOneListenPortAdnSourceList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92d1dd00-576c-4eea-819c-9d28152bc01a	2019-06-27 16:47:03+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.log.export}	5	f	f	apiv4_batch_logExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3a970ace-99eb-4a09-bb78-d617bb81ce3e	2019-06-27 16:47:11+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.zengzhi_pay}	5	f	f	apiv4_order_zengzhiPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
81132237-64ab-4591-9cdf-042779553984	2019-06-27 16:47:03+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Web.Domain.batch.log.search}	5	f	f	apiv4_batch_logSearch	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
68f4cac0-a4b3-40eb-b4a7-66418796c1f7	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_editSettingsRule_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48901494-0e9a-4b59-8fc6-2a5a1324f24f	2019-12-11 15:55:11+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dispatch.template.bind.save}	5	f	f	apiv4_saveTemplateBind	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
01b88980-d4b8-4fb3-945c-f937fbb59c28	2019-06-27 16:46:41+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.list}	5	f	f	apiv4_Get_postMemberList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1b3415d1-5d9e-4ddd-b5b9-65dcd5ceda61	2019-12-13 16:37:24+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{POST}	{}	{/v1/task/add}	5	f	f	service_batch_AddTask	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ae668e7e-6148-4b63-ac4c-f290674ff7dd	2020-04-19 21:29:42+08	2020-04-19 22:22:06+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeAttack/ackTrend}	5	f	f	ads_ackTrendUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
88031385-3577-48d8-b8bc-31d8ddab5757	2020-04-19 21:29:43+08	2020-04-19 22:22:10+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/receiver/saveApi}	5	f	f	ads_saveApiUsingPOST47	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48ef586e-5a00-4945-be84-6affc591c056	2020-04-19 21:29:43+08	2020-04-19 22:22:11+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/template/query}	5	f	f	ads_queryUsingPOST17	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92b67d8d-f350-4ad5-ae81-3eecc38f4c36	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.hsts"}	5	f	f	apiv4_WebCdnDomainSetting_put_hsts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1967f581-2d52-4717-9621-27590509ab2d	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.all_view_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_get_all_view_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2a168562-c719-47d0-8df6-727f788084fd	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.forward.rule.cc.setting.info}	5	f	f	apiv4_GetTjkdPlusForwardRuleCcSettingInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f005e17-2ed8-4f1c-97c2-0cb98cd10d81	2019-06-27 16:46:31+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.alert.info}	5	f	f	apiv4_CloudMonitor_alertInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ec5b097d-c727-4f80-9f8f-77df2ece1646	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.save}	5	f	f	apiv4_CloudMonitor_linkageSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d96b4ee0-c656-4623-8c0c-16b1108b2de9	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.forward.rule.info}	5	f	f	apiv4_GetTjkdAppForwardRuleInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0f042cf5-ba05-421c-8229-5b4339d3d2e7	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_edit_websocket_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0640d689-9cb6-4fbb-914f-cff500636c70	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.waf.web.cc.Province.top}	5	f	f	apiv4_Get_postStatisticWafWebCcProvinceTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0dfba679-ab45-4446-a456-56fcaae86c2f	2019-06-27 16:47:03+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.batch.subtask}	5	f	f	apiv4_batch_addDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
81ba0fb3-11f0-42f6-9a0e-6c005e516538	2019-06-27 16:46:46+08	2019-07-03 10:59:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.add.subUser}	5	f	f	apiv4_PostPermissionAddSubuser	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ef546c0-1e78-45be-b362-e96976dfc0fb	2019-06-27 16:47:03+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.batch.set.update}	5	f	f	apiv4_batch_update	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
383ed32c-52f7-4a56-8572-7eb5159e22d7	2019-11-05 11:49:39+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.set.save.rule}	5	f	f	apiv4_web_cdn_save_rule	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7f0fbfb9-5bdc-42cb-9866-2d5bc421f2c4	2019-06-27 16:46:31+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.failurerate}	5	f	f	apiv4_CloudMonitor_MonitorStats_statsFailureRate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
25f98efa-7015-42fc-99fb-418812fdfe3b	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.batch.add}	5	f	f	apiv4_PostTjkdPlusForwardRuleBatchAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa5b1d16-ca20-45f3-ac68-8ac2b7f59328	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.adjustmentdaybill}	5	f	f	apiv4_PostOrderAdjustmentdaybill	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
272f45f8-278d-4954-b74c-254cbb7ebe3e	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.plus.forward.rule.batch.save}	5	f	f	apiv4_PostTjkdPlusForwardRuleBatchSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
de29401b-730d-4c04-bf5b-8d183ab5e36d	2019-06-27 16:46:45+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.isrelation}	5	f	f	apiv4_PostCustomerManageIsrelation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
285d21e7-5252-4a2b-b249-02f204d06c4a	2019-06-27 16:46:56+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.batch.savemessagestatus}	5	f	f	apiv4_PutMessagecenterBatchSavemessagestatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f3404203-8978-40bd-9f4a-d317ee60292c	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.adjustmentorder}	5	f	f	apiv4_PostOrderAdjustmentorder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5a5130f3-c14e-49ac-b98c-ce2a656f0af7	2020-04-19 21:29:43+08	2020-04-19 22:22:07+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/template/saveApi}	5	f	f	ads_saveApiUsingPOST63	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d44c128-346e-40f0-87ea-71ff732ce803	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.strategy.sysinfo}	5	f	f	apiv4_PostPermissionStrategySysinfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9744bb2a-b9b4-477a-bf2f-5ce37cc2c8d2	2019-12-13 16:37:24+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/batch}	0	t	f	service_batch_uripre_batch	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69fefbe1-3bca-46dc-bdd2-806dfa256062	2020-11-11 09:59:03+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/batch_save_status}	5	f	f	service_disp_Ip_batchSaveStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
11673fb2-242e-4346-98ed-1663fdecd0bd	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafWebSiteCount}	5	f	f	apiv4_getWafWebSiteCount	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
61ea9a56-e975-4345-8439-e22f4d058c9d	2019-06-27 16:46:44+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.add.task}	5	f	f	apiv4_NodeMonitor_addTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5063feec-0c2b-44da-a8d2-ade6b8bd2a86	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.domain.batch.edit}	5	f	f	apiv4_PostTjkdAppDomainBatchEdit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a2fc379f-562a-4417-b21f-16fea333deeb	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/records/line_list}	5	f	f	service_dns_AdminDnsRecords_lineList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ed7de0a-69de-41f5-bcaf-e5bb066888b5	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.browser_cache"}	5	f	f	apiv4_WebCdnDomainSetting_get_browser_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d26e807a-7b4e-49d7-9a90-b6eae45f8a9c	2019-06-27 16:46:34+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/Tjkd.plus.forward.rule.packet.message.del}	5	f	f	apiv4_DeleteTjkdPlusForwardRulePacketMessageDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1343d0d3-fd76-4bf6-b02e-bff380994a80	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tjkd.app.package.ip.list}	5	f	f	apiv4_GetTjkdAppPackageIpList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7660d8a5-c122-496f-b57e-52961e853009	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackLogDetail}	5	f	f	apiv4_getWafAttackEventLogDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c4452f6-0f47-432f-a2c9-1f453c6fd490	2020-04-19 22:19:39+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{POST}	{}	{/tag/save}	5	f	f	service_tag_TagSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
70fda053-bb28-4242-8b61-c3c7bc24f77f	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTHackerPortraitAttackTactics}	5	f	f	apiv4_getWafAPTHackerPortraitAttackTactics	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f251ffd3-abb3-4662-850e-0a3813542880	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackLogs}	5	f	f	apiv4_getWafAttackEventLogs	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e9e58a89-8fd2-44ab-b187-35343e2a6164	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackIpList}	5	f	f	apiv4_getWafAttackIpList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
74616c5b-6fe8-4193-a0db-982b488ba40f	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackTimesAndAttackNameTimes}	5	f	f	apiv4_getWafAttackTimesAndAttackNameTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
65c3fa9b-3943-495b-9031-5a0a8979b252	2019-06-27 16:46:44+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.delete.task}	5	f	f	apiv4_NodeMonitor_deleteTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
60cc1b36-47aa-46e1-9fee-7417753e15b8	2019-06-27 16:46:44+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.save.task}	5	f	f	apiv4_NodeMonitor_saveTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ad1219f3-5c01-41b7-9215-2eff6643723a	2020-04-19 22:19:38+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag/delete}	5	f	f	service_tag_TagDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c120d6c3-b3e3-4ca3-ad63-4694cdedbe1c	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.domain.batch.add}	5	f	f	apiv4_PostTjkdAppDomainBatchAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
326188de-ede6-4bd6-8281-94a714ba587b	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.stats_domainid}	5	f	f	apiv4_Get_postFirewallPolicyStats_domainid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48df736b-7305-44f1-9fd5-34132d8ca531	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafWebShellAttackLogDetail}	5	f	f	apiv4_getWafWebShellAttackEventLogDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e71da8d-e510-4370-9e2c-e764653be7c7	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafWebShellAttackLogs}	5	f	f	apiv4_getWafWebShellAttackEventLogs	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e6fb692-cb5b-45f8-9a4f-c65cc31e8043	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf.rules"}	5	f	f	apiv4_addCloudWafRule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a8cca660-6ba4-4416-a668-37a79e175a55	2020-04-19 22:18:45+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag/info}	5	f	f	service_tag_TagInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c52026c4-2ba2-4e59-a5f8-7cf2a1fd8d0e	2020-04-19 22:19:40+08	2021-01-01 21:36:21+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag_type/list}	5	f	f	service_tag_TagTypeList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fc437d16-af11-492e-b55e-21e71e35422b	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/add}	5	f	f	dispatchapi_AddServer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7abd46f0-eca4-4e06-b818-7d28b92e1dff	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/idc_house/info}	5	f	f	dispatchapi_GetIdcHouseInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0d563309-f641-4eeb-9b6a-292056dbaa77	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/update}	5	f	f	dispatchapi_UpdateIdcHouse	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ab6a27dc-e714-49b0-9719-ea52206ee152	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.adjustmentprice}	5	f	f	apiv4_PostOrderAdjustmentprice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
89127524-6baf-4514-a70f-7eebcba29502	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/add}	5	f	f	dispatchapi_AddServerIp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c3b8b5a2-1d00-42a4-a5b8-c1f5b931a3de	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/del}	5	f	f	dispatchapi_DelServerIp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c5a0bc9b-1a58-4f27-83f9-5d5bee351d51	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	dispatchapi_GetServerIpInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d6a295a-156c-4d2e-9934-ebeb5c41c39a	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/list}	5	f	f	dispatchapi_GetServerIpList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e365185-0468-4fb1-828c-0ddfc5bb7c12	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/del}	5	f	f	dispatchapi_DelServer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
518dd5f1-4d6b-46fe-b8bc-d9e3c43ab631	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/update}	5	f	f	dispatchapi_UpdateServerIp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d179129d-ec97-4694-8b6c-182150715bd5	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/serverIp/add_to_dispatch}	5	f	f	dispatchapi_addServerIpToDispatch	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0f27551b-8f58-4a66-8541-d4fd8dda4cc7	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/del}	5	f	f	dispatchapi_DelIdcHouse	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e298b15-0153-4ba7-bcdd-33098b0424c4	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf.rules"}	5	f	f	apiv4_getCloudWafRuleList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c295e6cc-90a8-4c31-86b0-d5431336d753	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackIpTimes}	5	f	f	apiv4_getWafAttackIpTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0988ca92-c7df-4dca-93ea-02cb68ea4e73	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTIpAssociationInfo}	5	f	f	apiv4_getWafAPTIpAssociationInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a658ac10-bc33-47ca-897d-38fb77dc4063	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/serverIp/info}	5	f	f	dispatchapi_GetServerInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a2daace9-e6b5-42c5-b1ea-52321675dada	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/server/list}	5	f	f	dispatchapi_GetServerList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a71293c-1c3e-4607-afa5-364d487dddc1	2019-06-18 11:00:48+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/server/update}	5	f	f	dispatchapi_UpdateServer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5eb60755-05f3-4be2-b92c-28d26348ba45	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{POST}	{}	{/v1/idc_house/add}	5	f	f	dispatchapi_AddIdcHouse	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
20401f49-4d43-4b26-a511-d024bf0b1c62	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.scan.task.add}	5	f	f	apiv4_PostShieldScanTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9babf575-86fe-4bac-804f-d3f8e66daf32	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.package.list}	5	f	f	apiv4_getHwwsPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c99bab5b-4b43-4e67-bbdf-de5b1a75bbf0	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/region/get}	5	f	f	dispatchapi_GetRegion	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
45965659-94f2-4794-9136-0b97da82d90b	2019-06-18 11:00:47+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/asset}	0	t	f	dispatchapi_uripre_asset	\N	\N	\N	\N	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8d80a602-0133-43d1-a2ec-bc567cbe79e7	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/shield.risk.setting.content.save}	5	f	f	apiv4_PutShieldRiskSettingContentSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9310a8e2-3f92-4ffb-9870-29523e869522	2020-04-19 22:19:39+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag/list}	5	f	f	service_tag_TagList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e01ec901-d969-4ce3-86ae-eab2cc6d7941	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/cloudsafe.hwws.package.update}	5	f	f	apiv4_updatePackageName	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
99e11fa5-fa5e-40f3-92fb-17dd3bedf71e	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/smgc.property.get.token}	5	f	f	apiv4_ScanObserveProperty_getPropertyToken	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
19ec0028-53fa-443b-b0e1-60557fe27c18	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.mobile_jump"}	5	f	f	apiv4_WebCdnDomainSetting_get_mobile_jump	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d8bcb0d-c961-438f-a265-81f64111c2d4	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_ddos"}	5	f	f	apiv4_WebCdnDomainSetting_put_anti_ddos	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e3c580a9-3570-4b2f-87d2-5a964f851c7c	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.back_source_host"}	5	f	f	apiv4_WebCdnDomainSetting_put_back_source_host	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd54ea2c-49b4-453b-8485-585aa74544c8	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTIpAttackLink}	5	f	f	apiv4_getWafAPTIpAttackLink	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5cac65e8-7a44-4c1d-8573-a7b09320839a	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudsafe.hwws.package.unbind.domain}	5	f	f	apiv4_unBindDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ff78ed65-cd45-4796-9234-ddbd5eaa8bee	2019-06-27 16:46:45+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.getcustomerlist}	5	f	f	apiv4_PostCustomerManageGetcustomerlist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa3dc7af-930e-4e56-be7e-a927042c35d2	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.recreateprice}	5	f	f	apiv4_Order_reCreatePrice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b01842a3-7575-418c-83fa-f3caaff4b989	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/records/save}	5	f	f	service_dns_AdminDnsRecords_recordsSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa2018a8-220a-4191-8e40-034026161b9a	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/domains/add}	5	f	f	service_dns_AdminDnsDomain_domainsAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
39ef7c24-a9bd-4a99-89fb-df54dbc6f644	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{POST}	{}	{/records/add}	5	f	f	service_dns_AdminDnsRecords_recordsAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28cf816b-9070-4b1e-b120-17d796c58288	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/records/list}	5	f	f	service_dns_AdminDnsRecords_recordsList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6bb5a3d0-0148-4087-badf-f7bd2edeba9b	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.alert.list}	5	f	f	apiv4_CloudMonitor_alertList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e64b93e9-655c-4f1b-b700-befef4dc3f91	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/buy.riskDetection.products}	5	f	f	apiv4_Get_postBuyRiskdetectionProducts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1a807145-e336-44cf-9c46-344699c1e18f	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.records}	5	f	f	apiv4_CloudMonitor_linkageRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d12440b-a47c-4771-8da9-a1507443c3ba	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{GET}	{}	{/records/info}	5	f	f	service_dns_AdminDnsRecords_recordsInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
52f61089-a066-4682-a2fd-c246777bd9de	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.billmonthdetail}	5	f	f	apiv4_PostOrderBillmonthdetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e737bd46-c5df-4000-afec-2b41f4963bf9	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTIpList}	5	f	f	apiv4_getWafAPTIpList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9f929811-efbc-4bae-86c8-c5975a1785b1	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.package.all}	5	f	f	apiv4_GetTjkdPlusPackageAll	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5785edc9-38ff-41fa-b88b-bedfeacb743e	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.add}	5	f	f	apiv4_CloudMonitor_monitorTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bf27730e-8449-41b7-8924-5522306834bf	2019-12-18 16:18:28+08	2020-04-06 21:04:45+08	25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	{http,https}	{DELETE}	{}	{/records/batch_del}	5	f	f	service_dns_AdminDnsRecords_recordsBatchDel	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ee28edd7-edd8-425d-b247-b6c1ae420e93	2019-08-22 16:47:20+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/firewall.policyGroup.get_domainid}	5	f	f	apiv4_GetFirewallPolicygroupGet_domainid	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1511b364-e503-4afc-97b9-505b88dd8bb1	2019-06-27 16:46:46+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.add.subUserGroup}	5	f	f	apiv4_PostPermissionAddSubusergroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
978a8f37-4a35-4818-8568-bb4bd28d89a8	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.billmonthconfirm}	5	f	f	apiv4_PostOrderBillmonthconfirm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5873917e-7b17-4aa7-8788-777a4d11000c	2019-06-27 16:46:46+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/private.node.related.add}	5	f	f	apiv4_PostPrivateNodeRelatedAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5486aa39-dc28-4d43-8e6b-b544d9e6ea76	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.list}	5	f	f	apiv4_CloudMonitor_monitorTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bbd7bb3e-7f83-4626-a19c-79da2863bdf6	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.plus.package.list}	5	f	f	apiv4_GetTjkdPlusPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
886d9886-d1d9-4f47-98ee-4cf31be690c2	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.billmonthlist}	5	f	f	apiv4_PostOrderBillmonthlist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8b5a9e8b-f78a-4793-a222-cce6589f8605	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.billdaydetail}	5	f	f	apiv4_PostOrderCdnBilldaydetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
387897a1-28d9-421d-95b2-2b7b76c19b1e	2019-06-27 16:46:45+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.billdaylist}	5	f	f	apiv4_PostOrderCdnBilldaylist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
940f8869-0546-4b86-a98d-51a3a96d7e1b	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_gzip"}	5	f	f	apiv4_WebCdnDomainSetting_get_page_gzip	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ad23a7e5-fadc-477c-9066-b3e13f072c29	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafscanlogsDetail}	5	f	f	apiv4_getScanEventLogsDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6207631b-b8a2-49be-8eb1-85491b450f59	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTVisitLine}	5	f	f	apiv4_getWafAPTVisitLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
779621f5-d294-4821-9872-df49106095f2	2019-06-08 18:18:44+08	2019-06-09 11:00:32+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/tjkd.app.package.list}	5	t	f	GetTjkdAppPackageList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
780b5ac8-e304-4da2-ab25-b52a5a406e43	2019-06-27 16:46:28+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/smgc.property.name.change}	5	f	f	apiv4_Controller_Api_V4_ScanObserve_ScanObserveProperty_changePropertyName	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
594f7fe9-58dc-426f-bcf5-9c7eaffb83ee	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_detailSettingsRuleWebHoneypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f9595b42-2290-4813-9fe0-227cd5b8193c	2019-06-27 16:46:42+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAPTHackerPortraitAttackNameTop10}	5	f	f	apiv4_getWafAPTHackerPortraitAttackNameTop10	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
198e3ceb-22e2-469c-bbdd-f37cde3927a5	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.open}	5	f	f	apiv4_CloudMonitor_monitorTaskInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3cee3513-20be-4378-83ab-aa8acaf5dfad	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.open}	5	f	f	apiv4_CloudMonitor_monitorTaskOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
576ac97d-9c6b-4d30-bfad-a3114ce0a9f1	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.Web.Domain.nodes}	5	f	f	apiv4_getTjkdWebDomainNodes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
675e9887-3545-4b9b-a3f6-119cb371f8c4	2019-08-22 16:47:21+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policyGroup.delete}	5	f	f	apiv4_PostFirewallPolicygroupDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bf46625d-6f77-44be-a28d-3e9623d71392	2019-06-28 16:09:57+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.permissionModuleNames}	5	f	f	apiv4_GetPermissionGetPermissionmodulenames	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
871c8eee-11eb-4184-b639-e884eab1a514	2020-10-29 18:56:02+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/line_group/bind}	5	f	f	service_disp_Ip_bindLineGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
33165496-b38b-4af5-b654-29419d044188	2020-11-11 09:59:04+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/policy/ip/select}	5	f	f	service_disp_DispPolicyIpSelect	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9ca810d7-8eb4-4bbf-81fe-8ff08ba4f181	2020-04-19 22:19:40+08	2021-01-01 21:36:21+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{POST}	{}	{/tag_type/save}	5	f	f	service_tag_TagTypeSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a68f677e-0446-4c30-bede-7aba68a5550e	2020-11-11 09:59:04+08	2021-01-01 21:36:25+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/ip/select}	5	f	f	service_disp_IpPoolIpSelect	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ce7e4828-23ed-46f8-8aea-5a8088f7b612	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.app.access.group.all.list}	5	f	f	apiv4_ZeroTrustAccessGroup_getAllGroups	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5851f1cf-fb67-488f-8317-a0379b736c85	2020-04-19 22:19:54+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag/tree}	5	f	f	service_tag_TagTree	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
367c4abb-dd3e-4904-ad8d-8a417523c9a2	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.alertSetting.info}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorAlert_getAlertSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b91f4f1c-da7f-49a8-bdde-a435afd2247b	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.monitor.alertSetting.save}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorAlert_saveAlertSetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
00e6ecc0-793e-4cdd-b4f0-b2dfaf58f8cc	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.event.list}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorEvent_monitorEventList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
96497fb4-e52a-4656-b002-7618e64d9c58	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.add}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b4d8ed61-bbe4-4309-877b-674a294468e6	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.delete}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1318a709-42d6-448c-ae18-4a537c8c7904	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.disable}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskDisable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
542174be-6a4c-465c-95db-d0581682883a	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.enable}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskEnable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fe2065ad-c48e-4055-aec3-06864869d04f	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.info}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e717552a-3c0c-4ac0-b5ba-bb724ca4e65c	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.list}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
247dff71-19de-4218-abe7-f808a22f0ffe	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.monitor.task.save}	5	f	f	apiv4_Controller_Api_V4_CloudMonitorNew_MonitorTask_monitorTaskSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
07d9b689-c8f8-4ce1-af69-b7affaa27f57	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.delay.avg}	5	f	f	apiv4_Controller_Api_V4_StatReport_Monitor_MonitorTaskStat_getDelayAvgLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
279267bc-e16b-435e-9393-e0ee569a7ac5	2019-06-29 14:18:27+08	2019-07-01 12:06:21+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.monitor.task.availability.line}	5	f	f	apiv4_Controller_Api_V4_StatReport_Monitor_MonitorTaskStat_getTaskAvailabilityLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3ac02802-00e2-4657-a9e3-6d3f80f23c46	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Domain.Dispatch.domainTask.add}	5	f	f	apiv4_Controller_Api_V4_Dispatch_domainDispatchTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b1516975-3a42-4bb7-8348-15ebd6ac91ff	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.del}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_delGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6729cd82-0c7b-4de2-be31-533870e20c2c	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.all.list}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_getAllGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7c1332b0-c8bd-4962-95a4-2dca63ca60a0	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.domain.list}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_getGroupDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f88c4190-7c89-4d3e-87ca-1e32da1df6ba	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.info}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_getGroupInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c586f66d-f74d-4200-bb5d-f3dc6f790a28	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.list}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_getGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cc43615a-a998-4cb8-836c-7c87a0514ff7	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.domain.save}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_saveDomainToGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
930c624a-f276-46ac-a83c-de1b64660d4d	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.save}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_saveGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4c4e31a2-cc0b-4c23-85f2-dd0abba3dca9	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getPdfReportList}	5	f	f	apiv4_Controller_Api_V4_member_report_getPdfReportList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5487daf9-0ae1-49fe-9541-f5ef98f78429	2020-04-19 21:29:38+08	2020-04-19 22:22:05+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/attackEvent/query}	5	f	f	ads_queryUsingPOST11	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
11f16f24-73fe-4ba0-a39e-78818cb208d7	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.ip.visit.data}	5	f	f	apiv4_Get_postStatisticTjkdAppIpVisitData	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
101fda53-0514-4df5-b99a-ba4f57be779e	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/permission.edit.subUserStatus}	5	f	f	apiv4_PutPermissionEditSubuserstatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7242bec-928d-472a-8eb5-3c8830e8c07e	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.save}	5	f	f	apiv4_CloudMonitor_monitorTaskSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f6e94ab1-460c-47b0-85fa-af75094f3af7	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.package.domain.list}	5	f	f	apiv4_Get_postTjkdPlusPackageDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bbe52c6b-527f-4c77-b00b-a2e4ae5ea409	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/tjkd.plus.package.info}	5	f	f	apiv4_Get_postTjkdPlusPackageInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b700e7a7-949e-40f3-ac8e-20e0ea345802	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.records}	5	f	f	apiv4_CloudMonitor_taskRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a444ca74-8601-4581-833d-1f730df1804e	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist"}	5	f	f	apiv4_WebCdnDomainSetting_get_visit_limit_blacklist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f201508a-e641-4411-9596-13ad209d0091	2020-04-19 21:29:42+08	2020-04-19 22:22:05+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/clusterStatus/queryCluster}	5	f	f	ads_clusterUsingPOST7	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b42f14b-db50-452d-a64e-9a236bb47679	2020-04-19 21:29:40+08	2020-04-19 22:22:06+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/pcap/execute/}	5	f	f	ads_executeUsingPOST55	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
61a105e9-9a96-41d8-b062-e73573ff2fa4	2019-06-27 16:46:47+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.new}	5	f	f	apiv4_PostSendnoticeNew	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d2af19b7-6e36-4ce8-b37a-3887c937b71b	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.whole.report.token}	5	f	f	apiv4_WholeNetMap_getReportTokenByMemberId	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e663dd87-7487-4027-b067-38432a197cd9	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/V4/log.download.add}	5	f	f	apiv4_PostV4LogDownloadAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dbd22ae2-da5e-4739-a27e-7553dd707362	2019-06-27 16:46:46+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/private.node.related.del}	5	f	f	apiv4_PostPrivateNodeRelatedDel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7a92822-1876-429e-abaa-81901d4d0092	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_modify"}	5	f	f	apiv4_WebCdnDomainSetting_get_anti_modify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dbb9b81a-a326-4790-a972-3a43e630dd20	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/permission.edit.subUserGroup}	5	f	f	apiv4_PutPermissionEditSubusergroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
41982c9c-98f0-465d-bed7-67e59942617e	2020-04-19 21:29:41+08	2020-04-19 22:22:06+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/analyzeAgentDevice/queryLoad}	5	f	f	ads_queryLoadUsingPOST	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48fb138c-2fad-4d08-b851-7b7d778c8e83	2019-06-27 16:46:47+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/private.node.remarks.save}	5	f	f	apiv4_PostPrivateNodeRemarksSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62e08268-0cd9-485f-8b5c-541089288e8f	2019-06-27 16:46:46+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.open}	5	f	f	apiv4_PostOrderCdnOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8111a1bc-cce4-4d14-af40-dcca66babbe7	2019-06-27 16:46:46+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.updatetemplate}	5	f	f	apiv4_PostOrderCdnUpdatetemplate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eb42866c-acf0-4f37-99ba-b10c42d34a64	2019-06-27 16:46:47+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/firewall.member.transfer}	5	f	f	apiv4_GetFirewallMemberTransfer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7c5cbf64-8870-4dba-b90b-350b5cf82a3a	2020-04-19 21:29:42+08	2020-04-19 22:22:07+08	659daf51-d0e8-46b3-8867-f6c4051582c7	{http,https}	{POST}	{}	{/v1/admin/device/saveApi}	5	f	f	ads_saveApiUsingPOST23	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78f9fd24-4134-4319-a6ae-ce58e49ec181	2020-11-11 09:59:03+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/distribute/list}	5	f	f	service_disp_IpDistributeList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cdd8a946-b664-4fc4-b271-55c79a00a220	2020-03-13 17:44:35+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/share_data.region}	5	f	f	apiv4_ShareData_ipRegion	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bbab429b-a4d3-4233-9288-d9d5b755d4d6	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.save}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_saveGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d0230b5a-01f1-4782-bfb5-7a80a9c793c7	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/url}	5	f	f	apiv4_Controller_Api_Common_CloudMonitor_NewCloudMonitorCallBack	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3968cda6-64e1-4119-bb70-0ba8a097189b	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.back_source_host"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsBack_source_host	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
447c2710-0711-4fe1-aa44-adc0b2d1bad8	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.back_source_host"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsBack_source_host	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
93536bee-c37c-4c6a-9be7-27603ac5f3b6	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.slice"}	5	f	f	apiv4_get_domain_backsource_slice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b1da6e59-bb0c-4874-b417-62ab71ecdb38	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_404"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsDiy_page_404	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
63e524b2-b04a-42c9-84da-22d4635130fb	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_500"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsDiy_page_500	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
02313945-c6d7-4c13-8c1e-5f76a8fa653c	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_502_or_504"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsDiy_page_502_or_504	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ad11b466-30cb-4b6c-a2dd-9bb1e66a4595	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_404"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsDiy_page_404	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
90e32cef-d7be-4ead-9858-13d391a911ac	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_500"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsDiy_page_500	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
834910e2-72c6-4f55-ae67-45ddc7d4d662	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.diy_page_502_or_504"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsDiy_page_502_or_504	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c61e9c99-fbe2-46a5-a9b4-a841a2eea60e	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.domain.info}	5	f	f	apiv4_Controller_Api_V4_CloudSafe_Hwws_Domain_getDomainInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8c19124c-4fbc-4eb6-883c-d0d69e992218	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_modify"}	5	f	f	apiv4_get_hwws_anti_modify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8d2cb62f-d782-425e-b98d-09bd966a5cb9	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf"}	5	f	f	apiv4_get_hwws_cloud_waf	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b36ca39-4092-4ad0-af24-98b045a441c9	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.content_replace"}	5	f	f	apiv4_get_hwws_content_replace	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ee5e12a5-40c3-4c8f-9bfb-841c1bf2fdc1	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.del}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_delGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
58f1ad3b-0128-4bf8-8e5b-c2615ec32cd8	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.all.list}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_getAllGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c0da4c3-ecd3-49dc-a81c-a0bf074bc6fe	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.domain.list}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_getGroupDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b234a034-28ac-4862-9c66-c0be82c74496	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.info}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_getGroupInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
26e86ca3-8250-4c76-a8c9-5366bcd9d238	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.list}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_getGroupList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d3b1bb1-1003-4261-901d-41e630328e2e	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.domain.save}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_saveDomainToGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1879a058-c910-46a8-b16f-2ee023011c79	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.https"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsHttps	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
364b6b15-ccc4-45ad-9186-40a3523d7e6a	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsVisit_limit_blacklist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c4c3028-2d67-4c4f-8e31-dbc948bc1c88	2019-06-08 18:18:55+08	2019-06-09 11:00:42+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/statistic.tai.cc.top.province}	5	t	f	getTopProvinceStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dc611d4b-b42c-4b8e-9529-ca4eacda69cc	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsWebsocket	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
699d9971-f248-4055-ae29-0172d8cc3143	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.zone_limit"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsZone_limit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
103cb5ec-9d7e-4ba7-a7f9-9498d270eae6	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAnti_cc	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
236d130f-3bc2-4815-8cc1-79dc26290c3b	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_ddos"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAnti_ddos	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0ae54239-7600-46da-a04b-628e377cb127	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_refer"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAnti_refer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7c2d7ca4-875f-4b49-bb95-77a068ff3250	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_ids"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsCloud_ids	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e5deb535-2ada-413c-8ec6-27560593438c	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.hsts"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsHsts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
63f62256-4185-4310-b222-09194f6bda30	2019-06-08 18:18:55+08	2019-06-09 11:00:42+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/statistic.tai.cc.top}	5	t	f	getTopStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
11cbe4db-8a8d-4959-82c9-173fb4ee1ef1	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.https"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsHttps	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8a4f9d4e-3066-4691-babb-c62ec7af73df	2019-06-08 18:18:55+08	2019-06-09 11:00:42+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/statistic.tai.cc.top.country}	5	t	f	getTopCountryStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27b1903f-e8ec-417c-83e2-dd9f5f16a359	2019-06-08 18:18:54+08	2019-06-09 11:00:41+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/statistic.tai.cc.line}	5	t	f	getCcLineStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6aae56c9-2548-4401-86d2-a492fbaae60c	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_ddos"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAnti_ddos	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
66056641-2161-4c59-a656-7cd39edb99cc	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.Label.Tai.del}	5	f	f	apiv4_Controller_Api_V4_WebCdnProtection_Domain_labelDelTai	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
14c406f7-bd78-47a0-a5d4-0f08fa48e52d	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAnti_cc	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2d4a95d7-09db-4c5e-bd92-ebe435ecea21	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_refer"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAnti_refer	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
46305c3b-e014-45b5-9845-266d72367291	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_ids"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsCloud_ids	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69960c5d-d5ab-4bcf-8bc2-135910bbebe4	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.hsts"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsHsts	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c63b9651-fab7-4cf5-aa17-12a1d8a16dbc	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsWebsocket	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d8abc758-c431-4719-8382-f6d09aca9233	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_auto_dynamic_static_separation"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsPage_auto_dynamic_static_separation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c65dca51-cb27-4132-83f2-7bddd4942049	2019-06-27 16:47:03+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.batchDelete}	5	f	f	apiv4_batchDeleteDnsDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
24ee8492-09b2-40f6-ad33-6ec366078997	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.zone_limit"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsZone_limit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c12ae231-0d54-44bd-9c5a-286c13daf114	2019-06-27 16:47:03+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.delAlias}	5	f	f	apiv4_delDnsDomainAlias	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7b864590-19fd-49ad-bc49-3212ad2fda44	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsVisit_limit_blacklist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
983a01a0-421e-42cf-acf1-dc5472aa7144	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/finance.order.pay}	5	f	f	apiv4_PutFinanceOrderPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1cfb7920-593c-4783-a541-c139e90c2280	2019-06-27 16:46:56+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.changemessagestatus}	5	f	f	apiv4_PutMessagecenterChangemessagestatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f8574c6-cf8b-47fe-9aa5-72e8f1c3aaa7	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.tcp.cc.Country.top}	5	f	f	apiv4_Get_postStatisticTjkdAppTcpCcCountryTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0e8bc7f8-fb2e-49cb-ab88-1925a8b8dc26	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.detail}	5	f	f	apiv4_order_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e52cc709-ee4d-4efb-a7ac-cb8c6bdda229	2019-06-27 16:46:56+08	2019-12-26 10:49:00+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/messagecenter.center.usableSmsNumber}	5	f	f	apiv4_PutMessagecenterCenterUsablesmsnumber	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c67e4e4-359d-48e8-b39d-5ae982af329d	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_gzip"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsPage_gzip	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
02d54710-6c16-459f-a012-f6b65346b61b	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_optimization"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsPage_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3475a211-9300-4116-9943-f23e28c3c9a2	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.DomainId.Settings.setCacheOrder}	5	f	f	apiv4_Web_Domain_Region	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8c9bee12-3a1f-46d0-ad36-3ffc6411f5fc	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.ajax_load"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAjax_load	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9f24c4db-3ea9-4b1d-a93e-a88332450522	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.all_view_optimization"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAll_view_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5dc8f70d-6a05-48dc-aff0-b07a6dfd642f	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.always_online"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsAlways_online	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
68dad324-6de7-4081-a68d-e45d78d22835	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.browser_cache"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsBrowser_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
df948099-4523-4c5d-b70f-67d804d2548c	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsCdn_advance_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e775281b-445f-432c-9e3d-22e8a2746613	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.mobile_jump"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsMobile_jump	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
36f29636-1822-499c-b6a1-ead8f88552f6	2020-09-09 17:47:34+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/cdn/admin}	1	t	f	service_cdn_uripre_agw_cdn_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9e1221ea-ad8e-4cca-8c9c-a4d0b019cf01	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.always_online"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAlways_online	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d5be914-4e8d-40ca-93d3-788fed24a75a	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_auto_dynamic_static_separation"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsPage_auto_dynamic_static_separation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4c3d23bc-c31f-4270-90a9-14bf5a3b8f19	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.WebP"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsWebp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64cf1051-7c9e-4f94-a5fe-3ed718f0c9c8	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.search_engine_optimization"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsSearch_engine_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2672cef0-a223-4da9-9002-9aa7db75a7f1	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.delete}	5	f	f	apiv4_deleteDnsDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
851b90b6-6aff-4c95-b6d3-12be772de1cf	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_gzip"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsPage_gzip	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
53ae87c8-e42b-4273-babb-47065cbb7b62	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_optimization"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsPage_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d7bed1d-ea55-44d8-beb6-bc33d226a54c	2019-06-29 14:18:29+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.search_engine_optimization"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsSearch_engine_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d85e71b6-8c2d-4d68-bce0-ef3626eee792	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.tcp.cc.line}	5	f	f	apiv4_Get_postStatisticTjkdAppTcpCcLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
269e0828-9205-4e63-b31c-9ee8972c5b4e	2019-06-27 16:46:36+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.detailLine}	5	f	f	apiv4_Get_postStatisticTjkdPlusDdosDetailline	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7012529-7a9b-46c6-b04b-022151252f8e	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.WebP"}	5	f	f	apiv4_GetWebDomainDomainidDomain_idSettingsWebp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
04533be1-3e6e-42e2-ae7e-43136dd7731c	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.ajax_load"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAjax_load	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
18b0b748-3b16-46bf-a892-a02cd579a68a	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.all_view_optimization"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsAll_view_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
29b789a8-fed5-463a-a7fe-f45e1e2ac7fb	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.browser_cache"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsBrowser_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
71e1c68f-cba3-4ed1-843c-e60f0c8bda91	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsCdn_advance_cache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9ef125b2-a353-455b-98f1-7ce197c76e5a	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.mobile_jump"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsMobile_jump	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4f2e5b2d-19f2-477d-b1f5-808352819646	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.tcp.cc.Province.top}	5	f	f	apiv4_Get_postStatisticTjkdAppTcpCcProvinceTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28b3fd33-2f25-45ca-ab63-49eaf8796bc6	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.tcp.conversation.line}	5	f	f	apiv4_Get_postStatisticTjkdAppTcpConversationLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
53cfc582-0a98-4845-b1a8-bd4db2d87de2	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.tcp.cc.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusTcpCcTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
807bde4c-bf87-4d9f-b97a-f4f337f20189	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.web.cc.Country.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusWebCcCountryTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
502002c2-d6f2-443b-8a65-5b2f98c866d4	2019-06-27 16:47:09+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.down}	5	f	f	apiv4_order_down	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
799dd6cc-e771-4e0d-abf4-5b2d11460840	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.waf_block_diy_page"}	5	f	f	apiv4_update_hwws_waf_block_diy_page	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f608294a-5cef-49ba-be63-fd1a852d0f00	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot"}	5	f	f	apiv4_update_hwws_web_honeypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8f720e3e-819f-4591-94f1-af0844d95231	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.linkage.log}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_MonitorStats_linkageLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
14d753f2-c3fc-47c8-a053-fccd43e9243b	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.availability}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_MonitorStats_statsAvailability	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
47a14649-1f86-46da-960b-2033fcc170f3	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.stats.failurerate}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_MonitorStats_statsFailureRate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
88c8d43c-d6d1-4a3a-9c64-8c558f2808ac	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.alert.info}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_alertInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
997bff82-c020-4fde-a0cb-949577f4e7f3	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.alert.list}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_alertList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ef889763-0389-4a0b-81ba-a0d3762bb81c	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.alertSetting.info}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_alertSettingInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
99ec87ae-8f27-4617-806d-2573ec078dbd	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.alertSetting.save}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_alertSettingSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7ae3d92-3917-4f22-81cf-7a3c71e2b782	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudmonitor.package.overview}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_getPackageOverview	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3620a74b-e5c0-476b-a478-1f7be342b3bf	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.info}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_linkageInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2872c9c4-bd6b-487a-926f-b9e1604ed883	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.records}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_linkageRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
697f930b-c05a-4c12-b7b6-1e6600d40850	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.linkage.save}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_linkageSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9201e1e5-703c-4f4d-a3ae-73852b458ec0	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.add}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
83b21ca4-ae23-4bc1-8d67-97ecd673cc86	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.delete}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ece5e513-1876-4a20-8479-0276ecb41b1d	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.open}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7094f1d-d05b-4b36-8a0f-2fdc8ca8eacb	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.waf_block_diy_page"}	5	f	f	apiv4_get_hwws_waf_block_diy_page	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
024c8996-f616-4705-b376-5844f0697fd5	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot"}	5	f	f	apiv4_get_hwws_web_honeypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c2ef9819-5d6e-4817-9791-eac424e080f1	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_modify"}	5	f	f	apiv4_update_hwws_anti_modify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
10a300ed-1572-4839-8bfd-d4022afd2838	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf"}	5	f	f	apiv4_update_hwws_cloud_waf	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ae13b70d-1ee8-4477-94af-00252364fc3f	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.content_replace"}	5	f	f	apiv4_update_hwws_content_replace	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0faf2120-6f7e-4bfe-aa33-8d9bc11c11d6	2019-06-29 14:18:30+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.safe_snap"}	5	f	f	apiv4_update_hwws_safe_snap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
79eb42b4-9071-4608-8351-fc7ad5fbaa55	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.cloudmonitor.monitor.resume}	5	f	f	apiv4_Controller_Api_Common_CloudMonitor_monitorResume	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48c2c8d1-d2ac-4d56-ae70-055d4c8e7e31	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchAdd}	5	f	f	apiv4_batchAddRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d330812-3e46-4d58-b5e0-8d24eee79276	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchDelete}	5	f	f	apiv4_batchDeleteRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3dc9d6f0-e266-4677-b49c-6c59b1880c2a	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchImport}	5	f	f	apiv4_batchImportRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
49219eda-6578-454b-92ca-7dc2941525ff	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchOpen}	5	f	f	apiv4_batchOpenRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80f871b7-b925-4be2-9c9c-63d20dba2c97	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchPause}	5	f	f	apiv4_batchPauseRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
97534429-2224-4407-a173-93cd7e43417f	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.delete}	5	f	f	apiv4_deleteRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62621577-5c12-4af0-b1c7-7ee209b58a3c	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.edit.remark}	5	f	f	apiv4_editRecordRemark	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1accc356-b8c8-4519-8333-e6bd166f2605	2019-06-29 14:18:30+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.getDomainDns}	5	f	f	apiv4_getDomainDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c188e2ef-40a1-4fb1-8035-2f9e2c34d033	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.batchDetail}	5	f	f	apiv4_getRecordBatchDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9cba7fbc-9a8f-4521-a6cb-9837472cb2c8	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.batchDomainList}	5	f	f	apiv4_getRecordBatchDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4f99acca-68c2-4b8b-9323-4ce48aa962bb	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.batchList}	5	f	f	apiv4_getRecordBatchList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
38ca128c-8661-4359-bdba-c546dc32e204	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.list}	5	f	f	apiv4_getRecordList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
88d34e25-29c7-42a1-b27c-d3e58c6c4cd6	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.list}	5	f	f	apiv4_getRecordTypes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
520a3289-7f67-408a-9d16-6149e5752bab	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.importRecord2CloudSpeed}	5	f	f	apiv4_importRecord2CloudSpeed	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da2746d9-ba8e-4fdd-9abd-0c362fb3b525	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.makeDomainDns}	5	f	f	apiv4_makeDomainDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a394e708-83bc-484f-9788-826095438702	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.open}	5	f	f	apiv4_openRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7a01f07-b567-4548-af6e-7369ee484909	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.pause}	5	f	f	apiv4_pauseRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3bf773c9-551a-444f-972d-5fce915cc3e2	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.open}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a42f39aa-cdf5-4064-9c4c-f2a9c5e5a5de	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.pause}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskPause	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8cfc14e5-5aae-4a20-95de-e35910a54987	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.save}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b6790f9f-7092-47aa-99a8-318661daa8dc	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.records}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_taskRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5fdfc889-bdd2-40ff-9db5-ee223526dcc7	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/common.cloudmonitor.task}	5	f	f	apiv4_Controller_Api_Common_CloudMonitor_getAllTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a095df96-3e05-480e-9aa8-bc7cddd12c67	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.cloudmonitor.monitor.down}	5	f	f	apiv4_Controller_Api_Common_CloudMonitor_monitorDown	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
46e27b65-25a6-4441-a1fd-939d90baac9d	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.receive.scan}	5	f	f	apiv4_Controller_Api_V4_memberReceiveScan	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d25ed9b6-402e-45d0-a42e-12ec7940ef89	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.count.list}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_getPropertyRiskCountList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9623cb04-958a-43f3-b1bd-3d5484550523	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.setting.info}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_getRiskSettingAllInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd99f29f-fd3b-4e26-bb28-3e2a89b45171	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.log.list}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_riskDetectionLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
741faecc-9bfa-427b-ada0-5f9e5204771d	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.risk.save.confirm.status}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_saveRiskLogConfirmStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b64d00e6-7427-4ced-bf72-f46ea8845c82	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/shield.risk.switch.act}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_switchRiskTaskByStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c5a65e7b-3621-4184-91ff-80d8fce72a5e	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.delete.task}	5	f	f	apiv4_Controller_Api_V4_NodeMonitor_deleteTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
99493ed1-d537-414e-afa9-f818cd1d3302	2019-06-29 14:18:36+08	2019-07-01 12:06:31+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.recreateprice}	5	f	f	apiv4_________	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80611dd7-227f-4abf-8d19-6b757faa508f	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.web.cc.line}	5	f	f	apiv4_Get_postStatisticTjkdPlusWebCcLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
866d8662-9117-4a04-8427-378aaa53134c	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/product.status.enable}	5	f	f	apiv4_Controller_Api_V4_Products_ProductStatus_enableProductStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
62b3c491-e91f-43a5-97a0-babea5a26c68	2019-06-29 14:18:31+08	2019-07-01 12:06:27+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/product.status.get}	5	f	f	apiv4_Controller_Api_V4_Products_ProductStatus_getProductStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b465915c-cfb6-4a79-8965-d8d26956e95f	2019-06-29 14:18:33+08	2019-07-01 12:06:28+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Tjkd.plus.protect.ip.firewall.info高防IP实时数据}	5	f	f	apiv4_Get_postTjkdPlusProtectIpFirewallInfoIp	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27f25952-f2cb-4913-892b-3642ab82e198	2019-06-29 14:18:33+08	2019-07-01 12:06:28+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.Web.op.log.add}	5	f	f	apiv4_Controller_Api_V4_Tjkd_Web_addTjkdWebOpLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1dbe47c2-8c2e-41b5-b921-1b84c3a57c44	2019-06-29 14:18:33+08	2019-07-01 12:06:28+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.Web.op.log.list}	5	f	f	apiv4_Controller_Api_V4_Tjkd_Web_getTjkdWebOpLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
193a391c-0535-4539-8564-047843e5f843	2019-06-29 14:18:33+08	2019-07-01 12:06:28+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.tjkd_web_import_url_protect"}	5	f	f	apiv4_PutWebDomainDomainidDomain_idSettingsTjkd_web_import_url_protect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3350507b-9db1-4659-8885-4e9b1b10fc32	2019-06-29 14:18:34+08	2019-07-01 12:06:29+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.whole.report.token}	5	f	f	apiv4_Controller_Api_V4_StatReport_WholeNetMap_getReportTokenByMemberId	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3799cc09-45e6-4e65-a849-9cd036eb1f72	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/shield.property.delete}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_deleteProperty	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
775efbdd-fb6f-494e-91af-61615b01b867	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.check.visit}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_checkDomainVisit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
99d825e9-8f1b-4437-bb6c-267c84553f4f	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/shield.risk.task.delete}	5	f	f	apiv4_Controller_Api_V4_ShieldEye_RiskDetection_deleteRiskTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
87f62a9f-535e-46ce-82f2-0fbc6740abf9	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.add.task}	5	f	f	apiv4_Controller_Api_V4_NodeMonitor_addTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e5f5fa30-adfc-42e5-9949-4251de15fb71	2019-06-29 14:18:35+08	2019-07-01 12:06:30+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/node.monitor.save.task}	5	f	f	apiv4_Controller_Api_V4_NodeMonitor_saveTask	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d9cb34d0-e2e9-41ff-a3c4-af9454eec5fd	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.page_auto_dynamic_static_separation"}	5	f	f	apiv4_WebCdnDomainSetting_get_page_auto_dynamic_static_separation	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f04bd0d-ea9c-499f-aa67-12429e0e88bf	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot"}	5	f	f	apiv4_WebCdnDomainSetting_get_web_honeypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e04d9fae-13c1-45d5-b944-bebd679c73fa	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.Web.op.log.add}	5	f	f	apiv4_Web_addTjkdWebOpLog	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a29da309-be9e-45f2-a4ba-35a43a8e33f6	2019-06-29 14:18:27+08	2019-07-01 12:06:20+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.add}	5	f	f	apiv4__Controller_Api_V4_CloudDns_DomainGroup_DomainGroup_addGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
59aaf5a0-de20-46cb-aef5-0ab4bc1befd7	2019-06-29 14:18:28+08	2019-07-01 12:06:22+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.add}	5	f	f	apiv4__Controller_Api_V4_WebCdnProtection_DomainGroup_DomainGroup_addGroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a435e1fa-0f79-476c-b311-fee4d81af0b0	2019-06-29 14:18:28+08	2019-07-01 12:06:23+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.Label.Tai.add}	5	f	f	apiv4_Controller_Api_V4_WebCdnProtection_Domain_labelAddTai	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8d21cec3-0d74-474a-a40e-954bacc995f8	2019-06-29 14:18:29+08	2019-07-01 12:06:25+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.safe_snap"}	5	f	f	apiv4_get_hwws_safe_snap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5ca44046-b5f9-4112-b63e-0bd8fa220fac	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.waf_block_diy_page"}	5	f	f	apiv4_WebCdnDomainSetting_get_waf_block_diy_page	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ff002135-782d-4888-bafd-ae68828c672d	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_editCloudWafRuleDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c0d6c28c-3fb4-4461-ab9d-99625e88aadf	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.web.cc.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusWebCcTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9a18b93f-e677-4da9-80a1-a455d96fb4c8	2019-06-27 16:47:00+08	2019-12-26 10:49:15+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainGroup.editDomainMap}	5	f	f	apiv4_editDomainMap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
08e54cfe-60c7-45a4-9cb7-2366ba7ba2a5	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Tjkd.Web.Domain.getexpiring}	5	f	f	apiv4_getTjkdWebExpiringDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9db01cc0-6bd0-416f-b81d-2918c19adb4b	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Tjkd.Web.Domain.protect}	5	f	f	apiv4_protectedTjkdWebDomain	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5669128e-7bc6-4d54-9067-34bbb9392a13	2019-06-27 16:46:38+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/statistic.tai.cc.top}	5	f	f	apiv4_getTopStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f4f727d1-1170-4f8d-89e8-9e1fec47f902	2019-06-27 16:46:39+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/customer.manage.getbasicconf}	5	f	f	apiv4_GetCustomerManageGetbasicconf	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
83512020-f97c-44b6-9716-107fbdfc9db2	2019-06-27 16:46:39+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/customer.manage.getrelationuserinfo}	5	f	f	apiv4_GetCustomerManageGetrelationuserinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
94a9418e-242f-4234-a9c1-2073ed86546d	2019-06-27 16:46:45+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.updatebasicinfo}	5	f	f	apiv4_PostCustomerManageUpdatebasicinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a4472b20-c299-4a02-80c4-bc2f64582cec	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/Member.getMemberMigrateTeam}	5	f	f	apiv4_getMemberMigrateTeam	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8853e00a-b76e-4666-b0e8-bd001696939c	2019-06-27 16:46:46+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.plan.billday}	5	f	f	apiv4_PostOrderPlanBillday	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ce3a2684-7c88-43a7-aa70-a96cd9cf7e1b	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Request.province}	5	f	f	apiv4_getTopProvince	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
76ca8902-c3ca-41df-8c8d-c20d4d2788b0	2019-06-27 16:47:09+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Visit.top}	5	f	f	apiv4_getVisitTopStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
937c421f-da5b-4753-9610-98d51df748a9	2019-08-31 16:54:15+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.sdk.package.block.details}	5	f	f	apiv4_Get_postFirewallReportSdkPackageBlockDetails	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
23d8463a-d9b6-4956-bc43-86e024c86acb	2020-09-09 17:47:34+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/cdn/console}	0	t	f	service_cdn_uripre_agw_cdn_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
599b9bcc-55a8-42ff-8337-74dd1cbc8c5c	2020-09-09 17:48:59+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET}	{}	{/domain/delete}	5	f	f	service_cdn_Domain_delete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3090c4ea-e16e-44a5-8a8a-307db959716f	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/bandwidth.const.list}	5	f	f	apiv4_getConstList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
20fa255a-2843-480d-8ca1-5200d74e04bc	2019-06-29 14:18:30+08	2019-07-01 12:06:26+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.list}	5	f	f	apiv4_Controller_Api_V4_CloudMonitor_monitorTaskList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
af464f08-6e87-4486-8da0-87968e511b1d	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.safe_snap"}	5	f	f	apiv4_WebCdnDomainSetting_get_safe_snap	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f9523ade-9a0d-48e4-acfd-8e545838cb4f	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/disp/console}	0	t	f	service_disp_uripre_agw_disp_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
386e3827-74c1-40f6-b0f4-2a870606c88a	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DomainLock.urlReSetUnLockPass}	5	f	f	apiv4_GetClouddnsDomainDomainlockUrlresetunlockpass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ba4d3171-3dab-4649-a066-ed73f1cf7735	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/s_disp}	0	t	f	service_disp_uripre_disp	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ccbcde6e-d2ef-49dd-8b16-81e98b0b09f5	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cloud_waf"}	5	f	f	apiv4_WebCdnDomainSetting_get_cloud_waf	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8e35ead4-69ca-47b9-af7f-84665479ab04	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.sendResetPassCode}	5	f	f	apiv4_PostClouddnsDomainDomainlockSendresetpasscode	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
84274195-6a39-48e7-abf8-5f52d4f25cba	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.reSetUnLockPass}	5	f	f	apiv4_PostClouddnsDomainDomainlockResetunlockpass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e88a2328-1edd-4e0f-a93f-a2a6c1afbdad	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.setUnLockPass}	5	f	f	apiv4_PostClouddnsDomainDomainlockSetunlockpass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
388d93ca-4ee8-4a10-8184-ed9e7b5d41a9	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainLogs.export}	5	f	f	apiv4_GetClouddnsDomainlogsExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cf9a5141-c011-4f99-a766-811ba40f1db0	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/bandwidthuser.operate.record}	5	f	f	apiv4_getUserRecordsList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c03fa5ae-fb2b-49d6-8f33-e0ac6b112495	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/bandwidthuser.operate.record}	5	f	f	apiv4_delUserRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cb14b0f1-0598-492f-a40e-74e85949e050	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.home.getsmsusablenum}	5	f	f	apiv4_Get_postMessagecenterHomeGetsmsusablenum	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69d10aec-7ec5-4416-8f3e-75c56f9fc1ec	2019-06-27 16:46:46+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.cdn.member.billday}	5	f	f	apiv4_PostOrderCdnMemberBillday	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
59955698-2475-4b60-a742-30ad5067779b	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/bandwidthhost.operate.record}	5	f	f	apiv4_getHostRecordsList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4480e323-5e7c-49f8-8585-67c86db97411	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policy.delete}	5	f	f	apiv4_PostFirewallPolicyDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
badddd14-f10d-466a-9b10-931c63ea06b8	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/bandwidth.operate.record}	5	f	f	apiv4_delRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e8e81ed-129e-42d1-b7ef-d91fadcd5c1b	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/bandwidth.operate.record}	5	f	f	apiv4_getRecordsList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9bbd29bf-efc2-4a2d-8334-86804ec103c3	2019-12-25 17:21:18+08	2020-04-10 10:51:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/tjkd.plus.package.save}	5	f	f	apiv4_Get_postTjkdPlusPackageSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
036ef6d9-a5e2-4482-b932-dbf0877c79d6	2019-06-27 16:46:41+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.content_replace"}	5	f	f	apiv4_WebCdnDomainSetting_get_content_replace	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
497611c8-0cca-451b-a593-36b05952e975	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/disp/admin}	0	t	f	service_disp_uripre_agw_disp_admin	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3934fc21-6305-46c7-ba75-72df14aa7738	2019-06-29 15:03:20+08	2019-07-02 11:22:30+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/idc_house/list}	5	f	f	dispatchapi_GetIdcHouseList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
559ddeab-cd9d-4034-a5c8-e85135ae50d3	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getcloudsafe}	5	f	f	apiv4_Get_postOverviewHomeGetcloudsafe	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3762b1ac-b769-4d22-a9bf-441fc9bc37d8	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getsmsandcdn}	5	f	f	apiv4_Get_postOverviewHomeGetsmsandcdn	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
54edd64d-9fbe-417e-8ecd-d4a290678999	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.gettjkdinfo}	5	f	f	apiv4_Get_postOverviewHomeGettjkdinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1045f54e-f6d0-4557-967a-90c9aadd44fb	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getUnread.message.number}	5	f	f	apiv4_Get_postOverviewHomeGetunreadMessageNumber	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a36eb4e9-8622-485f-ad58-85fe7df793d7	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getwebcdn}	5	f	f	apiv4_Get_postOverviewHomeGetwebcdn	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8a66a403-9f1e-4318-b1ab-a0939bf9d297	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/line/bind}	5	f	f	service_disp_IpBindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
06f47b2f-a7fd-4ae9-af64-0cc42027e015	2019-06-27 16:47:07+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Safe.cctop}	5	f	f	apiv4_getCcStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b984bbb9-da15-4cc2-9eea-de8089228575	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Traffic.domain.top}	5	f	f	apiv4_getDomainFlawTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ce6b10df-03bd-486e-abb9-8204b6f396e8	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/delete}	5	f	f	service_disp_IpDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
71ecac82-b558-4ea2-9db6-98e14aa3fcd4	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Visit.pv}	5	f	f	apiv4_getPvStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f526e06d-5170-458f-94bc-64bfca1ff793	2019-06-27 16:46:46+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.confirm}	5	f	f	apiv4_PostOrderConfirm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d7df6ac-c38b-47b8-8b8f-570675931b10	2019-12-30 16:20:44+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.package.bind.domain.list}	5	f	f	apiv4_getBindDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3fc9a103-865e-4e58-b513-b3f2e463fb20	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/tag/bind}	5	f	f	service_disp_IpBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6d02f5dc-ae9d-45c4-a7b7-f11a282e23b4	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/tag/clear}	5	f	f	service_disp_IpClearTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e36d674-e687-4bf5-9e20-5ed6548b8b26	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getbaseapplicationinfo}	5	f	f	apiv4_Get_postOverviewHomeGetbaseapplicationinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3c670964-cb36-48a4-9e08-e41225f0a695	2019-06-27 16:46:31+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/overview.home.getbigdata}	5	f	f	apiv4_Get_postOverviewHomeGetbigdata	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d1d79790-a631-41e8-b4c0-47542f9c47ac	2019-06-27 16:47:07+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Traffic.back}	5	f	f	apiv4_getBackStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da715b33-a883-4572-b032-3d54fc54c868	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/group/bind}	5	f	f	service_disp_IpBindGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
370df230-5770-4bde-9f73-8217bd96bd55	2019-12-30 16:20:44+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.package.canuse.domain.list}	5	f	f	apiv4_getCanUseDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
caf16dec-b730-444d-9665-8c0365ab7132	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/group/save}	5	f	f	service_disp_IpGroupSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a4b9309b-c609-48c7-abab-41f075b8ffa2	2020-01-08 17:28:33+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.get.preheat.cache.detail}	5	f	f	apiv4_GetWebDomainDashboardGetPreheatCacheDetail	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b0608eea-1098-420c-a1df-1d22b1c7443f	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/save}	5	f	f	service_disp_IpSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e5fc8bf0-996d-4b4b-8f88-893c35c27ee6	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/turn_status}	5	f	f	service_disp_IpTurnStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
43668246-8669-4fca-974c-134a89fbe6b5	2020-01-08 17:28:33+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.get.preheat.cache.list}	5	f	f	apiv4_GetWebDomainDashboardGetPreheatCacheList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3b705619-b63a-4c74-bed2-892a8196df07	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/group/unbind}	5	f	f	service_disp_IpUnbindGroup	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3269aaa3-024c-42ea-9eb7-45d7dfdc9df2	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/line/unbind}	5	f	f	service_disp_IpUnbindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e5e5bc29-178d-4ccc-860c-1dadadb42687	2019-06-27 16:46:24+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cdntpl.task.list}	5	f	f	apiv4_cdnplGetsJob	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a37dbc3c-c7b8-434b-9ec3-e4902f1c2c5a	2019-06-27 16:46:25+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dns.hijack.task.disable}	5	f	f	apiv4_DnsHijackTask_taskDisable	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9062ee1d-cb7f-43b9-837d-f25a51193019	2019-07-01 12:09:39+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.list}	5	f	f	apiv4_WebCdnDomain_getDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
77072076-8a4a-4051-8008-fc0ed365665c	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Traffic.backAndSpeed}	5	f	f	apiv4_getSpeedAndBackStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9ff3baf0-2c87-4e9b-838c-e9c2edcb87e6	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/tag/unbind}	5	f	f	service_disp_IpUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
706ac07c-299f-4a53-94b0-e88378184fbc	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/group/info}	5	f	f	service_disp_IpGroupInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
db750a9d-a861-4d8f-98df-73840a5cd68f	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/info}	5	f	f	service_disp_IpInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
97b60016-3f88-4dd6-87ed-d41a205b3a95	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/group/list}	5	f	f	service_disp_IpGroupList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d947caeb-a6bc-44bb-84fd-a0f7a73b5b5e	2020-05-19 22:03:30+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/list}	5	f	f	service_disp_IpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
25da8c2a-705d-4803-91f2-dec7546edf3e	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.retry_pay}	5	f	f	apiv4_Order_reTryPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28ff7df9-1bd3-4291-bace-6bcf3a7c6c12	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.formal_pay}	5	f	f	apiv4_Order_formalPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
243a1502-f164-40e4-98c1-e8a28f25c49b	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.ip.status.line}	5	f	f	apiv4_Get_postStatisticTjkdAppIpStatusLine	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64e42c36-0b80-4de9-9cf0-82245632d411	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.customerinfo}	5	f	f	apiv4_Order_customerInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
405c0fe6-ef48-4bea-bef3-5a84db061ee5	2019-06-27 16:46:32+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloudmonitor.task.delete}	5	f	f	apiv4_CloudMonitor_monitorTaskDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4523ab2b-8e22-42fa-9d2e-580f2feae3d0	2019-06-08 18:19:25+08	2019-06-09 11:01:09+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/finance.recharge.wxpay_checkpay}	5	t	f	WxPayCheck	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
68501eae-59c4-49c3-aac4-496b2039c7e0	2019-06-27 16:46:43+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Hwws.wafAttackNameTop10}	5	f	f	apiv4_getWafAttackNameTop10	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd0c561b-2583-4e78-9f33-ecd5af82cec1	2019-06-27 16:46:47+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/product.status.enable}	5	f	f	apiv4_ProductStatus_enableProductStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ea4e2ccf-5881-43f0-a0fe-ba748b41f54d	2019-06-27 16:46:37+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.web.cc.Province.top}	5	f	f	apiv4_Get_postStatisticTjkdPlusWebCcProvinceTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8a1fa4ed-2f89-4861-9a90-12005d1fc89d	2019-06-27 16:47:08+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Report.Traffic.speed}	5	f	f	apiv4_getSpeedStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
58b1e283-ba12-4f77-b0eb-a00151a8a208	2019-06-27 16:47:10+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/order.end_pay}	5	f	f	apiv4_order_endPay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c3fcc1be-0173-4c19-b85c-017772fb0854	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.start.times}	5	f	f	apiv4_Get_postStatisticTjkdAppStartTimes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
69e1f440-663c-4a17-bd5d-e80c0f0f0da2	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/agent/save}	5	f	f	service_disp_AgentSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cba1679d-28cc-41a8-a2f6-8aa7edd759b8	2019-07-16 16:47:42+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tjkd.app.domain.channel.source.batch.save}	5	f	f	apiv4_PostTjkdAppDomainChannelSourceBatchSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
acd9ad3f-ae02-43fd-aaff-c2f3ab9188eb	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.isp.top}	5	f	f	apiv4_Get_postStatisticTjkdAppIspTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
83c45a6e-97ea-4cd1-9900-b8b6c92dcde0	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_editSettingsRuleWebHoneypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5d090b37-d40a-4197-8871-db35f84c4258	2019-06-27 16:46:27+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.visit.avg.session.time}	5	f	f	apiv4_Get_postStatisticTjkdAppVisitAvgSessionTime	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b4681539-a70e-4425-97f9-2f289f19ca4d	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.batchDomainList}	5	f	f	apiv4_DnsDomainRecords_getRecordBatchDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d486fb54-69cc-4910-9757-6de1ce367bc9	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.retry_price}	5	f	f	apiv4_Order_reTryPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d8d53cd4-d04c-4a02-bff9-113ce630832b	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.delete}	5	f	f	apiv4_Get_postCrontabProcessDelete	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bfd2158e-e890-42dc-b88f-7f25cbeaf2af	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/agent/line/bind}	5	f	f	service_disp_AgentBindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
29c93480-29d9-4c39-b769-e8913d4b89da	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/agent/info}	5	f	f	service_disp_AgentInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e289f466-8726-4a73-8c9c-47f18d5aeb35	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/agent/list}	5	f	f	service_disp_AgentList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e04fd7b3-ebbc-4697-b4b3-bf4ec4a57110	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.unlock}	5	f	f	apiv4_PostClouddnsDomainDomainlockUnlock	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ed4297d-5bbe-4ab2-832e-d29221741486	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/V4/log.download.download}	5	f	f	apiv4_PostV4LogDownloadDownload	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e6a548a7-c971-4595-894e-747115b554e8	2019-06-27 16:46:49+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/WebCdn.logs.export}	5	f	f	apiv4_GetWebcdnLogsExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7dd7de99-414a-40f2-bc93-a9509705f884	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/shield.notice.member.list}	5	f	f	apiv4_GetShieldNoticeMemberList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
922d4f53-81cc-415e-aef8-ae4c510ef609	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecordsLogs.list}	5	f	f	apiv4_GetClouddnsDomainrecordslogsList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
76a81663-cf76-4920-bdec-3dfe1ecb4874	2019-06-27 16:46:49+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/WebCdn.logs.list}	5	f	f	apiv4_GetWebcdnLogsList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bfbc518e-1f87-4f52-a212-46406b585c92	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/shield.property.industry.list}	5	f	f	apiv4_GetShieldPropertyIndustryList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
041f912a-bd6a-4dee-99d0-a7360706ce5a	2019-06-27 16:46:27+08	2020-03-29 14:36:02+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.app.all.province.visit.top}	5	f	f	apiv4_Get_postStatisticTjkdAppAllProvinceVisitTop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
48308d2b-0778-4264-8832-a38cf766ae9a	2019-06-27 16:47:01+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_get_visit_limit_blacklist_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c25f7cfb-889f-4b56-a0a7-9e14e64bb0c8	2019-06-27 16:46:49+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.getCache}	5	f	f	apiv4_GetWebDomainDashboardGetcache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
edef1ef1-d996-4178-bb55-c936d3957942	2019-06-27 16:46:29+08	2020-03-29 14:36:03+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/finance.invoice.applyInfo}	5	f	f	apiv4_Get_postFinanceInvoiceApplyinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8bd7c812-72ee-4711-bfae-04a01e0efd0f	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/shield.risk.meal.list}	5	f	f	apiv4_GetShieldRiskMealList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7f77bb5d-9629-4020-b058-16669c207e86	2019-06-27 16:46:50+08	2020-03-29 14:36:08+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/site.friendlink}	5	f	f	apiv4_GetSiteFriendlink	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dbb4e973-6121-434c-a3a1-13dea8a24dd8	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.https"}	5	f	f	apiv4_WebCdnDomainSetting_get_https	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ea9c1137-17ec-4d5a-815a-178ca7fd8668	2019-06-27 16:46:49+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/Web.Domain.DashBoard.saveCache}	5	f	f	apiv4_PutWebDomainDashboardSavecache	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3456c6f2-baf9-4cbf-a2aa-2f701963501a	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/V4/log.download.list}	5	f	f	apiv4_GetV4LogDownloadList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
80e0b148-1406-4d16-90c8-ed52eeaaf563	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/recharge.baishan.balance}	5	f	f	apiv4_GetRechargeBaishanBalance	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
04277e7e-f44d-4fab-93d6-df8caf67cd6d	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.batchExport}	5	f	f	apiv4_PostClouddnsDomainDnsdomainBatchexport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2aa332f5-ef0d-4530-a841-5389ba9c2574	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/V4/log.download.update}	5	f	f	apiv4_PutV4LogDownloadUpdate	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2e82a606-81ac-477f-9a87-5d432b0d9831	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/V4/service.apply.detail.getUrl}	5	f	f	apiv4_GetV4ServiceApplyDetailGeturl	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f1c371d-7224-4b5c-9cc3-7ae9a87e1c60	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/V4/service.apply.detail.info}	5	f	f	apiv4_GetV4ServiceApplyDetailInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c288a4fa-bbdd-4626-bb49-7025b79f1a64	2019-06-27 16:46:49+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/member.report.getPdfReport报告}	5	f	f	apiv4_PostMemberReportGetpdfreport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
447ec028-95f5-465b-ac8a-ee09063549b4	2019-06-27 16:46:49+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/common.member.logs.list}	5	f	f	apiv4_GetCommonMemberLogsList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
06eeb517-dafa-48a2-9a62-e96b0eb46c03	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.cdn_advance_cache.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_del_cdn_advance_cache_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d310abcd-d49a-4e20-ab6c-09e7b6245bcc	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_del_visit_limit_blacklist_rule	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9b64bc09-9a4a-493d-81c5-a931f1597908	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/domain/list}	5	f	f	service_disp_DomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1b49d9ae-f563-4253-b338-3afdf339cf5e	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_del_websocket_rule_detail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
90efbacf-fce4-4637-90a6-4eeb1a407b9a	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/V4/service.apply.detail.save}	5	f	f	apiv4_PutV4ServiceApplyDetailSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5bb26e2e-dd85-48e1-99bf-3a512bbef12d	2019-06-27 16:46:38+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/permission.del.strategy}	5	f	f	apiv4_DeletePermissionDelStrategy	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3382545f-5f17-4ec9-99f9-7d29bafa36f5	2019-06-08 18:19:41+08	2019-06-09 11:01:26+08	\N	{http,https}	{PUT}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.DomainId.Settings.setCacheOrder}	5	t	f	Web_Domain_Region	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a22bb0ae-3624-4313-8e65-dd6f7da52d63	2019-06-27 16:46:38+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/permission.del.subUser}	5	f	f	apiv4_DeletePermissionDelSubuser	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c4c3d5fa-170e-443b-8c48-cfd4bb4713b8	2019-06-27 16:47:00+08	2020-03-29 14:36:05+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.resp_headers.rules.(?<id>\\\\d+)"}	5	f	f	apiv4_delSettingsRule_resp_headers	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
10764687-5b53-4767-bdb8-9dc46d9b2ad1	2019-06-27 16:46:38+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/permission.del.subUserGroup}	5	f	f	apiv4_DeletePermissionDelSubusergroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e0b44017-26af-4b11-bca6-7af83e4a9456	2019-06-27 16:46:41+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.center.initializeMemberMessageCenterSetting}	5	f	f	apiv4_Get_postMessagecenterCenterInitializemembermessagecentersetting	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
320c7b2e-28d0-4828-b8e8-684e357242d9	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/domain/line/bind}	5	f	f	service_disp_DomainBindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9f696510-a8c4-4cc6-8ac7-a5554d3dea3b	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/domain/tag/bind}	5	f	f	service_disp_DomainBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2cd6e96f-1a88-4da7-87f1-e31d1dc00d66	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/domain/info}	5	f	f	service_disp_DomainInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e592c031-97f1-4ff2-8ad8-5d329ff61815	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/domain/turn_net}	5	f	f	service_disp_DomainTurnNet	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eda06251-d9d7-4be0-be66-da086eba6e29	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/domain/line/unbind}	5	f	f	service_disp_DomainUnbindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
34fa24ee-442e-447a-ad56-9f94a379d3a1	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/domain/tag/unbind}	5	f	f	service_disp_DomainUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
de6d5126-e5e4-4a26-a33a-cc5c9e633fe9	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/agent/tag/bind}	5	f	f	service_disp_AgentBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f70ce009-4d8e-4f29-9087-f1cd8225ca1b	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/agent/tag/unbind}	5	f	f	service_disp_AgentUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
acf6420c-e9ef-481f-bcf7-0d5e19ebe2ac	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/meal/line/bind}	5	f	f	service_disp_MealBindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f3f471ba-45e1-49d2-867a-e33045a09b6a	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/meal/info}	5	f	f	service_disp_MealInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1cb99904-8038-4b0a-a6f3-60d75e4cd399	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/meal/list}	5	f	f	service_disp_MealList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2719a913-fdac-4352-8e52-6f0e2c692ae4	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/meal/save}	5	f	f	service_disp_MealSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d7f4f8ad-d2da-4392-b35c-42e50855b4fd	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.subUsersList}	5	f	f	apiv4_GetPermissionGetSubuserslist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f88abaa-e80d-462b-aa62-ae489e746933	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/finance.order.prepay}	5	f	f	apiv4_PutFinanceOrderPrepay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
32c6748c-cc55-4b66-aa45-cf2a531b8e55	2019-08-31 16:54:15+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.report.sdk.package.block.list}	5	f	f	apiv4_Get_postFirewallReportSdkPackageBlockList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d70b07c-ff8e-400d-a741-8feb85f6b155	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policy.sort}	5	f	f	apiv4_PostFirewallPolicySort	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bd9be870-19ed-490a-a317-8a28f5db0663	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policy.stop}	5	f	f	apiv4_PostFirewallPolicyStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f197d8e0-60c4-4656-8607-5fe467a877f3	2019-06-27 16:46:46+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/permission.add.strategy}	5	f	f	apiv4_PostPermissionAddStrategy	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cd029c96-ebf3-4e2d-aa81-92b3159ae545	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/tag/all}	5	f	f	service_disp_TagAll	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
49c5ea34-fe07-4f77-ab78-b00199b6f0a8	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/meal/line/unbind}	5	f	f	service_disp_MealUnbindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
180833ab-c021-4b65-adf6-0ffcd30a9433	2020-02-24 23:12:03+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dingzhi.baishan_atd.domain.deny_ip}	5	f	f	apiv4_BaishanATD_denyIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e4e69ed2-82b7-4314-9a13-ab9c5deb5c09	2020-02-24 23:12:03+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/dingzhi.baishan_atd.domain.list_ip}	5	f	f	apiv4_BaishanATD_denyIpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b16c47ab-2853-406f-aad1-43be413f1cbd	2019-06-27 16:46:48+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/firewall.policy.get_code}	5	f	f	apiv4_Get_postFirewallPolicyGet_code	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
594762b1-a7bc-407e-94bd-bb1c8cf7cb8b	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policy.open}	5	f	f	apiv4_PostFirewallPolicyOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
976d4416-1839-49e3-b489-440dd1683fbe	2019-08-22 16:47:21+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.policyGroup.open}	5	f	f	apiv4_PostFirewallPolicygroupOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d12eaac7-bfbf-4977-86b8-f72539d02f73	2019-06-27 16:46:49+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,PUT}	{}	{/V4/firewall.policy.save}	5	f	f	apiv4_Post_putFirewallPolicySave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
78673eae-2dd7-4b8b-82ca-3d2c1b84d1c8	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.subUserGroupList}	5	f	f	apiv4_GetPermissionGetSubusergrouplist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1ddd618e-b42b-42f8-999d-af3d5b3676c4	2019-06-27 16:46:39+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.get.subUserInfo}	5	f	f	apiv4_GetPermissionGetSubuserinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6ec7a998-4983-43d2-a615-c6898ec42555	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/permission.edit.strategy}	5	f	f	apiv4_PutPermissionEditStrategy	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
60dd1fb8-2547-40e3-af90-ddc21715d7f1	2019-06-27 16:46:47+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/permission.edit.subUser}	5	f	f	apiv4_PutPermissionEditSubuser	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
11053bea-9c5a-4258-9f45-73d2a0a71d5b	2019-06-27 16:46:48+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/remit.save}	5	f	f	apiv4_Get_postRemitSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2cd43988-df32-47de-a4df-082161ad4318	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/meal/tag/unbind}	5	f	f	service_disp_MealUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
724a0947-8bae-4556-80d6-a7da86e13bac	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/tag/check_use}	5	f	f	service_disp_TagCheckUse	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5d897781-55b5-4b96-9a54-02de755bbb37	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/tag/list}	5	f	f	service_disp_TagList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6f7cdfc9-ea2c-49e0-89c7-4745c7160667	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/tag/log/list}	5	f	f	service_disp_TagLogList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a4647699-8955-4feb-a93d-550bdb249ee8	2020-02-24 23:12:03+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.set.info}	5	f	f	apiv4_MemberSet_info	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e7e8102f-ff74-4ce4-ad04-3c2e3dae4d3b	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/tag/tree}	5	f	f	service_disp_TagTree	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
899c702a-1cd3-44cf-b8a3-8bff4461640f	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/user/line/bind}	5	f	f	service_disp_UserBindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
19b001c8-6978-4a3e-adee-7d8542ae18b9	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/user/tag/bind}	5	f	f	service_disp_UserBindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
20d16e3b-e3ac-4cf2-a187-0167cd71c2c0	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/user/info}	5	f	f	service_disp_UserInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d414e3cf-a70d-44ec-9f6c-cfc0cef3bf5d	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/user/list}	5	f	f	service_disp_UserList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7bab1811-09ac-45e3-abaf-7212c479916c	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/user/save}	5	f	f	service_disp_UserSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0e61fec6-c0f5-4728-b916-6f40f3235e2b	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/user/line/unbind}	5	f	f	service_disp_UserUnbindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dba9d2f0-8103-4542-9698-f3b800f2c0b2	2020-02-24 23:12:06+08	2020-02-24 23:12:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/share_data.ips}	5	f	f	apiv4_GetShare_dataIps	{}	\N	\N	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f32427be-c685-49f2-964f-fde27f010e39	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/user/tag/unbind}	5	f	f	service_disp_UserUnbindTag	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
709f63c5-1a86-4268-a406-3da74ffc4cb5	2019-09-25 15:25:57+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.group.undistributed.domain.list}	5	f	f	apiv4_CloudDns_DomainGroup_getGroupUndistributedDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1e773f7f-afb0-4f7a-9201-f7a641d12414	2020-02-24 23:12:04+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.plan.live_axis}	5	f	f	apiv4_Order_planLiveAxis	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
09aec8a4-018a-4c2b-aea9-fad55c429bb4	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/tag/sync/save}	5	f	f	service_disp_TagSyncSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c9eec2f-5032-4283-89aa-8a10fb4e6735	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/delete}	5	f	f	service_disp_LineDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d3cda90f-b773-4a25-bd89-9cec12c82ad2	2019-09-25 15:25:59+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.group.undistributed.domain.list}	5	f	f	apiv4_DomainGroup_ggtUndistributedDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b5f544b7-68e4-4491-b55a-8b4b2cf1d897	2020-02-27 20:01:24+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/share_data.ips}	5	f	f	apiv4_ShareData_ips	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4ea05c06-00b4-4689-a408-9cc4b65dfd88	2019-06-27 16:46:57+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.all_view_optimization"}	5	f	f	apiv4_WebCdnDomainSetting_put_all_view_optimization	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a33b24b9-5855-4d54-b5d9-c5810592eaa6	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/monitor/ip/event}	5	f	f	service_disp_Monitor_IpEvent	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ca2d7c3-f9cf-4fb2-8969-1e99d7775032	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/monitor/ip/list}	5	f	f	service_disp_Monitor_IpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
07a6eb20-9bdc-426c-ab63-3339513dc738	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/all}	5	f	f	service_disp_LineAll	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3ab68675-2e97-4984-8cbc-8ab37848727a	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/line/backip/bind}	5	f	f	service_disp_LineBindBackip	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d30f7ba-943d-4c36-b2f2-b8eae36fe7c4	2019-06-08 18:20:00+08	2019-06-09 11:01:46+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.All.Domains}	5	t	f	getAllDomains	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e4b2f11e-b395-4783-9e36-62bc9f37cd31	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/common.member.logs.export}	5	f	f	apiv4_PostCommonMemberLogsExport	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fadcd2bb-f9d0-4da4-9c90-80f04f6c658f	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/line/save}	5	f	f	service_disp_LineSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f662b383-9c41-43e2-9f72-adf42caa9aa4	2019-09-25 15:26:05+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/customer.manage.editinfolist}	5	f	f	apiv4_GetCustomerManageEditinfolist	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
247c9981-3800-407a-b586-b772d490da9a	2019-09-25 15:26:05+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/customer.manage.updatememberstatus}	5	f	f	apiv4_PostCustomerManageUpdatememberstatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
47a0414b-5d92-4915-83a2-2f6d443c36f4	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.scan.detail.list}	5	f	f	apiv4_Get_postShieldScanDetailList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cfb6de99-afca-4774-bf96-fb91f84cb989	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.scan.setting.info}	5	f	f	apiv4_Get_postShieldScanSettingInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d9657918-9d7f-4c02-ad1a-879c5132dc14	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.property.verify}	5	f	f	apiv4_PostShieldPropertyVerify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
31cebd1c-97c0-4517-8df6-793a418c1471	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.detection.info}	5	f	f	apiv4_Get_postShieldRiskDetectionInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c2e4b28-2aeb-48d7-b6ac-84a718d2d407	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.scan.meal.info}	5	f	f	apiv4_Get_postShieldRiskScanMealInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
90f2ae24-4d16-44b8-ba69-15ed37e3cbb8	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.risk.detection.add}	5	f	f	apiv4_PostShieldRiskDetectionAdd	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d1469298-eff7-4e8b-b0a3-cfadf86dfc31	2019-06-27 16:46:50+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.risk.detection.save}	5	f	f	apiv4_PostShieldRiskDetectionSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5eeb9754-0139-409e-b767-de0d9f251b5c	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/bandwidthhost.operate.record}	5	f	f	apiv4_addHostRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ccc52283-47bb-4ed2-b155-6f969e78803b	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/bandwidth.operate.record}	5	f	f	apiv4_addRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f5de228f-56a6-4c94-a762-3ad54537773d	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/bandwidthuser.operate.record}	5	f	f	apiv4_addUserRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7dd14462-626e-4dab-ab01-d1360164680d	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/bandwidthhost.operate.record}	5	f	f	apiv4_delHostRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6731a8e9-2394-4598-b1e5-01343a14b26f	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/info}	5	f	f	service_disp_LineInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6fc23e87-bb42-46a3-aed6-d5109c9604ef	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/list}	5	f	f	service_disp_LineList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4cbd60e1-e601-495c-ace2-c95601ccd6b1	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/meal}	5	f	f	service_disp_DispMeal	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
998cd706-fc6c-4c89-a646-589be93c5443	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidthhost.operate.record}	5	f	f	apiv4_updateHostRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
847bb265-23c3-47c5-9dc1-4df4efa61493	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/ips}	5	f	f	service_disp_DispIps	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7027b6d-5855-40f7-82e3-69fc433210ad	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidth.operate.record}	5	f	f	apiv4_updateRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
df40f7b7-2661-4f80-b9a7-5d4446cd13de	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/user/domain}	5	f	f	service_disp_DispUser_domain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
70c4fd94-bfc9-43cc-96d8-8d46d0a461a3	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/tree/nosearch}	5	f	f	service_disp_LineTreeNoSearch	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8e19d80c-e4ba-413d-a9e2-99a38a638ae6	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/line/backip/unbind}	5	f	f	service_disp_LineUnbindBackip	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c02b85a6-f19b-4f8f-8cf7-7499f99c0864	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/meal/ips}	5	f	f	service_disp_DispMealIps	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
42d7cee9-b799-48ef-98fb-aee42a4ed1cd	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/agent}	5	f	f	service_disp_DispAgent	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0a55e2c8-7864-4477-881d-39c0e49a6a7d	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/domain}	5	f	f	service_disp_DispDomain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4e4b4cb7-4580-405d-9676-ca68420daf9d	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/log}	5	f	f	service_disp_DispLogList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
671e0c28-852e-463f-a8b6-5efb300487e8	2020-09-09 17:48:59+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET}	{}	{/domain/info}	5	f	f	service_cdn_Domain_info	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cc489f88-329e-4d02-93a3-5340bb6b17f1	2020-02-27 20:01:26+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/bandwidthuser.operate.record}	5	f	f	apiv4_updateUserRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3fdcb7d3-2250-44dd-9f81-f5ac900784b9	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/record/delete}	5	f	f	service_disp_DispRecordDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5f5523a3-3b60-4f24-a434-5cc9c1834c4b	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/disp/record/save}	5	f	f	service_disp_DispRecordSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a624832e-393b-4c8a-af00-5994abffa73b	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/meal/domain}	5	f	f	service_disp_DispMeal_domain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f6e72d05-8e46-414b-ae66-3e429aaad138	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/record/turn_status}	5	f	f	service_disp_DispRecordTurnStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c2b37eba-812d-461a-adbc-210e077142b4	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/user}	5	f	f	service_disp_DispUser	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cab093dd-6f3b-497f-abf1-c4e6b6057121	2020-09-09 18:32:42+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.host.ip.add}	5	f	f	apiv4_SocPropertyHostIp_addHostIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ea7ff8c-aa37-4c25-a28d-19ae15c85ecc	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/line/tree}	5	f	f	service_disp_LineTree	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8cb86f83-2edc-46ce-a9b1-aae1d2db63bb	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/record/list}	5	f	f	service_disp_DispRecord	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
172e1a7e-26fa-45f8-ad9f-9e43764f89ee	2020-05-19 22:03:31+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/agent/domain}	5	f	f	service_disp_DispAgent_domain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6494eaff-1fec-4300-b3c2-cac8dd9b0cb1	2020-09-09 17:48:59+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET}	{}	{/domain/list}	5	f	f	service_cdn_Domain_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
49644b49-e27c-4fb3-91d5-6905cb4636f0	2020-09-09 17:48:59+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{POST}	{}	{/ca/verify}	5	f	f	service_cdn_Ca_verify	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7cea0c0e-e348-4fe3-a4fd-06fb8a24c3b0	2020-09-09 17:48:59+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{POST}	{}	{/domain/save}	5	f	f	service_cdn_Domain_Save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a513f782-e6b9-4e5a-bba6-db026291cc00	2020-09-09 18:32:42+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.property.host.ip.del}	5	f	f	apiv4_SocPropertyHostIp_delHostIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a5498d21-5ddb-41c6-9189-853eb2437c49	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.count.list}	5	f	f	apiv4_RiskDetection_getPropertyRiskCountList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6859f540-84a9-4f5a-9bb2-4ea04daa04a4	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchAdd}	5	f	f	apiv4_DnsDomainRecords_batchAddRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4fd91d47-e997-4693-a753-473e36ada066	2019-06-27 16:46:51+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.recreateorder}	5	f	f	apiv4_____	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
02dbe650-f9fe-499a-9457-2e6114cfbb8d	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.setting.info}	5	f	f	apiv4_RiskDetection_getRiskSettingAllInfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
67399e87-c855-4ce2-b051-e20407d9c851	2019-06-27 16:46:51+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/messagecenter.notice.delmembertonoticegroup}	5	f	f	apiv4_DeleteMessagecenterNoticeDelmembertonoticegroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2390ee8e-d5f9-46a6-aba0-ed3442825d5f	2019-06-27 16:47:03+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DnsDomain.checkTxtRecord}	5	f	f	apiv4_checkDomainRetrieveTxtRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0a6f2b88-457d-4a28-bc43-cb6b1012ae44	2019-06-27 16:46:51+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/messagecenter.notice.deletenoticemember}	5	f	f	apiv4_DeleteMessagecenterNoticeDeletenoticemember	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
dd063190-41a7-4bc2-918f-118bb745079e	2019-06-27 16:46:51+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/finance.recharge.wxpay_Recharge}	5	f	f	apiv4_WxPayCheck	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a2cb7e3-62e5-4a31-9efe-6b31aab07983	2019-06-27 16:47:04+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.Domain.DnsDomain.list}	5	f	f	apiv4_getDnsDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b09b6bb8-478b-43d5-ae03-0693aa24246b	2019-06-08 18:19:54+08	2019-06-09 11:01:40+08	\N	{http,https}	{POST}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/host.scan.editRecord}	5	t	f	editRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
264c17e1-3f58-4449-83d0-e0ba405e6940	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/shield.property.delete}	5	f	f	apiv4_ShieldEye_RiskDetection_deleteProperty	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28bd4efb-72ae-473c-8185-293a42d13b1b	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.forgetPass}	5	f	f	apiv4_PostClouddnsDomainDomainlockForgetpass	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7475698-829d-4c79-ba58-57726509bd7a	2019-06-27 16:46:49+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.Domain.DomainLock.lock}	5	f	f	apiv4_PostClouddnsDomainDomainlockLock	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2a620149-f730-46c8-8068-0e3763fab4d4	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.property.check.visit}	5	f	f	apiv4_ShieldEye_checkDomainVisit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e172caf1-7d46-4292-9295-59af7d7681b6	2019-06-27 16:46:51+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/messagecenter.notice.deletenoticegroup}	5	f	f	apiv4_DeleteMessagecenterNoticeDeletenoticegroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a33f99a9-8736-49d1-824f-340fced4981f	2019-06-27 16:46:51+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.add}	5	f	f	apiv4_DnsDomainRecords_addRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4483734e-8d9e-485e-9d71-2877b4476bec	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/shield.risk.log.list}	5	f	f	apiv4_RiskDetection_riskDetectionLogList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4218ad6d-e093-4bf4-818c-16764019d430	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/shield.risk.save.confirm.status}	5	f	f	apiv4_RiskDetection_saveRiskLogConfirmStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e3afd55-7fe9-4d18-a586-d98f68ab4ec2	2019-06-27 16:46:51+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/shield.risk.switch.act}	5	f	f	apiv4_RiskDetection_switchRiskTaskByStatus	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f3f2edd5-8e06-4e91-8a21-60fbbc2779c4	2020-01-14 16:24:44+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.ca.text.save}	5	f	f	apiv4_saveTextCaInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
294af8d3-863f-4093-8bc1-c379c6c3401a	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.detailLine}	5	f	f	apiv4_TjkdPlusDDosStat_getDDosDetailLineStat	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6f332314-2f1e-49ae-9d9c-282b80d822a4	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.detailList}	5	f	f	apiv4_TjkdPlusDDosStat_getDDosDetailListStat	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5c403e0e-ad30-4ab5-bcd4-c806a1da707d	2019-06-27 16:46:55+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.speed.product.list}	5	f	f	apiv4_Get_postCloudSpeedProductList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
269338ca-1537-42f9-bdb5-9319e559d80d	2019-06-27 16:46:55+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/taiji.plus.buy.menu}	5	f	f	apiv4_Get_postTaijiPlusBuyMenu	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
902d3a13-d3eb-4b52-9dda-0ca195950278	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.host.ip.list}	5	f	f	apiv4_SocPropertyHostIp_getHostIpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1bc258f1-dd4c-4bc8-b4a2-1b8e2130fda7	2019-06-27 16:46:55+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/taiji.plus.product.list}	5	f	f	apiv4_Get_postTaijiPlusProductList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
79bee6e8-0c71-4f02-8bfb-084af82203d4	2019-06-27 16:46:55+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/taiji.web.buy.menu}	5	f	f	apiv4_Get_postTaijiWebBuyMenu	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f27ead56-80fd-4c1e-8b7d-2b531a3c6884	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/taiji.web.domain.list}	5	f	f	apiv4_Get_postTaijiWebDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
08e5c3e9-77a4-4eec-8ee5-edd5bfb15ad3	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/taiji.web.product.list}	5	f	f	apiv4_Get_postTaijiWebProductList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
102f4b8d-fb51-4fb5-9df7-8eb5ebdbeb1b	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.buy.menu}	5	f	f	apiv4_PostCloudDnsBuyMenu	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2f57ac4a-ace6-4e88-8b3f-af9af683beb3	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.new_price}	5	f	f	apiv4_Order_NewPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
628c7b72-059c-4e8a-a68c-5f9b8f63fe02	2020-05-25 16:31:06+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payon_price}	5	f	f	apiv4_Order_PayOnPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
86ee5a4b-96a8-4ee0-a5c4-387b91ca6230	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.host.ip.save}	5	f	f	apiv4_SocPropertyHostIp_saveHostIp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7f9c1f5-f676-46b9-b63a-867736083236	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.new_pay}	5	f	f	apiv4_Order_NewPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9d54059f-24a0-41bb-bf88-5ab7cc40d9f1	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.order_list}	5	f	f	apiv4_Order_OrderList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ef3bb711-0777-4a6a-b08a-f2c1fdf90b5b	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.order_cancle}	5	f	f	apiv4_Order_cancle	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
46857841-2c45-446f-9353-c590910f22ec	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.order_verify}	5	f	f	apiv4_Order_OrderVerify	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c9375b7b-f8f9-4286-9e07-898c40085a5d	2020-05-25 16:31:06+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payoff_pay}	5	f	f	apiv4_Order_PayOffPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
357d5151-d56f-4b92-a672-fdad2ab5c895	2020-05-25 16:31:06+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payoff_price}	5	f	f	apiv4_Order_PayOffPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
461b1af3-5c7e-44f4-94bb-35e2d87952f3	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.plan_list}	5	f	f	apiv4_Order_PlanList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0fb97851-d06a-46df-bcee-66bfc97847b0	2020-05-25 16:31:06+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.payon_pay}	5	f	f	apiv4_Order_PayOnPay	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e69934b0-2c3d-4d3d-b71f-5212752bf2cf	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.host.ip.info}	5	f	f	apiv4_SocPropertyHostIp_getHostIpInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2ecc2215-21ce-48d6-a238-6009748c46ad	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.line}	5	f	f	apiv4_TjkdPlusDDosStat_getDDosLineStat	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
320579b8-98a3-45b7-b528-3b4b9ffa5318	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.ddos.list}	5	f	f	apiv4_TjkdPlusDDosStat_getDDosList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
90b94f61-0953-45c0-ada2-b9b10078260f	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/order.member_balance}	5	f	f	apiv4_Order_MemberBalance	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
eecf53cd-8cd9-42a5-a774-37391e553e9f	2020-05-25 16:31:05+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.new_order}	5	f	f	apiv4_Order_NewOrder	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d96449a5-e018-4eea-b4f2-064e588ec361	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.property.mapping.config.del}	5	f	f	apiv4_SocPropertyMappingConfig_delMappingConfig	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
643f0ba5-fec6-43bf-ba46-aace03428ee4	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.website.list}	5	f	f	apiv4_SocPropertyWebsite_getWebsiteList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
264155db-b211-4924-b965-d7bf448d79d1	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.website.save}	5	f	f	apiv4_SocPropertyWebsite_saveWebsite	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
604e49cf-8236-4f2e-835d-1357668bce3d	2020-12-14 16:22:14+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/group/domain/select}	5	f	f	service_disp_DispGroupDomainSelect	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c9731cd-3759-424c-b357-13fa363a330d	2020-12-14 16:22:14+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/record/domain}	5	f	f	service_disp_DispRecordDomain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6e62414b-7c19-4464-8547-6170bac431bc	2020-12-14 16:22:14+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/pool/ip/on}	5	f	f	service_disp_IpPoolIpOn	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2da37c7e-652f-4f31-b209-40c6184720cb	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.mapping.config.add}	5	f	f	apiv4_SocPropertyMappingConfig_addMappingConfig	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c918568-7ade-46b2-a16e-9a4772dae4e9	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.mapping.config.add.promptly.task}	5	f	f	apiv4_SocPropertyMappingConfig_addPromptlyTask	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6a36f4f7-2fda-487c-8787-044b37668ac3	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.mapping.config.change.status}	5	f	f	apiv4_SocPropertyMappingConfig_changeMappingStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
98026142-ac75-4256-94c8-c673657a395c	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.mapping.config.list}	5	f	f	apiv4_SocPropertyMappingConfig_getMappingConfigList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
86d8700c-3c3d-4a93-9844-eadf4c9b078d	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.mapping.config.save}	5	f	f	apiv4_SocPropertyMappingConfig_saveMappingConfig	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9033b879-d718-4542-9310-acce46b18efd	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.website.add}	5	f	f	apiv4_SocPropertyWebsite_addWebsite	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e2f3471c-3dcc-4a10-a80f-cbca42454adc	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.property.website.del}	5	f	f	apiv4_SocPropertyWebsite_delWebsite	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
337ad4b9-604f-4607-b9d3-faf4c05f0b52	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.trade.conf}	5	f	f	apiv4_SocPropertyWebsite_checkFreePackage	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d0cc7168-da46-4ab5-bdaa-674aefeb12a2	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.website.auth.code}	5	f	f	apiv4_SocPropertyWebsite_getAuthCode	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2a5aa66a-5014-437f-9176-18de52cc0404	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.website.info}	5	f	f	apiv4_SocPropertyWebsite_getWebsiteInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
82eb5c86-8100-408a-bbd0-0dba09623902	2020-09-09 18:32:42+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.website.verify.auth.code}	5	f	f	apiv4_SocPropertyWebsite_verifyAuthCode	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3df1869e-8a57-4aa5-aadf-f771a762efd2	2020-10-29 18:56:03+08	2021-01-01 21:36:25+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/pool/save}	5	f	f	service_disp_IpPoolSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fd739cc4-b6f3-4423-9b85-94afcecb4741	2020-04-10 10:51:03+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/ads.plan.ip.block.list}	5	f	f	apiv4_GetAdsPlanIpBlockList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
12d604b5-6c8a-42ae-936a-4d2ae198a634	2020-12-14 16:22:13+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/distributeinfo/list}	5	f	f	service_disp_IpDistributeinfoList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a7be02c1-0ccd-4156-a90f-4e6323315194	2020-12-14 16:22:13+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/group/delete}	5	f	f	service_disp_IpGroupDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b18679d6-1cca-4b16-9345-1c729005642a	2020-12-14 16:22:13+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/monitor/ip_alive/hand}	5	f	f	service_disp_Monitor_IpAlive_hand	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9c85e3a6-3b4d-446e-b12e-5434be2046fa	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.availability}	5	f	f	apiv4_PlusPackageIpMonitor_getAvailability	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
294744cf-bafe-4480-8cdb-2dbeb99c565f	2020-03-03 14:50:40+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET}	{}	{/oplog/info}	5	f	f	service_oplog_OpLog_info	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
38d2bdb8-efa4-4cdf-b84e-294b25351cd3	2020-03-03 14:50:40+08	2020-03-28 15:12:01+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/s_oplog}	0	t	f	service_oplog_uripre_batch	\N	\N	\N	\N	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b73d7584-5830-4e7b-b796-e6e94f9de7fe	2020-12-14 16:22:12+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/distribute/op}	5	f	f	service_disp_IpDistributeOp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64df630f-d5d7-479c-844f-94244e129e46	2019-06-08 18:20:06+08	2019-06-09 11:01:52+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Safe.cc}	5	t	f	getCcStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
972aded1-8b12-4417-98ee-9f8b5d5ba78d	2020-03-03 14:50:40+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{POST}	{}	{/oplog/save}	5	f	f	service_oplog_OpLog_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b7cf4bb1-ccbf-4c04-8239-1ed1c64c7fd2	2021-01-01 20:44:43+08	2021-01-01 21:36:23+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/ip/map}	5	f	f	service_disp_IpMap	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
5fe9fd23-6768-4c8c-b911-cea32c84e582	2021-01-01 21:36:32+08	2021-01-01 21:36:32+08	6418f317-1360-47c5-8665-e9023fac68fe	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/batch/admin}	1	t	f	service_batch_uripre_agw_batch_adimn	\N	\N	\N	\N	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
9b6b85b8-82a7-4e39-be22-408fa4739d16	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/statistic.tjkd.plus.delay.avg}	5	f	f	apiv4_PlusPackageIpMonitor_getDelayAvgLine	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6f3db49d-f29a-4e95-a438-8e558e0b15c4	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.add}	5	f	f	apiv4_ZeroTrustApp_addApp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fbc07443-2d6e-4c4a-8bef-6c5af6b2433e	2019-06-08 18:20:05+08	2019-06-09 11:01:51+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Visit.list}	5	t	f	getAllStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
200eb933-93d6-471b-ac7c-a5f490a90dc0	2019-06-08 18:20:06+08	2019-06-09 11:01:52+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Traffic.backAndspeed}	5	t	f	getBackStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7221af83-e5b6-4516-bee2-f25b9965200c	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.saas.template}	5	f	f	apiv4_ZeroTrustFieldConf_getSaasTemplateType	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6c198920-ff43-4262-ab22-a905337f6a3b	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.xml.metadata}	5	f	f	apiv4_ZeroTrustFieldConf_getSaasXMLMetadata	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
b146bed0-8e03-4975-babd-554712c8ff29	2020-09-09 18:32:46+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/user.ip.add}	5	f	f	apiv4_userIpAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f4773556-134d-4346-b41a-4ef9a5bcb504	2020-09-09 18:32:46+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/user.ip.del}	5	f	f	apiv4_userIpDel	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c96c1ede-a504-4213-8e43-942a2dd64d3b	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.app.saas.conf.fields}	5	f	f	apiv4_ZeroTrust_getSaasAppConfFields	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
2a2b92d2-1c8b-4b9c-a0ba-3053ac3db9b2	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.saas.conf.add}	5	f	f	apiv4_ZeroTrustSaasConf_addConf	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
77654e8a-48ad-4fc5-ad44-e10f6a406c76	2020-09-09 18:32:46+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/user.ip.list}	5	f	f	apiv4_userIpList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d65b0b49-4487-40bf-b35e-8ebc0371fb6c	2020-09-09 18:32:47+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/user.ip.save}	5	f	f	apiv4_userIpSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
14036ec0-a2ac-4024-8d09-95f2a2702abb	2020-05-26 09:51:37+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/ip.white.list}	5	f	f	apiv4_getIpWhiteList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
331a9f46-88e5-41fa-bcd6-b8f84e58e8e4	2020-05-26 09:51:37+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/ip.white.save}	5	f	f	apiv4_saveIpWhite	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2c8cd431-8412-4f44-87ce-c4a387eb5b0a	2020-03-03 14:50:40+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET}	{}	{/oplog/list}	5	f	f	service_oplog_OpLog_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
44a407e3-fca6-45e1-af72-61245a0ffa21	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/cloudsafe.hwws.domain.list}	5	f	f	apiv4_getHwwsDomainList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9fc62fd4-5c2a-4626-aeb6-cf5ad8322640	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.batchList}	5	f	f	apiv4_DnsDomainRecords_getRecordBatchList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e8b6ad13-9957-414f-a4e8-ac3563e76eda	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchOpen}	5	f	f	apiv4_DnsDomainRecords_batchOpenRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8ee00634-6df1-4939-b13a-830720001983	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.list}	5	f	f	apiv4_DnsDomainRecords_getRecordList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8084cafc-2b27-401d-8f7e-3f1bfbd1fb04	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/CloudDns.DomainRecords.list}	5	f	f	apiv4_DnsDomainRecords_getRecordTypes	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ef98ef57-7055-426e-ac5c-6d43d518bed8	2020-07-06 12:01:11+08	2020-07-06 12:01:11+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/turn_disp}	5	f	f	service_disp_Ip_turnDisp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
28dfc480-b2c0-48fa-a71f-9bbb7fdb820e	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/CloudDns.DomainRecords.importRecord2CloudSpeed}	5	f	f	apiv4_DnsDomainRecords_importRecord2CloudSpeed	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b549f155-b8ed-44f7-a830-d7bd5ec12e37	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.delete}	5	f	f	apiv4_DnsDomainRecords_deleteRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
36eb478a-cdb1-4e83-a07e-d2b730a6365f	2019-06-08 18:20:09+08	2019-06-09 11:01:55+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Visit.top}	5	t	f	getVisitTopStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7ee61164-ff02-4fa4-9a96-5127a7ba529f	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.edit}	5	f	f	apiv4_DnsDomainRecords_editRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
70509bc0-86cb-490e-98d5-9feb72a24c19	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/domain/save}	5	f	f	service_disp_DomainSave	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9e00c014-1302-45a5-a604-eefaf2fd70ba	2020-05-19 22:03:30+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/agent/line/unbind}	5	f	f	service_disp_AgentUnbindLine	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
82946965-b14e-4840-b78f-c5a43449fce0	2019-11-05 11:49:39+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/web.domain.set.get}	5	f	f	apiv4_web_cdn_get_set	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7e713815-92a7-4031-9aef-46e598251f30	2019-06-08 18:20:09+08	2019-06-09 11:01:54+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Request.province}	5	t	f	getTopProvince	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0ad8b7f4-405b-4348-9588-81eb1df63602	2019-06-08 18:20:07+08	2019-06-09 11:01:53+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Visit.pv}	5	t	f	getPvStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
da1bb939-5d5f-4f51-a213-7040d7c04711	2019-06-08 18:20:08+08	2019-06-09 11:01:53+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Code.stat}	5	t	f	getStatusCodeStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fceea9e8-e919-4162-a378-45fb2dd5a1af	2020-07-06 12:01:11+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/redisp}	5	f	f	service_disp_Ip_redisp	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c8424e4-09bb-48c2-a85e-c6c68d7fdbfa	2019-06-08 18:20:09+08	2019-06-09 11:01:54+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Visit.uv}	5	t	f	getUvStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
103a6485-0de0-4a5a-902b-eaab55c96eda	2019-06-08 18:20:08+08	2019-06-09 11:01:54+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Code.statDetail}	5	t	f	getStatusCodeStatDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
c662696b-cfbb-4642-8f19-f94add47132f	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tcp.forward.add}	5	f	f	apiv4_addTcpForward	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
610706d1-ef38-473c-a191-24c0a481b816	2019-06-08 18:20:08+08	2019-06-09 11:01:54+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Request.country}	5	t	f	getTopCountry	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a7f3456-f512-44fa-b48b-19a7cc23dfe3	2019-06-08 18:20:09+08	2019-06-09 11:01:55+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Visit.speed}	5	t	f	getVisitSpeedStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f43b35b9-3708-49d4-99c6-547e326d1ff0	2019-06-08 18:20:07+08	2019-06-09 11:01:53+08	\N	{http,https}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Traffic.speed}	5	t	f	getSpeedStat	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e938b199-4332-409b-ac45-1020ecd37d65	2019-06-27 16:46:44+08	2020-03-29 14:36:06+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.web_honeypot.rules"}	5	f	f	apiv4_listSettingsRuleWebHoneypot	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
66a347ce-8332-4038-ba60-17d0b595b146	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.makeDomainDns}	5	f	f	apiv4_DnsDomainRecords_makeDomainDns	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6dfefd44-8973-4be1-a153-49722417bd31	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.open}	5	f	f	apiv4_DnsDomainRecords_openRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2b7775ac-c828-4352-a697-6c3da6606a03	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.pause}	5	f	f	apiv4_DnsDomainRecords_pauseRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9460cc86-0ad1-42a6-a2bb-c7ecd6ab86e9	2020-07-07 14:18:40+08	2020-07-08 16:36:19+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/stop_records}	5	f	f	service_disp_Ip_stopRecords	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f92e1085-f8b6-4d7b-bd74-2a97f8f53426	2020-09-09 17:47:34+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/cdn}	1	t	f	service_cdn_uripre_cdn	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d971c7a6-dfc3-4918-9da4-219863af25ff	2020-07-06 12:01:12+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{POST}	{}	{/monitor/event/add}	5	f	f	service_disp_Monitor_EventAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
92e6dd6a-067a-4a58-bb14-ce3aeb546a22	2020-07-16 15:12:16+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.package.undistributed.domain.list}	5	f	f	apiv4_CloudDns_DomainPackage_getPackageUndistributedDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c5ba3c3-fddf-4189-bcbc-3ee5ac62753e	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/soc.log.download.fields}	5	f	f	apiv4_LogDownloadFieldConf_downloadFields	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
7b8a237e-9196-4159-99ac-b9cf1beb9ea3	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.task.add}	5	f	f	apiv4_LogDownloadTask_addTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
58ebdfd7-d7be-4eac-bb26-43a07fadc4cd	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.log.download.task.batch.cancel}	5	f	f	apiv4_LogDownloadTask_batchCancelTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6b79b3bb-8c24-4bc0-b4fa-c7e7b21da671	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.log.download.task.batch.del}	5	f	f	apiv4_LogDownloadTask_batchDeleteTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6364482b-f04f-41d3-853d-4a024b50b1ea	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.task.cancel}	5	f	f	apiv4_LogDownloadTask_cancelTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
93b2f749-7781-4f15-ba95-754ffe240537	2019-06-27 16:46:53+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_ddos"}	5	f	f	apiv4_WebCdnDomainSetting_get_anti_ddos	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
fa86fd5e-ed01-47df-845b-223d3d66a4b5	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.notice.getnoticememberlist}	5	f	f	apiv4_Get_postMessagecenterNoticeGetnoticememberlist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27d8fc3f-4fb8-49de-8d16-136bd4cef3ad	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.notice.verifycallback}	5	f	f	apiv4_Get_postMessagecenterNoticeVerifycallback	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
aa0300b8-e624-4a8f-ad05-6135fb0a8f6a	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.usable.domain.list}	5	f	f	apiv4_ZeroTrustApp_usableDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
30391833-cd81-4661-a7cd-8cf878f1ed84	2019-06-27 16:46:52+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.notice.getnoticegrouplist}	5	f	f	apiv4_Get_postMessagecenterNoticeGetnoticegrouplist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
daf3c6fc-483d-4cf4-87e4-f28078b612f6	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/messagecenter.notice.addnoticegroup}	5	f	f	apiv4_PostMessagecenterNoticeAddnoticegroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
64c14311-19cf-4bc9-ab3b-e40dabbecaee	2019-06-27 16:46:53+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/messagecenter.notice.updatenoticegroup}	5	f	f	apiv4_PostMessagecenterNoticeUpdatenoticegroup	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
ea79cc67-7839-430c-959e-d36b8295b60f	2020-07-08 16:35:40+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/ip/batch_record}	5	f	f	service_disp_Ip_batchRecord	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
27f792f0-c396-4dc5-8dd7-417fe540518a	2021-01-01 20:44:45+08	2021-01-01 21:36:24+08	88dde9c8-8a9c-4e12-84ce-4348ee825bb5	{http,https}	{GET}	{}	{/disp/group/tcp/select}	5	f	f	service_disp_DispGroupTcpSelect	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
721bd4f1-535a-47b9-bc66-7bbde750d006	2019-06-27 16:46:53+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.back_source_host"}	5	f	f	apiv4_WebCdnDomainSetting_get_back_source_host	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0e51b1b6-be9c-4ba2-8261-e4f3653e5a17	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.slice"}	5	f	f	apiv4_WebCdnDomainSetting_get_backsource_slice	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1514b819-5134-4ce4-aaa6-cda33df166db	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.task.del}	5	f	f	apiv4_LogDownloadTask_deleteTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
da93af8f-8be5-4c0d-a331-b56c77381b24	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.task.regenerate}	5	f	f	apiv4_LogDownloadTask_regenerateTask	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
bf675e58-30c5-4532-8a95-e3f732269163	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.domain_redirect"}	5	f	f	apiv4_WebCdnDomainSetting_get_domain_redirect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
71afd34a-0aa0-4704-b23e-d4dd8b564354	2019-06-27 16:46:53+08	2019-12-26 10:48:51+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.notice.verify}	5	f	f	apiv4_Get_postMessagecenterNoticeVerify	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f4318372-1435-463f-83e7-18a4e36f05b2	2019-06-27 16:46:52+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/Web.Domain.Label.Tai.del}	5	f	f	apiv4_Domain_labelDelTai	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e9ddd68b-0e59-4fb7-995c-ec96cf6558c6	2019-06-27 16:46:53+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.Region}	5	f	f	apiv4_WebCdnDomainSetting_getZone	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0e889c59-a456-4dc1-85f0-af5c1b5ed6e7	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.log.download.task.list}	5	f	f	apiv4_LogDownloadTask_taskList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
33fac8f4-790b-4f5e-866b-1d79a522fde7	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.template.add}	5	f	f	apiv4_LogDownloadTemplate_addTemplate	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
2fa30fef-7a5c-4500-95f8-3b39b85783ff	2021-01-01 21:36:37+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.batch.get.listen}	5	f	f	apiv4_batch_getListenPort	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
f3748564-6ebb-4031-8f29-e2baa7c28e9b	2021-01-01 21:36:37+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/web.domain.batch.subtask}	5	f	f	apiv4_saveWebDomain	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6662f228-56b8-4149-9907-bfd44a108be9	2019-06-08 18:20:15+08	2019-06-08 18:40:48+08	\N	{http}	{GET}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/Web.Domain.Report.Request.overview}	5	t	f	overViewRequest	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
19a1793d-35e8-4642-af7b-1c97928071e2	2019-06-27 16:46:55+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.getmessageinfo}	5	f	f	apiv4_Get_postMessagecenterGetmessageinfo	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9f8a76a5-3527-4422-97ca-55adcfbeb8df	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.zone_limit"}	5	f	f	apiv4_WebCdnDomainSetting_get_zone_limit	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
f4f18c63-942e-4a0b-9e44-18839bfe95cb	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc"}	5	f	f	apiv4_WebCdnDomainSetting_put_anti_cc	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
30b565ef-513c-4028-8add-624cfe049d2b	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.https"}	5	f	f	apiv4_WebCdnDomainSetting_put_https	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d2ef2c6c-96fe-413a-b4f2-550bc02d145e	2019-06-27 16:46:55+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/messagecenter.getmessagelist}	5	f	f	apiv4_Get_postMessagecenterGetmessagelist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b40cba46-542f-4157-9db6-9f436789b3e8	2019-06-27 16:46:55+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/cloud.dns.product.list}	5	f	f	apiv4_Get_postCloudDnsProductList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
10bbd9b0-de0d-4f32-af0a-02182cd03ed0	2019-06-27 16:46:55+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.visit_limit_blacklist"}	5	f	f	apiv4_WebCdnDomainSetting_put_visit_limit_blacklist	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bc131da9-02ac-430b-b821-1f0f45476a4f	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.created.order}	5	f	f	apiv4_PostCloudDnsCreatedOrder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
87da0221-af4e-41b0-a2e2-d746f5074e71	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.speed.buy.menu}	5	f	f	apiv4_PostCloudSpeedBuyMenu	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a1f93b10-06fa-4181-9fbc-01c93a1c0b98	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.source_site_protect"}	5	f	f	apiv4_WebCdnDomainSetting_put_source_site_protect	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1d447441-c536-4de3-9b0f-dd769086128a	2019-06-27 16:46:53+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.anti_cc"}	5	f	f	apiv4_WebCdnDomainSetting_get_anti_cc	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d31aa4c5-5cdc-435d-ac99-ff578ee7ddf5	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/finance.order.list}	5	f	f	apiv4_Get_postFinanceOrderList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
38f8d439-ede1-4a66-b0b8-c0af998d68db	2019-06-27 16:46:23+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/api}	0	t	f	apiv4_uripre_api	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
481d7306-9d48-4010-9305-be5d42a1cdcb	2019-06-27 16:46:54+08	2020-03-29 14:36:04+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/Web.Domain.DomainId.(?<domain_id>\\\\d+).Settings.websocket"}	5	f	f	apiv4_WebCdnDomainSetting_get_websocket	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
299cbe07-37a5-4ccf-9742-b73db0150ea7	2019-06-27 16:46:52+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/CloudDns.DomainRecords.batchImport}	5	f	f	apiv4_DnsDomainRecords_batchImportRecords	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d0daade8-9e60-42ad-8f2f-5a8436dd21a8	2019-06-27 16:46:55+08	2020-03-29 14:36:09+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/messagecenter.batch.deletemessage}	5	f	f	apiv4_DeleteMessagecenterBatchDeletemessage	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5019776f-acdc-4b51-858d-cab9c5ec97cd	2020-07-16 15:12:16+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.bind.package}	5	f	f	apiv4_CloudDns_DomainPackage_bindDomainToPackage	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b60f7da6-cd43-4a57-9183-5a3d25799c7f	2020-07-16 15:12:16+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.package.domain.list}	5	f	f	apiv4_CloudDns_DomainPackage_getPackageDomainList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3bdf706e-7bc2-4d8d-b83a-854a4ff02927	2020-07-16 15:12:16+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.package.list}	5	f	f	apiv4_CloudDns_DomainPackage_getPackageList	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a8fac0c7-496f-45c7-bd76-41972867c11e	2020-07-16 15:12:16+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.dns.domain.unbind.package}	5	f	f	apiv4_CloudDns_DomainPackage_unbindDomainFromPackage	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1ea4d006-0cc0-49bd-861e-94c67852d4a3	2020-07-16 15:12:18+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/share_data.ip.search}	5	f	f	apiv4_ShareData_ipSearch	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1f4b6e4d-5ca2-432c-b5af-79a0e025294c	2020-09-21 11:59:02+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/member.set.info.console}	5	f	f	apiv4_MemberSet_info_console	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
afa3e77b-6a2a-43bc-a0a8-d10f9f9fb630	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.open}	5	f	f	apiv4_Get_postCrontabCrontabOpen	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
6932a3e4-6596-43ca-9cdd-1e3c271073d3	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/finance.order.detail}	5	f	f	apiv4_Post_getFinanceOrderDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
36f2aa4a-9e4d-45f0-809c-2be428990803	2020-04-06 20:55:29+08	2021-01-01 21:36:17+08	de2547a8-e779-4bd3-9146-72ec9d34dcfe	{http,https}	{GET}	{}	{/v1/idc_house/info}	5	f	f	service_asset_GetIdcHouseInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
74f5c0fe-ebc2-4516-a093-a71aa775fc13	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.save}	5	f	f	apiv4_Get_postCrontabCrontabSave	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a0e6aeff-3158-493d-8086-c58e19fdf6d1	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.crontab.stop}	5	f	f	apiv4_Get_postCrontabCrontabStop	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
5644ce8f-62ba-4b5f-ae42-7fd81328d9d5	2019-06-27 16:46:40+08	2020-03-29 14:36:10+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/crontab.process.detail}	5	f	f	apiv4_Get_postCrontabProcessDetail	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2321ead6-287b-4207-90c3-962edbff7461	2019-06-27 16:46:56+08	2020-03-29 14:36:11+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/finance.product.meal.list}	5	f	f	apiv4_PostFinanceProductMealList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2eb227fb-8b46-4b35-b537-fdac8974ef5a	2020-05-25 16:30:57+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/ads.plan.ip.block.quota}	5	f	f	apiv4_GetAdsPlanIpBlockQuota	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
946fbbb1-a439-4fe4-a448-9ba02969bb1e	2019-06-27 16:47:12+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.unrequest}	5	f	f	apiv4_invoice_getsUnrequest	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0fbd51c3-8ccf-4c12-b44d-c4811a66b3dc	2019-06-27 16:46:56+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.cloud.monitor.alarm}	5	f	f	apiv4_PostSendnoticeCloudMonitorAlarm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cdcf04b3-c697-4439-aa45-d938943511d8	2019-06-27 16:46:56+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.risk.detection.alarm}	5	f	f	apiv4_PostSendnoticeRiskDetectionAlarm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
9697347a-8f46-44bd-a554-a3223a6da64b	2019-06-27 16:46:56+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/sendnotice.weakness.scan.alarm}	5	f	f	apiv4_PostSendnoticeWeaknessScanAlarm	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cc1bfb8d-cce5-47ad-9f2d-a8938d242d2e	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/cloud.speed.create.order}	5	f	f	apiv4_PostCloudSpeedCreateOrder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
3c958ba6-3e60-4ec3-8974-d70b06debacc	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/taiji.plus.create.order}	5	f	f	apiv4_PostTaijiPlusCreateOrder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
cc46f9a1-b4e4-4e8e-9ecf-aadc143b423a	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/taiji.web.create.order}	5	f	f	apiv4_PostTaijiWebCreateOrder	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
0c2b963a-d315-4383-8fc1-262f3a2c24a1	2019-06-27 16:46:55+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/finance.order.cancel}	5	f	f	apiv4_PostFinanceOrderCancel	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
717864fd-def7-4abf-887b-0495dc584fbe	2020-04-10 10:51:03+08	2021-01-01 21:36:34+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/ads.plan.ip.block.add}	5	f	f	apiv4_PostAdsPlanIpBlockAdd	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b5306cea-ab34-497d-8d81-107315cc295c	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.log.download.template.all}	5	f	f	apiv4_LogDownloadTemplate_allTemplate	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
28397787-2c80-416a-b7c7-3814e547da70	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.log.download.template.group.all}	5	f	f	apiv4_LogDownloadTemplate_allTemplateGroup	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
024f9c1b-76f4-45e1-a47b-b356fb6ae1f4	2020-07-16 15:12:20+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/finance.recharge.baofu_Recharge}	5	f	f	apiv4_baofuRecharge	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
2477316e-76cd-4ebc-b0ea-ab8ff34e15d2	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.template.batch.change.status}	5	f	f	apiv4_LogDownloadTemplate_batchChangeStatus	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
1bc6e938-b4bd-4f15-91d5-5e6bbd945674	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.log.download.template.batch.del}	5	f	f	apiv4_LogDownloadTemplate_batchDelTemplate	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
c3df8ca6-f466-454b-9805-a715c52109aa	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.template.change.status}	5	f	f	apiv4_LogDownloadTemplate_changeStatus	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
8c033434-7db1-41e7-abba-fd866786896d	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{DELETE}	{}	{/user.ip.item.del}	5	f	f	service_cdn_User_ip_item_del	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
63b9efec-5eaa-4c9d-a99d-344ec3785962	2019-06-27 16:46:33+08	2020-03-29 14:36:07+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/tjkd.app.forward.rule.list}	5	f	f	apiv4_Get_postTjkdAppForwardRuleList	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4d7ccfe0-06be-42ac-a426-bef3be9c09cf	2019-06-27 16:46:56+08	2020-03-29 14:36:12+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/finance.order.notpay}	5	f	f	apiv4_PutFinanceOrderNotpay	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
e3de4925-edf6-4a4a-8886-d44d5dfd4525	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{POST}	{}	{/user.ip.item.all}	5	f	f	service_cdn_User_ip_item_del_check	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
b8903564-8f42-489d-a752-b5c6f830ad64	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{PUT}	{}	{/user.ip.item.edit}	5	f	f	service_cdn_User_ip_item_edit	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
7a6dfe5f-7e61-41d4-841f-623eeb8f29b0	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{POST}	{}	{/user.ip.item.file.save}	5	f	f	service_cdn_User_ip_item_file_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
bb8d0a25-3127-4952-9d20-cba88cb128a3	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{GET}	{}	{/user.ip.item.list}	5	f	f	service_cdn_User_ip_item_list	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
14864cd1-32ef-4377-9aeb-753d55ace802	2020-10-10 10:36:11+08	2020-10-10 10:36:11+08	b02334cc-f0d7-4b6b-9a0f-149db22f8809	{http,https}	{POST}	{}	{/user.ip.item.text.save}	5	f	f	service_cdn_User_ip_item_text_save	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
db482935-b8da-4f67-9385-d20ca8c86163	2020-05-13 13:36:32+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag_type/delete}	5	f	f	service_tag_TagTypeDelete	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
deb79e2a-a278-4233-81a6-ac31f1cdd84e	2020-04-19 22:19:39+08	2021-01-01 21:36:20+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET}	{}	{/tag_type/info}	5	f	f	service_tag_TagTypeInfo	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
d6aa3473-29f6-40e5-aa0d-2aa070f71688	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.ca.group.domain.list}	5	f	f	apiv4_getGroupDomainList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
7f7ac175-1f09-4fda-922d-fdc2c73de052	2019-06-08 18:19:54+08	2019-06-09 11:01:40+08	\N	{http,https}	{POST}	{yundunapiv4.test.nodevops.cn,kong.yundunapiv4.test.nodevops.cn}	{/V4/host.scan.addRecord}	5	t	f	addRecord	{}	{}	{}	{}	\N	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
1c7919fc-5f98-4ca6-88f6-ef5c5dd83435	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{"/V4/.well-known/acme-challenge/{token}"}	5	f	f	apiv4_getTokenValue	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
0ded033e-714b-4d34-b5ce-cfd03a9096f6	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/soc.log.download.template.del}	5	f	f	apiv4_LogDownloadTemplate_delTemplate	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
dcae85e2-8457-47f1-9241-635bdda102c5	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.log.download.template.save}	5	f	f	apiv4_LogDownloadTemplate_saveTemplate	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
25bef8e5-8e4d-4312-9eb4-f1b059bfe942	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.log.download.template.list}	5	f	f	apiv4_LogDownloadTemplate_templateList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
57384980-fdee-44f6-bce5-6afaae17d6f3	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/soc.property.host.ip.change.status}	5	f	f	apiv4_SocPropertyHostIp_changeAuthStatus	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
8f02e1bf-5c63-4a92-a120-e775f1331800	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.host.ip.export}	5	f	f	apiv4_SocPropertyHostIp_exportHostIpList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
12ea61e2-4b38-44a0-af7f-0b7b9af40a8f	2021-01-01 21:36:35+08	2021-01-01 21:36:35+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.all.host.ip}	5	f	f	apiv4_SocPropertyHostIp_getAllHostIp	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
dc11f1c6-c05d-4a8a-bbd5-a3204a398340	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.mapping.task.list}	5	f	f	apiv4_SocPropertyMappingTask_getMappingTaskList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
7a240802-0928-4241-a3d9-195263353c59	2019-11-08 12:12:14+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/firewall.zhengan.turn_domain}	5	f	f	apiv4_PostFirewallZhenganTurn_domain	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
8ea53160-dfae-4711-96f9-877e7c834939	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/soc.property.website.export}	5	f	f	apiv4_SocPropertyWebsite_exportWebsiteList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
96d22286-778f-4737-b617-08ff22294369	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.app.rule.list}	5	f	f	apiv4_ZeroTrustAppRule_getAppRules	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
ca534061-a234-4754-8415-062daf0ce588	2019-06-18 10:20:21+08	2021-05-10 12:25:39+08	16ebe251-c8c8-482f-9d60-4775b64ad0cd	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	{}	{/s_tag}	0	t	f	service_tag_uripre_s_tag	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
be3267f7-2445-46e7-a6ae-7edc3be8d7dc	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.saas.change.status}	5	f	f	apiv4_ZeroTrustSaasConf_changeStatus	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
91b3f8bf-d344-4d90-9dd9-f74172a0bd12	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.saas.conf.list}	5	f	f	apiv4_ZeroTrustSaasConf_confList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
0c03e6b3-3b59-4f81-a077-4be69acb1229	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{DELETE}	{}	{/V4/zero.trust.saas.conf.del}	5	f	f	apiv4_ZeroTrustSaasConf_delConf	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
c3cbe9ae-7400-4a3f-9c89-b6abb8006ed5	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/zero.trust.saas.conf.all}	5	f	f	apiv4_ZeroTrustSaasConf_getAllList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
74d2679c-9411-496e-9b47-06d4ec18bef4	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST,GET}	{}	{/V4/zero.trust.saas.conf.info}	5	f	f	apiv4_ZeroTrustSaasConf_getConfInfo	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
240c17e5-3cd5-4bf1-b3b1-1681ee5fd65f	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/zero.trust.saas.conf.save}	5	f	f	apiv4_ZeroTrustSaasConf_saveConf	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
face9b64-d07c-4e6c-a181-92ee09d8cead	2020-09-09 15:18:57+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.member.status}	5	f	f	apiv4_ZeroTrustMemberSso_getMemberZeroTrustStatus	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
653e111d-9d0f-451b-952e-cc9c2176df67	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/zero.trust.portal.rule.conf.fields}	5	f	f	apiv4_ZeroTrustMemberSso_getPortalRuleFields	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
1be808a4-2b35-43d4-a85b-11e07e689b94	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.remove.admin.token}	5	f	f	apiv4_ZeroTrustSso_removeAdminToken	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
fefadcce-7a3c-4047-971e-51cfabd246e3	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.remove.self.token}	5	f	f	apiv4_ZeroTrustSso_removeSelfUserToken	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
90936a30-ebeb-4ca5-89fa-2fe80d1c5d28	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.remove.user.token}	5	f	f	apiv4_ZeroTrustSso_removeUserToken	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
7fbe69c4-83c1-4290-b49f-f297b8df0c6d	2021-01-01 21:36:36+08	2021-01-01 21:36:36+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/zero.trust.portal.session.duration}	5	f	f	apiv4_ZeroTrustSso_savePortalSessionDuration	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
b99fd562-0490-4df3-9f71-0a7e0937962c	2020-03-07 00:16:30+08	2021-01-01 21:36:37+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/Web.Domain.DashBoard.cache.clean.detail}	5	f	f	apiv4_GetWebDomainDashboardCacheCleanDetail	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
a98209fd-24e7-490f-bb0c-dd85ab9fa40b	2021-01-01 21:36:38+08	2021-01-01 21:36:38+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET,POST}	{}	{/V4/invoice.member.edit}	5	f	f	apiv4_invoice_editMemberInvoice	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6024db51-3ef9-4f66-8292-a598070f7fd4	2020-09-09 15:19:00+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/permission.strategy.groups}	5	f	f	apiv4_GetPermissionStrategyGroups	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
58d39292-d450-4ec1-b3eb-8f050b284d6c	2019-09-17 13:53:12+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.formal_price}	5	f	f	apiv4_Order_formalPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
de63799a-c170-4103-a779-b86c334136ae	2019-10-23 11:50:42+08	2021-01-01 21:36:39+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/order.try_price}	5	f	f	apiv4_Order_tryPrice	{}	\N	\N	{}	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
4bc5d5d4-612d-486b-84f2-61a459f67835	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/disp.domain.group.info}	5	f	f	apiv4_domainGroupInfo	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
6b711730-0cee-4148-b708-b3a82cccc91f	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/dispatch.node.type.get}	5	f	f	apiv4_getNodeType	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
45bd6839-cbb7-4a26-baee-1935cff5f298	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tcp.forward.info}	5	f	f	apiv4_getTcpForwardInfo	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
5eaf9415-094f-488f-ae3b-95efdc9b2e38	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/tcp.forward.list}	5	f	f	apiv4_getTcpForwardList	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
9a650cd2-9d6f-400d-a646-38bc5e8c114a	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/disp.group.add}	5	f	f	apiv4_groupAdd	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
afe9fb92-8aea-4d98-a6de-b540ad30ccf6	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/disp.group.batch.remark}	5	f	f	apiv4_groupBatchRemark	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
debd6e86-fa3d-41f1-91d2-8ca7ad27d506	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/disp.group.bind.domain}	5	f	f	apiv4_groupBindDomain	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
b97d2cef-3955-4f8a-b124-7fbd6d8ef7ba	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/disp.group.edit}	5	f	f	apiv4_groupEdit	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
50717b37-5ec2-4eae-9321-dec57d02e872	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/disp.group.info}	5	f	f	apiv4_groupInfo	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
896eae63-8aca-4200-a353-37523e6d2d3a	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/disp.ippool.add}	5	f	f	apiv4_ipPoolAdd	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
677f31cb-7869-49ea-8808-7c60abf04fda	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/disp.ippool.batch.remark}	5	f	f	apiv4_ipPoolBatchRemark	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
b36e96c3-f4f7-4807-a018-b32dcdfd8370	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/disp.ippool.bind.group}	5	f	f	apiv4_ipPoolBindGroup	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
7ab68456-ff41-4a70-ba9d-ce898a0dbc07	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{PUT}	{}	{/V4/disp.ippool.edit}	5	f	f	apiv4_ipPoolEdit	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
1b423555-aba7-4488-a0ed-763b54de6d2e	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{GET}	{}	{/V4/disp.ippool.info}	5	f	f	apiv4_ipPoolInfo	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
fdfbe14e-c2b8-4eee-b8f3-5a5c4ae07b2a	2021-01-01 21:36:40+08	2021-01-01 21:36:40+08	f859c408-2893-44e7-baff-60d3ac8fcbd3	{http,https}	{POST}	{}	{/V4/tcp.forward.bind.group}	5	f	f	apiv4_tcpForwardBindGroup	{}	\N	\N	{}	426	\N	v0	9b57a89e-2dcf-40ad-a478-782b7457c157
574193ae-8341-4e93-a6f8-6e721429517c	2020-04-06 20:55:30+08	2021-01-01 21:37:30+08	0cadc5bf-9092-4000-9301-23bd6979e6f0	{http,https}	{GET,POST,PUT,PATCH,DELETE,OPTIONS}	\N	{/agw/oplog/console}	0	t	f	service_oplog_uripre_agw_oplog_console	\N	\N	\N	\N	426	\N	v1	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: schema_meta; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.schema_meta (key, subsystem, last_executed, executed, pending) FROM stdin;
schema_meta	acme	000_base_acme	{000_base_acme}	\N
schema_meta	core	009_200_to_210	{000_base,001_14_to_15,002_15_to_1,003_100_to_110,004_110_to_120,005_120_to_130,006_130_to_140,007_140_to_150,008_150_to_200,009_200_to_210}	{}
schema_meta	hmac-auth	003_200_to_210	{000_base_hmac_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	oauth2	004_200_to_210	{000_base_oauth2,001_14_to_15,002_15_to_10,003_130_to_140,004_200_to_210}	{}
schema_meta	ip-restriction	001_200_to_210	{001_200_to_210}	{}
schema_meta	jwt	003_200_to_210	{000_base_jwt,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	basic-auth	003_200_to_210	{000_base_basic_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	key-auth	003_200_to_210	{000_base_key_auth,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	response-ratelimiting	002_15_to_10	{000_base_response_rate_limiting,001_14_to_15,002_15_to_10}	{}
schema_meta	acl	003_200_to_210	{000_base_acl,001_14_to_15,002_130_to_140,003_200_to_210}	{}
schema_meta	bot-detection	001_200_to_210	{001_200_to_210}	{}
schema_meta	session	000_base_session	{000_base_session}	\N
schema_meta	rate-limiting	004_200_to_210	{000_base_rate_limiting,001_14_to_15,002_15_to_10,003_10_to_112,004_200_to_210}	{}
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.services (id, created_at, updated_at, name, retries, protocol, host, port, path, connect_timeout, write_timeout, read_timeout, tags, client_certificate_id, tls_verify, tls_verify_depth, ca_certificates, ws_id) FROM stdin;
7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	2019-05-07 20:45:02+08	2019-05-07 20:45:42+08	homev5	5	http	homev5.kong.test.nodevops.cn	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
4da87494-91dd-48e3-ae5b-b2943397cf6c	2019-08-05 14:26:12+08	2019-08-05 14:26:12+08	example-service	5	http	github.com	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
b02334cc-f0d7-4b6b-9a0f-149db22f8809	2020-09-09 17:47:34+08	2020-10-10 10:36:11+08	service_cdn	5	http	service_cdn	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
de2547a8-e779-4bd3-9146-72ec9d34dcfe	2019-06-18 11:00:47+08	2021-01-01 21:36:17+08	service_asset	5	http	service_asset	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
16ebe251-c8c8-482f-9d60-4775b64ad0cd	2019-06-17 08:44:04+08	2021-01-01 21:36:20+08	service_tag	5	http	service_tag	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
88dde9c8-8a9c-4e12-84ce-4348ee825bb5	2019-07-12 13:49:50+08	2021-01-01 21:36:23+08	service_disp	5	http	service_disp	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
1710d7c1-d63d-418c-a0cc-8dc6d475fc41	2020-08-04 15:31:14+08	2021-01-01 21:36:29+08	dns_check	5	http	dns_check	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
659daf51-d0e8-46b3-8867-f6c4051582c7	2020-04-19 17:41:03+08	2020-04-19 22:22:05+08	ads	5	http	ads	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
6418f317-1360-47c5-8665-e9023fac68fe	2019-12-13 13:41:22+08	2021-01-01 21:36:32+08	service_batch	5	http	service_batch	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f859c408-2893-44e7-baff-60d3ac8fcbd3	2019-06-14 19:13:26+08	2021-01-01 21:36:34+08	apiv4	5	http	apiv4	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0cadc5bf-9092-4000-9301-23bd6979e6f0	2020-03-03 14:50:40+08	2021-01-01 21:37:29+08	service_oplog	5	http	service_oplog	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
df264124-bf20-4629-9d7c-e0fe9fa63d89	2019-12-10 15:48:06+08	2021-01-01 21:37:32+08	service_notify	5	http	service_notify	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	2019-12-12 18:01:13+08	2020-04-06 21:04:45+08	service_dns	5	http	service_dns	80	\N	60000	60000	60000	\N	\N	\N	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.sessions (id, session_id, expires, data, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: snis; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.snis (id, created_at, name, certificate_id, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.tags (entity_id, entity_name, tags) FROM stdin;
7ef32598-bbc8-4e5f-99ef-9e3ce6be0a80	services	\N
ae773d9b-9bdf-4892-b3c1-f2275751e465	routes	{}
bfb04dbb-d615-4e4f-8b57-118c48f17468	routes	{}
bd60db2a-877b-4c0a-a287-da3024fa2290	consumers	\N
c1ed0d61-452e-4e87-87e2-c91355141075	routes	{}
cfb6de99-afca-4774-bf96-fb91f84cb989	routes	{}
2dd4d53e-ea98-4e7c-b785-97e8b31f8b81	routes	{}
06f47b2f-a7fd-4ae9-af64-0cc42027e015	routes	{}
7de80d7f-96e9-4be2-a210-989024321cf3	routes	{}
240404a7-ee8f-4951-89a1-9a63b35c8984	routes	{}
91c6e50e-6b45-400d-9966-7bfb976a71c8	routes	{}
b984bbb9-da15-4cc2-9eea-de8089228575	routes	{}
0fcc7272-ceda-4745-a689-62934ae6739c	routes	{}
576ac97d-9c6b-4d30-bfad-a3114ce0a9f1	routes	{}
08e54cfe-60c7-45a4-9cb7-2366ba7ba2a5	routes	{}
96bff0dc-941e-4e32-bb16-32338a6bd291	routes	{}
a4b9309b-c609-48c7-abab-41f075b8ffa2	routes	{}
9db01cc0-6bd0-416f-b81d-2918c19adb4b	routes	{}
2fa30fef-7a5c-4500-95f8-3b39b85783ff	routes	{}
eb5e6c34-10c9-4e1e-941d-097532ee4f99	routes	{}
71ecac82-b558-4ea2-9db6-98e14aa3fcd4	routes	{}
f3748564-6ebb-4031-8f29-e2baa7c28e9b	routes	{}
a4647699-8955-4feb-a93d-550bdb249ee8	routes	{}
cba0bb69-730d-42fa-bf04-c67c7291a65d	routes	{}
dbfd518d-bcf6-4f35-b6d0-224f460c5422	upstreams	\N
b02334cc-f0d7-4b6b-9a0f-149db22f8809	services	\N
f92e1085-f8b6-4d7b-bd74-2a97f8f53426	routes	\N
36f29636-1822-499c-b6a1-ead8f88552f6	routes	\N
e741f1a1-fb3c-4775-92e4-7483c3a1d9b5	routes	{}
7dd7de99-414a-40f2-bc93-a9509705f884	routes	{}
77072076-8a4a-4051-8008-fc0ed365665c	routes	{}
859d34c1-eda8-40b3-9f21-62f000e4ba6e	routes	{}
6d6aa303-b40f-4801-b4ac-9a5dca13b520	routes	{}
bfbc518e-1f87-4f52-a212-46406b585c92	routes	{}
af18c4bd-6879-497e-be5f-9f8e7b238a2a	routes	{}
23d8463a-d9b6-4956-bc43-86e024c86acb	routes	\N
492aa7ab-d8a2-4ed2-a084-4bf322ca817a	routes	{}
cb3b8034-4e50-4967-951b-a4f02bb2714b	routes	{}
eb2637c8-279a-45c4-8cde-aee6927e7b10	routes	{}
8e9a9df8-ea20-4a9b-a51e-d3ede554ad28	routes	{}
72c0f629-1d6e-426e-a517-cecc2dcae3d2	routes	{}
672ef9c0-9d6b-40a0-851b-9f5b9e37cf1e	routes	{}
973c5834-82de-4bf6-8a5d-1891ca2c9b7d	routes	{}
c96c2c9e-24ba-4254-85fb-acadf3676731	routes	{}
650bcdc6-feeb-46ed-9d6b-48f561b040ed	routes	{}
4737288c-47b9-4b9a-b6b8-534b1466cb8f	routes	{}
8a1fa4ed-2f89-4861-9a90-12005d1fc89d	routes	{}
1da96c3f-9f68-437a-bbb3-4fa44a98e148	routes	{}
7cc1bff8-1ec3-4e04-a0ad-36586378ef0d	routes	{}
c6eeea26-d833-407f-85b0-9e750773dc67	routes	{}
74f5c0fe-ebc2-4516-a093-a71aa775fc13	routes	{}
f41efb66-a433-4f4d-a52c-32059fddcd3f	routes	{}
a0e6aeff-3158-493d-8086-c58e19fdf6d1	routes	{}
d8d53cd4-d04c-4a02-bff9-113ce630832b	routes	{}
a292c360-1ab4-4918-ae01-17875b3767c5	routes	{}
c94ad7bd-aae9-47ee-8729-46fa83e3c851	routes	{}
5644ce8f-62ba-4b5f-ae42-7fd81328d9d5	routes	{}
b85b9f07-b890-445c-b55c-fae525a34968	routes	{}
77b45228-2da3-4da5-b6ed-4c0c358573df	routes	{}
d1d79790-a631-41e8-b4c0-47542f9c47ac	routes	{}
42b0afe8-58d1-42b1-a8f7-d6fac7d3cb1d	routes	{}
b2a542fe-8098-47ac-b230-8477b3c98f6a	routes	{}
44c21064-e483-4eb0-a717-a37ff1a1954a	routes	{}
367b0666-dbb2-4b2d-b610-b05cfca0b0a6	routes	{}
3bc9dc2d-42b0-48ef-a22a-069b03f1528e	routes	{}
180833ab-c021-4b65-adf6-0ffcd30a9433	routes	{}
ea42473e-aa05-4f4d-882a-40e065bf89fd	plugins	\N
2c663d4a-93be-415b-8f75-4636e6335737	routes	{}
e4e69ed2-82b7-4314-9a13-ab9c5deb5c09	routes	{}
418c7c41-cb37-4111-92ef-0c3af10655af	routes	\N
0261ef7c-897f-4235-b5c0-8774f16346ec	routes	{}
f7be5b5b-539a-4b49-b2d2-fdcacc60bffd	routes	{}
91c18e67-0b17-44d2-ac60-297c678d8ea4	routes	{}
79c37c16-7f10-4881-99d2-2c10f0e1118e	routes	{}
dc0cda60-b532-4511-8c28-5a10f7a3832e	routes	\N
0e8bc7f8-fb2e-49cb-ab88-1925a8b8dc26	routes	{}
502002c2-d6f2-443b-8a65-5b2f98c866d4	routes	{}
767efe60-fded-4248-80b2-22ac89bc9f9e	routes	\N
a0af1a7d-c54c-4b61-9230-ae2f7b79c414	routes	{}
9e75a0b5-a1fe-443b-93e1-d1d89f4b07cd	upstreams	\N
df264124-bf20-4629-9d7c-e0fe9fa63d89	services	\N
fecaceb4-c73b-41bd-8e43-9b767d011fd4	targets	\N
23ab7040-0df9-4da2-ac9a-4fe99ce5bab8	targets	\N
bac1835f-b82e-474c-8b1f-6cd8fa608bec	routes	{}
a84cd075-2eca-44a7-af6f-c37229a3dc61	routes	{}
d7618cd0-057c-4b86-aceb-98f6aeede769	upstreams	\N
1710d7c1-d63d-418c-a0cc-8dc6d475fc41	services	\N
592beeed-3e91-4bb4-a97b-26e83d9abd22	targets	\N
5fe9fd23-6768-4c8c-b911-cea32c84e582	routes	\N
709f63c5-1a86-4268-a406-3da74ffc4cb5	routes	{}
dc73e53b-a44b-4386-ae95-146933a3b7d8	routes	{}
627dcfa2-b0c1-4d41-a52e-cf11e525d806	routes	{}
476ad275-0da1-4c88-954f-0cd3b1540330	routes	{}
392f1393-7963-4755-893b-2e4cefd08b8a	routes	{}
b99fd562-0490-4df3-9f71-0a7e0937962c	routes	{}
78afe70c-c52b-4699-805f-b4cf316e1b5a	routes	{}
b755ebe2-ed16-45ca-9f6a-98b0790587cd	routes	{}
f8fab4a9-77f0-4eb9-8119-c3ed2bb5bb92	routes	{}
6ada0aad-7dee-46d5-9984-dbd223d6c598	routes	{}
2ccc2184-2e0b-45e3-a486-18db51d0fda3	routes	{}
4ef492db-deb8-45e7-9a98-f92bb66cbdc5	routes	{}
3e2b684e-c88e-4573-8885-e801e348ea86	routes	{}
2c8f96ae-30bb-4c64-8627-b0f09834df83	routes	{}
f9124ba7-9b5b-4d3a-b4a9-36d93e31939d	routes	{}
bfb1ec68-0b25-44ea-8f7e-cc65e4d8a979	routes	{}
f37e9df1-b638-4ea7-ba75-61d585ccd4cb	routes	{}
2e36d674-e687-4bf5-9e20-5ed6548b8b26	routes	{}
1e773f7f-afb0-4f7a-9201-f7a641d12414	routes	{}
68f4cac0-a4b3-40eb-b4a7-66418796c1f7	routes	{}
1b21ccf7-1e27-4dac-9863-f42ee5a2ec93	routes	{}
ff453733-3487-40b5-9ba2-9526caaa3427	routes	{}
53be28d5-5073-40a6-be3f-bfd852779e25	routes	{}
3c670964-cb36-48a4-9e08-e41225f0a695	routes	{}
559ddeab-cd9d-4034-a5c8-e85135ae50d3	routes	{}
365f6c81-c71c-47f3-bb79-c01bbd44c07a	routes	{}
3762b1ac-b769-4d22-a9bf-441fc9bc37d8	routes	{}
2ea555a7-3545-4822-8287-e6d2e5af5b7e	routes	{}
7f0fbfb9-5bdc-42cb-9866-2d5bc421f2c4	routes	{}
54edd64d-9fbe-417e-8ecd-d4a290678999	routes	{}
b2f37cd4-9914-4492-8229-4638a89e8a72	routes	{}
d6d439cb-f07d-4d6f-a84b-57a4fcd41cec	routes	{}
69f7013c-8bf7-4a19-b270-feab116d63c6	routes	{}
4ce3c98f-8373-49a3-aba8-f29a421b7acc	routes	{}
8c506cc1-c2cf-4e7e-85f6-39be8944cbc4	routes	\N
b9708018-04fc-4e8a-9a43-edc696d9f06e	routes	{}
ffa375c3-da9f-4e9e-9b2b-97c8545ad65e	routes	{}
e5e5bc29-178d-4ccc-860c-1dadadb42687	routes	{}
92bc8c56-ae88-42ae-97f8-c16c9f8d3473	routes	{}
95bddf8a-c984-4588-bf75-345b1dc0c03a	routes	\N
7ffca55f-c4eb-4d3c-8463-b61005284651	routes	{}
028b42af-efd6-40f7-a45c-127a7bdd5943	routes	{}
1045f54e-f6d0-4557-967a-90c9aadd44fb	routes	{}
a36eb4e9-8622-485f-ad58-85fe7df793d7	routes	{}
b33f0b0e-11b2-46ec-a164-619f176668eb	routes	{}
6a335eed-fcad-43cd-883e-0a668c6b61b0	routes	{}
9313e7a4-0385-404e-9f8c-f638a965495f	routes	{}
b4de2654-3343-4894-8f73-c859b5eac1e2	routes	{}
f6438bb0-b419-42eb-8378-7d54e43b58d6	routes	{}
a64a9301-ba45-483e-807c-43b4b90047d5	routes	{}
6ef503a8-4c4c-457d-bbec-0770145a624c	routes	{}
e1eadde4-ec5d-4b98-9bbd-022e2548a10f	routes	{}
27659ccc-9c7f-49d6-942f-5446c4f3374f	routes	{}
f2bd20e5-3a0c-4aa2-81c6-f2282d1e3400	routes	{}
542396d8-ef0d-4370-b0ae-232290d26bd6	routes	{}
dd5ba993-cf99-43b0-b65d-fcc32addb0bf	routes	{}
b9f703fd-4cd4-4951-a7eb-22ea1a768e9b	routes	{}
87d89dc6-0085-4e9a-be04-1d917fa9532e	routes	{}
f94b471a-76fc-4b7a-8a79-9e3991062805	routes	{}
1652433f-d83b-4914-865c-a37991bb42da	routes	{}
89aeb733-dc1a-481a-bc21-2b0f3c52de62	routes	{}
f3822137-6fe0-4f30-b9f7-881dbaf8b41e	routes	{}
f1648051-3e87-432a-a97e-069aff271b9d	routes	{}
f34c672e-5839-49e5-8dee-a30eada63dd8	routes	{}
4d7df6ac-c38b-47b8-8b8f-570675931b10	routes	{}
0c3437b0-5d78-47af-b62c-aac41a22bc93	routes	{}
a8d1aadf-f6ea-411d-aa92-cc37ce1a179e	routes	{}
1e0007db-6925-4af2-826a-b662ef3bc3d6	routes	{}
daf78c30-8b60-4b19-9629-71484696c56b	routes	{}
b2efced5-f9c0-4dc9-aa65-970524c65800	routes	{}
3b6bde8c-8b84-433a-b858-2ca17a40f7c6	routes	{}
6179dc98-5c79-456c-b334-d8034b8349ef	routes	{}
618cb810-ad86-44ef-9955-e497e1bcd199	routes	{}
9d241191-d5b7-40ef-866e-95f8bb18975f	routes	{}
9850bf76-1295-4138-b5ba-504fd7c0ea33	routes	{}
5ef7a02c-0670-4836-a975-98ea582c184c	routes	{}
14036ec0-a2ac-4024-8d09-95f2a2702abb	routes	{}
33f09184-c533-479b-a86d-71f954d1184f	routes	{}
72696043-6a44-4a3c-b6c8-9f87e09a0f96	routes	{}
1f005e17-2ed8-4f1c-97c2-0cb98cd10d81	routes	{}
30489db9-58a9-4fb2-bfa4-772ed53bd46f	routes	{}
b9da0573-2b5f-490e-8692-218aacaf49c8	routes	{}
05cdec41-1bce-416d-b7ff-1e1fefa6c64d	routes	{}
9fc479c6-9200-4352-95d9-bfeaf544653b	routes	{}
8097bb67-84e6-4439-a600-2794a732d5e9	routes	{}
c55946df-05f3-4da0-b6b9-faba7d34b144	routes	{}
6bb5a3d0-0148-4087-badf-f7bd2edeba9b	routes	{}
b1bc588d-bf89-431b-8d11-c0a67c04255e	routes	{}
5517c44f-3174-46b5-9089-c1ce03291379	routes	{}
de9aa3e1-c16c-4729-9e06-d8a631bee628	routes	{}
9515d782-0399-4f44-b43f-11e7037d2d5d	routes	{}
ee3fc66c-de97-4196-bdc2-f31ae81d9f54	plugins	\N
331a9f46-88e5-41fa-bcd6-b8f84e58e8e4	routes	{}
5b09a292-882d-4b23-a049-394f68eda45c	routes	{}
f068c433-9a47-4cea-a8f7-fa85736b69c9	routes	{}
ad17f640-f070-4808-b007-cc6a0ba88748	routes	{}
370df230-5770-4bde-9f73-8217bd96bd55	routes	{}
e9188cdb-6595-4487-a588-f93a492940b9	targets	\N
7c95a52e-4604-4e52-9ee6-4bc34e896b6c	routes	\N
1459d67d-7631-497b-95e9-044008b1adec	routes	{}
1e4915d0-5d99-4ad6-bd13-b999bd3aa9f9	routes	{}
4d6db761-02ec-4c4b-b5fc-5e91ff2ce8e7	routes	{}
240357c2-87c3-45e8-b1f4-a1e0b5272123	routes	{}
8b999772-62a9-4c3a-a5eb-a7ff44407b4e	routes	{}
2429cbc7-aaab-417a-bc37-5772d0857d25	routes	{}
afa6a1c9-a1af-4829-a0f8-770e78266d41	routes	{}
dba9d2f0-8103-4542-9698-f3b800f2c0b2	routes	{}
0065e823-5483-4bae-a68e-2910a10559df	routes	{}
feaef837-7fdf-46c9-84d5-239653e7d84a	routes	{}
db397b07-3bb2-418a-a0d4-eb49563e2de5	routes	{}
d3cda90f-b773-4a25-bd89-9cec12c82ad2	routes	{}
050227f7-ef77-485e-a260-7fe3e0ead77b	routes	{}
5d090b37-d40a-4197-8871-db35f84c4258	routes	{}
f0c9e38b-b313-4f76-a636-c3756f95525d	routes	{}
d1e33816-da2f-4dc3-93b4-9de0dd5c0d78	routes	\N
01b9cb4a-c3f8-4766-bf9b-c6bce2ed2809	routes	{}
25da8c2a-705d-4803-91f2-dec7546edf3e	routes	{}
e69934b0-2c3d-4d3d-b71f-5212752bf2cf	routes	{}
beef7e6d-0dac-4e58-8b12-b371babfb7d2	routes	{}
06554b79-433f-427c-aca8-713372946201	routes	{}
602d0d5a-6373-4d76-8ef1-1dc114cc4b7d	routes	{}
599b9bcc-55a8-42ff-8337-74dd1cbc8c5c	routes	{}
adfbd3a6-bf3b-4306-b940-c97b280b1b50	routes	{}
31ec77bf-718e-4374-895b-96c54c8fbdbf	routes	{}
ca36d26a-df2a-43d0-9829-39ce92ed9e42	routes	{}
9bb347b0-3197-4fe8-bcae-845ee3340c57	routes	{}
f79951e9-e57e-447a-8ab7-db9421f49872	routes	{}
60da1527-ca67-4dc5-8f1c-926994c83e00	routes	{}
036ef6d9-a5e2-4482-b932-dbf0877c79d6	routes	{}
e0369f35-c832-4f2d-b0aa-1ea91a9e603d	routes	{}
af464f08-6e87-4486-8da0-87968e511b1d	routes	{}
94a9418e-242f-4234-a9c1-2073ed86546d	routes	{}
04a95946-846e-4c26-9c06-b66e027ee8a6	routes	{}
ebef31ed-8832-4ece-a5c2-a7e67a4cc7ec	routes	{}
b26a4369-5cf7-4a3b-9c7b-c284df4538df	routes	{}
243a1502-f164-40e4-98c1-e8a28f25c49b	routes	{}
a3a8463c-a78d-4a50-9417-cf88a581a34e	routes	{}
d8400932-6706-423a-be4d-149e11227d60	routes	{}
0fead794-feb8-4869-adc1-d905f5ee22e4	routes	{}
9dbf6372-b68c-405b-8771-04d975a6697e	routes	{}
6cb3a824-989c-4d4d-8fcc-f79324698f0d	routes	{}
1a3877a7-117b-4097-a091-c534df78596b	routes	{}
2249ddb9-c055-4e2b-a2b6-115994a71c1c	routes	{}
7d58f7a4-1b0f-4f55-92c5-a63fd49193a6	routes	{}
01b88980-d4b8-4fb3-945c-f937fbb59c28	routes	{}
ecb2f20e-04ed-4f7d-a7bd-75a1a1f7cb29	routes	{}
bb884ed9-32b9-4bd1-8b4f-69ed531c65c9	routes	{}
cab093dd-6f3b-497f-abf1-c4e6b6057121	routes	{}
ff44be98-c3c3-457e-a6e8-b1b7d67eef9a	routes	{}
c3fcc1be-0173-4c19-b85c-017772fb0854	routes	{}
d8be5812-f817-4f2c-ac12-c21b0386f99a	routes	{}
7f77bb5d-9629-4020-b058-16669c207e86	routes	{}
2f8574c6-cf8b-47fe-9aa5-72e8f1c3aaa7	routes	{}
b8090ba1-2faa-4ba3-ac2b-1fb496cd0ca0	routes	\N
6ca18272-176e-4366-95f7-b652a50d29f5	routes	{}
b54f8ab4-9b62-4953-90be-b8ed56cf3cfd	routes	{}
5ca44046-b5f9-4112-b63e-0bd8fa220fac	routes	{}
7e3b45d5-6a1f-4a9a-ab5c-acb37c7e52d5	routes	{}
4cd95fe0-f40b-4e80-95d9-ae09d5e2e5b0	routes	{}
902d3a13-d3eb-4b52-9dda-0ca195950278	routes	{}
3c05c095-95b3-458b-a26a-11b878a19816	routes	{}
fa7b303e-0d9a-4fc6-b585-05e2f5e98d21	routes	{}
2b7e5a30-6abe-4d0a-9c51-a161243386fa	routes	{}
a67b2d65-521b-45ec-afe1-6520b28590f6	routes	{}
2ca90677-96c6-42b7-8ff5-827e2e362784	routes	{}
496c89a3-9516-44e8-9d84-3e28ebbe0e26	routes	{}
6c9ed579-5b60-4702-a4d3-791189e75301	routes	{}
d85e71b6-8c2d-4d68-bce0-ef3626eee792	routes	{}
9b262ee5-75b0-419d-b24e-70ad91f561b4	routes	{}
c66e3014-9530-4543-bdf9-0b5ecd266891	routes	{}
4874a0c2-b775-4f66-8301-7c4db80b1f30	routes	{}
d7a92822-1876-429e-abaa-81901d4d0092	routes	{}
3ac234b8-343d-46af-aba6-0f2d6312abb5	routes	{}
81c20d88-dc2a-4b37-bab9-5ebe2f9a83cc	routes	{}
00f08394-7ca6-424e-a7d6-57e81fe4df77	routes	{}
acaa9bb4-4593-4033-ad2d-ed883090e963	routes	{}
1f04bd0d-ea9c-499f-aa67-12429e0e88bf	routes	{}
3b222ab0-31a9-4111-9423-d696fe8d421a	routes	{}
66f6fb1b-10d9-47c8-b421-353c92403410	routes	{}
cb14b0f1-0598-492f-a40e-74e85949e050	routes	{}
396402d3-df74-4e22-bd59-7823d23738a6	routes	{}
3b08a341-14f4-469a-9b70-c4d6f69e5c2a	routes	{}
4184f2de-e7a8-4f8c-8703-ae28f29d42f3	routes	{}
041f912a-bd6a-4dee-99d0-a7360706ce5a	routes	{}
368c7dd9-123b-4a47-8e1a-fede50b871c3	routes	{}
11f16f24-73fe-4ba0-a39e-78818cb208d7	routes	{}
acd9ad3f-ae02-43fd-aaff-c2f3ab9188eb	routes	{}
4f2e5b2d-19f2-477d-b1f5-808352819646	routes	{}
8e73b4ac-4f5d-4734-b0ed-186f7dfa56eb	routes	{}
e0b44017-26af-4b11-bca6-7af83e4a9456	routes	{}
cbd67e12-c342-4f82-adca-52cfe5fcf7a9	routes	{}
49784e90-d6e2-419e-8614-99b9796c0eb5	routes	{}
5d24825c-4b7e-44ef-b8d6-f524d17725ec	routes	{}
28b3fd33-2f25-45ca-ab63-49eaf8796bc6	routes	{}
ae22bc0a-3343-49f8-9f73-03498a8c37ae	routes	{}
e2a03a1b-f438-477f-a50a-5eae9fe043de	routes	{}
1086acae-0933-4cdb-92dc-433c749eb680	routes	{}
780b5ac8-e304-4da2-ab25-b52a5a406e43	routes	{}
ccbcde6e-d2ef-49dd-8b16-81e98b0b09f5	routes	{}
afa3e77b-6a2a-43bc-a0a8-d10f9f9fb630	routes	{}
a9c07314-35cf-41bd-964a-7a15cc41e757	routes	{}
e8e1689d-357f-4e22-984d-dba4b8265daf	routes	{}
cdd8a946-b664-4fc4-b271-55c79a00a220	routes	{}
f662b383-9c41-43e2-9f72-adf42caa9aa4	routes	{}
247c9981-3800-407a-b586-b772d490da9a	routes	{}
02f85448-3fa4-459c-925d-58349480a84e	routes	{}
f55cd8f6-355f-42d8-a720-5f23fb49c8a0	plugins	\N
f7dd7230-ef90-47d9-ba22-4a4787eaedc3	routes	{}
36f2aa4a-9e4d-45f0-809c-2be428990803	routes	{}
5112f813-cf2f-4632-97dd-c73e418f1f20	routes	{}
64d15392-08fa-49d2-8e1c-768ee6ec1c0c	routes	{}
1a7692d1-e0b4-4ccb-a7e4-3eaa0a82b57b	routes	\N
6d7cbaa8-a327-4557-825e-08688bf31462	routes	{}
8fea4b40-0cc8-402b-9ce0-9fc03fd4e4d9	plugins	\N
60d64212-62a5-4c7f-b134-50ef536b9130	routes	{}
671e0c28-852e-463f-a8b6-5efb300487e8	routes	{}
6494eaff-1fec-4300-b3c2-cac8dd9b0cb1	routes	{}
49644b49-e27c-4fb3-91d5-6905cb4636f0	routes	{}
a513f782-e6b9-4e5a-bba6-db026291cc00	routes	{}
7cea0c0e-e348-4fe3-a4fd-06fb8a24c3b0	routes	{}
4787c1e4-df7f-4fad-9c70-e17222c019a3	routes	{}
d26e807a-7b4e-49d7-9a90-b6eae45f8a9c	routes	{}
0c4452f6-0f47-432f-a2c9-1f453c6fd490	routes	{}
c226d34d-a1da-4a39-a4bf-de7fda8ffe9c	routes	{}
7a90fbee-72bf-404f-bcf5-c3a01884b146	routes	{}
5193048d-a90a-4fc9-8499-fd30b89b9d52	routes	{}
50c500cd-7926-4a9d-9edc-45c2497c8023	routes	{}
7c7511f1-589b-45fb-85d1-201d67bf5e66	routes	{}
42f28363-2f41-42cb-ab46-5010ffb584bf	routes	{}
2a168562-c719-47d0-8df6-727f788084fd	routes	{}
2da37c7e-652f-4f31-b209-40c6184720cb	routes	{}
92440477-8799-43c2-b254-f8b9642a23ff	routes	{}
deb79e2a-a278-4233-81a6-ac31f1cdd84e	routes	{}
c52026c4-2ba2-4e59-a5f8-7cf2a1fd8d0e	routes	{}
b2daa10f-26cf-4fee-bd7f-7ede5381ca6b	routes	{}
fd4aadaf-5c77-43c2-b3a5-7b1ab320e54a	routes	{}
cec7d2c3-0f7f-42dc-828f-a121a5d4f7fa	routes	{}
9ca810d7-8eb4-4bbf-81fe-8ff08ba4f181	routes	{}
959ddfe2-9562-4d9d-ab28-7fa832e24fe0	routes	{}
25d48655-7eac-4236-8302-e4904cd47928	routes	{}
5bf84f09-e0f0-4016-abcd-ed9c444953f0	routes	{}
a2e92834-0e05-4960-adc8-6024ff82a3a5	routes	{}
88a315f7-b05b-434d-b605-4e7c7f194102	routes	{}
cceb90cd-556b-4296-9547-3a19b847bd35	routes	{}
69d9725d-8d7d-49db-be96-4372c02bf86a	routes	{}
0f042cf5-ba05-421c-8229-5b4339d3d2e7	routes	{}
d96b4ee0-c656-4623-8c0c-16b1108b2de9	routes	{}
d001a265-ec14-468f-bd4d-c3631539eb1f	routes	{}
746189d5-cac8-4598-b3fe-af0f7ac8fe5a	routes	{}
1343d0d3-fd76-4bf6-b02e-bff380994a80	routes	{}
cd1ebde2-47ee-4723-b389-7a6818578c66	routes	{}
c120d6c3-b3e3-4ca3-ad63-4694cdedbe1c	routes	{}
5063feec-0c2b-44da-a8d2-ade6b8bd2a86	routes	{}
8f33ccd0-f79c-446a-af3b-0d3ef697920e	routes	{}
57ad57d4-d558-4989-9c88-d9e204aa6af4	routes	{}
c8adedbf-e18e-4cb2-aabf-9e8f0c1017fe	routes	{}
3f7b972a-c532-4bfd-a8fa-db83f7a311aa	routes	{}
d2bcc5b3-1282-414d-aade-efe1f0841eec	routes	{}
12f220aa-61a7-4355-bdc4-c6986d005229	routes	{}
6343f485-5d16-4226-95c2-da3b32d144a5	routes	{}
fceea9e8-e919-4162-a378-45fb2dd5a1af	routes	{}
d971c7a6-dfc3-4918-9da4-219863af25ff	routes	{}
ba8e6441-6a99-4492-aa37-0a704a1c2434	routes	\N
d96449a5-e018-4eea-b4f2-064e588ec361	routes	{}
98026142-ac75-4256-94c8-c673657a395c	routes	{}
32aa9a58-b3ad-44c7-bcc4-c6b75001b995	routes	{}
16bc126a-4850-42d6-b01a-2eeddec8144c	routes	{}
86d8700c-3c3d-4a93-9844-eadf4c9b078d	routes	{}
e4b99411-f68c-4880-b34d-9835e851efb9	routes	\N
e2f3471c-3dcc-4a10-a80f-cbca42454adc	routes	{}
ad1219f3-5c01-41b7-9215-2eff6643723a	routes	{}
16634c41-0cf8-41ee-8700-230e0b918ff4	routes	{}
6b791ff8-a47e-4130-bf52-3ee162f19ac0	routes	{}
6cac144b-4e1a-4ce2-a8af-9a131ce6f78d	routes	{}
ee1c38c8-7230-4ef0-8b66-c2a3809564e3	routes	{}
8901bd0a-9b14-4b71-b2c7-38b956d67464	targets	\N
b7e66a4e-29be-4bc9-8e0c-0fe611ba7d2d	routes	\N
1e8d5b9a-3e8c-49d1-8cc6-f06155aa4005	routes	{}
574193ae-8341-4e93-a6f8-6e721429517c	routes	\N
ddfcd00f-2cf0-485c-ac7b-46fb5cae8ba4	routes	\N
99e11fa5-fa5e-40f3-92fb-17dd3bedf71e	routes	{}
a8cca660-6ba4-4416-a668-37a79e175a55	routes	{}
2a8ef125-0933-4047-b50a-dc7a82bdc618	routes	{}
9f929811-efbc-4bae-86c8-c5975a1785b1	routes	{}
5ded6d0a-0da0-45a6-9a97-2be1aeed7e2d	routes	{}
6fea94f0-aaa5-45e8-8e32-b82d7b6e32cf	routes	{}
f6e94ab1-460c-47b0-85fa-af75094f3af7	routes	{}
2c9e14bc-7e5f-4677-8d2a-513c2c6ce30b	routes	{}
5ed97a7f-3bf3-4269-8810-c25ba0e220d3	routes	{}
3929ad5e-9c99-4b84-bda4-fdc070495fc9	routes	{}
5465e5ed-af15-420b-96eb-a0b67638bfaf	routes	{}
c0c026c1-6c90-4a5a-8557-f8b5a0e7ad40	routes	{}
e64b93e9-655c-4f1b-b700-befef4dc3f91	routes	{}
313ef525-d5ce-4d3c-9872-fcf8f50ae9bf	routes	{}
5e38affb-caed-46ca-9d6e-746f1fece5a2	routes	{}
62c81750-ae10-4ed0-af6b-e0ac780e87ea	routes	{}
edef1ef1-d996-4178-bb55-c936d3957942	routes	{}
43f5c46e-e675-4532-b8f2-29f15b8461eb	routes	{}
a14afe61-d28a-4f19-a017-dae5d161a49d	routes	{}
1899e324-1513-4171-961b-72ef843c2088	routes	{}
9e291431-ca59-42c8-9136-327bd2624198	routes	{}
ef98ef57-7055-426e-ac5c-6d43d518bed8	routes	{}
9c918568-7ade-46b2-a16e-9a4772dae4e9	routes	{}
9033b879-d718-4542-9310-acce46b18efd	routes	{}
337ad4b9-604f-4607-b9d3-faf4c05f0b52	routes	{}
d0cc7168-da46-4ab5-bdaa-674aefeb12a2	routes	{}
2a5aa66a-5014-437f-9176-18de52cc0404	routes	{}
643f0ba5-fec6-43bf-ba46-aace03428ee4	routes	{}
5851f1cf-fb67-488f-8317-a0379b736c85	routes	{}
264155db-b211-4924-b965-d7bf448d79d1	routes	{}
82eb5c86-8100-408a-bbd0-0dba09623902	routes	{}
acd6aceb-7c2b-491a-ae32-7df73ce1e7cb	routes	{}
afae8fdf-df4d-4b14-8591-b8d3f1d20639	routes	{}
920fa795-faf5-4bdd-bb31-009bc5945bc7	routes	{}
862e129d-54a6-4949-aa55-1d36f8a1089f	routes	{}
12395eb2-c573-4317-a9a1-d3d47edd74ed	routes	\N
25bef8e5-8e4d-4312-9eb4-f1b059bfe942	routes	{}
addc8d5e-cdbf-4f0d-9721-446d6ff4715b	plugins	\N
6a36f4f7-2fda-487c-8787-044b37668ac3	routes	{}
00481578-215c-4783-b21f-558332be5d59	routes	\N
458e1953-d766-4567-901c-53c6e847b522	targets	\N
86ee5a4b-96a8-4ee0-a5c4-387b91ca6230	routes	{}
57384980-fdee-44f6-bce5-6afaae17d6f3	routes	{}
8f02e1bf-5c63-4a92-a120-e775f1331800	routes	{}
12ea61e2-4b38-44a0-af7f-0b7b9af40a8f	routes	{}
dc11f1c6-c05d-4a8a-bbd5-a3204a398340	routes	{}
8ea53160-dfae-4711-96f9-877e7c834939	routes	{}
96d22286-778f-4737-b617-08ff22294369	routes	{}
7221af83-e5b6-4516-bee2-f25b9965200c	routes	{}
4da87494-91dd-48e3-ae5b-b2943397cf6c	services	\N
6c198920-ff43-4262-ab22-a905337f6a3b	routes	{}
f79e4e86-eae5-4618-9db3-fa2d8acf16ac	targets	\N
0eb131a8-aea8-41f7-8bb3-2b6b90b1d14e	targets	\N
c76dc660-0a5a-4e87-9935-28983d1e167a	targets	\N
bbe52c6b-527f-4c77-b00b-a2e4ae5ea409	routes	{}
f2b2d903-9016-4c1b-ba4b-820b58df4096	routes	{}
a3d31f7f-e8da-4e0f-89fa-4b73ab756c2f	routes	{}
12742cf2-2bc3-42a4-8c37-c193f8d4930b	routes	{}
07a58e00-3838-4a41-b7d7-4e4150f6f105	routes	{}
f297a290-43ed-443d-94bd-75766fee970a	routes	{}
15aa1fe3-ce58-45d7-9ebb-6a270471be2d	routes	{}
44e090a9-419b-422a-84c5-10e906bbe8fe	routes	{}
06fef246-0e8d-469c-8b78-f65042914503	routes	{}
0e9f303e-221e-4ea8-b028-13f438d37d02	plugins	\N
d65b0b49-4487-40bf-b35e-8ebc0371fb6c	routes	{}
e16be72f-fbcc-4db1-be05-b9a9a808ebab	routes	{}
d52af112-c673-42d1-9517-daa46f60a298	routes	{}
92d1dd00-576c-4eea-819c-9d28152bc01a	routes	{}
6aacc542-5dc9-4175-80d9-82b41a8671bf	routes	{}
b1352b95-115f-45ab-8a06-c4dbee6abfae	routes	{}
7f8ceabb-5f1d-40b8-8be2-4b7402b77c86	routes	{}
1f3680c0-f5cc-41f4-9c77-a42375537044	routes	{}
cecce448-d1a1-49fe-997a-9f54f2032db2	routes	{}
dfff7eba-3c46-4d0a-96ba-e48b247997fa	routes	{}
7ae4744b-ea92-4214-8452-9527b9df5740	routes	{}
18d7d8a6-5d62-4966-b2c9-c361fa9df92e	routes	{}
c74904a1-537d-4d99-bad8-41e16c176ec7	routes	{}
7ef546c0-1e78-45be-b362-e96976dfc0fb	routes	{}
7b15741f-cfaf-49f3-ba26-a14c6851b418	routes	{}
d166bf04-1c1e-47e1-8127-e1208fadf7ee	routes	{}
791d066f-4887-4189-a9e6-9699c82de6de	routes	{}
0dfba679-ab45-4446-a456-56fcaae86c2f	routes	{}
4a34ab59-8bc6-4411-95f0-2ed7d7a4e6fc	routes	{}
ee683a4b-ee14-4ffb-8ce1-a4b101f39c8f	routes	{}
2ba631a4-531f-44ca-9438-a2c79c0f692b	routes	{}
adcad3e6-5378-492f-8f0b-9876ca051b0c	routes	{}
eaf20d8d-75d3-4d28-8198-6df13d966b79	routes	{}
421fa34b-3ecd-48ae-a936-db83bcb905a3	routes	{}
a86c0ba3-c652-478e-b59c-52ebb7ff4a25	routes	{}
1f4b6e4d-5ca2-432c-b5af-79a0e025294c	routes	{}
02b3d60c-c353-448f-8455-466b8af0da71	routes	{}
0f27551b-8f58-4a66-8541-d4fd8dda4cc7	routes	{}
80f0bdb0-c2ce-424e-a840-369501341263	routes	{}
d71dfa0e-df3f-4d27-81b7-a582a3da5307	plugins	\N
c3cb55cc-22ac-43a8-8103-c9e39f110786	routes	{}
cb358e5e-97d2-48e8-9f99-92cf9a90d486	routes	{}
04d3a114-82bb-49ef-b674-f1eb6c056636	routes	{}
d79d9d9b-7fbb-4d81-b160-183106bbca94	routes	{}
f296c8e8-9a71-4e65-9598-d5a347c09b0e	routes	{}
050f8e2d-f905-46cd-95fd-b7361fe9c730	routes	{}
ae0e719e-1a58-4ddc-9531-1e06dc2acdbb	routes	{}
2b921ff7-014d-485c-bdcb-ff72730a87d6	routes	{}
05d042d5-38b8-416e-b047-a307d657e1bf	routes	{}
6995ad6c-a2e6-4d49-868e-e6b4e214dafe	routes	{}
1508cf41-469f-43b8-9141-18009f84b232	routes	{}
55e11492-f097-4be7-b98e-03e32317f2b1	routes	{}
f8336b39-e667-4e80-810f-71bdcf223087	routes	{}
310397a0-e428-4be5-8198-da1b865d6d82	routes	{}
de2547a8-e779-4bd3-9146-72ec9d34dcfe	services	\N
7abd46f0-eca4-4e06-b818-7d28b92e1dff	routes	{}
9310a8e2-3f92-4ffb-9870-29523e869522	routes	{}
45965659-94f2-4794-9136-0b97da82d90b	routes	\N
c99bab5b-4b43-4e67-bbdf-de5b1a75bbf0	routes	{}
d7c048a9-407b-4669-aebb-4f938c1ca4f3	routes	{}
32fa3349-c943-42de-949f-c2571f90f5b8	routes	{}
62a28942-a6df-41f6-9865-99ba360b645b	routes	{}
2ff61d00-274c-4e23-94ec-c8c18cbe9861	routes	{}
6f40a4f2-137a-4607-a52e-1ad1d4221f66	upstreams	\N
0d563309-f641-4eeb-9b6a-292056dbaa77	routes	{}
88dde9c8-8a9c-4e12-84ce-4348ee825bb5	services	\N
78dc59e5-5986-47fd-b3eb-e99f4d8a0142	routes	{}
da02835a-71e7-4c17-9551-092da9fc57fc	routes	{}
85712699-2a11-48b3-8d3e-a61325dc1842	routes	{}
9c85e3a6-3b4d-446e-b12e-5434be2046fa	routes	{}
9b6b85b8-82a7-4e39-be22-408fa4739d16	routes	{}
fc437d16-af11-492e-b55e-21e71e35422b	routes	{}
6e365185-0468-4fb1-828c-0ddfc5bb7c12	routes	{}
3b7cd3df-5446-440a-97a6-c16bfd1304a7	routes	{}
fa1c522e-bf10-47cf-bd78-78f19bf18a25	routes	{}
81132237-64ab-4591-9cdf-042779553984	routes	{}
147c4b50-888a-4aab-9380-2d5bba037071	routes	{}
a38e6da6-c7c1-451f-a210-e4badc3ced72	routes	{}
b146bed0-8e03-4975-babd-554712c8ff29	routes	{}
f4773556-134d-4346-b41a-4ef9a5bcb504	routes	{}
e25be106-a5b5-40ed-94e0-2324f134eb24	targets	\N
24953364-1bdc-4d03-a0d1-7ffb606b6037	targets	\N
9460cc86-0ad1-42a6-a2bb-c7ecd6ab86e9	routes	{}
1932bc3c-c414-4b38-94dc-8d0957d4011c	targets	\N
dd0065bc-c72d-459b-a07f-9f5665edeb20	targets	\N
77654e8a-48ad-4fc5-ad44-e10f6a406c76	routes	{}
a658ac10-bc33-47ca-897d-38fb77dc4063	routes	{}
a2daace9-e6b5-42c5-b1ea-52321675dada	routes	{}
89127524-6baf-4514-a70f-7eebcba29502	routes	{}
48308d2b-0778-4264-8832-a38cf766ae9a	routes	{}
c3b8b5a2-1d00-42a4-a5b8-c1f5b931a3de	routes	{}
00ae3c83-1750-41a2-840e-2a95050cb3d6	routes	{}
e5b29289-aa95-4bea-8ddf-c1b07a46f945	routes	{}
518dd5f1-4d6b-46fe-b8bc-d9e3c43ab631	routes	{}
d179129d-ec97-4694-8b6c-182150715bd5	routes	{}
7a71293c-1c3e-4607-afa5-364d487dddc1	routes	{}
7ea76f58-a230-41e7-aa1e-eb47ab70b059	routes	{}
16d5f8f9-8130-40a6-85e3-f9cd9e74921d	routes	{}
af61b990-65bf-44a1-b7e6-42b3ee2a686a	routes	{}
90f2ae24-4d16-44b8-ba69-15ed37e3cbb8	routes	{}
9a17f3f3-48dd-4b69-bb2b-71f1e4c9506d	routes	{}
9502224c-8f90-4e99-874a-966257b2e331	routes	{}
58232479-594d-4413-b927-469b9f576e39	routes	{}
8533b167-a76f-442d-b758-546e4b9e3060	routes	{}
6a59d6ca-3ff0-4df0-96bb-96ee7159e651	routes	{}
ab0d1320-4454-4687-b9b8-c874df8c2dd3	routes	{}
386e3827-74c1-40f6-b0f4-2a870606c88a	routes	{}
d8bd9227-e30a-44b0-8326-65f7afc3f312	routes	{}
0f8ab593-57aa-4769-ac46-1e8f4f8c9f57	routes	{}
448be9e6-1822-4f9e-8480-500a7b451abe	routes	{}
415c81d9-1ff9-4d50-ba1b-811129707633	routes	{}
d1469298-eff7-4e8b-b0a3-cfadf86dfc31	routes	{}
baf60502-b8b0-4983-82e9-f97126d8f1e7	routes	{}
c288a4fa-bbdd-4626-bb49-7025b79f1a64	routes	{}
e6a548a7-c971-4595-894e-747115b554e8	routes	{}
447ec028-95f5-465b-ac8a-ee09063549b4	routes	{}
19483a10-e7c4-4000-a1f0-d1512ec3988b	routes	{}
e4b2f11e-b395-4783-9e36-62bc9f37cd31	routes	{}
e04fd7b3-ebbc-4697-b4b3-bf4ec4a57110	routes	{}
307477f1-41b2-4699-8269-20871e944e2b	routes	{}
47a0414b-5d92-4915-83a2-2f6d443c36f4	routes	{}
b148b372-caa9-4427-b02a-b368199d764a	routes	{}
2e446131-4858-46fd-ae2d-d7f89e9328e8	routes	{}
1d286099-e757-4953-9ca3-eca40c74a990	routes	{}
c5a0bc9b-1a58-4f27-83f9-5d5bee351d51	routes	{}
4072876e-bfbf-480b-9911-a0d77f5e4d40	routes	{}
12d604b5-6c8a-42ae-936a-4d2ae198a634	routes	{}
2c06d567-e029-4936-8e43-bdd722193b7f	routes	{}
0a7eab77-8e33-41cf-9de4-a7231d9d98f6	routes	{}
76a81663-cf76-4920-bdec-3dfe1ecb4874	routes	{}
c25f7cfb-889f-4b56-a0a7-9e14e64bb0c8	routes	{}
922d4f53-81cc-415e-aef8-ae4c510ef609	routes	{}
ea9c1137-17ec-4d5a-815a-178ca7fd8668	routes	{}
4e86bfe2-2f11-4db2-b891-054478e1485b	routes	{}
d7242bec-928d-472a-8eb5-3c8830e8c07e	routes	{}
935f22b3-8f97-42b5-ad97-255a5abeb2d4	routes	{}
485b19d3-4d9b-4a66-a335-ba92a37e8302	routes	{}
b700e7a7-949e-40f3-ac8e-20e0ea345802	routes	{}
62125ad5-fa15-4663-9546-cbdb0eacd3ab	routes	{}
388d93ca-4ee8-4a10-8184-ed9e7b5d41a9	routes	{}
d9657918-9d7f-4c02-ad1a-879c5132dc14	routes	{}
cb5fb003-bdc6-4bda-ad5c-46f32c34b8ad	routes	{}
2d6a295a-156c-4d2e-9934-ebeb5c41c39a	routes	{}
11053bea-9c5a-4258-9f45-73d2a0a71d5b	routes	{}
2aa8e0c6-4430-46c0-89c1-ff6186cb74a2	routes	{}
c751ebe9-0865-4584-ab9a-cc3ad2426ac3	routes	{}
e1251394-6c9c-4f8f-9099-0090398306b8	routes	{}
8c6cc209-5161-4a73-80df-61d27000c3b0	routes	\N
c7206dec-7990-4704-98ef-c4370b9d1004	routes	{}
bfb37172-38fa-40ae-8aea-f8916662164c	routes	{}
21605554-a52a-4326-9f34-05abcd57cde6	routes	{}
729762c4-9a19-4cbc-bae8-40ddf5403e9f	routes	{}
2dbac621-27f2-4190-ab31-85abdeaa2f89	routes	{}
6dd41e55-f89a-4983-83e2-d0ff5ecef3e6	routes	{}
148e9865-fb99-4abb-8e03-5c03bc6c54ce	routes	{}
58b1e283-ba12-4f77-b0eb-a00151a8a208	routes	{}
850249c8-acba-4a64-a82d-aa360a1cb3ef	routes	{}
946fbbb1-a439-4fe4-a448-9ba02969bb1e	routes	{}
9dcf669c-e3fa-4ad8-bdf7-24e0cd34bedc	routes	{}
1d82916a-9c4e-4d0f-b312-9a3cf682e9bf	routes	{}
b3a4607f-7031-43e4-961f-c3ff030eb000	routes	{}
1cf652c9-787c-46bd-b0a5-6a1715fef42c	routes	{}
8ee07953-c422-48ae-b6f9-63aae42aa91c	routes	{}
e3bf1984-2a97-4577-b344-4ba7ecd0a4f5	routes	{}
963eca9c-a776-4616-aa7c-c5fb99771dfa	routes	{}
d1dec174-29d9-48e2-b5ae-63b95b682f2c	routes	{}
dc014037-ff56-4d96-b618-05f41d49f782	routes	{}
9d5d24bc-adc6-4047-bb62-5ea6bedc7563	routes	{}
0ef23cca-9b91-42b0-a742-ae32a548cc8c	routes	{}
aa852057-0300-4b33-8c01-61174239a93a	routes	{}
3a970ace-99eb-4a09-bb78-d617bb81ce3e	routes	{}
80e0b148-1406-4d16-90c8-ed52eeaaf563	routes	{}
d7625221-b0bb-454b-891e-7b66fc154aa3	routes	{}
74d7e1a0-e0f8-4ee1-9487-72c06b41236f	routes	{}
86dd3d2f-a356-41db-916b-c020266fc02f	routes	{}
825c527e-464f-4a11-b247-ec6c6650ab8b	routes	{}
741b6dc4-d2b7-4bf6-bb3b-96777f51199d	routes	{}
4fbe2d91-70f6-450c-9a3d-e8d91d116dcc	routes	{}
4480e323-5e7c-49f8-8585-67c86db97411	routes	{}
3deaa3f7-ae5b-4155-9846-cf1ba67beb69	routes	{}
594762b1-a7bc-407e-94bd-bb1c8cf7cb8b	routes	{}
4d70b07c-ff8e-400d-a741-8feb85f6b155	routes	{}
bd9be870-19ed-490a-a317-8a28f5db0663	routes	{}
d12eaac7-bfbf-4977-86b8-f72539d02f73	routes	{}
4c70cfa3-89af-46df-97b5-3bda82bd6548	targets	\N
a7be02c1-0ccd-4156-a90f-4e6323315194	routes	{}
b97a4e20-8b37-43be-b062-95a3020bd5dd	routes	{}
8bd7c812-72ee-4711-bfae-04a01e0efd0f	routes	{}
31cebd1c-97c0-4517-8df6-793a418c1471	routes	{}
9c2e4b28-2aeb-48d7-b6ac-84a718d2d407	routes	{}
f279bb32-25fa-4afc-9738-6cf8fc1e92b8	targets	\N
c4259ddc-33b4-4b92-889f-fcace9d1787b	routes	\N
ad864ee7-d69d-42e3-be3f-607f6ce7021d	targets	\N
b18679d6-1cca-4b16-9345-1c729005642a	routes	{}
604e49cf-8236-4f2e-835d-1357668bce3d	routes	{}
9c9731cd-3759-424c-b357-13fa363a330d	routes	{}
6e62414b-7c19-4464-8547-6170bac431bc	routes	{}
e6da971d-1960-495b-8bbd-d5387bb9636a	routes	{}
e99e2fa5-5c3a-4784-91fd-e2865f1889c2	plugins	\N
b73d7584-5830-4e7b-b796-e6e94f9de7fe	routes	{}
a98209fd-24e7-490f-bb0c-dd85ab9fa40b	routes	{}
c59673ed-58bc-4e13-8da0-aa520fb0a65b	targets	\N
4516aaeb-2dfa-4904-9ac6-1d1f9212dfe8	plugins	\N
7973d9e0-be9f-4969-80a2-d1868a215fb4	routes	{}
a740c57e-ed37-4c01-a3bf-da8be823be99	routes	{}
9474e130-eca2-4a94-a124-311690a75df4	routes	{}
0640d689-9cb6-4fbb-914f-cff500636c70	routes	{}
7387ef9f-3710-49ed-b2dc-5afb6e05dda8	routes	{}
e11f1eab-82da-4081-8bcd-f54f99fb4524	routes	{}
ad23a7e5-fadc-477c-9066-b3e13f072c29	routes	{}
eed03fc9-34a6-42cd-b15e-a8aa476834cd	routes	{}
73378220-0c4e-4412-8c96-5c125a93d110	routes	{}
f348b7d9-8a7c-4f9a-9b52-4fdde7f624a1	routes	{}
8bc53dbd-5bd4-4c9e-b4be-c54b165d9891	routes	{}
5eb60755-05f3-4be2-b92c-28d26348ba45	routes	{}
f930e7d1-e7ab-4343-a2e3-ed30059a367c	targets	\N
0f3fce69-35f2-4516-bd78-0a115815db33	upstreams	\N
b7cf4bb1-ccbf-4c04-8239-1ed1c64c7fd2	routes	{}
6e7b16a0-75ed-4e1f-9e5c-43b70d39f4b1	routes	{}
43668246-8669-4fca-974c-134a89fbe6b5	routes	{}
d7093520-81a8-4911-b87b-f4c94d7c32cf	routes	{}
18f969c0-1a92-42bd-a062-cb1b1a4580f8	routes	{}
d22073a8-7311-4669-862c-b5efa49256c3	routes	{}
2d4f6563-0beb-49c9-94b8-fa6ee81b1dea	routes	{}
d9848291-aae3-46e3-9648-e64c7233c0ea	routes	{}
f335320f-8ca5-453d-8a86-1de573790eb4	routes	{}
cda61616-3e28-4c7c-9083-b7d0691ad61c	routes	{}
8bd936d3-3f70-4b37-94b2-6fa999a398f9	routes	{}
a7c00827-3f28-4ff8-b7f4-b87e1a6d0758	routes	{}
10764687-5b53-4767-bdb8-9dc46d9b2ad1	routes	{}
2b41b9d6-0201-4ba6-bfa1-25f2702f69db	routes	{}
4e561e32-48a1-445e-b7a5-0d0eb7d05631	routes	{}
70fda053-bb28-4242-8b61-c3c7bc24f77f	routes	{}
0802b148-eb39-445b-b08f-8ccc6e88f15b	routes	{}
53cfc582-0a98-4845-b1a8-bd4db2d87de2	routes	{}
be78b21d-d172-4ac9-bf20-b08b133d784a	routes	{}
19bbbcba-391a-466b-8e37-32d277e56b4d	routes	{}
da0d6a8f-3246-4453-a929-1424f85b995e	routes	{}
b309a87c-bd87-4f56-a622-0eee54534c90	routes	{}
1a71f6b4-5561-44dd-85ac-d07e5549d355	routes	{}
33511bf6-8f7e-4882-bf3d-583e5e2569a9	routes	{}
666c5560-83dd-4d09-a571-3f3d3b781a5a	routes	{}
744e17ee-90b2-41fb-b04a-89ba573d230f	routes	{}
80b7a265-655b-4fba-b18d-980387eb1523	routes	{}
4d151ca4-d689-4edd-811e-92733f53c2cd	routes	{}
331517ac-c74d-4745-97c9-0ce7fd59d253	routes	{}
24079f5d-4ad7-492f-9989-585d44f8051b	routes	{}
60deb1da-88c2-4a19-a8ab-9aaf586c834d	routes	{}
bd379623-c032-4140-a28b-519a8499fd21	routes	{}
fd995924-2a79-48a1-a9c2-88d42ba837c3	routes	{}
bce5ea0e-f62d-40ff-a956-b53e351340ea	routes	{}
d9f41237-f1a2-457c-b937-3dc13bb85e92	routes	{}
a2fc379f-562a-4417-b21f-16fea333deeb	routes	{}
ce6cba19-1eb2-4459-8f72-1d2e58f9b585	targets	\N
807bde4c-bf87-4d9f-b97a-f4f337f20189	routes	{}
4fab8a8b-d7d8-4e7a-8223-8df3c516173c	routes	{}
00a2245b-c3da-4373-a664-eabf36428672	routes	{}
9d140db2-de05-4f33-93c8-e0a2c6b14fb3	targets	\N
0c66d774-8538-4d52-b949-a3613221f50e	routes	{}
80611dd7-227f-4abf-8d19-6b757faa508f	routes	{}
39ef7c24-a9bd-4a99-89fb-df54dbc6f644	routes	{}
d3a0217b-28dd-4e74-8536-ad526fb679d6	routes	{}
4fad1b72-2152-49b3-b37e-e630937bec37	targets	\N
482d36a9-6010-4581-92c9-9261e8d8159b	routes	{}
97e72e0a-74ff-4e10-80f5-297a6214403a	routes	{}
aa21d038-018c-40cb-b324-a8578c8bac23	targets	\N
5d7e1f11-52ec-4259-a677-caf8bac88838	routes	{}
bf27730e-8449-41b7-8924-5522306834bf	routes	{}
63b9efec-5eaa-4c9d-a99d-344ec3785962	routes	{}
4d12440b-a47c-4771-8da9-a1507443c3ba	routes	{}
4d0083ad-1c33-428b-9159-f230b39f5528	routes	{}
ea4e2ccf-5881-43f0-a0fe-ba748b41f54d	routes	{}
28cf816b-9070-4b1e-b120-17d796c58288	routes	{}
c0d6c28c-3fb4-4461-ab9d-99625e88aadf	routes	{}
b01842a3-7575-418c-83fa-f3caaff4b989	routes	{}
e04d9fae-13c1-45d5-b944-bebd679c73fa	routes	{}
8efaa9a9-5b3d-4275-a506-22ad8bdbdbd7	routes	{}
1bb0b516-4400-4cad-9870-db5ec05c59d9	routes	{}
063a5ba2-09cd-4ecd-8d1e-028d6ddb3cba	routes	{}
e983a63f-d3ef-4888-aa81-e1c09488bde5	routes	{}
39188bf8-fbfb-4c15-87a7-93c59a1896e9	routes	{}
6551a98f-85e1-4829-b3de-b73eb2e19255	targets	\N
3741e1f4-3d94-4fa7-b74b-e7aab41165e7	routes	\N
fa2018a8-220a-4191-8e40-034026161b9a	routes	{}
3b08566c-d560-4fbd-aa62-b0146b454de3	routes	{}
c586f66d-f74d-4200-bb5d-f3dc6f790a28	routes	{}
2f1c371d-7224-4b5c-9cc3-7ae9a87e1c60	routes	{}
48df736b-7305-44f1-9fd5-34132d8ca531	routes	{}
56d397a9-512d-4d82-bfee-2cc6d6141a56	routes	{}
d09473e6-e18e-46e9-a96a-3b341a07d07f	routes	{}
0279e5bd-bb2a-4df0-ae90-94c211499a05	routes	{}
b37b1add-8ac8-40e4-ab5c-fd7648fc7364	routes	{}
57404641-4c6f-4c50-8f19-45b7823c6a56	routes	{}
0cdc3ec9-037d-48d9-bb1d-98f9a367aa31	routes	{}
dc3a4ff6-9e85-4caa-8825-d1e3d0aedcb5	routes	{}
c202c3fe-2885-4f06-83b1-8f38b93c5910	routes	{}
5eaee2ed-4044-41eb-9f4e-6e4c930f53a7	routes	{}
cc43615a-a998-4cb8-836c-7c87a0514ff7	routes	{}
930c624a-f276-46ac-a83c-de1b64660d4d	routes	{}
3ac02802-00e2-4657-a9e3-6d3f80f23c46	routes	{}
4c4e31a2-cc0b-4c23-85f2-dd0abba3dca9	routes	{}
478970c2-6a9c-4f95-85f3-002ada3a2675	routes	{}
9694137c-1caa-4124-8627-b780e765ac75	routes	{}
1ddd618e-b42b-42f8-999d-af3d5b3676c4	routes	{}
367c4abb-dd3e-4904-ad8d-8a417523c9a2	routes	{}
b91f4f1c-da7f-49a8-bdde-a435afd2247b	routes	{}
59ed84c8-e428-4d5f-a6be-1eb87ca92ffc	targets	\N
00e6ecc0-793e-4cdd-b4f0-b2dfaf58f8cc	routes	{}
96497fb4-e52a-4656-b002-7618e64d9c58	routes	{}
f251ffd3-abb3-4662-850e-0a3813542880	routes	{}
925f19d0-e8e0-4cea-9e34-10e488ac8689	routes	{}
e9e58a89-8fd2-44ab-b187-35343e2a6164	routes	{}
d7f4f8ad-d2da-4392-b35c-42e50855b4fd	routes	{}
c295e6cc-90a8-4c31-86b0-d5431336d753	routes	{}
6e6fb692-cb5b-45f8-9a4f-c65cc31e8043	routes	{}
9937b4f8-22d6-4503-b422-5ee50e7078c4	routes	{}
61ea9a56-e975-4345-8439-e22f4d058c9d	routes	{}
65c3fa9b-3943-495b-9031-5a0a8979b252	routes	{}
1c0d4484-74d7-4b48-bc72-9068b6f23963	routes	{}
d99c7413-07bb-4f62-9ee3-5150f0a035ea	routes	{}
9c4c3028-2d67-4c4f-8e31-dbc948bc1c88	routes	{}
63f62256-4185-4310-b222-09194f6bda30	routes	{}
4685721c-afe6-420e-981c-36898aa373bb	routes	{}
b6a1e931-3b12-4d50-ac21-ca7d59168dbc	routes	{}
ff4c0bea-0347-438f-bd26-07200bdee709	routes	{}
68501eae-59c4-49c3-aac4-496b2039c7e0	routes	{}
b4d8ed61-bbe4-4309-877b-674a294468e6	routes	{}
1318a709-42d6-448c-ae18-4a537c8c7904	routes	{}
60cc1b36-47aa-46e1-9fee-7417753e15b8	routes	{}
a29da309-be9e-45f2-a4ba-35a43a8e33f6	routes	{}
fa869713-59c2-48f1-97bd-aa580441b1b9	routes	{}
48901494-0e9a-4b59-8fc6-2a5a1324f24f	routes	{}
bbbba5ec-a5ec-44b1-af5a-61a57bbf5440	targets	\N
7e71da8d-e510-4370-9e2c-e764653be7c7	routes	{}
7660d8a5-c122-496f-b57e-52961e853009	routes	{}
40e71503-4443-4458-a1e2-3e7a0bdb1bfa	routes	{}
d4615ec2-67a1-4a81-b815-ccd69bf61e80	targets	\N
542174be-6a4c-465c-95db-d0581682883a	routes	{}
fe2065ad-c48e-4055-aec3-06864869d04f	routes	{}
e717552a-3c0c-4ac0-b5ba-bb724ca4e65c	routes	{}
247dff71-19de-4218-abe7-f808a22f0ffe	routes	{}
07d9b689-c8f8-4ce1-af69-b7affaa27f57	routes	{}
279267bc-e16b-435e-9393-e0ee569a7ac5	routes	{}
92299eda-c032-4c11-b0e0-7126c6a5bc9c	routes	{}
bd25b119-4e35-4031-982f-be603caf9f08	routes	{}
df6b15bf-832f-4238-8bb5-f5da2ece7a8b	routes	{}
27b1903f-e8ec-417c-83e2-dd9f5f16a359	routes	{}
74616c5b-6fe8-4193-a0db-982b488ba40f	routes	{}
11673fb2-242e-4346-98ed-1663fdecd0bd	routes	{}
229d9ec9-f76b-496b-a085-cb2024f5f2a9	routes	{}
8a4f9d4e-3066-4691-babb-c62ec7af73df	routes	{}
a67965b2-0a9a-424b-b91d-aa6595170f20	routes	{}
594f7fe9-58dc-426f-bcf5-9c7eaffb83ee	routes	{}
ff002135-782d-4888-bafd-ae68828c672d	routes	{}
83c45a6e-97ea-4cd1-9900-b8b6c92dcde0	routes	{}
ab2c914e-09ae-44a0-8a21-00f2d4c9ccad	routes	{}
9babf575-86fe-4bac-804f-d3f8e66daf32	routes	{}
e938b199-4332-409b-ac45-1020ecd37d65	routes	{}
5cac65e8-7a44-4c1d-8573-a7b09320839a	routes	{}
e01ec901-d969-4ce3-86ae-eab2cc6d7941	routes	{}
33fc3d89-aab3-464e-9901-baa68924573d	routes	{}
b1516975-3a42-4bb7-8348-15ebd6ac91ff	routes	{}
3456c6f2-baf9-4cbf-a2aa-2f701963501a	routes	{}
2e82a606-81ac-477f-9a87-5d432b0d9831	routes	{}
935fb5d8-6470-425a-be97-789fa8d1ea8c	routes	{}
cdac2fc2-c134-45a8-aba9-3d3d9a2fe0dd	routes	{}
78673eae-2dd7-4b8b-82ca-3d2c1b84d1c8	routes	{}
27f792f0-c396-4dc5-8dd7-417fe540518a	routes	{}
38f8d439-ede1-4a66-b0b8-c0af998d68db	routes	\N
6729cd82-0c7b-4de2-be31-533870e20c2c	routes	{}
fe62ab21-fd95-441c-852a-5230114b963f	routes	\N
e03333c0-99ef-49aa-a954-790c0e24fbf7	routes	{}
05ca7054-3ff9-4571-8766-720663516d6a	routes	{}
1b789ce4-dfc2-4e43-8ef2-b0db5b5aa9f4	routes	{}
934fe162-d09b-4de5-825f-b11a17f0f2cf	routes	{}
7c1332b0-c8bd-4962-95a4-2dca63ca60a0	routes	{}
f88c4190-7c89-4d3e-87ca-1e32da1df6ba	routes	{}
af186f6c-f505-41d9-8fbc-64ed9adbdbe5	routes	{}
3a237bbb-a71b-42db-913c-40628b1c56bb	targets	\N
48fb138c-2fad-4d08-b851-7b7d778c8e83	routes	{}
dd0c561b-2583-4e78-9f33-ecd5af82cec1	routes	{}
84303426-66f0-4144-8ae8-b97ac4284f89	routes	{}
779621f5-d294-4821-9872-df49106095f2	routes	{}
6ec7a998-4983-43d2-a615-c6898ec42555	routes	{}
28750471-b1ad-409c-9bee-e5e7b477994b	routes	{}
61be5be5-7694-4c12-bc50-b9b53e20b1a3	routes	{}
8e806871-9abf-4e9b-98d1-21e90e148934	routes	{}
60dd1fb8-2547-40e3-af90-ddc21715d7f1	routes	{}
dbb9b81a-a326-4790-a972-3a43e630dd20	routes	{}
a53605af-751c-45ee-a81d-4d7c9d403abf	routes	{}
64e42c36-0b80-4de9-9cf0-82245632d411	routes	{}
fa5b1d16-ca20-45f3-ac68-8ac2b7f59328	routes	{}
f3404203-8978-40bd-9f4a-d317ee60292c	routes	{}
69d10aec-7ec5-4416-8f3e-75c56f9fc1ec	routes	{}
62e08268-0cd9-485f-8b5c-541089288e8f	routes	{}
8111a1bc-cce4-4d14-af40-dcca66babbe7	routes	{}
f526e06d-5170-458f-94bc-64bfca1ff793	routes	{}
8853e00a-b76e-4666-b0e8-bd001696939c	routes	{}
983a01a0-421e-42cf-acf1-dc5472aa7144	routes	{}
10b42538-3688-4304-be32-f0ad84cc7c18	routes	{}
e79ee21b-bb1b-4e1e-b964-2fdc96e17809	routes	{}
19ec0028-53fa-443b-b0e1-60557fe27c18	routes	{}
9c213966-0bf9-4b8c-ac6b-0c979b884fe3	routes	{}
d9cb34d0-e2e9-41ff-a3c4-af9454eec5fd	routes	{}
1f88abaa-e80d-462b-aa62-ae489e746933	routes	{}
ab6a27dc-e714-49b0-9719-ea52206ee152	routes	{}
978a8f37-4a35-4818-8568-bb4bd28d89a8	routes	{}
52f61089-a066-4682-a2fd-c246777bd9de	routes	{}
cbeb1c11-7041-4448-b1e0-cce36349521c	routes	{}
eb42866c-acf0-4f37-99ba-b10c42d34a64	routes	{}
940f8869-0546-4b86-a98d-51a3a96d7e1b	routes	{}
dbb00893-65bb-4b09-b996-a6d286da5b6c	routes	{}
0d6acd6d-4a76-4c32-83fe-7f25a6296720	routes	{}
98f23b69-8efd-4fa8-a87c-a298fd28da92	routes	{}
6f8c22f1-60c1-41cd-99e9-f4e666135d7e	routes	{}
1e0eaea4-1615-4341-bc06-77e25405a578	routes	{}
732e6cf9-c34e-40d3-90d7-ff600462c2d0	routes	{}
714c159e-a782-4764-b4ba-f175caf8927a	routes	{}
1ce80ae3-e5fa-4dd0-8369-973d0b97cd47	routes	{}
9bc360c2-ae9b-404c-88d7-4ffdfba7e1bd	routes	{}
de29401b-730d-4c04-bf5b-8d183ab5e36d	routes	{}
886d9886-d1d9-4f47-98ee-4cf31be690c2	routes	{}
8b5a9e8b-f78a-4793-a222-cce6589f8605	routes	{}
387897a1-28d9-421d-95b2-2b7b76c19b1e	routes	{}
0028325b-9426-48b5-a440-217880e2a201	routes	{}
675e9887-3545-4b9b-a3f6-119cb371f8c4	routes	{}
28ff7df9-1bd3-4291-bace-6bcf3a7c6c12	routes	{}
73f936bd-38c1-4de5-9555-3325c6504d9d	routes	{}
1f7df578-8bb1-4262-8fb0-9cb2d3fc2640	routes	{}
3834dc0e-ed49-4fb8-80dd-9125f085a64d	targets	\N
df590319-a970-41a6-b051-66d75885a94e	routes	{}
b3e6b05c-e55c-49a2-999e-f639e16dad2a	routes	{}
9026ef86-1169-4acd-8fc7-f644f822742a	routes	{}
c19a8c06-4242-4060-aef8-6b729350a0e0	routes	{}
f4b05593-3d6c-451e-8e3b-b2de4a739a13	routes	{}
976d4416-1839-49e3-b489-440dd1683fbe	routes	{}
216bab1d-3a13-4c11-b4f7-ab318b920f87	routes	{}
44e81465-7cd1-4bbd-873e-f2ec55b12787	targets	\N
d2af19b7-6e36-4ce8-b37a-3887c937b71b	routes	{}
e663dd87-7487-4027-b067-38432a197cd9	routes	{}
7ed4297d-5bbe-4ab2-832e-d29221741486	routes	{}
2aa332f5-ef0d-4530-a841-5389ba9c2574	routes	{}
90efbacf-fce4-4637-90a6-4eeb1a407b9a	routes	{}
f38603e2-c602-4fd3-826d-317f181b01d2	routes	{}
a5ab2c17-c3ad-4aba-96e0-d4361714b937	routes	{}
1967f581-2d52-4717-9621-27590509ab2d	routes	{}
39a13220-cde5-4ecc-9daf-9a9e4bd41b29	routes	{}
4ea05c06-00b4-4689-a408-9cc4b65dfd88	routes	{}
5f0f26f3-aef9-4eab-b2e8-1cdfde42a658	routes	{}
aab9f32a-2b14-448b-9807-2db921186119	routes	{}
683281bb-2940-469d-a88c-fc1fb5ecdc75	routes	{}
f197d8e0-60c4-4656-8607-5fe467a877f3	routes	{}
1511b364-e503-4afc-97b9-505b88dd8bb1	routes	{}
aef118db-a801-4f86-81ed-a7f5071badc7	routes	{}
285d21e7-5252-4a2b-b249-02f204d06c4a	routes	{}
81ba0fb3-11f0-42f6-9a0e-6c005e516538	routes	{}
1cfb7920-593c-4783-a541-c139e90c2280	routes	{}
eb953002-f2f4-4b88-9618-cd9bdfd539c2	routes	{}
2156547c-c1bc-44c0-85a5-95f706beeb9a	routes	{}
5873917e-7b17-4aa7-8788-777a4d11000c	routes	{}
24bdba7a-4c33-47ed-a3d2-0a2f2dc98886	routes	{}
59aaf5a0-de20-46cb-aef5-0ab4bc1befd7	routes	{}
ee5e12a5-40c3-4c8f-9bfb-841c1bf2fdc1	routes	{}
58f1ad3b-0128-4bf8-8e5b-c2615ec32cd8	routes	{}
dbd22ae2-da5e-4739-a27e-7553dd707362	routes	{}
e52cc709-ee4d-4efb-a7ac-cb8c6bdda229	routes	{}
5ed7de0a-69de-41f5-bcaf-e5bb066888b5	routes	{}
8c033434-7db1-41e7-abba-fd866786896d	routes	{}
e3de4925-edf6-4a4a-8886-d44d5dfd4525	routes	{}
b8903564-8f42-489d-a752-b5c6f830ad64	routes	{}
7a6dfe5f-7e61-41d4-841f-623eeb8f29b0	routes	{}
bb8d0a25-3127-4952-9d20-cba88cb128a3	routes	{}
14864cd1-32ef-4377-9aeb-753d55ace802	routes	{}
6600270c-a008-499b-893c-03a00bf036ef	targets	\N
f859c408-2893-44e7-baff-60d3ac8fcbd3	services	\N
c96c1ede-a504-4213-8e43-942a2dd64d3b	routes	{}
2a2b92d2-1c8b-4b9c-a0ba-3053ac3db9b2	routes	{}
be3267f7-2445-46e7-a6ae-7edc3be8d7dc	routes	{}
91b3f8bf-d344-4d90-9dd9-f74172a0bd12	routes	{}
0c03e6b3-3b59-4f81-a077-4be69acb1229	routes	{}
c3cbe9ae-7400-4a3f-9c89-b6abb8006ed5	routes	{}
74d2679c-9411-496e-9b47-06d4ec18bef4	routes	{}
240c17e5-3cd5-4bf1-b3b1-1681ee5fd65f	routes	{}
653e111d-9d0f-451b-952e-cc9c2176df67	routes	{}
1be808a4-2b35-43d4-a85b-11e07e689b94	routes	{}
fefadcce-7a3c-4047-971e-51cfabd246e3	routes	{}
90936a30-ebeb-4ca5-89fa-2fe80d1c5d28	routes	{}
7fbe69c4-83c1-4290-b49f-f297b8df0c6d	routes	{}
c7a67004-eec8-4617-8c6c-24b571504a91	targets	\N
6d3248a8-bba3-495e-8ea7-6263208278cd	targets	\N
5ec599f6-9990-4091-a883-6b76a32b499d	plugins	\N
f608294a-5cef-49ba-be63-fd1a852d0f00	routes	{}
2e298b15-0153-4ba7-bcdd-33098b0424c4	routes	{}
99ec87ae-8f27-4617-806d-2573ec078dbd	routes	{}
b7ae3d92-3917-4f22-81cf-7a3c71e2b782	routes	{}
3620a74b-e5c0-476b-a478-1f7be342b3bf	routes	{}
2872c9c4-bd6b-487a-926f-b9e1604ed883	routes	{}
ece5e513-1876-4a20-8479-0276ecb41b1d	routes	{}
20fa255a-2843-480d-8ca1-5200d74e04bc	routes	{}
a7094f1d-d05b-4b36-8a0f-2fdc8ca8eacb	routes	{}
44a407e3-fca6-45e1-af72-61245a0ffa21	routes	{}
97534429-2224-4407-a173-93cd7e43417f	routes	{}
62621577-5c12-4af0-b1c7-7ee209b58a3c	routes	{}
3bf773c9-551a-444f-972d-5fce915cc3e2	routes	{}
a42f39aa-cdf5-4064-9c4c-f2a9c5e5a5de	routes	{}
8cfc14e5-5aae-4a20-95de-e35910a54987	routes	{}
b6790f9f-7092-47aa-99a8-318661daa8dc	routes	{}
a095df96-3e05-480e-9aa8-bc7cddd12c67	routes	{}
79eb42b4-9071-4608-8351-fc7ad5fbaa55	routes	{}
48c2c8d1-d2ac-4d56-ae70-055d4c8e7e31	routes	{}
4d330812-3e46-4d58-b5e0-8d24eee79276	routes	{}
3dc9d6f0-e266-4677-b49c-6c59b1880c2a	routes	{}
49219eda-6578-454b-92ca-7dc2941525ff	routes	{}
1accc356-b8c8-4519-8333-e6bd166f2605	routes	{}
c188e2ef-40a1-4fb1-8035-2f9e2c34d033	routes	{}
9cba7fbc-9a8f-4521-a6cb-9837472cb2c8	routes	{}
88d34e25-29c7-42a1-b27c-d3e58c6c4cd6	routes	{}
520a3289-7f67-408a-9d16-6149e5752bab	routes	{}
da2746d9-ba8e-4fdd-9abd-0c362fb3b525	routes	{}
a394e708-83bc-484f-9788-826095438702	routes	{}
b7a01f07-b567-4548-af6e-7369ee484909	routes	{}
b465915c-cfb6-4a79-8965-d8d26956e95f	routes	{}
27f25952-f2cb-4913-892b-3642ab82e198	routes	{}
1dbe47c2-8c2e-41b5-b921-1b84c3a57c44	routes	{}
193a391c-0535-4539-8564-047843e5f843	routes	{}
3350507b-9db1-4659-8885-4e9b1b10fc32	routes	{}
46e27b65-25a6-4441-a1fd-939d90baac9d	routes	{}
99d825e9-8f1b-4437-bb6c-267c84553f4f	routes	{}
d25ed9b6-402e-45d0-a42e-12ec7940ef89	routes	{}
9623cb04-958a-43f3-b1bd-3d5484550523	routes	{}
dd99f29f-fd3b-4e26-bb28-3e2a89b45171	routes	{}
741faecc-9bfa-427b-ada0-5f9e5204771d	routes	{}
b64d00e6-7427-4ced-bf72-f46ea8845c82	routes	{}
87f62a9f-535e-46ce-82f2-0fbc6740abf9	routes	{}
c5a65e7b-3621-4184-91ff-80d8fce72a5e	routes	{}
e5f5fa30-adfc-42e5-9949-4251de15fb71	routes	{}
99493ed1-d537-414e-afa9-f818cd1d3302	routes	{}
c58951c8-18cb-4e9c-8dda-aaeb9149bf9b	routes	{}
58d39292-d450-4ec1-b3eb-8f050b284d6c	routes	{}
db482935-b8da-4f67-9385-d20ca8c86163	routes	{}
d5ab8e8c-c1a0-4994-98a4-5038828de578	routes	{}
a0772ed8-520c-46cb-ad6a-d692112ecda1	routes	\N
4ff78a5c-9b39-45a1-83e0-3ec6dcf0801e	routes	{}
0c0da4c3-ecd3-49dc-a81c-a0bf074bc6fe	routes	{}
b234a034-28ac-4862-9c66-c0be82c74496	routes	{}
26e86ca3-8250-4c76-a8c9-5366bcd9d238	routes	{}
2d3b1bb1-1003-4261-901d-41e630328e2e	routes	{}
bbab429b-a4d3-4233-9288-d9d5b755d4d6	routes	{}
d0230b5a-01f1-4782-bfb5-7a80a9c793c7	routes	{}
3968cda6-64e1-4119-bb70-0ba8a097189b	routes	{}
447c2710-0711-4fe1-aa44-adc0b2d1bad8	routes	{}
93536bee-c37c-4c6a-9be7-27603ac5f3b6	routes	{}
b1da6e59-bb0c-4874-b417-62ab71ecdb38	routes	{}
63e524b2-b04a-42c9-84da-22d4635130fb	routes	{}
02313945-c6d7-4c13-8c1e-5f76a8fa653c	routes	{}
ad11b466-30cb-4b6c-a2dd-9bb1e66a4595	routes	{}
90e32cef-d7be-4ead-9858-13d391a911ac	routes	{}
834910e2-72c6-4f55-ae67-45ddc7d4d662	routes	{}
c61e9c99-fbe2-46a5-a9b4-a841a2eea60e	routes	{}
ca534061-a234-4754-8415-062daf0ce588	routes	\N
8c19124c-4fbc-4eb6-883c-d0d69e992218	routes	{}
8d2cb62f-d782-425e-b98d-09bd966a5cb9	routes	{}
3b36ca39-4092-4ad0-af24-98b045a441c9	routes	{}
8d21cec3-0d74-474a-a40e-954bacc995f8	routes	{}
024c8996-f616-4705-b376-5844f0697fd5	routes	{}
c2ef9819-5d6e-4817-9791-eac424e080f1	routes	{}
10a300ed-1572-4839-8bfd-d4022afd2838	routes	{}
ae13b70d-1ee8-4477-94af-00252364fc3f	routes	{}
0faf2120-6f7e-4bfe-aa33-8d9bc11c11d6	routes	{}
799dd6cc-e771-4e0d-abf4-5b2d11460840	routes	{}
8f720e3e-819f-4591-94f1-af0844d95231	routes	{}
14d753f2-c3fc-47c8-a053-fccd43e9243b	routes	{}
47a14649-1f86-46da-960b-2033fcc170f3	routes	{}
88c8d43c-d6d1-4a3a-9c64-8c558f2808ac	routes	{}
997bff82-c020-4fde-a0cb-949577f4e7f3	routes	{}
ef889763-0389-4a0b-81ba-a0d3762bb81c	routes	{}
697f930b-c05a-4c12-b7b6-1e6600d40850	routes	{}
9201e1e5-703c-4f4d-a3ae-73852b458ec0	routes	{}
83b21ca4-ae23-4bc1-8d67-97ecd673cc86	routes	{}
5fdfc889-bdd2-40ff-9db5-ee223526dcc7	routes	{}
80f871b7-b925-4be2-9c9c-63d20dba2c97	routes	{}
4f99acca-68c2-4b8b-9323-4ce48aa962bb	routes	{}
38ca128c-8661-4359-bdba-c546dc32e204	routes	{}
866d8662-9117-4a04-8427-378aaa53134c	routes	{}
62b3c491-e91f-43a5-97a0-babea5a26c68	routes	{}
3799cc09-45e6-4e65-a849-9cd036eb1f72	routes	{}
775efbdd-fb6f-494e-91af-61615b01b867	routes	{}
9d3421a7-f477-4a3c-bc28-352c7864162d	routes	{}
d2b0e1de-fdc5-4fb6-a38b-c8f13863229f	routes	{}
6d9858a0-f038-4556-84b9-24e4efe69bd9	routes	{}
f4462206-122a-4159-bbac-8ac4a5851034	targets	\N
d486fb54-69cc-4910-9757-6de1ce367bc9	routes	{}
3b2ea849-a5d6-47a8-b988-4350d132aaa4	routes	{}
25bad5d3-a4a9-45bd-b57b-1d9436a3ee20	services	\N
9528a1da-b67f-41cf-810e-b410636e4941	routes	{}
bbd7bb3e-7f83-4626-a19c-79da2863bdf6	routes	{}
69bbaf37-69bd-478c-baae-3ae6a671f706	routes	{}
ccdd0b56-691a-40c2-aae5-7e6e32ad82ce	routes	{}
6418f317-1360-47c5-8665-e9023fac68fe	services	\N
8d41360e-e151-4f3b-8c12-a63200246c14	upstreams	\N
2ac6aad8-9655-4570-95a8-11692d19b7a1	targets	\N
d0daade8-9e60-42ad-8f2f-5a8436dd21a8	routes	{}
bf675e58-30c5-4532-8a95-e3f732269163	routes	{}
b4681539-a70e-4425-97f9-2f289f19ca4d	routes	{}
9fc62fd4-5c2a-4626-aeb6-cf5ad8322640	routes	{}
4b23a43f-b38e-4f63-a05d-8d823b20ecf7	routes	{}
7d6bdf74-9e22-49bd-bba8-9d24a14ea5b9	routes	{}
2a620149-f730-46c8-8068-0e3763fab4d4	routes	{}
b827a880-6e00-41f5-9c93-1a797710fb7d	routes	{}
8d80a602-0133-43d1-a2ec-bc567cbe79e7	routes	{}
e172caf1-7d46-4292-9295-59af7d7681b6	routes	{}
67399e87-c855-4ce2-b051-e20407d9c851	routes	{}
19a1793d-35e8-4642-af7b-1c97928071e2	routes	{}
4fd91d47-e997-4693-a753-473e36ada066	routes	{}
d2ef2c6c-96fe-413a-b4f2-550bc02d145e	routes	{}
1c2a4143-9e8d-4ec1-82ed-1f9aeb0d17d0	routes	{}
8ee00634-6df1-4939-b13a-830720001983	routes	{}
7e853571-3631-4d08-9f25-33c00b59d2ac	routes	{}
a1cdc84f-9a24-4a69-a1d9-2e3204fb924c	routes	{}
2321ead6-287b-4207-90c3-962edbff7461	routes	{}
6d9a9172-2893-4a2d-8064-71efb6328797	routes	{}
20401f49-4d43-4b26-a511-d024bf0b1c62	routes	{}
5edd8368-3915-4d2d-adf2-2c9c9a4f3e55	routes	{}
d0612459-d70f-4595-9f88-2af9467e7c10	routes	{}
b40cba46-542f-4157-9db6-9f436789b3e8	routes	{}
6bde394d-4471-4dc3-9c7b-d5edfc13ad24	routes	{}
52f8f9a7-cb38-4f13-849a-3b2d8c057248	routes	{}
a5498d21-5ddb-41c6-9189-853eb2437c49	routes	{}
02dbe650-f9fe-499a-9457-2e6114cfbb8d	routes	{}
f4318372-1435-463f-83e7-18a4e36f05b2	routes	{}
d31aa4c5-5cdc-435d-ac99-ff578ee7ddf5	routes	{}
7f0aeb18-80cd-462b-91cf-0a5d4364d2a0	plugins	\N
4218ad6d-e093-4bf4-818c-16764019d430	routes	{}
dbb4e973-6121-434c-a3a1-13dea8a24dd8	routes	{}
8084cafc-2b27-401d-8f7e-3f1bfbd1fb04	routes	{}
e9ddd68b-0e59-4fb7-995c-ec96cf6558c6	routes	{}
28dfc480-b2c0-48fa-a71f-9bbb7fdb820e	routes	{}
1d447441-c536-4de3-9b0f-dd769086128a	routes	{}
0fbd51c3-8ccf-4c12-b44d-c4811a66b3dc	routes	{}
cdcf04b3-c697-4439-aa45-d938943511d8	routes	{}
9697347a-8f46-44bd-a554-a3223a6da64b	routes	{}
c00d9271-af18-46ba-bdf7-b5a82f7cdb97	routes	{}
5456ad26-4f0c-47b3-90dc-3822f92e77d1	routes	{}
93b2f749-7781-4f15-ba95-754ffe240537	routes	{}
0a6f2b88-457d-4a28-bc43-cb6b1012ae44	routes	{}
fa86fd5e-ed01-47df-845b-223d3d66a4b5	routes	{}
4483734e-8d9e-485e-9d71-2877b4476bec	routes	{}
7e3afd55-7fe9-4d18-a586-d98f68ab4ec2	routes	{}
0c2b963a-d315-4383-8fc1-262f3a2c24a1	routes	{}
ee18c50e-479a-4765-85a9-9849e7d0bdad	routes	{}
30b565ef-513c-4028-8add-624cfe049d2b	routes	{}
01cefdd7-c1cc-4ce9-b6c0-8530e84e8f0b	plugins	\N
71afd34a-0aa0-4704-b23e-d4dd8b564354	routes	{}
a1f93b10-06fa-4181-9fbc-01c93a1c0b98	routes	{}
10bbd9b0-de0d-4f32-af0a-02182cd03ed0	routes	{}
072de41f-1abf-4f9e-a4a1-3c376cd80d44	routes	{}
27d8fc3f-4fb8-49de-8d16-136bd4cef3ad	routes	{}
299cbe07-37a5-4ccf-9742-b73db0150ea7	routes	{}
f7fef9a9-7cee-4950-95ac-acc21c5b2d59	routes	{}
30391833-cd81-4661-a7cd-8cf878f1ed84	routes	{}
aa744eb7-8759-461b-bb95-4a48e1ff3e2f	routes	{}
721bd4f1-535a-47b9-bc66-7bbde750d006	routes	{}
0e51b1b6-be9c-4ba2-8261-e4f3653e5a17	routes	{}
e8b6ad13-9957-414f-a4e8-ac3563e76eda	routes	{}
75028ebb-8c6d-4478-8b9c-fffca60ebe68	routes	{}
4f7744ab-1d1e-4d9e-833f-6f7a75f08502	routes	{}
daf3c6fc-483d-4cf4-87e4-f28078b612f6	routes	{}
a33f99a9-8736-49d1-824f-340fced4981f	routes	{}
64c14311-19cf-4bc9-ab3b-e40dabbecaee	routes	{}
6859f540-84a9-4f5a-9bb2-4ea04daa04a4	routes	{}
3f8b6c01-a7a4-448a-ac5d-1cec5124f602	routes	{}
b549f155-b8ed-44f7-a830-d7bd5ec12e37	routes	{}
7ee61164-ff02-4fa4-9a96-5127a7ba529f	routes	{}
264c17e1-3f58-4449-83d0-e0ba405e6940	routes	{}
93872a70-d7f6-4d94-b8db-67ae800ee5a7	routes	{}
eed5c6c0-8cdc-427b-9185-bd39da751f7f	routes	{}
31a06924-a724-4f0a-8ed1-563f27df79cc	routes	{}
66a347ce-8332-4038-ba60-17d0b595b146	routes	{}
6dfefd44-8973-4be1-a153-49722417bd31	routes	{}
2b7775ac-c828-4352-a697-6c3da6606a03	routes	{}
5db6bbed-eb96-4a13-b5f2-3c8edd258094	targets	\N
f3f2edd5-8e06-4e91-8a21-60fbbc2779c4	routes	{}
6aae56c9-2548-4401-86d2-a492fbaae60c	routes	{}
685d1b3e-6fb6-4455-8f2a-17bccb3f5aae	routes	{}
241740a2-eebf-4d29-aaa5-4d3b83996992	routes	{}
aa0300b8-e624-4a8f-ad05-6135fb0a8f6a	routes	{}
1763700c-d5c9-48c0-ba5c-89a48faa930e	routes	{}
a435e1fa-0f79-476c-b311-fee4d81af0b0	routes	{}
7a2ba11b-95a9-40f4-af74-321ddf059609	routes	{}
d889eceb-4aea-4cdb-8025-ef6c7e626619	routes	{}
06d024d7-7763-4e23-b21e-79bc62c6b4d6	routes	{}
c66f6e67-0337-4984-990a-98079b63d0b7	routes	{}
66056641-2161-4c59-a656-7cd39edb99cc	routes	{}
14c406f7-bd78-47a0-a5d4-0f08fa48e52d	routes	{}
46305c3b-e014-45b5-9845-266d72367291	routes	{}
69960c5d-d5ab-4bcf-8bc2-135910bbebe4	routes	{}
1879a058-c910-46a8-b16f-2ee023011c79	routes	{}
2d4a95d7-09db-4c5e-bd92-ebe435ecea21	routes	{}
364b6b15-ccc4-45ad-9186-40a3523d7e6a	routes	{}
dc611d4b-b42c-4b8e-9529-ca4eacda69cc	routes	{}
699d9971-f248-4055-ae29-0172d8cc3143	routes	{}
4d30f7ba-943d-4c36-b2f2-b8eae36fe7c4	routes	{}
103cb5ec-9d7e-4ba7-a7f9-9498d270eae6	routes	{}
16ebe251-c8c8-482f-9d60-4775b64ad0cd	services	\N
66acdc42-3b44-43b6-a55e-457a9655db51	routes	{}
c66a39ea-9b4b-4388-9823-ad6c436ecea1	routes	{}
2c20d634-6fc4-482f-bdfc-9101ef800071	routes	{}
2f1f1608-01ba-4dc5-b631-afdd3e72cab6	routes	{}
6f3db49d-f29a-4e95-a438-8e558e0b15c4	routes	{}
a03f225c-c8c9-4b22-9424-235ffa130bf0	routes	{}
7eaaece6-55d8-406d-861b-c661d8716904	plugins	\N
b09b6bb8-478b-43d5-ae03-0693aa24246b	routes	{}
f4f727d1-1170-4f8d-89e8-9e1fec47f902	routes	{}
59955698-2475-4b60-a742-30ad5067779b	routes	{}
723398b6-c43c-46ac-85f3-048f8f6f0ca1	routes	{}
c03fa5ae-fb2b-49d6-8f33-e0ac6b112495	routes	{}
79bee6e8-0c71-4f02-8bfb-084af82203d4	routes	{}
f27ead56-80fd-4c1e-8b7d-2b531a3c6884	routes	{}
181f7b06-9b61-4571-8a22-3a27d779a5d2	routes	{}
cf9a5141-c011-4f99-a766-811ba40f1db0	routes	{}
30d14147-c1b9-49a2-9386-09d6eb6aed80	routes	{}
236d130f-3bc2-4815-8cc1-79dc26290c3b	routes	{}
4d8bcb0d-c961-438f-a265-81f64111c2d4	routes	{}
0ae54239-7600-46da-a04b-628e377cb127	routes	{}
f25b3b8e-0af2-495a-a09d-a2ac250637c9	routes	{}
f84675cb-7d8f-49c4-878d-9e4e23a2dd3a	routes	{}
92b67d8d-f350-4ad5-ae81-3eecc38f4c36	routes	{}
5eeb9754-0139-409e-b767-de0d9f251b5c	routes	{}
3090c4ea-e16e-44a5-8a8a-307db959716f	routes	{}
937c421f-da5b-4753-9610-98d51df748a9	routes	{}
aed9840a-22cf-473e-a6a9-073c410dcec2	routes	{}
32c6748c-cc55-4b66-aa45-cf2a531b8e55	routes	{}
5785edc9-38ff-41fa-b88b-bedfeacb743e	routes	{}
7c2d7ca4-875f-4b49-bb95-77a068ff3250	routes	{}
e5deb535-2ada-413c-8ec6-27560593438c	routes	{}
11cbe4db-8a8d-4959-82c9-173fb4ee1ef1	routes	{}
7b864590-19fd-49ad-bc49-3212ad2fda44	routes	{}
c63b9651-fab7-4cf5-aa17-12a1d8a16dbc	routes	{}
24ee8492-09b2-40f6-ad33-6ec366078997	routes	{}
8c9bee12-3a1f-46d0-ad36-3ffc6411f5fc	routes	{}
9f24c4db-3ea9-4b1d-a93e-a88332450522	routes	{}
5dc8f70d-6a05-48dc-aff0-b07a6dfd642f	routes	{}
68dad324-6de7-4081-a68d-e45d78d22835	routes	{}
df948099-4523-4c5d-b70f-67d804d2548c	routes	{}
e775281b-445f-432c-9e3d-22e8a2746613	routes	{}
d8abc758-c431-4719-8382-f6d09aca9233	routes	{}
9c67e4e4-359d-48e8-b39d-5ae982af329d	routes	{}
02d54710-6c16-459f-a012-f6b65346b61b	routes	{}
64cf1051-7c9e-4f94-a5fe-3ed718f0c9c8	routes	{}
a7012529-7a9b-46c6-b04b-022151252f8e	routes	{}
04533be1-3e6e-42e2-ae7e-43136dd7731c	routes	{}
18b0b748-3b16-46bf-a892-a02cd579a68a	routes	{}
9e1221ea-ad8e-4cca-8c9c-a4d0b019cf01	routes	{}
29b789a8-fed5-463a-a7fe-f45e1e2ac7fb	routes	{}
71e1c68f-cba3-4ed1-843c-e60f0c8bda91	routes	{}
9ef125b2-a353-455b-98f1-7ce197c76e5a	routes	{}
6d5be914-4e8d-40ca-93d3-788fed24a75a	routes	{}
851b90b6-6aff-4c95-b6d3-12be772de1cf	routes	{}
3382545f-5f17-4ec9-99f9-7d29bafa36f5	routes	{}
53ae87c8-e42b-4273-babb-47065cbb7b62	routes	{}
9d7bed1d-ea55-44d8-beb6-bc33d226a54c	routes	{}
4c3d23bc-c31f-4270-90a9-14bf5a3b8f19	routes	{}
3475a211-9300-4116-9943-f23e28c3c9a2	routes	{}
2f8369e5-1470-4d8b-b566-a8808874889b	routes	{}
80c665c3-31cd-4c57-b27f-c0fd89129fd3	routes	{}
ccc52283-47bb-4ed2-b155-6f969e78803b	routes	{}
405c0fe6-ef48-4bea-bef3-5a84db061ee5	routes	{}
8a66a403-9f1e-4318-b1ab-a0939bf9d297	routes	{}
198e3ceb-22e2-469c-bbdd-f37cde3927a5	routes	{}
5486aa39-dc28-4d43-8e6b-b544d9e6ea76	routes	{}
3cee3513-20be-4378-83ab-aa8acaf5dfad	routes	{}
5fd398c8-6bf6-498d-8e0c-f0eab5e4aa1b	routes	{}
306bdd64-621f-497d-9966-6c02629f6028	routes	{}
23e553c3-db0b-451d-908d-0430b796788f	routes	{}
886852e4-607a-45a8-af52-06719d1ad332	routes	{}
eedae31e-e570-4150-9e8f-9cb53c9290b8	routes	{}
ea79cc67-7839-430c-959e-d36b8295b60f	routes	{}
101fda53-0514-4df5-b99a-ba4f57be779e	routes	{}
fa3dc7af-930e-4e56-be7e-a927042c35d2	routes	{}
cb2d5b54-2e0f-45b2-a90a-5547e1f2502d	routes	{}
edc6c436-7f04-446c-a5d8-ff12c7e530b8	routes	{}
34f6bb9e-5f96-4423-9f3f-7a3fe6cd8159	routes	{}
18965395-d461-4bce-8ca2-320873f27d8a	routes	{}
ffa51583-c876-49ec-bca2-7f399e81c77c	routes	{}
3b3ce153-46d0-4633-9de1-8921d68d64b1	routes	{}
949449c6-f809-4181-b029-d20ed0a1da14	routes	{}
2e58cafd-411a-40eb-a9f3-7f0ee165832a	routes	{}
5c403e0e-ad30-4ab5-bcd4-c806a1da707d	routes	{}
269e0828-9205-4e63-b31c-9ee8972c5b4e	routes	{}
269338ca-1537-42f9-bdb5-9319e559d80d	routes	{}
4523ab2b-8e22-42fa-9d2e-580f2feae3d0	routes	{}
1bc258f1-dd4c-4bc8-b4a2-1b8e2130fda7	routes	{}
8df74001-af6a-4cc4-9e9b-d09aded8ab2c	routes	{}
08e5c3e9-77a4-4eec-8ee5-edd5bfb15ad3	routes	{}
102f4b8d-fb51-4fb5-9df7-8eb5ebdbeb1b	routes	{}
7dd14462-626e-4dab-ab01-d1360164680d	routes	{}
d62407d9-f3c2-4805-a75d-79557742508e	routes	{}
e3c580a9-3570-4b2f-87d2-5a964f851c7c	routes	{}
f182a6dc-68c2-48d2-aead-b3e9451041db	routes	{}
7185e407-d3a5-4fe0-a45e-93d9c9a06692	routes	{}
b2491309-9dc0-4721-9405-53b4bcd47b41	routes	{}
b4081abf-0ca4-40fe-b410-23dd1b9c40e8	routes	{}
79d30e3a-a767-4d41-a57f-d0f62508cd8a	routes	{}
83512020-f97c-44b6-9716-107fbdfc9db2	routes	{}
ff78ed65-cd45-4796-9234-ddbd5eaa8bee	routes	{}
717864fd-def7-4abf-887b-0495dc584fbe	routes	{}
5669128e-7bc6-4d54-9067-34bbb9392a13	routes	{}
5a6f1aba-48bc-44d2-9d0e-ba9d52fb3ce3	routes	{}
64d4e098-effb-4fcf-81f5-18a906b29acc	routes	{}
6e8e81ed-129e-42d1-b7ef-d91fadcd5c1b	routes	{}
315dd29c-982f-49b9-934a-acf55ef157bf	routes	{}
fd739cc4-b6f3-4423-9b85-94afcecb4741	routes	{}
6d02f5dc-ae9d-45c4-a7b7-f11a282e23b4	routes	{}
ce6b10df-03bd-486e-abb9-8204b6f396e8	routes	{}
d980338c-a132-432e-beed-7f5ac5ef7363	routes	{}
f5de228f-56a6-4c94-a762-3ad54537773d	routes	{}
ba4d3171-3dab-4649-a066-ed73f1cf7735	routes	\N
497611c8-0cca-451b-a593-36b05952e975	routes	\N
f9523ade-9a0d-48e4-acfd-8e545838cb4f	routes	\N
da715b33-a883-4572-b032-3d54fc54c868	routes	{}
3fc9a103-865e-4e58-b513-b3f2e463fb20	routes	{}
badddd14-f10d-466a-9b10-931c63ea06b8	routes	{}
6b00d6f5-ee7f-4a64-86f7-9a4719a3b5fd	routes	{}
655d339d-1f6f-4adb-bc22-94c323edc573	routes	{}
78b5c5a0-d947-48e3-8017-59e157961faf	routes	{}
efaa903b-be39-404f-8871-71baece3b397	routes	{}
1b3415d1-5d9e-4ddd-b5b9-65dcd5ceda61	routes	{}
1336118e-951a-4803-bf61-1f5a875f45c9	routes	{}
c6334e4d-4a86-4c36-9f52-91cd70bdb404	routes	{}
57d101c5-fdd7-4168-a324-ef05267857e3	routes	{}
aea0885d-630f-4489-b194-d02394c4af63	routes	{}
a3c0ba3a-b37d-43c9-a8d2-1276e7cb52f3	routes	{}
e076e221-ef86-42a9-8464-293839ab50e8	routes	{}
d4e0d67f-c450-4195-b16a-726ae5aba32c	routes	{}
e0e0f7e8-e4c8-4f60-9b1a-7d6b37ff0d91	routes	{}
ce7e4828-23ed-46f8-8aea-5a8088f7b612	routes	{}
dd8ce77c-50e2-4fee-a857-538a7b5ce98b	routes	{}
de63799a-c170-4103-a779-b86c334136ae	routes	{}
01b0fdca-7eb7-418f-b5ed-6ca0ba430fbc	routes	{}
9062ee1d-cb7f-43b9-837d-f25a51193019	routes	{}
7a240802-0928-4241-a3d9-195263353c59	routes	{}
ec5b097d-c727-4f80-9f8f-77df2ece1646	routes	{}
70e45a8f-3f46-4b80-8a8a-37c3831e2331	targets	\N
2b5bfb6a-b93d-4287-ab82-ca1a25baea13	routes	{}
7eceeab7-eed9-4252-abee-d3d12484049d	routes	{}
4e9632fe-ceb9-47e8-9ce0-3f68e50e3515	routes	{}
71619507-3f42-4df0-b84c-1c81d5dc6809	routes	{}
61a105e9-9a96-41d8-b062-e73573ff2fa4	routes	{}
07fccb63-bb40-4a6e-9ed8-e8e1be0c3938	routes	{}
887a3f7a-e7d7-4980-906e-c77138a092a6	routes	{}
13ea26a0-91c6-4697-ba20-295482a2d50e	routes	{}
1e55d351-5c6b-4553-b6e5-ff73cd13dcef	routes	{}
64df630f-d5d7-479c-844f-94244e129e46	routes	{}
ab0e27c0-7774-41a2-b2b2-195a59fb4a69	routes	{}
0ad8b7f4-405b-4348-9588-81eb1df63602	routes	{}
f43b35b9-3708-49d4-99c6-547e326d1ff0	routes	{}
cd468382-012c-44ea-a168-d1b1623d7dcb	routes	{}
da1bb939-5d5f-4f51-a213-7040d7c04711	routes	{}
103a6485-0de0-4a5a-902b-eaab55c96eda	routes	{}
610706d1-ef38-473c-a191-24c0a481b816	routes	{}
7e713815-92a7-4031-9aef-46e598251f30	routes	{}
0c8424e4-09bb-48c2-a85e-c6c68d7fdbfa	routes	{}
7a7f3456-f512-44fa-b48b-19a7cc23dfe3	routes	{}
36eb478a-cdb1-4e83-a07e-d2b730a6365f	routes	{}
80f9ea21-072b-483f-a9bd-becec4420e63	routes	{}
7ad35af1-e32c-4cee-98f1-19d1cde8c35b	routes	{}
78d593c1-bcf9-4af0-b43b-72474326fe10	routes	{}
f945930e-541e-4773-8a37-6c0b78f60962	routes	{}
941cc241-c5b6-4f46-885d-88c23c08a592	routes	{}
3f1034ba-dc62-4c43-abf8-335ea5f97b6c	routes	{}
4f44333b-fbfe-436d-9afe-507a54cd093f	routes	{}
9a18b93f-e677-4da9-80a1-a455d96fb4c8	routes	{}
2f16d912-72ff-450f-808a-3bb993f1943e	routes	{}
7e37e8aa-3d98-49dc-bd66-353fbf98d28a	routes	{}
0ec1f3d1-c326-48c9-ae63-4e1e623b9368	routes	{}
e25279f9-5db3-4c7b-9d72-2646035a0529	routes	{}
be988e0e-46ab-4c61-bb60-e6884ed63305	routes	{}
90cbfa0e-2075-445c-b994-fb5500ec21ad	routes	{}
bd529f94-264b-41b3-a15e-34ea2db7c879	routes	{}
25f98efa-7015-42fc-99fb-418812fdfe3b	routes	{}
1ff26d50-0116-48d6-a5ce-b13df3888465	targets	\N
7a0b3569-8d57-4a33-9f37-d6c5112c4b43	upstreams	\N
72223b4b-7c4e-4d80-9c9a-a358ac7c75c6	routes	{}
272f45f8-278d-4954-b74c-254cbb7ebe3e	routes	{}
61aa1896-e85e-4d36-a39e-be4aa7989905	routes	{}
7f7ac175-1f09-4fda-922d-fdc2c73de052	routes	{}
eafd749b-3813-485d-bb13-a6bad91b2d7f	routes	{}
c4c3d5fa-170e-443b-8c48-cfd4bb4713b8	routes	{}
1e76770d-810a-428d-bce2-fcbf0fb7594c	routes	{}
216b1f81-0983-42bb-a3ab-70839dfa44d7	routes	{}
2ef2f03d-688b-43a0-9bcd-25df954d2617	routes	{}
7757e550-817b-488e-a1ec-4f97a8f47c1e	routes	{}
06eeb517-dafa-48a2-9a62-e96b0eb46c03	routes	{}
d310abcd-d49a-4e20-ab6c-09e7b6245bcc	routes	{}
1b49d9ae-f563-4253-b338-3afdf339cf5e	routes	{}
ca25ec00-ed76-4a5f-9a55-04d5608a2104	routes	{}
e7c31a77-f76b-4a6e-a016-7baea36dbf72	routes	{}
face9b64-d07c-4e6c-a181-92ee09d8cead	routes	{}
1a807145-e336-44cf-9c46-344699c1e18f	routes	{}
b16c47ab-2853-406f-aad1-43be413f1cbd	routes	{}
130c9265-2eb1-4836-b73d-372aec66deb6	routes	{}
8f5bdb7b-769b-47cd-bfc8-9a7b6f478d36	routes	{}
98afcc7e-bf75-4582-af9e-744212423cd0	routes	{}
b5f544b7-68e4-4491-b55a-8b4b2cf1d897	routes	{}
f641eb78-befd-4b2f-a378-85dd6000274a	routes	{}
7cc009b5-2f56-4b48-b025-82e7576f9f47	routes	{}
c51a3bed-d3cc-4df7-9c00-7aad787b504c	routes	{}
6912e187-b4f2-44fb-93e5-5bae6599e8a3	routes	{}
130f2585-1b27-4321-b624-c6bfa673400e	routes	{}
a37dbc3c-c7b8-434b-9ec3-e4902f1c2c5a	routes	{}
c9c67321-5322-4299-8ea2-a0b99fc6dd17	routes	{}
b245ff65-675b-49c3-aea8-cce6e4670845	routes	{}
89cda439-4a68-4cf1-9265-5bac52b678f7	routes	{}
a2dfb34d-38d5-4ca5-9a03-9652d6414764	routes	{}
c21f78b4-e199-46d3-8823-9cecde3ba779	routes	{}
fbc07443-2d6e-4c4a-8bef-6c5af6b2433e	routes	{}
200eb933-93d6-471b-ac7c-a5f490a90dc0	routes	{}
2f4908df-3719-4de0-a94f-fac5775f3e87	upstreams	\N
772dcb86-d741-418f-812d-c5d4eaf2f8a3	routes	{}
827f1ef4-1198-431c-a4af-0ce4136ff621	routes	{}
dd376a4e-943d-40ad-88d7-c15d1e61842b	routes	{}
3ea57c6a-b123-4708-8619-ab245ca1d25e	routes	{}
9744bb2a-b9b4-477a-bf2f-5ce37cc2c8d2	routes	\N
3bdf706e-7bc2-4d8d-b83a-854a4ff02927	routes	{}
92e6dd6a-067a-4a58-bb14-ce3aeb546a22	routes	{}
caf16dec-b730-444d-9665-8c0365ab7132	routes	{}
bfd2158e-e890-42dc-b88f-7f25cbeaf2af	routes	{}
087b2e1a-9468-42c9-a191-8b7690af7135	routes	{}
82946965-b14e-4840-b78f-c5a43449fce0	routes	{}
4d6f2f70-7981-4f3a-86c6-2c67e8f33af0	routes	{}
3f8110e9-4e62-4506-83e2-22c110887267	routes	{}
2d124c9e-3da5-4a9a-b937-268c21d9cd82	routes	{}
1b7858bb-223d-40de-a73c-d93943a6982f	routes	{}
949b304b-6157-47c7-a93b-8654394b884f	routes	{}
6b2f5f0d-bcdb-43db-9f57-50c0fc19311f	routes	{}
89c7799b-a310-4237-a8c5-78e5f2b6fac3	routes	{}
94cca026-3462-4bbe-8bda-e7935e2ee2b6	routes	{}
f0a9e0a4-d690-4191-8787-07714e882e66	routes	{}
277deb6e-3658-4407-89a0-d7b4c16b80bb	routes	{}
2e5ab277-ed71-426a-9327-41e819f2d8bf	routes	{}
0f42024b-cbdb-44aa-9a46-affabd9bdbf5	routes	{}
326188de-ede6-4bd6-8281-94a714ba587b	routes	{}
b0608eea-1098-420c-a1df-1d22b1c7443f	routes	{}
d71570aa-1383-4e7e-80df-60307d2bd33f	routes	\N
140af5f5-6bd7-4833-b189-9d2bdb4e6c15	routes	\N
b7fe88f0-0e58-42a8-b9c2-2923a39c4768	routes	\N
320c7b2e-28d0-4828-b8e8-684e357242d9	routes	{}
3b1bb26c-c9b2-4688-9953-22c57f3e2344	routes	\N
5019776f-acdc-4b51-858d-cab9c5ec97cd	routes	{}
b60f7da6-cd43-4a57-9183-5a3d25799c7f	routes	{}
9f696510-a8c4-4cc6-8ac7-a5554d3dea3b	routes	{}
2cd6e96f-1a88-4da7-87f1-e31d1dc00d66	routes	{}
9b64bc09-9a4a-493d-81c5-a931f1597908	routes	{}
e592c031-97f1-4ff2-8ad8-5d329ff61815	routes	{}
eda06251-d9d7-4be0-be66-da086eba6e29	routes	{}
34fa24ee-442e-447a-ad56-9f94a379d3a1	routes	{}
c792f267-8b4d-4e44-9c4e-e3482f47921a	targets	\N
db3d42f3-df5e-430c-8261-2208abede4ab	targets	\N
73d1f1b1-d0cd-42d1-b00c-a6bb84a30845	routes	{}
37e20ca1-ba2b-4f4e-92a8-43ee927c4209	routes	{}
3ac9063b-eb31-4a49-a9f5-237a3cb3d8bd	routes	{}
64b8aeeb-c888-4bff-b2cf-9aa0c03e778a	routes	{}
b5065f48-dfda-4ad7-b09a-731ccc66c0e1	routes	{}
d26f262a-3aa9-48b0-be71-b3ec7417684e	routes	{}
c35c7faf-373e-47c7-a5ca-bbaa3f49327a	routes	{}
b7262e58-bde8-4ab8-ac6f-61b491eefe1b	routes	{}
bdee667a-7d02-4924-b92a-d767c0026939	routes	{}
de6d5126-e5e4-4a26-a33a-cc5c9e633fe9	routes	{}
f70ce009-4d8e-4f29-9087-f1cd8225ca1b	routes	{}
a444ca74-8601-4581-833d-1f730df1804e	routes	{}
481d7306-9d48-4010-9305-be5d42a1cdcb	routes	{}
9f8a76a5-3527-4422-97ca-55adcfbeb8df	routes	{}
f4f18c63-942e-4a0b-9e44-18839bfe95cb	routes	{}
8e35ead4-69ca-47b9-af7f-84665479ab04	routes	{}
099d4ea5-971d-4844-bb12-4bbcc79f5625	routes	{}
f3f471ba-45e1-49d2-867a-e33045a09b6a	routes	{}
1cb99904-8038-4b0a-a6f3-60d75e4cd399	routes	{}
5487daf9-0ae1-49fe-9541-f5ef98f78429	routes	{}
e88a2328-1edd-4e0f-a93f-a2a6c1afbdad	routes	{}
c5c18ac7-79e6-4120-a08c-42d98ecefe91	routes	{}
5c73fdec-67a1-4898-bd52-6c98cf19fb8c	routes	{}
6932a3e4-6596-43ca-9cdd-1e3c271073d3	routes	{}
4d7ccfe0-06be-42ac-a426-bef3be9c09cf	routes	{}
ee28edd7-edd8-425d-b247-b6c1ae420e93	routes	{}
885bc174-4ce0-4a73-8a63-3a1f5fb5a456	routes	{}
7c5cbf64-8870-4dba-b90b-350b5cf82a3a	routes	{}
092134aa-1545-418d-8a3e-f205240b6628	routes	{}
a7b9e26a-3291-457a-ab47-19dd3c6d536a	routes	{}
70509bc0-86cb-490e-98d5-9feb72a24c19	routes	{}
8442d4fc-504b-4862-ba2a-0bb5293b62cb	routes	{}
ba2d8065-7399-474b-b3b3-1c36e172c57c	routes	{}
5b426ccd-3a15-42eb-a9df-ac7e6bc0b76b	routes	{}
309521b7-ca91-46a1-bb32-1917337cebe8	routes	{}
dd1570fd-9ef1-4a81-859f-3aa8dfcf8fda	routes	{}
e49fa4aa-9f15-4b3c-bac6-37f905cfca3e	routes	{}
2719a913-fdac-4352-8e52-6f0e2c692ae4	routes	{}
49c5ea34-fe07-4f77-ab78-b00199b6f0a8	routes	{}
2cd43988-df32-47de-a4df-082161ad4318	routes	{}
cd029c96-ebf3-4e2d-aa81-92b3159ae545	routes	{}
5d897781-55b5-4b96-9a54-02de755bbb37	routes	{}
6f7cdfc9-ea2c-49e0-89c7-4745c7160667	routes	{}
09aec8a4-018a-4c2b-aea9-fad55c429bb4	routes	{}
e7e8102f-ff74-4ce4-ad04-3c2e3dae4d3b	routes	{}
899c702a-1cd3-44cf-b8a3-8bff4461640f	routes	{}
19b001c8-6978-4a3e-adee-7d8542ae18b9	routes	{}
20d16e3b-e3ac-4cf2-a187-0167cd71c2c0	routes	{}
d414e3cf-a70d-44ec-9f6c-cfc0cef3bf5d	routes	{}
7bab1811-09ac-45e3-abaf-7212c479916c	routes	{}
0e61fec6-c0f5-4728-b916-6f40f3235e2b	routes	{}
f32427be-c685-49f2-964f-fde27f010e39	routes	{}
a33b24b9-5855-4d54-b5d9-c5810592eaa6	routes	{}
7ca2d7c3-f9cf-4fb2-8969-1e99d7775032	routes	{}
94e7e730-719f-4575-a696-ca5495047428	routes	\N
db750a9d-a861-4d8f-98df-73840a5cd68f	routes	{}
d947caeb-a6bc-44bb-84fd-a0f7a73b5b5e	routes	{}
e5fc8bf0-996d-4b4b-8f88-893c35c27ee6	routes	{}
3b705619-b63a-4c74-bed2-892a8196df07	routes	{}
3269aaa3-024c-42ea-9eb7-45d7dfdc9df2	routes	{}
9ff3baf0-2c87-4e9b-838c-e9c2edcb87e6	routes	{}
706ac07c-299f-4a53-94b0-e88378184fbc	routes	{}
97b60016-3f88-4dd6-87ed-d41a205b3a95	routes	{}
a8fac0c7-496f-45c7-bd76-41972867c11e	routes	{}
a6015ceb-9af2-4586-bd3c-288f0ce09703	routes	{}
1ea4d006-0cc0-49bd-861e-94c67852d4a3	routes	{}
29c93480-29d9-4c39-b769-e8913d4b89da	routes	{}
e289f466-8726-4a73-8c9c-47f18d5aeb35	routes	{}
69e1f440-663c-4a17-bd5d-e80c0f0f0da2	routes	{}
9e00c014-1302-45a5-a604-eefaf2fd70ba	routes	{}
acf6420c-e9ef-481f-bcf7-0d5e19ebe2ac	routes	{}
998cd706-fc6c-4c89-a646-589be93c5443	routes	{}
cc489f88-329e-4d02-93a3-5340bb6b17f1	routes	{}
024f9c1b-76f4-45e1-a47b-b356fb6ae1f4	routes	{}
134365b0-66c3-4b98-9355-a8126aaa12fc	routes	{}
724a0947-8bae-4556-80d6-a7da86e13bac	routes	{}
0925e43c-378c-4696-ad7b-932f60f8fff2	upstreams	\N
659daf51-d0e8-46b3-8867-f6c4051582c7	services	\N
2b42f14b-db50-452d-a64e-9a236bb47679	routes	{}
602de9ef-e8a4-49f6-9b21-bae5f230bf36	routes	{}
9ba4c172-3ac7-42ca-8a56-c4496036dd2f	routes	{}
0a8027f4-1786-483b-8508-36bdf6f9b22c	targets	\N
5a4ad050-a716-4776-9414-4f292183b22a	targets	\N
e1d178d6-56a9-47cf-add1-b82e41a705d5	routes	{}
c33d7111-9fe6-4052-8eee-d46ab44f75bd	routes	{}
c13b4470-4d15-4e90-8af7-1e0a37671910	routes	{}
76cf69c6-53b3-4db9-af50-1a8bcdbfa696	routes	{}
38d2bdb8-efa4-4cdf-b84e-294b25351cd3	routes	\N
11a6586c-0fb9-49a6-8fa0-079e7c829425	routes	{}
15027737-e5dc-4517-a6ff-e65113914a2c	routes	{}
474f8782-e704-478e-8950-206f914ac9a1	routes	{}
fdce23c4-73b0-47e1-891d-6b9a94868e70	routes	{}
32563794-da91-4fbb-a9d0-c8edcc47e369	routes	{}
5ffd1bd6-9745-49bf-b73c-f096c0c2e2c5	routes	{}
2c735e9c-5c6f-4bd7-9c78-b6589f0a0a61	routes	{}
1a0d447d-9d88-42d2-9037-3b07c6445f4f	routes	{}
c0e263fc-5441-4f2d-b482-b1540c5ad3cd	routes	{}
539b6f9d-40be-439f-910d-123ab5df4deb	routes	{}
2a8dca07-95e8-4302-8483-ee59b72de329	routes	{}
3df1869e-8a57-4aa5-aadf-f771a762efd2	routes	{}
188e8261-7983-4924-9637-2f7f48822c75	routes	{}
d6aa3473-29f6-40e5-aa0d-2aa070f71688	routes	{}
1c7919fc-5f98-4ca6-88f6-ef5c5dd83435	routes	{}
d2a6d1ec-41e5-4ea5-ada0-cb44cf2aef4e	routes	{}
490cd055-5343-4003-80b8-07e52e8518bb	routes	{}
07cad934-a5bb-4f41-83e5-af2e2296d70c	routes	{}
a3cf6bc9-5802-496d-a84e-b4480f095edf	routes	{}
c662696b-cfbb-4642-8f19-f94add47132f	routes	{}
4bc5d5d4-612d-486b-84f2-61a459f67835	routes	{}
6b711730-0cee-4148-b708-b3a82cccc91f	routes	{}
45bd6839-cbb7-4a26-baee-1935cff5f298	routes	{}
7ed2558c-2fa1-492b-8eb3-02427d12c957	routes	{}
1206bbcb-91aa-404d-9d4c-12ae492d630c	routes	{}
d904e8f9-2a1c-444a-9795-4f516cf4380f	routes	{}
94b61ca1-d2d4-4cce-a508-70dcc525b88b	routes	{}
54c92605-bd90-4dab-9f7f-25b8bb489b06	routes	{}
a744cba0-5da5-40af-b110-7b17dec67fa8	routes	{}
5a28742c-aea3-482f-bdfd-ffde3e1dea5b	routes	{}
9ba638da-c6e4-44ce-b993-a52e71f8ab4d	routes	{}
6e0599c3-5749-4dbd-8a99-ae8165bd29e6	routes	{}
cba1679d-28cc-41a8-a2f6-8aa7edd759b8	routes	{}
ce3a2684-7c88-43a7-aa70-a96cd9cf7e1b	routes	{}
4d373ad4-d5ff-42fd-822a-6cdd1c1fe8d3	routes	{}
56aedc5a-6d93-4e6d-b16b-775c75de816b	routes	{}
76ca8902-c3ca-41df-8c8d-c20d4d2788b0	routes	{}
a4472b20-c299-4a02-80c4-bc2f64582cec	routes	{}
5bb26e2e-dd85-48e1-99bf-3a512bbef12d	routes	{}
a22bb0ae-3624-4313-8e65-dd6f7da52d63	routes	{}
bf46625d-6f77-44be-a28d-3e9623d71392	routes	{}
3c958ba6-3e60-4ec3-8974-d70b06debacc	routes	{}
cc46f9a1-b4e4-4e8e-9ecf-aadc143b423a	routes	{}
18029c75-ee63-43bf-a7c4-8be6fd7aac5a	routes	{}
6662f228-56b8-4149-9907-bfd44a108be9	routes	{}
5eaf9415-094f-488f-ae3b-95efdc9b2e38	routes	{}
9a650cd2-9d6f-400d-a646-38bc5e8c114a	routes	{}
afe9fb92-8aea-4d98-a6de-b540ad30ccf6	routes	{}
debd6e86-fa3d-41f1-91d2-8ca7ad27d506	routes	{}
b97d2cef-3955-4f8a-b124-7fbd6d8ef7ba	routes	{}
50717b37-5ec2-4eae-9321-dec57d02e872	routes	{}
2ba30216-235a-401d-9f7b-2d336a4c8257	plugins	\N
896eae63-8aca-4200-a353-37523e6d2d3a	routes	{}
677f31cb-7869-49ea-8808-7c60abf04fda	routes	{}
b36e96c3-f4f7-4807-a018-b32dcdfd8370	routes	{}
7ab68456-ff41-4a70-ba9d-ce898a0dbc07	routes	{}
1b423555-aba7-4488-a0ed-763b54de6d2e	routes	{}
fdfbe14e-c2b8-4eee-b8f3-5a5c4ae07b2a	routes	{}
0769b583-e7ed-4b7f-96e3-79a547dfc0eb	upstreams	\N
0cadc5bf-9092-4000-9301-23bd6979e6f0	services	\N
294744cf-bafe-4480-8cdb-2dbeb99c565f	routes	{}
58ac0801-2bce-4e3a-85b7-ad67ad4c4911	targets	\N
871c8eee-11eb-4184-b639-e884eab1a514	routes	{}
ce679bf8-030d-49f4-8bb1-ba8494d915eb	routes	{}
63713a31-d94b-43d6-8370-cf0c1d696164	routes	{}
f7eea087-de2b-4c65-86e8-72425a61eceb	routes	{}
208e5bec-4ba5-485a-9375-7114dc437971	routes	{}
bea003da-8149-4000-9ef5-38d12d5e579c	routes	{}
a74436aa-0e78-4af4-bbfd-b7ff47b8ae5b	routes	{}
05b48042-3af7-4b24-801a-b5ea00169daa	routes	{}
da1cfc52-e668-45d6-9d2a-4fe505d0e18b	routes	{}
bada221d-3d05-4860-8bb7-3e8c5c950884	routes	{}
2c8cd431-8412-4f44-87ce-c4a387eb5b0a	routes	{}
972aded1-8b12-4417-98ee-9f8b5d5ba78d	routes	{}
b3240931-c1a2-48b5-b68f-32cea8f1d241	targets	\N
2622f771-85b3-415f-b669-d4ffdda0cf37	targets	\N
c629bc4b-9f62-4a75-8460-308cb52c6287	routes	{}
875a848a-7572-49eb-9fd9-4df0562dcd04	routes	{}
2d44c128-346e-40f0-87ea-71ff732ce803	routes	{}
abe5b49b-2e2a-47ff-b1a1-96d86eb5449f	routes	{}
a327fd91-6b59-4450-b79e-7cd63e5da433	routes	{}
27c746ea-6491-49b0-b48f-2e7e9d8c099f	routes	{}
3934fc21-6305-46c7-ba75-72df14aa7738	routes	{}
ade69953-2850-4efb-bf40-ce30f1f382f8	routes	{}
fadcd2bb-f9d0-4da4-9c90-80f04f6c658f	routes	{}
7ea7ff8c-aa37-4c25-a28d-19ae15c85ecc	routes	{}
70c4fd94-bfc9-43cc-96d8-8d46d0a461a3	routes	{}
8e19d80c-e4ba-413d-a9e2-99a38a638ae6	routes	{}
8697c156-532e-4f45-a6a3-017793bb4899	routes	{}
c5b88e77-a319-4f4b-98ba-a9177826aa6e	routes	{}
f9595b42-2290-4813-9fe0-227cd5b8193c	routes	{}
0988ca92-c7df-4dca-93ea-02cb68ea4e73	routes	{}
dd54ea2c-49b4-453b-8485-585aa74544c8	routes	{}
e737bd46-c5df-4000-afec-2b41f4963bf9	routes	{}
6207631b-b8a2-49be-8eb1-85491b450f59	routes	{}
dd063190-41a7-4bc2-918f-118bb745079e	routes	{}
3b32f04f-4077-4bdb-b157-bbe79ecfdf69	routes	\N
0413c91b-dbc6-4157-9e6e-ca6b9674eadf	routes	{}
7cd7590b-b9b8-4e1a-b9da-48f394684bb4	routes	{}
42d7cee9-b799-48ef-98fb-aee42a4ed1cd	routes	{}
172e1a7e-26fa-45f8-ad9f-9e43764f89ee	routes	{}
0a55e2c8-7864-4477-881d-39c0e49a6a7d	routes	{}
48c37d32-b5ff-4837-8c37-618692e8783d	routes	{}
623dda1b-f609-454c-8169-ccd8a24a1f8f	routes	{}
46ef6dff-3c0e-4a06-99d8-783da2403960	routes	{}
7dbe191e-446c-414a-b260-e5e047664071	routes	{}
5b7543c4-2fbb-4e59-be58-b934ba42912a	routes	{}
0ba59fca-00dd-4404-9a5a-17baf28fce91	routes	{}
f201508a-e641-4411-9596-13ad209d0091	routes	{}
41982c9c-98f0-465d-bed7-67e59942617e	routes	{}
ae668e7e-6148-4b63-ac4c-f290674ff7dd	routes	{}
5a5130f3-c14e-49ac-b98c-ce2a656f0af7	routes	{}
34347d4b-631e-477d-bf0b-623904ec30ce	routes	{}
88031385-3577-48d8-b8bc-31d8ddab5757	routes	{}
48ef586e-5a00-4945-be84-6affc591c056	routes	{}
7a3f7e15-1ec8-4152-bc1a-769887aeeff6	routes	{}
5adaac4a-82dc-4508-8743-a404f7e05b99	routes	{}
6b08a116-d055-413a-b88b-6acf035a17da	routes	{}
1e959ee4-a0a1-45b4-ab72-223d7cc61c3d	routes	{}
9610915d-f56a-4924-86f8-28d87288e7e8	routes	{}
47b02209-0e7e-4a29-b0f6-64ad7046aa38	routes	{}
212c9a74-a98c-4b8a-93e5-a343aa50c95d	routes	{}
6024db51-3ef9-4f66-8292-a598070f7fd4	routes	{}
5a419dde-c626-45ef-94b6-dd323d10a39b	routes	{}
524b40cd-8e52-43ae-8bb1-d81eba336a6c	routes	{}
9c469100-2587-4b0c-b95c-cf98d2c6fc2e	routes	{}
036bd326-cab7-4e78-8d96-a4bd943d0a7e	routes	{}
847bb265-23c3-47c5-9dc1-4df4efa61493	routes	{}
4e4b4cb7-4580-405d-9676-ca68420daf9d	routes	{}
4cbd60e1-e601-495c-ace2-c95601ccd6b1	routes	{}
c02b85a6-f19b-4f8f-8cf7-7499f99c0864	routes	{}
a624832e-393b-4c8a-af00-5994abffa73b	routes	{}
c2b37eba-812d-461a-adbc-210e077142b4	routes	{}
df40f7b7-2661-4f80-b9a7-5d4446cd13de	routes	{}
8cb86f83-2edc-46ce-a9b1-aae1d2db63bb	routes	{}
3fdcb7d3-2250-44dd-9f81-f5ac900784b9	routes	{}
5f5523a3-3b60-4f24-a434-5cc9c1834c4b	routes	{}
f6e72d05-8e46-414b-ae66-3e429aaad138	routes	{}
9d131de5-849f-4387-a29d-5fec30c55e93	routes	{}
bd61063c-ef95-4b2c-87aa-a61651690f1f	routes	{}
3940f03b-8576-4c0c-bea2-f34efde86bf2	routes	{}
2844c9e9-bc84-4bc1-98dd-8e0b957ab053	routes	{}
0c5ba3c3-fddf-4189-bcbc-3ee5ac62753e	routes	{}
7b8a237e-9196-4159-99ac-b9cf1beb9ea3	routes	{}
58ebdfd7-d7be-4eac-bb26-43a07fadc4cd	routes	{}
c1e8711a-b2b0-49ce-99cc-75dd774457ad	targets	\N
07a6eb20-9bdc-426c-ab63-3339513dc738	routes	{}
3ab68675-2e97-4984-8cbc-8ab37848727a	routes	{}
2c9eec2f-5032-4283-89aa-8a10fb4e6735	routes	{}
6731a8e9-2394-4598-b1e5-01343a14b26f	routes	{}
6b79b3bb-8c24-4bc0-b4fa-c7e7b21da671	routes	{}
6fc23e87-bb42-46a3-aed6-d5109c9604ef	routes	{}
6364482b-f04f-41d3-853d-4a024b50b1ea	routes	{}
1514b819-5134-4ce4-aaa6-cda33df166db	routes	{}
da93af8f-8be5-4c0d-a331-b56c77381b24	routes	{}
0e889c59-a456-4dc1-85f0-af5c1b5ed6e7	routes	{}
33fac8f4-790b-4f5e-866b-1d79a522fde7	routes	{}
b5306cea-ab34-497d-8d81-107315cc295c	routes	{}
28397787-2c80-416a-b7c7-3814e547da70	routes	{}
2477316e-76cd-4ebc-b0ea-ab8ff34e15d2	routes	{}
1bc6e938-b4bd-4f15-91d5-5e6bbd945674	routes	{}
c3df8ca6-f466-454b-9805-a715c52109aa	routes	{}
0ded033e-714b-4d34-b5ce-cfd03a9096f6	routes	{}
dcae85e2-8457-47f1-9241-635bdda102c5	routes	{}
90b94f61-0953-45c0-ada2-b9b10078260f	routes	{}
eecf53cd-8cd9-42a5-a774-37391e553e9f	routes	{}
a7f9c1f5-f676-46b9-b63a-867736083236	routes	{}
2f57ac4a-ace6-4e88-8b3f-af9af683beb3	routes	{}
9d54059f-24a0-41bb-bf88-5ab7cc40d9f1	routes	{}
46857841-2c45-446f-9353-c590910f22ec	routes	{}
461b1af3-5c7e-44f4-94bb-35e2d87952f3	routes	{}
ef3bb711-0777-4a6a-b08a-f2c1fdf90b5b	routes	{}
8842b004-83cf-4a4c-84aa-3c6b27f59eef	plugins	\N
c9375b7b-f8f9-4286-9e07-898c40085a5d	routes	{}
357d5151-d56f-4b92-a672-fdad2ab5c895	routes	{}
9bbd29bf-efc2-4a2d-8334-86804ec103c3	routes	{}
0fb97851-d06a-46df-bcee-66bfc97847b0	routes	{}
628c7b72-059c-4e8a-a68c-5f9b8f63fe02	routes	{}
83635081-33aa-4351-bda6-a83bc9a197f5	routes	\N
ad6d64b0-3b6a-49ab-9158-ff6c33eaffc6	targets	\N
5f46ed6f-e83d-4d2c-a81a-c0ddd6401b30	targets	\N
3db8e552-9567-4145-a7ee-ce8e02576162	routes	{}
04277e7e-f44d-4fab-93d6-df8caf67cd6d	routes	{}
28bd4efb-72ae-473c-8185-293a42d13b1b	routes	{}
b7475698-829d-4c79-ba58-57726509bd7a	routes	{}
84274195-6a39-48e7-abf8-5f52d4f25cba	routes	{}
e94a274a-a502-47fa-821d-c006d300a7de	routes	{}
dfdd6268-694a-4afe-b200-678d1e6a9aed	routes	{}
c65dca51-cb27-4132-83f2-7bddd4942049	routes	{}
2390ee8e-d5f9-46a6-aba0-ed3442825d5f	routes	{}
c12ae231-0d54-44bd-9c5a-286c13daf114	routes	{}
2672cef0-a223-4da9-9002-9aa7db75a7f1	routes	{}
ddfda831-25e0-480f-8dca-7585b8bbe8ae	routes	{}
4561c716-7116-4d98-a008-008a22bda959	routes	{}
7a2cb7e3-62e5-4a31-9efe-6b31aab07983	routes	{}
bc131da9-02ac-430b-b821-1f0f45476a4f	routes	{}
87da0221-af4e-41b0-a2e2-d746f5074e71	routes	{}
cc1bfb8d-cce5-47ad-9f2d-a8938d242d2e	routes	{}
78f9fd24-4134-4319-a6ae-ce58e49ec181	routes	{}
69fefbe1-3bca-46dc-bdd2-806dfa256062	routes	{}
33165496-b38b-4af5-b654-29419d044188	routes	{}
a68f677e-0446-4c30-bede-7aba68a5550e	routes	{}
090666c5-2a85-44fe-9bab-80e0de4abae7	targets	\N
68955659-9ef8-4947-aeda-3248c8cedf1b	upstreams	\N
2eb227fb-8b46-4b35-b537-fdac8974ef5a	routes	{}
7d9ae4b7-5dc8-47d1-a34e-6a3d9774e515	routes	{}
383ed32c-52f7-4a56-8572-7eb5159e22d7	routes	{}
7e99b857-7205-484d-a0d9-dcd3d7c55e37	routes	{}
a7027b6d-5855-40f7-82e3-69fc433210ad	routes	{}
294af8d3-863f-4093-8bc1-c379c6c3401a	routes	{}
6f332314-2f1e-49ae-9d9c-282b80d822a4	routes	{}
2ecc2215-21ce-48d6-a238-6009748c46ad	routes	{}
320579b8-98a3-45b7-b528-3b4b9ffa5318	routes	{}
\.


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.targets (id, created_at, upstream_id, target, weight, tags, ws_id) FROM stdin;
db3d42f3-df5e-430c-8261-2208abede4ab	2020-04-19 21:29:36.219+08	0925e43c-378c-4696-ad7b-932f60f8fff2	172.16.100.112:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f930e7d1-e7ab-4343-a2e3-ed30059a367c	2021-01-01 20:44:43.513+08	6f40a4f2-137a-4607-a52e-1ad1d4221f66	172.16.100.112:7970	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
6600270c-a008-499b-893c-03a00bf036ef	2021-01-01 21:36:17.625+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
58ac0801-2bce-4e3a-85b7-ad67ad4c4911	2021-01-01 21:36:20.766+08	2f4908df-3719-4de0-a94f-fac5775f3e87	172.16.100.112:7971	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
c1e8711a-b2b0-49ce-99cc-75dd774457ad	2021-01-01 21:36:23.691+08	6f40a4f2-137a-4607-a52e-1ad1d4221f66	172.16.100.112:7970	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
090666c5-2a85-44fe-9bab-80e0de4abae7	2021-01-01 21:36:29.951+08	d7618cd0-057c-4b86-aceb-98f6aeede769	172.16.100.112:59106	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
592beeed-3e91-4bb4-a97b-26e83d9abd22	2021-01-01 21:36:32.335+08	7a0b3569-8d57-4a33-9f37-d6c5112c4b43	172.16.100.112:8888	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
4c70cfa3-89af-46df-97b5-3bda82bd6548	2020-04-19 22:22:04.805+08	0925e43c-378c-4696-ad7b-932f60f8fff2	172.16.100.112:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
9d140db2-de05-4f33-93c8-e0a2c6b14fb3	2021-01-01 21:37:29.903+08	0769b583-e7ed-4b7f-96e3-79a547dfc0eb	172.16.100.112:59104	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
e9188cdb-6595-4487-a588-f93a492940b9	2020-04-06 20:55:29.612+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
bbbba5ec-a5ec-44b1-af5a-61a57bbf5440	2021-01-01 21:37:32.575+08	9e75a0b5-a1fe-443b-93e1-d1d89f4b07cd	172.16.100.112:8085	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f4462206-122a-4159-bbac-8ac4a5851034	2020-05-13 13:36:30.677+08	2f4908df-3719-4de0-a94f-fac5775f3e87	172.16.100.112:7971	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
b3240931-c1a2-48b5-b68f-32cea8f1d241	2021-05-09 21:03:46.141+08	0769b583-e7ed-4b7f-96e3-79a547dfc0eb	service_oplog.test.nodevops.cn:59104	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
5db6bbed-eb96-4a13-b5f2-3c8edd258094	2020-05-13 15:51:32.113+08	2f4908df-3719-4de0-a94f-fac5775f3e87	172.16.100.112:7971	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
ad6d64b0-3b6a-49ab-9158-ff6c33eaffc6	2021-05-09 21:03:51.373+08	0769b583-e7ed-4b7f-96e3-79a547dfc0eb	172.16.100.112:59104	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
fecaceb4-c73b-41bd-8e43-9b767d011fd4	2021-05-09 21:21:23.172+08	d7618cd0-057c-4b86-aceb-98f6aeede769	dns_check.test.nodevops.cn:59106	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
8901bd0a-9b14-4b71-b2c7-38b956d67464	2021-05-09 21:21:26.991+08	d7618cd0-057c-4b86-aceb-98f6aeede769	172.16.100.112:59106	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f79e4e86-eae5-4618-9db3-fa2d8acf16ac	2021-05-09 21:21:59.113+08	0925e43c-378c-4696-ad7b-932f60f8fff2	ads.test.nodevops.cn:9089	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
e25be106-a5b5-40ed-94e0-2324f134eb24	2021-05-09 21:22:02.867+08	0925e43c-378c-4696-ad7b-932f60f8fff2	172.16.100.112:9089	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
f279bb32-25fa-4afc-9738-6cf8fc1e92b8	2021-05-09 21:23:48.156+08	dbfd518d-bcf6-4f35-b6d0-224f460c5422	172.16.100.112:59108	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
4fad1b72-2152-49b3-b37e-e630937bec37	2021-05-09 21:24:16.181+08	dbfd518d-bcf6-4f35-b6d0-224f460c5422	service_cdn.test.nodevops.cn:59107	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
d4615ec2-67a1-4a81-b815-ccd69bf61e80	2021-05-09 21:24:25.388+08	dbfd518d-bcf6-4f35-b6d0-224f460c5422	172.16.100.112:59107	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
c7a67004-eec8-4617-8c6c-24b571504a91	2021-05-09 21:26:04.506+08	7a0b3569-8d57-4a33-9f37-d6c5112c4b43	service_batch.test.nodevops.cn:8888	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
2622f771-85b3-415f-b669-d4ffdda0cf37	2021-05-09 21:26:08.125+08	7a0b3569-8d57-4a33-9f37-d6c5112c4b43	172.16.100.112:8888	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
5f46ed6f-e83d-4d2c-a81a-c0ddd6401b30	2021-05-09 21:27:06.119+08	8d41360e-e151-4f3b-8c12-a63200246c14	service_dns.test.nodevops.cn:7972	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
23ab7040-0df9-4da2-ac9a-4fe99ce5bab8	2021-05-09 21:27:10.659+08	8d41360e-e151-4f3b-8c12-a63200246c14	172.16.100.112:7972	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0eb131a8-aea8-41f7-8bb3-2b6b90b1d14e	2021-05-09 21:27:51.162+08	9e75a0b5-a1fe-443b-93e1-d1d89f4b07cd	service_notify.test.nodevops.cn:8085	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
c76dc660-0a5a-4e87-9935-28983d1e167a	2021-05-09 21:27:57.742+08	9e75a0b5-a1fe-443b-93e1-d1d89f4b07cd	172.16.100.112:8085	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
24953364-1bdc-4d03-a0d1-7ffb606b6037	2021-05-09 21:29:32.772+08	6f40a4f2-137a-4607-a52e-1ad1d4221f66	service_disp.test.nodevops.cn:7970	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
c59673ed-58bc-4e13-8da0-aa520fb0a65b	2021-05-09 21:29:42.504+08	6f40a4f2-137a-4607-a52e-1ad1d4221f66	172.16.100.112:7970	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
aa21d038-018c-40cb-b324-a8578c8bac23	2021-05-09 21:30:23.755+08	0f3fce69-35f2-4516-bd78-0a115815db33	service_asset.test.nodevops.cn:9089	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
1932bc3c-c414-4b38-94dc-8d0957d4011c	2021-05-09 21:30:26.892+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
3a237bbb-a71b-42db-913c-40628b1c56bb	2021-05-09 21:31:34.66+08	2f4908df-3719-4de0-a94f-fac5775f3e87	service_tag.test.nodevops.cn:7971	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
dd0065bc-c72d-459b-a07f-9f5665edeb20	2021-05-09 21:31:44.054+08	2f4908df-3719-4de0-a94f-fac5775f3e87	172.16.100.112:7971	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
ce6cba19-1eb2-4459-8f72-1d2e58f9b585	2020-04-06 21:04:30.4+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
6551a98f-85e1-4829-b3de-b73eb2e19255	2020-04-06 21:04:45.127+08	8d41360e-e151-4f3b-8c12-a63200246c14	172.16.100.112:7972	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
59ed84c8-e428-4d5f-a6be-1eb87ca92ffc	2020-04-06 21:05:50.19+08	7a0b3569-8d57-4a33-9f37-d6c5112c4b43	172.16.100.112:8888	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
6d3248a8-bba3-495e-8ea7-6263208278cd	2021-05-09 21:33:19.278+08	68955659-9ef8-4947-aeda-3248c8cedf1b	yundunapiv4.test.nodevops.cn:80	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
2ac6aad8-9655-4570-95a8-11692d19b7a1	2020-04-06 21:16:05.427+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.33:9089	0	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
458e1953-d766-4567-901c-53c6e847b522	2020-09-10 17:32:57.715+08	dbfd518d-bcf6-4f35-b6d0-224f460c5422	172.16.100.112:59107	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
70e45a8f-3f46-4b80-8a8a-37c3831e2331	2020-04-14 14:24:51.761+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
c792f267-8b4d-4e44-9c4e-e3482f47921a	2020-04-19 15:30:26.565+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.112:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
3834dc0e-ed49-4fb8-80dd-9125f085a64d	2020-10-10 10:36:11.424+08	dbfd518d-bcf6-4f35-b6d0-224f460c5422	172.16.100.112:59108	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0a8027f4-1786-483b-8508-36bdf6f9b22c	2019-07-02 11:22:30.35+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.33:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
5a4ad050-a716-4776-9414-4f292183b22a	2019-07-02 11:22:30.53+08	0f3fce69-35f2-4516-bd78-0a115815db33	172.16.100.33:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
44e81465-7cd1-4bbd-873e-f2ec55b12787	2020-08-17 19:12:39.475+08	0769b583-e7ed-4b7f-96e3-79a547dfc0eb	172.16.100.112:59104	100	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
ad864ee7-d69d-42e3-be3f-607f6ce7021d	2020-12-14 16:22:12.54+08	6f40a4f2-137a-4607-a52e-1ad1d4221f66	172.16.100.112:7970	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
1ff26d50-0116-48d6-a5ce-b13df3888465	2020-04-19 21:26:41.703+08	0925e43c-378c-4696-ad7b-932f60f8fff2	172.16.100.112:9089	50	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: ttls; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.ttls (primary_key_value, primary_uuid_value, table_name, primary_key_name, expire_at) FROM stdin;
\.


--
-- Data for Name: upstreams; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.upstreams (id, created_at, name, hash_on, hash_fallback, hash_on_header, hash_fallback_header, hash_on_cookie, hash_on_cookie_path, slots, healthchecks, tags, algorithm, host_header, client_certificate_id, ws_id) FROM stdin;
9e75a0b5-a1fe-443b-93e1-d1d89f4b07cd	2019-12-10 15:48:06+08	service_notify	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
8d41360e-e151-4f3b-8c12-a63200246c14	2019-12-12 18:01:13+08	service_dns	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0f3fce69-35f2-4516-bd78-0a115815db33	2019-06-18 11:00:47+08	service_asset	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
2f4908df-3719-4de0-a94f-fac5775f3e87	2019-06-17 16:12:21+08	service_tag	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0925e43c-378c-4696-ad7b-932f60f8fff2	2020-04-19 17:41:03+08	ads	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
7a0b3569-8d57-4a33-9f37-d6c5112c4b43	2019-12-13 10:46:38+08	service_batch	none	none	\N	\N	\N	/	1000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
68955659-9ef8-4947-aeda-3248c8cedf1b	2019-06-17 16:08:38+08	apiv4	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
6f40a4f2-137a-4607-a52e-1ad1d4221f66	2019-07-12 13:49:50+08	service_disp	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
0769b583-e7ed-4b7f-96e3-79a547dfc0eb	2020-03-03 14:50:40+08	service_oplog	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
dbfd518d-bcf6-4f35-b6d0-224f460c5422	2020-09-09 17:47:34+08	service_cdn	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
d7618cd0-057c-4b86-aceb-98f6aeede769	2020-08-04 15:31:14+08	dns_check	none	none	\N	\N	\N	/	10000	{"active": {"type": "http", "healthy": {"interval": 0, "successes": 0, "http_statuses": [200, 302]}, "timeout": 1, "http_path": "/", "https_sni": null, "unhealthy": {"interval": 0, "timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505]}, "concurrency": 10, "https_verify_certificate": true}, "passive": {"type": "http", "healthy": {"successes": 0, "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]}, "unhealthy": {"timeouts": 0, "tcp_failures": 0, "http_failures": 0, "http_statuses": [429, 500, 503]}}, "threshold": 0}	\N	round-robin	\N	\N	9b57a89e-2dcf-40ad-a478-782b7457c157
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY public.workspaces (id, name, comment, created_at, meta, config) FROM stdin;
9b57a89e-2dcf-40ad-a478-782b7457c157	default	\N	2020-12-26 22:01:00+08	\N	\N
\.


--
-- Name: acls acls_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_cache_key_key UNIQUE (cache_key);


--
-- Name: acls acls_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: acls acls_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: acme_storage acme_storage_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_key_key UNIQUE (key);


--
-- Name: acme_storage acme_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_pkey PRIMARY KEY (id);


--
-- Name: apis apis_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.apis
    ADD CONSTRAINT apis_name_key UNIQUE (name);


--
-- Name: apis apis_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.apis
    ADD CONSTRAINT apis_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: basicauth_credentials basicauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: ca_certificates ca_certificates_cert_digest_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_cert_digest_key UNIQUE (cert_digest);


--
-- Name: ca_certificates ca_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: cluster_events cluster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.cluster_events
    ADD CONSTRAINT cluster_events_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: consumers consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_ws_id_custom_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_custom_id_unique UNIQUE (ws_id, custom_id);


--
-- Name: consumers consumers_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: hmacauth_credentials hmacauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: hmacauth_credentials hmacauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: jwt_secrets jwt_secrets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: jwt_secrets jwt_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_pkey PRIMARY KEY (id);


--
-- Name: jwt_secrets jwt_secrets_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: keyauth_credentials keyauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: keyauth_credentials keyauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: locks locks_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (key);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_code_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_code_unique UNIQUE (ws_id, code);


--
-- Name: oauth2_credentials oauth2_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_credentials oauth2_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_pkey PRIMARY KEY (id);


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_client_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_client_id_unique UNIQUE (ws_id, client_id);


--
-- Name: oauth2_tokens oauth2_tokens_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_tokens oauth2_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_access_token_unique UNIQUE (ws_id, access_token);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_refresh_token_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_refresh_token_unique UNIQUE (ws_id, refresh_token);


--
-- Name: plugins plugins_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_cache_key_key UNIQUE (cache_key);


--
-- Name: plugins plugins_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: ratelimiting_metrics ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.ratelimiting_metrics
    ADD CONSTRAINT ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: response_ratelimiting_metrics response_ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.response_ratelimiting_metrics
    ADD CONSTRAINT response_ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: routes routes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: routes routes_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: schema_meta schema_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.schema_meta
    ADD CONSTRAINT schema_meta_pkey PRIMARY KEY (key, subsystem);


--
-- Name: services services_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: services services_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: snis snis_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: snis snis_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_name_key UNIQUE (name);


--
-- Name: snis snis_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (entity_id);


--
-- Name: targets targets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: ttls ttls_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.ttls
    ADD CONSTRAINT ttls_pkey PRIMARY KEY (primary_key_value, table_name);


--
-- Name: upstreams upstreams_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: upstreams upstreams_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_pkey PRIMARY KEY (id);


--
-- Name: upstreams upstreams_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: workspaces workspaces_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_name_key UNIQUE (name);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: acls_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_consumer_id_idx ON public.acls USING btree (consumer_id);


--
-- Name: acls_group_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_group_idx ON public.acls USING btree ("group");


--
-- Name: acls_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_tags_idex_tags_idx ON public.acls USING gin (tags);


--
-- Name: basicauth_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX basicauth_consumer_id_idx ON public.basicauth_credentials USING btree (consumer_id);


--
-- Name: basicauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX basicauth_tags_idex_tags_idx ON public.basicauth_credentials USING gin (tags);


--
-- Name: certificates_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX certificates_tags_idx ON public.certificates USING gin (tags);


--
-- Name: cluster_events_at_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_at_idx ON public.cluster_events USING btree (at);


--
-- Name: cluster_events_channel_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_channel_idx ON public.cluster_events USING btree (channel);


--
-- Name: cluster_events_expire_at_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_expire_at_idx ON public.cluster_events USING btree (expire_at);


--
-- Name: consumers_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX consumers_tags_idx ON public.consumers USING gin (tags);


--
-- Name: consumers_username_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX consumers_username_idx ON public.consumers USING btree (lower(username));


--
-- Name: hmacauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX hmacauth_credentials_consumer_id_idx ON public.hmacauth_credentials USING btree (consumer_id);


--
-- Name: hmacauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX hmacauth_tags_idex_tags_idx ON public.hmacauth_credentials USING gin (tags);


--
-- Name: jwt_secrets_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwt_secrets_consumer_id_idx ON public.jwt_secrets USING btree (consumer_id);


--
-- Name: jwt_secrets_secret_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwt_secrets_secret_idx ON public.jwt_secrets USING btree (secret);


--
-- Name: jwtsecrets_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwtsecrets_tags_idex_tags_idx ON public.jwt_secrets USING gin (tags);


--
-- Name: keyauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_credentials_consumer_id_idx ON public.keyauth_credentials USING btree (consumer_id);


--
-- Name: keyauth_credentials_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_credentials_ttl_idx ON public.keyauth_credentials USING btree (ttl);


--
-- Name: keyauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_tags_idex_tags_idx ON public.keyauth_credentials USING gin (tags);


--
-- Name: locks_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX locks_ttl_idx ON public.locks USING btree (ttl);


--
-- Name: oauth2_authorization_codes_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_codes_authenticated_userid_idx ON public.oauth2_authorization_codes USING btree (authenticated_userid);


--
-- Name: oauth2_authorization_codes_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_codes_ttl_idx ON public.oauth2_authorization_codes USING btree (ttl);


--
-- Name: oauth2_authorization_credential_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_credential_id_idx ON public.oauth2_authorization_codes USING btree (credential_id);


--
-- Name: oauth2_authorization_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_service_id_idx ON public.oauth2_authorization_codes USING btree (service_id);


--
-- Name: oauth2_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_consumer_id_idx ON public.oauth2_credentials USING btree (consumer_id);


--
-- Name: oauth2_credentials_secret_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_secret_idx ON public.oauth2_credentials USING btree (client_secret);


--
-- Name: oauth2_credentials_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_tags_idex_tags_idx ON public.oauth2_credentials USING gin (tags);


--
-- Name: oauth2_tokens_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_authenticated_userid_idx ON public.oauth2_tokens USING btree (authenticated_userid);


--
-- Name: oauth2_tokens_credential_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_credential_id_idx ON public.oauth2_tokens USING btree (credential_id);


--
-- Name: oauth2_tokens_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_service_id_idx ON public.oauth2_tokens USING btree (service_id);


--
-- Name: oauth2_tokens_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_ttl_idx ON public.oauth2_tokens USING btree (ttl);


--
-- Name: plugins_api_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_api_id_idx ON public.plugins USING btree (api_id);


--
-- Name: plugins_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_consumer_id_idx ON public.plugins USING btree (consumer_id);


--
-- Name: plugins_name_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_name_idx ON public.plugins USING btree (name);


--
-- Name: plugins_route_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_route_id_idx ON public.plugins USING btree (route_id);


--
-- Name: plugins_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_service_id_idx ON public.plugins USING btree (service_id);


--
-- Name: plugins_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_tags_idx ON public.plugins USING gin (tags);


--
-- Name: ratelimiting_metrics_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX ratelimiting_metrics_idx ON public.ratelimiting_metrics USING btree (service_id, route_id, period_date, period);


--
-- Name: ratelimiting_metrics_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX ratelimiting_metrics_ttl_idx ON public.ratelimiting_metrics USING btree (ttl);


--
-- Name: routes_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX routes_service_id_idx ON public.routes USING btree (service_id);


--
-- Name: routes_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX routes_tags_idx ON public.routes USING gin (tags);


--
-- Name: services_fkey_client_certificate; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX services_fkey_client_certificate ON public.services USING btree (client_certificate_id);


--
-- Name: services_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX services_tags_idx ON public.services USING gin (tags);


--
-- Name: session_sessions_expires_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX session_sessions_expires_idx ON public.sessions USING btree (expires);


--
-- Name: snis_certificate_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX snis_certificate_id_idx ON public.snis USING btree (certificate_id);


--
-- Name: snis_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX snis_tags_idx ON public.snis USING gin (tags);


--
-- Name: tags_entity_name_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX tags_entity_name_idx ON public.tags USING btree (entity_name);


--
-- Name: tags_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX tags_tags_idx ON public.tags USING gin (tags);


--
-- Name: targets_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_tags_idx ON public.targets USING gin (tags);


--
-- Name: targets_target_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_target_idx ON public.targets USING btree (target);


--
-- Name: targets_upstream_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_upstream_id_idx ON public.targets USING btree (upstream_id);


--
-- Name: ttls_primary_uuid_value_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX ttls_primary_uuid_value_idx ON public.ttls USING btree (primary_uuid_value);


--
-- Name: upstreams_fkey_client_certificate; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX upstreams_fkey_client_certificate ON public.upstreams USING btree (client_certificate_id);


--
-- Name: upstreams_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX upstreams_tags_idx ON public.upstreams USING gin (tags);


--
-- Name: workspaces_name_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX workspaces_name_idx ON public.workspaces USING btree (name);


--
-- Name: acls acls_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER acls_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.acls FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: basicauth_credentials basicauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER basicauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.basicauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: ca_certificates ca_certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER ca_certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.ca_certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: certificates certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: consumers consumers_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER consumers_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.consumers FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: hmacauth_credentials hmacauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER hmacauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.hmacauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: jwt_secrets jwtsecrets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER jwtsecrets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.jwt_secrets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: keyauth_credentials keyauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER keyauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keyauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: oauth2_credentials oauth2_credentials_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER oauth2_credentials_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.oauth2_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: plugins plugins_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER plugins_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.plugins FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: routes routes_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER routes_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.routes FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: services services_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER services_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.services FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: snis snis_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER snis_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.snis FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: targets targets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER targets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.targets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: upstreams upstreams_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER upstreams_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.upstreams FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: acls acls_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: acls acls_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: basicauth_credentials basicauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: certificates certificates_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: consumers consumers_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: hmacauth_credentials hmacauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: jwt_secrets jwt_secrets_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: jwt_secrets jwt_secrets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keyauth_credentials keyauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_credentials oauth2_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_tokens oauth2_tokens_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: plugins plugins_api_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_api_id_fkey FOREIGN KEY (api_id) REFERENCES public.apis(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_route_id_fkey FOREIGN KEY (route_id, ws_id) REFERENCES public.routes(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: routes routes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id);


--
-- Name: routes routes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: services services_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_client_certificate_id_fkey FOREIGN KEY (client_certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: services services_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: snis snis_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_certificate_id_fkey FOREIGN KEY (certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: snis snis_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: targets targets_upstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_upstream_id_fkey FOREIGN KEY (upstream_id, ws_id) REFERENCES public.upstreams(id, ws_id) ON DELETE CASCADE;


--
-- Name: targets targets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: upstreams upstreams_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_client_certificate_id_fkey FOREIGN KEY (client_certificate_id) REFERENCES public.certificates(id);


--
-- Name: upstreams upstreams_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- PostgreSQL database dump complete
--

