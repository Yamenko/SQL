--=============== ������ 4. ���������� � SQL =======================================
--======== �������� ����� ==============

--������� �1

-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)

--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������
 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����
create table tbl_language(
id 			serial 		primary key,
lang_name 	varchar(50)	unique not null,
shot_name	varchar(10)	unique not null,
date_add	timestamp	default now());


--�������� ������ � ������� �����
insert into tbl_language (lang_name, shot_name)
values ('Russian', 'rus'), ('English', 'eng'), ('Franch', 'fr');


--�������� ������� ����������
create table tbl_national (
	id 			serial			primary key,
	nation_name	varchar(100)	unique not null,
	date_add	timestamp		default now());


--�������� ������ � ������� ����������
insert into tbl_national (nation_name)
values ('Slavyane'), ('Anglosacs'), ('Asians');


--�������� ������� ������
create table tbl_country (
	id	serial		primary key,
	country_name varchar(100) unique not null,
	date_add timestamp default now());


--�������� ������ � ������� ������
insert into tbl_country (country_name)
values ('Russia'), ('USA'), ('Franch'), ('Germany');


--�������� ������ ������� �� �������

create table national_language(
	id_national integer, 
	id_language integer,
	date_add timestamp default now(),
	constraint id_nat_lang primary key (id_national, id_language),
	constraint id_nat_lang_nat_id FOREIGN KEY (id_national)  REFERENCES tbl_national (id), 
	constraint id_nat_lang_lang_id FOREIGN key (id_language) references tbl_language (id)
);

--�������� ������ � ������� �� �������
insert into national_language(id_national, id_language)
values (1, 1), (1, 3), (2, 1), (2, 3), (3, 2), (3, 3)

--�������� ������ ������� �� �������
create table country_national(
	id_country 		integer, 
	id_national		integer,
	date_add timestamp default now(),
	constraint id_cont_nat primary key (id_country, id_national),
	constraint id_cont_nat_cont_id FOREIGN KEY (id_country)  REFERENCES tbl_country (id), 
	constraint id_cont_nat_nat_id FOREIGN key (id_national) references tbl_national (id)
);


--�������� ������ � ������� �� �������
insert into country_national(id_country, id_national)
values (1, 1), (1, 3), (2, 1), (2, 3), (3, 2), (3, 3), (4, 1)
