-- Q01: Danh sách user theo đơn vị, sắp theo tên
SELECT u.userID,
       CONCAT(u.lastName, ' ', u.middleName, ' ', u.firstName) AS fullName,
       u.jobTitle,
       un.unitName
FROM USER AS u
JOIN UNIT AS un ON un.unitID = u.unitID
WHERE un.unitCode = 'CNTT'
ORDER BY u.lastName, u.firstName;

-- Q02: Thiết bị và máy chủ đang được phê duyệt kết nối
SELECT dsa.approvalID,
       CONCAT(u.lastName,' ',u.firstName) AS ownerName,
       d.model                             AS deviceModel,
       s.serverName,
       s.ipAddress,
       dsa.approvalDate
FROM DEVICE_SERVER_APPROVAL AS dsa
JOIN DEVICE AS d  ON d.deviceID  = dsa.deviceID
JOIN USER   AS u  ON u.userID    = d.userID
JOIN SERVER AS s  ON s.serverID  = dsa.serverID
WHERE dsa.revocationDate IS NULL
ORDER BY ownerName, s.serverName;

-- Q03: Dịch vụ chưa có quyền truy cập nào được cấp
SELECT svc.serviceID,
       svc.serviceName,
       s.serverName,
       svc.startDate
FROM SERVICE AS svc
JOIN SERVER  AS s  ON s.serverID = svc.serverID
LEFT JOIN SERVICE_PERMISSION AS sp ON sp.serviceID = svc.serviceID
WHERE sp.servicePermissionID IS NULL
ORDER BY svc.serviceName;

-- Q04: Số thiết bị theo đơn vị; chỉ hiển thị đơn vị có >= 2 thiết bị
SELECT un.unitCode,
       un.unitName,
       COUNT(d.deviceID)                                    AS totalDevices,
       SUM(CASE WHEN fd.deviceID IS NOT NULL THEN 1 ELSE 0 END) AS fixedCount,
       SUM(CASE WHEN md.deviceID IS NOT NULL THEN 1 ELSE 0 END) AS mobileCount
FROM UNIT AS un
JOIN USER   AS u  ON u.unitID   = un.unitID
JOIN DEVICE AS d  ON d.userID   = u.userID
LEFT JOIN FIXED_DEVICE  AS fd ON fd.deviceID = d.deviceID
LEFT JOIN MOBILE_DEVICE AS md ON md.deviceID = d.deviceID
GROUP BY un.unitID, un.unitCode, un.unitName
HAVING COUNT(d.deviceID) >= 2
ORDER BY totalDevices DESC;

-- Q05: User chưa có thiết bị nào được phê duyệt kết nối máy chủ
SELECT u.userID,
       CONCAT(u.lastName,' ',u.firstName) AS fullName,
       u.jobTitle
FROM USER AS u
WHERE NOT EXISTS (
  SELECT 1
  FROM DEVICE AS d
  JOIN DEVICE_SERVER_APPROVAL AS dsa ON dsa.deviceID = d.deviceID
  WHERE d.userID = u.userID
    AND dsa.revocationDate IS NULL
)
ORDER BY u.lastName;

WITH server_device_count AS (
  SELECT s.serverID,
         s.serverName,
         s.ipAddress,
         COUNT(dsa.deviceID) AS activeDeviceCount
  FROM SERVER AS s
  LEFT JOIN DEVICE_SERVER_APPROVAL AS dsa
         ON dsa.serverID = s.serverID
        AND dsa.revocationDate IS NULL
  GROUP BY s.serverID, s.serverName, s.ipAddress
)
SELECT serverName,
       ipAddress,
       activeDeviceCount,
       RANK() OVER (ORDER BY activeDeviceCount DESC) AS loadRank
FROM server_device_count
ORDER BY activeDeviceCount DESC;

-- Q07: Số lượng phê duyệt theo tháng trong năm 2023
SELECT DATE_FORMAT(approvalDate, '%Y-%m') AS approvalMonth,
       COUNT(*)                            AS totalApprovals,
       SUM(CASE WHEN revocationDate IS NOT NULL THEN 1 ELSE 0 END) AS revokedCount
FROM DEVICE_SERVER_APPROVAL
WHERE YEAR(approvalDate) = 2023
GROUP BY DATE_FORMAT(approvalDate, '%Y-%m')
ORDER BY approvalMonth;

-- Q08: Sử dụng view vw_server_device_load
SELECT *
FROM vw_server_device_load
WHERE activeDeviceCount >= 2
ORDER BY activeDeviceCount DESC;