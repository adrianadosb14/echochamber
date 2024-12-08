/*
  _   _ _____ _   _  ___  ______ _____ _____ _____ 
 | | | /  ___| | | |/ _ \ | ___ \_   _|  _  /  ___|
 | | | \ `--.| | | / /_\ \| |_/ / | | | | | \ `--. 
 | | | |`--. \ | | |  _  ||    /  | | | | | |`--. \
 | |_| /\__/ / |_| | | | || |\ \ _| |_\ \_/ /\__/ /
  \___/\____/ \___/\_| |_/\_| \_|\___/ \___/\____/                                          
*/

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_user;
CREATE OR REPLACE FUNCTION create_user(
    i_username VARCHAR,
    i_email VARCHAR,
    i_password VARCHAR,
    i_type INT
	)
RETURNS TABLE(o_user_id uuid)
AS $$
BEGIN
    o_user_id = gen_random_uuid();
    INSERT INTO users(
        user_id,
        username,
        email,
        password,
        type
    )VALUES(
        o_user_id,
        i_username,
        i_email,
        crypt(i_password, gen_salt('bf')),
        i_type
    );
	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS delete_user;
CREATE OR REPLACE FUNCTION delete_user(
    i_user_id uuid
	)
RETURNS TABLE(o_user_id uuid)
AS $$
BEGIN
    o_user_id = i_user_id;
    delete from users where user_id = i_user_id;
	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

/*
  _____ _____ _____ _____ _____ _   _  _____ _____ 
 /  ___|  ___/  ___|_   _|  _  | \ | ||  ___/  ___|
 \ `--.| |__ \ `--.  | | | | | |  \| || |__ \ `--. 
  `--. \  __| `--. \ | | | | | | . ` ||  __| `--. \
 /\__/ / |___/\__/ /_| |_\ \_/ / |\  || |___/\__/ /
 \____/\____/\____/ \___/ \___/\_| \_/\____/\____/ 
*/

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS login_user;
CREATE OR REPLACE FUNCTION login_user(
    i_email VARCHAR,
    i_password VARCHAR
	)
RETURNS TABLE(o_last_access TIMESTAMPTZ, o_user_id uuid, o_username varchar,  o_type int)
AS $$
DECLARE x_user_id uuid;
BEGIN
    SELECT user_id, username, type FROM users
    WHERE email = i_email AND password = crypt(i_password, password)
    INTO o_user_id, o_username, o_type;

    IF (o_user_id IS NOT NULL)
    THEN
        UPDATE users SET last_access = NOW()
        WHERE user_id = o_user_id;

        o_last_access = NOW();
    END IF;

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS check_session;
CREATE OR REPLACE FUNCTION check_session(
    i_user_id uuid
	)
RETURNS TABLE(o_last_access TIMESTAMPTZ)
AS $$
DECLARE x_last_access TIMESTAMPTZ;
BEGIN
    
    SELECT last_access FROM users
    WHERE user_id = i_user_id
    INTO x_last_access;

    IF (x_last_access + INTERVAL '30 Minutes' < NOW())
    THEN
        PERFORM exception_session_expired();
    ELSE
        UPDATE users SET last_access = NOW()
        WHERE user_id = i_user_id;
        
        o_last_access = NOW();
    END IF;

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

/*
 
 ______ _____ _____ _____ 
 | ___ \  _  /  ___|_   _|
 | |_/ / | | \ `--.  | |  
 |  __/| | | |`--. \ | |  
 | |   \ \_/ /\__/ / | |  
 \_|    \___/\____/  \_/  
                          
                          
 
*/

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_post;
CREATE OR REPLACE FUNCTION create_post(
    i_user_id uuid,
    i_event_id uuid,
    i_content VARCHAR
	)
RETURNS TABLE(o_post_id uuid)
AS $$
BEGIN
    
    o_post_id = gen_random_uuid();
    INSERT INTO post(
        post_id,
        user_id,
        event_id,
        content,
        creation_date
    ) VALUES(
        o_post_id,
        i_user_id,
        i_event_id,
        i_content,
        now()
    );

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS delete_post;
CREATE OR REPLACE FUNCTION delete_post(
    i_user_id uuid,         -- Usuario que realiza la acción.   
    i_post_id uuid
	)
