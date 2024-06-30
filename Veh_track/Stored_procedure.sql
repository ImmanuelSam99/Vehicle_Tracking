DELIMITER $$

CREATE PROCEDURE `gps_summary_imm`()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE current_imei BIGINT;

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE avg_speed FLOAT;
    DECLARE max_speed FLOAT;
    DECLARE engine_duration TIME;
    DECLARE idle_duration TIME;
    DECLARE stop_duration TIME;
    DECLARE starting_satellite INT;
    DECLARE ending_satellite INT;

    DECLARE cur CURSOR FOR 
    SELECT DISTINCT imei 
    FROM teltonika_gps.asset_activity_report_main_tbl 
    WHERE DATE(datetime_info) = '2023-06-03';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO current_imei;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS (
            SELECT 1 
            FROM teltonika_gps.gps_summary_imm 
            WHERE imei = current_imei AND DATE(start_time) = '2023-06-03'
        ) THEN

            SELECT MIN(datetime_info), MAX(datetime_info) INTO start_time, end_time
            FROM teltonika_gps.asset_activity_report_main_tbl
            WHERE imei = current_imei AND DATE(datetime_info) = '2023-06-03';

            SELECT AVG(speed), MAX(speed) INTO avg_speed, max_speed
            FROM teltonika_gps.asset_activity_report_main_tbl
            WHERE imei = current_imei AND DATE(datetime_info) = '2023-06-03';

            SELECT 
                SEC_TO_TIME(SUM(TIME_TO_SEC(delta_time) * (ignition_type = 1 AND movement_type = 1))),
                SEC_TO_TIME(SUM(TIME_TO_SEC(delta_time) * (ignition_type = 1 AND movement_type = 0))),
                SEC_TO_TIME(SUM(TIME_TO_SEC(delta_time) * (ignition_type = 0 AND movement_type = 0)))
			INTO engine_duration, idle_duration, stop_duration
            FROM teltonika_gps.asset_activity_report_main_tbl
            WHERE imei = current_imei 
			AND DATE(datetime_info) = '2023-06-03';

            SELECT satellites
            INTO starting_satellite
            FROM teltonika_gps.asset_activity_report_main_tbl
            WHERE imei = current_imei 
			AND DATE(datetime_info) = '2023-06-03'
            ORDER BY datetime_info ASC
            LIMIT 1;

            SELECT satellites
            INTO ending_satellite
            FROM teltonika_gps.asset_activity_report_main_tbl
            WHERE imei = current_imei 
            AND DATE(datetime_info) = '2023-06-03'
            ORDER BY datetime_info DESC
            LIMIT 1;

            INSERT INTO teltonika_gps.gps_summary_imm (imei, start_time, end_time, avg_speed, max_speed, engine_duration, 
                idle_duration, stop_duration, starting_satellite, ending_satellite) 
			VALUES (current_imei, start_time, end_time, avg_speed, max_speed, engine_duration, idle_duration, stop_duration, 
            starting_satellite, ending_satellite);
        END IF;
    END LOOP;
CLOSE cur;
END$$

DELIMITER ;
