-- View 1: Tải kết nối thiết bị theo máy chủ
CREATE OR REPLACE VIEW vw_server_device_load AS
SELECT s.serverID,
       s.serverName,
       s.ipAddress,
       sr.roomName,
       COUNT(dsa.approvalID) AS activeDeviceCount
FROM SERVER AS s
JOIN SERVER_ROOM AS sr ON sr.serverRoomID = s.serverRoomID
LEFT JOIN DEVICE_SERVER_APPROVAL AS dsa
       ON dsa.serverID = s.serverID
      AND dsa.revocationDate IS NULL
GROUP BY s.serverID, s.serverName, s.ipAddress, sr.roomName;

-- Test:
SELECT * FROM vw_server_device_load ORDER BY activeDeviceCount DESC;

- View 2: Tổng hợp quyền truy cập dịch vụ theo người dùng
CREATE OR REPLACE VIEW vw_user_permission_summary AS
SELECT u.userID,
       CONCAT(u.lastName,' ',u.firstName) AS fullName,
       un.unitName,
       svc.serviceName,
       s.serverName,
       sp.permissionGrantDate
FROM SERVICE_PERMISSION AS sp
JOIN USER    AS u   ON u.userID   = sp.userID
JOIN UNIT    AS un  ON un.unitID  = u.unitID
JOIN SERVICE AS svc ON svc.serviceID = sp.serviceID
JOIN SERVER  AS s   ON s.serverID   = svc.serverID
ORDER BY u.lastName, svc.serviceName;

-- Test:
SELECT * FROM vw_user_permission_summary WHERE fullName LIKE '%An%';

DELIMITER $$

CREATE FUNCTION fn_count_active_approvals(
  p_deviceID VARCHAR(36)
)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
  DECLARE v_count INT DEFAULT 0;
  SELECT COUNT(*)
    INTO v_count
    FROM DEVICE_SERVER_APPROVAL
   WHERE deviceID       = p_deviceID
     AND revocationDate IS NULL;
  RETURN v_count;
END$$

DELIMITER ;

-- Test:
SELECT fn_count_active_approvals('d001') AS activeApprovals;  -- Expected: 2
SELECT fn_count_active_approvals('d999') AS activeApprovals;  -- Expected: 0

DELIMITER $$

CREATE PROCEDURE sp_approve_device_server(
  IN p_approvalID   VARCHAR(36),
  IN p_deviceID     VARCHAR(36),
  IN p_serverID     VARCHAR(36),
  IN p_approvalDate DATE
)
BEGIN
  DECLARE v_deviceExists INT DEFAULT 0;
  DECLARE v_serverExists INT DEFAULT 0;
  DECLARE v_activeExists INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- Kiểm tra device
  SELECT COUNT(*) INTO v_deviceExists FROM DEVICE WHERE deviceID = p_deviceID;
  IF v_deviceExists = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Device does not exist';
  END IF;

  -- Kiểm tra server
  SELECT COUNT(*) INTO v_serverExists FROM SERVER WHERE serverID = p_serverID;
  IF v_serverExists = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Server does not exist';
  END IF;

  -- Kiểm tra đã có approval active chưa
  SELECT COUNT(*) INTO v_activeExists
    FROM DEVICE_SERVER_APPROVAL
   WHERE deviceID = p_deviceID AND serverID = p_serverID
     AND revocationDate IS NULL;
  IF v_activeExists > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Active approval already exists for this device-server pair';
  END IF;

  INSERT INTO DEVICE_SERVER_APPROVAL
    (approvalID, deviceID, serverID, approvalDate, revocationDate)
  VALUES
    (p_approvalID, p_deviceID, p_serverID, p_approvalDate, NULL);

  COMMIT;
  SELECT 'Approval created successfully' AS result;
END$$

DELIMITER ;

-- Test positive:
CALL sp_approve_device_server('ap_new','d005','sv003',CURDATE());
-- Test negative (device không tồn tại):
CALL sp_approve_device_server('ap_x','d999','sv001',CURDATE());
-- Test negative (đã có active approval):
CALL sp_approve_device_server('ap_dup','d001','sv001',CURDATE());

DELIMITER $$

CREATE PROCEDURE sp_revoke_device_access(
  IN p_deviceID       VARCHAR(36),
  IN p_serverID       VARCHAR(36),
  IN p_revocationDate DATE
)
BEGIN
  DECLARE v_approvalID VARCHAR(36) DEFAULT NULL;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT approvalID INTO v_approvalID
    FROM DEVICE_SERVER_APPROVAL
   WHERE deviceID = p_deviceID
     AND serverID = p_serverID
     AND revocationDate IS NULL
   LIMIT 1
   FOR UPDATE;

  IF v_approvalID IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No active approval found to revoke';
  END IF;

  UPDATE DEVICE_SERVER_APPROVAL
     SET revocationDate = p_revocationDate
   WHERE approvalID = v_approvalID;

  COMMIT;
  SELECT CONCAT('Revoked approval: ', v_approvalID) AS result;
END$$

DELIMITER ;

-- Test positive:
CALL sp_revoke_device_access('d003','sv003',CURDATE());
-- Test negative (không có record active):
CALL sp_revoke_device_access('d003','sv003',CURDATE());