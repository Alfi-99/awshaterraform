# AWS High Availability Infrastructure with Terraform

Repositori ini berisi kode Terraform untuk mendesain infrastruktur web 3-tier yang resilien di AWS. Arsitektur ini menggunakan prinsip *Multi-AZ* untuk menjamin ketersediaan tinggi pada lapisan *compute* dan *database*.

## 🏗️ Desain Arsitektur

Infrastruktur ini terdiri dari komponen-komponen berikut:

* **VPC & Networking:** VPC dengan CIDR `10.30.0.0/16` dan 2 Subnet Publik di Availability Zone (AZ) yang berbeda.
* **Application Load Balancer (ALB):** Berfungsi sebagai entitas tunggal untuk menerima trafik HTTP (Port 80) dan mendistribusikannya ke backend.
* **Auto Scaling Group (ASG):** Mengelola armada instance EC2 secara otomatis. Jika ada instance yang tidak sehat, ASG akan menggantinya secara otomatis.
* **RDS Multi-AZ:** Database MySQL yang berjalan dengan replika standby di AZ berbeda untuk *failover* otomatis jika terjadi gangguan pada zona utama.



---

## 📂 Struktur Project

| File | Deskripsi |
| :--- | :--- |
| `provider.tf` | Definisi provider AWS dan konfigurasi region. |
| `network.tf` | Resource VPC, Subnet, Internet Gateway, dan Route Table. |
| `web_tier.tf` | Konfigurasi Security Group web, ALB, Launch Template, dan ASG. |
| `db_tier.tf` | Konfigurasi Security Group database, Subnet Group, dan RDS Instance. |

---

## 🚀 Alur Kerja (Workflow)

Ikuti langkah-langkah berikut untuk melakukan deployment:

### 1. Inisialisasi
Langkah ini digunakan untuk mengunduh plugin provider AWS yang diperlukan oleh Terraform.
```bash
terraform init
```

### 2. Validasi & Perencanaan
Melihat perubahan apa saja yang akan dilakukan Terraform terhadap infrastruktur AWS sebelum eksekusi dilakukan.
```bash
terraform plan
```

### 3. Eksekusi (Deployment)
Menerapkan konfigurasi ke akun AWS. Pastikan kredensial AWS sudah terkonfigurasi di mesin lokal.
```bash
terraform apply
```
*(Ketik `yes` saat konfirmasi muncul. Estimasi waktu: 10-15 menit karena provisi database RDS).*

### 4. Penghapusan Resource
Untuk menghindari biaya yang tidak diinginkan setelah pengujian selesai, hapus seluruh resource dengan perintah:
```bash
terraform destroy
```

---

## 🛡️ Matriks Keamanan (Security Groups)

Sistem ini menerapkan isolasi trafik antar lapisan (*tier isolation*):

1.  **ALB Security Group:** Mengizinkan trafik masuk port 80 dari `0.0.0.0/0`.
2.  **Web Security Group:** Mengizinkan trafik port 80 **hanya** jika berasal dari Security Group ALB.
3.  **Database Security Group:** Mengizinkan trafik port 3306 (MySQL) **hanya** jika berasal dari Security Group Web.

---

## 🔍 Detail Spesifikasi

* **Region:** `ap-southeast-1` (Singapore)
* **OS:** Ubuntu 22.04 LTS
* **Instance Type:** `t3.micro`
* **Database:** MySQL 8.0 (Free Tier Eligible)
* **Scaling:** Minimal 2 instance, Maksimal 3 instance.

---

**Catatan Teknis:** - User data pada `web_tier.tf` secara otomatis menginstal Apache untuk keperluan *health check* Load Balancer.
- Gunakan perintah `terraform fmt` untuk menjaga kerapihan sintaks kode sebelum melakukan *commit*.