RETURNS TABLE(o_post_id uuid)
AS $$
declare x_op_user_id uuid;  -- Original poster user_id
BEGIN
    
    SELECT user_id FROM post
    WHERE post_id = i_post_id
    INTO x_op_user_id;

    -- Si el usuario que realiza la acción es el que publicó el post,
    -- lo eliminamos.
    -- Si no, lanzamos una excepción.
    IF (x_op_user_id = i_user_id)
    THEN
        DELETE FROM post WHERE post_id = i_post_id;
        o_post_id = i_post_id;
    ELSE
         PERFORM exception_action_not_allowed();
    END IF;

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_posts;
CREATE OR REPLACE FUNCTION get_posts(
    i_event_id uuid
    )
RETURNS TABLE(
    o_post_id uuid,
    o_user_id uuid,
    o_username varchar,
    o_event_id uuid,
    o_content varchar,
    o_creation_date TIMESTAMPTZ
    )
AS $$
declare x_r record;
BEGIN
    
    for x_r in
    select p.*, u.username from post p
    join users u on u.user_id = p.user_id
    where event_id = i_event_id
    loop
        o_post_id = x_r.post_id;
        o_user_id = x_r.user_id;
        o_username = x_r.username;
        o_event_id = x_r.event_id;
        o_content = x_r.content;
        o_creation_date = x_r.creation_date;
	RETURN NEXT;
    end loop;

END;$$ language plpgsql;


/*
  _____ _   _ _____ _   _ _____ _____ _____ 
 |  ___| | | |  ___| \ | |_   _|  _  /  ___|
 | |__ | | | | |__ |  \| | | | | | | \ `--. 
 |  __|| | | |  __|| . ` | | | | | | |`--. \
 | |___\ \_/ / |___| |\  | | | \ \_/ /\__/ /
 \____/ \___/\____/\_| \_/ \_/  \___/\____/ 
                                                                                   
*/

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_event;
CREATE OR REPLACE FUNCTION create_event(
    i_user_id uuid,
    i_title VARCHAR,
    i_description VARCHAR,
    i_start_date TIMESTAMPTZ,
    i_end_date TIMESTAMPTZ,
    i_latitude double precision,
    i_longitude double precision

	)
RETURNS TABLE(o_event_id uuid)
AS $$
BEGIN
    
    o_event_id = gen_random_uuid();
    INSERT INTO event(
        event_id,
        user_id,
        title,
        description,
        start_date,
        end_date,
        geoloc
    ) VALUES(
        o_event_id,
        i_user_id,
        i_title,
        i_description,
        i_start_date,
        i_end_date,
        ST_GeomFromText('POINT('|| i_longitude || ' ' || i_latitude || ')', 4326)
    );
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS delete_event;
CREATE OR REPLACE FUNCTION delete_event(
    i_user_id uuid,         -- Usuario que realiza la acción.   
    i_event_id uuid
	)
RETURNS TABLE(o_event_id uuid)
AS $$
declare x_op_user_id uuid;  -- Original poster user_id
BEGIN
    
    SELECT user_id FROM event
    WHERE event_id = i_event_id
    INTO x_op_user_id;

    -- Si el usuario que realiza la acción es el que publicó el post,
    -- lo eliminamos.
    -- Si no, lanzamos una excepción.
    IF (x_op_user_id = i_user_id)
    THEN
        DELETE FROM event WHERE event_id = i_event_id;
        o_event_id = i_event_id;
    ELSE
         PERFORM exception_action_not_allowed();
    END IF;

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_events;
CREATE OR REPLACE FUNCTION get_events(
    i_search_term VARCHAR,
    i_start_date TIMESTAMPTZ,
    i_end_date TIMESTAMPTZ,
    i_longitude double precision,
    i_latitude double precision,
    i_radius double precision
)
RETURNS TABLE(
    o_event_id uuid,
    o_user_id uuid,
    o_title varchar,
    o_description varchar,
    o_start_date TIMESTAMPTZ,
    o_end_date TIMESTAMPTZ,
    o_longitude double precision,
    o_latitude double precision
    )
AS $$
declare x_r record;
BEGIN
    
    for x_r in
    select * from event
    where ((i_search_term is null) or
    title ilike ('%'|| i_search_term || '%') or
    description ilike ('%'|| i_search_term || '%')) AND
    ((i_start_date is null or i_end_date is null) OR (start_date BETWEEN i_start_date and i_end_date)) AND
    ((i_longitude is null or i_latitude is null) OR (ST_DWithin(Geography(event.geoloc),Geography(ST_MakePoint(i_longitude,i_latitude)),i_radius)))


    loop
        o_event_id = x_r.event_id;
        o_user_id = x_r.user_id;
        o_title = x_r.title;
        o_description = x_r.description;
        o_start_date = x_r.start_date;
        o_end_date = x_r.end_date;
        o_longitude = ST_X(x_r.geoloc::geometry);
        o_latitude = ST_Y(x_r.geoloc::geometry);
	RETURN NEXT;
    end loop;

