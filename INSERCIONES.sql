-- Primero desactivar la verificación de claves foráneas para insertar los datos
SET FOREIGN_KEY_CHECKS = 0;

-- SE LIMPIAN TODAS LAS TABLAS PARA PODER EJECUTAR LAS INSERCIONES UNA Y OTRA VEZ
TRUNCATE TABLE transactions;
TRUNCATE TABLE payment_notifications;
TRUNCATE TABLE schedule_details;
TRUNCATE TABLE payments;
TRUNCATE TABLE schedule;
TRUNCATE TABLE pay_event_type;
TRUNCATE TABLE plan_per_user;
TRUNCATE TABLE plan_prices;
TRUNCATE TABLE pay_available_method;
TRUNCATE TABLE pay_user_roles;
TRUNCATE TABLE pay_user_permissions;
TRUNCATE TABLE pay_rolespermissions;
TRUNCATE TABLE pay_user;
TRUNCATE TABLE pay_roles;
TRUNCATE TABLE pay_permissions;
TRUNCATE TABLE pay_modules;
TRUNCATE TABLE pay_plan_type;
TRUNCATE TABLE subscriptions;
TRUNCATE TABLE features_per_plan;
TRUNCATE TABLE features_plan;
TRUNCATE TABLE currency_conversion;
TRUNCATE TABLE pay_currency;
TRUNCATE TABLE user_addresses;
TRUNCATE TABLE user_mediafiles;
TRUNCATE TABLE user_phone;
TRUNCATE TABLE pay_contact_info_type;
TRUNCATE TABLE pay_contact;
TRUNCATE TABLE pay_address;
TRUNCATE TABLE user_cities;
TRUNCATE TABLE pay_state;
TRUNCATE TABLE pay_country;
TRUNCATE TABLE pay_method;

SET FOREIGN_KEY_CHECKS = 1;



-- ==========================ENUNCIADO 4.1 (INSERCIONES)==========================



USE `paymentassistant`;

-- Ubicación: País, Estado, Ciudad y Dirección
INSERT INTO `pay_country` (`country_id`, `name`, `currency`, `currencysymbol`, `language`)
VALUES (1, 'Costa Rica', 'CRC', '₡', 'es');

INSERT INTO `pay_state` (`state_id`, `name`, `country_id`)
VALUES (1, 'San José', 1);

INSERT INTO `user_cities` (`city_id`, `name`, `state_id`)
VALUES (1, 'San José', 1);

INSERT INTO `pay_address` (`addressid`, `line1`, `line2`, `zipcode`, `geoposition`, `city_id`)
VALUES (1, 'Avenida Central 123', NULL, '10101', ST_GeomFromText('POINT(0 0)'), 1);

