# AWS High Availability Infrastructure with Terraform

Repositori ini berisi infrastruktur berbasis kode (IaC) untuk membangun arsitektur web 3-tier yang tahan banting (*highly available*) di AWS. Arsitektur ini memastikan aplikasi tetap berjalan meskipun terjadi gangguan pada salah satu data center (Availability Zone).

## 🏗️ Arsitektur Sistem

Infrastruktur ini mencakup komponen-komponen utama berikut:

* **VPC & Networking:** Custom VPC dengan 2 Public Subnet di AZ berbeda (`ap-southeast-1a` & `ap-southeast-1b`).
* **Application Load Balancer (ALB):** Sebagai entry point tunggal yang mendistribusikan trafik secara merata.
* **Auto Scaling Group (ASG):** Mengelola minimal 2 instance EC2 secara otomatis dengan fitur *Self-Healing*.
* **RDS Multi-AZ:** Database MySQL dengan replika standby di zona berbeda untuk *failover* otomatis.
* **Dynamic User Data:** Skrip bash otomatis yang menginstal Apache dan menampilkan lokasi AZ secara real-time di browser.



---

## 📂 Struktur File

| File | Deskripsi |
| :--- | :--- |
| `provider.tf` | Konfigurasi provider AWS. |
| `network.tf` | Definisi VPC, Subnets, IGW, dan Routing. |
| `web_tier.tf` | Konfigurasi ALB, ASG, Launch Template, dan Security Groups. |
| `db_tier.tf` | Konfigurasi RDS Multi-AZ dan DB Subnet Group. |
| `.gitignore` | Mencegah file sensitif (.tfstate) terunggah ke Git. |

---

## 🚀 Cara Menjalankan

### 1. Persiapan
Pastikan AWS CLI sudah terkonfigurasi:
```bash
aws configure
```

### 2. Deployment
Jalankan perintah Terraform secara berurutan:
```bash
terraform init
terraform plan
terraform apply
```

### 3. Verifikasi High Availability
Akses **DNS Name** dari Load Balancer di browser. Lakukan *refresh* untuk melihat trafik berpindah antar Availability Zone.

### 4. Instance Refresh
Jika kamu mengubah skrip `user_data`, ASG dikonfigurasi untuk melakukan **Rolling Update** secara otomatis melalui blok `instance_refresh`:
```hcl
instance_refresh {
  strategy = "Rolling"
}
```

---

## 🛡️ Keamanan Jaringan (Security Matrix)

Isolasi trafik diterapkan secara ketat menggunakan Security Groups:
1.  **ALB:** Menerima trafik HTTP (80) dari publik.
2.  **Web Server:** Hanya menerima trafik dari Security Group ALB.
3.  **Database:** Hanya menerima trafik port 3306 dari Security Group Web Server.

---

## 🧹 Membersihkan Resource
Jangan lupa hapus semua resource setelah selesai pengujian untuk menghindari biaya tambahan:
```bash
terraform destroy
```
```

---