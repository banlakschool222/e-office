-- ============================================================
-- e-สารบรรณโรงเรียน — Supabase Schema
-- วิธีใช้: วางทั้งหมดใน Supabase Dashboard > SQL Editor > Run
-- ============================================================

create extension if not exists "uuid-ossp";

-- ===== DROP ก่อน (ถ้าต้องการเริ่มใหม่) =====
drop table if exists logs cascade;
drop table if exists orders cascade;
drop table if exists memos cascade;
drop table if exists outgoing cascade;
drop table if exists incoming cascade;
drop table if exists number_sequences cascade;
drop table if exists number_formats cascade;
drop table if exists school_config cascade;
drop table if exists users cascade;
drop function if exists get_next_seq cascade;

-- ============================================================
-- USERS
-- ============================================================
create table users (
  id          uuid primary key default uuid_generate_v4(),
  username    text unique not null,
  password    text not null,
  fullname    text not null,
  role        text not null default 'teacher'
                check (role in ('admin','director','staff','teacher')),
  department  text,
  status      text not null default 'active'
                check (status in ('active','inactive')),
  created_at  timestamptz default now()
);

insert into users (username,password,fullname,role,department) values
  ('admin',   'admin123', 'นายวิชัย สุขสันต์',    'admin',    'ฝ่ายบริหาร'),
  ('director','dir123',   'นางสมศรี ดีงาม',        'director', 'ผู้บริหาร'),
  ('staff',   'staff123', 'นางสาวรัตนา จริงใจ',    'staff',    'ธุรการ'),
  ('teacher', 'teach123', 'นายประสิทธิ์ เรียนดี',  'teacher',  'กลุ่มสาระคณิตศาสตร์');

-- ============================================================
-- SCHOOL CONFIG
-- ============================================================
create table school_config (
  id             serial primary key,
  school_name    text not null default 'โรงเรียนบ้านวารินชำราบ',
  school_name_en text,
  school_code    text,
  under_org      text,
  address        text,
  tel            text,
  email          text,
  website        text,
  director_name  text,
  logo_url       text,
  updated_at     timestamptz default now()
);
insert into school_config (school_name) values ('โรงเรียนบ้านวารินชำราบ');

-- ============================================================
-- NUMBER FORMATS
-- ============================================================
create table number_formats (
  id            serial primary key,
  type          text unique not null,
  enabled       boolean default true,
  prefix        text default '',
  suffix        text default '',
  separator     text default '/',
  year_type     text default 'thai',
  year_full     boolean default true,
  padding       int default 3,
  include_year  boolean default true,
  include_month boolean default false,
  start_number  int default 1,
  label         text,
  updated_at    timestamptz default now()
);
insert into number_formats (type,prefix,padding,label) values
  ('incoming','รบ.',3,'หนังสือรับ'),
  ('outgoing','ส.',3,'หนังสือส่ง'),
  ('memos','บข.',3,'บันทึกข้อความ'),
  ('orders','คำสั่งที่ ',2,'คำสั่ง');

-- ============================================================
-- NUMBER SEQUENCES (running number แต่ละปี)
-- ============================================================
create table number_sequences (
  id    serial primary key,
  type  text not null,
  year  int  not null,
  seq   int  not null default 0,
  unique(type, year)
);

-- Atomic function สำหรับดึงเลขรันนิ่งถัดไป
create or replace function get_next_seq(p_type text, p_year int)
returns int language plpgsql as $$
declare v_seq int;
begin
  insert into number_sequences (type,year,seq) values (p_type,p_year,1)
  on conflict (type,year)
  do update set seq = number_sequences.seq + 1
  returning seq into v_seq;
  return v_seq;
end;
$$;

