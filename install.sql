CREATE TABLE `warmod_matches` (
  `match_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_a_name` varchar(128) NOT NULL,
  `team_b_name` varchar(128) NOT NULL,
  `CURRENT_MAP` varchar(64) NOT NULL,
  `team_size` int(11) UNSIGNED NOT NULL,
  `team_a_t_score` int(11) UNSIGNED NOT NULL,
  `team_b_ct_score` int(11) UNSIGNED NOT NULL,
  `team_a_ct_score` int(11) UNSIGNED NOT NULL,
  `team_b_t_score` int(11) UNSIGNED NOT NULL,
  `mix_end_time` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`match_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `warmod_stats` (
  `stats_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `match_id` int(11) UNSIGNED NOT NULL,
  `usgn` int(11) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `code` char(2) NOT NULL,
  `name` varchar(25) NOT NULL,
  `team` tinyint(1) UNSIGNED NOT NULL,
  `mix_dmg` int(11) UNSIGNED NOT NULL,
  `total_kills` int(11) UNSIGNED NOT NULL,
  `total_deaths` int(11) UNSIGNED NOT NULL,
  `bomb_plants` int(11) UNSIGNED NOT NULL,
  `bomb_defusals` int(11) UNSIGNED NOT NULL,
  `double` int(11) UNSIGNED NOT NULL,
  `triple` int(11) UNSIGNED NOT NULL,
  `quadra` int(11) UNSIGNED NOT NULL,
  `aces` int(11) UNSIGNED NOT NULL,
  `total_mvp` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`stats_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;