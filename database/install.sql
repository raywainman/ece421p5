delimiter $$

DROP TABLE IF EXISTS game_restore_players$$
DROP TABLE IF EXISTS game_results_players$$
DROP TABLE IF EXISTS game_results$$
DROP TABLE IF EXISTS game$$
DROP TABLE IF EXISTS player$$

delimiter $$

CREATE TABLE `game` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `data` blob NOT NULL,
  `complete` int(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs$$


delimiter $$

CREATE TABLE `game_restore_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs$$


delimiter $$

CREATE TABLE `game_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game_id` int(11) NOT NULL,
  `winnerid` int(11) NOT NULL,
  `completed_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `game_id_UNIQUE` (`game_id`),
  CONSTRAINT `gameid` FOREIGN KEY (`game_id`) REFERENCES `game` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs$$


delimiter $$

CREATE TABLE `game_results_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `game_results_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `tokens` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `results_id` (`game_results_id`),
  CONSTRAINT `results_id` FOREIGN KEY (`game_results_id`) REFERENCES `game_results` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs$$


delimiter $$

CREATE TABLE `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs$$


