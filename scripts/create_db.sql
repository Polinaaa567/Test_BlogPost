CREATE DATABASE blogpost
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


\c blogpost;

CREATE SEQUENCE IF NOT EXISTS public.users_id_user_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.users_id_user_seq
    OWNED BY public.users.id_user;

ALTER SEQUENCE public.users_id_user_seq
    OWNER TO postgres;

CREATE SEQUENCE IF NOT EXISTS public.post_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.post_id_seq
    OWNER TO postgres;

CREATE SEQUENCE IF NOT EXISTS public.id_comment_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.id_comment_seq
    OWNED BY public.comments.id_comment;

ALTER SEQUENCE public.id_comment_seq
    OWNER TO postgres;


CREATE SEQUENCE IF NOT EXISTS public.post_likes_id_post_likes_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.post_likes_id_post_likes_seq
    OWNED BY public.post_likes.id_post_likes;

ALTER SEQUENCE public.post_likes_id_post_likes_seq
    OWNER TO postgres;


CREATE TABLE IF NOT EXISTS public.users
(
    id_user integer NOT NULL DEFAULT nextval('users_id_user_seq'::regclass),
    email text COLLATE pg_catalog."default" NOT NULL,
    password text COLLATE pg_catalog."default" NOT NULL,
    last_name text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    avatar bigint[],
    CONSTRAINT users_pkey PRIMARY KEY (id_user)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.posts
(
    id_post integer NOT NULL DEFAULT nextval('post_id_seq'::regclass),
    headline text COLLATE pg_catalog."default",
    text_post text COLLATE pg_catalog."default",
    id_user_creator integer NOT NULL,
    state text COLLATE pg_catalog."default" NOT NULL,
    date_published timestamp with time zone,
    photo_post bigint[],
    CONSTRAINT posts_pkey PRIMARY KEY (id_post),
    CONSTRAINT posts_id_user_creator_fkey FOREIGN KEY (id_user_creator)
        REFERENCES public.users (id_user) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.posts
    OWNER to postgres;


CREATE TABLE IF NOT EXISTS public.post_likes
(
    id_post_likes integer NOT NULL DEFAULT nextval('post_likes_id_post_likes_seq'::regclass),
    id_post integer NOT NULL,
    id_user integer NOT NULL,
    CONSTRAINT post_likes_pkey PRIMARY KEY (id_post_likes),
    CONSTRAINT post_likes_id_post_fkey FOREIGN KEY (id_post)
        REFERENCES public.posts (id_post) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID,
    CONSTRAINT post_likes_id_user_fkey FOREIGN KEY (id_user)
        REFERENCES public.users (id_user) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.post_likes
    OWNER to postgres;


CREATE TABLE IF NOT EXISTS public.comments
(
    id_comment integer NOT NULL DEFAULT nextval('id_comment_seq'::regclass),
    id_user_comment integer,
    id_post integer NOT NULL,
    text_comment text COLLATE pg_catalog."default" NOT NULL,
    date_creator timestamp with time zone NOT NULL,
    CONSTRAINT comments_pkey PRIMARY KEY (id_comment),
    CONSTRAINT comments_id_post_fkey FOREIGN KEY (id_post)
        REFERENCES public.posts (id_post) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID,
    CONSTRAINT comments_id_user_comment_fkey FOREIGN KEY (id_user_comment)
        REFERENCES public.users (id_user) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.comments
    OWNER to postgres;