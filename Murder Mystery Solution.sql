-- Start by searching for a crime that was a murder that occurred sometime on Jan. 15, 2018 and occurred in SQL City.

SELECT
  *
FROM
  crime_scene_report
WHERE
  date = 20180115
  AND city = 'SQL City';

-- Description of the only murder on this day reads: "Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave"."
-- Let's search for the witnesses.

--Witness #1: Morty Schapiro, "I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W"."

SELECT
  *
FROM
  interview AS i
JOIN
  person AS p
ON
  i.person_id = p.id
WHERE
  p.address_street_name LIKE '%Northwestern%'
ORDER BY
  p.address_number DESC
LIMIT
  1;


--Witness #2: Annabel Miller, "I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th."

SELECT
  *
FROM
  interview AS i
JOIN
  person AS p
ON
  i.person_id = p.id
WHERE
  p.address_street_name LIKE '%Franklin%'
  AND p.name LIKE 'Annabel %';


-- Both witnesses gave great clues!
-- The murderer went to the gym on Jan 9 and was carrying a gold member bag with a membership number that started with "48Z".
-- The other witness also saw that the man got into a car with a plate that included "H42W"

SELECT
  *
FROM
  get_fit_now_check_in AS c
JOIN
  get_fit_now_member AS m
ON
  c.membership_id = m.id
JOIN
  person AS p
ON
  m.person_id = p.id
JOIN
  drivers_license AS l
ON
  p.license_id = l.id
WHERE
  c.membership_id LIKE '48Z%'
  AND c.check_in_date = '20180109'
  AND m.membership_status = 'gold'
  AND l.plate_number LIKE '%H42W%';

-- We found our murderer!: Jeremy Bowers
-- However, we're instructed to the interview transcript of the murderer to find the real villain behind this crime!

SELECT
  *
FROM
  interview
WHERE
  person_id IN (
      SELECT
        p.id
      FROM
        get_fit_now_check_in AS c
      JOIN
        get_fit_now_member AS m
      ON
        c.membership_id = m.id
      JOIN
        person AS p
      ON
        m.person_id = p.id
      JOIN
        drivers_license AS l
      ON
        p.license_id = l.id
      WHERE
        c.membership_id LIKE '48Z%'
        AND c.check_in_date = '20180109'
        AND m.membership_status = 'gold'
        AND l.plate_number LIKE '%H42W%');

-- Jeremy's interview states: "I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017."

SELECT
  *,
  COUNT(f.person_id) AS num_events
FROM
  facebook_event_checkin AS f
JOIN
  person AS p
ON
  f.person_id = p.id
WHERE
  f.event_name LIKE '%Symphony%'
  AND (date BETWEEN 20171201 AND 20171231)
  AND person_id IN (
    SELECT
      p.id
    FROM
      drivers_license AS l
    JOIN
      person AS p
    ON
      l.id = p.license_id
    WHERE
      l.car_make LIKE '%Tesla%'
      AND l.car_model LIKE '%Model S%'
      AND l.hair_color = 'red'
      AND l.gender = 'female' )
GROUP BY
  f.person_id
HAVING
  num_events = 3;

-- Miranda Priestly, the queen of fashion, was behind the murder!
