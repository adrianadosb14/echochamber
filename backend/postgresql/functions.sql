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
    i_description VARCHAR,
    i_avatar BYTEA,
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
        description,
        avatar,
        type
    )VALUES(
        o_user_id,
        i_username,
        i_email,
        crypt(i_password, gen_salt('bf')),
        i_description,
        i_avatar,
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
RETURNS TABLE(o_last_access TIMESTAMPTZ, o_user_id uuid, o_username varchar)
AS $$
DECLARE x_user_id uuid;
BEGIN
    SELECT user_id, username FROM users
    WHERE email = i_email AND password = crypt(i_password, password)
    INTO o_user_id, o_username;

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
    i_content VARCHAR
	)
RETURNS TABLE(o_post_id uuid)
AS $$
BEGIN
    
    o_post_id = gen_random_uuid();
    INSERT INTO post(
        post_id,
        user_id,
        content
    ) VALUES(
        o_post_id,
        i_user_id,
        i_content
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
CREATE OR REPLACE FUNCTION get_events()
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
