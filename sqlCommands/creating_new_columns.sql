ALTER TABLE users
ADD COLUMN IF NOT EXISTS first_name VARCHAR(12),
ADD COLUMN IF NOT EXISTS last_name VARCHAR(12);


UPDATE users 
SET 
    first_name =  SUBSTRING(name, 1, POSITION(' ' in name) - 1),
    last_name =  SUBSTRING(name, 0, POSITION(' ' in name) + 1);
 


