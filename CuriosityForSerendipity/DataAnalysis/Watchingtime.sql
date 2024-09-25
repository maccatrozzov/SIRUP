CREATE TABLE watchingtime AS
( SELECT user_id,
time_day_id as timepoint,
amount_time_id
FROM wmprojec_vistatv_conflict.part1_question5_cf);

INSERT INTO watchingtime (user_id, timepoint, amount_time_id)
SELECT user_id, day_id, amount_time_id FROM part1_question6_cf;

# Search for user_id with more or less answers
SELECT count(user_id) FROM
(
SELECT watchingtime.*, users_cf.notspam 
FROM wmprojec_vistatv_conflict.watchingtime, wmprojec_vistatv_conflict.users_cf 
WHERE users_cf.user=watchingtime.user_id AND notspam=1) as e 
GROUP BY user_id 
having (count(user_id)<11 or count(user_id)>11);

# show notspam answers in watchingtime table
SELECT watchingtime.* FROM wmprojec_vistatv_conflict.watchingtime, wmprojec_vistatv_conflict.users_cf 
WHERE users_cf.user=watchingtime.user_id AND notspam=1;
