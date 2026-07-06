-- =====================================================
-- UniSecure Research Cloud Database
-- MySQL 8.0
-- =====================================================


DROP DATABASE IF EXISTS unisecure_research_cloud_db;


CREATE DATABASE unisecure_research_cloud_db CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;


USE unisecure_research_cloud_db;


-- =====================================================
-- TABLE: UNIT
-- =====================================================


CREATE TABLE UNIT(
unitID VARCHAR(10) PRIMARY KEY, unitCode VARCHAR(20) NOT NULL UNIQUE, unitName VARCHAR(100) NOT NULL,
postOfficeBox VARCHAR(30), phoneNumber VARCHAR(15)
);


-- =====================================================
-- TABLE: SERVER_ROOM
-- =====================================================

CREATE TABLE SERVER_ROOM( serverRoomID VARCHAR(10) PRIMARY KEY, roomName VARCHAR(100) NOT NULL
);


-- =====================================================
-- TABLE: USER
-- =====================================================


CREATE TABLE `USER`(
userID VARCHAR(10) PRIMARY KEY, unitID VARCHAR(10) NOT NULL, lastName VARCHAR(50) NOT NULL, firstName VARCHAR(50) NOT NULL,
middleName VARCHAR(50), jobTitle VARCHAR(100),

CONSTRAINT fk_user_unit FOREIGN KEY (unitID) REFERENCES UNIT(unitID) ON UPDATE RESTRICT ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: DEVICE
-- =====================================================


CREATE TABLE DEVICE(
deviceID VARCHAR(10) PRIMARY KEY, userID VARCHAR(10) NOT NULL,

manufacturer VARCHAR(100), model VARCHAR(100),
registrationDate DATE,


CONSTRAINT fk_device_user FOREIGN KEY(userID) REFERENCES `USER`(userID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: FIXED_DEVICE
-- =====================================================


CREATE TABLE FIXED_DEVICE( deviceID VARCHAR(10) PRIMARY KEY,
staticIPAddress VARCHAR(45), macAddress VARCHAR(30), buildingName VARCHAR(100), roomNumber VARCHAR(20),

CONSTRAINT fk_fixed_device FOREIGN KEY(deviceID) REFERENCES DEVICE(deviceID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: MOBILE_DEVICE

-- =====================================================


CREATE TABLE MOBILE_DEVICE( deviceID VARCHAR(10) PRIMARY KEY,
serialNumber VARCHAR(100), operatingSystem VARCHAR(100), osVersion VARCHAR(50), screenLockEnabled BOOLEAN, dataEncryptionEnabled BOOLEAN,

CONSTRAINT fk_mobile_device FOREIGN KEY(deviceID) REFERENCES DEVICE(deviceID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: SERVER
-- =====================================================


CREATE TABLE SERVER(
serverID VARCHAR(10) PRIMARY KEY, serverRoomID VARCHAR(10) NOT NULL,
serverName VARCHAR(100), manufacturer VARCHAR(100), ipAddress VARCHAR(45), operatingSystem VARCHAR(100),

CONSTRAINT fk_server_room FOREIGN KEY(serverRoomID)

REFERENCES SERVER_ROOM(serverRoomID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: PHYSICAL_SERVER
-- =====================================================


CREATE TABLE PHYSICAL_SERVER( serverID VARCHAR(10) PRIMARY KEY,

CONSTRAINT fk_physical_server FOREIGN KEY(serverID) REFERENCES SERVER(serverID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: VIRTUAL_SERVER
-- =====================================================


CREATE TABLE VIRTUAL_SERVER( serverID VARCHAR(10) PRIMARY KEY,
physicalServerID VARCHAR(10) NOT NULL,

CONSTRAINT fk_virtual_server FOREIGN KEY(serverID) REFERENCES SERVER(serverID) ON UPDATE RESTRICT

ON DELETE RESTRICT,


CONSTRAINT fk_virtual_physical FOREIGN KEY(physicalServerID)
REFERENCES PHYSICAL_SERVER(serverID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: SERVICE
-- =====================================================


CREATE TABLE SERVICE(
serviceID VARCHAR(10) PRIMARY KEY, serverID VARCHAR(10) NOT NULL,
serviceName VARCHAR(100), startDate DATE,

CONSTRAINT fk_service_server FOREIGN KEY(serverID) REFERENCES SERVER(serverID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: CREDENTIALS
-- =====================================================


CREATE TABLE CREDENTIALS(

credentialID VARCHAR(10) PRIMARY KEY, userID VARCHAR(10) UNIQUE,
username VARCHAR(50), passwordHash VARCHAR(255), creationDate DATE,

CONSTRAINT fk_credentials_user FOREIGN KEY(userID) REFERENCES `USER`(userID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: SERVICE_PERMISSION
-- =====================================================


CREATE TABLE SERVICE_PERMISSION(
servicePermissionID VARCHAR(10) PRIMARY KEY, userID VARCHAR(10) NOT NULL,
serviceID VARCHAR(10) NOT NULL,
permissionGrantDate DATE,


CONSTRAINT fk_permission_user FOREIGN KEY(userID) REFERENCES `USER`(userID) ON UPDATE RESTRICT
ON DELETE RESTRICT,

CONSTRAINT fk_permission_service FOREIGN KEY(serviceID)

REFERENCES SERVICE(serviceID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);


-- =====================================================
-- TABLE: DEVICE_SERVER_APPROVAL
-- =====================================================


CREATE TABLE DEVICE_SERVER_APPROVAL( approvalID VARCHAR(10) PRIMARY KEY, deviceID VARCHAR(10) NOT NULL,
serverID VARCHAR(10) NOT NULL,
approvalDate DATE, revocationDate DATE,

CONSTRAINT fk_approval_device FOREIGN KEY(deviceID) REFERENCES DEVICE(deviceID) ON UPDATE RESTRICT
ON DELETE RESTRICT,


CONSTRAINT fk_approval_server FOREIGN KEY(serverID) REFERENCES SERVER(serverID) ON UPDATE RESTRICT
ON DELETE RESTRICT
);
SHOW TABLES ;

Phụ lục B. Mã nguồn SQL dữ liệu mẫu (INSERT DATA)
-- =====================================================
-- INSERT DATA
-- =====================================================


-- UNIT
INSERT INTO UNIT VALUES
('U001','IT','Information Technology','PO101','0901234567'), ('U002','HR','Human Resource','PO102','0902345678'),
('U003','FIN','Finance','PO103','0903456789');


-- SERVER ROOM
INSERT INTO SERVER_ROOM VALUES
('SR001','Main Server Room'), ('SR002','Backup Server Room');

-- USER
INSERT INTO `USER` VALUES
('US001','U001','Nguyen','An','Van','Administrator'),
('US002','U001','Tran','Binh','Thi','Lecturer'),
('US003','U002','Le','Cuong','Van','Manager');


-- DEVICE
INSERT INTO DEVICE VALUES ('DV001','US001','Dell','Latitude 5520','2025-01-10'),
('DV002','US002','HP','EliteBook 840','2025-02-01'),
('DV003','US003','Apple','MacBook Air','2025-03-01');


-- FIXED DEVICE
INSERT INTO FIXED_DEVICE VALUES ('DV001','192.168.1.100','AA:BB:CC:11:22:33','Building A','101');

-- MOBILE DEVICE
INSERT INTO MOBILE_DEVICE VALUES ('DV002','SN1001','Windows','11',TRUE,TRUE),
('DV003','SN1002','macOS','15',TRUE,TRUE);


-- SERVER
INSERT INTO SERVER VALUES
('SV001','SR001','Application Server','Dell','192.168.10.1','Windows Server'),
('SV002','SR002','Database Server','HP','192.168.10.2','Ubuntu');


-- PHYSICAL SERVER
INSERT INTO PHYSICAL_SERVER VALUES ('SV001');

-- VIRTUAL SERVER
INSERT INTO VIRTUAL_SERVER VALUES ('SV002','SV001');

-- SERVICE
INSERT INTO SERVICE VALUES ('SE001','SV001','Email Service','2025-01-01'),
('SE002','SV002','Database Service','2025-01-15');


-- CREDENTIALS
INSERT INTO CREDENTIALS VALUES ('CR001','US001','admin','123456789','2025-01-01'),
('CR002','US002','binh','987654321','2025-01-05'),
('CR003','US003','cuong','456789123','2025-01-10');


-- SERVICE PERMISSION

INSERT INTO SERVICE_PERMISSION VALUES ('SP001','US001','SE001','2025-02-01'),
('SP002','US002','SE002','2025-02-10'),
('SP003','US003','SE001','2025-02-20');


-- DEVICE SERVER APPROVAL
INSERT INTO DEVICE_SERVER_APPROVAL VALUES ('AP001','DV001','SV001','2025-03-01',NULL),
('AP002','DV002','SV002','2025-03-02',NULL),
('AP003','DV003','SV002','2025-03-05',NULL);


-- =====================================================
-- CREATE INDEX
-- =====================================================


CREATE INDEX idx_device_user ON DEVICE(userID);

CREATE INDEX idx_server_room ON SERVER(serverRoomID);

CREATE INDEX idx_service_server ON SERVICE(serverID);

CREATE INDEX idx_permission_user ON SERVICE_PERMISSION(userID);

Phụ lục C. Các câu lệnh SQL truy vấn và kiểm thử
-- =====================================================
-- SAMPLE QUERY
-- =====================================================

-- 1. Danh sách đơn vị
SELECT * FROM UNIT;


-- 2. Danh sách người dùng
SELECT * FROM `USER`;


-- 3. Danh sách thiết bị
SELECT * FROM DEVICE;


-- 4. Người dùng và đơn vị
SELECT
u.userID, u.lastName, u.firstName, un.unitName FROM `USER` u JOIN UNIT un
ON u.unitID = un.unitID;


-- 5. Thiết bị của từng người dùng
SELECT
u.firstName, u.lastName, d.deviceID, d.manufacturer, d.model
FROM `USER` u JOIN DEVICE d
ON u.userID = d.userID;

-- 6. Server và phòng máy SELECT
s.serverName, sr.roomName FROM SERVER s
JOIN SERVER_ROOM sr
ON s.serverRoomID = sr.serverRoomID;


-- 7. Dịch vụ chạy trên server nào
SELECT
sv.serviceName, se.serverName FROM SERVICE sv JOIN SERVER se
ON sv.serverID = se.serverID;


-- 8. Danh sách tài khoản
SELECT
u.firstName, u.lastName, c.username FROM `USER` u
JOIN CREDENTIALS c
ON u.userID = c.userID;


-- 9. Đếm số thiết bị
SELECT COUNT(*) AS TotalDevice FROM DEVICE;

-- 10. Đếm số người dùng theo đơn vị
SELECT

unitID,
COUNT(*) AS TotalUsers FROM `USER`
GROUP BY unitID; SHOW TABLES; SELECT * FROM UNIT;
SELECT * FROM `USER`; SELECT * FROM DEVICE; SELECT * FROM SERVER; SELECT * FROM SERVICE;

-- Tạo user ứng dụng
CREATE USER 'app_user'@'localhost' IDENTIFIED BY '123';


-- Chỉ cho phép thao tác dữ liệu (không cho DROP, ALTER)
GRANT SELECT, INSERT, UPDATE
ON unisecure_research_cloud_db.* TO 'app_user'@'localhost';

-- Tạo user chỉ đọc
CREATE USER 'readonly_user'@'localhost' IDENTIFIED BY '123';


GRANT SELECT
ON unisecure_research_cloud_db.*

TO 'readonly_user'@'localhost';


-- Xem quyền
SHOW GRANTS FOR 'app_user'@'localhost'; SHOW GRANTS FOR 'readonly_user'@'localhost';

FLUSH PRIVILEGES;


-- Xem danh sách bảng
SHOW TABLES;


-- Xem cấu trúc bảng quan trọng DESCRIBE DEVICE; DESCRIBE `USER`; DESCRIBE SERVICE; DESCRIBE SERVER;

-- Xem câu lệnh tạo bảng
SHOW CREATE TABLE DEVICE; SHOW CREATE TABLE SERVICE;

-- Kiểm tra khóa ngoại
SELECT TABLE_NAME, COLUMN_NAME,
CONSTRAINT_NAME, REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'unisecure_research_cloud_db' AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Kiểm tra index
SHOW INDEX FROM DEVICE; SHOW INDEX FROM SERVER; SHOW INDEX FROM SERVICE;