END;$$ language plpgsql;


/*

 ______ _____ _      _____ 
 |  ___|_   _| |    |  ___|
 | |_    | | | |    | |__  
 |  _|   | | | |    |  __| 
 | |    _| |_| |____| |___ 
 \_|    \___/\_____/\____/ 
                                             
 
*/
--------------------------------------------------------------------
DROP FUNCTION IF EXISTS upload_file;
CREATE OR REPLACE FUNCTION upload_file(
    i_user_id uuid,
    i_filename VARCHAR
	)
RETURNS TABLE(o_file_id uuid)
AS $$
BEGIN
    
    o_file_id = gen_random_uuid();
    INSERT INTO file(
        file_id,
        user_id,
        filename
    ) VALUES(
        o_file_id,
        i_user_id,
        i_filename
    );
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_event_file;
CREATE OR REPLACE FUNCTION create_event_file(
    i_event_id uuid,
    i_user_id uuid,
    i_filename VARCHAR
	)
RETURNS TABLE(o_event_file_id uuid, o_file_id uuid)
AS $$
BEGIN

    SELECT uf.o_file_id FROM upload_file(
    i_user_id,
    i_filename
	) uf INTO o_file_id;
    
    o_event_file_id = gen_random_uuid();
    INSERT INTO event_file(
        event_file_id,
        event_id,
        file_id
    ) VALUES(
        o_event_file_id,
        i_event_id,
        o_file_id
    );
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS remove_event_file;
CREATE OR REPLACE FUNCTION remove_event_file(
    i_event_file_id uuid,
    i_user_id uuid
	)
RETURNS TABLE(o_event_file_id uuid)
AS $$
DECLARE x_file_id uuid;
DECLARE x_user_id uuid;
BEGIN

    SELECT file_id, user_id from event_file
    where event_file_id = i_event_file_id
    into x_file_id, x_user_id;

    if (x_user_id != i_user_id)
    THEN
        PERFORM exception_action_not_allowed();
    end if;

    DELETE FROM file WHERE file_id = x_file_id;
    DELETE FROM event_file WHERE event_file_id = i_event_file_id;

    o_event_file_id = i_event_file_id;
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_event_files;
CREATE OR REPLACE FUNCTION get_event_files(
    i_event_id uuid
	)
RETURNS TABLE(o_file_id uuid, o_user_id uuid, o_username VARCHAR, o_filename VARCHAR, o_event_file_id uuid, o_event_id uuid)
AS $$
declare x_r record;
BEGIN
    for x_r in
    select ef.*, f.filename, u.username, f.user_id from event_file ef
    join file f on f.file_id = ef.file_id
    join users u on u.user_id = f.user_id
    where ef.event_id = i_event_id
    loop
        o_file_id = x_r.file_id;
        o_user_id = x_r.user_id;
        o_username = x_r.username;
        o_filename = x_r.filename;
        o_event_file_id = x_r.event_file_id;
        o_event_id = x_r.event_id;
        RETURN NEXT;
    end loop;
END;$$ language plpgsql;

--------------------------------------------------------------------
/*
  _____ ___  _____  _____ 
 |_   _/ _ \|  __ \/  ___|
   | |/ /_\ \ |  \/\ `--. 
   | ||  _  | | __  `--. \
   | || | | | |_\ \/\__/ /
   \_/\_| |_/\____/\____/ 

*/
--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_tag;
CREATE OR REPLACE FUNCTION create_tag(
    i_name VARCHAR,
    i_color VARCHAR
	)
RETURNS TABLE(o_tag_id uuid)
AS $$
BEGIN
    
    o_tag_id = gen_random_uuid();
    INSERT INTO tag(
        tag_id,
        name,
        color
    ) VALUES(
        o_tag_id,
        i_name,
        i_color
    );

	
	RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS delete_tag;
CREATE OR REPLACE FUNCTION delete_tag(
    i_user_id uuid,  -- Usuario que realiza la acción.   
    i_tag_id uuid
	)
