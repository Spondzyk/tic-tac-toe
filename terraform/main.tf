# Definicja wersji Terraform wymaganej do uruchomienia projektu
terraform {
  required_providers {              #Terraform opiera się na wtyczkach zwanych "dostawcami" do interakcji z systemami
                                    #zdalnymi. Konfiguracje Terraform muszą zadeklarować, których dostawców wymagają, aby Terraform mógł je zainstalować i używać.
    aws = {
      source  = "hashicorp/aws"     # Jest to lokalizacja, z której Terraform ma pobrać dostawcę. W tym przypadku,
                                    # hashicorp/aws oznacza, że dostawca znajduje się w rejestrze dostawców HashiCorp.
      version = "~> 5.42.0"         # Określa wersję dostawcy ~> 5.42.0 oznacza, że Terraform użyje wersji dostawcy równorzędnej
                                    # lub nowszej niż 5.42.0,
    }
  }

  required_version = ">= 1.7.5"     # Określa minimalną wersję Terraforma wymaganą do uruchomienia projektu. (równorzędnej lub nowszej niż 1.7.5)
}

# Konfiguracja dostawcy AWS
provider "aws" {                    # Dostawcy umożliwiają Terraform interakcję z dostawcami usług w chmurze, dostawcami SaaS i innymi interfejsami API.
                                    # Ponadto wszystkie konfiguracje Terraform muszą deklarować, których dostawców wymagają, aby Terraform mógł je zainstalować i używać.
  region  = "us-east-1"             # Określenie regionu AWS, w którym będą tworzone zasoby
}

# Utworzenie VPC
resource "aws_vpc" "main" {         # Blok zasobów deklaruje zasób określonego typu o określonej nazwie lokalnej.
                                    # Terraform używa tej nazwy, gdy odnosi się do zasobu w tym samym module, ale nie ma ona znaczenia poza zakresem tego modułu.
  cidr_block       = "10.0.0.0/16"  # Zakres adresów IP dla VPC - Jest to zakres adresów IP, które są przypisywane do VPC. W przykładzie "10.0.0.0/16" oznacza,
                                    # że VPC będzie mieć dostępne adresy IP z zakresu od "10.0.0.0" do "10.0.255.255". Notacja "/16" określa, ile bitów jest przeznaczonych dla adresu sieci,
                                    # a reszta jest przeznaczona dla adresów hostów w sieci. Ogranicza, które adresy IP mogą być używane w ramach VPC.

  instance_tenancy = "default"      # Typ tenancji instancji (domyślny) - Wartość "default" oznacza, że instancje EC2 będą działały w domyślnym trybie tenancji,
                                    # co oznacza, że będą uruchamiane na sprzęcie współdzielonym z innymi klientami AWS.
                                    # "Tenancja" odnosi się do sposobu, w jaki zasoby są udostępniane i zarządzane w ramach infrastruktury chmurowej lub usług hostingowych.
                                    # Jest to koncepcja dotycząca sposobu alokacji i izolacji zasobów między różnymi klientami lub użytkownikami.
  tags = {
    Name = "main-vpc"               # Tagowanie VPC
                                    # Tagi są metadanymi przypisanymi do zasobów w celu ich opisu, identyfikacji i organizacji. Mogą być one używane do różnych celów,
                                    # takich jak identyfikacja zasobów, zarządzanie kosztami, grupowanie zasobów według funkcji, środowiska itp.
  }
}

# Utworzenie podsieci wewnątrz VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id                          # Identyfikator VPC, do którego należy podsieć
  cidr_block = "10.0.1.0/24"                            # Zakres adresów IP dla podsieci - "/24" oznacza, że pierwsze 24 bity adresu IP są przeznaczone dla adresu sieci,
                                                        # a pozostałe 8 bitów są przeznaczone dla adresów hostów w tej podsieci. Oznacza to, że podsieć ma 256 adresów IP hostów,
                                                        # Podsieć o takim zakresie adresów IP może obsługiwać do 254 urządzeń, a adres sieci to "10.0.1.0",
                                                        # a adresy hostów to od "10.0.1.1" do "10.0.1.254". Ta podsieć ma maskę podsieci "255.255.255.0".

  tags = {
    Name = "subnet"                                     # Tagowanie podsieci
  }
}

# Utworzenie bramy internetowej
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id                              # Identyfikator VPC, do którego należy brama internetowa

  tags = {
    Name = "gateway"                                    # Tagowanie bramy internetowej
  }
}

# Routing table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id                              # Identyfikator VPC, do którego należy tablica routingu

  route {
    cidr_block = "0.0.0.0/0"                            # Zakres adresów IP dla ruchu wychodzącego - "/0" oznacza, że nie ma maski podsieci, co oznacza, że wszystkie adresy IP są uwzględnione.
                                                        # Oznacza to, że dowolny ruch wychodzący jest dozwolony do wszystkich możliwych docelowych adresów IP.
    gateway_id = aws_internet_gateway.gw.id             # Identyfikator bramy internetowej dla ruchu wychodzącego
  }

  tags = {
    Name = "route-table"                                # Tagowanie tablicy routingu
  }
}

