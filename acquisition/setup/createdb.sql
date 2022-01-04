SELECT 'CREATE DATABASE emissionkit'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'emissionkit')\gexec