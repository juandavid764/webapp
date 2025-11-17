class Config:
    MYSQL_HOST = 'db'
    MYSQL_USER = 'miniweb_user'
    MYSQL_PASSWORD = 'miniweb_pass'
    MYSQL_DB = 'myflaskapp'
    SQLALCHEMY_DATABASE_URI = f'mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DB}'