# Tworzymy skojarzenie między tabelą routingu a podsiecią.
resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.route_table.id       # Określamy, że to skojarzenie będzie dotyczyło tabeli routingu o nazwie "route_table" (wykorzystując jej identyfikator).
  subnet_id = aws_subnet.subnet.id                      # Określamy, że ta podsieć (o identyfikatorze "subnet") będzie powiązana z tą tabelą routingu.
}

# Grupa bezpieczenstwa
resource "aws_security_group" "security_group" {
  # Nazwa i opis grupy bezpieczeństwa
  name        = "security_group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id  # Przypisanie grupy bezpieczeństwa do VPC

  # Reguly przychodzacego ruchu
  ingress {
    from_port   = 22             # Określa numer portu, od którego ruch jest zezwolony.
    to_port     = 22             # Określa numer portu, do którego ruch jest zezwolony.
    protocol    = "tcp"          # Określa protokół, który jest zezwolony.
    cidr_blocks = ["0.0.0.0/0"]  # Przychodzący ruch na porcie 22 - Określa zakres adresów IP, które mogą wysyłać wychodzący ruch. Wartość "0.0.0.0/0" oznacza, że ruch jest dozwolony dla wszystkich adresów IP.
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Przychodzący ruch na porcie 8080
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Przychodzący ruch na porcie 3000
  }

  # Reguly wychodzacego ruchu
  egress {
    from_port   = 0              # Wartość 0 oznacza, że ruch może wyjść z dowolnego portu.
    to_port     = 0              # Wartość 0 oznacza, że ruch może być kierowany do dowolnego portu.
    protocol    = "-1"           # Wartość "-1" oznacza, że ruch jest dozwolony dla wszystkich protokołów.
    cidr_blocks = ["0.0.0.0/0"]  # Wychodzący ruch na wszystkie porty
  }

  tags = {
    Name = "security_group"      # Dodanie tagu do grupy bezpieczeństwa
  }
}

# Jest to deklaracja zasobu w Terraformie, który będzie generował klucz prywatny TLS.
resource "tls_private_key" "pk" {
  algorithm = "RSA"                                         # Algorytm RSA
  rsa_bits  = 4096                                          # Długość klucza 4096 bitów
}

# Jest to deklaracja zasobu w Terraformie, który będzie tworzył parę kluczy dla AWS.
resource "aws_key_pair" "kp" {
  key_name   = "myKey"                                      # Nazwa klucza w AWS
  public_key = tls_private_key.pk.public_key_openssh        # Użycie klucza publicznego TLS
}

# Tworzenie lokalnego pliku z kluczem prywatnym w formacie PEM
resource "local_file" "ssh_key" {
  filename = "${path.module}/myKey.pem"                     # Ścieżka do lokalnego pliku
  content  = tls_private_key.pk.private_key_pem             # Użycie klucza prywatnego w formacie PEM
}

# Zapisanie adresu IP instancji do pliku
resource "local_file" "instance_ip" {
  filename = "${path.module}/instance_ip.txt"               # Ścieżka do lokalnego pliku
  content  = aws_instance.tic_tac_toe_server.public_ip      # Użycie adresu IP publicznego instancji
}

# Utworzenie instancji EC2
resource "aws_instance" "tic_tac_toe_server" {
  # Określamy AMI (Amazon Machine Image), czyli obraz maszyny, na podstawie którego zostanie utworzona instancja EC2.
  # AMI to gotowy obraz systemu operacyjnego i aplikacji, który można uruchomić jako instancję w chmurze AWS.
  ami = "ami-0c101f26f147fa7fd"

  # Określamy typ instancji EC2, czyli konfigurację sprzętową, jaką będzie miała instancja.
  # "t2.micro" to jeden z najbardziej podstawowych typów instancji, oferujący ograniczone zasoby CPU i pamięci RAM.
  instance_type = "t2.micro"

  # Ustawienie, aby instancja otrzymała publiczny adres IP, który umożliwi komunikację z nią spoza sieci wirtualnej.
  associate_public_ip_address = true

  # Określenie identyfikatora podsieci, do której instancja zostanie przypisana
  subnet_id = aws_subnet.subnet.id

  # Określenie identyfikatora grupy zabezpieczeń VPC
  vpc_security_group_ids = [aws_security_group.security_group.id]

  # Określenie nazwy pary kluczy SSH, która będzie używana do uwierzytelniania się na instancji EC2
  key_name = aws_key_pair.kp.key_name

  # Określenie skryptu użytkownika, który zostanie uruchomiony podczas startu instancji EC2
  user_data = file("${path.module}/install_docker.sh")

  # Ustawienie, aby Terraform automatycznie zastępował skrypt użytkownika podczas zmiany
  user_data_replace_on_change = true

  # Określenie tagów przypisanych do instancji EC2
  tags = {
    Name = "tic_tac_toe"
  }
}