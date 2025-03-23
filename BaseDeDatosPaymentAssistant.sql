-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema paymentassistant
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema paymentassistant
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `paymentassistant` ;
USE `paymentassistant` ;

-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_name` VARCHAR(50) COLLATE 'utf8mb3_bin' NOT NULL,
  `phone` VARCHAR(20) COLLATE 'utf8mb3_bin' NOT NULL,
  `birth` DATE NOT NULL,
  `password` VARBINARY(255) NOT NULL,
  `delete` BIT(1) NOT NULL,
  `last_update` DATETIME NOT NULL,
  `active` BIT(1) NOT NULL,
  `role` TINYINT NOT NULL,
  `email` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_voice_session`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_voice_session` (
  `session_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `status` ENUM('active', 'completed', 'failed') COLLATE 'utf8mb3_bin' NOT NULL,
  `audio_s3_uri` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  `create_at` DATETIME NOT NULL,
  PRIMARY KEY (`session_id`),
  INDEX `ai_voice_session_user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_voice_session_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_event_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_event_type` (
  `eventtype_id` INT NOT NULL AUTO_INCREMENT,
  `event_type` VARCHAR(50) COLLATE 'utf8mb3_bin' NOT NULL DEFAULT 'USER_CONFIRMATION, USER_CORRECTION, SYSTEM_ERROR',
  PRIMARY KEY (`eventtype_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_interaction_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_interaction_logs` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT,
  `session_id` INT NOT NULL,
  `description` VARCHAR(500) COLLATE 'utf8mb3_bin' NULL DEFAULT NULL,
  `additional_info_json` JSON NULL DEFAULT NULL,
  `eventtype_id` INT NOT NULL,
  PRIMARY KEY (`log_id`),
  INDEX `ai_interaction_logs_session_id_idx` (`session_id` ASC) VISIBLE,
  INDEX `ai_interaction_logs_eventtype_id_idx` (`eventtype_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_interaction_logs_ai_voice_session`
    FOREIGN KEY (`session_id`)
    REFERENCES `paymentassistant`.`ai_voice_session` (`session_id`),
  CONSTRAINT `fk_ai_interaction_logs_pay_event_type`
    FOREIGN KEY (`eventtype_id`)
    REFERENCES `paymentassistant`.`pay_event_type` (`eventtype_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_transcription`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_transcription` (
  `transcription_id` BIGINT NOT NULL,
  `session_id` INT NOT NULL,
  `transcript_text` VARCHAR(2000) COLLATE 'utf8mb3_bin' NOT NULL,
  `is_partial` BIT(1) NOT NULL,
  `confidence_avg` DECIMAL(5,2) NOT NULL,
  `start_time_sec` DECIMAL(6,2) NOT NULL,
  `end_time_sec` DECIMAL(6,2) NOT NULL,
  `stable` BIT(1) NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`transcription_id`),
  INDEX `ai_transcription_session_id_idx` (`session_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_transcription_ai_voice_session`
    FOREIGN KEY (`session_id`)
    REFERENCES `paymentassistant`.`ai_voice_session` (`session_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_lex_interpretation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_lex_interpretation` (
  `interpretation_id` BIGINT NOT NULL AUTO_INCREMENT,
  `session_id` INT NOT NULL,
  `transcription_id` BIGINT NOT NULL,
  `intent_name` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `confidence` DECIMAL(5,2) NOT NULL,
  `slots_json` JSON NOT NULL,
  `fulfillment_state` VARCHAR(50) COLLATE 'utf8mb3_bin' NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `definite` BIT(1) NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `financial_identity` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `method` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `iban` CHAR(34) COLLATE 'utf8mb3_bin' NULL DEFAULT NULL,
  `startdate` DATETIME NOT NULL,
  `enddate` DATETIME NOT NULL,
  `recurrencytype` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `endtype` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` CHAR(3) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`interpretation_id`),
  INDEX `ai_lex_interpretation_session_id_idx` (`session_id` ASC) VISIBLE,
  INDEX `ai_lex_interpretation_transcription_id_idx` (`transcription_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_lex_interpretation_ai_transcription`
    FOREIGN KEY (`transcription_id`)
    REFERENCES `paymentassistant`.`ai_transcription` (`transcription_id`),
  CONSTRAINT `fk_ai_lex_interpretation_ai_voice_session`
    FOREIGN KEY (`session_id`)
    REFERENCES `paymentassistant`.`ai_voice_session` (`session_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_payment_config`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_payment_config` (
  `config_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `session_id` INT NOT NULL,
  `payment_config_json` JSON NOT NULL,
  `status` ENUM('active', 'pending', 'cancelled') COLLATE 'utf8mb3_bin' NOT NULL,
  `created_at` DATETIME NOT NULL,
  `interpretation_id` BIGINT NOT NULL,
  PRIMARY KEY (`config_id`),
  INDEX `ai_payment_config_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `ai_payment_config_session_id_idx` (`session_id` ASC) VISIBLE,
  INDEX `ai_payment_config_interpretation_id_idx` (`interpretation_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_payment_config_ai_lex_interpretation`
    FOREIGN KEY (`interpretation_id`)
    REFERENCES `paymentassistant`.`ai_lex_interpretation` (`interpretation_id`),
  CONSTRAINT `fk_ai_payment_config_ai_voice_session`
    FOREIGN KEY (`session_id`)
    REFERENCES `paymentassistant`.`ai_voice_session` (`session_id`),
  CONSTRAINT `fk_ai_payment_config_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`ai_screec_record`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`ai_screec_record` (
  `screen_record_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `session_id` INT NOT NULL,
  `config_id` INT NOT NULL,
  `event_description` VARCHAR(500) COLLATE 'utf8mb3_bin' NOT NULL,
  `metadata_json` JSON NULL DEFAULT NULL,
  PRIMARY KEY (`screen_record_id`),
  INDEX `ai_screec_record_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `ai_screec_record_session_id_idx` (`session_id` ASC) VISIBLE,
  INDEX `ai_screec_record_config_id_idx` (`config_id` ASC) VISIBLE,
  CONSTRAINT `fk_ai_screec_record_ai_payment_config`
    FOREIGN KEY (`config_id`)
    REFERENCES `paymentassistant`.`ai_payment_config` (`config_id`),
  CONSTRAINT `fk_ai_screec_record_ai_voice_session`
    FOREIGN KEY (`session_id`)
    REFERENCES `paymentassistant`.`ai_voice_session` (`session_id`),
  CONSTRAINT `fk_ai_screec_record_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_currency`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_currency` (
  `currency_id` INT NOT NULL AUTO_INCREMENT,
  `code` CHAR(3) COLLATE 'utf8mb3_bin' NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `symbol` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`currency_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`currency_conversion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`currency_conversion` (
  `conversion_id` INT NOT NULL AUTO_INCREMENT,
  `from_currency` INT NOT NULL,
  `to_currency` INT NOT NULL,
  `rate` DECIMAL(10,6) NOT NULL,
  `last_update` DATETIME NOT NULL,
  `currency_id` INT NOT NULL,
  PRIMARY KEY (`conversion_id`),
  INDEX `currency_conversion_currency_id_idx` (`currency_id` ASC) VISIBLE,
  CONSTRAINT `fk_currency_conversion_pay_currency`
    FOREIGN KEY (`currency_id`)
    REFERENCES `paymentassistant`.`pay_currency` (`currency_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`features_plan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`features_plan` (
  `features_id` INT NOT NULL,
  `description` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `datatype` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`features_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`subscriptions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`subscriptions` (
  `subscriptions_id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `logourl` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`subscriptions_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`features_per_plan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`features_per_plan` (
  `featuresPerPlan_id` INT NOT NULL,
  `value` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `enable` BIT(1) NOT NULL,
  `subscriptions_id` INT NOT NULL,
  `features_id` INT NOT NULL,
  PRIMARY KEY (`featuresPerPlan_id`),
  INDEX `features_per_plan_subscriptions_id_idx` (`subscriptions_id` ASC) VISIBLE,
  INDEX `features_per_plan_features_id_idx` (`features_id` ASC) VISIBLE,
  CONSTRAINT `fk_features_per_plan_features_plan`
    FOREIGN KEY (`features_id`)
    REFERENCES `paymentassistant`.`features_plan` (`features_id`),
  CONSTRAINT `fk_features_per_plan_subscriptions`
    FOREIGN KEY (`subscriptions_id`)
    REFERENCES `paymentassistant`.`subscriptions` (`subscriptions_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`languages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`languages` (
  `languages_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `culture` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`languages_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`logserenty`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`logserenty` (
  `logserentyid` INT NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`logserentyid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`logsources`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`logsources` (
  `logsourcesid` INT NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`logsourcesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`logtypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`logtypes` (
  `logtypeid` INT NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `ref1Desc` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `ref2Desc` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `value1Desc` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `value2Desc` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`logtypeid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`logs` (
  `logsid` INT NOT NULL,
  `description` VARCHAR(80) COLLATE 'utf8mb3_bin' NOT NULL,
  `posttime` DATETIME NOT NULL,
  `computer` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `username` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `trace` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `referenceid1` BIGINT NOT NULL,
  `referenceid2` BIGINT NOT NULL,
  `value1` VARCHAR(180) COLLATE 'utf8mb3_bin' NOT NULL,
  `value2` VARCHAR(180) COLLATE 'utf8mb3_bin' NOT NULL,
  `checksum` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  `logtypeid` INT NOT NULL,
  `logsourcesid` INT NOT NULL,
  `logserentyid` INT NOT NULL,
  PRIMARY KEY (`logsid`),
  INDEX `logs_logtypeid_idx` (`logtypeid` ASC) VISIBLE,
  INDEX `logs_logsourcesid_idx` (`logsourcesid` ASC) VISIBLE,
  INDEX `logs_logserentyid_idx` (`logserentyid` ASC) VISIBLE,
  CONSTRAINT `fk_logs_logserenty`
    FOREIGN KEY (`logserentyid`)
    REFERENCES `paymentassistant`.`logserenty` (`logserentyid`),
  CONSTRAINT `fk_logs_logsources`
    FOREIGN KEY (`logsourcesid`)
    REFERENCES `paymentassistant`.`logsources` (`logsourcesid`),
  CONSTRAINT `fk_logs_logtypes`
    FOREIGN KEY (`logtypeid`)
    REFERENCES `paymentassistant`.`logtypes` (`logtypeid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`mediatype`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`mediatype` (
  `mediatype_id` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) COLLATE 'utf8mb3_bin' NOT NULL,
  `description` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`mediatype_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_country`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_country` (
  `country_id` INT NOT NULL,
  `name` VARCHAR(50) COLLATE 'utf8mb3_bin' NOT NULL,
  `currency` VARCHAR(30) COLLATE 'utf8mb3_bin' NOT NULL,
  `currencysymbol` CHAR(3) COLLATE 'utf8mb3_bin' NOT NULL,
  `language` VARCHAR(7) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`country_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_state`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_state` (
  `state_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(40) COLLATE 'utf8mb3_bin' NOT NULL,
  `country_id` INT NOT NULL,
  PRIMARY KEY (`state_id`),
  INDEX `pay_state_country_id_idx` (`country_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_state_pay_country`
    FOREIGN KEY (`country_id`)
    REFERENCES `paymentassistant`.`pay_country` (`country_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`user_cities`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`user_cities` (
  `city_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) COLLATE 'utf8mb3_bin' NOT NULL,
  `state_id` INT NOT NULL,
  PRIMARY KEY (`city_id`),
  INDEX `user_cities_state_id_idx` (`state_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_cities_pay_state`
    FOREIGN KEY (`state_id`)
    REFERENCES `paymentassistant`.`pay_state` (`state_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_address` (
  `addressid` INT NOT NULL AUTO_INCREMENT,
  `line1` VARCHAR(200) COLLATE 'utf8mb3_bin' NOT NULL,
  `line2` VARCHAR(100) COLLATE 'utf8mb3_bin' NULL DEFAULT NULL,
  `zipcode` VARCHAR(9) COLLATE 'utf8mb3_bin' NOT NULL,
  `geoposition` POINT NOT NULL,
  `city_id` INT NOT NULL,
  PRIMARY KEY (`addressid`),
  INDEX `pay_address_city_id_idx` (`city_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_address_user_cities`
    FOREIGN KEY (`city_id`)
    REFERENCES `paymentassistant`.`user_cities` (`city_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_method`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_method` (
  `method_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `apiURL` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  `secret_key` CHAR(64) COLLATE 'utf8mb3_bin' NOT NULL,
  `key` CHAR(64) COLLATE 'utf8mb3_bin' NOT NULL,
  `logoIconURL` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `config` JSON NOT NULL,
  PRIMARY KEY (`method_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_available_method`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_available_method` (
  `available_method` INT NOT NULL,
  `mask_account` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `token` VARBINARY(128) NOT NULL,
  `exptokendate` DATE NOT NULL,
  `name` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `user_id` INT NOT NULL,
  `method_id` INT NOT NULL,
  PRIMARY KEY (`available_method`),
  UNIQUE INDEX `method_id_UNIQUE` (`available_method` ASC) VISIBLE,
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_pay_available_method_pay_method_type1_idx` (`method_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_available_method_pay_method_type1`
    FOREIGN KEY (`method_id`)
    REFERENCES `paymentassistant`.`pay_method` (`method_id`),
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_contact`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_contact` (
  `contact_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `value` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`contact_id`),
  UNIQUE INDEX `pay_contact_contact_id_UNIQUE` (`contact_id` ASC) VISIBLE,
  INDEX `pay_contact_user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_contact_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_contact_info_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_contact_info_type` (
  `infotype_id` INT NOT NULL,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `contact_id` INT NOT NULL,
  PRIMARY KEY (`infotype_id`),
  INDEX `contact_info_type_contact_id_idx` (`contact_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_contact_info_type_pay_contact`
    FOREIGN KEY (`contact_id`)
    REFERENCES `paymentassistant`.`pay_contact` (`contact_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_modules`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_modules` (
  `moduleid` TINYINT NOT NULL,
  `name` VARCHAR(40) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`moduleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_permissions` (
  `permissions_id` INT NOT NULL,
  `moduleid` TINYINT NOT NULL,
  `description` VARCHAR(70) COLLATE 'utf8mb3_bin' NOT NULL,
  `code` VARCHAR(10) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`permissions_id`),
  INDEX `pay_permissions_moduleid_idx` (`moduleid` ASC) VISIBLE,
  CONSTRAINT `fk_pay_permissions_pay_modules`
    FOREIGN KEY (`moduleid`)
    REFERENCES `paymentassistant`.`pay_modules` (`moduleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_plan_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_plan_type` (
  `plan_type_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `enable` BIT(1) NOT NULL,
  `acquisition` DATE NOT NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`plan_type_id`),
  INDEX `pay_plan_type_user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_plan_type_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_roles` (
  `roleid` INT NOT NULL AUTO_INCREMENT,
  `name_role` VARCHAR(30) COLLATE 'utf8mb3_bin' NOT NULL,
  `last_update` DATETIME NOT NULL,
  `description` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`roleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_rolespermissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_rolespermissions` (
  `rolespermissions_id` INT NOT NULL,
  `permissions_id` INT NOT NULL,
  `roleid` INT NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `deleted` BIT(1) NOT NULL,
  `last_update` DATETIME NOT NULL,
  PRIMARY KEY (`rolespermissions_id`),
  INDEX `pay_rolespermissions_roleid_idx` (`roleid` ASC) VISIBLE,
  INDEX `pay_rolespermissions_permissions_id_idx` (`permissions_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_rolespermissions_pay_permissions`
    FOREIGN KEY (`permissions_id`)
    REFERENCES `paymentassistant`.`pay_permissions` (`permissions_id`),
  CONSTRAINT `fk_pay_rolespermissions_pay_roles`
    FOREIGN KEY (`roleid`)
    REFERENCES `paymentassistant`.`pay_roles` (`roleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_user_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_user_permissions` (
  `rolepermissionsid` INT NOT NULL,
  `user_id` INT NOT NULL,
  `permissions_id` INT NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `last_update` DATETIME NOT NULL,
  `checksum` VARBINARY(255) NOT NULL,
  PRIMARY KEY (`rolepermissionsid`),
  INDEX `pay_user_permissions_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `pay_user_permissions_permissions_id_idx` (`permissions_id` ASC) VISIBLE,
  CONSTRAINT `fk_pay_user_permissions_pay_permissions`
    FOREIGN KEY (`permissions_id`)
    REFERENCES `paymentassistant`.`pay_permissions` (`permissions_id`),
  CONSTRAINT `fk_pay_user_permissions_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`pay_user_roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`pay_user_roles` (
  `userrolesid` INT NOT NULL AUTO_INCREMENT,
  `roleid` INT NOT NULL,
  `user_id` INT NOT NULL,
  `last_update` DATETIME NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `enabled` BIT(1) NOT NULL,
  PRIMARY KEY (`userrolesid`),
  INDEX `pay_user_roles_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `pay_user_roles_roleid_idx` (`roleid` ASC) VISIBLE,
  CONSTRAINT `fk_pay_user_roles_pay_roles`
    FOREIGN KEY (`roleid`)
    REFERENCES `paymentassistant`.`pay_roles` (`roleid`),
  CONSTRAINT `fk_pay_user_roles_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`schedule`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`schedule` (
  `schedule_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `recurrencytype` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `repit` TINYINT NOT NULL,
  `endType` VARCHAR(45) COLLATE 'utf8mb3_bin' NOT NULL,
  `repetitions` TINYINT NOT NULL,
  `end_date` DATE NOT NULL,
  PRIMARY KEY (`schedule_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`payments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`payments` (
  `payments_id` BIGINT UNSIGNED NOT NULL,
  `user_id` INT NOT NULL,
  `available_method` INT NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `current_price` DECIMAL(10,2) NOT NULL,
  `currency` CHAR(3) COLLATE 'utf8mb3_bin' NOT NULL,
  `auth` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  `changeToken` VARBINARY(128) NOT NULL,
  `description` VARCHAR(200) COLLATE 'utf8mb3_bin' NOT NULL,
  `error` BIT(1) NOT NULL,
  `date` DATETIME NOT NULL,
  `result` ENUM('SUCCESS', 'FAILED', 'PENDING') COLLATE 'utf8mb3_bin' NOT NULL,
  `checksum` BINARY(32) NOT NULL,
  `schedule_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`payments_id`),
  INDEX `payments_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `payments_available_method_idx` (`available_method` ASC) VISIBLE,
  INDEX `payments_schedule_id_idx` (`schedule_id` ASC) VISIBLE,
  CONSTRAINT `fk_payments_pay_available_method`
    FOREIGN KEY (`available_method`)
    REFERENCES `paymentassistant`.`pay_available_method` (`available_method`),
  CONSTRAINT `fk_payments_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`),
  CONSTRAINT `fk_payments_schedule`
    FOREIGN KEY (`schedule_id`)
    REFERENCES `paymentassistant`.`schedule` (`schedule_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`plan_prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`plan_prices` (
  `prices_id` INT NOT NULL AUTO_INCREMENT,
  `amount` DECIMAL(6,2) NOT NULL,
  `recurrencytype` ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY') COLLATE 'utf8mb3_bin' NOT NULL,
  `post_time` DATETIME NOT NULL,
  `endDate` DATETIME NOT NULL,
  `current` BIT(1) NOT NULL,
  `plan_type_id` INT NOT NULL,
  `subscriptions_id` INT NOT NULL,
  PRIMARY KEY (`prices_id`),
  INDEX `plan_prices_plan_type_id_idx` (`plan_type_id` ASC) VISIBLE,
  INDEX `plan_prices_subscriptions_id_idx` (`subscriptions_id` ASC) VISIBLE,
  CONSTRAINT `fk_plan_prices_pay_plan_type`
    FOREIGN KEY (`plan_type_id`)
    REFERENCES `paymentassistant`.`pay_plan_type` (`plan_type_id`),
  CONSTRAINT `fk_plan_prices_subscriptions`
    FOREIGN KEY (`subscriptions_id`)
    REFERENCES `paymentassistant`.`subscriptions` (`subscriptions_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`plan_per_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`plan_per_user` (
  `planuser_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `prices_id` INT NOT NULL,
  `acquisition` DATETIME NOT NULL,
  `enable` BIT(1) NOT NULL,
  PRIMARY KEY (`planuser_id`),
  INDEX `plan_per_user_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `plan_per_user_prices_id_idx` (`prices_id` ASC) VISIBLE,
  CONSTRAINT `fk_plan_per_user_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`),
  CONSTRAINT `fk_plan_per_user_plan_prices`
    FOREIGN KEY (`prices_id`)
    REFERENCES `paymentassistant`.`plan_prices` (`prices_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`schedule_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`schedule_details` (
  `details_id` INT NOT NULL,
  `deleted` BIT(1) NOT NULL,
  `basedate` DATE NOT NULL,
  `datepart` DATE NOT NULL,
  `LastExecute` DATETIME NOT NULL,
  `NextExecute` DATETIME NOT NULL,
  `plan_id` INT NOT NULL,
  `schedule_id` INT NOT NULL,
  `planuser_id` INT NOT NULL,
  PRIMARY KEY (`details_id`),
  INDEX `schedule_details_plan_id_idx` (`plan_id` ASC) VISIBLE,
  INDEX `schedule_details_schedule_id_idx` (`schedule_id` ASC) VISIBLE,
  INDEX `schedule_details_planuser_id_idx` (`planuser_id` ASC) VISIBLE,
  CONSTRAINT `fk_schedule_details_pay_plan_type`
    FOREIGN KEY (`plan_id`)
    REFERENCES `paymentassistant`.`pay_plan_type` (`plan_type_id`),
  CONSTRAINT `fk_schedule_details_plan_per_user`
    FOREIGN KEY (`planuser_id`)
    REFERENCES `paymentassistant`.`plan_per_user` (`planuser_id`),
  CONSTRAINT `fk_schedule_details_schedule`
    FOREIGN KEY (`schedule_id`)
    REFERENCES `paymentassistant`.`schedule` (`schedule_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`payment_notifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`payment_notifications` (
  `notificationid` INT NOT NULL,
  `payments_id` BIGINT UNSIGNED NOT NULL,
  `description` VARCHAR(100) COLLATE 'utf8mb3_bin' NULL DEFAULT NULL,
  `enable` BIT(1) NOT NULL,
  `message` VARCHAR(70) COLLATE 'utf8mb3_bin' NOT NULL,
  `details_id` INT NOT NULL,
  PRIMARY KEY (`notificationid`),
  INDEX `payment_notifications_payments_id_idx` (`payments_id` ASC) VISIBLE,
  INDEX `payment_notifications_details_id_idx` (`details_id` ASC) VISIBLE,
  CONSTRAINT `fk_payment_notifications_payments`
    FOREIGN KEY (`payments_id`)
    REFERENCES `paymentassistant`.`payments` (`payments_id`),
  CONSTRAINT `fk_payment_notifications_schedule_details`
    FOREIGN KEY (`details_id`)
    REFERENCES `paymentassistant`.`schedule_details` (`details_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`transactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`transactions` (
  `transaction_id` INT NOT NULL AUTO_INCREMENT,
  `balanceid` INT NOT NULL,
  `payments_id` BIGINT UNSIGNED NOT NULL,
  `user_id` INT NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `description` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `transaction_date` DATETIME NOT NULL,
  `post_time` DATETIME NOT NULL,
  `checksum` VARBINARY(32) NOT NULL,
  `ref_number` VARCHAR(255) COLLATE 'utf8mb3_bin' NOT NULL,
  PRIMARY KEY (`transaction_id`),
  INDEX `transactions_payments_id_idx` (`payments_id` ASC) VISIBLE,
  INDEX `transactions_user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_transactions_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`),
  CONSTRAINT `fk_transactions_payments`
    FOREIGN KEY (`payments_id`)
    REFERENCES `paymentassistant`.`payments` (`payments_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`translation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`translation` (
  `translation_id` INT NOT NULL AUTO_INCREMENT,
  `code` CHAR(6) COLLATE 'utf8mb3_bin' NOT NULL,
  `caption` VARCHAR(100) COLLATE 'utf8mb3_bin' NOT NULL,
  `enabled` BIT(1) NOT NULL,
  `languages_id` INT NOT NULL,
  PRIMARY KEY (`translation_id`),
  INDEX `translation_languages_id_idx` (`languages_id` ASC) VISIBLE,
  CONSTRAINT `fk_translation_languages`
    FOREIGN KEY (`languages_id`)
    REFERENCES `paymentassistant`.`languages` (`languages_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`user_addresses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`user_addresses` (
  `useraddresses_id` INT NOT NULL AUTO_INCREMENT,
  `enable` BIT(1) NOT NULL,
  `addressid` INT NOT NULL,
  `contact_id` INT NOT NULL,
  PRIMARY KEY (`useraddresses_id`),
  INDEX `user_addresses_addressid_idx` (`addressid` ASC) VISIBLE,
  INDEX `user_addresses_contact_id_idx` (`contact_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_addresses_pay_address`
    FOREIGN KEY (`addressid`)
    REFERENCES `paymentassistant`.`pay_address` (`addressid`),
  CONSTRAINT `fk_user_addresses_pay_contact`
    FOREIGN KEY (`contact_id`)
    REFERENCES `paymentassistant`.`pay_contact` (`contact_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`user_mediafiles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`user_mediafiles` (
  `mediafile_id` INT NOT NULL AUTO_INCREMENT,
  `photourl` VARCHAR(200) COLLATE 'utf8mb3_bin' NOT NULL,
  `deleted` BIT(1) NOT NULL,
  `lastupdate` DATETIME NOT NULL,
  `user_id` INT NOT NULL,
  `mediatype_id` TINYINT NOT NULL,
  PRIMARY KEY (`mediafile_id`),
  INDEX `user_mediafiles_user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `user_mediafiles_mediatype_id_idx` (`mediatype_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_mediafiles_mediatype`
    FOREIGN KEY (`mediatype_id`)
    REFERENCES `paymentassistant`.`mediatype` (`mediatype_id`),
  CONSTRAINT `fk_user_mediafiles_pay_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `paymentassistant`.`pay_user` (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`user_phone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`user_phone` (
  `phone_id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(6) COLLATE 'utf8mb3_bin' NOT NULL,
  `type` ENUM('personal', 'trabajo', 'otro') COLLATE 'utf8mb3_bin' NOT NULL,
  `number` VARCHAR(20) COLLATE 'utf8mb3_bin' NOT NULL,
  `contact_id` INT NOT NULL,
  PRIMARY KEY (`phone_id`),
  INDEX `user_phone_contact_id_idx` (`contact_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_phone_pay_contact`
    FOREIGN KEY (`contact_id`)
    REFERENCES `paymentassistant`.`pay_contact` (`contact_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentassistant`.`user_plan_limit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentassistant`.`user_plan_limit` (
  `limitid` INT NOT NULL,
  `limit` INT NOT NULL,
  `planuser_id` INT NOT NULL,
  `featuresPerPlan_id` INT NOT NULL,
  PRIMARY KEY (`limitid`),
  INDEX `user_plan_limit_planuser_id_idx` (`planuser_id` ASC) VISIBLE,
  INDEX `user_plan_limit_featuresPerPlan_id_idx` (`featuresPerPlan_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_plan_limit_features_per_plan`
    FOREIGN KEY (`featuresPerPlan_id`)
    REFERENCES `paymentassistant`.`features_per_plan` (`featuresPerPlan_id`),
  CONSTRAINT `fk_user_plan_limit_plan_per_user`
    FOREIGN KEY (`planuser_id`)
    REFERENCES `paymentassistant`.`plan_per_user` (`planuser_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
