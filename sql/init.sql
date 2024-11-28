DELETE FROM tenant WHERE id > 100;
DELETE FROM visit_history WHERE created_at >= '1654041600';
UPDATE id_generator SET id=2678400000 WHERE stub='a';
ALTER TABLE id_generator AUTO_INCREMENT=2678400000;

-- index作成に時間がかかる場合は初期化がタイムアウトになって負荷テストが実行されない。
-- 本当は複合indexを貼りたい...
-- ALTER TABLE `visit_history` ADD INDEX `tenant_compet_player_id_idx` (`tenant_id`, `competition_id`, `player_id`);
DROP INDEX `player_id_idx` ON `visit_history`;
ALTER TABLE `visit_history` ADD INDEX `player_id_idx` ( `player_id`);