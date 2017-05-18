-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema sm
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema sm
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sm` DEFAULT CHARACTER SET utf8 ;
USE `sm` ;

-- -----------------------------------------------------
-- Table `sm`.`zgan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zgan` (
  `GanId` INT(11) NOT NULL,
  `Gan` VARCHAR(2) NOT NULL,
  `YingYangId` INT(11) NOT NULL,
  `WuHangId` INT(11) NOT NULL,
  `JiJieId` INT(11) NULL DEFAULT NULL,
  `FangWeiId` INT(11) NULL DEFAULT NULL,
  `TiBiaoId` INT(11) NULL DEFAULT NULL,
  `ZangFuId` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`GanId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zzhi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zzhi` (
  `ZhiId` INT(11) NOT NULL,
  `Zhi` VARCHAR(2) NOT NULL,
  `YingYangId` INT(11) NOT NULL,
  `WuhangId` INT(11) NOT NULL,
  `FromShi` INT(11) NOT NULL,
  `ToShi` INT(11) NOT NULL,
  `ShengXiaoId` INT(11) NOT NULL,
  `CangGanId1` INT(11) NOT NULL,
  `CangGanId2` INT(11) NULL DEFAULT NULL,
  `CangGanId3` INT(11) NULL DEFAULT NULL,
  `JiJieId` INT(11) NOT NULL,
  `FangWeiId` INT(11) NOT NULL,
  PRIMARY KEY (`ZhiId`),
  INDEX `FK_zZhi_zCangGan1` (`CangGanId1` ASC),
  INDEX `FK_zZhi_zCangGan2` (`CangGanId2` ASC),
  INDEX `FK_zZhi_zCangGan3` (`CangGanId3` ASC),
  CONSTRAINT `FK_zZhi_zCangGan1`
    FOREIGN KEY (`CangGanId1`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_zZhi_zCangGan2`
    FOREIGN KEY (`CangGanId2`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_zZhi_zCangGan3`
    FOREIGN KEY (`CangGanId3`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zjieqi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zjieqi` (
  `JieQiId` INT(11) NOT NULL,
  `JieQiMonth` INT(11) NOT NULL,
  `JieQi` VARCHAR(50) NOT NULL,
  `ZhiId` INT(11) NOT NULL,
  `Minutes` INT(11) NOT NULL,
  PRIMARY KEY (`JieQiId`),
  INDEX `FK_zJieQi_zZhi` (`ZhiId` ASC),
  CONSTRAINT `FK_zJieQi_zZhi`
    FOREIGN KEY (`ZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dmingzhu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dmingzhu` (
  `MingZhuId` INT(11) NOT NULL AUTO_INCREMENT,
  `Disabled` TINYINT(1) NOT NULL DEFAULT '0',
  `MingZhu` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `XingBie` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `GongLi` DATETIME(6) NULL DEFAULT NULL,
  `NongLi` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `GongLiNian` INT(11) NULL DEFAULT NULL,
  `GongLiYue` INT(11) NULL DEFAULT NULL,
  `GongLiRi` INT(11) NULL DEFAULT NULL,
  `Shi` INT(11) NULL DEFAULT NULL,
  `Feng` INT(11) NULL DEFAULT NULL,
  `NongLiNian` INT(11) NULL DEFAULT NULL,
  `NongLiYue` INT(11) NULL DEFAULT NULL,
  `NongLiRi` INT(11) NULL DEFAULT NULL,
  `NianGanId` INT(11) NULL DEFAULT NULL,
  `NianZhiId` INT(11) NULL DEFAULT NULL,
  `YueGanId` INT(11) NULL DEFAULT NULL,
  `YueZhiId` INT(11) NULL DEFAULT NULL,
  `RiGanId` INT(11) NULL DEFAULT NULL,
  `RiZhiId` INT(11) NULL DEFAULT NULL,
  `ShiGanId` INT(11) NULL DEFAULT NULL,
  `ShiZhiId` INT(11) NULL DEFAULT NULL,
  `CurrentJieQiId` INT(11) NULL DEFAULT NULL,
  `PreviousJieQiId` INT(11) NULL DEFAULT NULL,
  `PreviousJieQiDate` DATETIME(6) NULL DEFAULT NULL,
  `NextJieQiId` INT(11) NULL DEFAULT NULL,
  `NextJieQiDate` DATETIME(6) NULL DEFAULT NULL,
  `IsShun` TINYINT(1) NOT NULL,
  `Note` VARCHAR(200) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `CreateBy` VARCHAR(50) CHARACTER SET 'utf8mb4' NOT NULL,
  `CreateDateTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LastModifyBy` VARCHAR(50) CHARACTER SET 'utf8mb4' NOT NULL,
  `LastModifyDateTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`MingZhuId`),
  INDEX `FK_dMingZhu_zJieQi` (`PreviousJieQiId` ASC),
  INDEX `FK_dMingZhu_zJieQi1` (`NextJieQiId` ASC),
  INDEX `FK_dMingZhu_zZhi` (`NianZhiId` ASC),
  INDEX `FK_dMingZhu_zZhi1` (`YueZhiId` ASC),
  INDEX `FK_dMingZhu_zZhi2` (`RiZhiId` ASC),
  INDEX `FK_dMingZhu_zZhi3` (`ShiZhiId` ASC),
  INDEX `FK_dMingZhu_zGan` (`NianGanId` ASC),
  INDEX `FK_dMingZhu_zGan1` (`YueGanId` ASC),
  INDEX `FK_dMingZhu_zGan2` (`RiGanId` ASC),
  INDEX `FK_dMingZhu_zGan3` (`ShiGanId` ASC),
  CONSTRAINT `FK_dMingZhu_zGan`
    FOREIGN KEY (`NianGanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zGan1`
    FOREIGN KEY (`YueGanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zGan2`
    FOREIGN KEY (`RiGanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zGan3`
    FOREIGN KEY (`ShiGanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zJieQi`
    FOREIGN KEY (`PreviousJieQiId`)
    REFERENCES `sm`.`zjieqi` (`JieQiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zJieQi1`
    FOREIGN KEY (`NextJieQiId`)
    REFERENCES `sm`.`zjieqi` (`JieQiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zZhi`
    FOREIGN KEY (`NianZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zZhi1`
    FOREIGN KEY (`YueZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zZhi2`
    FOREIGN KEY (`RiZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dMingZhu_zZhi3`
    FOREIGN KEY (`ShiZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dbazi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dbazi` (
  `BaZiId` INT(11) NOT NULL AUTO_INCREMENT,
  `MingZhuId` INT(11) NOT NULL,
  `GanZhiTypeId` INT(11) NOT NULL,
  `Year` INT(11) NULL DEFAULT NULL,
  `GanId` INT(11) NULL DEFAULT NULL,
  `ZhiId` INT(11) NULL DEFAULT NULL,
  `ZhiCGanId1` INT(11) NULL DEFAULT NULL,
  `ZhiCGanId2` INT(11) NULL DEFAULT NULL,
  `ZhiCGanId3` INT(11) NULL DEFAULT NULL,
  `GanSSId` INT(11) NULL DEFAULT NULL,
  `ZhiSSId1` INT(11) NULL DEFAULT NULL,
  `ZhiSSId2` INT(11) NULL DEFAULT NULL,
  `ZhiSSId3` INT(11) NULL DEFAULT NULL,
  `WangShuaiId` INT(11) NULL DEFAULT NULL,
  `NaYinId` INT(11) NULL DEFAULT NULL,
  `BaZiSeq` INT(11) NULL DEFAULT NULL,
  `BaZiRefId` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`BaZiId`),
  INDEX `FK_dBaZi_dMingZhu` (`MingZhuId` ASC),
  INDEX `FK_dBaZi_zGan` (`GanId` ASC),
  INDEX `FK_dBaZi_zZhi` (`ZhiId` ASC),
  INDEX `FK_dBaZi_zZhiCGan1` (`ZhiCGanId1` ASC),
  INDEX `FK_dBaZi_zZhiCGan2` (`ZhiCGanId2` ASC),
  INDEX `FK_dBaZi_zZhiCGan3` (`ZhiCGanId3` ASC),
  CONSTRAINT `FK_dBaZi_dMingZhu`
    FOREIGN KEY (`MingZhuId`)
    REFERENCES `sm`.`dmingzhu` (`MingZhuId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dBaZi_zGan`
    FOREIGN KEY (`GanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dBaZi_zZhi`
    FOREIGN KEY (`ZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dBaZi_zZhiCGan1`
    FOREIGN KEY (`ZhiCGanId1`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dBaZi_zZhiCGan2`
    FOREIGN KEY (`ZhiCGanId2`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_dBaZi_zZhiCGan3`
    FOREIGN KEY (`ZhiCGanId3`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 156
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dmingzhuadd`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dmingzhuadd` (
  `MingZhuId` INT(11) NOT NULL,
  `JQMonthFromDt` DATETIME(6) NULL DEFAULT NULL,
  `JQMonthToDt` DATETIME(6) NULL DEFAULT NULL,
  `QiYunDateTime` DATETIME(6) NULL DEFAULT NULL,
  `QiYunSui` INT(11) NULL DEFAULT NULL,
  `KongWangZhiId1` INT(11) NULL DEFAULT NULL,
  `KongWangZhiId2` INT(11) NULL DEFAULT NULL,
  INDEX `FK_dMingZhuAdd_dMingZhu` (`MingZhuId` ASC),
  CONSTRAINT `FK_dMingZhuAdd_dMingZhu`
    FOREIGN KEY (`MingZhuId`)
    REFERENCES `sm`.`dmingzhu` (`MingZhuId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dmingzhugzgx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dmingzhugzgx` (
  `MingZhuId` INT(11) NOT NULL,
  `GXTypeId` INT(11) NULL DEFAULT NULL,
  `DYPeriod` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `DYSui` VARCHAR(10) NULL DEFAULT NULL,
  `Year` INT(11) NULL DEFAULT NULL,
  `GanZhiTypeId1` INT(11) NULL DEFAULT NULL,
  `GanId1` INT(11) NULL DEFAULT NULL,
  `ZhiId1` INT(11) NULL DEFAULT NULL,
  `GanZhiTypeId2` INT(11) NULL DEFAULT NULL,
  `GanId2` INT(11) NULL DEFAULT NULL,
  `ZhiId2` INT(11) NULL DEFAULT NULL,
  `GanZhiTypeId3` INT(11) NULL DEFAULT NULL,
  `GanId3` INT(11) NULL DEFAULT NULL,
  `ZhiId3` INT(11) NULL DEFAULT NULL,
  `GXId` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dmingzhuss`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dmingzhuss` (
  `MingZhuId` INT(11) NOT NULL,
  `ShengShaId` INT(11) NOT NULL,
  `GanZhiTypeId` INT(11) NOT NULL,
  `Remark` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `CreateDateTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`MingZhuId`, `ShengShaId`, `GanZhiTypeId`),
  CONSTRAINT `FK_dMingZhuSS_dMingZhu`
    FOREIGN KEY (`MingZhuId`)
    REFERENCES `sm`.`dmingzhu` (`MingZhuId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dmingzhuzwadd`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dmingzhuzwadd` (
  `MingZhuId` INT(11) NOT NULL,
  `WuHangId` INT(11) NOT NULL,
  `YueGanId` INT(11) NOT NULL DEFAULT '0',
  `YueZhiId` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`MingZhuId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dziwei`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dziwei` (
  `ZiWeiId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `MingZhuId` INT(11) NOT NULL,
  `PaiPanTypeId` INT(11) NOT NULL,
  `GongWeiId` INT(11) NULL DEFAULT NULL,
  `IsShengGong` TINYINT(1) NOT NULL DEFAULT '0',
  `GanId` INT(11) NOT NULL,
  `ZhiId` INT(11) NOT NULL,
  `HuaLuXYId` INT(11) NULL DEFAULT NULL,
  `HuaLuGWId` INT(11) NULL DEFAULT NULL,
  `HuaQuanXYId` INT(11) NULL DEFAULT NULL,
  `HuaQuanGWId` INT(11) NULL DEFAULT NULL,
  `HuaKeXYId` INT(11) NULL DEFAULT NULL,
  `HuaKeGWId` INT(11) NULL DEFAULT NULL,
  `HuaJiXYId` INT(11) NULL DEFAULT NULL,
  `HuaJiGWId` INT(11) NULL DEFAULT NULL,
  `DaXianFrom` INT(11) NULL DEFAULT NULL,
  `DaXianTo` INT(11) NULL DEFAULT NULL,
  `DaXian` INT(11) NULL DEFAULT NULL,
  `Year` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ZiWeiId`),
  INDEX `FK_dZiWei_dMingZhu` (`MingZhuId` ASC),
  CONSTRAINT `FK_dZiWei_dMingZhu`
    FOREIGN KEY (`MingZhuId`)
    REFERENCES `sm`.`dmingzhu` (`MingZhuId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1166
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`dziweixingyao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`dziweixingyao` (
  `ZiWeiId` BIGINT(20) NOT NULL,
  `XingYaoId` INT(11) NOT NULL,
  `MiaoXianId` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ZiWeiId`, `XingYaoId`),
  INDEX `FK_dZiWeiXingYao_wMiaoXian` (`MiaoXianId` ASC),
  CONSTRAINT `FK_dZiWeiXingYao_dZiWei`
    FOREIGN KEY (`ZiWeiId`)
    REFERENCES `sm`.`dziwei` (`ZiWeiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tjieqi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tjieqi` (
  `JieQiId` INT(11) NOT NULL,
  `JieQiMonth` INT(11) NOT NULL,
  `JieQi` VARCHAR(50) NOT NULL,
  `ZhiId` INT(11) NOT NULL,
  `Minutes` INT(11) NOT NULL,
  `fromDt` DATETIME NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tjieri`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tjieri` (
  `jieriid` INT(11) NULL DEFAULT NULL,
  `jrtype` INT(11) NULL DEFAULT NULL,
  `hmon` INT(11) NULL DEFAULT NULL,
  `hday` INT(11) NULL DEFAULT NULL,
  `recess` INT(11) NULL DEFAULT NULL,
  `holiday` VARCHAR(50) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tlunarsolarmap`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tlunarsolarmap` (
  `IYear` INT(11) NULL DEFAULT NULL,
  `IMon` INT(11) NULL DEFAULT NULL,
  `IDay` INT(11) NULL DEFAULT NULL,
  `IHour` INT(11) NULL DEFAULT NULL,
  `IMin` INT(11) NULL DEFAULT NULL,
  `IIsLeapM` BIT(1) NULL DEFAULT NULL,
  `IToLunar` BIT(1) NULL DEFAULT NULL,
  `SolarDt` DATETIME NULL DEFAULT NULL,
  `SolarY` INT(11) NULL DEFAULT NULL,
  `SolarM` INT(11) NULL DEFAULT NULL,
  `SolarD` INT(11) NULL DEFAULT NULL,
  `LunarDtStr` VARCHAR(50) NULL DEFAULT NULL,
  `LunarY` INT(11) NULL DEFAULT NULL,
  `LunarM` INT(11) NULL DEFAULT NULL,
  `LunarD` INT(11) NULL DEFAULT NULL,
  `IsLeapY` BIT(1) NULL DEFAULT NULL,
  `IsLeapM` BIT(1) NULL DEFAULT NULL,
  `CurJQ` VARCHAR(4) NULL DEFAULT NULL,
  `PrevJQ` VARCHAR(4) NULL DEFAULT NULL,
  `PrevJQDt` DATETIME NULL DEFAULT NULL,
  `NextJQ` VARCHAR(4) NULL DEFAULT NULL,
  `NextJQDt` DATETIME NULL DEFAULT NULL,
  `JQMonthFromDt` DATETIME NULL DEFAULT NULL,
  `JQMonthToDt` DATETIME NULL DEFAULT NULL,
  `NGan` VARCHAR(1) NULL DEFAULT NULL,
  `NZhi` VARCHAR(1) NULL DEFAULT NULL,
  `YGan` VARCHAR(1) NULL DEFAULT NULL,
  `YZhi` VARCHAR(1) NULL DEFAULT NULL,
  `RGan` VARCHAR(1) NULL DEFAULT NULL,
  `RZhi` VARCHAR(1) NULL DEFAULT NULL,
  `SGan` VARCHAR(1) NULL DEFAULT NULL,
  `SZhi` VARCHAR(1) NULL DEFAULT NULL,
  `ConsteName` VARCHAR(10) NULL DEFAULT NULL,
  `Animal` VARCHAR(2) NULL DEFAULT NULL,
  `ChinaConstellation` VARCHAR(3) NULL DEFAULT NULL,
  `SolarHoliday` VARCHAR(100) NULL DEFAULT NULL,
  `LunarHoliday` VARCHAR(100) NULL DEFAULT NULL,
  `WeekDayHoliday` VARCHAR(100) NULL DEFAULT NULL,
  `Week` VARCHAR(3) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tlunaryear`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tlunaryear` (
  `id` INT(11) NULL DEFAULT NULL,
  `bitdata` BINARY(3) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tmingzhu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tmingzhu` (
  `MingZhu` VARCHAR(50) NULL DEFAULT NULL,
  `XingBie` VARCHAR(1) NULL DEFAULT NULL,
  `Year` INT(11) NULL DEFAULT NULL,
  `Month` INT(11) NULL DEFAULT NULL,
  `Day` INT(11) NULL DEFAULT NULL,
  `Hour` INT(11) NULL DEFAULT NULL,
  `Minute` INT(11) NULL DEFAULT NULL,
  `IsLeapMonth` INT(11) NULL DEFAULT NULL,
  `IsLunar` INT(11) NULL DEFAULT NULL,
  `Note` VARCHAR(200) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tyear`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tyear` (
  `yearno` INT(11) NULL DEFAULT NULL,
  `bitdt` BINARY(3) NULL DEFAULT NULL,
  `bitdata` INT(11) NULL DEFAULT NULL,
  `leapmon` INT(11) NULL DEFAULT NULL,
  `ydays` INT(11) NULL DEFAULT NULL,
  `fromdays` INT(11) NULL DEFAULT NULL,
  `todays` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`tymday`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`tymday` (
  `yearno` INT(11) NULL DEFAULT NULL,
  `monno` INT(11) NULL DEFAULT NULL,
  `mdays` INT(11) NULL DEFAULT NULL,
  `leapdays` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zganzhigx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zganzhigx` (
  `GXId` INT(11) NOT NULL AUTO_INCREMENT,
  `GXTypeId` INT(11) NULL DEFAULT NULL,
  `GanZhiId1` INT(11) NOT NULL,
  `GanZhiId2` INT(11) NOT NULL,
  `GanZhiId3` INT(11) NULL DEFAULT NULL,
  `GanZhiGXId` INT(11) NULL DEFAULT NULL,
  `GXValueId` INT(11) NULL DEFAULT NULL,
  `Remark` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  PRIMARY KEY (`GXId`))
ENGINE = InnoDB
AUTO_INCREMENT = 395
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zjiazi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zjiazi` (
  `JiaZiId` INT(11) NOT NULL,
  `jiaZiGanId` INT(11) NOT NULL,
  `JiaZiZhiId` INT(11) NOT NULL,
  `NaYinId` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`JiaZiId`),
  INDEX `FK_zJiaZi_zGan` (`jiaZiGanId` ASC),
  INDEX `FK_zJiaZi_zZhi` (`JiaZiZhiId` ASC),
  CONSTRAINT `FK_zJiaZi_zGan`
    FOREIGN KEY (`jiaZiGanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_zJiaZi_zZhi`
    FOREIGN KEY (`JiaZiZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zsetting`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zsetting` (
  `SKey` VARCHAR(20) NOT NULL,
  `SKeyId` INT(11) NULL DEFAULT NULL,
  `SValue` VARCHAR(50) CHARACTER SET 'utf8mb4' NOT NULL,
  `Disabled` TINYINT(1) NOT NULL DEFAULT '0',
  `GanId1` INT(11) NULL DEFAULT NULL,
  `GanId2` INT(11) NULL DEFAULT NULL,
  `GanId3` INT(11) NULL DEFAULT NULL,
  `GanId4` INT(11) NULL DEFAULT NULL,
  `ZhiId1` INT(11) NULL DEFAULT NULL,
  `ZhiId2` INT(11) NULL DEFAULT NULL,
  `ZhiId3` INT(11) NULL DEFAULT NULL,
  `ZhiId4` INT(11) NULL DEFAULT NULL,
  `TypeId` INT(11) NULL DEFAULT NULL,
  `XingYaoId` INT(11) NULL DEFAULT NULL,
  `ShunNi` TINYINT(1) NULL DEFAULT NULL,
  `SNote` VARCHAR(200) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zsuanming`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zsuanming` (
  `SKey` VARCHAR(20) NOT NULL,
  `SKeyId` INT(11) NOT NULL,
  `SValue` VARCHAR(50) CHARACTER SET 'utf8mb4' NOT NULL,
  `STypeId` INT(11) NULL DEFAULT NULL,
  `SAlias` VARCHAR(50) CHARACTER SET 'utf8mb4' NULL DEFAULT NULL,
  `SDisabled` TINYINT(1) NOT NULL DEFAULT '0')
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zwfeixing`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zwfeixing` (
  `FeiXingTypeId` INT(11) NOT NULL,
  `FeiXing` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `FromGongWeiID` INT(11) NULL DEFAULT NULL,
  `ToGongWeiID` INT(11) NULL DEFAULT NULL,
  `Note` LONGTEXT NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zwgansihua`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zwgansihua` (
  `GanSiHuaId` INT(11) NOT NULL,
  `GanId` INT(11) NOT NULL,
  `SiHuaId` INT(11) NOT NULL,
  `XingYaoId` INT(11) NOT NULL,
  `Disabled` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (`GanSiHuaId`),
  INDEX `FK_wGanSiHua_wXingYao` (`XingYaoId` ASC),
  INDEX `FK_wGanSiHua_zGan` (`GanId` ASC),
  CONSTRAINT `FK_wGanSiHua_zGan`
    FOREIGN KEY (`GanId`)
    REFERENCES `sm`.`zgan` (`GanId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zwmiaoxiangx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zwmiaoxiangx` (
  `XingYaoId` INT(11) NOT NULL,
  `ZhiId` INT(11) NOT NULL,
  `MiaoXianId` INT(11) NOT NULL,
  PRIMARY KEY (`XingYaoId`, `ZhiId`, `MiaoXianId`),
  INDEX `FK_wMiaoXianGX_zZhi` (`ZhiId` ASC),
  CONSTRAINT `FK_wMiaoXianGX_zZhi`
    FOREIGN KEY (`ZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zwuhang`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zwuhang` (
  `WuHangId` INT(11) NOT NULL AUTO_INCREMENT,
  `WuHang` VARCHAR(2) NOT NULL,
  `WuHangJu` VARCHAR(10) CHARACTER SET 'utf8mb4' NOT NULL,
  `JuShu` INT(11) NOT NULL,
  `QiZhiId` INT(11) NOT NULL,
  PRIMARY KEY (`WuHangId`),
  INDEX `FK_zWuHang_zZhi` (`QiZhiId` ASC),
  CONSTRAINT `FK_zWuHang_zZhi`
    FOREIGN KEY (`QiZhiId`)
    REFERENCES `sm`.`zzhi` (`ZhiId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `sm`.`zwuhanggx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`zwuhanggx` (
  `WuHangGXId` INT(11) NOT NULL,
  `ZhuTiId` INT(11) NOT NULL,
  `ShengKeId` INT(11) NOT NULL,
  `KeTiId` INT(11) NOT NULL,
  PRIMARY KEY (`WuHangGXId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

USE `sm` ;

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vbazi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vbazi` (`MingZhuId` INT, `MingZhu` INT, `XingBie` INT, `GongLi` INT, `NongLi` INT, `DYPeriod` INT, `DYSui` INT, `DYGSS` INT, `DYGan` INT, `DYZhi` INT, `DYZCG1` INT, `DYZCG2` INT, `DYZCG3` INT, `DYZCSS1` INT, `DYZCSS2` INT, `DYZCSS3` INT, `DYGanId` INT, `DYZhiId` INT, `DYZCGId1` INT, `DYZCGId2` INT, `DYZCGId3` INT, `GanZhiTypeId` INT, `GanZhiType` INT, `Year` INT, `GSS` INT, `Gan` INT, `Zhi` INT, `ZCG1` INT, `ZCG2` INT, `ZCG3` INT, `ZCSS1` INT, `ZCSS2` INT, `ZCSS3` INT, `LGanId` INT, `LZhiId` INT, `ZCGId1` INT, `ZCGId2` INT, `ZCGId3` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vganzhigx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vganzhigx` (`GXType` INT, `GXId` INT, `GXTypeId` INT, `GanZhiId1` INT, `GanZhiId2` INT, `GanZhiId3` INT, `GanZhiGXId` INT, `GXValueId` INT, `Remark` INT, `GanZhi1` INT, `GanZhi2` INT, `GanZhi3` INT, `GanZhiGX` INT, `GXValue` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vjiazi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vjiazi` (`JiaZiId` INT, `jiaZiGanId` INT, `JiaZiZhiId` INT, `NaYinId` INT, `Gan` INT, `Zhi` INT, `SValue` INT, `WuHangiD` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vmingzhu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vmingzhu` (`MingZhuId` INT, `MingZhu` INT, `XingBie` INT, `GongLi` INT, `NongLi` INT, `GongLiNian` INT, `NongLiNian` INT, `Sui` INT, `BaZiByJieQi` INT, `BaZiByYueFeng` INT, `Note` INT, `CurJieQi` INT, `PrevJieQi` INT, `PreviousJieQiDate` INT, `NextJieQi` INT, `NextJieQiDate` INT, `QiYunDateTime` INT, `QiYunSui` INT, `WuHangJu` INT, `QiJuSui` INT, `CreateDateTime` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vmingzhugzgx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vmingzhugzgx` (`mingzhuid` INT, `year` INT, `dyperiod` INT, `dysui` INT, `gan1` INT, `zhi1` INT, `ganzhitype1` INT, `gan2` INT, `zhi2` INT, `ganzhitype2` INT, `gan3` INT, `zhi3` INT, `ganzhitype3` INT, `gxtype` INT, `ganzhigx` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vmingzhuss`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vmingzhuss` (`MingZhu` INT, `GanZhiType` INT, `ShengSha` INT, `MingZhuId` INT, `ShengShaId` INT, `GanZhiTypeId` INT, `Remark` INT, `CreateDateTime` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vniantoyue`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vniantoyue` (`GanId1` INT, `GanId2` INT, `YueGanId` INT, `YueZhiId` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vritoshi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vritoshi` (`GanId1` INT, `GanId2` INT, `ShiGanId` INT, `ShiZhiId` INT, `JiaZiId` INT, `jiaZiGanId` INT, `JiaZiZhiId` INT, `NaYinId` INT, `Gan` INT, `Zhi` INT, `SValue` INT, `WuHangiD` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vsihua`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vsihua` (`GanSiHuaId` INT, `GanId` INT, `SiHuaId` INT, `XingYaoId` INT, `Disabled` INT, `SiHua` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vwuhanggx`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vwuhanggx` (`WuHangKe` INT, `WuHangZhu` INT, `WuHang` INT, `WuHangGXId` INT, `ZhuTiId` INT, `ShengKeId` INT, `KeTiId` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vzwfeixing`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vzwfeixing` (`MingZhuId` INT, `MingZhu` INT, `LFeiXing` INT, `LNote` INT, `QFeiXin` INT, `QNote` INT, `KFeiXing` INT, `KNote` INT, `JFeiXing` INT, `JNote` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vzwgongwei`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vzwgongwei` (`MingZhu` INT, `XingBie` INT, `GongLi` INT, `NongLi` INT, `PaiPanType` INT, `GongWei` INT, `Gan` INT, `Zhi` INT, `HLXY` INT, `HLGW` INT, `HQXY` INT, `HQGW` INT, `HKXY` INT, `HKGW` INT, `HJXY` INT, `HJGW` INT, `ZiWeiId` INT, `MingZhuId` INT, `PaiPanTypeId` INT, `GongWeiId` INT, `IsShengGong` INT, `GanId` INT, `ZhiId` INT, `HuaLuXYId` INT, `HuaLuGWId` INT, `HuaQuanXYId` INT, `HuaQuanGWId` INT, `HuaKeXYId` INT, `HuaKeGWId` INT, `HuaJiXYId` INT, `HuaJiGWId` INT, `DaXianFrom` INT, `DaXianTo` INT, `DaXian` INT, `Year` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vzwingyaozhi`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vzwingyaozhi` (`ZWZhiId` INT, `ZWZhi` INT, `ZWXYId` INT, `TJZhiId` INT, `TJXYId` INT, `TYAZhiId` INT, `TYAXYId` INT, `WQZhiId` INT, `WQXYId` INT, `TTZhiId` INT, `TTXYId` INT, `LZZhiId` INT, `LZXYId` INT, `TFZhiId` INT, `TFXYId` INT, `TYIZhiId` INT, `TYIXYId` INT, `TLAZhiId` INT, `TLAXYId` INT, `JMZhiId` INT, `JMXYId` INT, `TXZhiId` INT, `TXXYId` INT, `TLZhiId` INT, `TLXYId` INT, `QSZhiId` INT, `QSXYId` INT, `PJZhiId` INT, `PJXYId` INT);

-- -----------------------------------------------------
-- Placeholder table for view `sm`.`vzwxingyao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sm`.`vzwxingyao` (`ZiWeiId` INT, `MingZhuId` INT, `PaiPanType` INT, `GongWei` INT, `XingYao` INT, `XingYaoId` INT, `XingYaoTypeId` INT, `XingYaoType` INT, `PaiPanTypeId` INT, `GongWeiId` INT);

-- -----------------------------------------------------
-- function fConvertLunarDtStr
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` FUNCTION `fConvertLunarDtStr`(n int,t int) RETURNS char(10) CHARSET utf8
BEGIN
/* 转换农历日期为中文 select fConvertLunarDtStr(1,2)   */
declare lStr char(10);
declare HZNum  char(10);
declare nStr1 char(10);
declare nStr2 char(4);
declare nStr3 char(13);
set HZNum = N'零一二三四五六七八九';
set nStr1 = N'日一二三四五六七八九';
set nStr2 = N'初十廿卅';
  
  if t =1 and (n <0 or n >9) then set lStr='';
  elseif t =2 and (n <1 or n >13) then set lStr='';
  elseif t =3 and (n <1 or n >30) then  set lStr='';
  elseif t =3 then
	   if n = 10 then set lStr=N'初十';
	   elseif n = 20 then set lStr=N'二十';
	   elseif n = 30 then set lStr=N'三十';
	   else   set lStr=concat(substring(nStr2,truncate(n/10,0)+1,1),substring(nStr1,truncate(n%10+1,0),1));
	   end if;
  else
		 if (n <10) then set lStr=substring(HZNum,n+1,1); end if;
		 if t =2 and n = 1 then set lStr='正'; end if;
		 if n = 10 then set lStr=N'十'; end if;
		 if n = 11 then set lStr=N'十一'; end if;
		 if n = 12 then set lStr=N'腊'; end if;
         
  end if ;

  RETURN lStr;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function fGanZhiOffset
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` FUNCTION `fGanZhiOffset`(FromId int,Offs int,IsShun bit,IsGan bit) RETURNS int(11)
BEGIN
/*  干支顺逆移多少位:从甲1顺数3是丙3　select fGanZhiOffset(1,3,1,1)   */
	declare ToId int;
	declare Size int;
	if IsGan then set Size = 10; else set Size=12; end if;

	if IsShun = 1 then 
		set ToId=(FromId+Offs-1)%Size;
		if(ToId < 0) then  set ToId = ToId+Size; end if;
		if(ToId = 0) then  set ToId = Size; end if;
	elseif IsShun = 0 then
		set ToId=(FromId-Offs+1)%Size;
		if(ToId < 0) then  set ToId =ToId+ Size; end if;
		if(ToId = 0) then  set ToId = Size;  end if;
    end if;

  RETURN ToId;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function fGetMonthDays
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` FUNCTION `fGetMonthDays`(bitData int,mon int,leap bit) RETURNS int(11)
BEGIN
    /*得到当前月份天数:1986年农历2月天数  select fGetMonthDays(27968,2,0) */
    declare t1 int;
    declare t2 int;
    declare t3 int;
    declare t4 int;
	if leap = 0 then
		set t1 = bitData & 0x0000FFFF;
		set t2 = 16 - mon;
		set t3 =  1<<t2;
		if t1 & t3 = 0 then
		 set t4 = 29;
		else 
		 set t4 = 30;
        end if;
	else 
		if bitData & 0x10000 = 0 then
		 set t4 = 29;
		else 
		 set t4 = 30;
         end if;
      end if;
			  

  RETURN t4;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzAddMingZhu
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzAddMingZhu`(
    IN imzname varchar(50), 
	IN ixingbie varchar(1), 
	IN iyear int,
	IN imon int,
	IN iday int,
	IN ihour int,
	IN imin int,
	IN iIsleapM bit,
	IN iToLunar bit,
	IN iNote varchar(200))
ExitP:BEGIN
    /*根据农历新历,增加命主并且排盘
	call pzAddMingZhu('test',N'女',1995,10,2,6,3,0,1,'');
    */

	declare MESSAGE_TEXT text;
	declare MinYear int ;declare MaxYear int; declare IsShun bit;declare offsetDay int;declare i int;declare j int;
    declare MingZhuId int;declare GongLi datetime;declare QiYunDateTime datetime;declare KongWangZhiId int;
	set MinYear = 1900; /*1900年为鼠年 */
	set MaxYear=2050;
	/*varidate input */
	if ixingbie<>N'男' and ixingbie<>N'女' then 
      SET MESSAGE_TEXT = '非法性别';
      select MESSAGE_TEXT;
      leave ExitP;
    end if;

	if iToLunar = 1 and ( iyear<MinYear or iyear> MaxYear-1 or imon<1 or imon>12 or iday<1 or iday>31) then
      SET MESSAGE_TEXT = '非法公历日期';
      select MESSAGE_TEXT;
      leave ExitP;
     end if;
      
	if iToLunar = 0 and ( iyear<MinYear or iyear> MaxYear or imon<1 or imon>12 or iday<1 or iday>30) then
      SET MESSAGE_TEXT = '非法农历日期';
      select MESSAGE_TEXT;
      leave ExitP;
	end if;
      
	if  ihour<0 or ihour>24 or imin<0 or imin>60 then 
      SET MESSAGE_TEXT = '非法时间';
      select MESSAGE_TEXT;
      leave ExitP;
	end if;

/* insert into tlunarsolarmap */
 call pzConvertLunarSolar (iyear,imon,iday,ihour,imin,iIsleapM,iToLunar);

 set IsShun = 0;
 select IsShun=1 from tlunarsolarmap m, zgan g where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar
 and g.gan=m.nGan and ((ixingbie='男' and g.YingYangId=1) or (ixingbie='女' and g.YingYangId=2));

 insert into dmingzhu(MingZhu,Xingbie,GongLi,NongLi,GongLiNian,GongLiYue,GongLiRi
 ,Shi,Feng,NongLiNian,NongLiYue,NongLiRi
 ,NianGanId,NianZhiId,YueGanId,YueZhiId,RiGanId,RiZhiId,ShiGanId,ShiZhiId
 ,CurrentJieQiId,PreviousJieQiId,PreviousJieQiDate,NextJieQiId,NextJieQiDate,IsShun,Note,CreateBy,CreateDateTime,LastModifyBy,LastModifyDateTime) 
 select (case length(rtrim(ltrim(imzname))) when 0 then N'某人'+date_format(m.solarDt,'%Y%m%d') else imzname end) as MingZhu
 ,ixingbie as Xingbie,solarDt as GongLi,lunarDtStr as NongLi,solarY as GongLiNian,solarM as GongLiYue,solarD as GongLiRi
 ,ihour as Shi,imin as Feng,lunarY as NongLiNian,lunarM as NongLiYue,lunarD as NongLiRi
 ,ng.GanId as NianGanId,nz.ZhiId as NianZhiId,yg.GanId as YueGanId,yz.ZhiId as YueZhiId
 ,rg.GanId as RiGanId,rz.ZhiId as RiZhiId,sg.GanId as ShiGanId,sz.ZhiId as ShiZhiId
 ,cjq.JieQiId as CurrentJieQiId, pjq.JieQiId as PreviousJieQiId,prevJQDt as PreviousJieQiDate,njq.JieQiId as NextJieQiId,nextJQDt as NextJieQiDate
 ,IsShun as IsShun,iNote as Note,current_user(),now(),current_user(),now()
 from tlunarsolarmap m
 left join zGan ng on m.nGan = ng.Gan  left join zZhi nz on m.nZhi = nz.Zhi
 left join zGan yg on m.yGan = yg.Gan  left join zZhi yz on m.yZhi = yz.Zhi
 left join zGan rg on m.rGan = rg.Gan  left join zZhi rz on m.rZhi = rz.Zhi
 left join zGan sg on m.sGan = sg.Gan  left join zZhi sz on m.sZhi = sz.Zhi
 left join zJieQi cjq on m.curJQ = cjq.JieQi 
 left join zJieQi pjq on m.prevJQ = pjq.JieQi left join zJieQi njq on m.nextJQ = njq.JieQi
 where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar;

  set MingZhuId=LAST_INSERT_ID();
 insert into dMingZhuAdd(MingZhuId,JQMonthFromDt,JQMonthToDt)
 select MingZhuId,JQMonthFromDt,JQMonthToDt from tlunarsolarmap m where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar; 


 select @GongLi := mz.GongLi,@KongWangZhiId:=(mz.RiZhiId-mz.RiGanId+12-1)%12 from dMingZhu mz where mz.MingZHuId=MingZhuId;

 select @QiYunDateTime:=date_add(date_add(@GongLi,INTERVAL days/3 year),INTERVAL 4*(days%3) month)
 from (
 select case IsShun when 1 then datediff(mzad.JQMonthToDt,@GongLi) else datediff(@GongLi,mzad.JQMonthFromDt) end as days
,case IsShun when 1 then time_format(timediff(mzad.JQMonthToDt,@GongLi),'%H') else time_format(timediff(@GongLi,mzad.JQMonthFromDt),'%H') end as hours
,case IsShun when 1 then time_format(timediff(mzad.JQMonthToDt,@GongLi),'%i') else time_format(timediff(@GongLi,mzad.JQMonthFromDt),'%i') end as minutes
from dMingZhuAdd mzad where mzad.MingZHuId=MingZhuId) as mza;

update dMingZhuAdd set QiYunDateTime=@QiYunDateTime,QiYunSui= year(@QiYunDateTime)-year(@GongLi)
,KongWangZhiId1=@KongWangZhiId,KongWangZhiId2=@KongWangZhiId+1
where dMingZhuAdd.MingZHuId=MingZhuId;


/*八字排盘 */
 call pzFenXiBaZi(MingZhuId);

/* 紫薇排盘 */
 call pzwpaipan(MingZhuId);

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzConvertLunarSolar
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzConvertLunarSolar`(
	IN iyear int,
	IN imon int,
	IN iday int,
	IN ihour int,
	IN imin int,
	IN iIsleapM bit,
	IN iToLunar bit)
ExitP:BEGIN
    /* 农历新历互相转换
    call pzConvertLunarSolar( 1995,10,2,8,2,0,1);
    */

	/*返回值 */
    declare MESSAGE_TEXT text;
	declare solarDt datetime; declare leapdays int; declare isLeapM bit;declare isLeapY bit; declare solarY int; declare solarM int; declare solarD int; declare lunarY  int; declare lunarM int; declare lunarD int; declare lunarDtStr varchar(50);
	declare curJQ varchar(4); declare prevJQ varchar(4); declare prevJQDt datetime; declare nextJQ varchar(4); declare nextJQDt datetime; declare JieQiMonth int; declare JQMonthFromDt datetime; declare JQMonthToDt datetime; /*节气 */
	declare nGan varchar(1); declare nZhi varchar(1); declare yGan varchar(1); declare yZhi varchar(1); declare rGan varchar(1); declare rZhi varchar(1); declare sGan varchar(1); declare sZhi varchar(1); /*四柱 */
	declare consteName varchar(10); declare animal varchar(2); /*星座生肖 */
	declare chinaConstellation varchar(3); /*28星宿 */
	declare SolarHoliday varchar(100); declare LunarHoliday varchar(100); declare WeekDayHoliday varchar(100); declare Week varchar(3); /*节日 */
    /*农历阴历转换 */
	declare  dayDiff int; declare  fromdays int; declare mdays int;
	declare lunarYStr varchar(10); declare lunarMStr varchar(10); declare lunarDStr varchar(10);
    declare leapmon int;
    declare tmpGan varchar(12); declare indexGan int; declare  i int; declare tHour int; declare tMin int; declare offset int;
    declare jieQiStartDt datetime; declare JieQiId int;
    declare Bitdata int; declare WeekOfMonth int; declare dayOfWeek int;
    declare wOfMon int; declare firstMonthDay datetime;
	declare MinYear int ; declare MaxYear int;
	declare startDt datetime; declare  gzStartYr datetime; declare sartYr int; declare chinaConste datetime; declare chinaConsteStr varchar(200);
	declare ganStr varchar(10); declare zhiStr varchar(12); declare consteStr varchar(50); declare  animalStr varchar(12); declare WeekStr varchar(100);
	set MinYear = 1900; /*1900年为鼠年*/
	set MaxYear=2050;
	set startDt = str_to_date('1900-01-30','%Y-%m-%d');
	set gzStartYr = '1899-12-22';
	set sartYr = 1864; /*干支计算起始年*/
	set chinaConste='2007-9-13';/*28星宿参考值,本日为角*/
	set chinaConsteStr=N'角木蛟亢金龙女土蝠房日兔心月狐尾火虎箕水豹斗木獬牛金牛氐土貉虚日鼠危月燕室火猪壁水獝奎木狼娄金狗胃土彘昴日鸡毕月乌觜火猴参水猿井木犴鬼金羊柳土獐星日马张月鹿翼火蛇轸水蚓';
    set ganStr = N'甲乙丙丁戊己庚辛壬癸' ;
	set zhiStr = N'子丑寅卯辰巳午未申酉戌亥';
	set animalStr = N'鼠牛虎兔龙蛇马羊猴鸡狗猪';
	set WeekStr=N'星期日星期一星期二星期三星期四星期五星期六';
	set consteStr=N'白羊座金牛座双子座巨蟹座狮子座处女座天秤座天蝎座射手座摩羯座水瓶座双鱼座';
    /*初始化用户变量 */
    set  @lunarY=0,@lunarM=0,@isLeapY=0,@dayDiffYearStart=0,@dayDiffMonStart=0,@mdays=0,@leapdays=0,@leapmon=0,@curJQ='',@prevJQDt=null,@prevJQ='',@nextJQ='',@nextJQDt=null
    ,@JieQiId=0,@JieQiMonth=0,@yZhi=0,@JQMonthFromDt=null,@JQMonthToDt=null,@Bitdata=0,@SolarHoliday='' ,   @LunarHoliday='',  @WeekDayHoliday=''; 

    /*varidate inpjut */
	if iTolunar = 1 and ( iyear<MinYear or iyear> MaxYear-1 or imon<1 or imon>12 or iday<1 or iday>31) then 
      set MESSAGE_TEXT = '非法公历日期';
      select MESSAGE_TEXT;
      leave ExitP;
    end if;
	if iTolunar = 0 and ( iyear<MinYear or iyear> MaxYear or imon<1 or imon>12 or iday<1 or iday>30) then
      set MESSAGE_TEXT = '非法农历日期';
      select MESSAGE_TEXT;
      leave ExitP;
    end if;
	if  ihour<0 or ihour>24 or imin<0 or imin>60 then 
      SET MESSAGE_TEXT = '非法时间';
      select MESSAGE_TEXT;
      leave ExitP;
	end if;


  create table if not exists tLunarsolarmap(
    IYear int , IMon int , IDay int, IHour int,IMin int, IIsLeapM bit , IToLunar bit/*输入 */
    ,SolarDt datetime,SolarY int,SolarM int,SolarD int
	,LunarDtStr  varchar(50),LunarY int,LunarM  int,LunarD  int
	,IsLeapY bit,IsLeapM bit
	,CurJQ varchar(4),PrevJQ varchar(4) ,PrevJQDt datetime,NextJQ varchar(4),NextJQDt datetime,JQMonthFromDt datetime,JQMonthToDt datetime
	,NGan varchar(1),NZhi varchar(1),YGan varchar(1),YZhi varchar(1),RGan varchar(1),RZhi varchar(1),SGan varchar(1),SZhi varchar(1) /*四柱 */
	,ConsteName varchar(10),Animal varchar(2),ChinaConstellation varchar(3) /*28星宿 */
	,SolarHoliday varchar(100),LunarHoliday varchar(100),WeekDayHoliday varchar(100),Week  varchar(3) /*节日  */
    );
    

   if (select 1 from tLunarsolarmap m where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar) then
    select * from tLunarsolarmap m where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar ; 
    leave ExitP;
   end if;
    
 
	/*创建农历年表用来保存年月天数,节气表,节日表*/
  /*  drop table  if exists tLunarYear; */
  if not exists (select 1 from tLunarYear) then 
	create table  if not exists tLunarYear( id int,bitdata binary(3));

	INSERT tLunarYear (id,bitdata) VALUES (1, 0x004BD8);
	INSERT tLunarYear (id,bitdata) VALUES (2, 0x004AE0);
	INSERT tLunarYear (id,bitdata) VALUES (3, 0x00A570);
	INSERT tLunarYear (id,bitdata) VALUES (4, 0x0054D5);
	INSERT tLunarYear (id,bitdata) VALUES (5, 0x00D260);
	INSERT tLunarYear (id,bitdata) VALUES (6, 0x00D950);
	INSERT tLunarYear (id,bitdata) VALUES (7, 0x016554);
	INSERT tLunarYear (id,bitdata) VALUES (8, 0x0056A0);
	INSERT tLunarYear (id,bitdata) VALUES (9, 0x009AD0);
	INSERT tLunarYear (id,bitdata) VALUES (10, 0x0055D2);
	INSERT tLunarYear (id,bitdata) VALUES (11, 0x004AE0);
	INSERT tLunarYear (id,bitdata) VALUES (12, 0x00A5B6);
	INSERT tLunarYear (id,bitdata) VALUES (13, 0x00A4D0);
	INSERT tLunarYear (id,bitdata) VALUES (14, 0x00D250);
	INSERT tLunarYear (id,bitdata) VALUES (15, 0x01D255);
	INSERT tLunarYear (id,bitdata) VALUES (16, 0x00B540);
	INSERT tLunarYear (id,bitdata) VALUES (17, 0x00D6A0);
	INSERT tLunarYear (id,bitdata) VALUES (18, 0x00ADA2);
	INSERT tLunarYear (id,bitdata) VALUES (19, 0x0095B0);
	INSERT tLunarYear (id,bitdata) VALUES (20, 0x014977);
	INSERT tLunarYear (id,bitdata) VALUES (21, 0x004970);
	INSERT tLunarYear (id,bitdata) VALUES (22, 0x00A4B0);
	INSERT tLunarYear (id,bitdata) VALUES (23, 0x00B4B5);
	INSERT tLunarYear (id,bitdata) VALUES (24, 0x006A50);
	INSERT tLunarYear (id,bitdata) VALUES (25, 0x006D40);
	INSERT tLunarYear (id,bitdata) VALUES (26, 0x01AB54);
	INSERT tLunarYear (id,bitdata) VALUES (27, 0x002B60);
	INSERT tLunarYear (id,bitdata) VALUES (28, 0x009570);
	INSERT tLunarYear (id,bitdata) VALUES (29, 0x0052F2);
	INSERT tLunarYear (id,bitdata) VALUES (30, 0x004970);
	INSERT tLunarYear (id,bitdata) VALUES (31, 0x006566);
	INSERT tLunarYear (id,bitdata) VALUES (32, 0x00D4A0);
	INSERT tLunarYear (id,bitdata) VALUES (33, 0x00EA50);
	INSERT tLunarYear (id,bitdata) VALUES (34, 0x006E95);
	INSERT tLunarYear (id,bitdata) VALUES (35, 0x005AD0);
	INSERT tLunarYear (id,bitdata) VALUES (36, 0x002B60);
	INSERT tLunarYear (id,bitdata) VALUES (37, 0x0186E3);
	INSERT tLunarYear (id,bitdata) VALUES (38, 0x0092E0);
	INSERT tLunarYear (id,bitdata) VALUES (39, 0x01C8D7);
	INSERT tLunarYear (id,bitdata) VALUES (40, 0x00C950);
	INSERT tLunarYear (id,bitdata) VALUES (41, 0x00D4A0);
	INSERT tLunarYear (id,bitdata) VALUES (42, 0x01D8A6);
	INSERT tLunarYear (id,bitdata) VALUES (43, 0x00B550);
	INSERT tLunarYear (id,bitdata) VALUES (44, 0x0056A0);
	INSERT tLunarYear (id,bitdata) VALUES (45, 0x01A5B4);
	INSERT tLunarYear (id,bitdata) VALUES (46, 0x0025D0);
	INSERT tLunarYear (id,bitdata) VALUES (47, 0x0092D0);
	INSERT tLunarYear (id,bitdata) VALUES (48, 0x00D2B2);
	INSERT tLunarYear (id,bitdata) VALUES (49, 0x00A950);
	INSERT tLunarYear (id,bitdata) VALUES (50, 0x00B557);
	INSERT tLunarYear (id,bitdata) VALUES (51, 0x006CA0);
	INSERT tLunarYear (id,bitdata) VALUES (52, 0x00B550);
	INSERT tLunarYear (id,bitdata) VALUES (53, 0x015355);
	INSERT tLunarYear (id,bitdata) VALUES (54, 0x004DA0);
	INSERT tLunarYear (id,bitdata) VALUES (55, 0x00A5B0);
	INSERT tLunarYear (id,bitdata) VALUES (56, 0x014573);
	INSERT tLunarYear (id,bitdata) VALUES (57, 0x0052B0);
	INSERT tLunarYear (id,bitdata) VALUES (58, 0x00A9A8);
	INSERT tLunarYear (id,bitdata) VALUES (59, 0x00E950);
	INSERT tLunarYear (id,bitdata) VALUES (60, 0x006AA0);
	INSERT tLunarYear (id,bitdata) VALUES (61, 0x00AEA6);
	INSERT tLunarYear (id,bitdata) VALUES (62, 0x00AB50);
	INSERT tLunarYear (id,bitdata) VALUES (63, 0x004B60);
	INSERT tLunarYear (id,bitdata) VALUES (64, 0x00AAE4);
	INSERT tLunarYear (id,bitdata) VALUES (65, 0x00A570);
	INSERT tLunarYear (id,bitdata) VALUES (66, 0x005260);
	INSERT tLunarYear (id,bitdata) VALUES (67, 0x00F263);
	INSERT tLunarYear (id,bitdata) VALUES (68, 0x00D950);
	INSERT tLunarYear (id,bitdata) VALUES (69, 0x005B57);
	INSERT tLunarYear (id,bitdata) VALUES (70, 0x0056A0);
	INSERT tLunarYear (id,bitdata) VALUES (71, 0x0096D0);
	INSERT tLunarYear (id,bitdata) VALUES (72, 0x004DD5);
	INSERT tLunarYear (id,bitdata) VALUES (73, 0x004AD0);
	INSERT tLunarYear (id,bitdata) VALUES (74, 0x00A4D0);
	INSERT tLunarYear (id,bitdata) VALUES (75, 0x00D4D4);
	INSERT tLunarYear (id,bitdata) VALUES (76, 0x00D250);
	INSERT tLunarYear (id,bitdata) VALUES (77, 0x00D558);
	INSERT tLunarYear (id,bitdata) VALUES (78, 0x00B540);
	INSERT tLunarYear (id,bitdata) VALUES (79, 0x00B6A0);
	INSERT tLunarYear (id,bitdata) VALUES (80, 0x0195A6);
	INSERT tLunarYear (id,bitdata) VALUES (81, 0x0095B0);
	INSERT tLunarYear (id,bitdata) VALUES (82, 0x0049B0);
	INSERT tLunarYear (id,bitdata) VALUES (83, 0x00A974);
	INSERT tLunarYear (id,bitdata) VALUES (84, 0x00A4B0);
	INSERT tLunarYear (id,bitdata) VALUES (85, 0x00B27A);
	INSERT tLunarYear (id,bitdata) VALUES (86, 0x006A50);
	INSERT tLunarYear (id,bitdata) VALUES (87, 0x006D40);
	INSERT tLunarYear (id,bitdata) VALUES (88, 0x00AF46);
	INSERT tLunarYear (id,bitdata) VALUES (89, 0x00AB60);
	INSERT tLunarYear (id,bitdata) VALUES (90, 0x009570);
	INSERT tLunarYear (id,bitdata) VALUES (91, 0x004AF5);
	INSERT tLunarYear (id,bitdata) VALUES (92, 0x004970);
	INSERT tLunarYear (id,bitdata) VALUES (93, 0x0064B0);
	INSERT tLunarYear (id,bitdata) VALUES (94, 0x0074A3);
	INSERT tLunarYear (id,bitdata) VALUES (95, 0x00EA50);
	INSERT tLunarYear (id,bitdata) VALUES (96, 0x006B58);
	INSERT tLunarYear (id,bitdata) VALUES (97, 0x0055C0);
	INSERT tLunarYear (id,bitdata) VALUES (98, 0x00AB60);
	INSERT tLunarYear (id,bitdata) VALUES (99, 0x0096D5);
	INSERT tLunarYear (id,bitdata) VALUES (100, 0x0092E0);
	INSERT tLunarYear (id,bitdata) VALUES (101, 0x00C960);
	INSERT tLunarYear (id,bitdata) VALUES (102, 0x00D954);
	INSERT tLunarYear (id,bitdata) VALUES (103, 0x00D4A0);
	INSERT tLunarYear (id,bitdata) VALUES (104, 0x00DA50);
	INSERT tLunarYear (id,bitdata) VALUES (105, 0x007552);
	INSERT tLunarYear (id,bitdata) VALUES (106, 0x0056A0);
	INSERT tLunarYear (id,bitdata) VALUES (107, 0x00ABB7);
	INSERT tLunarYear (id,bitdata) VALUES (108, 0x0025D0);
	INSERT tLunarYear (id,bitdata) VALUES (109, 0x0092D0);
	INSERT tLunarYear (id,bitdata) VALUES (110, 0x00CAB5);
	INSERT tLunarYear (id,bitdata) VALUES (111, 0x00A950);
	INSERT tLunarYear (id,bitdata) VALUES (112, 0x00B4A0);
	INSERT tLunarYear (id,bitdata) VALUES (113, 0x00BAA4);
	INSERT tLunarYear (id,bitdata) VALUES (114, 0x00AD50);
	INSERT tLunarYear (id,bitdata) VALUES (115, 0x0055D9);
	INSERT tLunarYear (id,bitdata) VALUES (116, 0x004BA0);
	INSERT tLunarYear (id,bitdata) VALUES (117, 0x00A5B0);
	INSERT tLunarYear (id,bitdata) VALUES (118, 0x015176);
	INSERT tLunarYear (id,bitdata) VALUES (119, 0x0052B0);
	INSERT tLunarYear (id,bitdata) VALUES (120, 0x00A930);
	INSERT tLunarYear (id,bitdata) VALUES (121, 0x007954);
	INSERT tLunarYear (id,bitdata) VALUES (122, 0x006AA0);
	INSERT tLunarYear (id,bitdata) VALUES (123, 0x00AD50);
	INSERT tLunarYear (id,bitdata) VALUES (124, 0x005B52);
	INSERT tLunarYear (id,bitdata) VALUES (125, 0x004B60);
	INSERT tLunarYear (id,bitdata) VALUES (126, 0x00A6E6);
	INSERT tLunarYear (id,bitdata) VALUES (127, 0x00A4E0);
	INSERT tLunarYear (id,bitdata) VALUES (128, 0x00D260);
	INSERT tLunarYear (id,bitdata) VALUES (129, 0x00EA65);
	INSERT tLunarYear (id,bitdata) VALUES (130, 0x00D530);
	INSERT tLunarYear (id,bitdata) VALUES (131, 0x005AA0);
	INSERT tLunarYear (id,bitdata) VALUES (132, 0x0076A3);
	INSERT tLunarYear (id,bitdata) VALUES (133, 0x0096D0);
	INSERT tLunarYear (id,bitdata) VALUES (134, 0x004BD7);
	INSERT tLunarYear (id,bitdata) VALUES (135, 0x004AD0);
	INSERT tLunarYear (id,bitdata) VALUES (136, 0x00A4D0);
	INSERT tLunarYear (id,bitdata) VALUES (137, 0x01D0B6);
	INSERT tLunarYear (id,bitdata) VALUES (138, 0x00D250);
	INSERT tLunarYear (id,bitdata) VALUES (139, 0x00D520);
	INSERT tLunarYear (id,bitdata) VALUES (140, 0x00DD45);
	INSERT tLunarYear (id,bitdata) VALUES (141, 0x00B5A0);
	INSERT tLunarYear (id,bitdata) VALUES (142, 0x0056D0);
	INSERT tLunarYear (id,bitdata) VALUES (143, 0x0055B2);
	INSERT tLunarYear (id,bitdata) VALUES (144, 0x0049B0);
	INSERT tLunarYear (id,bitdata) VALUES (145, 0x00A577);
	INSERT tLunarYear (id,bitdata) VALUES (146, 0x00A4B0);
	INSERT tLunarYear (id,bitdata) VALUES (147, 0x00AA50);
	INSERT tLunarYear (id,bitdata) VALUES (148, 0x01B255);
	INSERT tLunarYear (id,bitdata) VALUES (149, 0x006D20);
	INSERT tLunarYear (id,bitdata) VALUES (150, 0x00ADA0);
	INSERT tLunarYear (id,bitdata) VALUES (151, 0x014B63);
    
    create table  if not exists tYear(
		 yearno int,
		 bitdt binary(3),
		 bitdata int,
		 leapmon int,
		 ydays int,
		 fromdays int,
		 todays int
		);
        
    create table  if not exists tYMday(
	 yearno int,
	 monno int,
	 mdays int,
	 leapdays int
	);
    
    
    /*生成年月天数 */  
    insert into tYear(yearNo,bitdt)
    select * from tLunarYear;
    
    update tyear set yearNo=yearNo+1899,bitData=CONV(HEX(bitdt),16,10),leapmon=CONV(HEX(bitdt),16,10) & 0xF;

	insert into tYMday(yearno,monno)
	select yearno,1 from tYear
	union
	select yearno,2 from tYear
	union
	select yearno,3 from tYear
	union
	select yearno,4 from tYear
	union
	select yearno,5 from tYear
	union
	select yearno,6 from tYear
	union
	select yearno,7 from tYear
	union
	select yearno,8 from tYear
	union
	select yearno,9 from tYear
	union
	select yearno,10 from tYear
	union
	select yearno,11 from tYear
	union
	select yearno,12 from tYear;

	update tYMday inner join tYear y on y.yearNo = tYMday.yearno  set mdays =  fGetMonthDays(y.bitdata,tYMday.monno,0) ;
	update tYMday inner join tYear y  on  y.yearNo = tYMday.yearno and y.leapmon=tYMday.monno set  leapdays =  fGetMonthDays(y.bitdata,y.leapmon,1);
	update tYear set ydays=(select  sum(ym.mdays)+sum(ifnull(ym.leapdays,0)) from tYMday ym where ym.yearno=tYear.yearno);
	update tyear y1 inner join (
    select y1.yearno,sum(y2.ydays) as fdays  from tYear y1 left join tYear y2  on  y2.yearno<y1.yearno group by y1.yearno ) as t on y1.yearno=t.yearno set y1.fromdays=ifnull(t.fdays,0),y1.todays=ifnull(t.fdays,0)+ydays;

end if;

	/* drop table if exists tJieQi; */
    if not exists (select 1 from tJieQi) then
		create table  if not exists tJieQi(
		JieQiId int NOT NULL,
		JieQiMonth int NOT NULL,
		JieQi varchar(50) NOT NULL,
		ZhiId int NOT NULL,
		Minutes int NOT NULL,
		fromDt Datetime);

		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (1, 12, N'小寒', 2, 0);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (2, 12, N'大寒', 2, 21208);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (3, 1, N'立春', 3, 42467);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (4, 1, N'雨水', 3, 63836);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (5, 2, N'惊蛰', 4, 85337);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (6, 2, N'春分', 4, 107014);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (7, 3, N'清明', 5, 128867);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (8, 3, N'谷雨', 5, 150921);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (9, 4, N'立夏', 6, 173149);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (10, 4, N'小满', 6, 195551);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (11, 5, N'芒种', 7, 218072);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (12, 5, N'夏至', 7, 240693);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (13, 6, N'小暑', 8, 263343);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (14, 6, N'大暑', 8, 285989);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (15, 7, N'立秋', 9, 308563);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (16, 7, N'处暑', 9, 331033);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (17, 8, N'白露', 10, 353350);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (18, 8, N'秋分', 10, 375494);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (19, 9, N'寒露', 11, 397447);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (20, 9, N'霜降', 11, 419210);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (21, 10, N'立冬', 12, 440795);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (22, 10, N'小雪', 12, 462224);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (23, 11, N'大雪', 1, 483532);
		INSERT tJieQi (JieQiId,JieQiMonth,JieQi,ZhiId,Minutes) VALUES (24, 11, N'冬至', 1, 504758);
    end if;
    
	/*drop table if exists tJieRi;*/
    if not exists (select 1 from tJieQi) then
		create table  if not exists tJieRi(
		jieriid int,
		jrtype int,  /* 1:公历节日　2:农历节日 3:按第几个星期算的节日 */
		hmon int,
		hday int,
		recess int,
		holiday varchar(50)
		);

		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (1, 1, 1, 1, 1, N'元旦');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (2, 1, 2, 2, 0, N'世界湿地日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (3, 1, 2, 10, 0, N'国际气象节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (4, 1, 2, 14, 0, N'情人节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (5, 1, 3, 1, 0, N'国际海豹日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (6, 1, 3, 5, 0, N'学雷锋纪念日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (7, 1, 3, 8, 0, N'妇女节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (8, 1, 3, 12, 0, N'植树节 孙中山逝世纪念日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (9, 1, 3, 14, 0, N'国际警察日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (10, 1, 3, 15, 0, N'消费者权益日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (11, 1, 3, 17, 0, N'中国国医节 国际航海日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (12, 1, 3, 21, 0, N'世界森林日 消除种族歧视国际日 世界儿歌日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (13, 1, 3, 22, 0, N'世界水日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (14, 1, 3, 24, 0, N'世界防治结核病日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (15, 1, 4, 1, 0, N'愚人节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (16, 1, 4, 7, 0, N'世界卫生日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (17, 1, 4, 22, 0, N'世界地球日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (18, 1, 5, 1, 1, N'劳动节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (19, 1, 5, 2, 1, N'劳动节假日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (20, 1, 5, 3, 1, N'劳动节假日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (21, 1, 5, 4, 0, N'青年节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (22, 1, 5, 8, 0, N'世界红十字日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (23, 1, 5, 12, 0, N'国际护士节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (24, 1, 5, 31, 0, N'世界无烟日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (25, 1, 6, 1, 0, N'国际儿童节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (26, 1, 6, 5, 0, N'世界环境保护日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (27, 1, 6, 26, 0, N'国际禁毒日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (28, 1, 7, 1, 0, N'建党节 香港回归纪念 世界建筑日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (29, 1, 7, 11, 0, N'世界人口日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (30, 1, 8, 1, 0, N'建军节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (31, 1, 8, 8, 0, N'中国男子节 父亲节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (32, 1, 8, 15, 0, N'抗日战争胜利纪念');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (33, 1, 9, 9, 0, N'  逝世纪念');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (34, 1, 9, 10, 0, N'教师节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (35, 1, 9, 18, 0, N'九·一八事变纪念日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (36, 1, 9, 20, 0, N'国际爱牙日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (37, 1, 9, 27, 0, N'世界旅游日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (38, 1, 9, 28, 0, N'孔子诞辰');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (39, 1, 10, 1, 1, N'国庆节 国际音乐日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (40, 1, 10, 2, 1, N'国庆节假日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (41, 1, 10, 3, 1, N'国庆节假日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (42, 1, 10, 6, 0, N'老人节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (43, 1, 10, 24, 0, N'联合国日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (44, 1, 11, 10, 0, N'世界青年节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (45, 1, 11, 12, 0, N'孙中山诞辰纪念');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (46, 1, 12, 1, 0, N'世界艾滋病日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (47, 1, 12, 3, 0, N'世界残疾人日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (48, 1, 12, 20, 0, N'澳门回归纪念');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (49, 1, 12, 24, 0, N'平安夜');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (50, 1, 12, 25, 0, N'圣诞节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (51, 1, 12, 26, 0, N' 诞辰纪念');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (52, 2, 1, 1, 1, N'春节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (53, 2, 1, 15, 0, N'元宵节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (54, 2, 5, 5, 0, N'端午节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (55, 2, 7, 7, 0, N'七夕情人节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (56, 2, 7, 15, 0, N'中元节 盂兰盆节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (57, 2, 8, 15, 0, N'中秋节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (58, 2, 9, 9, 0, N'重阳节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (59, 2, 12, 8, 0, N'腊八节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (60, 2, 12, 23, 0, N'北方小年(扫房)');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (61, 2, 12, 24, 0, N'南方小年(掸尘)');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (62, 3, 5, 2, 1, N'母亲节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (63, 3, 5, 3, 1, N'全国助残日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (64, 3, 6, 3, 1, N'父亲节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (65, 3, 9, 3, 3, N'国际和平日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (66, 3, 9, 4, 1, N'国际聋人节');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (67, 3, 10, 1, 2, N'国际住房日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (68, 3, 10, 1, 4, N'国际减轻自然灾害日');
		INSERT tJieRi (jieriid,jrtype,hmon,hday,recess,holiday) VALUES (69, 3, 11, 4, 5, N'感恩节');
    end if ;

	/*select * from tYear */

	if iTolunar = 1 then

	    /* 公历转换成阴历 */
		set solarY = iyear;
		set solarM=imon;
		set solarD=iday;
		set solarDt = str_to_date(concat(solarY,'-',solarM,'-',solarD,' ',ihour,':',imin,':00'),'%Y-%m-%d %H:%i:%s'); 
		if solarDt<'1900-01-30' or solarDt>'2049-12-31' then 
          SET MESSAGE_TEXT = '超出可转换的日期';  
		  select MESSAGE_TEXT;
		  leave ExitP;
		end if;
		set dayDiff = datediff(solarDt,startDt);
        
		select  @lunarY:=y.yearno,@isLeapY:=(case leapmon when 0 then 0 else 1 end),@dayDiffYearStart:=dayDiff - y.fromdays  from tYear y where dayDiff between y.fromdays and y.todays;
		select @lunarM:=ym.monno,@dayDiffMonStart:=@dayDiffYearStart-(select sum(ym1.mdays)+sum(ifnull(ym1.leapdays,0)) from tYMday ym1 where ym1.yearno= ym.yearno and ym1.monno<ym.monno)
		,@mdays:=ym.mdays,@leapdays:=ym.leapdays
		 from tYMday ym where ym.yearno=@lunarY  and @dayDiffYearStart between (select sum(ym1.mdays)+sum(ifnull(ym1.leapdays,0)) from tYMday ym1 where ym1.yearno= ym.yearno and ym1.monno<ym.monno) and 
		(select sum(ym2.mdays)+sum(ifnull(ym2.leapdays,0)) from tYMday ym2 where ym2.yearno= ym.yearno and ym2.monno<ym.monno+1);
		if @dayDiffMonStart>@mdays then
			set lunarD = @dayDiffMonStart - @mdays;
			set isLeapM = 1;
		else 
			set lunarD = @dayDiffMonStart ;
			set isLeapM = 0;
		end if;
        set lunarY = @lunarY,lunarM = @lunarM,isLeapY=@isLeapY;
	else 	

	  /* 阴历转换成公历  */
	    set lunarY=iyear;
		set lunarM=imon;
		set lunarD=iday ;
		
		select @dayDiffYearStart := y.fromdays,@isLeapY :=(case y.leapmon when 0 then 0 else 1 end),@leapmon:=y.leapmon from tYear y where y.yearno=lunarY ;
		if IsleapM = 1 and lunarM <> @leapmon then
		  set IsleapM = 0;
          SET MESSAGE_TEXT = '非法农历日期';  
          select MESSAGE_TEXT;
		  leave ExitP;
        end if ;

		select @dayDiffMonStart:=@dayDiffYearStart+(select sum(ym1.mdays)+sum(ifnull(ym1.leapdays,0)) from tYMday ym1 where ym1.yearno=ym.yearno and ym1.monno<ym.monno)+(case IsleapM when 1 then mdays else 0 end)+lunarD  
		from tYMday ym  where ym.yearno=lunarY  and ym.monno=lunarM;
		set solarDt = date_add(startDt,INTERVAL @dayDiffMonStart DAY);
		set solarY = year(solarDt);
		set solarM = month(solarDt);
		set solarD = day(solarDt);
        set isLeapY = @isLeapY, leapmon = @leapmon;
	end if;
    
	set lunarYStr =  concat(fConvertLunarDtStr(truncate(lunarY/1000,0),1), fConvertLunarDtStr(truncate((lunarY %1000)/100,0),1), fConvertLunarDtStr(truncate((lunarY %100)/10,0),1), fConvertLunarDtStr(truncate(lunarY %10,0),1));
	set lunarMStr =  fConvertLunarDtStr(lunarM,2);
	set lunarDStr =  fConvertLunarDtStr(lunarD,3);
	set lunarDtStr= concat('农历' ,lunarYStr , '年', (case isLeapM when 1 then '闰' else '' end), lunarMStr ,'月', lunarDStr,'日');


	/*四柱干支 */

	/*年干支 */
	set i=(lunarY -sartYr)%60;
	set nGan = substring(ganStr,i%10+1,1);
	set nZhi = substring(zhiStr,i%12+1,1);
	/*月干支 */
	set jieQiStartDt = STR_TO_DATE('1900-01-06 02:05:00','%Y-%m-%d %H:%i:%s');	
	update tJieQi set fromDt = date_add(jieQiStartDt, INTERVAL 525948.76 * (solarY - 1900)+ tJieQi.Minutes minute);

    if exists(select 1 from tJieQi jq where jq.jieqiid=1 and jq.fromdt>solarDt) then
	  select @JQMonthToDt:=jq.fromDt,@nextJQ:=JieQi,@nextJQDt := fromDt from tJieQi jq where jq.jieqiid=1 and jq.fromdt>solarDt;
      update tJieQi set fromDt = date_add(jieQiStartDt, INTERVAL 525948.76 * (solarY-1 - 1900)+ tJieQi.Minutes minute);
      select @curJQ:=jq.JieQi,@JieQiId:=jq.JieQiId,@JieQiMonth:=jq.JieQiMonth,@yZhi:=substring(zhiStr,jq.ZhiId,1),@prevJQDt := jq.fromDt
	  from tJieQi jq where solarDt between jq.fromDt and 
	 (select jq2.fromDt from tJieQi jq2 where jq2.JieQiId =  jq.JieQiId+1 ) ; 
      if @JieQiId=0 then 
         select @curJQ:=jq.JieQi,@JieQiId:=jq.JieQiId,@JieQiMonth:=jq.JieQiMonth,@yZhi:=substring(zhiStr,jq.ZhiId,1),@prevJQDt := jq.fromDt
		 from tJieQi jq where jq.jieqiid=24 ;
      else 
         select @nextJQ:=JieQi,@nextJQDt := fromDt from tJieQi jq where jq.JieQiId=(case @JieQiId when 24 then 1 else @JieQiId+1 end);
	     select @JQMonthToDt:=jq.fromDt from tJieQi jq where jq.JieQiMonth = @JieQiMonth+1 and jq.JieQiId%2=1;
      end if ;
    else 
	  select @curJQ:=jq.JieQi,@JieQiId:=jq.JieQiId,@JieQiMonth:=jq.JieQiMonth,@yZhi:=substring(zhiStr,jq.ZhiId,1),@prevJQDt := jq.fromDt
	  from tJieQi jq where solarDt between jq.fromDt and 
	 (select jq2.fromDt from tJieQi jq2 where jq2.JieQiId =  jq.JieQiId+1 ) ;
        	select @JQMonthFromDt:=jq.fromDt from tJieQi jq where jq.JieQiMonth = @JieQiMonth and jq.JieQiId%2=1;
      select @nextJQ:=JieQi,@nextJQDt := fromDt from tJieQi jq where jq.JieQiId=(case @JieQiId when 24 then 1 else @JieQiId+1 end);
	  select @JQMonthToDt:=jq.fromDt from tJieQi jq where jq.JieQiMonth = @JieQiMonth+1 and jq.JieQiId%2=1;
    end if ;
        
	select @prevJQ:=jq.JieQi from tJieQi jq where jq.JieQiId=(case @JieQiId when 1 then 24 else @JieQiId-1 end);
	select @JQMonthFromDt:=jq.fromDt from tJieQi jq where jq.JieQiMonth = @JieQiMonth and jq.JieQiId%2=1;
    set curJQ=@curJQ,prevJQ=@prevJQ,prevJQDt=@prevJQDt,nextJQ=@nextJQ,nextJQDt=@nextJQDt,JQMonthFromDt=@JQMonthFromDt,JQMonthToDt=@JQMonthToDt,JieQiMonth=@JieQiMonth,yZhi=@yZhi;
    
	/*按照节气定月干支 */
	set i = i%10;
	set yGan =substring(ganStr,((case i when 0 then 3 when 1 then 5 when 2 then 7 when 3 then 9 when 4 then 1 
	when 5 then 3 when 6 then 5 when 7 then 7 when 8 then 9  when 9 then 1 end)+JieQiMonth-2)%10+1,1);
	
    select ihour;
	/*日干支*/
	set dayDiff = datediff(solarDt,gzStartYr);
	set i = dayDiff%60 ;
	set rGan = substring(ganStr,i%10+1,1);
	set rZhi = substring(zhiStr,i%12+1,1);
	/*时干支*/
	set tHour = ihour ;
	set tMin = imin;
	set i = i%10;
	if imin != 0 then set tHour = tHour+1; end if;
	set offset = floor(tHour/2 );
	if offset >=12 then set offset=0 ; end if;
	set sGan =substring(ganStr,((case i when 0 then 1 when 1 then 3 when 2 then 5 when 3 then 7 when 4 then 9 
	when 5 then 1 when 6 then 3 when 7 then 5 when 8 then 7  when 9 then 9 end)+offset-1)%10+1,1);
	set sZhi = substring(zhiStr,offset+1,1);

	/*星座*/
	  set i=solarM *100 + solarD;
	  if ((i >= 321) and (i <= 419)) then set offset=0;
	  elseif ((i >= 420) and (i <= 520)) then set offset=1;
	  elseif ((i >= 521) and (i <= 620)) then set offset=2;
	  elseif ((i >= 621) and (i <= 722)) then set offset=3;
	  elseif ((i= 823) and (i <= 922)) then set offset=4;
	  elseif ((i= 823) and (i <= 922)) then set offset=5;
	  elseif ((i >= 923) and (i <= 1022)) then set offset=6;
	  elseif ((i >= 1023) and (i <= 1121)) then set offset=7;
	  elseif ((i >= 1122) and (i <= 1221)) then set offset=8;
	  elseif ((i >= 1222) or (i <= 119)) then set offset=9;
	  elseif ((i >= 120) and (i <= 218)) then set offset=10;
	  elseif ((i >= 219) and (i <= 320)) then set offset=11;
      end if;
	  set consteName= substring(consteStr,offset*3+1,3);
      
      /*属相*/ 
	  set animal = substring(animalStr,(solarY-MinYear)%12+1,1);

	  /*28星宿计算*/
	  set i = datediff(solarDt,chinaConste)%28;
	  if i >= 0 then 
         set chinaConstellation = substring(chinaConsteStr,i*3+1,3);
	  else 
         set chinaConstellation = substring(chinaConsteStr,(27+i)*3+1,3);
      end if;

	  /*节日 */   
	  select @SolarHoliday:=holiday from tJieRi where jrtype=1 and hmon=solarM and hday=solarD;
	  if IsLeapM = 0 then
	  select @LunarHoliday:=holiday from tJieRi where jrtype=2 and hmon=lunarM and hday=lunarD;
      end if;
	  if lunarM = 12 then /*除夕 */ 
	   select @Bitdata:=bitdata from tYear where yearno=lunarY ;
	   set i= fGetMonthDays(@Bitdata,12,0);
	   if lunarD = i then set @LunarHoliday=N'除夕'; end if;
	  end if;
	  set dayOfWeek = date_format(solarDt,'%w')+1;
	  set Week = substring(WeekStr,(dayOfWeek-1)*3+1,3);
	  set firstMonthDay = date_add(solarDt,INTERVAL 1-solarD DAY);
	  set WeekOfMonth = week(solarDt)-week(date_add(solarDt,INTERVAL 1-solarD DAY))+1 ;
	  set i = date_format(firstMonthDay,'%w')+1;
	  select @WeekDayHoliday:=holiday from tJieRi where jrtype=3 and hmon=solarM  and recess=dayOfWeek
	  and ((i>=dayOfWeek and hday = WeekOfMonth-1) or (i<dayOfWeek and hday = WeekOfMonth));
      set SolarHoliday=@SolarHoliday,LunarHoliday=@LunarHoliday,WeekDayHoliday=@WeekDayHoliday;
	  
    insert into tLunarsolarmap
    select iyear , imon, iday , ihour ,imin , iisleapm as IIsLeapM , itolunar as IToLunar
    ,solarDt  as solarDt,solarY as solarY,solarM as solarM,solarD as solarD
	,lunarDtStr as lunarDtStr,lunarY  as lunarY,lunarM  as lunarM,lunarD  as lunarD,isLeapY as isLeapY,isLeapM as isLeapM
	,curJQ as curJQ,prevJQ as prevJQ ,prevJQDt as prevJQDt ,nextJQ as nextJQ,nextJQDt as nextJQDt,JQMonthFromDt as JQMonthFromDt ,JQMonthToDt as JQMonthToDt
	,nGan as nGan,nZhi as nZhi,yGan as yGan,yZhi as yZhi,rGan as rGan,rZhi as rZhi,sGan as sGan,sZhi as sZhi /*四柱 */
	,consteName as consteName,animal as  animal,chinaConstellation as chinaConstellation /*28星宿 */
	,SolarHoliday as SolarHoliday,LunarHoliday as LunarHoliday,WeekDayHoliday as WeekDayHoliday,Week  as Week; /*节日 */
    

    select * from tLunarsolarmap m where m.IYear = iyear and m.IMon = imon and m.IDay = iday and m.IHour = ihour and  m.IMin = imin and m.IIsLeapM = iisleapm and m.IToLunar = itolunar ;
    
  /*  
  
  drop table tLunarYear;
  drop table tYear;
  drop table tYMday;
  drop table tJieQi;
  drop table tJieRi;
  */
  
/*
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	ROLLBACK;
	SELECT 'An error has occurred!';
	END;
*/
SET SQL_SAFE_UPDATES = 0;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzDelMingZhu
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzDelMingZhu`(
    IN MingZhuId int)
BEGIN
     /*    清除某命主数据 : call pzDelMingZhu(1);      
           清除数据然后增加个例子 : call pzDelMingZhu(0);              */
	 declare mingzhuid int;
           
     if MingZhuId > 0 then
		delete from dMingZhuAdd where dMingZhuAdd.MingZhuId = MingZhuId;
		delete from dMingZhuGZGX where dMingZhuGZGX.MingZhuId = MingZhuId;
		delete from dMingZhuSS where dMingZhuSS.MingZhuId = MingZhuId;
		delete from dBaZi where dBaZi.MingZhuId = MingZhuId;

		delete from dZiWeiXingYao;
		delete from dZiWei;
		delete from dMingZhuZWAdd;

		delete from dMingZhu where dMingZhu.MingZhuId = MingZhuId;

    else

		truncate table dmingzhuadd;
		truncate table dmingzhugzgx;
		truncate table dmingzhuss;
        truncate table dbazi;
        
        truncate table dziweixingyao;
		truncate table dmingzhuzwadd;
        
        delete from  dziwei;
		delete from dmingzhu;
		
        /* set AUTO_INCREMENT as 1 */
		ALTER TABLE dmingzhu AUTO_INCREMENT=1;
        ALTER TABLE dziwei AUTO_INCREMENT=1;
		
		/*  add sample data  */
		call pzAddMingZhu('test',N'男',1986,11,14,2,23,0,1,'');
        
        /* view result       */
        set mingzhuid = 1;
        select * from vmingzhu mz where mz.mingzhuid=mingzhuid order by CreateDateTime desc,mingzhu;
        select mingzhu,ganzhitype,shengsha,remark from vmingzhuss mz where mz.mingzhuid=mingzhuid;
		select * from vmingzhugzgx mz where mz.mingzhuid=mingzhuid;
        select * from  vzwfeixing mz where mz.mingzhuid=mingzhuid;
        select * from vzwgongwei mz where mz.mingzhuid=mingzhuid order by daxianfrom,paipantype;
        select PaiPanType,GongWei,XingYao,XingYaoType from vzwxingyao order by paipantypeid,gongweiid;
    end if;


END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzFenXiBaZi
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzFenXiBaZi`(IN MingZhuId int)
BEGIN
    /*八字排盘
    call pzFenXiBaZi(3);
    */

	delete from dMingZhuSS where dMingZhuSS.MingZhuId = MingZhuId;
	delete from dMingZhuGZGX where dMingZhuGZGX.mingzhuid=MingZhuId;
	delete from dBaZi where dBaZi.MingZhuId = MingZhuId;
	
	select @IsShun := mz.IsShun,@QiYunYear:=year(mza.QiYunDateTime),@NianGanId:=mz.NianGanId,@NianZhiId:=mz.NianZhiId,@YueGanId:=mz.YueGanId,@YueZhiId:=mz.YueZhiId
    ,@RiGanId:=mz.RiGanId,@ShiGanId:=mz.ShiGanId,@ShiZhiId:=mz.ShiZhiId,@IsShun:=mz.IsShun,@QiYunSui:=mza.QiYunSui,@GongLiYear :=year(mz.gongli)
    ,@SpecYear :=not(isnull(mz.GongLi))  from  dMingZhu mz,dMingZhuAdd mza 
	where mz.mingzhuid=mza.mingzhuid and mz.MingZhuId = MingZhuId;
    select @HandleXiaoYun:=1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=6;
    select @HandleMingGong:=1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=8;
    select @HandleTaiYuan:=1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=9;
    
	/* 年月日时柱  */
		insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)  
select t2.MingZhuId,t2.skeyid as GanZhiTypeId,null as year,t2.GanId,t2.ZhiId,t2.ZhiCGanId1,t2.ZhiCGanId2,t2.ZhiCGanId3
, case t2.skeyid when 3 then null else ss1.GXValueId end as GanSSId
,ss2.GXValueId as ZhiSSId1
,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId as WangShuaiId
,jz.NaYinId,null as baziseq,null as bazirefid
 from (
select t1.*,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3
from (
select mz.MingZhuId,gzt.skeyid,mz.RiGanId 
,case gzt.skeyid when 1 then mz.nianganid when 2 then mz.yueganid when 3 then mz.riganid when 4 then mz.shiganid end as GanId
,case gzt.skeyid when 1 then mz.nianzhiid when 2 then mz.yuezhiid when 3 then mz.rizhiid when 4 then mz.shizhiid end as ZhiId
  from dmingzhu mz, zsuanming gzt 
where mz.mingzhuid=MingZhuId and gzt.skey='bzGanZhiType' and gzt.skeyid in (1,2,3,4)
) as t1
left join zZhi z on t1.ZhiId = z.Zhiid 
) as t2
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t2.RiGanId and ss1.GanZhiId2 = t2.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t2.RiGanId and ss2.GanZhiId2 = t2.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t2.RiGanId and ss3.GanZhiId2 = t2.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t2.RiGanId and ss4.GanZhiId2 = t2.ZhiCGanId3
left join zJiaZi jz on jz.jiaZiGanId = t2.GanId and jz.JiaZiZhiId = t2.ZhiId
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t2.RiGanId and ssgx.GanZhiId2 = t2.ZhiId;


/*大运 */
    drop temporary table if exists temptb ;
    create temporary table  temptb as 
	select t2.*  from (
	select fGanZhiOffset(@YueGanId,offset+1,@IsShun,1) as GanId ,fGanZhiOffset(@YueZhiId,offset+1,@IsShun,0) as ZhiId,t.* from (
 select 1 as offset union select 2 as offset union select 3 as offset union select 4 as offset
 union select 5 as offset union select 6 as offset union select 7 as offset union select 8 as offset
 /*union select 9 as offset union select 10 as offset  */
 ) as t ) as t2;

/*select * from temptb */

	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
		,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
		,WangShuaiId,NaYinId,baziseq,bazirefid)
	select MingZhuId as MingZhuId,5 as GanZhiTypeId
	,@QiYunYear+(t.offset-1)*10 as year,t.GanId,t.ZhiId,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3
	, ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId,t.offset,null 
	from  temptb t 
	 left join zJiaZi jz on t.GanId =jz.jiaZiGanId and t.ZhiId=jz.JiaZiZhiId
	left join zZhi z on t.ZhiId=z.ZhiId/*) as t3 */
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = z.CangGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = z.CangGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = z.CangGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t.ZhiId;

	 
	/* 流年 */
    
    insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
	,WangShuaiId,NaYinId,baziseq,bazirefid)
    select MingZhuId as MingZhuId,7 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
,ssgx.GXValueId as WangShuaiId,jz.NaYinId as NaYinId,t3.BaZiSeq,t3.BaZiRefId  from (
select  jz.*,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from (
select  fGanZhiOffset(@NianGanId,z.ZhiId,1,1) as GanId ,fGanZhiOffset(@NianZhiId,z.ZhiId,1,0) as ZhiId,@GongLiYear+z.ZhiId-1 as Year
,z.ZhiId-1 as BaZiSeq,null as BaZiRefId from Zzhi z where z.ZhiId<=@QiYunSui) jz 
left join zZhi z on jz.ZhiId = z.Zhiid ) as t3
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
left join zjiazi jz on jz.JiaZiGanId = t3.GanId and jz.JiaZiZhiId = t3.ZhiId;

	
if(@SpecYear = 1) then
    insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
	,WangShuaiId,NaYinId,baziseq,bazirefid)
	select MingZhuId as MingZhuId,7 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
	,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId as NaYinId,t3.BaZiSeq,t3.BaZiRefId  from (
	select  jz.*,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from (
	select fGanZhiOffset(@NianGanId,(bz.BaZiSeq-1)*10+g.GanId+@QiYunSui,1,1) as GanId ,fGanZhiOffset(@NianZhiId,(bz.BaZiSeq-1)*10+g.GanId+@QiYunSui,1,0) as ZhiId,bz.Year+g.GanId-1 as Year
	,(bz.BaZiSeq-1)*10+g.GanId+@QiYunSui-1 as BaZiSeq,bz.BaZiId as BaZiRefId from dbazi bz,zgan g where bz.mingzhuid=MingZhuId and bz.ganzhitypeid=5) jz 
	left join zZhi z on jz.ZhiId = z.Zhiid ) as t3
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
	left join zjiazi jz on jz.JiaZiGanId = t3.GanId and jz.JiaZiZhiId = t3.ZhiId;
end if;


	/*小运 */
if(@SpecYear = 1) and (@HandleXiaoYun=1) then
	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
		,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
		,WangShuaiId,NaYinId,baziseq,bazirefid)
	select MingZhuId as MingZhuId,6 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
	,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId as NaYinId,t3.BaZiSeq,t3.BaZiRefId  from (
	select  jz.*
	,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from (
	select fGanZhiOffset(1,bz.baziseq+1,@IsShun,1) as GanId ,fGanZhiOffset(1,bz.baziseq+1,@IsShun,0) as ZhiId,bz.year,bz.baziseq,bz.BaZiRefId from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid= 7 order by baziseq) jz 
	left join zZhi z on jz.ZhiId = z.Zhiid ) as t3
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
	left join zjiazi jz on jz.JiaZiGanId = t3.GanId and jz.JiaZiZhiId = t3.ZhiId
	where not exists (select 1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=6) ; 

end if;

	/*命宫 */
if(@HandleMingGong = 1)  then
	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
		,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)
	select MingZhuId as MingZhuId,8 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
	,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId as NaYinId,t3.BaZiSeq,t3.BaZiRefId  from (
	select  jz.*
	,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from (
	select ny.YueGanId as GanId,fGanZhiOffset((26-fGanZhiOffset(@YueZhiId,3,0,0)-fGanZhiOffset(@ShiZhiId,3,0,0))%12,3,1,0) as ZhiId,null as year, null as baziseq,null as BaZiRefId 
	from vniantoyue ny where (ny.GanId1=1 or ny.GanId2=1) and ny.YueZhiId=fGanZhiOffset((26-fGanZhiOffset(@YueZhiId,3,0,0)-fGanZhiOffset(@ShiZhiId,3,0,0))%12,3,1,0)  ) jz 
	left join zZhi z on jz.ZhiId = z.Zhiid ) as t3
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
	left join zjiazi jz on jz.JiaZiGanId = t3.GanId and jz.JiaZiZhiId = t3.ZhiId;
end if;

	/*胎元 */
if(@HandleTaiYuan = 1)  then
	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)
	select MingZhuId as MingZhuId,9 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
	,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId as NaYinId,t3.BaZiSeq,t3.BaZiRefId  from (
	select  jz.*
	,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from (
	select fGanZhiOffset(@YueGanId,2,1,1) as GanId,fGanZhiOffset(@YueZhiId,3,1,0) as ZhiId,null as year, null as baziseq,null as BaZiRefId 
	) jz 
	left join zZhi z on jz.ZhiId = z.Zhiid ) as t3
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
	left join zjiazi jz on jz.JiaZiGanId = t3.GanId and jz.JiaZiZhiId = t3.ZhiId;
end if;

	/*神煞 */
	call pzFenXiShengSha (MingZhuId);

   /* 干支关系 */
   call pzFenXiGZGX(MingZhuId);

 
 

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzFenXiGZGX
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzFenXiGZGX`(IN MingZhuId int)
BEGIN
     /*分析某命主干支邢冲合害关系
     call pzFenXiGZGX(9);
     */
 delete from dmingzhugzgx  where dmingzhugzgx.MingZhuId=MingZhuId;
 select @GongLiNian:=mz.GongLiNian from dmingzhu mz where mz.mingzhuid=MingZhuId;
 
 /* 八字之间的干支关系 gxtypeid 1:干 2:支 */
  insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId) 
select MingZhuId,1,'',null,GanZhiTypeId1,Id1,null,GanZhiTypeId2,Id2,null,null,null,null,t2.GXId from 
 (SELECT distinct a.Id as Id1,a.ganzhitypeid as ganzhitypeid1, b.Id as Id2,b.ganzhitypeid as ganzhitypeid2
FROM (select bz.GanId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) a
CROSS JOIN (select bz.GanId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) b
WHERE a.Id != b.Id and a.ganzhitypeid != b.ganzhitypeid) t1,
( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=1) t2 where t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2;

 insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)  
select MingZhuId,2,'',null,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,null,null,null,t2.GXId from 
 (SELECT distinct a.Id as Id1,a.ganzhitypeid as ganzhitypeid1, b.Id as Id2,b.ganzhitypeid as ganzhitypeid2
FROM (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) a
CROSS JOIN (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) b
WHERE a.Id != b.Id and a.ganzhitypeid != b.ganzhitypeid  ) t1,
( SELECT GXId,  GanZhiId1, GanZhiId2, GanZhiId3, Remark FROM zganzhigx where gxtypeid=2 and GanZhiId3 is null) t2 where t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2 ;

 insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)   
select MingZhuId,2,'',null,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,GanZhiTypeId3,null,Id3,t2.GXId from 
 (SELECT distinct a.Id as Id1,a.ganzhitypeid as ganzhitypeid1, b.Id as Id2,b.ganzhitypeid as ganzhitypeid2,c.Id as Id3,c.ganzhitypeid as ganzhitypeid3
FROM (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) a
CROSS JOIN (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) b
CROSS JOIN (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) c
WHERE a.Id != b.Id and a.Id != c.Id and b.Id != c.Id and a.ganzhitypeid != b.ganzhitypeid and b.ganzhitypeid != c.ganzhitypeid and a.ganzhitypeid != c.ganzhitypeid ) t1,
( SELECT GXId,  GanZhiId1, GanZhiId2, GanZhiId3, Remark FROM zganzhigx where gxtypeid=2 and GanZhiId3 is not null) t2 where t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2 and  t1.id3=t2.GanZhiId3 ;

/* 八字跟和大运之间的干支关系 gxtypeid 1:干 2:支 */
insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)    
select MingZhuId,1,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.DYYear,GanZhiTypeId1,Id1,null,GanZhiTypeId2,Id2,null,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,bz.ganid as Id1,bz.GanZhiTypeId as GanZhiTypeId1,dybz.ganid as Id2,dybz.GanZhiTypeId as GanZhiTypeId2 from 
 (select ganid,GanZhiTypeId from dbazi where ganzhitypeid in (1,2,3,4) and mingzhuid=MingZhuId) bz ,
 (select year,ganid,GanZhiTypeId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where bz.GanId!=dybz.GanId
 ) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=1) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);

 
 insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)    
select MingZhuId,2,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.DYYear,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,bz.zhiid as Id1,bz.GanZhiTypeId as GanZhiTypeId1,dybz.zhiid as Id2,dybz.GanZhiTypeId as GanZhiTypeId2 from 
 (select zhiid,GanZhiTypeId from dbazi where ganzhitypeid in (1,2,3,4) and mingzhuid=MingZhuId) bz ,
 (select year,zhiid,GanZhiTypeId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where bz.ZhiId!=dybz.ZhiId
 ) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=2  and GanZhiId3 is null) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);
 
 insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)    
 select MingZhuId,2,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.DYYear,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,GanZhiTypeId3,null,Id3,t2.GXId from 
(
select dybz.year as DYYear,bz.*,dybz.Id as Id3,dybz.GanZhiTypeId as GanZhiTypeId3  from( 
select a.id as Id1,a.GanZhiTypeId as GanZhiTypeId1,b.id as Id2,b.GanZhiTypeId as GanZhiTypeId2 from( 
select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) a
CROSS JOIN (select bz.ZhiId as Id,bz.ganzhitypeid from dbazi bz where bz.mingzhuid=MingZhuId and ganzhitypeid in (1,2,3,4)) b
WHERE a.Id != b.Id  and a.ganzhitypeid != b.ganzhitypeid) bz,
 (select year,zhiid as Id,ganzhitypeid from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where bz.Id1!=dybz.Id and bz.Id2!=dybz.Id order by dybz.year
) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2,GanZhiId3,Remark FROM zganzhigx where gxtypeid=2 and GanZhiId3 is not null) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2 and t1.id3=t2.GanZhiId3) 
 or (t1.Id1=t2.GanZhiId3 and t1.id2=t2.GanZhiId1 and t1.id3=t2.GanZhiId2);
 
 /* 八字，大运和流年之间的干支关系 gxtypeid 1:干 2:支 */
 /*干 & 八字 & 流年 */
  insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)   
select MingZhuId,1,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.Year,GanZhiTypeId1,Id1,null,GanZhiTypeId2,Id2,null,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,lnbz.year as Year,bz.ganid as Id1,bz.GanZhiTypeId as GanZhiTypeId1,lnbz.ganid as Id2,lnbz.GanZhiTypeId as GanZhiTypeId2 from 
 (select year,ganid,GanZhiTypeId from dbazi where ganzhitypeid in (1,2,3,4) and mingzhuid=MingZhuId) bz ,
 (select year,ganid,GanZhiTypeId,BaZiRefId from dbazi where ganzhitypeid in (7) and mingzhuid=MingZhuId) lnbz,
 (select year,BaZiId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where bz.GanId!=lnbz.GanId and lnbz.BaZiRefId=dybz.BaZiId
 ) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=1) t2
 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);
 
 /*干 & 大运 & 流年 */
  insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)    
select MingZhuId,1,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.Year,GanZhiTypeId1,Id1,null,GanZhiTypeId2,Id2,null,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,lnbz.year as Year,lnbz.ganid as Id1,lnbz.GanZhiTypeId as GanZhiTypeId1,dybz.ganid as Id2,dybz.GanZhiTypeId as GanZhiTypeId2 from 
 (select year,ganid,GanZhiTypeId,BaZiRefId from dbazi where ganzhitypeid in (7) and mingzhuid=MingZhuId) lnbz ,
 (select year,ganid,GanZhiTypeId,BaZiId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where lnbz.GanId!=dybz.GanId and lnbz.BaZiRefId=dybz.BaZiId
 ) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=1) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);
  
 /*支 & 八字 & 流年 */
 insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)   
select MingZhuId,2,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.Year,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,lnbz.year as Year,bz.zhiid as Id1,bz.GanZhiTypeId as GanZhiTypeId1,lnbz.zhiid as Id2,lnbz.GanZhiTypeId as GanZhiTypeId2 from 
 (select year,ZhiId,GanZhiTypeId from dbazi where ganzhitypeid in (1,2,3,4) and mingzhuid=MingZhuId) bz ,
 (select year,ZhiId,GanZhiTypeId,BaZiRefId from dbazi where ganzhitypeid in (7) and mingzhuid=MingZhuId) lnbz,
 (select year,BaZiId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where bz.ZhiId!=lnbz.ZhiId and lnbz.BaZiRefId=dybz.BaZiId
 ) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=2) t2
 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);
 
 /*支 & 大运 & 流年 */
  insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)   
select MingZhuId,1,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.year,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,null,null,null,t2.GXId from 
(
select dybz.year as DYYear,lnbz.year ,lnbz.ZhiId as Id1,lnbz.GanZhiTypeId as GanZhiTypeId1,dybz.ZhiId as Id2,dybz.GanZhiTypeId as GanZhiTypeId2 from 
 (select year,ZhiId,GanZhiTypeId,BaZiRefId from dbazi where ganzhitypeid in (7) and mingzhuid=MingZhuId) lnbz ,
 (select year,ZhiId,GanZhiTypeId,BaZiId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz where lnbz.ZhiId!=dybz.ZhiId and lnbz.BaZiRefId=dybz.BaZiId
 ) t1,
 ( SELECT GXId,GanZhiId1, GanZhiId2, Remark FROM zganzhigx where gxtypeid=2  and GanZhiId3 is null) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2) or (t1.Id1=t2.GanZhiId2 and t1.id2=t2.GanZhiId1);
  
  /*支 & 八字 & 大运 & 流年 */
   insert into  dmingzhugzgx(MingZhuId,GXTypeId,DYPeriod,DYSui,Year,GanZhiTypeId1,GanId1,ZhiId1,GanZhiTypeId2,GanId2,ZhiId2,GanZhiTypeId3,GanId3,ZhiId3,GXId)   
 select MingZhuId,2,concat(t1.DYYear,'-',(t1.DYYear + 9)),concat(t1.DYYear-@GongLiNian,'-',(t1.DYYear-@GongLiNian + 9)),t1.Year,GanZhiTypeId1,null,Id1,GanZhiTypeId2,null,Id2,GanZhiTypeId3,null,Id3,t2.GXId from 
(
select dybz.year as DYYear,lnbz.year as Year,bz.Id as Id1,bz.GanZhiTypeId as GanZhiTypeId1,dybz.Id as Id2,dybz.GanZhiTypeId as GanZhiTypeId2,lnbz.Id as Id3,lnbz.GanZhiTypeId as GanZhiTypeId3 from
 (select year,ZhiId as Id,GanZhiTypeId from dbazi where ganzhitypeid in (1,2,3,4) and mingzhuid=MingZhuId) bz,
 (select year,zhiid as Id,ganzhitypeid,BaZiId from dbazi where ganzhitypeid in (5) and mingzhuid=MingZhuId) dybz,
 (select year,zhiid as Id,ganzhitypeid,BaZiRefId from dbazi where ganzhitypeid in (7) and mingzhuid=MingZhuId) lnbz where lnbz.BaZiRefId=dybz.BaZiId and bz.Id!=dybz.Id and bz.Id!=dybz.Id and dybz.Id!=lnbz.Id
 and bz.ganzhitypeid != dybz.ganzhitypeid and bz.ganzhitypeid != lnbz.ganzhitypeid and dybz.ganzhitypeid != lnbz.ganzhitypeid order by dybz.year
) t1,
 ( SELECT GXId,  GanZhiId1, GanZhiId2,GanZhiId3,Remark FROM zganzhigx where gxtypeid=2 and GanZhiId3 is not null) t2 where (t1.Id1=t2.GanZhiId1 and t1.id2=t2.GanZhiId2 and t1.id3=t2.GanZhiId3) 
 or (t1.Id1=t2.GanZhiId3 and t1.id2=t2.GanZhiId1 and t1.id3=t2.GanZhiId2);
  
  
 select * from dmingzhugzgx gx where gx.MingZhuId=MingZhuId;

 
 
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzFenXiShengSha
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzFenXiShengSha`(IN MingZhuId int)
BEGIN
     /*分析某命主神煞
     call pzFenXiShengSha(3);
     */
     
     drop temporary table if exists mingzhuss ;
	 create temporary table mingzhuss  (
		 MingZhuId int,
		 ShengShaId int,
		 GanZhiTypeId int,
		 Remark varchar(50) );

    
	/*年和日干查四柱 */
	insert into mingzhuss 
	select distinct t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	/*,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,t2.ShengSha */
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from dBaZi bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from dBaZi bz, zsetting  ss1
	 where   ss1.skey like 'bzshengsha%'  and ss1.typeid=6
	 and (bz.ganid=ss1.ganid1 or bz.ganid=ss1.ganid2) 
	and   bz.MingZhuId=MingZhuId and ganzhitypeid in (1,3) ) as t2
	where  t1.mingzhuid=t2.mingZhuId and t1.mingzhuid=t2.mingzhuid and 
	 (t1.zhiid=t2.zhiid1 or t1.zhiid=t2.zhiid2 or t1.zhiid=t2.zhiid3 or t1.zhiid=t2.zhiid4)
	  order by t1.GanZhiTypeId;


	/*年日支查四柱*/
	insert into mingzhuss  
	 	select distinct t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	/*,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4 */
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from dBaZi bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from dBaZi bz,zsetting  ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=11
	 and (bz.zhiid=ss1.zhiid1 or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3) 
	and   bz.mingzhuid=MingZhuId and ganzhitypeid in (1,3) ) as t2
	where  t1.mingzhuid=MingZhuId and t1.mingzhuid=t2.mingzhuid and 
	t1.zhiid=t2.zhiid4
	  order by t1.GanZhiTypeId;
      
     

	/*与年支相冲的前一位地支*/
	insert into mingzhuss  
		select distinct bz.MingZhuID,29 as ShengShaId,bz.GanZhiTypeId
	/*,bz.ganid,bz.zhiid,t2.zhiid5*/
	,'阳男阴女与年支相冲的前一地支为元辰，如是阴男阳女，即以年支相冲的后一位地支为元辰。' as Remark 
	from dBaZi bz ,
	(select (case when zhiid5<0 then zhiid5+12 when zhiid5>12 then zhiid5-12 else zhiid5 end) as zhiid5 from (
	select mz.nianzhiid,mz.xingbie,z.yingyangid
	,(case when mz.nianzhiid=zgx.ganzhiid1 then zgx.ganzhiid2+1 else zgx.ganzhiid1+1  end) as zhiid5 from dMingZhu mz,zzhi z,vganzhigx zgx 
	where mz.MingZhuId = MingZhuId and  ganzhigxid=2 and mz.nianzhiid=z.zhiid
	 and (mz.nianzhiid=zgx.ganzhiid1 or mz.nianzhiid=zgx.ganzhiid2)
	 and ((z.yingyangid= 1 and mz.xingbie='男') or (z.yingyangid= 0 and mz.xingbie='女'))
	 union
	 select mz.nianzhiid,mz.xingbie,z.yingyangid
	,(case when mz.nianzhiid=zgx.ganzhiid1 then zgx.ganzhiid2-1 else zgx.ganzhiid1-1  end) as zhiid5 from dMingZhu mz,zzhi z,vganzhigx zgx 
	where mz.MingZhuId = MingZhuId and  ganzhigxid=2 and mz.nianzhiid=z.zhiid
	 and (mz.nianzhiid=zgx.ganzhiid1 or mz.nianzhiid=zgx.ganzhiid2)
	 and ((z.yingyangid= 0 and mz.xingbie='男') or (z.yingyangid= 1 and mz.xingbie='女'))) as t) as t2
	 where bz.MingZhuId = MingZhuId and bz.GanZhiTypeId in (1,2,3,4) and bz.zhiid = t2.zhiid5;
	  
	/*年支查前后n位*/

	 
	/*年柱查四柱*/
	insert into mingzhuss 
		select distinct t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	/*,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4 */
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from dBaZi bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from dBaZi bz,zsetting  ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=12
	 and (bz.zhiid=ss1.zhiid1 or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3) 
	and   mingzhuid=MingZhuId and ganzhitypeid in (1) ) as t2
	where  t1.mingzhuid=MingZhuId and t1.mingzhuid=t2.mingzhuid and 
	t1.zhiid=t2.zhiid4
	  order by t1.GanZhiTypeId;
	 
	/*日干查四柱*/
	insert into mingzhuss 
	select  distinct bz.MingZhuId,t.ShengShaId,GanZhiTypeId
	  /*,GanId,ZhiId */
	  ,t.Remark from dBaZi bz,
	  (select GanZhiId2,case gxvalueid when 6 then '禄神' when 7 then '羊刃' end as Remark
	   ,case gxvalueid when 6 then 18 when 7 then 23 end as ShengShaId from dMingZhu mz
	  left join vGanZhiGX wsgx on wsgx.gxtypeid=4 and wsgx.GanZhiId1 = mz.RiGanId
	  where mz.MingZhuId = MingZhuId and  gxvalueid in (6,7)) as t
	  where bz.MingZhuId = MingZhuId and ganzhitypeid in (1,2,3,4) and zhiid = ganzhiid2;


	/*日时柱查神煞*/

insert into mingzhuss  
select distinct t.MingZhuId,t.ShengShaId,t1.GanZhiTypeId,t.Remark from (
select 
/*riganid,rizhiid,shiganid,shizhiid, */
mz.MingZhuId,38 as shengshaid,'' as remark from dMingZhu mz
inner join zsetting  ss1 on ss1.skeyid=38 and mz.riganid=ss1.ganid1 and mz.rizhiid=ss1.zhiid1
inner join zsetting  ss2 on ss2.skeyid=38 and mz.shiganid=ss2.ganid1 and mz.shizhiid=ss2.zhiid1
where mz.MingZhuId = MingZhuId 
union 
select 
/*riganid,rizhiid,shiganid,shizhiid */
mz.MingZhuId,skeyid as shengshaid,snote as remark from dMingZhu mz , zsetting ssgx
where mz.mingzhuid=MingZhuId and ssgx.skey like 'bzshengsha%' and ssgx.skeyid=19 and 
( (riganid=ssgx.ganid1 and rizhiid=ssgx.zhiid1 and shiganid=ssgx.ganid2 and shizhiid=ssgx.zhiid2)
or (riganid=ssgx.ganid3 and rizhiid=ssgx.zhiid3 and shiganid=ssgx.ganid4 and shizhiid=ssgx.zhiid4))) as t,
(select MingZhuId as MingZhuId,3 as GanZhiTypeId
union
select MingZhuId as MingZhuId,4 as GanZhiTypeId) as t1 where t.MingZhuId = t1.MingZhuId;
 
	/*日旬查四柱*/
	insert into mingzhuss 
	select distinct bz.MingZhuId,35 as ShengShaId,bz.GanZhiTypeId,'日柱空亡' as Remark
/*,bz.GanId,bz.ZhiId,t.KWZhi1,t.KWZhi2  */
from dbazi bz ,
(select mza.KongWangZhiId1 as kwzhi1,mza.KongWangZhiId2 as kwzhi2 from dMingZhu mz , dMingZhuAdd mza
where mz.mingzhuid=MingZhuId and  mz.mingzhuid =mza.mingzhuid) as t
where bz.mingzhuid=MingZhuId and bz.GanZhiTypeId in (1,2,3,4,9)
and (bz.zhiid=kwzhi1 or bz.zhiid=kwzhi2);


	/*日柱查神煞*/ 
	insert into mingzhuss
	select distinct mz.MingZhuId,ssgx.skeyid as ShengShaId,3 as GanZhiTypeId,ssgx.snote as Remark
	  /*ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha  */
	  from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=15
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and ((RiGanId = ssgx.GanId1 and RiZhiId = ssgx.ZhiId1)
	  or (RiGanId = ssgx.GanId2 and RiZhiId = ssgx.ZhiId2)
	  or (RiGanId = ssgx.GanId3 and RiZhiId = ssgx.ZhiId3)
	  or (RiGanId = ssgx.GanId4 and RiZhiId = ssgx.ZhiId4));


	/*三干相连查神煞*/
	insert into mingzhuss
	 select distinct bz.MingZhuId,7 as  ShengShaId,1 as GanZhiTypeId,Remark
 /*,GanId1,GanId2,GanId3  */
 from dMingZhu bz
	   ,(select ss.GanId1,ss.GanId2,ss.GanId3,ss.snote as Remark from zsetting ss
	    where  ss.skey like 'bzshengsha%'  and ss.typeid=7) as t
	  where mingzhuid=MingZhuId and ((bz.NianGanId = t.GanId1 and bz.YueGanId = t.GanId2 and bz.RiGanId = t.GanId3)
	  or (bz.YueGanId = t.GanId1 and bz.RiGanId = t.GanId2 and bz.ShiGanId = t.GanId3));

	/*时柱查神煞*/
	insert into mingzhuss
	select distinct mz.MingZhuId,ssgx.skeyid as ShengShaId,4 as GanZhiTypeId,ssgx.snote as Remark
	 /* ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha  */
	  from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=16
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and ((ShiGanId = ssgx.GanId1 and ShiZhiId = ssgx.ZhiId1)
	  or (ShiGanId = ssgx.GanId2 and ShiZhiId = ssgx.ZhiId2)
	  or (ShiGanId = ssgx.GanId3 and ShiZhiId = ssgx.ZhiId3)
	  or (ShiGanId = ssgx.GanId4 and ShiZhiId = ssgx.ZhiId4));


	/*月支查干*/
    drop temporary table if exists bz ;
	create temporary table
bz as 
( 
    select GanZhiTypeId,GanId,ZhiId from dBaZi  where MingZhuId = MingZhuId and GanZhiTypeId in (1,2,3,4)
) ;

insert into mingzhuss
select distinct t.mingzhuid,t.skeyid as ShengShaId,bz.GanZhiTypeId,t.snote as Remark from (
select mz.mingzhuid,ssgx.*from dMingZhu mz,zsetting ssgx
inner join dBaZi bz1 on bz1.MingZhuId = MingZhuId and bz1.GanZhiTypeId in (1,2,3,4) and bz1.ganid=ganid1
inner join dBaZi bz2 on bz2.MingZhuId = MingZhuId and bz2.GanZhiTypeId in (1,2,3,4) and bz2.ganid=ganid2
where  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=20
and mz.mingzhuid=MingZhuId and  (mz.yuezhiid=ssgx.zhiid1 or mz.yuezhiid=ssgx.zhiid2 or mz.yuezhiid=ssgx.zhiid3 )
) as t,bz
where (bz.GanId=t.GanId3 or  bz.GanId=t.GanId4);

	/*月支查日柱 */
	insert into mingzhuss
	select  distinct mz.MingZhuId,ssgx.skeyid as ShengShaId,3 as GanZhiTypeId,ssgx.snote as Remark
/*ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha */
from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=14
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and RiGanId = ssgx.GanId4 and RiZhiId = ssgx.ZhiId4;

	/*月支查四柱*/
	insert into mingzhuss
	select distinct t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
/*,t1.Ganid,t1.Zhiid,t2.Remark,t2.ganid1,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,ShengSha*/
 from (
select MingZhuId ,GanZhiTypeId,ganid,zhiid from dBaZi bz where ganzhitypeid in (1,2,3,4) ) as t1
,(select MingZhuId,ganid,zhiid,ganid1,zhiid1,zhiid2,zhiid3,zhiid4,snote as remark,skeyid as shengshaId
from dBaZi bz, zsetting ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=8
 and (bz.zhiid=ss1.zhiid1  or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3 ) 
and  mingzhuid= MingZhuId and ganzhitypeid in (2) ) as t2
where t1.mingzhuid= MingZhuId and t1.mingzhuid=t2.mingzhuid and 
 (t1.ganid = t2.ganid1 or t1.zhiid=t2.zhiid4) order by t1.GanZhiTypeId;

	/*以月支查四柱干支相合者*/
	insert into mingzhuss
	select distinct t1.MingZhuId
/*,t1.Ganid,t1.Zhiid,t2.ganid1,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,ganid5,zhiid5 */
,case t2.shengshaid when 3 then 5 when 4 then 6 end as shengshaId,t1.GanZhiTypeId
,concat(trim(t2.Remark),',',trim(remark2))  as remark from (
select MingZhuId ,GanZhiTypeId,ganid,zhiid from dBaZi bz where ganzhitypeid in (1,2,3,4) ) as t1
,(select MingZhuId,ganid,zhiid,ganid1,zhiid1,zhiid2,zhiid3,zhiid4,ganid5,zhiid5,snote as remark,remark2,skeyid as shengshaid
from dBaZi bz, 
( select ssgx.*
	 ,case when ssgx.ganid1=ggx.ganzhiid1 then ggx.ganzhiid2 else ggx.ganzhiid1 end as ganid5
	 ,case when ssgx.zhiid4=zgx.ganzhiid1 then zgx.ganzhiid2 else zgx.ganzhiid1 end as zhiid5
	 ,ifnull(ggx.remark,zgx.remark) as remark2
	  from zsetting ssgx
	  left join vganzhigx ggx on  (ssgx.ganid1= ggx.GanzhiId1 or ssgx.ganid1= ggx.GanzhiId2 ) and ggx.ganzhigxid=1
	  left join vganzhigx zgx on  (ssgx.zhiid4 = zgx.GanzhiId1 or ssgx.zhiid4 = zgx.GanzhiId2) and zgx.ganzhigxid=1
	  where ssgx.skey like 'bzshengsha%'  and skeyid  in (3,4)
) as  ss1  where (bz.zhiid=ss1.zhiid1  or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3 ) 
and  bz.mingzhuid= MingZhuId and ganzhitypeid in (2) ) as t2
where t1.mingzhuid= MingZhuId and t1.mingzhuid=t2.mingzhuid and 
 (t1.ganid = t2.ganid5 or t1.zhiid=t2.zhiid5) order by t1.GanZhiTypeId;

    select * from mingzhuss;
    delete from dmingzhuss where dmingzhuss.MingZhuId = MingZhuId;
	insert into dmingzhuss(MingZhuId,ShengShaId,GanZhiTypeId,Remark) select * from mingzhuss;
    drop table mingzhuss;
    drop table bz;


END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzPaiPanAll
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzPaiPanAll`()
BEGIN
    /* import csv data to table tmingzhu 
    
    LOAD DATA INFILE 'D:\Temp\mingzhu.csv'
	INTO TABLE tMingZhu 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
    call pzPaiPanAll()           */
	declare MingZhu varchar(50);declare XingBie varchar(1);declare Year int;declare Month int;declare Day int;
    declare Hour int;declare Minute int;declare IsLeapMonth int;declare IsLunar int;declare Note int;
    declare m_done int default 0;

   declare mzs cursor for select *  from tmingzhu mz ;
   declare continue handler for not found set m_done = 1;
   
   
   open mzs; /*开启游标 */
   while m_done=0 do /*取值 */
	 fetch  mzs into MingZhu,XingBie,Year,Month,Day,Hour,Minute,IsLeapMonth,IsLunar,Note; /*这样就将游标指向下一行，得到的第一行值就传给变量了 */
       call pzAddMingZhu(MingZhu,XingBie,Year,Month,Day,Hour,Minute,IsLeapMonth,IsLunar,Note);
	  end while;
   close mzs; /*关闭游标 */

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure pzwPaiPan
-- -----------------------------------------------------

DELIMITER $$
USE `sm`$$
CREATE DEFINER=`root`@`%` PROCEDURE `pzwPaiPan`(
    IN MingZhuId int)
BEGIN
    /*  给某命主排紫薇盘: call pzwPaiPan(12)           */
    declare PaiPanTypeId int; declare MGZhiId int;declare SGZhiId int;
    declare Yu int;declare Shang int;declare ZiWeiZhiId int;declare StartZhiId int;
    declare TianFuZhiId int;
    declare LuCunZhiId int;
    declare HuoStartZhiId int;declare LingStartZhiId int;
	declare JieKongZhiId int;declare JieKongZhiId1 int;declare JieKongZhiId2 int;
	declare HuaGaiZhiId int;
	declare ChangShengStartZhiId int;
	declare BoShieStartZhiId int;
	declare JiangQianStartZhiId int;
    declare WenChangZhiId int;declare WenQuZhiId int;
	declare ZuoFuZhiId int;declare YouBiZhiId int;
    select @NongLiYue:=NongLiYue,@NianGanId:=NianGanId,@NianZhiId:=NianZhiId,@NongLiRi:=NongLiRi,@ShiZhiId:=ShiZhiId ,@IsShun=IsShun from dmingzhu mz where mz.mingzhuid=MingZhuId;

    delete from dziweixingyao where ziweiid in (select ziweiid from dziwei where dziwei.mingzhuid=MingZhuId);
	delete from dziwei  where dziwei.mingzhuid=MingZhuId ;
	/*命盘 */
    set PaiPanTypeId =1;
	if PaiPanTypeId =1 then
		delete from dZiWeiXingYao where dZiWeiXingYao.ZiWeiId in (select ZiWeiId from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId);
		delete from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId;
		delete from dMingZhuZWAdd  where dMingZhuZWAdd.MingZhuId=MingZhuId;

		/*1.定命身宫 */
		set MGZhiId = fGanZhiOffset(@NongLiYue+2,@ShiZhiId,0,0);
		set SGZhiId = fGanZhiOffset(@NongLiYue+2,@ShiZhiId,1,0);
	
		drop temporary table if exists tmptb ;
		create temporary table tmptb(GongWeiId int, GanId int,ZhiId int);
		
		/*2.定十二宫 */
	   INSERT INTO tmptb(GongWeiId,ZhiId) select SKeyId as GongWeiId, fGanZhiOffset(MGZhiId,SKeyId,1,0) as ZhiId from zsuanming gw where gw.skey='zwGongWei' and gw.SKeyId<13;

		/*3.安十二宫天干 */
		Update tmptb inner join vNianToYue ny on   tmptb.ZhiId = ny.YueZhiId  set GanId=ny.YueGanId 
		where (ny.GanId1 = @NianGanId or ny.GanId2 = @NianGanId);
		

		/*select g.Gan,z.Zhi,* from tmptb tb */
		/*left join wGongWei gw on tb.GongWeiId = gw.GongWeiId */
		/*left join zGan g on tb.GanId = g.GanId */
		/*left join zZhi z on tb.ZhiId = z.ZhiId */
		insert into dZiWei(MingZhuId,PaiPanTypeId,GongWeiId,GanId,ZhiId)
		select MingZhuId,PaiPanTypeId,tb.GongWeiId,tb.GanId,tb.ZhiId from tmptb tb where not exists
		(select 1 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId);

		/*身宫 */
		update dZiWei set IsShengGong = 1 where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId
		and SGZhiId=dZiWei.ZhiId;


		/*4.定五行局 */
		select @JuShu:=wh.JuShu,@WuHangId := wh.WuHangId from vJiaZi jz 
		inner join tmptb tb on tb.GongWeiId =1 and jz.JiaZiGanid = tb.GanId and jz.jiaziZhiId=tb.zhiid
		left join zWuHang wh on wh.WuHangId = jz.wuhangid;

		select @YueGanId:=YueGanId,@YueZhiId:=YueZhiId from vNianToYue where yuezhiid=fGanZhiOffset (@NongLiYue,3,1,0)
		and (Ganid1=@NianGanId or Ganid2=@NianGanId);

		insert into dMingZhuZWAdd(mingzhuid,wuhangid,YueGanId,yuezhiid) values(MingZhuId,@WuHangId,@YueGanId,@YueZhiId);
	 

		/*5.起大限 */
		if @IsShun = 1 then
		  update dZiWei inner join zsuanming gw on mingzhuid=MingZhuId and gw.skey='zwGongWei' and dZiWei.GongWeiId=gw.SKeyId set DaXianFrom = @JuShu+(gw.SKeyId-1)*10,DaXianTo=@JuShu+(gw.SKeyId-1)*10+9 ;
		else
		  update dZiWei inner join zsuanming gw   on gw.skeyid=dZiWei.GongWeiId and gw.skey='zwGongWei' and dZiWei.GongWeiId=gw.SKeyId 
		  inner join zsuanming gw2 on  gw.svalue=gw2.svalue and gw2.skey='zwGongWeiNi' 
		  set DaXianFrom = @JuShu+(gw2.SKeyId-1)*10,DaXianTo=@JuShu+(gw2.SKeyId-1)*10+9 
		  where mingzhuid=MingZhuId;
		end if;
		

		/*6.起紫薇星 */
		set Yu = @NongLiRi%@JuShu;
		set Shang=@NongLiRi/@JuShu;
		if Yu = 0 then
			set ZiWeiZhiId = 3 ;  /* 寅宫 */
		else 
			if (@JuShu=2 and Yu=1) or (@JuShu=3 and Yu=2) or  (@JuShu=4 and Yu=3) or (@JuShu=5 and Yu=4) or (@JuShu=6 and Yu=5) then
				 set StartZhiId = 2 ;   /* 丑宫 */
			elseif (@JuShu=3 and Yu=1) or (@JuShu=4 and Yu=2) or  (@JuShu=5 and Yu=3) or (@JuShu=6 and Yu=4) then
				 set StartZhiId = 5 ;   /* 辰宫 */
			elseif (@JuShu=4 and Yu=1) or (@JuShu=5 and Yu=2) or  (@JuShu=6 and Yu=3) then
				 set StartZhiId = 12 ;   /* 亥宫 */
			elseif (@JuShu=5 and Yu=1) or (@JuShu=6 and Yu=2) then
				 set StartZhiId = 7;    /* 午宫 */
			elseif (@JuShu=6 and Yu=1) then
				 set StartZhiId = 10 ;  /* 酉宫 */
			end if;
			 set ZiWeiZhiId = fGanZhiOffset(StartZhiId,Shang,1,0);
		end if;	
		/*select StartZhiId,ZiWeiZhiId,Shang,Yu,@JuShu;  */

		/*7.安天府 */
		if ZiWeiZhiId = 3 or ZiWeiZhiId = 9 then
		 set TianFuZhiId = ZiWeiZhiId;
		else
		   if ZiWeiZhiId < 6 then
			set TianFuZhiId = 6-ZiWeiZhiId ; 
		   else
			set TianFuZhiId = 18-ZiWeiZhiId ;
		   end if;
		end if;
		/*select ZiWeiZhiId,TianFuZhiId

		/*8.安十四正曜 */
		delete from dZiWeiXingYao where ZiWeiId in (select ZiWeiId from dZiWei where MingZhuId=MingZhuId and PaiPanTypeId=PaiPanTypeId);
		/*紫薇 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,1 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=ZiWeiZhiId;
		/*天机 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,2 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(ZiWeiZhiId,2,0,0);
		/*太阳 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,3 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(ZiWeiZhiId,4,0,0);  
		/*武曲 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,4 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(ZiWeiZhiId,5,0,0);  
		/*天同 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,5 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(ZiWeiZhiId,6,0,0);  
		/*廉贞 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,6 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(ZiWeiZhiId,9,0,0);  
		/*天府 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,7 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=TianFuZhiId; 
		/*太阴 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,8 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,2,1,0);
		/*贪狼 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,9 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,3,1,0);
		/*巨门 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,10 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,4,1,0);
		/*天相 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,11 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,5,1,0);
		/*天梁 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,12 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,6,1,0);
		/*七杀 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,13 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,7,1,0);
		/*破军 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,14 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(TianFuZhiId,11,1,0);
		
		/*9.左辅右弼 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,19 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(5,@NongLiYue,1,0);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,20 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(11,@NongLiYue,0,0);
		
		/*文曲文昌 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,23 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(11,@ShiZhiId,0,0);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,24 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(5,@ShiZhiId,1,0);
		
		/*地劫地空 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,27 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(12,@ShiZhiId,1,0);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,28 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId=fGanZhiOffset(12,@ShiZhiId,0,0);

		/*10.安四化星 */
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId
		set HuaLuXYId=sh.XingYaoId  where sh.SiHuaId=1;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId
		set HuaQuanXYId=sh.XingYaoId  where sh.SiHuaId=2;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId
		set HuaKeXYId=sh.XingYaoId  where sh.SiHuaId=3;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId
		set HuaJiXYId=sh.XingYaoId  where sh.SiHuaId=4;

		/*安四化星宫位 */
		update dZiWei inner join  (
		select dZiWei.ZiWeiId ,zwhl.GongWeiId as HLGongWeiId, zwhq.GongWeiId as HQGongWeiId
		,zwhk.GongWeiId as HKGongWeiId,zwhj.GongWeiId as HJGongWeiId from dZiWei
		inner join dZiWeiXingYao zwxyhl on dZiWei.HuaLuXYId = zwxyhl.XingYaoId
		inner join dZiWei zwhl on zwhl.ZiWeiId = zwxyhl.ZiWeiId and zwhl.MingZhuId=MingZhuId and zwhl.PaiPanTypeId=PaiPanTypeId
		inner join dZiWeiXingYao zwxyhq on dZiWei.HuaQuanXYId = zwxyhq.XingYaoId
		inner join dZiWei zwhq on zwhq.ZiWeiId = zwxyhq.ZiWeiId and zwhq.MingZhuId=MingZhuId and zwhq.PaiPanTypeId=PaiPanTypeId
		inner join dZiWeiXingYao zwxyhk on dZiWei.HuaKeXYId = zwxyhk.XingYaoId
		inner join dZiWei zwhk on zwhk.ZiWeiId = zwxyhk.ZiWeiId and zwhk.MingZhuId=MingZhuId and zwhk.PaiPanTypeId=PaiPanTypeId
		inner join dZiWeiXingYao zwxyhj on dZiWei.HuaJiXYId = zwxyhj.XingYaoId
		inner join dZiWei zwhj on zwhj.ZiWeiId = zwxyhj.ZiWeiId and zwhj.MingZhuId=MingZhuId and zwhj.PaiPanTypeId=PaiPanTypeId
		where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId 
		) as t on dZiWei.ZiWeiId = t.ZiWeiId
		set HuaLuGWId=t.HLGongWeiId,HuaQuanGWId=t.HQGongWeiId
		,HuaKeGWId=t.HKGongWeiId,HuaJiGWId=t.HJGongWeiId 
        where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId;


		/*TypeId '1' : 依年干定,'2':依年支定,'3':从某宫起年支,'4':某宫起月份,'5':依月份定 */
		/*11.天魁,天钺,12.禄存,14.天福,天官,15.天厨 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=1 and zw.ZhiId = s.ZhiId1
		and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId 
		and ( s.GanId1=@NianGanId or s.GanId2=@NianGanId or s.GanId3=@NianGanId or s.GanId4=@NianGanId);
		
		/*18.天马,21.孤辰,寡宿,24.蜚廉,华盖,破碎,咸池 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=2 and s.skey not in ('zwHuoXing','zwLingXing') 
		and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId 
		and zw.ZhiId = s.ZhiId4 and ( s.ZhiId1=@NianZhiId or s.ZhiId2=@NianZhiId or s.ZhiId3=@NianZhiId);

		/*19.天哭,天虚,20.红鸾,天喜,24.龙德,月德,25.年德,天德,27.龙池,凤阁, */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=3 
		and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId 
		and zw.ZhiId = fGanZhiOffset(s.ZhiId1,@NianZhiId,s.ShunNi,0);

		/*29.天刑,天姚 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=4
		and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId 
		and zw.ZhiId = fGanZhiOffset(s.ZhiId1,@NongLiYue,s.ShunNi,0);

		/*30.解神,天巫,31.天月,32.阴煞 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=5
		and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId 
		and zw.ZhiId = s.ZhiId4 and ( s.ZhiId1=@NongLiYue or s.ZhiId2=@NongLiYue or s.ZhiId3=@NongLiYue);

		/*return */

		/*12.定羊，陀 */
		select LuCunZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=25;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,17 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(LuCunZhiId,2,1,0); 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,18 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(LuCunZhiId,2,0,0); 

		/*13.定火星，铃星 */
		select @HuoStartZhiId:=ZhiId4 from zSetting where skey='zwHuoXing' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId);
		select @LingStartZhiId:=ZhiId4 from zSetting where skey='zwLingXing' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,15 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(@HuoStartZhiId,@ShiZhiId,1,0) ;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,16 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(@LingStartZhiId,@ShiZhiId,1,0); 

		/*16.安截空 */

		select JieKongZhiId1=ZhiId1,JieKongZhiId2=ZhiId2 from zSetting where skey='zwJieKong' and (GanId1=@NianGanId or GanId2=@NianGanId);
		if @NianGanId%2 = JieKongZhiId1%2 then set JieKongZhiId=JieKongZhiId1; end if;
		if @NianGanId%2 = JieKongZhiId2%2 then set JieKongZhiId=JieKongZhiId2; end if;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,48 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = JieKongZhiId;

		/*17.安旬空？ */
		/*18.安天空 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,46 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(@NianZhiId,2,1,0); 
		/*22.安劫煞 */

		select HuaGaiZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=39;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,116 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(HuaGaiZhiId,2,0,0); 
		/*23.安大耗？ */
		/*26.安天才天寿 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,40 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(MGZhiId,@NianZhiId,1,0); 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,41 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(SGZhiId,@NianZhiId,1,0); 
		/*28.安台辅封诰 */
		select WenChangZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=23;
		select WenQuZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=24;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,56 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(WenQuZhiId,3,1,0); 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,57 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(WenQuZhiId,3,0,0); 
		/*33.安伤使 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw.ZiWeiId,117 from dZiWei zw where  zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.GongWeiId = (case @IsShun when 1 then 6  when 0 then 8 end);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw.ZiWeiId,118 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.GongWeiId = (case @IsShun when 1 then 8  when 0 then 6 end);
		/*34.安三台八座 */
		select ZuoFuZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=19;
		select YouBiZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=20;
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,58 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(ZuoFuZhiId,@NongLiRi,1,0); 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,59 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(YouBiZhiId,@NongLiRi,0,0); 
		/*34.安恩光天贵 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,60 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(WenChangZhiId,@NongLiRi-1,1,0); 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select ZiWeiId,61 from dZiWei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId and zw.ZhiId = fGanZhiOffset(WenQuZhiId,@NongLiRi-1,1,0); 
		/*36.安命主 */
		/*37.安身主 */
		/*38.安长生十二神 */

		if @JuShu = 2 or @JuShu = 5 then set  ChangShengStartZhiId = 9; end if;
		if @JuShu = 4 then set  ChangShengStartZhiId = 6; end if;
		if @JuShu = 6 then set  ChangShengStartZhiId = 3; end if;
		if @JuShu = 3 then set  ChangShengStartZhiId = 12; end if;
		/*insert into dZiWeiXingYao(ZiWeiId,XingYaoId) */
		select zw.ZiWeiId,xy.SKeyId from dZiWei zw,zsuanming xy where  xy.skey='zwXingYao' and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId
		and  xy.sTypeId=5 and zw.ZhiId = fGanZhiOffset(ChangShengStartZhiId,xy.SKeyId-65,@IsShun,0) ;

		/*41.安生年博士十二神? */

		select BoShieStartZhiId = ganzhiid2 from vGanZhiGX where gxtypeid=4 and ganzhiid1=@NianGanId and gxvalue='临官' ;
		/*insert into dZiWeiXingYao(ZiWeiId,XingYaoId)  */
		select zw.ZiWeiId,xy.SKeyId from dZiWei zw,zsuanming xy where  xy.skey='zwXingYao' and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId
		and  xy.sTypeId=8 and zw.ZhiId = fGanZhiOffset(BoShieStartZhiId,xy.SKeyId-101,@IsShun,0) ;

		/*39.安太岁十二神 */
		/*insert into dZiWeiXingYao(ZiWeiId,XingYaoId)  */
		select zw.ZiWeiId,xy.SKeyId from dZiWei zw,zsuanming xy where  xy.skey='zwXingYao' and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId
		and  xy.sTypeId=6 and zw.ZhiId = fGanZhiOffset(@NianZhiId,xy.SKeyId-77,1,0) ;
		
		/*40.安将前诸星 */
		select @JiangQianStartZhiId:=ZhiId4 from zSetting where skey='zwJiangQian' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId);
		/*insert into dZiWeiXingYao(ZiWeiId,XingYaoId)  */
		select zw.ZiWeiId,xy.SKeyId from dZiWei zw,zsuanming xy where  xy.skey='zwXingYao' and zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId
		and  xy.sTypeId=7 and zw.ZhiId = fGanZhiOffset(JiangQianStartZhiId,xy.SKeyId-89,1,0) ;

	 
		drop table tmptb;
    end if;
    
    /* 大限   */
    set PaiPanTypeId =2;
    if PaiPanTypeId =2 then
    	delete from dZiWeiXingYao where dZiWeiXingYao.ZiWeiId in (select ZiWeiId from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId);
		delete from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId;
        
        insert into dziwei(MingZhuId,paiPanTypeId,GongWeiId,GanId,ZhiId,HuaLuXYId,HuaLuGWId,HuaQuanXYId,HuaQuanGWId,HuaKeXyId,HuaKeGWId,HuaJiXYId,HuaJiGWId,DaXianFrom,DaXianTo,DaXian)
        select MingZhuId,paiPanTypeId,fGanZhiOffset(GongWeiId,dx.daxian+1,not(@IsShun),0),GanId,ZhiId,HuaLuXYId,fGanZhiOffset(HuaLuGWId,dx.daxian+1,not(@IsShun),0),HuaQuanXYId,fGanZhiOffset(HuaQuanGWId,dx.daxian+1,not(@IsShun),0)
			,HuaKeXyId,fGanZhiOffset(HuaKeGWId,dx.daxian+1,not(@IsShun),0),HuaJiXYId,fGanZhiOffset(HuaJiGWId,dx.daxian+1,not(@IsShun),0),@JuShu +(dx.DaXian-1)*10,@JuShu+(dx.DaXian-1)*10+9,dx.daxian from (
		select 1 as daxian  union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8) as dx
		,dziwei zw where zw.MingZhuId=12 and zw.PaiPanTypeId=1;
        
        /*TypeId '1' : 依年干定,'2':依年支定,'3':从某宫起年支,'4':某宫起月份,'5':依月份定,'6':干定支 */
			/*运禄存,羊，陀 */

		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,120 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = s.ZhiId1
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,119 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,2,1,0)
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,121 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,2,0,0)
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
            
		/*运昌曲 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,124 from dZiWei zw,dZiWei zw2,zsetting sz where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and sz.GanId1= zw.GanId and zw2.ZhiId = sz.ZhiId1
		and skey='zwLiuChang'; 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,125 from dZiWei zw,dZiWei zw2,zsetting sz where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and sz.GanId1= zw.GanId and zw2.ZhiId = sz.ZhiId1
		and skey='zwLiuQu'; 
		
		/*运魁钺 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,122 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and s.skey='zwTianKui' and zw2.ZhiId = s.ZhiId1
		and (s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,123 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and s.skey='zwTianYue' and zw2.ZhiId = s.ZhiId1
		and (s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		/*运马 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,126 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and s.skey='zwTianMa' and zw2.ZhiId = s.ZhiId4
		and ( s.ZhiId1=zw.ZhiId or s.ZhiId2=zw.ZhiId or s.ZhiId3=zw.ZhiId);
		
		/*运鸾,运喜*/
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,127 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and s.skey='zwHongLuan' and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,zw.ZhiId,s.ShunNi,0);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,128 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.daxian=zw2.daxian and s.skey='zwTianXi' and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,zw.ZhiId,s.ShunNi,0);

    end if;
    
    /* 流年   */
    set PaiPanTypeId =3;
    if PaiPanTypeId =3 then
    	delete from dZiWeiXingYao where dZiWeiXingYao.ZiWeiId in (select ZiWeiId from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId);
		delete from dZiWei where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId=PaiPanTypeId;
        
        insert into dziwei(MingZhuId,PaiPanTypeId,Year,GanId,ZhiId,DaXianFrom,DaXianTo,DaXian)
         select MingZhuId,3,idx+1984-1 as Year,fGanZhiOffset(1,idx,1,1) as GanId,fGanZhiOffset(1,idx,1,0) as ZhiId,@JuShu +(idx-1)*10,@JuShu+(idx-1)*10+9,idx as DaXian from (
         select  * from (select 1 as idx  union select 2 union select 3 union select 4 union select 5 union select 6 ) as t1 where idx<5
		union
		select idx+5-1 from (
		select t2.idx+(t1.idx-1)*10 as idx from (
		select 1 as idx  union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8) as t1
		cross join 
		 (select 1 as idx  union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9 union select 10) as t2
		 ) as t3 order by idx) as ln;
           
        insert into dziwei(MingZhuId,paiPanTypeId,GongWeiId,GanId,ZhiId,Year,DaXianFrom,DaXianTo,DaXian) 
        select MingZhuId,4,t5.GongWeiId,ny.YueGanId as GanId,t5.ZhiId,t5.Year,@JuShu +(t5.DaXian-1)*10,@JuShu+(t5.DaXian-1)*10+9,t5.DaXian from (
		select t4.GongWeiId,t4.year,fGanZhiOffset(zw2.ZhiId+t4.DaXian-1,t4.GongWeiId,1,0) as ZhiId,t4.DaXian from (        
		select zw.GongWeiId,zwy.year,zwy.daxian from dZiWei zwy,dziwei zw where zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=1 and zwy.PaiPanTypeId=3 and zwy.MingZhuId=MingZhuId
		 ) as t4,dziwei zw2 where zw2.MingZhuId=MingZhuId and zw2.PaiPanTypeId=1 and zw2.ZhiId=@NianZhiId
		 ) as t5,vNianToYue ny where t5.ZhiId = ny.YueZhiId and (ny.GanId1 = @NianGanId or ny.GanId2 = @NianGanId)
		 order by t5.Year,t5.GongWeiId;

        /*安四化星 */
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4)
		set HuaLuXYId=sh.XingYaoId  where sh.SiHuaId=1;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4)
		set HuaQuanXYId=sh.XingYaoId  where sh.SiHuaId=2;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4)
		set HuaKeXYId=sh.XingYaoId  where sh.SiHuaId=3;
		update dZiWei inner join zwgansihua sh on dZiWei.GanId=sh.GanId 
		and dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4)
		set HuaJiXYId=sh.XingYaoId  where sh.SiHuaId=4;

		/*安四化星宫位 */
		update dZiWei inner join  (
		select distinct dZiWei.ZiWeiId ,zwhl.GongWeiId as HLGongWeiId , zwhq.GongWeiId as HQGongWeiId
        ,zwhk.GongWeiId as HKGongWeiId,zwhj.GongWeiId as HJGongWeiId from dZiWei
        inner join dZiWei zw on zw.MingZhuId=MingZhuId and zw.PaiPanTypeId=1
        inner join dZiWei zw2 on zw2.MingZhuId=MingZhuId and zw2.PaiPanTypeId=1 and zw2.GongWeiId=zw.HuaLuGWId
		inner join dZiWei zwhl on zwhl.MingZhuId=MingZhuId and zwhl.PaiPanTypeId=4 and zwhl.year=dZiWei.year 
        and zw2.ganid=zwhl.ganid and zw2.zhiid=zwhl.zhiid and dZiWei.HuaLuXYId=zw.HuaLuXYId
        
        inner join dZiWei zw3 on zw3.MingZhuId=MingZhuId and zw3.PaiPanTypeId=1 and zw3.GongWeiId=zw.HuaQuanGWId
		inner join dZiWei zwhq on zwhq.MingZhuId=MingZhuId and zwhq.PaiPanTypeId=4 and zwhq.year=dZiWei.year 
        and zw3.ganid=zwhq.ganid and zw3.zhiid=zwhq.zhiid and dZiWei.HuaQuanXYId=zw.HuaQuanXYId
        
        inner join dZiWei zw4 on zw4.MingZhuId=MingZhuId and zw4.PaiPanTypeId=1 and zw4.GongWeiId=zw.HuaKeGWId
		inner join dZiWei zwhk on zwhk.MingZhuId=MingZhuId and zwhk.PaiPanTypeId=4 and zwhk.year=dZiWei.year 
        and zw4.ganid=zwhk.ganid and zw4.zhiid=zwhk.zhiid and dZiWei.HuaKeXYId=zw.HuaKeXYId
     
        inner join dZiWei zw5 on zw5.MingZhuId=MingZhuId and zw5.PaiPanTypeId=1 and zw5.GongWeiId=zw.HuaJiGWId
		inner join dZiWei zwhj on zwhj.MingZhuId=MingZhuId and zwhj.PaiPanTypeId=4 and zwhj.year=dZiWei.year 
        and zw5.ganid=zwhj.ganid and zw5.zhiid=zwhj.zhiid and dZiWei.HuaJiXYId=zw.HuaJiXYId
        
		where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4)
		) as t on dZiWei.ZiWeiId = t.ZiWeiId
		set HuaLuGWId=t.HLGongWeiId,HuaQuanGWId=t.HQGongWeiId,HuaKeGWId=t.HKGongWeiId,HuaJiGWId=t.HJGongWeiId 
        where dZiWei.MingZhuId=MingZhuId and dZiWei.PaiPanTypeId in (3,4);


        /*TypeId '1' : 依年干定,'2':依年支定,'3':从某宫起年支,'4':某宫起月份,'5':依月份定,'6':干定支 */
		/*流禄存,羊，陀 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,130 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = s.ZhiId1
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,129 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,2,1,0)
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,131 from dZiWei zw ,dZiWei zw2 ,zSetting s where s.XingYaoId=25 and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,2,0,0)
		and zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=PaiPanTypeId  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year
		and ( s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
            
		/*流昌曲 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,114 from dZiWei zw,dZiWei zw2,zsetting sz where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and sz.GanId1= zw.GanId and zw2.ZhiId = sz.ZhiId1
		and skey='zwLiuChang'; 
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,115 from dZiWei zw,dZiWei zw2,zsetting sz where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and sz.GanId1= zw.GanId and zw2.ZhiId = sz.ZhiId1
		and skey='zwLiuQu'; 
		
		/*流魁钺 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,132 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and s.skey='zwTianKui' and zw2.ZhiId = s.ZhiId1
		and (s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,133 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and s.skey='zwTianYue' and zw2.ZhiId = s.ZhiId1
		and (s.GanId1=zw.GanId or s.GanId2=zw.GanId or s.GanId3=zw.GanId or s.GanId4=zw.GanId);
		
		/*流马 */
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,134 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and s.skey='zwTianMa' and zw2.ZhiId = s.ZhiId4
		and ( s.ZhiId1=zw.ZhiId or s.ZhiId2=zw.ZhiId or s.ZhiId3=zw.ZhiId);
		
		/*流鸾,运喜*/
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,135 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and s.skey='zwHongLuan' and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,zw.ZhiId,s.ShunNi,0);
		
		insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
		select zw2.ZiWeiId,136 from dZiWei zw,dZiWei zw2,zsetting s where zw.MingZhuId=MingZhuId and zw2.MingZhuId=MingZhuId and zw.PaiPanTypeId=4  and zw2.PaiPanTypeId=PaiPanTypeId
		and zw.GongWeiId=1 and zw.year=zw2.year and s.skey='zwTianXi' and zw2.ZhiId = fGanZhiOffset(s.ZhiId1,zw.ZhiId,s.ShunNi,0);

    end if;
    

END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `sm`.`vbazi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vbazi`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vbazi` AS select `mz`.`MingZhuId` AS `MingZhuId`,`mz`.`MingZhu` AS `MingZhu`,`mz`.`XingBie` AS `XingBie`,`mz`.`GongLi` AS `GongLi`,`mz`.`NongLi` AS `NongLi`,concat(`dybz`.`Year`,'-',(`dybz`.`Year` + 9)) AS `DYPeriod`,concat((`dybz`.`Year` - `mz`.`GongLiNian`),'-',((`dybz`.`Year` - `mz`.`GongLiNian`) + 9)) AS `DYSui`,`dygss`.`SValue` AS `DYGSS`,`dyg`.`Gan` AS `DYGan`,`dyz`.`Zhi` AS `DYZhi`,`dyzcg1`.`Gan` AS `DYZCG1`,`dyzcg2`.`Gan` AS `DYZCG2`,`dyzcg3`.`Gan` AS `DYZCG3`,`dyzcgss1`.`SValue` AS `DYZCSS1`,`dyzcgss2`.`SValue` AS `DYZCSS2`,`dyzcgss3`.`SValue` AS `DYZCSS3`,`dyg`.`GanId` AS `DYGanId`,`dyz`.`ZhiId` AS `DYZhiId`,`dyzcg1`.`GanId` AS `DYZCGId1`,`dyzcg2`.`GanId` AS `DYZCGId2`,`dyzcg3`.`GanId` AS `DYZCGId3`,`gzt`.`SKeyId` AS `GanZhiTypeId`,`gzt`.`SValue` AS `GanZhiType`,`bz`.`Year` AS `Year`,`gss`.`SValue` AS `GSS`,`g`.`Gan` AS `Gan`,`z`.`Zhi` AS `Zhi`,`zcg1`.`Gan` AS `ZCG1`,`zcg2`.`Gan` AS `ZCG2`,`zcg3`.`Gan` AS `ZCG3`,`zcgss1`.`SValue` AS `ZCSS1`,`zcgss2`.`SValue` AS `ZCSS2`,`zcgss3`.`SValue` AS `ZCSS3`,`g`.`GanId` AS `LGanId`,`z`.`ZhiId` AS `LZhiId`,`zcg1`.`GanId` AS `ZCGId1`,`zcg2`.`GanId` AS `ZCGId2`,`zcg3`.`GanId` AS `ZCGId3` from (((((((((((((((((((((`sm`.`dbazi` `bz` join `sm`.`dmingzhu` `mz` on((`bz`.`MingZhuId` = `mz`.`MingZhuId`))) join `sm`.`zsuanming` `gzt` on(((`gzt`.`SKey` = 'bzGanZhiType') and (`bz`.`GanZhiTypeId` = `gzt`.`SKeyId`)))) left join `sm`.`zsuanming` `gss` on(((`gss`.`SKey` = 'bzShiSheng') and (`bz`.`GanSSId` = `gss`.`SKeyId`)))) left join `sm`.`zgan` `g` on((`bz`.`GanId` = `g`.`GanId`))) left join `sm`.`zzhi` `z` on((`bz`.`ZhiId` = `z`.`ZhiId`))) left join `sm`.`zgan` `zcg1` on((`bz`.`ZhiCGanId1` = `zcg1`.`GanId`))) left join `sm`.`zgan` `zcg2` on((`bz`.`ZhiCGanId2` = `zcg2`.`GanId`))) left join `sm`.`zgan` `zcg3` on((`bz`.`ZhiCGanId3` = `zcg3`.`GanId`))) left join `sm`.`zsuanming` `zcgss1` on(((`zcgss1`.`SKey` = 'bzShiSheng') and (`bz`.`ZhiSSId1` = `zcgss1`.`SKeyId`)))) left join `sm`.`zsuanming` `zcgss2` on(((`zcgss2`.`SKey` = 'bzShiSheng') and (`bz`.`ZhiSSId2` = `zcgss2`.`SKeyId`)))) left join `sm`.`zsuanming` `zcgss3` on(((`zcgss3`.`SKey` = 'bzShiSheng') and (`bz`.`ZhiSSId3` = `zcgss3`.`SKeyId`)))) left join `sm`.`dbazi` `dybz` on(((`bz`.`BaZiRefId` = `dybz`.`BaZiId`) and (`dybz`.`GanZhiTypeId` = 5)))) left join `sm`.`zgan` `dyg` on((`dybz`.`GanId` = `dyg`.`GanId`))) left join `sm`.`zzhi` `dyz` on((`dybz`.`ZhiId` = `dyz`.`ZhiId`))) left join `sm`.`zgan` `dyzcg1` on((`dybz`.`ZhiCGanId1` = `dyzcg1`.`GanId`))) left join `sm`.`zgan` `dyzcg2` on((`dybz`.`ZhiCGanId2` = `dyzcg2`.`GanId`))) left join `sm`.`zgan` `dyzcg3` on((`dybz`.`ZhiCGanId3` = `dyzcg3`.`GanId`))) left join `sm`.`zsuanming` `dygss` on(((`dygss`.`SKey` = 'bzShiSheng') and (`dybz`.`GanSSId` = `dygss`.`SKeyId`)))) left join `sm`.`zsuanming` `dyzcgss1` on(((`dyzcgss1`.`SKey` = 'bzShiSheng') and (`dybz`.`ZhiSSId1` = `dyzcgss1`.`SKeyId`)))) left join `sm`.`zsuanming` `dyzcgss2` on(((`dyzcgss2`.`SKey` = 'bzShiSheng') and (`dybz`.`ZhiSSId2` = `dyzcgss2`.`SKeyId`)))) left join `sm`.`zsuanming` `dyzcgss3` on(((`dyzcgss3`.`SKey` = 'bzShiSheng') and (`dybz`.`ZhiSSId3` = `dyzcgss3`.`SKeyId`)))) where (`gzt`.`SKeyId` in (1,2,3,4,7)) order by `bz`.`MingZhuId`,`gzt`.`SKeyId`,`bz`.`Year`;

-- -----------------------------------------------------
-- View `sm`.`vganzhigx`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vganzhigx`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vganzhigx` AS select `gzgxt`.`SValue` AS `GXType`,`gx`.`GXId` AS `GXId`,`gx`.`GXTypeId` AS `GXTypeId`,`gx`.`GanZhiId1` AS `GanZhiId1`,`gx`.`GanZhiId2` AS `GanZhiId2`,`gx`.`GanZhiId3` AS `GanZhiId3`,`gx`.`GanZhiGXId` AS `GanZhiGXId`,`gx`.`GXValueId` AS `GXValueId`,`gx`.`Remark` AS `Remark`,`g1`.`Gan` AS `GanZhi1`,`g2`.`Gan` AS `GanZhi2`,NULL AS `GanZhi3`,`gzgx`.`SValue` AS `GanZhiGX`,`wh`.`WuHang` AS `GXValue` from (((((`sm`.`zganzhigx` `gx` left join `sm`.`zsuanming` `gzgxt` on(((`gx`.`GXTypeId` = `gzgxt`.`SKeyId`) and (`gzgxt`.`SKey` = 'bzGanZhiGXType')))) left join `sm`.`zgan` `g1` on((`g1`.`GanId` = `gx`.`GanZhiId1`))) left join `sm`.`zgan` `g2` on((`g2`.`GanId` = `gx`.`GanZhiId2`))) left join `sm`.`zsuanming` `gzgx` on(((`gzgx`.`SKey` = 'bzGanZhiGX') and (`gx`.`GanZhiGXId` = `gzgx`.`SKeyId`)))) left join `sm`.`zwuhang` `wh` on((`wh`.`WuHangId` = `gx`.`GXValueId`))) where (`gx`.`GXTypeId` = 1) union select `gzgxt`.`SValue` AS `GXType`,`gx`.`GXId` AS `GXId`,`gx`.`GXTypeId` AS `GXTypeId`,`gx`.`GanZhiId1` AS `GanZhiId1`,`gx`.`GanZhiId2` AS `GanZhiId2`,`gx`.`GanZhiId3` AS `GanZhiId3`,`gx`.`GanZhiGXId` AS `GanZhiGXId`,`gx`.`GXValueId` AS `GXValueId`,`gx`.`Remark` AS `Remark`,`z1`.`Zhi` AS `GanZhi1`,`z2`.`Zhi` AS `GanZhi2`,`z3`.`Zhi` AS `GanZhi3`,`gzgx`.`SValue` AS `GanZhiGX`,`wh`.`WuHang` AS `GXValue` from ((((((`sm`.`zganzhigx` `gx` left join `sm`.`zsuanming` `gzgxt` on(((`gx`.`GXTypeId` = `gzgxt`.`SKeyId`) and (`gzgxt`.`SKey` = 'bzGanZhiGXType')))) left join `sm`.`zzhi` `z1` on((`z1`.`ZhiId` = `gx`.`GanZhiId1`))) left join `sm`.`zzhi` `z2` on((`z2`.`ZhiId` = `gx`.`GanZhiId2`))) left join `sm`.`zzhi` `z3` on((`z3`.`ZhiId` = `gx`.`GanZhiId3`))) left join `sm`.`zsuanming` `gzgx` on(((`gzgx`.`SKey` = 'bzGanZhiGX') and (`gx`.`GanZhiGXId` = `gzgx`.`SKeyId`)))) left join `sm`.`zwuhang` `wh` on((`wh`.`WuHangId` = `gx`.`GXValueId`))) where (`gx`.`GXTypeId` = 2) union select `gzgxt`.`SValue` AS `GXType`,`gx`.`GXId` AS `GXId`,`gx`.`GXTypeId` AS `GXTypeId`,`gx`.`GanZhiId1` AS `GanZhiId1`,`gx`.`GanZhiId2` AS `GanZhiId2`,`gx`.`GanZhiId3` AS `GanZhiId3`,`gx`.`GanZhiGXId` AS `GanZhiGXId`,`gx`.`GXValueId` AS `GXValueId`,`gx`.`Remark` AS `Remark`,`g1`.`Gan` AS `GanZhi1`,`g2`.`Gan` AS `GanZhi2`,NULL AS `GanZhi3`,NULL AS `GanZhiGX`,`ss`.`SValue` AS `GXValue` from ((((`sm`.`zganzhigx` `gx` left join `sm`.`zsuanming` `gzgxt` on(((`gx`.`GXTypeId` = `gzgxt`.`SKeyId`) and (`gzgxt`.`SKey` = 'bzGanZhiGXType')))) left join `sm`.`zgan` `g1` on((`g1`.`GanId` = `gx`.`GanZhiId1`))) left join `sm`.`zgan` `g2` on((`g2`.`GanId` = `gx`.`GanZhiId2`))) left join `sm`.`zsuanming` `ss` on(((`ss`.`SKey` = 'bzShiSheng') and (`gx`.`GXValueId` = `ss`.`SKeyId`)))) where (`gx`.`GXTypeId` = 3) union select `gzgxt`.`SValue` AS `GXType`,`gx`.`GXId` AS `GXId`,`gx`.`GXTypeId` AS `GXTypeId`,`gx`.`GanZhiId1` AS `GanZhiId1`,`gx`.`GanZhiId2` AS `GanZhiId2`,`gx`.`GanZhiId3` AS `GanZhiId3`,`gx`.`GanZhiGXId` AS `GanZhiGXId`,`gx`.`GXValueId` AS `GXValueId`,`gx`.`Remark` AS `Remark`,`g`.`Gan` AS `GanZhi1`,`z`.`Zhi` AS `GanZhi2`,NULL AS `GanZhi3`,NULL AS `GanZhiGX`,`ss`.`SValue` AS `GXValue` from ((((`sm`.`zganzhigx` `gx` left join `sm`.`zsuanming` `gzgxt` on(((`gx`.`GXTypeId` = `gzgxt`.`SKeyId`) and (`gzgxt`.`SKey` = 'bzGanZhiGXType')))) left join `sm`.`zgan` `g` on((`g`.`GanId` = `gx`.`GanZhiId1`))) left join `sm`.`zzhi` `z` on((`z`.`ZhiId` = `gx`.`GanZhiId2`))) left join `sm`.`zsuanming` `ss` on(((`ss`.`SKey` = 'bzWangShuai') and (`gx`.`GXValueId` = `ss`.`SKeyId`)))) where (`gx`.`GXTypeId` = 4);

-- -----------------------------------------------------
-- View `sm`.`vjiazi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vjiazi`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vjiazi` AS select `jz`.`JiaZiId` AS `JiaZiId`,`jz`.`jiaZiGanId` AS `jiaZiGanId`,`jz`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz`.`NaYinId` AS `NaYinId`,`g`.`Gan` AS `Gan`,`z`.`Zhi` AS `Zhi`,`ny`.`SValue` AS `SValue`,(select `wh`.`WuHangId` from `sm`.`zwuhang` `wh` where (substr(`ny`.`SValue`,char_length(`ny`.`SValue`),1) = convert(`wh`.`WuHang` using utf8mb4))) AS `WuHangiD` from (((`sm`.`zjiazi` `jz` left join `sm`.`zgan` `g` on((`g`.`GanId` = `jz`.`jiaZiGanId`))) left join `sm`.`zzhi` `z` on((`z`.`ZhiId` = `jz`.`JiaZiZhiId`))) left join `sm`.`zsuanming` `ny` on(((`ny`.`SKeyId` = `jz`.`NaYinId`) and (`ny`.`SKey` = 'bzNaYin'))));

-- -----------------------------------------------------
-- View `sm`.`vmingzhu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vmingzhu`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vmingzhu` AS select `mz`.`MingZhuId` AS `MingZhuId`,`mz`.`MingZhu` AS `MingZhu`,`mz`.`XingBie` AS `XingBie`,date_format(`mz`.`GongLi`,'%Y-%m-%d') AS `GongLi`,`mz`.`NongLi` AS `NongLi`,`mz`.`GongLiNian` AS `GongLiNian`,`mz`.`NongLiNian` AS `NongLiNian`,(year(now()) - `mz`.`GongLiNian`) AS `Sui`,concat(`g1`.`Gan`,`z1`.`Zhi`,' ',`g2`.`Gan`,`z2`.`Zhi`,' ',`g3`.`Gan`,`z3`.`Zhi`,' ',`g4`.`Gan`,`z4`.`Zhi`) AS `BaZiByJieQi`,concat(`g1`.`Gan`,`z1`.`Zhi`,' ',`yg`.`Gan`,`yz`.`Zhi`,' ',`g3`.`Gan`,`z3`.`Zhi`,' ',`g4`.`Gan`,`z4`.`Zhi`) AS `BaZiByYueFeng`,ifnull(`mz`.`Note`,'') AS `Note`,`cjq`.`JieQi` AS `CurJieQi`,`pjq`.`JieQi` AS `PrevJieQi`,`mz`.`PreviousJieQiDate` AS `PreviousJieQiDate`,`njq`.`JieQi` AS `NextJieQi`,`mz`.`NextJieQiDate` AS `NextJieQiDate`,`mza`.`QiYunDateTime` AS `QiYunDateTime`,`mza`.`QiYunSui` AS `QiYunSui`,`wh`.`WuHangJu` AS `WuHangJu`,`wh`.`JuShu` AS `QiJuSui`,date_format(`mz`.`CreateDateTime`,'%Y-%m-%d') AS `CreateDateTime` from ((((((((((((((((`sm`.`dmingzhu` `mz` left join `sm`.`zgan` `g1` on((`mz`.`NianGanId` = `g1`.`GanId`))) left join `sm`.`zgan` `g2` on((`mz`.`YueGanId` = `g2`.`GanId`))) left join `sm`.`zgan` `g3` on((`mz`.`RiGanId` = `g3`.`GanId`))) left join `sm`.`zgan` `g4` on((`mz`.`ShiGanId` = `g4`.`GanId`))) left join `sm`.`zzhi` `z1` on((`mz`.`NianZhiId` = `z1`.`ZhiId`))) left join `sm`.`zzhi` `z2` on((`mz`.`YueZhiId` = `z2`.`ZhiId`))) left join `sm`.`zzhi` `z3` on((`mz`.`RiZhiId` = `z3`.`ZhiId`))) left join `sm`.`zzhi` `z4` on((`mz`.`ShiZhiId` = `z4`.`ZhiId`))) left join `sm`.`zjieqi` `cjq` on((`mz`.`CurrentJieQiId` = `cjq`.`JieQiId`))) left join `sm`.`zjieqi` `pjq` on((`mz`.`PreviousJieQiId` = `pjq`.`JieQiId`))) left join `sm`.`zjieqi` `njq` on((`mz`.`NextJieQiId` = `njq`.`JieQiId`))) left join `sm`.`dmingzhuadd` `mza` on((`mz`.`MingZhuId` = `mza`.`MingZhuId`))) left join `sm`.`dmingzhuzwadd` `mzza` on((`mz`.`MingZhuId` = `mzza`.`MingZhuId`))) left join `sm`.`zwuhang` `wh` on((`mzza`.`WuHangId` = `wh`.`WuHangId`))) left join `sm`.`zgan` `yg` on((`yg`.`GanId` = `mzza`.`YueGanId`))) left join `sm`.`zzhi` `yz` on((`yz`.`ZhiId` = `mzza`.`YueZhiId`))) order by date_format(`mz`.`CreateDateTime`,'%Y-%m-%d') desc,`mz`.`MingZhu`;

-- -----------------------------------------------------
-- View `sm`.`vmingzhugzgx`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vmingzhugzgx`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vmingzhugzgx` AS select `mzgx`.`MingZhuId` AS `mingzhuid`,`mzgx`.`Year` AS `year`,`mzgx`.`DYPeriod` AS `dyperiod`,`mzgx`.`DYSui` AS `dysui`,`g1`.`Gan` AS `gan1`,`z1`.`Zhi` AS `zhi1`,`gzt1`.`SValue` AS `ganzhitype1`,`g2`.`Gan` AS `gan2`,`z2`.`Zhi` AS `zhi2`,`gzt2`.`SValue` AS `ganzhitype2`,`g3`.`Gan` AS `gan3`,`z3`.`Zhi` AS `zhi3`,`gzt3`.`SValue` AS `ganzhitype3`,(case `mzgx`.`GXTypeId` when 1 then '干' else '支' end) AS `gxtype`,`gzgx`.`GanZhiGX` AS `ganzhigx` from ((((((((((`sm`.`dmingzhugzgx` `mzgx` left join `sm`.`zgan` `g1` on((`mzgx`.`GanId1` = `g1`.`GanId`))) left join `sm`.`zgan` `g2` on((`mzgx`.`GanId2` = `g2`.`GanId`))) left join `sm`.`zgan` `g3` on((`mzgx`.`GanId3` = `g3`.`GanId`))) left join `sm`.`zzhi` `z1` on((`mzgx`.`ZhiId1` = `z1`.`ZhiId`))) left join `sm`.`zzhi` `z2` on((`mzgx`.`ZhiId2` = `z2`.`ZhiId`))) left join `sm`.`zzhi` `z3` on((`mzgx`.`ZhiId3` = `z3`.`ZhiId`))) left join `sm`.`zsuanming` `gzt1` on(((`gzt1`.`SKey` = 'bzGanZhiType') and (`mzgx`.`GanZhiTypeId1` = `gzt1`.`SKeyId`)))) left join `sm`.`zsuanming` `gzt2` on(((`gzt2`.`SKey` = 'bzGanZhiType') and (`mzgx`.`GanZhiTypeId2` = `gzt2`.`SKeyId`)))) left join `sm`.`zsuanming` `gzt3` on(((`gzt3`.`SKey` = 'bzGanZhiType') and (`mzgx`.`GanZhiTypeId3` = `gzt3`.`SKeyId`)))) left join `sm`.`vganzhigx` `gzgx` on((`mzgx`.`GXId` = `gzgx`.`GXId`))) where ((`mzgx`.`Year` = year(curdate())) or `mzgx`.`DYPeriod` in (select concat(cast(`sm`.`dbazi`.`Year` as char(5) charset utf8),'-',cast((`sm`.`dbazi`.`Year` + 9) as char(5) charset utf8)) from `sm`.`dbazi` where (`sm`.`dbazi`.`BaZiId` = (select `bz`.`BaZiRefId` from `sm`.`dbazi` `bz` where ((`bz`.`Year` = year(curdate())) and (`bz`.`MingZhuId` = `mzgx`.`MingZhuId`))))) or (length(`mzgx`.`DYPeriod`) = 0)) order by `mzgx`.`Year`;

-- -----------------------------------------------------
-- View `sm`.`vmingzhuss`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vmingzhuss`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vmingzhuss` AS select `mz`.`MingZhu` AS `MingZhu`,`gzt`.`SValue` AS `GanZhiType`,`ss`.`SValue` AS `ShengSha`,`mzss`.`MingZhuId` AS `MingZhuId`,`mzss`.`ShengShaId` AS `ShengShaId`,`mzss`.`GanZhiTypeId` AS `GanZhiTypeId`,`mzss`.`Remark` AS `Remark`,`mzss`.`CreateDateTime` AS `CreateDateTime` from (((`sm`.`dmingzhuss` `mzss` left join `sm`.`dmingzhu` `mz` on((`mzss`.`MingZhuId` = `mz`.`MingZhuId`))) left join `sm`.`zsuanming` `ss` on(((`mzss`.`ShengShaId` = `ss`.`SKeyId`) and (`ss`.`SKey` = 'bzShengSha')))) left join `sm`.`zsuanming` `gzt` on(((`mzss`.`GanZhiTypeId` = `gzt`.`SKeyId`) and (`gzt`.`SKey` = 'bzGanZhiType')))) order by `mzss`.`GanZhiTypeId`;

-- -----------------------------------------------------
-- View `sm`.`vniantoyue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vniantoyue`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vniantoyue` AS select 1 AS `GanId1`,6 AS `GanId2`,`sm`.`zjiazi`.`jiaZiGanId` AS `YueGanId`,`sm`.`zjiazi`.`JiaZiZhiId` AS `YueZhiId` from `sm`.`zjiazi` where (`sm`.`zjiazi`.`JiaZiId` between 3 and 14) union select 2 AS `GanId1`,7 AS `GanId2`,`zjiazi_4`.`jiaZiGanId` AS `YueGanId`,`zjiazi_4`.`JiaZiZhiId` AS `YueZhiId` from `sm`.`zjiazi` `zjiazi_4` where (`zjiazi_4`.`JiaZiId` between 15 and 26) union select 3 AS `GanId1`,8 AS `GanId2`,`zjiazi_3`.`jiaZiGanId` AS `YueGanId`,`zjiazi_3`.`JiaZiZhiId` AS `YueZhiId` from `sm`.`zjiazi` `zjiazi_3` where (`zjiazi_3`.`JiaZiId` between 27 and 38) union select 4 AS `GanId1`,9 AS `GanId2`,`zjiazi_2`.`jiaZiGanId` AS `YueGanId`,`zjiazi_2`.`JiaZiZhiId` AS `YueZhiId` from `sm`.`zjiazi` `zjiazi_2` where (`zjiazi_2`.`JiaZiId` between 39 and 50) union select 5 AS `GanId1`,10 AS `GanId2`,`zjiazi_1`.`jiaZiGanId` AS `YueGanId`,`zjiazi_1`.`JiaZiZhiId` AS `YueZhiId` from `sm`.`zjiazi` `zjiazi_1` where ((`zjiazi_1`.`JiaZiId` between 51 and 60) or (`zjiazi_1`.`JiaZiId` between 1 and 2));

-- -----------------------------------------------------
-- View `sm`.`vritoshi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vritoshi`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vritoshi` AS select 1 AS `GanId1`,6 AS `GanId2`,`jz1`.`jiaZiGanId` AS `ShiGanId`,`jz1`.`JiaZiZhiId` AS `ShiZhiId`,`jz1`.`JiaZiId` AS `JiaZiId`,`jz1`.`jiaZiGanId` AS `jiaZiGanId`,`jz1`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz1`.`NaYinId` AS `NaYinId`,`jz1`.`Gan` AS `Gan`,`jz1`.`Zhi` AS `Zhi`,`jz1`.`SValue` AS `SValue`,`jz1`.`WuHangiD` AS `WuHangiD` from `sm`.`vjiazi` `jz1` where (`jz1`.`JiaZiId` between 1 and 12) union select 2 AS `GanId1`,7 AS `GanId2`,`jz2`.`jiaZiGanId` AS `ShiGanId`,`jz2`.`JiaZiZhiId` AS `ShiZhiId`,`jz2`.`JiaZiId` AS `JiaZiId`,`jz2`.`jiaZiGanId` AS `jiaZiGanId`,`jz2`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz2`.`NaYinId` AS `NaYinId`,`jz2`.`Gan` AS `Gan`,`jz2`.`Zhi` AS `Zhi`,`jz2`.`SValue` AS `SValue`,`jz2`.`WuHangiD` AS `WuHangiD` from `sm`.`vjiazi` `jz2` where (`jz2`.`JiaZiId` between 13 and 24) union select 3 AS `GanId1`,8 AS `GanId2`,`jz3`.`jiaZiGanId` AS `ShiGanId`,`jz3`.`JiaZiZhiId` AS `ShiZhiId`,`jz3`.`JiaZiId` AS `JiaZiId`,`jz3`.`jiaZiGanId` AS `jiaZiGanId`,`jz3`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz3`.`NaYinId` AS `NaYinId`,`jz3`.`Gan` AS `Gan`,`jz3`.`Zhi` AS `Zhi`,`jz3`.`SValue` AS `SValue`,`jz3`.`WuHangiD` AS `WuHangiD` from `sm`.`vjiazi` `jz3` where (`jz3`.`JiaZiId` between 25 and 36) union select 4 AS `GanId1`,9 AS `GanId2`,`jz4`.`jiaZiGanId` AS `ShiGanId`,`jz4`.`JiaZiZhiId` AS `ShiZhiId`,`jz4`.`JiaZiId` AS `JiaZiId`,`jz4`.`jiaZiGanId` AS `jiaZiGanId`,`jz4`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz4`.`NaYinId` AS `NaYinId`,`jz4`.`Gan` AS `Gan`,`jz4`.`Zhi` AS `Zhi`,`jz4`.`SValue` AS `SValue`,`jz4`.`WuHangiD` AS `WuHangiD` from `sm`.`vjiazi` `jz4` where (`jz4`.`JiaZiId` between 37 and 48) union select 5 AS `GanId1`,10 AS `GanId2`,`jz5`.`jiaZiGanId` AS `ShiGanId`,`jz5`.`JiaZiZhiId` AS `ShiZhiId`,`jz5`.`JiaZiId` AS `JiaZiId`,`jz5`.`jiaZiGanId` AS `jiaZiGanId`,`jz5`.`JiaZiZhiId` AS `JiaZiZhiId`,`jz5`.`NaYinId` AS `NaYinId`,`jz5`.`Gan` AS `Gan`,`jz5`.`Zhi` AS `Zhi`,`jz5`.`SValue` AS `SValue`,`jz5`.`WuHangiD` AS `WuHangiD` from `sm`.`vjiazi` `jz5` where (`jz5`.`JiaZiId` between 49 and 60);

-- -----------------------------------------------------
-- View `sm`.`vsihua`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vsihua`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vsihua` AS select `gsh`.`GanSiHuaId` AS `GanSiHuaId`,`gsh`.`GanId` AS `GanId`,`gsh`.`SiHuaId` AS `SiHuaId`,`gsh`.`XingYaoId` AS `XingYaoId`,`gsh`.`Disabled` AS `Disabled`,concat(convert(`g`.`Gan` using utf8mb4),'年',`sh`.`SValue`,'在',`xy`.`SValue`) AS `SiHua` from (((`sm`.`zwgansihua` `gsh` left join `sm`.`zgan` `g` on((`gsh`.`GanId` = `g`.`GanId`))) left join `sm`.`zsuanming` `sh` on(((`sh`.`SKey` = 'zwSiHua') and (`gsh`.`SiHuaId` = `sh`.`SKeyId`)))) left join `sm`.`zsuanming` `xy` on(((`xy`.`SKey` = 'zwXingYao') and (`gsh`.`XingYaoId` = `xy`.`SKeyId`)))) order by `gsh`.`GanId`,`gsh`.`SiHuaId`;

-- -----------------------------------------------------
-- View `sm`.`vwuhanggx`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vwuhanggx`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vwuhanggx` AS select `wh1`.`WuHang` AS `WuHangKe`,`sk`.`SValue` AS `WuHangZhu`,`wh2`.`WuHang` AS `WuHang`,`whgx`.`WuHangGXId` AS `WuHangGXId`,`whgx`.`ZhuTiId` AS `ZhuTiId`,`whgx`.`ShengKeId` AS `ShengKeId`,`whgx`.`KeTiId` AS `KeTiId` from (((`sm`.`zwuhanggx` `whgx` left join `sm`.`zwuhang` `wh1` on((`wh1`.`WuHangId` = `whgx`.`KeTiId`))) left join `sm`.`zwuhang` `wh2` on((`wh2`.`WuHangId` = `whgx`.`ZhuTiId`))) left join `sm`.`zsuanming` `sk` on(((`sk`.`SKey` = 'bzShengKe') and (`whgx`.`ShengKeId` = `sk`.`SKeyId`))));

-- -----------------------------------------------------
-- View `sm`.`vzwfeixing`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vzwfeixing`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vzwfeixing` AS select `zw`.`MingZhuId` AS `MingZhuId`,`mz`.`MingZhu` AS `MingZhu`,`lnfx`.`FeiXing` AS `LFeiXing`,`lnfx`.`Note` AS `LNote`,`qnfx`.`FeiXing` AS `QFeiXin`,`qnfx`.`Note` AS `QNote`,`knfx`.`FeiXing` AS `KFeiXing`,`knfx`.`Note` AS `KNote`,`jnfx`.`FeiXing` AS `JFeiXing`,`jnfx`.`Note` AS `JNote` from (((((`sm`.`dziwei` `zw` left join `sm`.`dmingzhu` `mz` on((`zw`.`MingZhuId` = `mz`.`MingZhuId`))) left join `sm`.`zwfeixing` `lnfx` on((isnull(`lnfx`.`FromGongWeiID`) and (`lnfx`.`FeiXingTypeId` = 1) and (`lnfx`.`ToGongWeiID` = `zw`.`HuaLuGWId`)))) left join `sm`.`zwfeixing` `qnfx` on((isnull(`qnfx`.`FromGongWeiID`) and (`qnfx`.`FeiXingTypeId` = 2) and (`qnfx`.`ToGongWeiID` = `zw`.`HuaQuanGWId`)))) left join `sm`.`zwfeixing` `knfx` on((isnull(`knfx`.`FromGongWeiID`) and (`knfx`.`FeiXingTypeId` = 3) and (`knfx`.`ToGongWeiID` = `zw`.`HuaKeGWId`)))) left join `sm`.`zwfeixing` `jnfx` on((isnull(`jnfx`.`FromGongWeiID`) and (`jnfx`.`FeiXingTypeId` = 4) and (`jnfx`.`ToGongWeiID` = `zw`.`HuaJiGWId`)))) where (`zw`.`GanId` = `mz`.`NianGanId`) union select `zw`.`MingZhuId` AS `MingZhuId`,`mz`.`MingZhu` AS `MingZhu`,`lnfx`.`FeiXing` AS `LFeiXing`,`lnfx`.`Note` AS `LNote`,`qnfx`.`FeiXing` AS `QFeiXin`,`qnfx`.`Note` AS `QNote`,`knfx`.`FeiXing` AS `KFeiXing`,`knfx`.`Note` AS `KNote`,`jnfx`.`FeiXing` AS `JFeiXing`,`jnfx`.`Note` AS `JNote` from (((((`sm`.`dziwei` `zw` left join `sm`.`dmingzhu` `mz` on((`zw`.`MingZhuId` = `mz`.`MingZhuId`))) left join `sm`.`zwfeixing` `lnfx` on(((`lnfx`.`FromGongWeiID` = `zw`.`GongWeiId`) and (`lnfx`.`FeiXingTypeId` = 1) and (`lnfx`.`ToGongWeiID` = `zw`.`HuaLuGWId`)))) left join `sm`.`zwfeixing` `qnfx` on(((`qnfx`.`FromGongWeiID` = `zw`.`GongWeiId`) and (`qnfx`.`FeiXingTypeId` = 2) and (`qnfx`.`ToGongWeiID` = `zw`.`HuaQuanGWId`)))) left join `sm`.`zwfeixing` `knfx` on(((`knfx`.`FromGongWeiID` = `zw`.`GongWeiId`) and (`knfx`.`FeiXingTypeId` = 3) and (`knfx`.`ToGongWeiID` = `zw`.`HuaKeGWId`)))) left join `sm`.`zwfeixing` `jnfx` on(((`jnfx`.`FromGongWeiID` = `zw`.`GongWeiId`) and (`jnfx`.`FeiXingTypeId` = 4) and (`jnfx`.`ToGongWeiID` = `zw`.`HuaJiGWId`))));

-- -----------------------------------------------------
-- View `sm`.`vzwgongwei`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vzwgongwei`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vzwgongwei` AS select `mz`.`MingZhu` AS `MingZhu`,`mz`.`XingBie` AS `XingBie`,`mz`.`GongLi` AS `GongLi`,`mz`.`NongLi` AS `NongLi`,`ppt`.`SValue` AS `PaiPanType`,`gw`.`SValue` AS `GongWei`,`g`.`Gan` AS `Gan`,`z`.`Zhi` AS `Zhi`,`hlxy`.`SValue` AS `HLXY`,`hlgw`.`SValue` AS `HLGW`,`hqxy`.`SValue` AS `HQXY`,`hqgw`.`SValue` AS `HQGW`,`hkxy`.`SValue` AS `HKXY`,`hkgw`.`SValue` AS `HKGW`,`hjxy`.`SValue` AS `HJXY`,`hjgw`.`SValue` AS `HJGW`,`zw`.`ZiWeiId` AS `ZiWeiId`,`zw`.`MingZhuId` AS `MingZhuId`,`zw`.`PaiPanTypeId` AS `PaiPanTypeId`,`zw`.`GongWeiId` AS `GongWeiId`,`zw`.`IsShengGong` AS `IsShengGong`,`zw`.`GanId` AS `GanId`,`zw`.`ZhiId` AS `ZhiId`,`zw`.`HuaLuXYId` AS `HuaLuXYId`,`zw`.`HuaLuGWId` AS `HuaLuGWId`,`zw`.`HuaQuanXYId` AS `HuaQuanXYId`,`zw`.`HuaQuanGWId` AS `HuaQuanGWId`,`zw`.`HuaKeXYId` AS `HuaKeXYId`,`zw`.`HuaKeGWId` AS `HuaKeGWId`,`zw`.`HuaJiXYId` AS `HuaJiXYId`,`zw`.`HuaJiGWId` AS `HuaJiGWId`,`zw`.`DaXianFrom` AS `DaXianFrom`,`zw`.`DaXianTo` AS `DaXianTo`,`zw`.`DaXian` AS `DaXian`,`zw`.`Year` AS `Year` from (((((((((((((`sm`.`dziwei` `zw` left join `sm`.`dmingzhu` `mz` on((`zw`.`MingZhuId` = `mz`.`MingZhuId`))) left join `sm`.`zsuanming` `gw` on(((`gw`.`SKey` = 'zwGongWei') and (`zw`.`GongWeiId` = `gw`.`SKeyId`)))) left join `sm`.`zgan` `g` on((`zw`.`GanId` = `g`.`GanId`))) left join `sm`.`zzhi` `z` on((`zw`.`ZhiId` = `z`.`ZhiId`))) left join `sm`.`zsuanming` `hlxy` on(((`hlxy`.`SKey` = 'zwXingYao') and (`hlxy`.`SKeyId` = `zw`.`HuaLuXYId`)))) left join `sm`.`zsuanming` `hlgw` on(((`hlgw`.`SKey` = 'zwGongWei') and (`hlgw`.`SKeyId` = `zw`.`HuaLuGWId`)))) left join `sm`.`zsuanming` `hqxy` on(((`hqxy`.`SKey` = 'zwXingYao') and (`hqxy`.`SKeyId` = `zw`.`HuaQuanXYId`)))) left join `sm`.`zsuanming` `hqgw` on(((`hqgw`.`SKey` = 'zwGongWei') and (`hqgw`.`SKeyId` = `zw`.`HuaQuanGWId`)))) left join `sm`.`zsuanming` `hkxy` on(((`hkxy`.`SKey` = 'zwXingYao') and (`hkxy`.`SKeyId` = `zw`.`HuaKeXYId`)))) left join `sm`.`zsuanming` `hkgw` on(((`hkgw`.`SKey` = 'zwGongWei') and (`hkgw`.`SKeyId` = `zw`.`HuaKeGWId`)))) left join `sm`.`zsuanming` `hjxy` on(((`hjxy`.`SKey` = 'zwXingYao') and (`hjxy`.`SKeyId` = `zw`.`HuaJiXYId`)))) left join `sm`.`zsuanming` `hjgw` on(((`hjgw`.`SKey` = 'zwGongWei') and (`hjgw`.`SKeyId` = `zw`.`HuaJiGWId`)))) left join `sm`.`zsuanming` `ppt` on(((`ppt`.`SKey` = 'zwPaiPanType') and (`ppt`.`SKeyId` = `zw`.`PaiPanTypeId`)))) order by `zw`.`MingZhuId`,`zw`.`GongWeiId`;

-- -----------------------------------------------------
-- View `sm`.`vzwingyaozhi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vzwingyaozhi`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vzwingyaozhi` AS select `sm`.`zzhi`.`ZhiId` AS `ZWZhiId`,`sm`.`zzhi`.`Zhi` AS `ZWZhi`,1 AS `ZWXYId`,`fGanZhiOffset`(`sm`.`zzhi`.`ZhiId`,2,0,0) AS `TJZhiId`,2 AS `TJXYId`,`fGanZhiOffset`(`sm`.`zzhi`.`ZhiId`,4,0,0) AS `TYAZhiId`,3 AS `TYAXYId`,`fGanZhiOffset`(`sm`.`zzhi`.`ZhiId`,5,0,0) AS `WQZhiId`,4 AS `WQXYId`,`fGanZhiOffset`(`sm`.`zzhi`.`ZhiId`,6,0,0) AS `TTZhiId`,5 AS `TTXYId`,`fGanZhiOffset`(`sm`.`zzhi`.`ZhiId`,9,0,0) AS `LZZhiId`,6 AS `LZXYId`,(((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1) AS `TFZhiId`,7 AS `TFXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),2,1,0) AS `TYIZhiId`,8 AS `TYIXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),3,1,0) AS `TLAZhiId`,9 AS `TLAXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),4,1,0) AS `JMZhiId`,10 AS `JMXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),5,1,0) AS `TXZhiId`,11 AS `TXXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),6,1,0) AS `TLZhiId`,12 AS `TLXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),7,1,0) AS `QSZhiId`,13 AS `QSXYId`,`fGanZhiOffset`((((17 - `sm`.`zzhi`.`ZhiId`) % 12) + 1),11,1,0) AS `PJZhiId`,14 AS `PJXYId` from `sm`.`zzhi`;

-- -----------------------------------------------------
-- View `sm`.`vzwxingyao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `sm`.`vzwxingyao`;
USE `sm`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sm`.`vzwxingyao` AS select `zw`.`ZiWeiId` AS `ZiWeiId`,`zw`.`MingZhuId` AS `MingZhuId`,`ppt`.`SValue` AS `PaiPanType`,`gw`.`SValue` AS `GongWei`,`xy`.`SValue` AS `XingYao`,`xy`.`SKeyId` AS `XingYaoId`,`xy`.`STypeId` AS `XingYaoTypeId`,`xyt`.`SValue` AS `XingYaoType`,`zw`.`PaiPanTypeId` AS `PaiPanTypeId`,`zw`.`GongWeiId` AS `GongWeiId` from (((((`sm`.`dziwei` `zw` left join `sm`.`dziweixingyao` `zwxy` on((`zw`.`ZiWeiId` = `zwxy`.`ZiWeiId`))) left join `sm`.`zsuanming` `xy` on(((`xy`.`SKey` = 'zwXingYao') and (`zwxy`.`XingYaoId` = `xy`.`SKeyId`)))) left join `sm`.`zsuanming` `xyt` on(((`xy`.`STypeId` = `xyt`.`SKeyId`) and (`xyt`.`SKey` = 'zwXingYaoType') and (`xyt`.`SDisabled` = 0)))) left join `sm`.`zsuanming` `ppt` on(((`ppt`.`SKey` = 'zwPaiPanType') and (`zw`.`PaiPanTypeId` = `ppt`.`SKeyId`)))) left join `sm`.`zsuanming` `gw` on(((`gw`.`SKey` = 'zwGongWei') and (`zw`.`GongWeiId` = `gw`.`SKeyId`)))) order by `zw`.`GanId`,`xy`.`STypeId`,`xy`.`SKeyId`;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
