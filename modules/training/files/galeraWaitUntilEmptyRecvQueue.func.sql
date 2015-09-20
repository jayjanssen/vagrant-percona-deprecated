USE test; DROP FUNCTION IF EXISTS galeraWaitUntilEmptyRecvQueue; 
DELIMITER $$
CREATE 
    DEFINER=root@localhost FUNCTION galeraWaitUntilEmptyRecvQueue()
    RETURNS INT UNSIGNED READS SQL DATA
BEGIN
    DECLARE queue INT UNSIGNED;
    DECLARE starttime TIMESTAMP;
    DECLARE blackhole INT UNSIGNED;
    SET starttime = SYSDATE();
    SELECT VARIABLE_VALUE AS trx INTO queue
        FROM information_schema.GLOBAL_STATUS
        WHERE VARIABLE_NAME = 'wsrep_local_recv_queue';   
    WHILE queue > 1 DO /* we allow the queue to be 1 */
        SELECT VARIABLE_VALUE AS trx INTO queue
            FROM information_schema.GLOBAL_STATUS
            WHERE VARIABLE_NAME = 'wsrep_local_recv_queue';
        SELECT SLEEP(1) into blackhole;
    END WHILE;
    RETURN SYSDATE() - starttime;
END$$
DELIMITER ;