CREATE TABLE teltonika_gps.gps_summary_imm (
    imei BIGINT NOT NULL,
    start_time DATETIME,
    end_time DATETIME,
    avg_speed FLOAT,
    max_speed FLOAT,
    engine_duration TIME,
    idle_duration TIME,
    stop_duration TIME,
    starting_satellite INT,
    ending_satellite INT);

DESCRIBE teltonika_gps.asset_activity_report_main_tbl;