RETURNS TABLE(o_tag_id uuid)
AS $$
BEGIN
    
    -- COMPROBAR PERMISOS!!!!!!!!!!

    DELETE FROM tag WHERE tag_id = i_tag_id;
    o_tag_id = i_tag_id;


	
	RETURN NEXT;
END;$$ language plpgsql;

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_all_tags;
CREATE OR REPLACE FUNCTION get_all_tags(
	)
RETURNS TABLE(o_tag_id uuid, o_name VARCHAR, o_color VARCHAR)
AS $$
declare x_r record;
BEGIN
    for x_r in
    select * from tag
    loop
        o_tag_id = x_r.tag_id;
        o_name = x_r.name;
        o_color = x_r.color;
        RETURN NEXT;
    end loop;
END;$$ language plpgsql;

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_event_tags;
CREATE OR REPLACE FUNCTION get_event_tags(
    i_event_id uuid
	)
RETURNS TABLE(o_event_tag_id uuid, o_event_id uuid, o_tag_id uuid, o_color VARCHAR, o_name VARCHAR)
AS $$
declare x_r record;
BEGIN

    for x_r in
    select et.*, t.name, t.color from event_tag et
    join tag t on t.tag_id = et.tag_id
    where et.event_id = i_event_id
    loop
        o_event_tag_id = x_r.event_tag_id;
        o_event_id = x_r.event_id;
        o_tag_id = x_r.tag_id;
        o_color = x_r.color;
        o_name = x_r.name;
        RETURN NEXT;
    end loop;
END;$$ language plpgsql;

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_event_tag;
CREATE OR REPLACE FUNCTION create_event_tag(
    i_event_id uuid,
    i_tag_id uuid
	)
RETURNS TABLE(o_event_tag_id uuid)
AS $$
BEGIN
    o_event_tag_id = gen_random_uuid();
    INSERT INTO event_tag(
        event_tag_id,
        event_id,
        tag_id
    ) VALUES (
        o_event_tag_id,
        i_event_id,
        i_tag_id
    );

    RETURN NEXT;
END;$$ language plpgsql;

/*
 
  _     _____ _   __ _____ _____ 
 | |   |_   _| | / /|  ___/  ___|
 | |     | | | |/ / | |__ \ `--. 
 | |     | | |    \ |  __| `--. \
 | |_____| |_| |\  \| |___/\__/ /
 \_____/\___/\_| \_/\____/\____/ 
                                 
                                 
 
*/

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_event_like;
CREATE OR REPLACE FUNCTION create_event_like(
    i_user_id uuid,
    i_event_id uuid
	)
RETURNS TABLE(o_event_like_id uuid)
AS $$
BEGIN
    o_event_like_id = gen_random_uuid();
    INSERT INTO event_like(
        event_like_id,
        user_id,
        event_id,
        creation_date
    ) VALUES (
        o_event_like_id,
        i_user_id,
        i_event_id,
        now()
    );

    RETURN NEXT;
END;$$ language plpgsql;

--------------------------------------------------------------------
DROP FUNCTION IF EXISTS remove_event_like;
CREATE OR REPLACE FUNCTION remove_event_like(
    i_user_id uuid,
    i_event_like_id uuid
	)
RETURNS TABLE(o_event_like_id uuid)
AS $$
declare x_op_user_id uuid;  -- Original poster user_id
BEGIN

    select user_id from event_like
    where event_like_id = i_event_like_id
    into x_op_user_id;
    
    IF (x_op_user_id = i_user_id)
    THEN
        DELETE FROM event_like WHERE event_like_id = i_event_like_id;
        o_event_like_id = i_event_like_id;
    ELSE
         PERFORM exception_action_not_allowed();
    END IF;

    RETURN NEXT;
END;$$ language plpgsql;
--------------------------------------------------------------------
DROP FUNCTION IF EXISTS get_event_likes;
CREATE OR REPLACE FUNCTION get_event_likes(
    i_event_id uuid
	)
RETURNS TABLE(o_event_like_id uuid, o_event_id uuid, o_user_id uuid, o_username VARCHAR, o_creation_date TIMESTAMPTZ)
AS $$
declare x_r record;
BEGIN
    for x_r in
    select el.*, u.username from event_like el
    join users u on u.user_id = el.user_id
    where el.event_id = i_event_id
    loop
        o_event_like_id = x_r.event_like_id;
        o_user_id = x_r.user_id;
        o_username = x_r.username;
        o_event_id = x_r.event_id;
        o_creation_date = x_r.creation_date;
        RETURN NEXT;
    end loop;
END;$$ language plpgsql;