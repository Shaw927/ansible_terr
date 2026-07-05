# Ansible: ClickHouse + Vector + LightHouse

Playbook разворачивает и настраивает три сервиса на отдельных хостах в Yandex Cloud:
ClickHouse, Vector и LightHouse (вебка для ClickHouse).

## Инвентарь

Хосты создаются через Terraform (`terraform/main.tf`). Файл ansible/prod.yml
генерируется автоматически из шаблона `terraform/templates/inventory.tftpl`
и в репозиторий не коммитится (см. `.gitignore`).

Чтобы поднять хосты и получить инвентарь

    cd terraform
    terraform init
    terraform apply

## Что делает playbook

### Play ClickHouse
Устанавливает ClickHouse из официального apt-репозитория, добавляет GPG-ключ,
запускает и проверяет сервис на порту 9000.

### Play Vector
Скачивает дистрибутив Vector, распаковывает, разворачивает конфиг из шаблона
(`templates/vector.yaml.j2`), создаёт systemd unit и перезапускает сервис
при изменении конфига.

### Play LightHouse
Скачивает статику LightHouse с GitHub, ставит Nginx, разворачивает конфиг
из шаблона (`templates/lighthouse_nginx.conf.j2`) и запускает веб-сервер на порту 8080.

## Переменные

| Play       | Переменная           | Значение по умолчанию   |
|------------|-----------------------|--------------------------|
| clickhouse | clickhouse_version    | 24.8.4.13                |
| vector     | vector_version         | 0.42.0                   |
| lighthouse | lighthouse_http_port   | 8080                     |
| lighthouse | lighthouse_web_root    | /var/www/lighthouse      |
| lighthouse | lighthouse_version     | master                   |

Переменные задаются в `ansible/group_vars/*.yml`.

## Теги

- `clickhouse` — весь play ClickHouse
- `vector` — весь play Vector
- `lighthouse` — весь play LightHouse
- `distr` — скачивание и установка дистрибутивов
- `config` — конфиги и шаблоны
- `packages` — установка пакетов
- `service` — запуск/перезапуск сервисов

## Запуск

    cd ansible
    ansible-lint site.yml
    ansible-playbook -i prod.yml site.yml --check
    ansible-playbook -i prod.yml site.yml --diff
