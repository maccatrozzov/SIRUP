#Add completiontime column to users_cf table
#ALTER TABLE wmprojec_vistatv_conflict.users_cf 
    #ADD COLUMN completiontime time NULL
		#AFTER IP_1;
        
#UPDATE wmprojec_vistatv_conflict.users_cf SET completiontime = TIMEDIFF(end,start);

#step 1: Combine all useful inforation from user profile & ratings of recommendations creating one big table.
CREATE TABLE bigtable AS
(
SELECT programmes_watched.*,
recommendations_evaluation.surprised,
recommendations_evaluation.interesting,
recommendations_evaluation.usuallyWatched,
recommendations_evaluation.notInteresting,
recommendations_evaluation.notUnderstand,
user_demographics_cf.age,
user_demographics_cf.gender,
user_demographics_cf.country,
user_demographics_cf.education,
user_demographics_cf.job,
users_cf.start,
users_cf.end,
users_cf.completiontime,
users_cf.IP_1,
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

FROM wmprojec_vistatv_conflict.programmes_watched

JOIN wmprojec_vistatv_conflict.recommendations_evaluation 
ON wmprojec_vistatv_conflict.programmes_watched.user_id=wmprojec_vistatv_conflict.recommendations_evaluation.user_id
AND wmprojec_vistatv_conflict.programmes_watched.pid= wmprojec_vistatv_conflict.recommendations_evaluation.pid

LEFT JOIN wmprojec_vistatv_conflict.user_demographics_cf
ON wmprojec_vistatv_conflict.user_demographics_cf.user_id=wmprojec_vistatv_conflict.programmes_watched.user_id

LEFT JOIN wmprojec_vistatv_conflict.users_cf
ON wmprojec_vistatv_conflict.users_cf.user=wmprojec_vistatv_conflict.programmes_watched.user_id

LEFT JOIN wmprojec_vistatv_conflict.part2_question1_cf
ON wmprojec_vistatv_conflict.part2_question1_cf.user_id= wmprojec_vistatv_conflict.programmes_watched.user_id

LEFT JOIN wmprojec_vistatv_conflict.part2_question2_cf
ON wmprojec_vistatv_conflict.part2_question2_cf.user_id= wmprojec_vistatv_conflict.programmes_watched.user_id

LEFT JOIN wmprojec_vistatv_conflict.part2_question3_cf
ON wmprojec_vistatv_conflict.part2_question3_cf.user_id= wmprojec_vistatv_conflict.programmes_watched.user_id

)
;
# Step 2: detect spam answers and select not spam user_id
ALTER TABLE bigtable
ADD COLUMN spam_check int NOT NULL DEFAULT 0,
ADD COLUMN spam_slow int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarcuriosity1 int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarcuriosity2 int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarreason int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarpreference int NOT NULL DEFAULT 0,
ADD COLUMN spam_similarrating int not null default 0,
ADD COLUMN TotalSpamFlags int NOT NULL DEFAULT 0,
ADD COLUMN hasFlags int NOT NULL DEFAULT 0,
ADD COLUMN UserSpamFlags int NOT NULL DEFAULT 0,
ADD COLUMN UserTotalSpamFlags int NOT NULL DEFAULT 0,
ADD COLUMN TotalRecommendations int not null default 0,
ADD COLUMN notspam int not null default 0;

# Add check question about interesting vs notinteresting contradictions 
UPDATE bigtable
SET spam_check = 1
WHERE (notInteresting BETWEEN 6 AND 7 AND interesting BETWEEN 6 AND 7)
OR (notInteresting >7 AND interesting>7);

# Slow participants are set at 6min30sec, but I think this is a bit too slow, we might want to lower this a bit.
UPDATE bigtable
SET spam_slow = 1
WHERE (completiontime < CAST('00:05:00' AS TIME)
OR completiontime is null );

# Flag answers which have all similar answers on likert-scale questions.
UPDATE bigtable
SET spam_similarcuriosity1 = 1
WHERE (discoverPlaces=learnSubjects 
AND learnSubjects=listenMusic 
AND listenMusic=strangeSound 
AND strangeSound=machinery 
AND machinery=solution);

UPDATE bigtable
SET spam_similarcuriosity2 = 1
WHERE (influenceDecision=outOfScope 
AND outOfScope=unexpected 
AND unexpected=usefulIdeas);

UPDATE bigtable
SET spam_similarpreference =1
WHERE (familiarGenre=favoriteActor 
AND favoriteActor=favoriteDirector 
AND favoriteDirector=intrigue 
AND intrigue=mood 
AND mood=mind);

UPDATE bigtable 
SET spam_similarreason = 1
WHERE (genre = format
AND format=actor
AND actor=director
AND director=popularity
AND popularity=topic);

