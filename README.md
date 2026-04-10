# AWS High Availability Infrastructure with ECS Fargate & Terraform

Repositori ini berisi infrastruktur berbasis **Infrastructure as Code (IaC)** menggunakan Terraform untuk mendeploy aplikasi web sederhana ke **Amazon ECS (Elastic Container Service) Fargate**. Proyek ini juga mengintegrasikan **CI/CD Pipeline** menggunakan GitHub Actions.

## 🏗️ Topologi Infrastruktur

Infrastruktur ini dirancang dengan prinsip *High Availability* dan *Scalability*.



### Komponen Utama:
1.  **VPC (Virtual Private Cloud):** Jaringan terisolasi dengan rentang IP `10.0.0.0/16`.
2.  **Subnets:** Terdiri dari Public Subnet untuk **Application Load Balancer (ALB)** dan Bastion Host.
3.  **Application Load Balancer (ALB):** Sebagai pintu masuk utama yang mendistribusikan trafik ke container.
4.  **Amazon ECS Fargate:** Menjalankan container Docker tanpa perlu mengelola server (Serverless).
5.  **Amazon ECR (Elastic Container Registry):** Tempat penyimpanan Docker Image.
6.  **Amazon RDS (MySQL):** Database relasional yang ditempatkan di subnet khusus.
7.  **IAM Roles:** Izin akses untuk Task Execution agar ECS bisa mengambil image dari ECR dan menulis log ke CloudWatch.

---

## 🚀 Alur CI/CD (Otomasi)

Proyek ini menggunakan **GitHub Actions** untuk memastikan setiap perubahan kode pada `main` branch langsung dideploy ke AWS secara otomatis.



1.  **Developer** melakukan `git push` ke GitHub.
2.  **GitHub Actions** terpicu dan melakukan:
    * Login ke AWS menggunakan Credentials.
    * Build Docker Image dari `Dockerfile`.
    * Push Image ke **Amazon ECR**.
    * Update **ECS Task Definition** dengan image terbaru.
    * Deploy ke **ECS Service**.

---

## 🛠️ Persiapan & Instalasi

### Prasyarat
* Terraform installed.
* AWS CLI configured dengan akses Administrator.
* Akun GitHub dan Repository.

### Langkah-langkah Deployment

1.  **Clone Repository:**
    ```bash
    git clone https://github.com/username/repository-kamu.git
    cd repository-kamu
    ```

2.  **Inisialisasi Terraform:**
    ```bash
    terraform init
    ```

3.  **Deploy Infrastruktur:**
    ```bash
    terraform apply -auto-approve
    ```

4.  **Konfigurasi GitHub Secrets:**
    Masukkan variabel berikut ke **Settings > Secrets and variables > Actions** di repositori GitHub kamu:
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`

---

## 📂 Struktur File
* `provider.tf`: Konfigurasi provider AWS dan Region.
* `network.tf`: Definisi VPC, Subnet, Internet Gateway, dan Route Tables.
* `ecs_tier.tf`: Definisi Cluster, Task Definition, dan Service ECS.
* `elb_tier.tf`: Konfigurasi Load Balancer dan Target Group.
* `db_tier.tf`: Konfigurasi database RDS MySQL.
* `iam.tf`: Definisi Role dan Policy untuk akses antar layanan.
* `.github/workflows/deploy.yml`: Pipeline otomatisasi deployment.

---

## 📝 Catatan Penting
* **Keamanan:** Jangan pernah melakukan commit pada file `terraform.tfstate` atau mengekspos `ACCESS_KEY` di dalam kode.
* **Biaya:** Pastikan melakukan `terraform destroy` jika infrastruktur sudah tidak digunakan untuk menghindari tagihan yang membengkak.

---

### Cara Mengakses Web
Setelah semua proses selesai (Centang Hijau di GitHub Actions), ambil **DNS Name** dari Load Balancer melalui output Terraform:
```bash
terraform output alb_dns_name
```