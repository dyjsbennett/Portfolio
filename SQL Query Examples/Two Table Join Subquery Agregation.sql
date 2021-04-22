--Please write a single SQL query to evaluate both revenue and subscription conversion for monthly cohorts 
--from Apr 1, 2020 through Mar 31, 2021. 
--We are trying to understand the trends in new user revenue and paid subscription conversion over the past year on iOS and Android separately.
--Specifically we want to know how much revenue each monthly cohort has generated over time and the subscription conversion of each monthly cohort.
--I wrote this in Notepad++ with the SQLite environment inmind. 


SELECT
     registration_month
     ,OS
     ,new_subscribers
     ,ROUND(CAST(new_subscribers AS float) /cast(registrations as float),2) AS conversion_rate --Convert an INT value into a float and round to 2 decimal places
     ,subscription_revenue
FROM(
    SELECT --I used a subquery to organize my data
        date(registration_at,'start of month') AS registration_month --I anchored when a month started by when a user registers for service.
        ,u.platform AS OS --alias of platform
        ,COUNT(DISTINCT CASE WHEN 
                    date(u.first_subscription_payment_at,'start of month') = date(u.registration_at,'start of month') --Condition to only include subsritpions made within the month in question
                        THEN u.user_id
                        ELSE NULL
                        END) AS new_subscribers --Monthly count of new subscribers
        ,COUNT(DISTINCT CASE WHEN 
                    date(u.registration_at,'start of month') = date(u.registration_at,'start of month') --Condition to only include registrations made within the month in question
                    THEN u.user_id
                    ELSE NULL
                END) AS registrations --Monthly count of new registrations. Needed to calculate conversion rate
        ,ROUND(SUM(CASE WHEN 
                   payment_type = 'subscription' 	--Condition to only include subscription payments.											
                   AND date(payment_at,'start of month') = date(u.registration_at,'start of month') --Condition for only where the payments are only for the same month as the registration month
                   THEN p.payment_amount  --Return the 
                   ELSE null
               END),2) AS subscription_revenue	--Total Monthly subscription calculation
   FROM PAYMENTS p
   LEFT OUTER JOIN USERS u --join the payments and users tables. I used left outter to capture all of the payment records. 
   ON p.user_id = u.user_id --Common field on both 
   WHERE u.registration_at BETWEEN '2020-04-01' and '2021-03-31' --set the timeframe for the scope of the assignment, April 1, 2020 and March 31, 2021
   AND is_refunded = 'F'    				--only retireve payments that have not been refunded.
   GROUP BY registration_month, u.platform
)
GROUP BY registration_month, os --Group findings by month, then by platform.
;