UPDATE bigtable
SET spam_similarrating=1
WHERE (surprised=interesting 
AND interesting=usuallyWatched
AND usuallyWatched=notInteresting
AND notInteresting=notUnderstand);

#sum total flags per answer (recommendation)
UPDATE bigtable
SET TotalSpamFlags = (SELECT SUM(spam_slow + spam_check + spam_similarcuriosity1 + spam_similarcuriosity2 + spam_similarreason + spam_similarrating + spam_similarpreference));

#flag answer as 'spam' if any type of spam is detected
UPDATE bigtable
SET hasFLAGS = 1
WHERE (spam_slow + spam_check + spam_similarcuriosity1 + spam_similarcuriosity2 + spam_similarreason + spam_similarrating + spam_similarpreference) > 0;

#Sum answers flagged as 'spam' per participant
UPDATE bigtable,
(SELECT user_id, sum(hasFlags) as sumFlags
FROM bigtable GROUP BY user_id) as a
SET bigtable.UserSpamFlags = a.sumFlags
WHERE bigtable.user_id=a.user_id;

# sum total spam flags per answer per participant (sum all flags of the 9 recommendations)
UPDATE bigtable,
(SELECT user_id, sum(TotalSpamFlags) as sumTotalFlags
FROM bigtable GROUP BY user_id) as b
SET bigtable.UserTotalSpamFlags = b.sumTotalFlags
WHERE bigtable.user_id=b.user_id;

#count nr. of rated recommendations per participant
UPDATE bigtable,
(SELECT user_id, count(*) as RatedRec
FROM bigtable GROUP BY user_id order by count(*)) as c
SET bigtable.TotalRecommendations=c.RatedRec
WHERE bigtable.user_id=c.user_id;

#show frequency of flagged spam answers on recommedations per user (completiontime excluded). 
#In total 187 p finished the survey.
SELECT user_id, 
sum(hasFlags), 
sum(TotalSpamFlags), 
sum(spam_check), 
sum(spam_similarcuriosity1), 
sum(spam_similarcuriosity2), 
sum(spam_similarreason),
sum(spam_similarpreference),
sum(spam_similarrating)
FROM bigtable WHERE TotalRecommendations=9 and user_id>206
GROUP by user_id;

#show number of participants which are not indicated as spam:
	# <3 (out of 9) failed the check question(interesting AND notinteresting both positive or negative).
	# <3 (out of 9) similar likert scale answers on rating reason for watching/not watching recommendation
	# 0 or 1 out of 3 tables of the coping_potential_questions page has similar likert scale answers
	# <3 (out of 9) similar likert scale answers on recommendation serendipity questions
SELECT count(user_id) from
(select user_id from bigtable
WHERE TotalRecommendations=9 and user_id>206
GROUP by user_id having (sum(spam_similarcuriosity1) +
sum(spam_similarcuriosity2) + sum(spam_similarpreference))<10
AND sum(spam_similarreason)<3
AND sum(spam_similarrating)<3
AND sum(spam_check)<3
AND sum(spam_slow)=0) as e;

# flag the not spam answers/participants. These will be used for data analysis.
# In total 94 participants included, fast participants (<5min) excluded.
UPDATE bigtable,
(select user_id from bigtable
WHERE TotalRecommendations=9 and user_id>206
GROUP by user_id having (sum(spam_similarcuriosity1) +
sum(spam_similarcuriosity2) + sum(spam_similarpreference))<10
AND sum(spam_similarreason)<3
AND sum(spam_similarrating)<3
AND sum(spam_check)<3
AND sum(spam_slow)=0) as e
SET bigtable.notspam=1
WHERE bigtable.user_id=e.user_id;

#save not spam users to users_cf as new column
ALTER TABLE users_cf
ADD COLUMN notspam int null;

UPDATE users_cf,
(select user_id from bigtable
WHERE TotalRecommendations=9 and user_id>206
GROUP by user_id having (sum(spam_similarcuriosity1) +
sum(spam_similarcuriosity2) + sum(spam_similarpreference))<10
AND sum(spam_similarreason)<3
AND sum(spam_similarrating)<3
AND sum(spam_check)<3
AND sum(spam_slow)=0) as e
SET users_cf.notspam=1
WHERE users_cf.user=e.user_id;

#show ratings from not spam participants
SELECT * FROM bigtable WHERE notspam=1;


#SELECT COUNT(DISTINCT user_id) from bigtable where user_id>206;

#SELECT COUNT(DISTINCT user_id) from recommendations_evaluation where user_id>206;

#SELECT COUNT(DISTINCT user_id) from programmes_watched where user_id>206;

#SELECT COUNT(DISTINCT user_id) from recommendations_evaluation where user_id>206;

#SELECT COUNT(DISTINCT user_id) from part2_question3_cf where user_id>206;
