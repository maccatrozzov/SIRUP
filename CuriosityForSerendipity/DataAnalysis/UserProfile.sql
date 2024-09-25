#step 1: Combine all useful inforation from user profile & ratings of recommendations creating one big table.
CREATE TABLE userprofile AS
(
SELECT users_cf.*,
user_demographics_cf.gender,
user_demographics_cf.age,
user_demographics_cf.education,
user_demographics_cf.country,
user_demographics_cf.job,
part2_question1_cf.discoverPlaces,
part2_question1_cf.learnSubjects,
part2_question1_cf.listenMusic,
part2_question1_cf.strangeSound,
part2_question1_cf.machinery,
part2_question1_cf.solution,
part2_question2_cf.influenceDecision,
part2_question2_cf.outOfScope,
part2_question2_cf.unexpected,
part2_question2_cf.usefulIdeas,
part2_question3_cf.familiarGenre,
part2_question3_cf.favoriteActor,
part2_question3_cf.favoriteDirector,
part2_question3_cf.intrigue,
part2_question3_cf.mood,
part2_question3_cf.mind

FROM wmprojec_vistatv_conflict.users_cf


LEFT JOIN wmprojec_vistatv_conflict.user_demographics_cf
ON wmprojec_vistatv_conflict.users_cf.user=wmprojec_vistatv_conflict.user_demographics_cf.user_id

LEFT JOIN wmprojec_vistatv_conflict.part2_question1_cf
ON wmprojec_vistatv_conflict.part2_question1_cf.user_id= wmprojec_vistatv_conflict.users_cf.user

LEFT JOIN wmprojec_vistatv_conflict.part2_question2_cf
ON wmprojec_vistatv_conflict.part2_question2_cf.user_id= wmprojec_vistatv_conflict.users_cf.user

LEFT JOIN wmprojec_vistatv_conflict.part2_question3_cf
ON wmprojec_vistatv_conflict.part2_question3_cf.user_id= wmprojec_vistatv_conflict.users_cf.user

)
;
# Step 2: detect spam answers and select not spam user_id
ALTER TABLE userprofile
ADD COLUMN spam_slow int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarcuriosity1 int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarcuriosity2 int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarpreference int NOT NULL DEFAULT 0,
ADD COLUMN TotalSpamFlags int NOT NULL DEFAULT 0;

# Slow participants are set at 6min30sec, but I think this is a bit too slow, we might want to lower this a bit.
UPDATE userprofile
SET spam_slow = 1
WHERE ((completiontime < CAST('00:03:00' AS TIME) AND user<207)
OR (completiontime < CAST('00:05:00' AS TIME) AND user>207)
OR completiontime is null );

# Flag answers which have all similar answers on likert-scale questions.
UPDATE userprofile
SET spam_similarcuriosity1 = 1
WHERE ((discoverPlaces=learnSubjects 
AND learnSubjects=listenMusic 
AND listenMusic=strangeSound 
AND strangeSound=machinery 
AND machinery=solution)
OR discoverPlaces is null);

UPDATE userprofile
SET spam_similarcuriosity2 = 1
WHERE ((influenceDecision=outOfScope 
AND outOfScope=unexpected 
AND unexpected=usefulIdeas)
OR outOfscope is null);

UPDATE userprofile
SET spam_similarpreference =1
WHERE ((familiarGenre=favoriteActor 
AND favoriteActor=favoriteDirector 
AND favoriteDirector=intrigue 
AND intrigue=mood 
AND mood=mind)
OR familiarGenre is null);

#sum total flags per answer (recommendation)
UPDATE userprofile
SET TotalSpamFlags = (SELECT SUM(spam_slow + spam_similarcuriosity1 + spam_similarcuriosity2 + spam_similarpreference));


SELECT * from
(select * from userprofile
GROUP by user having ((sum(spam_similarcuriosity1) +
sum(spam_similarcuriosity2) + sum(spam_similarpreference))<2
AND sum(spam_slow)=0 AND user<206)
OR notspam=1) as e;

Select * FROM userprofile;


