# AWS Infrastructure & Automated Configuration with Terraform, Ansible & GitHub Actions

+ Un pipeline completo de Infraestructura como Código (IaC) y Gestión de Configuración que despliega de forma automática una arquitectura web en AWS, aprovisiona un servidor Nginx con plantillas dinámicas Jinja2, gestiona secretos cifrados con Ansible Vault / AWS SSM Parameter Store y automatiza el flujo completo mediante GitHub Actions.

+ Automatización de infraestructura en la nube AWS combinando **Terraform** para el orquestado IaaS, **Ansible** para la gestión de configuración PaaS mediante inventario dinámico, y **GitHub Actions** como orquestador CI/CD GitOps.

+ El proyecto implementa un patrón de seguridad con **Ansible Vault** y **AWS Systems Manager Parameter Store (SSM)** para evitar la exposición de credenciales en el repositorio.

---

---

## 📐 Arquitectura del Sistema

El objetivo principal de este proyecto es demostrar una integración limpia entre **Terraform** (para el aprovisionamiento de infraestructura) y **Ansible** (para la configuración de servicios y software), eliminando las dependencias de IPs estáticas mediante **Inventarios Dinámicos** y protegiendo datos sensibles en la nube.

```plaintext
                                   ┌──────────────────────────────────┐
                                   │  GitHub Repository (main branch) │
                                   └────────────────┬─────────────────┘
                                                    │ (push / trigger)
                                                    ▼
                                   ┌──────────────────────────────────┐
                                   │     GitHub Actions Runner        │
                                   └─────────┬──────────────┬─────────┘
                                             │              │
                     ┌───────────────────────┘              └───────────────────────┐
                     │ (1. Apply IaC)                                               │ (2. Configure)
                     ▼                                                              ▼
       ┌──────────────────────────┐                                   ┌──────────────────────────┐
       │     Terraform Engine     │                                   │      Ansible Engine      │
       └─────────────┬────────────┘                                   └─────────────┬────────────┘
                     │                                                              │
                     ▼                                                              ▼
┌───────────────────────────────────────────┐                      ┌───────────────────────────────────────────┐
│              AWS Cloud                    │                      │            AWS Cloud (EC2)                │
│                                           │                      │                                           │
│  ├── EC2 Instance (Tag: Env=production)   │◄─────────────────────┼─── Dynamic Inventory (aws_ec2)            │
│  ├── Security Group (Ports 22, 80)        │                      │   ├── Decrypts Ansible Vault (AES-256)   │
│  └── SSM Parameter Store (SecureString)   │◄─────────────────────┼─── Reads SSM Parameter Store via API      │
│                                           │                      │   └── Deploys Nginx + Jinja2 Template     │
└─────────────────────────────────────────--┘                      └───────────────────────────────────────────┘
```

## Componentes clave
- Provisionamiento (Terraform): Declaración de la instancia EC2, Security Groups y parámetros en AWS SSM Parameter Store (`SecureString`).
- Configuración (Ansible Roles): Módulo nginx_webserver desacoplado y reutilizable que procesa plantillas `.j2`.
- Inventario Dinámico (`aws_ec2`): Descubrimiento de hosts en tiempo real mediante etiquetas de AWS sin hardcodear direcciones IP.
- Secretos Híbridos: Gestión dual mediante cifrado simétrico local (Ansible Vault) y gestión centralizada en la nube (AWS SSM KMS).
- GitOps & CI/CD: Pipeline automatizado en GitHub Actions con validaciones y ejecución mediante runners aislados.

## 📁 Estructura del Proyecto

```bash
aws-ansible-gitops-pipeline/
├── .github/
│   └── workflows/
│       └── iac_pipeline.yml     # Workflow ajustado a la raíz/iac
├── .gitignore                   # Archivo de exclusiones de Git
├── README.md                    # Documentación estilo aws-3-tier-terraform
├── docs/
│   └── images/                  # Carpeta para guardar las capturas
│       ├── pipeline-success.png
│       └── website-output.png
└── iac/                         # Carpeta raíz de la infraestructura
    ├── ansible.cfg
    ├── aws_ec2.yml
    ├── main.tf
    ├── site.yml
    └── roles/
        └── nginx_webserver/
```

## 🔧 Prerrequisitos
+ Si deseas ejecutar el proyecto de forma local en tu máquina o WSL:
    - AWS CLI configurado con credenciales (aws configure).
    - Terraform >= v1.5.0
    - Ansible >= v2.15.0
    - Colección de AWS para Ansible instalada: `ansible-galaxy collection install amazon.aws`
    - Librerías de Python requeridas: `pip install boto3 botocore`