-- ============================================================
-- INCOMING (หนังสือรับ)
-- ============================================================
create table incoming (
  id            uuid primary key default uuid_generate_v4(),
  year          int  not null,
  receive_no    text not null,
  book_no       text,
  date_received text,
  title         text not null,
  department    text,
  responsible   text,
  urgent        text default 'ปกติ',
  status        text default 'รอดำเนินการ',
  note          text,
  file_url      text,
  file_name     text,
  file_drive_id text,
  attach_type   text,
  reserved      boolean default false,
  created_by    uuid references users(id),
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
insert into incoming (year,receive_no,book_no,date_received,title,department,responsible,urgent,status) values
  (2569,'รบ.001/2569','ศธ 04001/1234','01/05/2569','การอบรมพัฒนาครูหลักสูตรใหม่','สพม.เขต 29','นางสาวรัตนา จริงใจ','ด่วนที่สุด','รอดำเนินการ'),
  (2569,'รบ.002/2569','ศธ 0560/254', '02/05/2569','รายงานผลการดำเนินงานประจำปี 2568','สพป.อุบลฯ เขต 1','นายวิชัย สุขสันต์','ด่วน','กำลังดำเนินการ'),
  (2569,'รบ.003/2569','สน 001/2569', '03/05/2569','การเบิกจ่ายงบประมาณปี 2569','กระทรวงการคลัง','นางสมศรี ดีงาม','ปกติ','ดำเนินการแล้ว'),
  (2569,'รบ.004/2569','ศธ 04002/567','05/05/2569','แจ้งกำหนดการสอบปลายภาค 1/2569','สพม.เขต 29','นายประสิทธิ์ เรียนดี','ด่วน','รอดำเนินการ'),
  (2569,'รบ.005/2569','กค 0409/123', '06/05/2569','การอนุมัติงบประมาณเพิ่มเติม','สำนักงบประมาณ','นางสาวรัตนา จริงใจ','ปกติ','ส่งต่อแล้ว');

-- ============================================================
-- OUTGOING (หนังสือส่ง)
-- ============================================================
create table outgoing (
  id            uuid primary key default uuid_generate_v4(),
  year          int  not null,
  send_no       text not null,
  date_sent     text,
  title         text not null,
  to_department text,
  urgent        text default 'ปกติ',
  signer        text,
  status        text default 'ร่าง',
  content       text,
  file_url      text,
  file_name     text,
  file_drive_id text,
  attach_type   text,
  created_by    uuid references users(id),
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
insert into outgoing (year,send_no,date_sent,title,to_department,urgent,signer,status) values
  (2569,'ส.001/2569','02/05/2569','ขอส่งรายงานผลการดำเนินงาน ประจำปีการศึกษา 2568','สพม.เขต 29','ปกติ','นางสมศรี ดีงาม','ส่งแล้ว'),
  (2569,'ส.002/2569','04/05/2569','ขออนุมัติโครงการพัฒนาศักยภาพนักเรียน','สพม.เขต 29','ด่วน','นางสมศรี ดีงาม','รอลงนาม'),
  (2569,'ส.003/2569','06/05/2569','แจ้งรายชื่อครูเข้าร่วมอบรม','สพม.เขต 29','ด่วนที่สุด','นางสมศรี ดีงาม','ส่งแล้ว'),
  (2569,'ส.004/2569','08/05/2569','ขอความร่วมมือในการจัดกิจกรรมวันสำคัญ','องค์การบริหารส่วนตำบล','ปกติ','','ร่าง');

-- ============================================================
-- MEMOS (บันทึกข้อความ)
-- ============================================================
create table memos (
  id            uuid primary key default uuid_generate_v4(),
  year          int  not null,
  memo_no       text not null,
  title         text not null,
  to_person     text,
  status        text default 'ร่าง',
  content       text,
  file_url      text,
  file_name     text,
  file_drive_id text,
  attach_type   text,
  created_by    uuid references users(id),
  created_at    text,
  updated_at    timestamptz default now()
);
insert into memos (year,memo_no,title,to_person,status,created_at) values
  (2569,'บข.001/2569','ขออนุมัติดำเนินการซ่อมแซมอาคารเรียน','ผู้อำนวยการโรงเรียน','อนุมัติแล้ว','01/05/2569'),
  (2569,'บข.002/2569','รายงานผลการนิเทศการสอนภาคเรียนที่ 1/2569','ผู้อำนวยการโรงเรียน','รออนุมัติ','05/05/2569'),
  (2569,'บข.003/2569','ขอใช้งบประมาณจัดซื้อสื่อการสอน','ผู้อำนวยการโรงเรียน','ร่าง','08/05/2569');

-- ============================================================
-- ORDERS (คำสั่ง)
-- ============================================================
create table orders (
  id             uuid primary key default uuid_generate_v4(),
  year           int  not null,
  order_no       text not null,
  title          text not null,
  effective_date text,
  status         text default 'ร่าง',
  content        text,
  file_url       text,
  file_name      text,
  file_drive_id  text,
  attach_type    text,
  created_by     uuid references users(id),
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);
insert into orders (year,order_no,title,effective_date,status) values
  (2569,'คำสั่งที่ 01/2569','แต่งตั้งคณะกรรมการดำเนินงานสอบปลายภาค','15/05/2569','มีผลบังคับใช้'),
  (2569,'คำสั่งที่ 02/2569','แต่งตั้งคณะกรรมการรับนักเรียน ปีการศึกษา 2569','01/03/2569','มีผลบังคับใช้'),
  (2569,'คำสั่งที่ 03/2569','มอบหมายหน้าที่การสอนภาคเรียนที่ 1 ปีการศึกษา 2569','16/05/2569','ร่าง');

-- ============================================================
-- LOGS
-- ============================================================
create table logs (
  id         uuid primary key default uuid_generate_v4(),
  user_name  text,
  user_id    uuid references users(id),
  action     text not null,
  detail     text,
  created_at timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table users            enable row level security;
alter table school_config    enable row level security;
alter table number_formats   enable row level security;
alter table number_sequences enable row level security;
alter table incoming         enable row level security;
alter table outgoing         enable row level security;
alter table memos            enable row level security;
alter table orders           enable row level security;
alter table logs             enable row level security;

-- อนุญาตทุก operation ผ่าน anon key (ระบบจัดการ auth เอง)
create policy "anon_all" on users            for all using (true) with check (true);
create policy "anon_all" on school_config    for all using (true) with check (true);
create policy "anon_all" on number_formats   for all using (true) with check (true);
create policy "anon_all" on number_sequences for all using (true) with check (true);
create policy "anon_all" on incoming         for all using (true) with check (true);
create policy "anon_all" on outgoing         for all using (true) with check (true);
create policy "anon_all" on memos            for all using (true) with check (true);
create policy "anon_all" on orders           for all using (true) with check (true);
create policy "anon_all" on logs             for all using (true) with check (true);

-- ===== ตรวจสอบผลลัพธ์ =====
select table_name from information_schema.tables
where table_schema='public' order by table_name;
