- 6.1 Audit Trigger – trg_au_approval_audit -
DROP TABLE IF EXISTS APPROVAL_AUDIT;

CREATE TABLE APPROVAL_AUDIT
(
    auditID INT AUTO_INCREMENT PRIMARY KEY,
    approvalID VARCHAR(10),
    deviceID VARCHAR(10),
    serverID VARCHAR(10),
    approvalDate DATE,
    revocationDate DATE,
    actionType VARCHAR(20),
    actionTime DATETIME DEFAULT CURRENT_TIMESTAMP
);

6.2 Trigger 
DROP TRIGGER IF EXISTS trg_au_approval_audit;
DELIMITER $$

CREATE TRIGGER trg_au_approval_audit
AFTER INSERT
ON DEVICE_SERVER_APPROVAL
FOR EACH ROW
BEGIN
    INSERT INTO APPROVAL_AUDIT
    (
        approvalID,
        deviceID,
        serverID,
        approvalDate,
        revocationDate,
        actionType
    )
    VALUES
    (
        NEW.approvalID,
        NEW.deviceID,
        NEW.serverID,
        NEW.approvalDate,
        NEW.revocationDate,
        'INSERT'
    );
END$$
DELIMITER ;

6.3 Event Scheduler
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS ev_delete_old_audit;
DELIMITER $$

CREATE EVENT ev_delete_old_audit
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM APPROVAL_AUDIT
    WHERE actionTime < DATE_SUB(NOW(), INTERVAL 90 DAY);
END$$
DELIMITER ;
SHOW EVENTS;





