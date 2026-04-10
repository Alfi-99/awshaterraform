# Contoh untuk aplikasi web sederhana (Apache)
FROM ubuntu:22.04

# Install web server
RUN apt-get update && apt-get install -y apache2

# Copy file index kamu ke dalam container
# Pastikan kamu punya file index.html di folder yang sama
COPY index.html /var/www/html/index.html

# Jalankan apache di foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]