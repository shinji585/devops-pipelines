SELECT
   count(*) as total_users,
   min( followers ) as min_followers,
   max( followers ) as max_followers,
   round( avg(followers )) as avg_followers
from users
