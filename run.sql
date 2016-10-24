-- create standardization functions

CREATE OR REPLACE FUNCTION tz.standardize_day_month2(p_text text)
  RETURNS text AS
$BODY$

declare
	result character varying(2);
begin
	result := lpad(p_Text,2,'0');
	return result;

end

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION tz.standardize_name(p_text text)
  RETURNS text AS
$BODY$

declare
	result text;
begin
	result := p_Text;
	-- To UPPER case
	result := '@'||trim(upper(result))||'@';

	-- Remove prefix
	
	result := replace(result,'@MR.','');
	result := replace(result,'@MRS.','');
	result := replace(result,'@MS.','');
	result := replace(result,'@DR.','');

	result := replace(result,'@MR ','');
	result := replace(result,'@MRS ','');
	result := replace(result,'@MS ','');
	result := replace(result,'@DR ','');


	-- Remove suffix
	
	result := replace(result,' III@','');
	result := replace(result,' JR@','');
	result := replace(result,' JR.@','');

	-- Remove all digits
	result := replace(result,'0','');
	result := replace(result,'1','');
	result := replace(result,'2','');
	result := replace(result,'3','');
	result := replace(result,'4','');
	result := replace(result,'5','');
	result := replace(result,'6','');
	result := replace(result,'7','');
	result := replace(result,'8','');
	result := replace(result,'9','');
	
	-- Remove special characters
	result := replace(result,'.','');
	result := replace(result,'!','');
	result := replace(result,';','');
	result := replace(result,':','');
	result := replace(result,'''','');
	result := replace(result,'\"','');
	result := replace(result,'-','');
	result := replace(result,'_','');
	result := replace(result,'*','');
	result := replace(result,'[','');
	result := replace(result,']','');
	result := replace(result,'{','');
	result := replace(result,'}','');
	result := replace(result,'(','');
	result := replace(result,')','');
	result := replace(result,'#','');
	result := replace(result,'@','');
	result := replace(result,'%','');
	result := replace(result,'^','');
	result := replace(result,'$','');
	result := replace(result,'&','');
	result := replace(result,'>','');
	result := replace(result,'<','');
	result := replace(result,'\\','');
	result := replace(result,'/','');
	result := replace(result,'+','');
	result := replace(result,'=','');

	-- Remove space
	result := replace(result,' ','');

	return result;
end

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Add columns to table
ALTER TABLE tz.ibd 
ADD COLUMN s_first character varying(50), 
ADD COLUMN s_last character varying(50), 
ADD COLUMN s_mob character varying(2), 
ADD COLUMN s_dob character varying(2), 
ADD COLUMN s_yob character varying(4),
ADD COLUMN seed1 character varying(110),
ADD COLUMN block1 character varying(50),
ADD COLUMN block2 character varying(50),
ADD COLUMN block3 character varying(50);

ALTER TABLE tz.zip3
ADD COLUMN s_first character varying(50), 
ADD COLUMN s_last character varying(50), 
ADD COLUMN s_mob character varying(2), 
ADD COLUMN s_dob character varying(2), 
ADD COLUMN s_yob character varying(4),
ADD COLUMN s_yob character varying(4),
ADD COLUMN seed1 character varying(110),
ADD COLUMN block1 character varying(50),
ADD COLUMN block2 character varying(50),
ADD COLUMN block3 character varying(60);

UPDATE tz.ibd SET
s_first = tz.standardize_name(first),
s_last = tz.standardize_name(last),
s_dob = tz.standardize_day_month(extract(day from dob)::text),
s_mob = tz.standardize_day_month(extract(month from dob)::text),
s_yob = extract(year from dob)::character varying(4),
seed1 = s_first||s_last||s_yob||'-'||s_mob||'-'||s_dob,
block1 = left(s_last,4)||s_yob,
block2 = left(zip,2)||s_mob||s_dob,
block3 = soundex(s_last)||left(s_first,1)||s_yob||'-'||s_mob||'-'||s_dob;

UPDATE tz.zip3 SET
s_first = tz.standardize_name(first),
s_last = tz.standardize_name(last),
s_dob = tz.standardize_day_month(extract(day from dob)::text),
s_mob = tz.standardize_day_month(extract(month from dob)::text),
s_yob = extract(year from dob)::character varying(4),
seed1 = s_first||s_last||s_yob||'-'||s_mob||'-'||s_dob,
block1 = left(s_last,4)||s_yob,
block2 = left(zip,2)||s_mob||s_dob,
block3 = soundex(s_last)||left(s_first,1)||s_yob||'-'||s_mob||'-'||s_dob;

CREATE TABLE tz.encrypted_ibd
(
	id integer,
	first_hash character varying(2000),
	last_hash character varying(2000),
	yob_hash character varying(2000),
	mob_hash character varying(2000),
	dob_hash character varying(2000),
	gender_hash character varying(2000),
	seed1_hash character varying(2000),
	block1_hash character varying(256),
	block2_hash character varying(256),
	block3_hash character varying(256)
);

CREATE TABLE tz.encrypted_zip3
(
	id integer,
	first_hash character varying(2000),
	last_hash character varying(2000),
	yob_hash character varying(2000),
	mob_hash character varying(2000),
	dob_hash character varying(2000),
	gender_hash character varying(2000),
	seed1_hash character varying(2000),
	block1_hash character varying(256),
	block2_hash character varying(256),
	block3_hash character varying(256)
);