-- Método de pago (estático)
INSERT INTO `pay_method` (`method_id`, `name`, `apiURL`, `secret_key`, `key`, `logoIconURL`, `enabled`, `config`)
VALUES (1, 'Tarjeta de Crédito', 'https://api.tdc.example.com',
        'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
        '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        'https://img.tdc.example.com/logo.png', b'1', '{"param": "valor"}');


-- INSERCIÓN DE DATOS

-- FUNCIÓN PARA LLENAR USUARIOS
DROP PROCEDURE IF EXISTS sp_fill_pay_user;
DELIMITER //
CREATE PROCEDURE sp_fill_pay_user()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 20 DO
    INSERT INTO `pay_user` 
      (`name`, `last_name`, `phone`, `birth`, `password`, `delete`, `last_update`, `active`, `role`, `email`)
    VALUES (
      CONCAT('Nombre', i),
      CONCAT('Apellido', i),
      LPAD(i, 8, '0'),
      DATE_SUB('1990-01-01', INTERVAL i YEAR),
      UNHEX(SHA2(CONCAT('pass', i), 256)),
      b'0',
      NOW(),
      b'1',  -- Solo usuarios activos
      1,
      CONCAT('user', i, '@example.com')
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

-- LLAMADA A LA FUNCIÓN 
CALL sp_fill_pay_user();

-- ELIMINAR FUNCIÓN PARA PERMITIR QUE SE REPITA LAS INSERCIONES
DROP PROCEDURE IF EXISTS sp_fill_pay_available_method;
DELIMITER //
CREATE PROCEDURE sp_fill_pay_available_method()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 20 DO
    INSERT INTO `pay_available_method`
      (`available_method`, `mask_account`, `token`, `exptokendate`, `name`, `user_id`, `method_id`)
    VALUES (
      i, 
      CONCAT('****', LPAD(1000 + i, 4, '0')),
      UNHEX(SHA2(CONCAT('token', i), 256)),
      '2025-12-31',
      CONCAT('Cuenta Usuario ', i),
      i,  
      1
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

-- LLAMADA A LA FUNCIÓN
CALL sp_fill_pay_available_method();

-- FUNCIÓN PARA LLENAR LOS PAGOS
DROP PROCEDURE IF EXISTS sp_fill_payments;
DELIMITER //
CREATE PROCEDURE sp_fill_payments()
BEGIN
  DECLARE uid INT DEFAULT 1;
  DECLARE random_price DECIMAL(10,2);
  DECLARE random_date DATE;
  WHILE uid <= 20 DO
    SET random_price = FLOOR(18000 + (RAND() * (33000 - 18000)));
    SET random_date = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * DATEDIFF(CURDATE(), '2024-01-01')) DAY);
    INSERT INTO `payments`
      (`payments_id`, `user_id`, `available_method`, `price`, `current_price`, `currency`, `auth`, `changeToken`, `description`, `error`, `date`, `result`, `checksum`, `schedule_id`)
    VALUES (
      uid,         
      uid,
      uid,         
      random_price,
      random_price,
      'CRC',
      CONCAT('auth', uid),
      UNHEX(SHA2(CONCAT('chg', uid), 256)),
      'Suscripción 2024',
      b'0',
      random_date,
      'SUCCESS',
      UNHEX(SHA2(CONCAT('chk', uid), 256)),
      NULL
    );
    SET uid = uid + 1;
  END WHILE;
END //
DELIMITER ;

-- LLAMADA A LA FUNCIÓN
CALL sp_fill_payments();



-- ==========================ENUNCIADO 4.2 (INSERCIONES)==========================



INSERT INTO `subscriptions` (`subscriptions_id`, `description`, `logourl`)
VALUES (1, 'Plan Básico', 'https://example.com/logo.png');

INSERT INTO `features_plan` (`features_id`, `description`, `enabled`, `datatype`)
VALUES (1, 'Acceso Básico', b'1', 'boolean');

INSERT INTO `pay_plan_type` (`plan_type_id`, `name`, `enable`, `acquisition`, `user_id`)
VALUES (1, 'Plan Mensual', b'1', '2024-01-01', 1);

INSERT INTO `plan_prices` (`prices_id`, `amount`, `recurrencytype`, `post_time`, `endDate`, `current`, `plan_type_id`, `subscriptions_id`)
VALUES (1, 100.00, 'MONTHLY', NOW(), '2024-12-31', b'1', 1, 1);

INSERT INTO `schedule` (`schedule_id`, `name`, `recurrencytype`, `repit`, `endType`, `repetitions`, `end_date`)
VALUES (1, 'Plan Mensual', 'MONTHLY', 1, 'DATE', 12, '2024-12-31');

-- FUNCIÓN PARA LLENAR PLANES POR USUARIO
DROP PROCEDURE IF EXISTS sp_fill_plan_per_user;
DELIMITER //
CREATE PROCEDURE sp_fill_plan_per_user()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 20 DO
    INSERT INTO `plan_per_user` (`planuser_id`, `user_id`, `prices_id`, `acquisition`, `enable`)
    VALUES (i, i, 1, NOW(), b'1');
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL sp_fill_plan_per_user();

-- FUNCIÓN PARA DENTRO DE 13 DÍAS
DROP PROCEDURE IF EXISTS sp_fill_schedule_details;
DELIMITER //
CREATE PROCEDURE sp_fill_schedule_details()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 13 DO
    INSERT INTO `schedule_details` 
      (`details_id`, `deleted`, `basedate`, `datepart`, `LastExecute`, `NextExecute`, `plan_id`, `schedule_id`, `planuser_id`)
    VALUES (
      i,
      b'0',
      '2024-01-01',
      '2024-02-01',
      NOW(),
      DATE_ADD(NOW(), INTERVAL FLOOR(RAND() * 15) DAY),  -- FECHA 5 DÍAS
      1,         
      1,         
      i           
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL sp_fill_schedule_details();



-- ==========================ENUNCIADO 4.3 (INSERCIONES)==========================



DROP PROCEDURE IF EXISTS sp_fill_ai_voice_session;
DELIMITER //
CREATE PROCEDURE sp_fill_ai_voice_session()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE user INT;
  DECLARE start_time DATETIME;
  DECLARE end_time DATETIME;
  
  WHILE i <= 100 DO
    SET user = FLOOR(1 + (RAND() * 20));  -- Usuarios del 1 al 20
    SET start_time = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY);
    SET end_time = DATE_ADD(start_time, INTERVAL FLOOR(10 + (RAND() * 120)) MINUTE);
    
    INSERT INTO ai_voice_session 
      (`user_id`, `start_time`, `end_time`, `status`, `audio_s3_uri`, `create_at`)
    VALUES (
      user,
      start_time,
      end_time,
      'completed',
      CONCAT('https://s3.example.com/session_', i),
      start_time
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;



-- ==========================ENUNCIADO 4.4 (INSERCIONES)==========================


-- INSERCIÓN DE TIPOS DE SESIONES
INSERT INTO pay_event_type (`eventtype_id`, `event_type`)
VALUES 
  (1, 'USER_CONFIRMATION'),
  (2, 'USER_CORRECTION'),
  (3, 'SYSTEM_ERROR'),
  (4, 'HALLUCINATION'),
  (5, 'INTENT_MISMATCH');

-- FUNCIÓN PARA LLENAR LOGS DE ERRORES
DROP PROCEDURE IF EXISTS sp_fill_error_logs;
DELIMITER //
CREATE PROCEDURE sp_fill_error_logs()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE session_id INT;
  DECLARE error_type INT;
  
  WHILE i <= 100 DO
    SET session_id = FLOOR(1 + (RAND() * 100));  
    SET error_type = FLOOR(2 + (RAND() * 3));    
    
    INSERT INTO ai_interaction_logs 
      (`session_id`, `description`, `additional_info_json`, `eventtype_id`)
    VALUES (
      session_id,
      CONCAT('Error en sesión ', session_id),
      CONCAT(
        '{"error_type": "', 
        CASE error_type
          WHEN 2 THEN 'user_correction'
          WHEN 3 THEN 'system_error'
          WHEN 4 THEN 'hallucination'
        END, 
        '", "details": "El usuario corrigió la interpretación 3 veces."}'
      ),
      error_type
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

CALL sp_fill_error_logs();