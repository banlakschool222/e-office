# 📚 e-สารบรรณโรงเรียน — คู่มือติดตั้ง

> GitHub Pages + Supabase + Google Drive  
> ฟรี 100% — รองรับ 10+ ผู้ใช้พร้อมกัน

---

## 🗂️ ไฟล์ในโปรเจค

```
index.html   ← แอปหลัก (แก้ CONFIG 4 บรรทัด)
schema.sql   ← SQL สำหรับสร้างฐานข้อมูล Supabase
README.md    ← คู่มือนี้
```

---

## ⏱️ เวลาที่ใช้ทั้งหมด: ประมาณ 30–45 นาที

---

## ขั้นตอนที่ 1 — สร้างฐานข้อมูล Supabase (10 นาที)

### 1.1 สมัครบัญชี Supabase
1. เปิด [supabase.com](https://supabase.com) → คลิก **Start your project**
2. สมัครด้วย GitHub หรืออีเมล (ฟรี)
3. คลิก **New project**
4. ตั้งค่า:
   - **Name**: `sarabun` (หรือชื่ออะไรก็ได้)
   - **Database Password**: ตั้งรหัสผ่านแข็งแกร่ง (จดไว้)
   - **Region**: `Southeast Asia (Singapore)`
5. รอประมาณ 2 นาที

### 1.2 รัน SQL สร้างตาราง
1. ในหน้า Supabase → คลิก **SQL Editor** (เมนูซ้าย)
2. คลิก **New query**
3. เปิดไฟล์ `schema.sql` → คัดลอกทั้งหมด → วางในช่อง SQL
4. คลิก **Run** (หรือ Ctrl+Enter)
5. ตรวจสอบผลลัพธ์ด้านล่าง — ควรเห็นรายชื่อตาราง 9 ตาราง

### 1.3 คัดลอก URL และ Key
1. คลิก **Settings** (เมนูซ้าย) → **API**
2. คัดลอก **Project URL** เช่น `https://abcxyz.supabase.co`
3. คัดลอก **anon public** key (ข้อความยาวที่ขึ้นต้นด้วย `eyJ...`)
4. จดไว้ใช้ในขั้นตอนที่ 3

---

## ขั้นตอนที่ 2 — ตั้งค่า Google Drive API (15 นาที)

> จำเป็นสำหรับการแนบไฟล์จาก Google Drive  
> ถ้ายังไม่ต้องการฟีเจอร์นี้ ข้ามไปขั้นตอนที่ 3 ได้เลย

### 2.1 สร้าง Google Cloud Project
1. เปิด [console.cloud.google.com](https://console.cloud.google.com)
2. คลิก **Select a project** → **New Project**
3. ชื่อ: `sarabun-school` → **Create**

### 2.2 เปิด Google Drive API
1. ในเมนูซ้าย → **APIs & Services** → **Library**
2. ค้นหา `Google Drive API` → คลิก → **Enable**
3. ค้นหา `Google Picker API` → คลิก → **Enable**

### 2.3 สร้าง API Key
1. **APIs & Services** → **Credentials** → **Create Credentials** → **API key**
2. คัดลอก API Key
3. คลิก **Restrict Key**:
   - Application restrictions: **HTTP referrers**
   - เพิ่ม: `https://YOUR_GITHUB_USERNAME.github.io/*`
   - API restrictions: เลือก **Google Drive API** และ **Google Picker API**
4. **Save**

### 2.4 สร้าง OAuth 2.0 Client ID
1. **Create Credentials** → **OAuth client ID**
2. ถ้าขึ้น Configure consent screen:
   - User Type: **External** → **Create**
   - App name: `e-สารบรรณโรงเรียน`
   - User support email: อีเมลของคุณ
   - Developer contact: อีเมลของคุณ
   - **Save and Continue** × 3 → **Back to Dashboard**
3. กลับมาสร้าง OAuth client ID:
   - Application type: **Web application**
   - Name: `sarabun-web`
   - Authorized JavaScript origins:
     ```
     https://YOUR_GITHUB_USERNAME.github.io
     http://localhost
     ```
   - **Create**
4. คัดลอก **Client ID** เช่น `123456789.apps.googleusercontent.com`

---

## ขั้นตอนที่ 3 — แก้ไข CONFIG ในไฟล์ index.html (2 นาที)

เปิดไฟล์ `index.html` ด้วย Notepad หรือ VS Code  
หาบรรทัด `const CONFIG = {` แล้วแก้ค่า 4 บรรทัด:

```javascript
const CONFIG = {
  supabase_url:  'https://abcxyz.supabase.co',        // ← ใส่ Project URL
  supabase_anon: 'eyJhbGciOiJIUzI1NiIsInR5c...',     // ← ใส่ anon key
  google_client_id: '123456789.apps.googleusercontent.com', // ← ใส่ Client ID
  google_api_key:   'AIzaSyXXXXXXXXX',                // ← ใส่ API Key
};
```

> 💡 ถ้ายังไม่มี Google Client ID ให้ใส่ `''` (ว่าง) ได้  
> ระบบจะทำงานปกติ แต่ปุ่ม "เลือกจาก Google Drive" จะไม่ทำงาน

---

## ขั้นตอนที่ 4 — อัปโหลดขึ้น GitHub Pages (5 นาที)

### 4.1 สร้าง Repository
1. เปิด [github.com](https://github.com) → **New repository**
2. ชื่อ: `sarabun` (หรืออะไรก็ได้)
3. **Public** (จำเป็นสำหรับ GitHub Pages ฟรี)
4. **Create repository**

### 4.2 อัปโหลดไฟล์
**วิธีง่ายที่สุด (ไม่ต้องใช้ Git):**
1. ในหน้า Repository ที่เพิ่งสร้าง → คลิก **uploading an existing file**
2. ลาก `index.html`, `schema.sql`, `README.md` วางลงไป
3. คลิก **Commit changes**

### 4.3 เปิด GitHub Pages
1. คลิก **Settings** (แถบบน) → **Pages** (เมนูซ้าย)
2. Source: **Deploy from a branch**
3. Branch: **main** → Folder: **/ (root)**
4. คลิก **Save**
5. รอ 1–2 นาที จะได้ URL เช่น:
   ```
   https://YOUR_USERNAME.github.io/sarabun/
   ```
6. แชร์ URL นี้ให้ทีมงาน 10 คน

---

## ขั้นตอนที่ 5 — ทดสอบการใช้งาน

เปิด URL → Login ด้วย:

| Username | Password | บทบาท |
|----------|----------|-------|
| `admin` | `admin123` | ผู้ดูแลระบบ |
| `director` | `dir123` | ผู้อำนวยการ |
| `staff` | `staff123` | ธุรการ |
| `teacher` | `teach123` | ครู |

> ⚠️ **เปลี่ยนรหัสผ่านทันที** หลัง login ครั้งแรก  
> ไปที่ ตั้งค่า → จัดการผู้ใช้ → แก้ไข

---

## ตั้งค่าข้อมูลโรงเรียน

1. Login ด้วย admin
2. ตั้งค่า → ข้อมูลโรงเรียน
3. กรอกชื่อโรงเรียน, สังกัด, ที่อยู่
4. สำหรับโลโก้: อัปโหลดรูปไปที่ Google Drive → แชร์เป็น "Anyone with the link" → ใช้ลิงก์นั้น

---

## 🔒 ความปลอดภัยเพิ่มเติม (แนะนำ)

### จำกัดการเข้าถึง Supabase เฉพาะ domain ของคุณ
1. Supabase Dashboard → **Settings** → **API**
2. **Allowed origins**: ใส่ `https://YOUR_USERNAME.github.io`

### เปิดใช้งาน Supabase Dashboard MFA
1. **Account** → **Security** → เปิด Two-factor authentication

---

## ❓ คำถามที่พบบ่อย

**Q: ข้อมูลหายไปหรือเปล่าถ้าแก้ไฟล์ index.html?**  
A: ไม่หาย ข้อมูลเก็บใน Supabase แยกจากไฟล์ HTML

**Q: ผู้ใช้ 10 คนเข้าพร้อมกันได้ไหม?**  
A: ได้ Supabase free tier รองรับ connection พร้อมกันได้มาก

**Q: แผน Free ของ Supabase มีข้อจำกัดอะไรบ้าง?**  
A: 500MB database, 50,000 rows/table, 5GB bandwidth/เดือน — เพียงพอมากสำหรับ 10 คน

**Q: Google Drive ใช้ได้กี่ GB?**  
A: 15GB ต่อบัญชี Google — ถ้าไม่พอสามารถสร้างบัญชีใหม่สำหรับโรงเรียนได้

**Q: ถ้า Supabase หยุดบริการฟรีในอนาคต?**  
A: ย้ายไปแผนชำระเงิน ($25/เดือน) หรือ export ข้อมูลออกมาใช้ฐานข้อมูลอื่นได้

---

## 📞 สอบถามเพิ่มเติม

หากติดปัญหาสามารถ:
- เปิด Issue ใน GitHub Repository นี้
- ตรวจสอบ Console ใน Browser (F12) เพื่อดู error message
- ตรวจสอบ Supabase Dashboard → **Logs** → **API**
