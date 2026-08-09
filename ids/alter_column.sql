ALTER TABLE transformers
ALTER COLUMN id SET DEFAULT gen_random_uuid()::uuid;