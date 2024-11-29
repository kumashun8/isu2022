DROP INDEX `tenant_compet_player_id_idx` ON `visit_history`;
ALTER TABLE `visit_history` ADD INDEX `tenant_compet_player_id_idx` (`tenant_id`, `competition_id`, `player_id`);

-- tenant_id 単体でselectされていないので消す
ALTER TABLE `visit_history` ADD INDEX `tenant_id_idx` (`tenant_id`);
DROP INDEX `tenant_id_idx` ON `visit_history`;