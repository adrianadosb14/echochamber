DROP FUNCTION IF EXISTS exception_session_expired;
CREATE OR REPLACE FUNCTION exception_session_expired()
RETURNS VOID
AS $$
BEGIN
    RAISE 'session_expired';
END;$$ language plpgsql;


DROP FUNCTION IF EXISTS exception_action_not_allowed;
CREATE OR REPLACE FUNCTION exception_action_not_allowed()
RETURNS VOID
AS $$
BEGIN
    RAISE 'action_not_allowed';
END;$$ language plpgsql;